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

git commit \
    --message "Testing anchore"

git push --set-upstream origin anchore

jx create pullrequest \
  --title "Testing anchore" \
  --body "Title says is all" \
  --batch-mode

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

git commit \
    --message "Still testing anchore"

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

ANCHORE_CLI_URL=http://$(kubectl -n anchore get ing anchore-engine -o jsonpath="{.spec.rules[0].host}")

anchore-cli --u admin --p anchore --url $ANCHORE_CLI_URL system status

anchore-cli --u admin --p anchore --url $ANCHORE_CLI_URL system wait

anchore-cli --u admin --p anchore --url $ANCHORE_CLI_URL system feeds list

anchore-cli --u admin --p anchore --url $ANCHORE_CLI_URL image list

anchore-cli --u admin --p anchore --url $ANCHORE_CLI_URL image add debian:7

anchore-cli --u admin --p anchore --url $ANCHORE_CLI_URL image wait debian:7

anchore-cli --u admin --p anchore --url $ANCHORE_CLI_URL image vuln debian:7 os

anchore-cli --u admin --p anchore --url $ANCHORE_CLI_URL image add openjdk:10-jdk

anchore-cli --u admin --p anchore --url $ANCHORE_CLI_URL image wait openjdk:10-jdk

anchore-cli --u admin --p anchore --url $ANCHORE_CLI_URL image vuln openjdk:10-jdk os

# Wait for a few moments if the output is empty and repeat the command

# open "https://github.com/anchore/anchore-cli/issues/6"

# TODO: Modify the pipeline to check CVE results.

# TODO: Enable prometheus metrics

# TODO: Enable events notification
```