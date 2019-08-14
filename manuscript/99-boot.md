## TODO

- [ ] Code
- [ ] Write
- [-] Code review static GKE
- [ ] Code review serverless GKE
- [-] Code review static EKS
- [-] Code review serverless EKS
- [-] Code review static AKS
- [-] Code review serverless AKS
- [-] Code review existing static cluster
- [-] Code review existing serverless cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com 

# Boot

NOTE: Validated (works) only with serverless GKE

NOTE: `--skip-installation`
NOTE: Changed the name of the cluster from `jx-rocks` to `jx-boot` because of phantom storage

* Create new **GKE** cluster: [gke-jx-serverless-boot.sh](TODO:)

```bash
# https://jenkins-x.io/getting-started/boot/

kubectl get nodes

GH_USER=[...]

CLUSTER_NAME=[...]

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-staging

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-production

open "https://github.com/jenkins-x/jenkins-x-boot-config.git"

# Fork it

git clone \
    https://github.com/$GH_USER/jenkins-x-boot-config.git \
    environment-$CLUSTER_NAME-dev

cd environment-$CLUSTER_NAME-dev

cat jx-requirements.yml \
    | sed -e \
    "s@clusterName: \"\"@clusterName: \"$CLUSTER_NAME\"@g" \
    | tee jx-requirements.yml

cat jx-requirements.yml \
    | sed -e \
    "s@nvironmentGitOwner: \"\"@nvironmentGitOwner: \"$GH_USER\"@g" \
    | tee jx-requirements.yml

PROJECT=[...] #  e.g., devops26

cat jx-requirements.yml \
    | sed -e \
    "s@project: \"\"@project: \"$PROJECT\"@g" \
    | tee jx-requirements.yml

# PROVIDER=[...] # e.g., gke

# cat jx-requirements.yml \
#     | sed -e \
#     "s@provider: gke@provider: $PROVIDER@g" \
#     | tee jx-requirements.yml

ZONE=[...] # e.g., us-east1

cat jx-requirements.yml \
    | sed -e \
    "s@zone: \"\"@zone: \"$ZONE\"@g" \
    | tee jx-requirements.yml

# https://github.com/jenkins-x/jx/issues/5039

cat jx-requirements.yml

jx boot # --batch-mode

git status

git add .

git commit -m "Initial setup"

git push

kubectl get pods

cat jenkins-x.yml

kubectl get ns

jx get env

# Explore the last commit

git push

# jx repo --batch-mode

cd ..

jx create quickstart \
    --filter golang-http \
    --project-name jx-boot \
    --batch-mode

jx get activity \
    --filter jx-boot/master \
    --watch

# ctrl+c

jx get activity \
    --filter environment-$CLUSTER_NAME-staging/master \
    --watch

# ctrl+c

kubectl get ns

jx get applications -e staging

STAGING_ADDR=[...]

curl $STAGING_ADDR

cd environment-$CLUSTER_NAME-dev

# env dir?

cat env/parameters.yaml

ls -1 ~/.jx/localSecrets/

ls -1 ~/.jx/localSecrets/jx-boot

cat ~/.jx/localSecrets/jx-boot/adminUser.yaml

cat ~/.jx/localSecrets/jx-boot/pipelineUser.yaml

cat ~/.jx/localSecrets/jx-boot/prow.yaml

env/parameters.yaml

kubectl get pods | grep docker

cat env/parameters.yaml \
    | sed -e \
    "s@enableDocker: false@enableDocker: true@g" \
    | tee env/parameters.yaml

jx boot

git status

git add .

git commit -m "Initial setup"

git push

kubectl get pods | grep docker

cd ../jx-boot

echo "Testing Docker Hub" \
    | tee README.md

git add .

git commit -m "A silly change"

git push --set-upstream origin master

jx get activity \
    --filter jx-boot/master \
    --watch

# ctrl+c

jx get activity \
    --filter environment-$CLUSTER_NAME-staging/master \
    --watch

# ctrl+c

# TODO: `ingress` section in `jx-requirements.yml`

# TODO: Change to external Docker registry

# TODO: Explore the files

# TODO: Destroy the cluster, create a new one, and re-run `jx boot`

# TODO: Explore storage

# jx profile cloudbees

# jx profile oss
```

## What Now?

```bash
cd ..

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-dev

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-staging

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-production

hub delete -y \
    $GH_USER/jx-boot

rm -rf environment-$CLUSTER_NAME-dev

rm -rf jx-boot

# Delete storage
```