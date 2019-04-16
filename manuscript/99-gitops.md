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

PROJECT=[...] # Replace `[...]` with the name of the GCP project (e.g. jx).

GH_USER=[...] # Replace `[...]` with GitHub username

echo "nexus:
  enabled: false
" | tee myvalues.yaml

# Added `--gitops true`
# Removed `-b`
jx create cluster gke \
    -n jx-rocks \
    -p $PROJECT \
    -r us-east1 \
    -m n1-standard-2 \
    --min-num-nodes 3 \
    --max-num-nodes 5 \
    --default-admin-password=admin \
    --default-environment-prefix jx-rocks \
    --git-provider-kind github \
    --gitops true \
    --vault true \
    --no-tiller true

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

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```