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
" | tee myvalues.yaml

# Please replace [...] with a unique name (e.g., your GitHub user and a day and month).
# Otherwise, it might fail to create a registry.
CLUSTER_NAME=[...]

jx create cluster aks \
    --cluster-name $CLUSTER_NAME \
    --resource-group-name jxrocks-group \
    --location eastus \
    --node-vm-size Standard_D2s_v3 \
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
    -n $CLUSTER_NAME \
    -g jxrocks-group \
    --yes

kubectl config delete-cluster $CLUSTER_NAME

kubectl config delete-context $CLUSTER_NAME

kubectl config unset \
    users.clusterUser_jxrocks-group_$CLUSTER_NAME

az group delete \
    --name jxrocks-group \
    --yes
