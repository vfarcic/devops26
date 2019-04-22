## TODO

- [ ] Code
- [ ] Write
- [ ] Code review GKE
- [ ] Code review EKS
- [ ] Code review AKS
- [ ] Code review existing cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# GitOps

## Cluster

TODO

### Uninstall the old jx

TODO

### New GKE

```bash
jx version

# PROJECT=[...] # Replace `[...]` with the name of the GCP project (e.g. jx).

# # Added `--gitops` and `--no-gitops-vault`
# jx create cluster gke \
#     -n jx-rocks \
#     -p $PROJECT \
#     -r us-east1 \
#     -m n1-standard-2 \
#     --min-num-nodes 1 \
#     --max-num-nodes 2 \
#     --default-admin-password=admin \
#     --default-environment-prefix jx-rocks \
#     --git-provider-kind github \
#     --no-tiller \
#     --gitops \
#     --no-gitops-vault \
#     -b

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml

# External IP
LB_IP=[...]

# The domain through which 
# we can access the applications
DOMAIN=serverless.$LB_IP.nip.io

# The Namespace where Ingress is running
INGRESS_NS=ingress-nginx

# The name of the NGINX Ingress Deployment
INGRESS_DEP=nginx-ingress-controller

PROVIDER=[...]

gcloud iam service-accounts \
    create vfarcic \
    --display-name "vfarcic"

gcloud iam service-accounts list

jx create terraform \
    -c jx-production=gke \
    --gke-project-id $PROJECT \
    --gke-zone us-east1-c \
    --gke-machine-type n1-standard-2 \
    --gke-min-num-nodes 3 \
    --gke-max-num-nodes 2 \
    --default-admin-password=admin \
    --default-environment-prefix jx-rocks \
    --git-provider-kind github \
    --no-tiller \
    --gitops \
    --no-gitops-vault

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
    --gitops \
    --no-gitops-vault \
    -b

# Use default answers, except...

# GitHub user name:
# API Token:
```

## What Now?

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

hub delete -y \
  $GH_USER/environment-jx-rocks-dev

rm -rf jenkins-x-dev-environment

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```