```bash
# Create a Kubernetes cluster

# Install Ingress

# Install tiller

helm repo add gitlab https://charts.gitlab.io/

helm repo update

LB_IP=[...] # Replace `[...]` with the IP of your load balancer

helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --set global.hosts.domain=$LB_IP.nip.io \
  --set global.hosts.https=false \
  --values helm/gitlab-values.yaml \
  --timeout 900 --wait

kubectl -n gitlab get secret \
    gitlab-gitlab-initial-root-password \
    -o jsonpath="{.data.password}" \
    | base64 --decode; echo

# Copy the output

open "http://gitlab.$LB_IP.nip.io"

# Sign in with user `root` and the password from the copied output

# Navigate to gravar > "Settings"
# Select "Access Token" from the left-hand menu
# Type `jx` as the Name, select the *api* checkbox
# Click the *Create personal access token* button

GL_TOKEN=[...] # Replace `[...]` with the token

# jx create git server \
#   -k gitlab \
#   -n gitlab \
#   -u http://gitlab.$LB_IP.nip.io/

PROVIDER=[...] # Change `[...]` to t your k8s provider (e.g., `aks`, `eks`, `gke`)

INGRESS_NS=ingress-nginx

INGRESS_DEP=nginx-ingress-controller

# The command that follows uses `-b` to run in the batch mode and it assumes that this is not the first time you create a cluster with `jx`.
# If that's not the case and this is indeed the first time you're creating a `jx` cluster, it will not have some of the default values like GitHub user and the installation might fail.

jx install \
    --provider $PROVIDER \
    --external-ip $LB_IP \
    --domain jenkinx.$LB_IP.nip.io \
    --default-admin-password=admin \
    --ingress-namespace $INGRESS_NS \
    --ingress-deployment $INGRESS_DEP \
    --tiller-namespace kube-system \
    --default-environment-prefix jx-rocks \
    --git-provider-kind gitlab \
    --git-provider-url http://gitlab.$LB_IP.nip.io \
    --git-username root \
    --git-api-token $GL_TOKEN \
    -b

# TODO: Switch to prow

# Paste the token when asked for `API Token`

open "http://jenkinx.$LB_IP.nip.io"
```