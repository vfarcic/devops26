####################
# Create a cluster #
####################

# Install [AWS CLI](https://aws.amazon.com/cli/) and make sure you have AWS admin permissions

# Install [eksctl](https://github.com/weaveworks/eksctl)

export AWS_ACCESS_KEY_ID=[...] # Replace [...] with the AWS Access Key ID

export AWS_SECRET_ACCESS_KEY=[...] # Replace [...] with the AWS Secret Access Key

export AWS_DEFAULT_REGION=us-west-2

echo "nexus:
  enabled: false
" | tee myvalues.yaml

CLUSTER_NAME=jx-rocks

jx create cluster eks \
    --cluster-name $CLUSTER_NAME \
    --region $AWS_DEFAULT_REGION \
    --node-type t2.large \
    --nodes 3 \
    --nodes-min 3 \
    --nodes-max 6 \
    --default-admin-password=admin \
    --default-environment-prefix tekton \
    --git-provider-kind github \
    --namespace cd \
    --prow \
    --tekton

# When in doubt, use the default answers, except in the cases listed below
# Answer with `n` to `Would you like to register a wildcard DNS ALIAS to point at this ELB address?`
# Answer with `n` to `Would you like to enable long term logs storage? A bucket for provider eks will be created`

#############################
# Create Cluster Autoscaler #
#############################

ASG_NAME=$(aws autoscaling \
    describe-auto-scaling-groups \
    | jq -r ".AutoScalingGroups[] \
    | select(.AutoScalingGroupName \
    | startswith(\"eksctl-$CLUSTER_NAME-nodegroup\")) \
    .AutoScalingGroupName")

echo $ASG_NAME

aws autoscaling \
    create-or-update-tags \
    --tags \
    ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=true \
    ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=kubernetes.io/cluster/$CLUSTER_NAME,Value=true,PropagateAtLaunch=true

IAM_ROLE=$(aws iam list-roles \
    | jq -r ".Roles[] \
    | select(.RoleName \
    | startswith(\"eksctl-$CLUSTER_NAME-nodegroup\")) \
    .RoleName")

echo $IAM_ROLE

aws iam put-role-policy \
    --role-name $IAM_ROLE \
    --policy-name $CLUSTER_NAME-AutoScaling \
    --policy-document https://raw.githubusercontent.com/vfarcic/k8s-specs/master/scaling/eks-autoscaling-policy.json

mkdir -p charts

helm fetch stable/cluster-autoscaler \
    -d charts \
    --untar

rm -rf k8s-specs/aws/*

mkdir -p k8s-specs/aws

helm template charts/cluster-autoscaler \
    --name aws-cluster-autoscaler \
    --output-dir k8s-specs/aws \
    --namespace kube-system \
    --set autoDiscovery.clusterName=$CLUSTER_NAME \
    --set awsRegion=us-west-2 \
    --set sslCertPath=/etc/kubernetes/pki/ca.crt \
    --set rbac.create=true

kubectl apply \
    -n kube-system \
    -f k8s-specs/aws/cluster-autoscaler/*

#######################
# Destroy the cluster #
#######################

IAM_ROLE=$(aws iam list-roles \
    | jq -r ".Roles[] \
    | select(.RoleName \
    | startswith(\"eksctl-$CLUSTER_NAME-nodegroup\")) \
    .RoleName")

echo $IAM_ROLE

aws iam delete-role-policy \
    --role-name $IAM_ROLE \
    --policy-name $CLUSTER_NAME-AutoScaling

eksctl delete cluster -n $CLUSTER_NAME

# Delete unused volumes
for volume in `aws ec2 describe-volumes --output text| grep available | awk '{print $8}'`; do 
    echo "Deleting volume $volume"
    aws ec2 delete-volume --volume-id $volume
done
