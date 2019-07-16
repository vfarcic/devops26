## TODO

- [ ] Code
- [ ] Write
- [X] Code review static GKE
- [ ] Code review serverless GKE
- [X] Code review static EKS
- [ ] Code review serverless EKS
- [ ] Code review static AKS
- [ ] Code review serverless AKS
- [ ] Code review existing static cluster
- [ ] Code review existing serverless cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Managing Third-Party Applications

## Creating A Kubernetes Cluster With Jenkins X

TODO: Rewrite

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [TODO:](TODO:) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create a new static **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create a new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create a new static **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create a new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create a new static **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Create a new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** static cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

TODO: Intro to the next section

## Something

```bash
# NOTE: Output are from serverless Jenkins X

# If serverless
ENVIRONMENT=tekton

# If static
ENVIRONMENT=jx-rocks

rm -rf environment-$ENVIRONMENT-*

# Ignore the `no matches found` error

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-$ENVIRONMENT-staging.git

cd environment-$ENVIRONMENT-staging

cat env/requirements.yaml
```

```yaml
dependencies:
- name: exposecontroller
  version: 2.3.89
  repository: http://chartmuseum.jenkins-x.io
  alias: expose
- name: exposecontroller
  version: 2.3.89
  repository: http://chartmuseum.jenkins-x.io
  alias: cleanup
```

```bash
helm inspect chart stable/postgresql
```

```yaml
apiVersion: v1
appVersion: 11.3.0
description: Chart for PostgreSQL, an object-relational database management system
  (ORDBMS) with an emphasis on extensibility and on standards-compliance.
engine: gotpl
home: https://www.postgresql.org/
icon: https://bitnami.com/assets/stacks/postgresql/img/postgresql-stack-110x117.png
keywords:
- postgresql
- postgres
- database
- sql
- replication
- cluster
maintainers:
- email: containers@bitnami.com
  name: Bitnami
- email: cedric@desaintmartin.fr
  name: desaintmartin
name: postgresql
sources:
- https://github.com/bitnami/bitnami-docker-postgresql
version: 5.0.0
```

```bash
echo "- name: postgresql
  version: 5.0.0
  repository: https://kubernetes-charts.storage.googleapis.com" \
    | tee -a env/requirements.yaml

git add .

git commit -m "Added PostgreSQL"

git push

jx get activities \
    --filter environment-$ENVIRONMENT-staging \
    --watch
```

```
STEP                                                 STARTED AGO DURATION STATUS
vfarcic/environment-tekton-staging/master #1                 55s      31s Succeeded
  from build pack                                            55s      31s Succeeded
    Build Helm Apply                                         55s      31s Succeeded
    Git Merge                                                55s       0s Succeeded
    Git Source Vfarcic Environment Tekton Stag D2t2r        2m6s       1s Succeeded https://github.com/vfarcic/environment-tekton-staging
    Setup Jx Git Credentials                                 55s       1s Succeeded
    Nop                                                      54s      30s Succeeded
```

```bash
# Stop with *ctrl+c*

NAMESPACE=$(kubectl config view \
    --minify \
    --output jsonpath="{..namespace}")

kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

```
NAME              READY   STATUS    RESTARTS   AGE
jx-postgresql-0   1/1     Running   0          2m11s
```

```bash
cd ..

git clone \
    https://github.com/$GH_USER/environment-$ENVIRONMENT-production.git

cd environment-$ENVIRONMENT-production

echo "- name: postgresql
  version: 5.0.0
  repository: https://kubernetes-charts.storage.googleapis.com" \
    | tee -a env/requirements.yaml

helm inspect values stable/postgresql
```

```yaml
...
replication:
  enabled: false
  ...
```

```bash
echo "postgresql:
  replication:
    enabled: true" \
    | tee -a env/values.yaml

git add .

git commit -m "Added PostgreSQL"

git push

jx get activities \
    --filter environment-$ENVIRONMENT-production \
    --watch
```

```
STEP                                                 STARTED AGO DURATION STATUS
vfarcic/environment-tekton-production/master #1              46s      25s Succeeded
  from build pack                                            46s      25s Succeeded
    Build Helm Apply                                         46s      25s Succeeded
    Git Merge                                                46s       1s Succeeded
    Git Source Vfarcic Environment Tekton Prod Hkfbh         46s       1s Succeeded https://github.com/vfarcic/environment-tekton-production
    Setup Jx Git Credentials                                 46s       1s Succeeded
    Nop                                                      46s      25s Succeeded
```

```bash
# Stop with *ctrl+c*

kubectl \
    --namespace $NAMESPACE-production \
    get pods
