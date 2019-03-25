##############
# Upgrade jx #
##############

jx version

####################
# Create a cluster #
####################

# Install gcloud CLI (https://cloud.google.com/sdk/docs/quickstarts) and make sure that you have GCP admin permissions

# Open https://console.cloud.google.com/cloud-resource-manager to create a new GCP project if you do not have one available already. Make sure to enable billing for that project.

PROJECT=[...] # Replace `[...]` with the name of the GCP project (e.g. jx).

echo "nexus:
  enabled: false
" | tee myvalues.yaml

# The command that follows uses `-b` to run in the batch mode and it assumes that this is not the first time you create a cluster with `jx`.
# If that's not the case and this is indeed the first time you're creating a `jx` cluster, it will not have some of the default values like GitHub user and the installation might fail.
# Please remove `-b` from the command if this is NOT the first time you're creating a cluster with `jx`.

jx create cluster gke \
    -n jx-rocks \
    -p $PROJECT \
    -z us-east1-b \
    -m n1-standard-2 \
    --min-num-nodes 3 \
    --max-num-nodes 5 \
    --default-admin-password=admin \
    --default-environment-prefix jx-rocks \
    --git-provider-kind github \
    --namespace cd \
    --prow -b

# If asked for input, use the default answers unless you're sure you want a non-standard setup.

#######################
# Destroy the cluster #
#######################

gcloud container clusters \
    delete jx-rocks \
    --zone us-east1-b \
    --quiet

# Remove unused disks to avoid reaching the quota (and save a bit of money)
gcloud compute disks delete \
    $(gcloud compute disks list \
    --filter="-users:*" \
    --format="value(id)")