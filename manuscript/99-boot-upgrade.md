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

https://github.com/jenkins-x/jx/issues/6067
https://github.com/jenkins-x/jx/issues/6066
https://github.com/jenkins-x/jx/issues/6132

## Cluster

* Create new **GKE** cluster with Jenkins X: [gke-jx-boot.sh](TODO:)

## Backup

```bash
CLUSTER_NAME=[...]

cd environment-$CLUSTER_NAME-dev

# Open `jx-requirements.yml` in an editor

# Change `storage.backup.enabled` to `true`

# Create a GCP bucket with the name `jx-backup`

# Change `velero: {}` to 
# ```yaml
# velero:
#   namespace: velero
# ```

ls -1 systems

ls -1 systems/velero-backups

ls -1 systems/velero-backups/templates

cat systems/velero-backups/templates/default-backup.yaml

# TODO: Modify spec.schedule

git pull

git add .

git commit -m "Added backups"

git push

jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch

jx get build logs

kubectl --namespace velero \
    get all

# TODO: Validate that the backups are being created
```

## Update

```bash
# TODO: Upgrade Jenkins X version

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

## Storage

TODO: Code

## Extending The Boot Pipeline

TODO: Code

## Manual and Auto Upgrades

```
 jx step boot upgrade
```

TODO: Enable `autoUpdate` in `jx-requirements.yml`

## Domain & TLS

```bash
# https://github.com/jenkins-x/jx/issues/5715
# https://github.com/jenkins-x/jx/issues/5763

# TODO: Remove
# kubectl --namespace kube-system \
#     get service jxing-nginx-ingress-controller \
#     --output jsonpath="{.status.loadBalancer.ingress[0].ip}"

# TODO: Remove
# Change the DNS in your domain registrar

# TODO: Remove
# DOMAIN=[...]

# TODO: Remove
# ping $DOMAIN

# TODO: Explain how to create a domain in GCP or somewhere

git pull

# Open `jx-requirements.yml` in an editor

# Set `ingress.domain` to the new domain
# Set `ingress.externalDNS` to `true`
# Set `ingress.tls.email` to your email
# Set `ingress.tls.enabled` to `true`
# Set `ingress.tls.production` to `true`

git add .

git commit -m "Changed the domain"

git push

jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch

# *ctrl+c*

# TODO: Confirm that it works

# TODO: Change `environments.ingress` in `jx-requirements.yml`
```

## Update

```bash
kubectl get pods | grep docker

# It's empty

cat env/parameters.yaml

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
```

## What Now?

```bash
cd ..

export GH_USER=[...]

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-staging

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-production
```