```

```
NAME                     READY   STATUS    RESTARTS   AGE
jx-postgresql-master-0   1/1     Running   0          46s
jx-postgresql-slave-0    1/1     Running   0          46s
```

```bash
# NOTE: There is no promotion mechanism.
# NOTE: Comment on the option of running only in production.
# NOTE: Does not work well with app-specific tests

cd ..

jx create quickstart \
    --language go \
    --project-name prometheus \
    --batch-mode

jx get activities \
    --filter prometheus \
    --watch
```

```
STEP                                           STARTED AGO DURATION STATUS
vfarcic/prometheus/master #1                         2m23s    2m12s Succeeded Version: 0.0.1
  from build pack                                    2m23s    2m12s Succeeded
    Build Container Build                            2m23s      34s Succeeded
    Build Make Build                                 2m25s      33s Succeeded
    Build Post Build                                 2m23s      35s Succeeded
    Git Merge                                        2m25s       1s Succeeded
    Git Source Vfarcic Prometheus Master 72pr6       2m26s       1s Succeeded https://github.com/vfarcic/prometheus
    Promote Changelog                                2m22s      38s Succeeded
    Promote Helm Release                             2m22s      41s Succeeded
    Promote Jx Promote                               2m22s    2m11s Succeeded
    Setup Jx Git Credentials                         2m25s       2s Succeeded
    Nop                                              2m22s    2m11s Succeeded
  Promote: staging                                   1m37s    1m26s Succeeded
    PullRequest                                      1m37s    1m26s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/1 Merge SHA: 4876a5ee18f59e881590fd3073ea9c6a64db99ad
    Update                                             11s       0s Succeeded
```

```bash
# Stop with *ctrl+c*

# NOTE: Pushing image to EKS/ECR might fail the first time. If that happens, please go to ECR and manually create the repository *[USER]/prometheus*. 

kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

```
NAME                             READY   STATUS    RESTARTS   AGE
jx-postgresql-0                  1/1     Running   0          11m
jx-prometheus-54fb5668b8-79x8g   1/1     Running   0          18s
```

```bash
cd prometheus

helm inspect chart stable/prometheus
```

```yaml
apiVersion: v1
appVersion: 2.9.2
description: Prometheus is a monitoring system and time series database.
engine: gotpl
home: https://prometheus.io/
icon: https://raw.githubusercontent.com/prometheus/prometheus.github.io/master/assets/prometheus_logo-cb55bb5c346.png
maintainers:
- email: mgoodness@gmail.com
  name: mgoodness
- email: gianrubio@gmail.com
  name: gianrubio
name: prometheus
sources:
- https://github.com/prometheus/alertmanager
- https://github.com/prometheus/prometheus
- https://github.com/prometheus/pushgateway
- https://github.com/prometheus/node_exporter
- https://github.com/kubernetes/kube-state-metrics
tillerVersion: '>=2.8.0'
version: 8.11.3
```

```bash
cat charts/prometheus/requirements.yaml
```

```
cat: charts/prometheus/requirements.yaml: No such file or directory
```

```bash
echo "dependencies:
- name: prometheus
  alias: prometheus
  version: 8.11.3
  repository: https://kubernetes-charts.storage.googleapis.com" \
    | tee charts/prometheus/requirements.yaml

git add .

git commit -m "Added Prometheus dependency"

git push

jx get activities \
    --filter prometheus \
    --watch
```

```
STEP                                           STARTED AGO DURATION STATUS
...
vfarcic/prometheus/master #2                               1m46s    1m36s Succeeded Version: 0.0.2
  from build pack                                          1m46s    1m36s Succeeded
    Build Container Build                                  1m46s      12s Succeeded
    Build Make Build                                       1m47s       9s Succeeded
    Build Post Build                                       1m46s      12s Succeeded
    Git Merge                                              1m47s       2s Succeeded
    Git Source Vfarcic Prometheus Master Relea 58879       1m47s       1s Succeeded https://github.com/vfarcic/prometheus
    Promote Changelog                                      1m46s      16s Succeeded
    Promote Helm Release                                   1m46s      25s Succeeded
    Promote Jx Promote                                     1m46s    1m35s Succeeded
    Setup Jx Git Credentials                               1m47s       2s Succeeded
    Nop                                                    1m45s    1m35s Succeeded
  Promote: staging                                         1m17s     1m6s Succeeded
    PullRequest                                            1m17s     1m6s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/2 Merge SHA: 10c42ecfb2b833fb9f74a3b2a6e0dd1dc4122891
    Update                                                   11s       0s Succeeded
    Promoted                                                 11s       0s Succeeded  Application is at: http://prometheus.cd-staging.34.73.104.192.nip.io
```

