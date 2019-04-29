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

# Added `--gitops`. Replaced `-r` with `-z`. Removed `-b`
jx create cluster gke \
    --cluster-name jx-rocks \
    --project-id $PROJECT \
    --region us-east1 \
    --machine-type n1-standard-2 \
    --min-num-nodes 3 \
    --max-num-nodes 6 \
    --default-admin-password=admin \
    --default-environment-prefix tekton \
    --git-provider-kind github \
    --namespace cd \
    --prow \
    --tekton \
    --gitops

# Use default answers, except...

# GitHub user name:
# API Token:
```

## What Now?

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-tekton-staging

hub delete -y \
  $GH_USER/environment-tekton-production

hub delete -y \
  $GH_USER/environment-tekton-dev

rm -rf jenkins-x-dev-environment

rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*
```