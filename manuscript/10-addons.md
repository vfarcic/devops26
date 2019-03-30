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

# Extending Jenkins X Through Addons

So far, Jenkins X provided everything we need for continuous delivery out of the box. But, that might not always be the case. The chances are that sooner or later we'll need more tools that those that are included in the default installation. In such a case, we will have to add more tools to the cluster. We could do that by installing additional Helm charts or we can let Jenkins X help us with that as well. Since this is not the time and place to teach you Helm (I assume you already know how it works), we'll focus on the latter. We'll add a couple of additional tools to the cluster and explore how they can help us improve our processes.

But, before we do that, we might need to create a Jenkins X cluster.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [10-addons.sh](TODO:) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

We'll continue using the *go-demo-6* application. Please enter the local copy of the repository, unless you're there already.

```bash
cd go-demo-6
```

I> The commands that follow will reset your `master` with the contents of the `pr` branch that contains all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

```bash
git pull

git checkout pr

git merge -s ours master --no-edit

git checkout master

git merge pr

git push
```

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
jx import -b

jx get activities -f go-demo-6 -w
```

Please wait until the activity of the application shows that all the steps were executed successfully, and stop the watcher by pressing *ctrl+c*.

Now we can extend our cluster with additional tools.

## Using Addons To Extend Jenkins X

Jenkins X can be extended through addons and the first action we should perform is to check which ones are currently available.

```bash
jx get addons
```

My output is as follows.

```
NAME               CHART                         ENABLED STATUS VERSION
ambassador         datawire/ambassador
anchore            stable/anchore-engine
cb                 cb/core
flagger            flagger/flagger
gitea              jenkins-x/gitea
grafana            stable/grafana
istio              install/kubernetes/helm/istio
jx-build-templates jenkins-x/jx-build-templates
jx-prow            jenkins-x/prow
jx-sso-dex         jenkins-x/dex
jx-sso-operator    jenkins-x/sso-operator
knative-build      jenkins-x/knative-build
kubeless           incubator/kubeless
prometheus         stable/prometheus
tekton             jenkins-x/tekton
vault-operator     jenkins-x/vault-operator
```

As you can see, there are quite a few available addons. By the time you're reading this, the list will likely be bigger than those you can observe from my output. That should not matter much since our goal is not to go through all of them, but rather a only a few. We'll explore how to create (install) an addon that can be useful in our pipelines as well as to prepare for the objectives we'll define in the next chapter. Creating addons follows the same pattern, so knowing how to deal with a few should provide enough information to work with any.

The first addon we'll create is Anchore.

## Creating The Anchore Addon

One of the important things we're missing in our pipeline is security scanning. We are not yet confirming that our container images are safe to run.

There are many tools that we can use for security scanning and we do not have time to go through all the options available in the market. Instead, we'll focus on Anchore, simply because it is already available as one of the Jenkins X addons.

TODO: Describe Anchore

Creating an addon, in its simplest form, is very straightforward. All with have to do is execute `jx create addon`.

```bash
# echo "anchoreGlobal:
#   enableMetrics: True

# metrics:
#   enabled: True" \
#     | tee anchore-values.yaml

# jx create addon anchore \
#     -f anchore-values.yaml

jx create addon anchore

# jx create addon anchore \
#     -s anchoreGlobal.enableMetrics=true \
#     -s metrics.enabled=true

# helm get values anchore

# helm upgrade anchore stable/anchore-engine -i --reuse-values -f anchore-values.yaml --namespace anchore
```

TODO: Continue text

```
found dev namespace jx
Updating Helm repository...
Helm repository update done.
Namespace anchore created
 waiting for anchore deployment to be ready, this can take a few minutes
using stable version 2.3.97 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Created user admin API Token for addon server anchore-anchore-engine-core at http://anchore-engine.anchore.35.237.181.43.nip.io
```

```bash
jx get addons
```

```
NAME               CHART                         ENABLED STATUS   VERSION
ambassador         datawire/ambassador
anchore            stable/anchore-engine                 DEPLOYED 0.2.3
cb                 cb/core
flagger            flagger/flagger
gitea              jenkins-x/gitea
grafana            stable/grafana
istio              install/kubernetes/helm/istio
jx-build-templates jenkins-x/jx-build-templates
jx-prow            jenkins-x/prow
jx-sso-dex         jenkins-x/dex
jx-sso-operator    jenkins-x/sso-operator
knative-build      jenkins-x/knative-build
kubeless           incubator/kubeless
prometheus         stable/prometheus
tekton             jenkins-x/tekton
vault-operator     jenkins-x/vault-operator
```

```bash
kubectl -n anchore get pods
```

```
NAME                                           READY STATUS  RESTARTS AGE
anchore-anchore-engine-core-79fdddbd59-hz8wl   1/1   Running 0        7m
anchore-anchore-engine-worker-65584dcc7b-j86cv 1/1   Running 0        7m
anchore-postgresql-69dcd5bbc8-mzsv4            1/1   Running 0        7m
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
    APP_NAME = 'go-demo-6'
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
          dir('/home/jenkins/go/src/github.com/vfarcic/go-demo-6') {
            checkout scm
            sh "make unittest"
            sh "make linux"
            sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }
          dir('/home/jenkins/go/src/github.com/vfarcic/go-demo-6/charts/preview') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
          dir('/home/jenkins/go/src/github.com/vfarcic/go-demo-6') {
            script {
              sleep 15
              addr=sh(script: "kubectl -n jx-$ORG-$HELM_RELEASE get ing $APP_NAME -o jsonpath='{.spec.rules[0].host}'", returnStdout: true).trim()
              sh "ADDRESS=$addr make functest"
            }
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
          dir('/home/jenkins/go/src/github.com/vfarcic/go-demo-6') {
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
          dir('/home/jenkins/go/src/github.com/vfarcic/go-demo-6/charts/go-demo-6') {
            sh "jx step changelog --version v\$(cat ../../VERSION)"

            // release the helm chart
            sh "jx step helm release"

            // promote through all 'Auto' promotion Environments
            sh "jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)"
          }
          dir('/home/jenkins/go/src/github.com/vfarcic/go-demo-6') {
            script {
              sleep 15
              addr=sh(script: "kubectl -n jx-staging get ing $APP_NAME -o jsonpath='{.spec.rules[0].host}'", returnStdout: true).trim()
              sh "ADDRESS=$addr make functest"
              sh "ADDRESS=$addr make integtest"
            }
          }
        }
      }
    }
  }
}
```

```bash
git checkout -b anchore
```

```
Switched to a new branch 'anchore'
```

```bash
echo "This application uses Anchore" \
    | tee README.md

