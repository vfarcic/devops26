##############
# Upgrade jx #
##############

jx version

####################
# Create a cluster #
####################

# Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and make sure you have Azure admin permissions

echo "nexus:
  enabled: false
docker-registry:
  enabled: true
" | tee myvalues.yaml

jx create cluster aks \
    --cluster-name jxrocks \
    --resource-group-name jxrocks-group \
    --location eastus \
    --node-vm-size Standard_B2s \
    --nodes 3 \
    --default-admin-password=admin \
    --default-environment-prefix tekton \
    --git-provider-kind github \
    --namespace cd \
    --prow \
    --tekton \
    --batch-mode

#######################
# Destroy the cluster #
#######################

az aks delete \
    -n jxrocks \
    -g jxrocks-group \
    --yes

kubectl config delete-cluster jxrocks

kubectl config delete-context jxrocks

kubectl config unset \
    users.clusterUser_jxrocks-group_jxrocks

az group delete \
    --name jxrocks-group \
    --yes