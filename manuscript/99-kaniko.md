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

# kaniko

## Cluster

* Create new **GKE** cluster: [gke-jx-kaniko.sh](TODO:)
* Create new **EKS** cluster: [eks-jx-kaniko.sh](TODO:)
* Create new **AKS** cluster: [aks-jx-kaniko.sh](TODO:)
* Use an **existing** cluster: [install-kaniko.sh](TODO:)
* Use an **existing** cluster: [upgrade-kaniko.sh](TODO:)

```bash
# cd go-demo-6

# git pull

# git checkout pr

# git merge -s ours master --no-edit

# git checkout master

# git merge pr

# git push
```

```bash
# jx import --batch-mode

# jx get activities --filter go-demo-6 --watch
```

## Kaniko Manually

```bash
# TODO: Commands

# cd go-demo-6 # If you're not already there
```

## Kaniko Quickstart

```bash
jx create quickstart \
  --language go \
  --project-name jx-kaniko \
  --batch-mode

jx get activities \
    --filter jx-kaniko \
    --watch
```

## What Now?

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production
  
hub delete -y $GH_USER/jx-kaniko

rm -rf jx-kaniko

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
```
