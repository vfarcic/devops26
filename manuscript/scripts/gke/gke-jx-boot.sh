####################
# Create a cluster #
####################

# Use the same `PROJECT` as when you created the `dev` repository with `jx boot`
PROJECT=[...] # Replace `[...]` with the name of the GCP project (e.g. jx).

# Use the same `CLUSTER_NAME` as when you created the `dev` repository with `jx boot`
CLUSTER_NAME=[...] # Replace `[...]` with the name of the cluster (e.g., jx-boot)

gcloud auth login

gcloud container clusters \
    create $CLUSTER_NAME \
    --project $PROJECT \
    --region us-east1 \
    --machine-type n1-standard-2 \
    --enable-autoscaling \
    --num-nodes 1 \
    --max-nodes 2 \
    --min-nodes 1

kubectl create clusterrolebinding \
    cluster-admin-binding \
    --clusterrole cluster-admin \
    --user $(gcloud config get-value account)

#####################
# Install Jenkins X #
#####################

cd environment-$CLUSTER_NAME-dev

git pull

jx boot

# Repeat the `jx boot` command if the process is aborted because of upgrading the `jx` CLI

git --no-pager diff origin/master..HEAD

# It likely modified the IP to match the one of the LB of the new cluster

cd ..

#######################
# Destroy the cluster #
#######################

gcloud container clusters \
    delete $CLUSTER_NAME \
    --region us-east1 \
    --quiet

# Remove unused disks to avoid reaching the quota (and save a bit of money)
gcloud compute disks delete \
    --zone us-east1-b \
    $(gcloud compute disks list \
    --filter="zone:us-east1-b AND -users:*" \
    --format="value(id)") --quiet
gcloud compute disks delete \
    --zone us-east1-c \
    $(gcloud compute disks list \
    --filter="zone:us-east1-c AND -users:*" \
    --format="value(id)") --quiet
gcloud compute disks delete \
    --zone us-east1-d \
    $(gcloud compute disks list \
    --filter="zone:us-east1-d AND -users:*" \
    --format="value(id)") --quiet
