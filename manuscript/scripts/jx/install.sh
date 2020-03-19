# Source: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

#####################
# Install Jenkins X #
#####################

# Replace `[...]` with the IP of the load balancer created when you installed the NGINX Ingress controller`

LB_IP=[...]

# Replace `[...]` with the domain that will be used to access Jenkins X and that is pointing to your LB. 
# If you don't have a domain, use `jenkinx.$LB_IP.nip.io` as the value.`

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

jx install \
    --provider $PROVIDER \
    --external-ip $LB_IP \
    --domain $DOMAIN \
    --default-admin-password=admin \
    --ingress-namespace $INGRESS_NS \
    --ingress-deployment $INGRESS_DEP \
    --default-environment-prefix jx-rocks \
    --git-provider-kind github

#######################
# Uninstall Jenkins X #
#######################

jx uninstall \
  --context $(kubectl config current-context) \
  -b