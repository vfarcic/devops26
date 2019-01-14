####################
# Create a cluster #
####################

# Install gcloud CLI (https://cloud.google.com/sdk/docs/quickstarts) and make sure that you have GCP admin permissions

PROJECT=[...] # Replace [...] with the name of the GCP project (e.g. jx)

NAME=jx-rocks && ZONE=us-east1-b && MACHINE=n1-standard-2

MIN_NODES=3 && MAX_NODES=5 && PASS=admin

jx create cluster gke \
    -n $NAME \
    -p $PROJECT \
    -z $ZONE \
    -m $MACHINE \
    --min-num-nodes $MIN_NODES \
    --max-num-nodes $MAX_NODES \
    --default-admin-password=$PASS \
    --default-environment-prefix jx-rocks

# When in doubt, use the default answers

#######################
# Destroy the cluster #
#######################

gcloud container clusters delete $NAME --zone $ZONE --quiet
