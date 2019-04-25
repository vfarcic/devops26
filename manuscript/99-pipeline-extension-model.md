# Using The Extension Model in jenkins-x.yaml

Copying and pasting coode is one of developer's major sins. One of the first things we learn as developers is that duplicated code is hard to maintain. That's why we are creating libraries. We do not want to repeat ourselves and we even came up with a commonly used acronym DRY (don't repeat yourself). Jenkins users are sinful.

TODO: Repetition results in reinvention of the wheel

When we create pipelines thrugh static Jenkins X, every project gets a Jenkinsfile based on the pipeline residing in the buildpack we choose. If we have ten projects, there will be ten identical copies of the same Jenkinsfile. Over time, we'll modify those Jenkinsfiles and they might not all thee exactly the same. Even in those cases, most of Jenkinsfile contents will remain untouched. It does not matter whether 100% of Jenkinsfile contents is repeated across projects or that percentage drops. There is a high level of repetition.

TODO: Plugins > shared libraries

In the past, we fought repetition through Jenkins shared libraries. Whenever we

TODO: Shared libraries > executables

TODO: Extension model

## Creating A Kubernetes Cluster With Jenkins X

TODO: Rewrite

W> You might be used to the fact that until now we were always using the same Gists to create a cluster or install Jenkins X in an existing one. Those that follow are different.

If you kept the cluster from the previous chapter and it contains serverless Jenkinss X, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [TODO:](TODO:) Gist.

For your convenience, the Gists that will create a new Jenkins X cluster or install it inside an existing one are as follows.

* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

We will not need the `jx-prow` project we created in the previous chapter. If you are reusing the cluster and Jenkins X installation, you might want to remove it and save a bit of resources.

```bash
GH_USER=[...]

# TODO: Change to `--batch-mode`
jx delete application \
    $GH_USER/jx-serverless \
    -b
```

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

I> The commands that follow will reset your *go-demo-6* `master` with the contents of the `pr` branch that contains all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

```bash
cd go-demo-6

git pull

git checkout versioning

git merge -s ours master --no-edit

git checkout master

git merge versioning

git push

cd ..
```

Now we can explore Jenkins X Pipeline Extension Model.

## Pipeline Extension Model

```bash
cd go-demo-6

git checkout master

rm -f Jenkinsfile

# TODO: Change to `--batch-mode`
jx import -b
```

```
WARNING: No username defined for the current Git server!
performing pack detection in folder /Users/vfarcic/code/go-demo-6
--> Draft detected Go (42.156190%)
selected pack: /Users/vfarcic/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs/go

WARNING: Failed to apply the build pack in /Users/vfarcic/code/go-demo-6 due to mkdir /Users/vfarcic/code/go-demo-6/charts/preview: file exists
replacing placeholders in directory /Users/vfarcic/code/go-demo-6
app name: go-demo-6, git server: github.com, org: vfarcic, Docker registry org: devops24-book
skipping directory "/Users/vfarcic/code/go-demo-6/.git"
skipping ignored file "/Users/vfarcic/code/go-demo-6/charts/go-demo-6/charts/mongodb-5.3.0.tgz"
Creating GitHub webhook for vfarcic/go-demo-6 for url http://hook.cd.104.196.0.121.nip.io/hook

Watch pipeline activity via:    jx get activity -f go-demo-6 -w
Browse the pipeline log via:    jx get build logs vfarcic/go-demo-6/master
Open the Jenkins console via    jx console
You can list the pipelines via: jx get pipelines
When the pipeline is complete:  jx get applications

For more help on available commands see: https://jenkins-x.io/developing/browsing/

Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!
```

```bash
ls -1
```

```
Dockerfile
Makefile
OWNERS
OWNERS_ALIASES
README.md
charts
functional_test.go
go.mod
go.sum
jenkins-x.yml
main.go
main_test.go
production_test.go
skaffold.yaml
vendor
watch.sh
```

```bash
cat jenkins-x.yml
```

```yaml
buildPack: go
```

```bash
open "https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes"

open "https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/tree/master/packs/go"

open "https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/blob/master/packs/go/pipeline.yaml"

curl "https://raw.githubusercontent.com/jenkins-x-buildpacks/jenkins-x-kubernetes/master/packs/go/pipeline.yaml"
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
      - dir: /home/jenkins/go/src/REPLACE_ME_GIT_PROVIDER/REPLACE_ME_ORG/REPLACE_ME_APP_NAME/charts/preview
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
      - dir: /home/jenkins/go/src/REPLACE_ME_GIT_PROVIDER/REPLACE_ME_ORG/REPLACE_ME_APP_NAME/charts/REPLACE_ME_APP_NAME
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
curl "https://raw.githubusercontent.com/jenkins-x-buildpacks/jenkins-x-classic/master/packs/go/pipeline.yaml"
```

```yaml
agent:
  label: jenkins-go
  container: go
  dir: /home/jenkins/go/src/REPLACE_ME_GIT_PROVIDER/REPLACE_ME_ORG/REPLACE_ME_APP_NAME
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
      - groovy: git 'https://REPLACE_ME_GIT_PROVIDER/REPLACE_ME_ORG/REPLACE_ME_APP_NAME.git'
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
git checkout -b extension

# Increase the number of replicas

cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@replicaCount: 1@replicaCount: 3@g' \
    | tee charts/go-demo-6/values.yaml
```

```yaml
# Default values for Go projects.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
replicaCount: 3
image:
  repository: draft
  tag: dev
  pullPolicy: IfNotPresent
service:
  name: go-demo-6
  type: ClusterIP
  externalPort: 80
  internalPort: 8080
  annotations:
    fabric8.io/expose: "true"
    fabric8.io/ingress.annotations: "kubernetes.io/ingress.class: nginx"
resources:
  limits:
    cpu: 100m
    memory: 256Mi
  requests:
    cpu: 80m
    memory: 128Mi
probePath: /demo/hello?health=true
livenessProbe:
  initialDelaySeconds: 60
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
readinessProbe:
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
terminationGracePeriodSeconds: 10
go-demo-6-db:
  replicaSet:
    enabled: true


  usePassword: false
```

```bash
cat functional_test.go \
    | sed -e \
    's@fmt.Sprintf("http://@fmt.Sprintf("@g' \
    | tee functional_test.go

cat production_test.go \
    | sed -e \
    's@fmt.Sprintf("http://@fmt.Sprintf("@g' \
    | tee production_test.go

jx create step

# pullRequest
# build
# pre
# make unittest
```

```
Updated Jenkins X Pipeline file: jenkins-x.yml
```

```bash
cat jenkins-x.yml
```

```yaml
buildPack: go
pipelineConfig:
  agent: {}
  pipelines:
    pullRequest:
      build:
        preSteps:
        - sh: make unittest
```

```bash
git add .

git commit -m "Trying to extend the pipeline"

git push --set-upstream origin extension

# TODO: Change to `pullrequest`, `--title`, `--batch`, 
jx create pr \
    -t "Extensions" \
    --body "What I can say?" \
    -b
```

```
Created PullRequest #56 at https://github.com/vfarcic/go-demo-6/pull/56
```

```bash
BRANCH=[...] # e.g. `PR-56`

jx get build logs \
  --filter go-demo-6 \
  --branch $BRANCH

# If it fails, wait for a few moments and repeat

jx create step

# pullRequest
# promote
# post
# ADDRESS=`jx get preview --current 2>&1` make functest

cat jenkins-x.yml

git add .

git commit -m "Trying to extend the pipeline"

git push

# Wait for a few moments

jx get build logs
```

TODO: Continue code

TODO: Fail a test and use the `/retest` slash command

TODO: `replace` mode

TODO: Change the agent/image

TODO: Replace a lifecycle

TODO: Add integration tests to the staging repo

TODO: Add integration tests to the production repo

https://jenkins-x.io/architecture/jenkins-x-pipelines/#customising-the-pipelines
https://jenkins-x.io/architecture/build-packs


## What Now?

TODO: Rewrite

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you chose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-tekton-staging

hub delete -y \
  $GH_USER/environment-tekton-production

rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*
```