git add .

git commit -m "Testing anchore"

git push --set-upstream origin anchore

jx create pr \
  -t "Testing anchore" \
  --body "Title says is all" \
  -b

PR_ID=[...]

GH_USER=[...]

jx get activity -f go-demo-6 -w
```

```
...
vfarcic/go-demo-6/PR-46 #1
  Release                         6m49s     1m0s Succeeded
  Preview                         5m49s           https://github.com/vfarcic/go-demo-6/pull/46
    Preview Application           5m49s           http://go-demo-6.jx-vfarcic-go-demo-6-pr-46.35.237.181.43.nip.io
```

```bash
# The step that executes `make functest` might fail. Quick fix: increase the `sleep` step. Real fix: increase the number of replicas.

# *ctrl+c*

jx get previews
```

```
PULL REQUEST                                 NAMESPACE                  APPLICATION
https://github.com/vfarcic/go-demo-6/pull/46 jx-vfarcic-go-demo-6-pr-46 http://go-demo-6.jx-vfarcic-go-demo-6-pr-46.35.237.181.43.nip.io
```

```bash
PREVIEW_ENV=[...] # Namespace column without `jx-` prefix

jx get cve -e $PREVIEW_ENV
```

```
Image Severity Vulnerability URL Package Fix
```

```bash
# Add to `Jenkinsfile` inside the `CI Build and push snapshot` stage
```

```groovy
            sh "jx step post build --image docker.io/bitnami/mongodb:4.0.3"
            sh "jx step post build --image docker.io/library/debian:7"
```

```bash
# Add to `Jenkinsfile` inside the `Promote to Environments` stage
```

```groovy
            sh "jx step post build --image docker.io/bitnami/mongodb:4.0.3"
```

```bash
git add .

git commit -m "Still testing anchore"

git push

jx get activity -f go-demo-6 -w
```

```
...
vfarcic/go-demo-6/PR-46 #2
  Release                          1m1s     1m0s Succeeded
  Preview                            1s           https://github.com/vfarcic/go-demo-6/pull/46
    Preview Application              1s           http://go-demo-6.jx-vfarcic-go-demo-6-pr-46.35.237.181.43.nip.io
```

```bash
jx get cve -e $PREVIEW_ENV

anchore-cli --u $ANCHORE_CLI_USER --p $ANCHORE_CLI_PASS --url $ANCHORE_CLI_URL image wait openjdk:10-jdk

# Wait for a few moments if the output is empty and repeat the command

# open "https://github.com/anchore/anchore-cli/issues/6"

# TODO: Modify the pipeline to check CVE results.

# TODO: Enable prometheus metrics

# TODO: Enable events notification
```

## Prometheus

TODO: Move above anchore

```bash
echo "extraScrapeConfigs: |
  - job_name: anchore-api
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
    - targets:
      - anchore-anchore-engine:8228
    basic_auth:
      username: admin
      password: anchore
" | tee prom-values.yaml

jx create addon prometheus \
  -f prom-values.yaml

# TODO: Explore how to customize it.

PROM_ADDR=$(kubectl -n jx \
    get ing prometheus-server \
    -o jsonpath="{.spec.rules[0].host}")

open "http://$PROM_ADDR"

# Use *admin* as the username and the password

jx create addon grafana

GRAF_ADDR=$(kubectl -n jx \
    get ing     prometheus-server \
    -o jsonpath="{.spec.rules[0].host}")

open "http://$GRAF_ADDR"
```

TODO: Continue code

## Istio

NOTE: Except GKE

```bash
jx create addon istio
```

NOTE: GKE

```bash
gcloud beta container clusters \
    update jx-rocks \
    --update-addons=Istio=ENABLED \
    --istio-config=auth=MTLS_STRICT

kubectl -n istio-system \
    get pods,services
```

TODO: Code

## Flagger

TODO: Code

## Permanent Addons

TODO: Code

```bash
jx edit addon
```

## What Now?

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```