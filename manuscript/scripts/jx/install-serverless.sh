# Source: https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037

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

jx install \
    --provider $PROVIDER \
    --external-ip $LB_IP \
    --domain $DOMAIN \
    --default-admin-password=admin \
    --ingress-namespace $INGRESS_NS \
    --ingress-deployment $INGRESS_DEP \
    --default-environment-prefix jx-rocks \
    --git-provider-kind github \
    --namespace jx \
    --prow \
    --tekton

#######################
# Uninstall Jenkins X #
#######################

jx uninstall \
  --context $(kubectl config current-context) \
  --batch-mode