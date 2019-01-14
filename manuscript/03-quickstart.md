# Understanding The Structure Of A Jenkins X Project

## Cluster

Please use one of the Gists below to create a cluster with Jenkins X.

* **minikube* [minikube-jx.sh](https://gist.github.com/8ff4d268c9c1cfedb4a3258a7e8bd4fb)
* **GKE**: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* [eks-jx.sh](TODO:): **EKS** TODO:
* [aks-jx.sh](TODO:): **AKS** TODO:
* [jx.sh](TODO:): **Inside an existing cluster** TODO:

## Creating A Project

---

```bash
jx console

# Login with `admin`

jx create quickstart
```

```
? select the quickstart you wish to create  [Use arrows to move, type to filter]
> android-quickstart
  angular-io-quickstart
  aspnet-app
  dlang-http
  golang-http
  jenkins-cwp-quickstart
  jenkins-quickstart
  node-http
  node-http-watch-pipeline-activity
  open-liberty
  python-http
  rails-shopping-cart
  react-quickstart
  rust-http
  scala-akka-http-quickstart
  spring-boot-http-gradle
  spring-boot-rest-prometheus
  spring-boot-watch-pipeline-activity
  vertx-rest-prometheus
```

```bash
# Cancel with ctrl+c

jx create quickstart -l go -p jx-go -b true
```

```
Generated quickstart at /Users/vfarcic/code/devops26/jx-go
### NO charts folder /Users/vfarcic/code/devops26/jx-go/charts/golang-http
Created project at /Users/vfarcic/code/devops26/jx-go

No username defined for the current Git server!

Git repository created
performing pack detection in folder /Users/vfarcic/code/devops26/jx-go
--> Draft detected Go (65.746753%)
selected pack: /Users/vfarcic/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs/go
replacing placeholders in directory /Users/vfarcic/code/devops26/jx-go
app name: jx-go, git server: github.com, org: vfarcic, Docker registry org: vfarcic
skipping directory "/Users/vfarcic/code/devops26/jx-go/.git"
Using Git provider GitHub at https://github.com


About to create repository jx-go on server https://github.com with user vfarcic


Creating repository vfarcic/jx-go
Pushed Git repository to https://github.com/vfarcic/jx-go

Created Jenkins Project: http://jenkins.jx.jenkinx.34.73.64.91.nip.io/job/vfarcic/job/jx-go/

Watch pipeline activity via:    jx get activity -f jx-go -w
Browse the pipeline log via:    jx get build logs vfarcic/jx-go/master
Open the Jenkins console via    jx console
You can list the pipelines via: jx get pipelines
When the pipeline is complete:  jx get applications

For more help on available commands see: https://jenkins-x.io/developing/browsing/

Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!

Creating GitHub webhook for vfarcic/jx-go for url http://jenkins.jx.jenkinx.34.73.64.91.nip.io/github-webhook/
```

```bash
GH_USER=[...]

open "https://github.com/$GH_USER/jx-go"
```

![Figure 3-TODO: TODO:)](img/ch03/github-go-demo-6.png)

```bash
cd jx-go

ls -1
```

```
Dockerfile
Jenkinsfile
Makefile
OWNERS
OWNERS_ALIASES
README.md
charts
curlloop.sh
main.go
skaffold.yaml
watch.sh
```

```bash
cat Makefile
```

