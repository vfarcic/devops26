##############
# Upgrade jx #
##############

jx version

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

# The command that follows uses `-b` to run in the batch mode and it assumes that this is not the first time you create a cluster with `jx`.
# If that's not the case and this is indeed the first time you're creating a `jx` cluster, it will not have some of the default values like GitHub user and the installation might fail.
# Please remove `-b` from the command if this is NOT the first time you're creating a cluster with `jx`.

jx create cluster eks -n jx-rocks \
    -r $AWS_DEFAULT_REGION \
    --node-type t2.medium \
    --nodes 3 \
    --nodes-min 3 \
    --nodes-max 6 \
    --default-admin-password=admin \
    --default-environment-prefix jx-rocks \
    -b

# When in doubt, use the default answers, except in the case listed below
# Answer with `n` to `Would you like to register a wildcard DNS ALIAS to point at this ELB address?`

#############################
# Create Cluster Autoscaler #
#############################

ASG_NAME=$(aws autoscaling \
    describe-auto-scaling-groups \
    | jq -r ".AutoScalingGroups[] \
    | select(.AutoScalingGroupName \
    | startswith(\"eksctl-jx-rocks-nodegroup\")) \
    .AutoScalingGroupName")

echo $ASG_NAME

aws autoscaling \
    create-or-update-tags \
    --tags \
    ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=true \
    ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=kubernetes.io/cluster/jx-rocks,Value=true,PropagateAtLaunch=true

IAM_ROLE=$(aws iam list-roles \
    | jq -r ".Roles[] \
    | select(.RoleName \
    | startswith(\"eksctl-jx-rocks-nodegroup-0-NodeInstanceRole\")) \
    .RoleName")

echo $IAM_ROLE

aws iam put-role-policy \
    --role-name $IAM_ROLE \
    --policy-name jx-rocks-AutoScaling \
    --policy-document https://raw.githubusercontent.com/vfarcic/k8s-specs/master/scaling/eks-autoscaling-policy.json

helm install stable/cluster-autoscaler \
    --name aws-cluster-autoscaler \
    --namespace kube-system \
    --set autoDiscovery.clusterName=jx-rocks \
    --set awsRegion=us-west-2 \
    --set sslCertPath=/etc/kubernetes/pki/ca.crt \
    --set rbac.create=true --wait

#######################
# Destroy the cluster #
#######################

# Only if there are no other ELBs in that region. Otherwise, remove the LB manually.
LB_ARN=$(aws elbv2 describe-load-balancers | jq -r \
    ".LoadBalancers[0].LoadBalancerArn")

echo $LB_ARN

aws elbv2 delete-load-balancer \
    --load-balancer-arn $LB_ARN

IAM_ROLE=$(aws iam list-roles \
    | jq -r ".Roles[] \
    | select(.RoleName \
    | startswith(\"eksctl-jx-rocks-nodegroup-0-NodeInstanceRole\")) \
    .RoleName")

echo $IAM_ROLE

aws iam delete-role-policy \
    --role-name $IAM_ROLE \
    --policy-name jx-rocks-AutoScaling

eksctl delete cluster -n jx-rocks

# Delete unused volumes
for volume in `aws ec2 describe-volumes --output text| grep available | awk '{print $8}'`; do 
    echo "Deleting volume $volume"
    aws ec2 delete-volume --volume-id $volume
done
