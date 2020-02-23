# Source: https://gist.github.com/cdc18fd7c439d4b39cd810e999dd8ce6

####################
# Create a cluster #
####################

# Follow the instructions from https://github.com/weaveworks/eksctl to intall eksctl if you do not have it already.

# If you already have eksctl, please make sure that you are running the latest version

export AWS_ACCESS_KEY_ID=[...] # Replace [...] with the AWS Access Key ID

export AWS_SECRET_ACCESS_KEY=[...] # Replace [...] with the AWS Secret Access Key

export AWS_DEFAULT_REGION=us-east-1

export CLUSTER_NAME=[...] # Replace `[...]` with the name of the cluster (e.g., jx-eks)

eksctl create cluster \
    --name $CLUSTER_NAME \
    --region $AWS_DEFAULT_REGION \
    --node-type t2.large \
    --nodes 3 \
    --nodes-max 6 \
    --nodes-min 3 \
    --asg-access \
    --managed

#######################
# Add ECR Permissions #
#######################

IAM_ROLE=$(aws iam list-roles \
    | jq -r ".Roles[] \
    | select(.RoleName \
    | startswith(\"eksctl-$CLUSTER_NAME-nodegroup\")) \
    .RoleName")

echo $IAM_ROLE

aws iam attach-role-policy \
    --role-name $IAM_ROLE \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

#############################
# Create Cluster Autoscaler #
#############################

mkdir -p charts

helm fetch stable/cluster-autoscaler \
    -d charts \
    --untar

mkdir -p k8s-specs/aws

helm template charts/cluster-autoscaler \
    --name aws-cluster-autoscaler \
    --output-dir k8s-specs/aws \
    --namespace kube-system \
    --set autoDiscovery.clusterName=$CLUSTER_NAME \
    --set awsRegion=$AWS_DEFAULT_REGION \
    --set sslCertPath=/etc/kubernetes/pki/ca.crt \
    --set rbac.create=true

kubectl apply \
    -n kube-system \
    -f k8s-specs/aws/cluster-autoscaler/*

#####################
# Install Jenkins X #
#####################

git clone \
    https://github.com/jenkins-x/jenkins-x-boot-config.git \
    environment-$CLUSTER_NAME-dev

cd environment-$CLUSTER_NAME-dev

# Modify `jx-requirements.yaml`

jx boot

# Repeat the `jx boot` command if the process is aborted because of upgrading the `jx` CLI

cd ..

#######################
# Destroy the cluster #
#######################

IAM_ROLE=$(aws iam list-roles \
    | jq -r ".Roles[] \
    | select(.RoleName \
    | startswith(\"eksctl-$CLUSTER_NAME-nodegroup\")) \
    .RoleName")

echo $IAM_ROLE

aws iam detach-role-policy \
    --role-name $IAM_ROLE \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

aws iam delete-role-policy \
    --role-name $IAM_ROLE \
    --policy-name $CLUSTER_NAME-AutoScaling

eksctl delete cluster \
    --name $CLUSTER_NAME

# Delete unused volumes
for volume in `aws ec2 describe-volumes --output text| grep available | awk '{print $8}'`; do 
    echo "Deleting volume $volume"
    aws ec2 delete-volume --volume-id $volume
done
