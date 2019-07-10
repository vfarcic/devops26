# https://jenkins-x.io/news/alibaba-container-service-jenkins-x/

# Activate *Container Service*, *Resource Orchestration Service (ROS)*, *RAM*, and *Auto Scaling* services

# Create the [Container Service roles](https://www.alibabacloud.com/help/doc-detail/86484.htm?spm=a2c63.p38356.b99.38.663a333eMXExon).

# Download and install aliyun-cli (e.g., `brew install aliyun-cli`)

aliyun configure

REGION=ap-southeast-1

aliyun vpc CreateVpc \
    --VpcName jx-rocks \
    --Description "Jenkins X" \
    --RegionId ${REGION} \
    --CidrBlock 172.16.0.0/12

VPC_ID=[...]

aliyun vpc CreateVSwitch \
    --VSwitchName jx-rocks \
    --VpcId ${VPC_ID} \
    --RegionId ${REGION} \
    --ZoneId ${REGION}a \
    --Description "Jenkins X" \
    --CidrBlock 172.16.0.0/24

VSWITCH_ID=[...]

aliyun ecs ImportKeyPair \
    --KeyPairName jx-rocks \
    --RegionId ${REGION} \
    --PublicKeyBody "$(cat ~/.ssh/id_rsa.pub)"

VM_TYPE=ecs.n4.large

mkdir -p cluster

echo "{
    \"name\": \"jx-rocks\",
    \"cluster_type\": \"ManagedKubernetes\",
    \"disable_rollback\": true,
    \"timeout_mins\": 60,
    \"region_id\": \"${REGION}\",
    \"zoneid\": \"${REGION}b\",
    \"snat_entry\": true,
    \"cloud_monitor_flags\": false,
    \"public_slb\": true,
    \"worker_instance_type\": \"$VM_TYPE\",
    \"num_of_nodes\": 3,
    \"worker_system_disk_category\": \"cloud_efficiency\",
    \"worker_system_disk_size\": 120,
    \"worker_instance_charge_type\": \"PostPaid\",
    \"vpcid\": \"${VPC_ID}\",
    \"vswitchid\": \"${VSWITCH_ID}\",
    \"container_cidr\": \"192.168.0.0/16\",
    \"service_cidr\": \"10.0.0.0/20\",
    \"key_pair\": \"jx-rocks\"
}" | tee cluster/alibaba-k8s.json

aliyun cs POST /clusters \
    --header "Content-Type=application/json" \
    --body "$(cat cluster/alibaba-k8s.json)"

CLUSTER_ID=[...]

aliyun cs GET /k8s/${CLUSTER_ID}/user_config \
    | jq -r ".config" \
    | tee cluster/kubecfg-alibaba

# Repeat if error

export KUBECONFIG=$PWD/cluster/kubecfg-alibaba

aliyun ecs CreateInstance \
    --RegionId ${REGION} \
    --ZoneId ${REGION}a \
    --InstanceType ecs.t5-lc2m1.nano \
    --ImageId  \
    --help


kubectl get nodes

kubectl get storageclasses

kubectl patch \
    storageclass alicloud-disk-ssd \
    -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl get storageclasses

# open "https://cr.console.aliyun.com/"

open "https://cr.console.aliyun.com/$REGION/instances/namespaces"

# Create Namespace

# Convert it to *Public*

NAMESPACE=[...]

cat << EOF > cluster/alibaba-namespace.json
{
    "Namespace": {
        "Namespace": "${NAMESPACE}",
    }
}
EOF

aliyun cr PUT /namespace/${NAMESPACE} \
    --header "Content-Type=application/json" \
    --body "$(cat cluster/alibaba-namespace.json)"

aliyun cr POST /namespace/${NAMESPACE} \
    --header "Content-Type=application/json" \
    --body "$(cat cluster/alibaba-namespace.json)"

jx install \
    --provider alibaba \
    --default-admin-password=admin \
    --default-environment-prefix=jx-rocks \
    --docker-registry=registry.${REGION}.aliyuncs.com \
    --docker-registry-org=${NAMESPACE} \
    --tekton

# When in doubt, use the default answers, except in the case listed below
# Answer with `n` to `Would you like to enable long term logs storage? A bucket for provider eks will be created`

# Create docker login password from the console

# This is not Docker Hub, but the user in Alibaba
DOCKER_USERNAME=[...]

# This is not Docker Hub, but the password in Alibaba
DOCKER_PASSWORD=[...]

AUTH=$(echo -n "${DOCKER_USERNAME}:${DOCKER_PASSWORD}" | base64)

DATA=$(cat << EOF | base64
{
    "auths": {
        "registry.${REGION}.aliyuncs.com": {
            "auth": "${AUTH}"
        }
    }
}
EOF
)

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: jenkins-docker-cfg
  namespace: jx
data:
  config.json: ${DATA}
EOF