```bash
# Stop with *ctrl+c*

kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

```
NAME                                                READY   STATUS    RESTARTS   AGE
jx-postgresql-0                                     1/1     Running   0          20m
jx-prometheus-58688db9b9-grv5f                      1/1     Running   0          41s
jx-prometheus-alertmanager-67976b65dd-rxl7m         1/2     Running   0          40s
jx-prometheus-kube-state-metrics-68fb7ddcbf-j98c9   1/1     Running   0          40s
jx-prometheus-node-exporter-hh49d                   1/1     Running   0          40s
jx-prometheus-node-exporter-jwm26                   1/1     Running   0          40s
jx-prometheus-node-exporter-s7lvh                   1/1     Running   0          40s
jx-prometheus-pushgateway-dc6cb8787-db876           1/1     Running   0          40s
jx-prometheus-server-7797d7b59d-9frb5               1/2     Running   0          40s
```

```bash
# NOTE: PRs would be difficult because helm does not (yet) support nested dependencies

git checkout -b remove-pr

rm -f \
    Dockerfile \
    Makefile \
    curlloop.sh \
    main.go \
    skaffold.yaml \
    watch.sh \
    charts/prometheus/templates/*.yaml

rm -rf charts/preview
```
### Serverless

```bash
curl https://raw.githubusercontent.com/jenkins-x-buildpacks/jenkins-x-kubernetes/master/packs/go/pipeline.yaml
```

```yaml
extends:
  import: classic
  file: go/pipeline.yaml
pipelines:
  pullRequest:
    build:
      steps:
      - sh: export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml
        name: container-build
    postBuild:
      steps:
      - sh: jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION
        name: post-build
    promote:
      steps:
      - dir: /home/jenkins/go/src/github.com/vfarcic/code/charts/preview
        steps:
        - sh: make preview
          name: make-preview
        - sh: jx preview --app $APP_NAME --dir ../..
          name: jx-preview

  release:
    build:
      steps:
      - sh: export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml
        name: container-build
      - sh: jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)
        name: post-build
    promote:
      steps:
      - dir: /home/jenkins/go/src/github.com/vfarcic/code/charts/code
        steps:
        - sh: jx step changelog --version v\$(cat ../../VERSION)
          name: changelog
        - comment: release the helm chart
          name: helm-release
          sh: jx step helm release
        - comment: promote through all 'Auto' promotion Environments
          sh: jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)
          name: jx-promote
```

```bash
curl https://raw.githubusercontent.com/jenkins-x-buildpacks/jenkins-x-classic/master/packs/go/pipeline.yaml
```

```yaml
agent:
  label: jenkins-go
  container: go
  dir: /home/jenkins/go/src/github.com/vfarcic/code
pipelines:
  pullRequest:
    setup:
      steps:
      - groovy: checkout scm
    build:
      steps:
      - sh: make linux
        name: make-linux
  release:
    setup:
      steps:
      - groovy: git 'https://github.com/vfarcic/code.git'
        when: "prow"
      - groovy: checkout scm
        when: "!prow"
      - sh: git checkout master
        name: git-checkout-master
        comment: ensure we're not on a detached head
        when: "!prow"
      - sh: git config --global credential.helper store
        when: "!prow"
        name: git-config
      - sh: jx step git credentials
        when: "!prow"
        name: git-credentials
    setVersion:
      steps:
      - sh: echo \$(jx-release-version) > VERSION
        name: next-version
        comment: so we can retrieve the version in later steps
      - sh: jx step tag --version \$(cat VERSION)
        name: tag-version
    build:
      steps:
      - sh: make build
        name: make-build
```

```bash
# TODO: https://github.com/jenkins-x/jx/pull/3934

echo "buildPack: go
pipelineConfig:
  pipelines:
    overrides:
      - pipeline: pullRequest
        type: replace
      - pipeline: release
        stage: build
        type: replace
" | tee jenkins-x.yml

jx step syntax validate pipeline
```

### Static

```bash
echo 'pipeline {
  agent {
    label "jenkins-go"
  }
  environment {
    ORG = "vfarcic"
    APP_NAME = "prometheus"
    CHARTMUSEUM_CREDS = credentials("jenkins-x-chartmuseum")
  }
  stages {
    /* TODO: Removed
    stage("CI Build and push snapshot") {
      when {
        branch "PR-*"
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container("go") {
          dir("/home/jenkins/go/src/github.com/vfarcic/prometheus") {
            checkout scm
            sh "make linux"
            sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }
          dir("/home/jenkins/go/src/github.com/vfarcic/prometheus/charts/preview") {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
    }
    */
    stage("Build Release") {
      when {
        branch "master"
      }
      steps {
        container("go") {
          dir("/home/jenkins/go/src/github.com/vfarcic/prometheus") {
            checkout scm

            sh "git checkout master"
            sh "git config --global credential.helper store"
            sh "jx step git credentials"

            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
            sh "jx step tag --version \$(cat VERSION)"
            // sh "make build" // TODO: Remove
            // sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml" // TODO: Remove
            // sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)" // TODO: Remove
          } 
        }
      }
    }
    stage("Promote to Environments") {
      when {
        branch "master"
      }
      steps {
        container("go") {
          dir("/home/jenkins/go/src/github.com/vfarcic/prometheus/charts/prometheus") {
            sh "jx step changelog --version v\$(cat ../../VERSION)"

            // release the helm chart
            sh "jx step helm release"

            // promote through all "Auto" promotion Environments
            sh "jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)"
          }
        }
      }
    }
  }
}' | tee Jenkinsfile
```

### All

```bash
git add .

