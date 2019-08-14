##############
# Upgrade jx #
##############

jx version

####################
# Create a cluster #
####################

jx version

PROJECT=[...] # Replace `[...]` with the name of the GCP project (e.g. jx).

jx create cluster gke \
    --cluster-name jx-boot \
    --project-id $PROJECT \
    --region us-east1 \
    --machine-type n1-standard-2 \
    --min-num-nodes 1 \
    --max-num-nodes 2 \
    --skip-installation \
    --batch-mode

#######################
# Destroy the cluster #
#######################

gcloud container clusters \
    delete jx-boot \
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