```
SHELL := /bin/bash
GO := GO15VENDOREXPERIMENT=1 go
NAME := jx-go
OS := $(shell uname)
MAIN_GO := main.go
ROOT_PACKAGE := $(GIT_PROVIDER)/$(ORG)/$(NAME)
GO_VERSION := $(shell $(GO) version | sed -e 's/^[^0-9.]*\([0-9.]*\).*/\1/')
PACKAGE_DIRS := $(shell $(GO) list ./... | grep -v /vendor/)
PKGS := $(shell go list ./... | grep -v /vendor | grep -v generated)
PKGS := $(subst  :,_,$(PKGS))
BUILDFLAGS := ''
CGO_ENABLED = 0
VENDOR_DIR=vendor

all: build

check: fmt build test

build:
	CGO_ENABLED=$(CGO_ENABLED) $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME) $(MAIN_GO)

test: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) test $(PACKAGE_DIRS) -test.v

full: $(PKGS)

install:
	GOBIN=${GOPATH}/bin $(GO) install -ldflags $(BUILDFLAGS) $(MAIN_GO)

fmt:
	@FORMATTED=`$(GO) fmt $(PACKAGE_DIRS)`
	@([[ ! -z "$(FORMATTED)" ]] && printf "Fixed unformatted files:\n$(FORMATTED)") || true

clean:
	rm -rf build release

linux:
	CGO_ENABLED=$(CGO_ENABLED) GOOS=linux GOARCH=amd64 $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME) $(MAIN_GO)

.PHONY: release clean

FGT := $(GOPATH)/bin/fgt
$(FGT):
	go get github.com/GeertJohan/fgt

GOLINT := $(GOPATH)/bin/golint
$(GOLINT):
	go get github.com/golang/lint/golint

$(PKGS): $(GOLINT) $(FGT)
	@echo "LINTING"
	@$(FGT) $(GOLINT) $(GOPATH)/src/$@/*.go
	@echo "VETTING"
	@go vet -v $@
	@echo "TESTING"
	@go test -v $@

.PHONY: lint
lint: vendor | $(PKGS) $(GOLINT) # ❷
	@cd $(BASE) && ret=0 && for pkg in $(PKGS); do \
	    test -z "$$($(GOLINT) $$pkg | tee /dev/stderr)" || ret=1 ; \
	done ; exit $$ret

watch:
	reflex -r "\.go$" -R "vendor.*" make skaffold-run

skaffold-run: build
	skaffold run -p dev
```

```bash
cat Dockerfile
```

```
FROM scratch
EXPOSE 8080
ENTRYPOINT ["/jx-go"]
COPY ./bin/ /
```

```bash
cat skaffold.yaml
```

```yaml
apiVersion: skaffold/v1alpha2
kind: Config
build:
  tagPolicy:
    envTemplate:
      template: "{{.DOCKER_REGISTRY}}/vfarcic/jx-go:{{.VERSION}}"
  artifacts:
  - imageName: changeme
    workspace: .
    docker: {}
  local: {}
deploy:
  kubectl:
    manifests:
profiles:
- name: dev
  build:
    tagPolicy:
      envTemplate:
        template: "{{.DOCKER_REGISTRY}}/vfarcic/jx-go:{{.DIGEST_HEX}}"
    artifacts:
    - docker: {}
    local: {}
  deploy:
    helm:
      releases:
      - name: jx-go
        chartPath: charts/jx-go
        setValueTemplates:
          image.repository: "{{.DOCKER_REGISTRY}}/vfarcic/jx-go"
          image.tag: "{{.DIGEST_HEX}}"
```

```bash
ls -1 charts
```

```
jx-go
preview
```

```bash
ls -1 charts/jx-go
```

```
Chart.yaml
Makefile
README.md
charts
templates
values.yaml
```

```bash
ls -1 charts/preview
```

```
Chart.yaml
Makefile
charts
requirements.yaml
templates
values.yaml
```

```bash
cat Jenkinsfile
```

```groovy
pipeline {
  agent {
    label "jenkins-go"
  }
  environment {
    ORG = 'vfarcic'
    APP_NAME = 'jx-go'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
  }
  stages {
    stage('CI Build and push snapshot') {
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('go') {
          dir('/home/jenkins/go/src/github.com/vfarcic/jx-go') {
            checkout scm
            sh "make linux"
            sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }
          dir('/home/jenkins/go/src/github.com/vfarcic/jx-go/charts/preview') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
    }
    stage('Build Release') {
      when {
        branch 'master'
      }
      steps {
        container('go') {
          dir('/home/jenkins/go/src/github.com/vfarcic/jx-go') {
            checkout scm

            // ensure we're not on a detached head
            sh "git checkout master"
            sh "git config --global credential.helper store"
            sh "jx step git credentials"

            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
            sh "jx step tag --version \$(cat VERSION)"
            sh "make build"
            sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
          }
        }
      }
    }
    stage('Promote to Environments') {
      when {
        branch 'master'
      }
      steps {
        container('go') {
          dir('/home/jenkins/go/src/github.com/vfarcic/jx-go/charts/jx-go') {
            sh "jx step changelog --version v\$(cat ../../VERSION)"

            // release the helm chart
            sh "jx step helm release"

            // promote through all 'Auto' promotion Environments
            sh "jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)"
          }
        }
      }
    }
  }
}
```