git commit -m "Improved Jenkinsfile"

git push --set-upstream origin remove-pr

jx create pullrequest \
  --title "Remove PR" \
  --body "What I can say?" \
  --batch-mode

jx get activities \
    --filter prometheus \
    --watch

# Stop with *ctrl+c*

kubectl \
    --namespace $NAMESPACE-staging \
    get pods

kubectl \
    --namespace $NAMESPACE-staging \
    get ingress

# TODO: Merge the PR
# TODO: Switch to the master branch

helm inspect values stable/prometheus
```

```yaml
...
server:
  ...
  service:
    annotations: {}
    ...
```

```bash
echo 'prometheus:
  server:
    service:
      annotations:
        fabric8.io/expose: "true"
        fabric8.io/ingress.annotations: "kubernetes.io/ingress.class: nginx"' \
    | tee -a charts/prometheus/values.yaml

git add .

git commit -m "Added ingress"

git push

jx get activities \
    --filter prometheus \
    --watch

kubectl \
    --namespace $NAMESPACE-staging \
    get ingress

PROM_STAGING_ADDR=$(kubectl \
    --namespace $NAMESPACE-staging \
    get ingress prometheus-server \
    --output jsonpath="{.spec.rules[0].host}")

echo $PROM_STAGING_ADDR

open "http://$PROM_STAGING_ADDR"

jx get applications

# NOTE: Incorrrect. Check the version from GitHub

open "https://github.com/$GH_USER/prometheus/releases"

VERSION=[...] # Without `v`

jx promote prometheus \
    --version $VERSION \
    --env production \
    --batch-mode

# TODO: Resolve the conflict manually if `Rebasing PullRequest due to conflict`

kubectl \
    --namespace jx-production \
    get ingress

cd ../environment-$ENVIRONMENT-production

# If NOT EKS
LB_IP=$(kubectl \
  --namespace kube-system \
  get service jxing-nginx-ingress-controller \
  --output jsonpath="{.status.loadBalancer.ingress[0].ip}")

# If EKS
LB_HOST=$(kubectl \
  --namespace kube-system \
  get service jxing-nginx-ingress-controller \
  --output jsonpath="{.status.loadBalancer.ingress[0].hostname}")

# If EKS
echo $LB_HOST

# If EKS
export LB_IP="$(dig +short $LB_HOST \
    | tail -n 1)"

echo $LB_IP

PROM_ADDR=prometheus.$LB_IP.nip.io

git pull

echo "prometheus:
  server:
    service:
      annotations: {}
    ingress:
      enabled: true
      hosts:
      - $PROM_ADDR" \
    | tee -a env/values.yaml

git add .

git commit -m "Added prod domain"

git push

jx get activities \
    --filter environment-$ENVIRONMENT-production \
    --watch

kubectl \
    --namespace jx-production \
    get ingress

open "http://$PROM_ADDR"
```

## What Now?

TODO: Viktor: Rewrite

Now is a good time for you to take a break.

If you created a cluster only for the purpose of the exercises we executed, please destroy it. We'll start the next, and each other chapter from scratch as a way to save you from running your cluster longer than necessary and pay more than needed to your hosting vendor. If you created the cluster or installed Jenkins X using one of the Gists from the beginning of this chapter, you'll find the instructions on how to destroy the cluster or uninstall everything at the bottom.

If you did choose to destroy the cluster or to uninstall Jenkins X, please remove the repositories we created as well as the local files. You can use the commands that follow for that. Just remember to replace `[...]` with your GitHub user.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-$ENVIRONMENT-staging

hub delete -y \
  $GH_USER/environment-$ENVIRONMENT-production

hub delete -y $GH_USER/prometheus

rm -rf ~/.jx/environments/$GH_USER/environment-$ENVIRONMENT-*

rm -rf environment-$ENVIRONMENT-*

rm -rf prometheus
```

Finally, you might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just keep reading.
