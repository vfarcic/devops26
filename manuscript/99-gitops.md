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

* Create new static **GKE** cluster: [gke-jx-gitops.sh](TODO:)
* Create new serverless **GKE** cluster: [gke-jx-serverless-gitops.sh](TODO:)
* Create new static **EKS** cluster: [eks-jx-gitops.sh](TODO:)
* Create new serverless **EKS** cluster: [eks-jx-serverless-gitops.sh](TODO:)
* Create new static **AKS** cluster: [aks-jx-gitops.sh](TODO:)
* Create new serverless **AKS** cluster: [aks-jx-serverless-gitops.sh](TODO:)
* Use an **existing** static cluster: [install-gitops.sh](TODO:)
* Use an **existing** serverless cluster: [install-serverless-gitops.sh](TODO:)

```bash
# Use default answers, except...

# GitHub user name:
# API Token:
```

## What Now?

```bash
cd ..

GH_USER=[...]

# If serverless
ENVIRONMENT=tekton

# If static
ENVIRONMENT=jx-rocks

# If serverless
hub delete -y \
  $GH_USER/environment-$ENVIRONMENT-staging

# If serverless
hub delete -y \
  $GH_USER/environment-$ENVIRONMENT-production

# If serverless
hub delete -y \
  $GH_USER/environment-$ENVIRONMENT-dev

rm -rf ~/.jx/environments/$GH_USER/environment-$ENVIRONMENT-*
```