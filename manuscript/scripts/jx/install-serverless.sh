##############
# Upgrade jx #
##############

jx version

#####################
# Install Jenkins X #
#####################

# Replace `[...]` with the IP of the load balancer created when you installed the NGINX Ingress controller.
# An example command that retrieves the IP is as follows.
# kubectl get svc --all-namespaces -l app=nginx-ingress -l component=controller -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}"

LB_IP=[...]

# Replace `[...]` with the domain that will be used to access Jenkins X and that is pointing to your LB. 
# If you don't have a domain, use `serverless.$LB_IP.nip.io` as the value.`

DOMAIN=[...]

# Replace `[...]` with your Kubernetes provider.
# Execute `jx install --help | grep "provider="` to retrieve the list of the providers if you're unsure which one to set.
# Use `kubernetes` as the provider if none from the list match yours.

PROVIDER=[...]

# Replace `ingress-nginx` with the Namespace where the NGINX Ingress controller is installed

INGRESS_NS=ingress-nginx

# Replace `nginx-ingress-controller` with the name of the NGINX Ingress controller deployment

INGRESS_DEP=nginx-ingress-controller

echo "nexus:
  enabled: false
" | tee myvalues.yaml

# The command that follows uses `-b` to run in the batch mode and it assumes that this is not the first time you create a cluster with `jx`.
# If that's not the case and this is indeed the first time you're creating a `jx` cluster, it will not have some of the default values like GitHub user and the installation might fail.
# Please remove `-b` from the command if this is NOT the first time you're creating a cluster with `jx`.
# Remove `--ingress-*` arguments if you would like Jenkins X to install the NGINX Ingress controller

jx install \
    --provider $PROVIDER \
    --external-ip $LB_IP \
    --domain $DOMAIN \
    --default-admin-password=admin \
    --ingress-namespace $INGRESS_NS \
    --ingress-deployment $INGRESS_DEP \
    --default-environment-prefix tekton \
    --git-provider-kind github \
    --namespace cd \
    --no-tiller \
    --prow \
    --tekton \
    -b

#######################
# Uninstall Jenkins X #
#######################

jx uninstall \
  --context $(kubectl config current-context) \
  -b