```bash
open "https://github.com/$GH_USER/jx-go/settings/hooks"

# Webhooks will not work with minikube. The first build will execute but those triggered with the webhook will not.
```

![Figure 3-TODO: TODO:)](img/ch03/github-go-demo-6-webhooks.png)

```bash
open "https://github.com/jenkins-x-quickstarts"

ls -1 ~/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs
```

```
D
appserver
csharp
dropwizard
go
gradle
imports.yaml
javascript
liberty
maven
php
python
ruby
rust
scala
swift
```

```bash
ls -1 ~/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs/go
```

```
Dockerfile
Makefile
charts
pipeline.yaml
preview
skaffold.yaml
watch.sh
```

```bash
kubectl get pods -o name
```

```
pod/jenkins-...
pod/jenkins-x-chartmuseum-...
pod/jenkins-x-controllercommitstatus-...
pod/jenkins-x-controllerrole-...
pod/jenkins-x-controllerteam-...
pod/jenkins-x-controllerworkflow-...
pod/jenkins-x-docker-registry-...
pod/jenkins-x-gcactivities-...
pod/jenkins-x-gcactivities-...
pod/jenkins-x-gcpods-...
pod/jenkins-x-gcpods-...
pod/jenkins-x-gcpreviews-...
pod/jenkins-x-heapster-...
pod/jenkins-x-mongodb-...
pod/jenkins-x-monocular-api-...
pod/jenkins-x-monocular-prerender-...
pod/jenkins-x-monocular-ui-...
pod/jenkins-x-nexus-...
```

```bash
jx console
```

![Figure 3-TODO: TODO:)](img/ch03/jx-console-go-demo-6.png)

```bash
jx get activities
```

```
STEP                                              STARTED AGO DURATION STATUS
vfarcic/environment-jx-rocks-production/master #1      25m13s    3m46s Succeeded 
  Checkout Source                                      22m20s       5s Succeeded 
  Validate Environment                                 22m15s      20s Succeeded 
  Update Environment                                   21m55s      28s Succeeded 
vfarcic/environment-jx-rocks-staging/master #1         25m23s    2m35s Succeeded 
  Checkout Source                                      23m45s       6s Succeeded 
  Validate Environment                                 23m38s      20s Succeeded 
  Update Environment                                   23m18s      30s Succeeded 
vfarcic/environment-jx-rocks-staging/master #2         18m11s    1m14s Succeeded 
  Checkout Source                                      17m52s       5s Succeeded 
  Validate Environment                                 17m47s      21s Succeeded 
  Update Environment                                   17m26s      29s Succeeded 
vfarcic/jx-go/master #1                                21m12s    4m17s Succeeded Version: 0.0.1
  Checkout Source                                      20m35s       7s Succeeded 
  CI Build and push snapshot                           20m28s          NotExecuted 
  Build Release                                        20m27s      46s Succeeded 
  Promote to Environments                              19m41s    2m46s Succeeded 
  Promote: staging                                     19m22s    2m26s Succeeded 
    PullRequest                                        19m22s    1m25s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-rocks-staging/pull/1 Merge SHA: 563c73b772066fe5ef76ed247de6a6d87ea64288
    Update                                             17m57s     1m1s Succeeded  Status: Success at: http://jenkins.jx.jenkinx.34.73.64.91.nip.io/job/vfarcic/job/environment-jx-rocks-staging/job/master/2/display/redirect
    Promoted                                           17m57s     1m1s Succeeded  Application is at: http://jx-go.jx-staging.jenkinx.34.73.64.91.nip.io
```

