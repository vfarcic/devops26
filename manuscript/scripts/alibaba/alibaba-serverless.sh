https://gist.github.com/carlossg/1d60c766d9b7546ddb50b414dceb918eclear

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
    --KeyPairName jx-rocks2 \
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
    \"zoneid\": \"${REGION}a\",
    \"snat_entry\": true,
    \"cloud_monitor_flags\": false,
    \"public_slb\": true,
    \"worker_instance_type\": \"$VM_TYPE\",
    \"num_of_nodes\": 3,
    \"worker_system_disk_category\": \"cloud_efficiency\",
    \"worker_system_disk_size\": 120,
    \"worker_instance_charge_type\": \"PostPaid\",
    \"vpcid\": \"${VPC}\",
    \"vswitchid\": \"${VSWITCH}\",
    \"container_cidr\": \"172.20.0.0/16\",
    \"service_cidr\": \"172.21.0.0/20\",
    \"key_pair\": \"jx-rocks2\"
}" | tee cluster/alibaba-k8s.json

aliyun cs  POST /clusters \
    --header "Content-Type=application/json" \
    --body "$(cat cluster/alibaba-k8s.json)"

CLUSTER_ID=[...]

# Wait until the cluster is created

aliyun cs GET /k8s/${CLUSTER_ID}/user_config \
    | jq -r ".config" \
    | tee cluster/kubecfg-alibaba

export KUBECONFIG=$PWD/cluster/kubecfg-alibaba

kubectl get nodes

kubectl get storageclasses

kubectl patch \
    storageclass alicloud-disk-ssd \
    -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl get storageclasses

echo "chartmuseum:
  persistence:
    size: 20Gi
jenkins:
  Persistence:
    Size: 20Gi
monocular:
  mongodb:
    persistence:
      size: 20Gi
nexus:
  enabled: false" \
    | tee myvalues.yaml

NAMESPACE=jx-rocks-ns

cat << EOF > cluster/alibaba-namespace.json
{
    "Namespace": {
        "Namespace": "${NAMESPACE}",
    }
}
EOF

aliyun cr POST /namespace/${NAMESPACE} \
    --header "Content-Type=application/json" \
    --body "$(cat cluster/alibaba-namespace.json)"

cat << EOF > namespace.json
{
    "Namespace": {
        "AutoCreate": true,
        "DefaultVisibility": "public"
    }
}
EOF

# Create docker login password from the console

DOCKER_USERNAME=[...]

DOCKER_PASSWORD=[...]

jx install \
    --provider alibaba \
    --default-admin-password=admin \
    --default-environment-prefix tekton \
    --git-provider-kind github \
    --docker-registry=registry.${REGION}.aliyuncs.com \
    --docker-registry-org=${NAMESPACE} \
    --namespace cd \
    --prow \
    --tekton \
    --batch-mode
