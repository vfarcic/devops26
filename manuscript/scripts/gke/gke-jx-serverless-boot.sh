##############
# Upgrade jx #
##############

jx version

####################
# Create a cluster #
####################

PROJECT=[...] # Replace `[...]` with the name of the GCP project (e.g. jx).

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

# Remove container images from GCR
IMAGE=go-demo-6
for TAG in $(gcloud container images \
    list-tags gcr.io/$PROJECT/$IMAGE \
    --format='get(tags)')
do
	gcloud container images \
        delete gcr.io/$PROJECT/$IMAGE:$TAG \
        --quiet
done
