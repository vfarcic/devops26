## TODO

- [ ] Code
- [ ] Write
- [-] Code review static GKE
- [ ] Code review serverless GKE
- [-] Code review static EKS
- [ ] Code review serverless EKS
- [-] Code review static AKS
- [ ] Code review serverless AKS
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

# Upgrading The Cluster With JX Boot

## Cluster

* Create new **GKE** cluster with Jenkins X: [gke-jx-boot.sh](TODO:)

## Apps

```bash
# the ability to interactively ask questions to generate values.yaml based on JSON Schema
# the ability to create pull requests against the GitOps repo that manages your team/cluster
# the ability to store secrets in vault
# the ability to upgrade all apps to the latest version

# Planned features include:

# integrating kustomize to allow existing charts to be modified
# storing Helm repository credentials in vault
# taking existing values.yaml as defaults when asking questions based on JSON Schema during app upgrade
# only asking new questions during app upgrade
# jx get apps - the ability to list all apps that can be installed
# integration for bash completion

open "https://github.com/jenkins-x-apps"

# jx-app-statusbadge
# jx-app-sso
# jx-app-kuberhealthy
# jx-app-datadog
# jx-app-jacoco
# jx-app-cheese
# jx-app-athens
# jx-app-buildalerts
# jx-app-cert-manager
# jx-app-replicator
# jx-app-grafana
# jx-app-prometheus
# jx-app-istio
# jx-app-gke
# jx-app-test-lifecycle
# jx-app-ambassador
# jx-app-jenkins
# jx-app-anchore
# jx-app-gitea
# jx-app-sonarqube

# TODO: Change to something else (that works)
jx add app jx-app-istio

# Explore the PR
# Merge the PR

jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch

# *ctrl+c*

# TODO: Confirm that the app works

helm repo add istio.io \
    https://storage.googleapis.com/istio-release/releases/1.3.1/charts/

jx add app istio-init \
    --repository istio.io \
    --auto-merge

jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch

# *ctrl+c*

kubectl get crds | grep 'istio.io'

# There should be 23 CRDs

git pull

cp -r env/istio-init env/istio

cat env/istio/templates/app.yaml

# We should create a branch

cat env/istio/templates/app.yaml \
    | sed -e \
    's@istio-init@istio@g' \
    | tee env/istio/templates/app.yaml

# Might want to change `jenkins.io/chart-description` as well

cat env/requirements.yaml

echo "- name: istio
  repository: https://storage.googleapis.com/istio-release/releases/1.3.1/charts/
  version: 1.3.1" | tee -a env/requirements.yaml

git add .

git commit -m "Added Istio"

git push

jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --namespace istio-system \
    --watch

kubectl get namespaces

kubectl --namespace istio-system \
    get services

jx get apps

jx delete app istio

jx delete app istio-init
```

## Update

TODO: `jx add app` (e.g., prometheus)

TODO: Remove Nexus in `env/nexus/values.yaml`

TODO: Enable `backup` in `jx-requirements.yml`

TODO: Explore the `prowConfig` directory

TODO: Enable `autoUpdate` in `jx-requirements.yml`

TODO: Change `ingress` in `jx-requirements.yml` (including TLS)

TODO: Change `environments.ingress` in `jx-requirements.yml`

## Upgrade

```bash
kubectl get pods | grep docker

# It's empty

cat env/parameters.yaml \
    | sed -e \
    "s@enableDocker: false@enableDocker: true@g" \
    | tee env/parameters.yaml
```

```yaml
adminUser:
  password: vault:jx-boot/adminUser:password
  username: admin
enableDocker: true
pipelineUser:
  email: viktor@farcic.com
  token: vault:jx-boot/pipelineUser:token
  username: vfarcic
prow:
  hmacToken: vault:jx-boot/prow:hmacToken
```

```bash
# With local secrets we'd need to run `jx boot` locally

# If there's something wrong with Jenkins X inside the cluster, we can also run `jx boot` locally.

git status

git add .

git commit -m "Initial setup"

git push

jx get activities \
    --filter environment-$CLUSTER_NAME-dev \
    --watch

# TODO: Continue when https://github.com/jenkins-x/jx/issues/5381 is fixed


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

# TODO: Upgrade Jenkins X version

# TODO: Velero

# TODO: `autoUpdate` in `jx-requirements.yml`
```

## Recreate The Cluster

```bash
# Destroy the cluster and create a new one
# gke-jx-serverless-boot.sh

jx boot

# https://github.com/jenkins-x/jx/issues/5587

# TODO: Continue after the issue is closed

kubectl --namespace kube-system \
    get service jxing-nginx-ingress-controller \
    --output jsonpath="{.status.loadBalancer.ingress[0].ip}"
```

```
34.74.70.149
```

```bash
# Change DNSes of your domain

export DOMAIN=[...]

ping $DOMAIN

# Confirm that it is using the correct IP, and than wait some more

# Change `ingress.domain` (NOT `environments.ingress.domain`) in jx-requirements.yml

# Change `environments.ingress.domain` in jx-requirements.yml

git add .

git commit -m "Changed the domain"

git push

jx get activities \
    --filter environment-$CLUSTER_NAME-dev \
    --watch
```

## Extending The Boot Pipeline

TODO: Code

## What Now?

```bash
cd ..

export GH_USER=[...]

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-staging

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-production
```