```bash
jx get activities -f jx-go -w
```

```
STEP                         STARTED AGO DURATION STATUS
vfarcic/jx-go/master #1           21m46s    4m17s Succeeded Version: 0.0.1
  Checkout Source                  21m9s       7s Succeeded
  CI Build and push snapshot       21m2s          NotExecuted
  Build Release                    21m1s      46s Succeeded
  Promote to Environments         20m15s    2m46s Succeeded
  Promote: staging                19m56s    2m26s Succeeded
    PullRequest                   19m56s    1m25s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-rocks-staging/pull/1 Merge SHA: 563c73b772066fe5ef76ed247de6a6d87ea64288
    Update                        18m31s     1m1s Succeeded  Status: Success at: http://jenkins.jx.jenkinx.34.73.64.91.nip.io/job/vfarcic/job/environment-jx-rocks-staging/job/master/2/display/redirect
    Promoted                      18m31s     1m1s Succeeded  Application is at: http://jx-go.jx-staging.jenkinx.34.73.64.91.nip.io
```

```bash
# Press ctrl+c when `Promothed` is shown.

# If using minikube: `jx console` > Click the *environment-jx-rocks-staging* > Wait until *PR-** job is created (5 min. reindexing interval) and the build is finished executing > Click the *Branches* tab > Click the *Run* button when hovering over the *master* job.

jx get build logs
```

```
? Which pipeline do you want to view the logs of?:   [Use arrows to move, type to filter]
> vfarcic/environment-jx-rocks-production/master
  vfarcic/environment-jx-rocks-staging/master
  vfarcic/jx-go/master
```

```bash
# Cancel with ctrl+c

jx get build logs -f jx-go

jx get build logs $GH_USER/jx-go/master

jx get pipelines
```

```
Name                                           URL                                                                                                      LAST_BUILD STATUS  DURATION
vfarcic/environment-jx-rocks-production/master http://jenkins.jx.jenkinx.34.73.64.91.nip.io/job/vfarcic/job/environment-jx-rocks-production/job/master/ #1         SUCCESS 226.24µs
vfarcic/environment-jx-rocks-staging/master    http://jenkins.jx.jenkinx.34.73.64.91.nip.io/job/vfarcic/job/environment-jx-rocks-staging/job/master/    #2         SUCCESS 74.296µs
vfarcic/jx-go/master                           http://jenkins.jx.jenkinx.34.73.64.91.nip.io/job/vfarcic/job/jx-go/job/master/                           #1         SUCCESS 257.106µs
```

```bash
jx get apps
``` 

```
APPLICATION STAGING PODS URL                                                PRODUCTION PODS URL
jx-go       0.0.1   1/1  http://jx-go.jx-staging.jenkinx.34.73.64.91.nip.io
```

```bash
jx get env
```

```
AME       LABEL       KIND        PROMOTE NAMESPACE     ORDER CLUSTER SOURCE                                                         REF PR
dev        Development Development Never   jx            0
staging    Staging     Permanent   Auto    jx-staging    100           https://github.com/vfarcic/environment-jx-rocks-staging.git
production Production  Permanent   Manual  jx-production 200           https://github.com/vfarcic/environment-jx-rocks-production.git
```

```bash
jx get apps -e staging
```

```
APPLICATION STAGING PODS URL
jx-go       0.0.1   1/1  http://jx-go.jx-staging.jenkinx.34.73.64.91.nip.io
```

```bash
jx get apps -e production
```

```bash
No applications found in environments production
```

```bash
open "https://github.com/$GH_USER/jx-go/releases"
```

![Figure 3-TODO: TODO:)](img/ch03/github-go-demo-6-releases.png)

## Cleanup

Destroy the cluster.

Install https://hub.github.com/

```bash
hub delete -y $GH_USER/environment-jx-rocks-staging

hub delete -y $GH_USER/environment-jx-rocks-production

hub delete -y $GH_USER/jx-go

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

cd ..

rm -rf jx-go
```
