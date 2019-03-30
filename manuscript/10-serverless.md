## TODO

- [ ] Code
- [ ] Write
- [ ] Code review GKE
- [ ] Code review EKS
- [ ] Code review AKS
- [ ] Code review existing cluster
- [ ] Diagrams
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Serverless

## Creating A Cluster

TODO: Gists are different
TODO: Added `--prow` and `--namespace cd`

* Create new **GKE** cluster with serverless Jenkins X: [gke-jx-serverless.sh](TODO:)
* Create new **EKS** cluster with serverless Jenkins X: [eks-jx-serverless.sh](TODO:)
* Create new **AKS** cluster with serverless Jenkins X: [aks-jx-serverless.sh](TODO:)
* Use an **existing** cluster with serverless Jenkins X: [install-serverless.sh](TODO:)

## Installing Serverless In An Existing Cluster

```bash
cat install-serverless.sh
```

```
setting the dev namespace to: cd
Namespace cd created
 Using helmBinary helm with feature flag: none
Context "jxrocks" modified.
Storing the kubernetes provider aks in the TeamSettings
role cluster-admin already exists for the cluster
clusterroles.rbac.authorization.k8s.io 'cluster-admin' already exists
created role cluster-admin
Git configured for user: Viktor Farcic and email vfarcic@farcic.com
Using helm2
Configuring tiller
Tiller Deployment is running in namespace kube-system
existing ingress controller found, no need to install a new one
Waiting for external loadbalancer to be created and update the nginx-ingress-controller service in kube-system namespace
Using external IP: 40.121.198.38
nginx ingress controller installed and configured
Lets set up a Git user name and API token to be able to perform CI/CD

Select the CI/CD pipelines Git server and user
Setting the pipelines Git server https://github.com and user name vfarcic.
Saving the Git authentication configuration
Assign AKS https://jxrocks-jxrocks-group-7f9f9b-63b2f783.hcp.eastus.azmk8s.io:443 a reader role for ACR jxrocks.azurecr.io
Current configuration dir: /Users/vfarcic/.jx
versionRepository: https://github.com/jenkins-x/jenkins-x-versions
Current configuration dir: /Users/vfarcic/.jx
options.Flags.CloudEnvRepository: https://github.com/jenkins-x/cloud-environments
options.Flags.LocalCloudEnvironment: false
Cloning the Jenkins X cloud environments repo to /Users/vfarcic/.jx/cloud-environments
Current configuration dir: /Users/vfarcic/.jx
options.Flags.CloudEnvRepository: https://github.com/jenkins-x/cloud-environments
options.Flags.LocalCloudEnvironment: false
Cloning the Jenkins X cloud environments repo to /Users/vfarcic/.jx/cloud-environments
Enumerating objects: 1378, done.
Total 1378 (delta 0), reused 0 (delta 0), pack-reused 1378
setting the dev namespace to: cd
Generated helm values /Users/vfarcic/.jx/extraValues.yaml
Creating Secret jx-install-config in namespace cd
Installing Jenkins X platform helm chart from: /Users/vfarcic/.jx/cloud-environments/env-aks

Installing knative into namespace cd
Current configuration dir: /Users/vfarcic/.jx
versionRepository:
using stable version 0.1.14 from charts of jenkins-x/knative-build from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Upgrading Chart 'upgrade --namespace cd --install --force --timeout 6000 --version 0.1.14 --set  --set tillerNamespace= --set build.auth.git.username=viktor@farcic.com --set build.auth.git.username=viktor@farcic.com --set build.auth.git.password=f4119453fe32db697f7c4fb476bac6dd86bd1a42 knative-build jenkins-x/knative-build'

Installing Prow into namespace cd
Current configuration dir: /Users/vfarcic/.jx
versionRepository:
using stable version 0.0.410 from charts of jenkins-x/prow from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Upgrading Chart 'upgrade --namespace cd --install --force --timeout 6000 --version 0.0.410 --set  --set tillerNamespace= --set build.auth.git.username=viktor@farcic.com --set user=viktor@farcic.com --set oauthToken=f4119453fe32db697f7c4fb476bac6dd86bd1a42 --set hmacToken=8ca29c869e4e4e09c1f27976dfc4fea323b6c81f1 jx-prow jenkins-x/prow'

Installing BuildTemplates into namespace cd
Current configuration dir: /Users/vfarcic/.jx
versionRepository:
using stable version 0.0.520 from charts of jenkins-x/jx-build-templates from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Upgrading Chart 'upgrade --namespace cd --install --force --timeout 6000 --version 0.0.520 jx-build-templates jenkins-x/jx-build-templates'
Waiting for tiller pod to be ready, service account name is tiller, namespace is cd, tiller namespace is kube-system
Waiting for cluster role binding to be defined, named tiller-role-binding in namespace cd
 tiller cluster role defined: cluster-admin in namespace cd
tiller pod running
Installing jx into namespace cd
using stable version 0.0.3629 from charts of jenkins-x/jenkins-x-platform from /Users/vfarcic/.jx/jenkins-x-versions
Installing jenkins-x-platform version: 0.0.3629
Adding values file /Users/vfarcic/.jx/cloud-environments/env-aks/myvalues.yaml
Adding values file /Users/vfarcic/.jx/adminSecrets.yaml
Adding values file /Users/vfarcic/.jx/extraValues.yaml
Adding values file /Users/vfarcic/.jx/cloud-environments/env-aks/secrets.yaml
Upgrading Chart 'upgrade --namespace cd --install --timeout 6000 --version 0.0.3629 --values /Users/vfarcic/.jx/cloud-environments/env-aks/myvalues.yaml --values /Users/vfarcic/.jx/adminSecrets.yaml --values /Users/vfarcic/.jx/extraValues.yaml --values /Users/vfarcic/.jx/cloud-environments/env-aks/secrets.yaml jenkins-x jenkins-x/jenkins-x-platform'
waiting for install to be ready, if this is the first time then it will take a while to download images
Jenkins X deployments ready in namespace cd
Configuring the TeamSettings for Prow with engine KnativeBuild
Configuring the TeamSettings for ImportMode Jenkinsfile


        ********************************************************

             NOTE: Your admin password is: admin

        ********************************************************


Creating default staging and production environments
Using vfarcic environment git owner in batch mode.
Using Git provider GitHub at https://github.com


About to create repository environment-jx-rocks-staging on server https://github.com with user vfarcic


Creating repository vfarcic/environment-jx-rocks-staging
Git repository vfarcic/environment-jx-rocks-staging already exists
Pushed Git repository to https://github.com/vfarcic/environment-jx-rocks-staging

Creating staging Environment in namespace cd
Created environment staging
Namespace cd-staging created
 Creating GitHub webhook for vfarcic/environment-jx-rocks-staging for url /hook
Using Git provider GitHub at https://github.com


About to create repository environment-jx-rocks-production on server https://github.com with user vfarcic


Creating repository vfarcic/environment-jx-rocks-production
Git repository vfarcic/environment-jx-rocks-production already exists
Pushed Git repository to https://github.com/vfarcic/environment-jx-rocks-production

Creating production Environment in namespace cd
Created environment production
Namespace cd-production created
 Creating GitHub webhook for vfarcic/environment-jx-rocks-production for url /hook
No service called jenkins-x-chartmuseum could be found so couldn't wire up the local auth file to talk to chart museum

Jenkins X installation completed successfully


        ********************************************************

             NOTE: Your admin password is: admin

        ********************************************************



Your Kubernetes context is now set to the namespace: cd
To switch back to your original namespace use: jx namespace jx
Or to use this context/namespace in just one terminal use: jx shell
For help on switching contexts see: https://jenkins-x.io/developing/kube-context/

To import existing projects into Jenkins:       jx import
To create a new Spring Boot microservice:       jx create spring -d web -d actuator
To create a new microservice from a quickstart: jx create quickstart
```

## Creating A New Serverless Jenkins X Cluster

```bash
cat gke-jx-serverless.sh

cat eks-jx-serverless.sh

cat aks-jx-serverless.sh
```

## Exploring Serverless Jenkins X

```bash
kubectl -n cd get pods
```

```
NAME                                               READY   STATUS      RESTARTS   AGE
build-controller-6d8c58db8b-wz99p                  1/1     Running     0          55m
buildnum-77bdbb8bb-g59qv                           1/1     Running     0          53m
crier-766b799476-5bdvr                             1/1     Running     0          53m
deck-77bcb6c7cd-jv7tx                              1/1     Running     0          53m
deck-77bcb6c7cd-k6g8x                              1/1     Running     0          53m
hook-7bdd7f86c9-ds6qd                              1/1     Running     0          53m
hook-7bdd7f86c9-lj584                              1/1     Running     0          53m
horologium-7cc979bd5c-jfxln                        1/1     Running     0          53m
jenkins-x-chartmuseum-5b6f9fd646-nh9ng             1/1     Running     0          52m
jenkins-x-controllerbuild-68646c5c9d-t7jkg         1/1     Running     0          52m
jenkins-x-controllercommitstatus-dd46689c8-qs96g   1/1     Running     0          52m
jenkins-x-controllerrole-67dcc687cc-r8lrl          1/1     Running     0          52m
jenkins-x-controllerteam-59bb947b8b-mgndp          1/1     Running     0          52m
jenkins-x-controllerworkflow-76bb4755f6-nnwp5      1/1     Running     0          52m
jenkins-x-docker-registry-fb7878f76-d456t          1/1     Running     0          52m
jenkins-x-gcactivities-1548072000-bnnvh            0/1     Completed   0          40m
jenkins-x-gcactivities-1548073800-rmm68            0/1     Completed   0          10m
jenkins-x-gcpods-1548072000-tnslc                  0/1     Completed   0          40m
jenkins-x-gcpods-1548073800-kwwbr                  0/1     Completed   0          10m
jenkins-x-heapster-c6d44bc95-c2qvx                 2/2     Running     0          52m
jenkins-x-mongodb-7dd488d47b-hxs9v                 1/1     Running     1          52m
jenkins-x-monocular-api-595b688c65-4xgz2           1/1     Running     1          52m
jenkins-x-monocular-prerender-64f989797b-6v5xv     1/1     Running     0          52m
jenkins-x-monocular-ui-67dcd5cd57-c4xt2            1/1     Running     0          52m
plank-554959d957-655dh                             1/1     Running     0          53m
prow-build-78955d585f-9zs57                        1/1     Running     0          53m
sinker-6fb9f8dbdd-887sk                            1/1     Running     0          53m
tide-cf5f5b8d5-rn5pj                               1/1     Running     0          53m
```

```bash
# hook is the most important piece. It is a stateless server that listens for GitHub webhooks and dispatches them to the appropriate plugins. Hook's plugins are used to trigger jobs, implement 'slash' commands, post to Slack, and more.

kubectl -n cd describe deployment hook
```

```yaml
Name:                   hook
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=hook
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=hook
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=hook
  Service Account:  hook
  Containers:
   hook:
    Image:      jenkinsxio/hook:pipeline14
    Port:       8888/TCP
    Host Port:  0/TCP
    Args:
      --dry-run=false
    Limits:
      cpu:     400m
      memory:  256Mi
    Requests:
      cpu:        200m
      memory:     128Mi
    Liveness:     http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Readiness:    http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
      /etc/github from oauth (ro)
      /etc/plugins from plugins (ro)
      /etc/webhook from hmac (ro)
  Volumes:
   hmac:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  hmac-token
    Optional:    false
   oauth:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  oauth-token
    Optional:    false
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
   plugins:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      plugins
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  hook-84674dfd46 (2/2 replicas created)
NewReplicaSet:   <none>
Events:          <none>
```

```bash
kubectl -n cd describe cm config
```

```yaml
Name:         config
Namespace:    cd
Labels:       <none>
Annotations:  <none>

Data
====
config.yaml:
----
branch-protection:
  orgs:
    jenkins-x:
      repos:
        dummy:
          required_status_checks:
            contexts:
            - serverless-jenkins
    vfarcic:
      repos:
        environment-jx-rocks-production:
          required_status_checks:
            contexts:
            - promotion-build
        environment-jx-rocks-staging:
          required_status_checks:
            contexts:
            - promotion-build
        jx-go:
          required_status_checks:
            contexts:
            - serverless-jenkins
  protect-tested-repos: true
deck:
  spyglass: {}
gerrit: {}
owners_dir_blacklist:
  default: null
  repos: null
plank: {}
pod_namespace: cd
postsubmits:
  jenkins-x/dummy:
  - agent: knative-build
    branches:
    - master
    build_spec:
      serviceAccountName: knative-build-bot
      template:
        name: jenkins-base
    context: ""
    name: release
  vfarcic/environment-jx-rocks-production:
  - agent: knative-build
    branches:
    - master
    build_spec:
      serviceAccountName: helm
      template:
        env:
        - name: DEPLOY_NAMESPACE
          value: cd-production
        name: environment-apply
    context: ""
    name: promotion
  vfarcic/environment-jx-rocks-staging:
  - agent: knative-build
    branches:
    - master
    build_spec:
      serviceAccountName: helm
      template:
        env:
        - name: DEPLOY_NAMESPACE
          value: cd-staging
        name: environment-apply
    context: ""
    name: promotion
  vfarcic/jx-go:
  - agent: knative-build
    branches:
    - master
    build_spec:
      serviceAccountName: knative-build-bot
      template:
        name: jenkins-go
    context: ""
    name: release
presubmits:
  jenkins-x/dummy:
  - agent: knative-build
    always_run: true
    build_spec:
      serviceAccountName: helm
      template:
        name: jenkins-base
    context: serverless-jenkins
    name: serverless-jenkins
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
  vfarcic/environment-jx-rocks-production:
  - agent: knative-build
    always_run: true
    build_spec:
      serviceAccountName: knative-build-bot
      template:
        name: environment-build
    context: promotion-build
    name: promotion-build
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
  vfarcic/environment-jx-rocks-staging:
  - agent: knative-build
    always_run: true
    build_spec:
      serviceAccountName: knative-build-bot
      template:
        name: environment-build
    context: promotion-build
    name: promotion-build
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
  vfarcic/jx-go:
  - agent: knative-build
    always_run: true
    build_spec:
      serviceAccountName: helm
      template:
        name: jenkins-go
    context: serverless-jenkins
    name: serverless-jenkins
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
prowjob_namespace: cd
push_gateway: {}
sinker: {}
tide:
  context_options:
    from-branch-protection: true
    required-if-present-contexts: null
    skip-unknown-contexts: false
  queries:
  - labels:
    - approved
    missingLabels:
    - do-not-merge
    - do-not-merge/hold
    - do-not-merge/work-in-progress
    - needs-ok-to-test
    - needs-rebase
    repos:
    - jenkins-x/dummy
    - vfarcic/jx-go
  - missingLabels:
    - do-not-merge
    - do-not-merge/hold
    - do-not-merge/work-in-progress
    - needs-ok-to-test
    - needs-rebase
    repos:
    - jenkins-x/dummy-environment
    - vfarcic/environment-jx-rocks-staging
    - vfarcic/environment-jx-rocks-production
  target_url: http://deck.cd.34.73.176.245.nip.io

Events:  <none>
```

```bash
kubectl -n cd describe cm plugins
```

```yaml
Name:         plugins
Namespace:    cd
Labels:       <none>
Annotations:  <none>

Data
====
external-plugins.yaml:
----
Items: null

plugins.yaml:
----
approve:
- lgtm_acts_as_approve: true
  repos:
  - jenkins-x/dummy
  require_self_approval: true
- lgtm_acts_as_approve: true
  repos:
  - vfarcic/environment-jx-rocks-staging
  require_self_approval: true
- lgtm_acts_as_approve: true
  repos:
  - vfarcic/environment-jx-rocks-production
  require_self_approval: true
- lgtm_acts_as_approve: true
  repos:
  - vfarcic/jx-go
  require_self_approval: true
blunderbuss: {}
cat: {}
cherry_pick_unapproved: {}
config_updater: {}
external_plugins:
  jenkins-x/dummy: null
  vfarcic/environment-jx-rocks-production: null
  vfarcic/environment-jx-rocks-staging: null
  vfarcic/jx-go: null
heart: {}
owners: {}
plugins:
  jenkins-x/dummy:
  - config-updater
  - approve
  - assign
  - blunderbuss
  - help
  - hold
  - lgtm
  - lifecycle
  - size
  - trigger
  - wip
  - heart
  - cat
  - override
  vfarcic/environment-jx-rocks-production:
  - config-updater
  - approve
  - assign
  - blunderbuss
  - help
  - hold
  - lgtm
  - lifecycle
  - size
  - trigger
  - wip
  - heart
  - cat
  - override
  vfarcic/environment-jx-rocks-staging:
  - config-updater
  - approve
  - assign
  - blunderbuss
  - help
  - hold
  - lgtm
  - lifecycle
  - size
  - trigger
  - wip
  - heart
  - cat
  - override
  vfarcic/jx-go:
  - config-updater
  - approve
  - assign
  - blunderbuss
  - help
  - hold
  - lgtm
  - lifecycle
  - size
  - trigger
  - wip
  - heart
  - cat
  - override
requiresig: {}
sigmention: {}
slack: {}
triggers:
- repos:
  - jenkins-x/dummy
  trusted_org: jenkins-x
- repos:
  - vfarcic/environment-jx-rocks-staging
  trusted_org: vfarcic
- repos:
  - vfarcic/environment-jx-rocks-production
  trusted_org: vfarcic
- repos:
  - vfarcic/jx-go
  trusted_org: vfarcic
welcome:
- message_template: Welcome

Events:  <none>
```

```bash
# plank is the controller that manages the job execution and lifecycle for jobs that run in k8s pods.

kubectl -n cd describe deployment plank
```

```yaml
Name:                   plank
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=plank
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=plank
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=plank
  Service Account:  plank
  Containers:
   plank:
    Image:      jenkinsxio/plank:pipeline14
    Port:       <none>
    Host Port:  <none>
    Args:
      --dry-run=false
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
      /etc/github from oauth (ro)
  Volumes:
   oauth:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  oauth-token
    Optional:    false
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  plank-79d5bcc96b (1/1 replicas created)
NewReplicaSet:   <none>
Events:          <none>
```

```bash
# deck presents a nice view of recent jobs, command and plugin help information, the current status and (history)[https://prow.k8s.io/tide-history] of merge automation, and a dashboard for PR authors.

kubectl -n cd describe deployment deck
```

```yaml
Name:                   deck
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=deck
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=deck
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=deck
  Service Account:  deck
  Containers:
   deck:
    Image:      jenkinsxio/deck:pipeline14
    Port:       8080/TCP
    Host Port:  0/TCP
    Args:
      --hook-url=http://hook/plugin-help
      --tide-url=http://tide
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Liveness:     http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Readiness:    http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
  Volumes:
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   deck-5fbbdc9478 (2/2 replicas created)
Events:          <none>
```

```bash
kubectl -n cd describe deployment \
  horologium
```

```yaml
Name:                   horologium
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=horologium
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=horologium
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=horologium
  Service Account:  horologium
  Containers:
   horologium:
    Image:      jenkinsxio/horologium:pipeline14
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
  Volumes:
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   horologium-65d4c68b96 (1/1 replicas created)
Events:          <none>
```

```bash
# horologium triggers periodic jobs when necessary.

kubectl -n cd describe deployment sinker
```

```yaml
Name:                   sinker
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=sinker
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=sinker
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=sinker
  Service Account:  sinker
  Containers:
   sinker:
    Image:      jenkinsxio/sinker:pipeline14
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
  Volumes:
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   sinker-c95fc86b5 (1/1 replicas created)
Events:          <none>
```

```bash
# tide manages retesting and merging PRs once they meet the configured merge criteria.

kubectl -n cd describe deployment tide
```

```yaml
Name:                   tide
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=tide
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=tide
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=tide
  Service Account:  tide
  Containers:
   tide:
    Image:      jenkinsxio/tide:pipeline14
    Port:       8888/TCP
    Host Port:  0/TCP
    Args:
      --dry-run=false
      --github-endpoint=https://api.github.com
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Liveness:     http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Readiness:    http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
      /etc/github from oauth (ro)
  Volumes:
   oauth:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  oauth-token
    Optional:    false
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  tide-b99fd65b6 (1/1 replicas created)
NewReplicaSet:   <none>
Events:          <none>
```

```bash
jx console
```

```
> jenkins-x-chartmuseum
  jenkins-x-docker-registry
  jenkins-x-mongodb
  jenkins-x-monocular-api
  jenkins-x-monocular-prerender
  jenkins-x-monocular-ui
```

```bash
jx get activities

jx create quickstart -l go -p jx-go -b

kubectl -n cd get pods
```

```
NAME                                               READY   STATUS      RESTARTS   AGE
359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228    0/1     Init:2/3    0          20s
build-controller-6d8c58db8b-wz99p                  1/1     Running     0          58m
buildnum-77bdbb8bb-g59qv                           1/1     Running     0          57m
crier-766b799476-5bdvr                             1/1     Running     0          57m
deck-77bcb6c7cd-jv7tx                              1/1     Running     0          57m
deck-77bcb6c7cd-k6g8x                              1/1     Running     0          57m
hook-7bdd7f86c9-ds6qd                              1/1     Running     0          57m
hook-7bdd7f86c9-lj584                              1/1     Running     0          57m
horologium-7cc979bd5c-jfxln                        1/1     Running     0          57m
jenkins-x-chartmuseum-5b6f9fd646-nh9ng             1/1     Running     0          56m
jenkins-x-controllerbuild-68646c5c9d-t7jkg         1/1     Running     0          56m
jenkins-x-controllercommitstatus-dd46689c8-qs96g   1/1     Running     0          56m
jenkins-x-controllerrole-67dcc687cc-r8lrl          1/1     Running     0          56m
jenkins-x-controllerteam-59bb947b8b-mgndp          1/1     Running     0          56m
jenkins-x-controllerworkflow-76bb4755f6-nnwp5      1/1     Running     0          56m
jenkins-x-docker-registry-fb7878f76-d456t          1/1     Running     0          56m
jenkins-x-gcactivities-1548072000-bnnvh            0/1     Completed   0          44m
jenkins-x-gcactivities-1548073800-rmm68            0/1     Completed   0          14m
jenkins-x-gcpods-1548072000-tnslc                  0/1     Completed   0          44m
jenkins-x-gcpods-1548073800-kwwbr                  0/1     Completed   0          14m
jenkins-x-heapster-c6d44bc95-c2qvx                 2/2     Running     0          56m
jenkins-x-mongodb-7dd488d47b-hxs9v                 1/1     Running     1          56m
jenkins-x-monocular-api-595b688c65-4xgz2           1/1     Running     1          56m
jenkins-x-monocular-prerender-64f989797b-6v5xv     1/1     Running     0          56m
jenkins-x-monocular-ui-67dcd5cd57-c4xt2            1/1     Running     0          56m
plank-554959d957-655dh                             1/1     Running     0          57m
prow-build-78955d585f-9zs57                        1/1     Running     0          57m
sinker-6fb9f8dbdd-887sk                            1/1     Running     0          57m
tide-cf5f5b8d5-rn5pj                               1/1     Running     0          57m
```

```bash
jx get activities -f jx-go -w
```

```
STEP                     STARTED AGO DURATION STATUS
vfarcic/jx-go/master #1        1m23s          Running
  Credential Initializer       1m23s       0s Succeeded
  Git Source 0                                Pending https://github.com/vfarcic/jx-go.git
  Jenkins                                     Pending
```

```bash
jx logs -k
```

```
Waiting for a running Knative build pod in namespace jx
Found newest pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-credential-initializer
{"level":"warn","ts":1548074636.630049,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074636.6314034,"logger":"fallback-logger","caller":"creds-init/main.go:40","msg":"Credentials initialized."}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-git-source-0
{"level":"warn","ts":1548074638.4099896,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074638.6809788,"logger":"fallback-logger","caller":"git-init/main.go:92","msg":"Successfully cloned \"https://github.com/vfarcic/jx-go.git\" @ \"master\" in path \"/workspace\""}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-credential-initializer
{"level":"warn","ts":1548074636.630049,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074636.6314034,"logger":"fallback-logger","caller":"creds-init/main.go:40","msg":"Credentials initialized."}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-git-source-0
{"level":"warn","ts":1548074638.4099896,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074638.6809788,"logger":"fallback-logger","caller":"git-init/main.go:92","msg":"Successfully cloned \"https://github.com/vfarcic/jx-go.git\" @ \"master\" in path \"/workspace\""}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-credential-initializer
{"level":"warn","ts":1548074636.630049,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074636.6314034,"logger":"fallback-logger","caller":"creds-init/main.go:40","msg":"Credentials initialized."}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-git-source-0
{"level":"warn","ts":1548074638.4099896,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074638.6809788,"logger":"fallback-logger","caller":"git-init/main.go:92","msg":"Successfully cloned \"https://github.com/vfarcic/jx-go.git\" @ \"master\" in path \"/workspace\""}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-jenkins
Picked up _JAVA_OPTIONS: -Xmx400m
Started
Running in Durability level: PERFORMANCE_OPTIMIZED
  18.979 [id=34]        WARNING i.f.k.c.i.VersionUsageUtils#alert: The client is using resource type 'customresourcedefinitions' with unstable version 'v1beta1'
[Pipeline] node
Running on Jenkins in /tmp/jenkinsTests.tmp/jenkins2826394166145323058test/workspace/job
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Declarative: Checkout SCM)
[Pipeline] checkout
[Pipeline] }
[Pipeline] // stage
[Pipeline] withCredentials
[Pipeline] {
[Pipeline] withEnv
[Pipeline] {
[Pipeline] stage
[Pipeline] { (CI Build and push snapshot)
Stage "CI Build and push snapshot" skipped due to when conditional
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Build Release)
[Pipeline] dir
Running in /home/jenkins/go/src/github.com/vfarcic/jx-go
[Pipeline] {
[Pipeline] git
Cloning the remote Git repository
Cloning repository https://github.com/vfarcic/jx-go.git
 > git init /home/jenkins/go/src/github.com/vfarcic/jx-go # timeout=10
Fetching upstream changes from https://github.com/vfarcic/jx-go.git
 > git --version # timeout=10
 > git fetch --tags --progress https://github.com/vfarcic/jx-go.git +refs/heads/*:refs/remotes/origin/*
 > git config remote.origin.url https://github.com/vfarcic/jx-go.git # timeout=10
 > git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git config remote.origin.url https://github.com/vfarcic/jx-go.git # timeout=10
Fetching upstream changes from https://github.com/vfarcic/jx-go.git
 > git fetch --tags --progress https://github.com/vfarcic/jx-go.git +refs/heads/*:refs/remotes/origin/*
 > git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
Checking out Revision ac61663c66a30230f1fe2673564a7322b51b60ed (refs/remotes/origin/master)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f ac61663c66a30230f1fe2673564a7322b51b60ed
 > git branch -a -v --no-abbrev # timeout=10
 > git checkout -b master ac61663c66a30230f1fe2673564a7322b51b60ed
Commit message: "Draft create"
First time build. Skipping changelog.
[Pipeline] sh
+ jx-release-version
+ echo 0.0.1
[Pipeline] sh
+ cat VERSION
+ jx step tag --version 0.0.1
Tag v0.0.1 created and pushed to remote origin
[Pipeline] sh
+ make build
CGO_ENABLED=0 GO15VENDOREXPERIMENT=1 go build -ldflags '' -o bin/jx-go main.go
[Pipeline] sh
+ cat VERSION
+ export VERSION=0.0.1
+ skaffold build -f skaffold.yaml
Starting build...
Building [changeme]...
Sending build context to Docker daemon  6.506MB
Step 1/4 : FROM scratch
 --->
Step 2/4 : EXPOSE 8080
 ---> Running in 6ead86484cb6
 ---> 0a3b6cbce573
Step 3/4 : ENTRYPOINT /jx-go
 ---> Running in 84f3c1aa9628
 ---> 4bad0075d276
Step 4/4 : COPY ./bin/ /
 ---> ff8869653123
Successfully built ff8869653123
The push refers to a repository [10.31.244.225:5000/vfarcic/jx-go]
e8a596b3e697: Preparing
e8a596b3e697: Pushed
0.0.1: digest: sha256:02cb565d8740e235df2945b1592c80852aca9eea930a7d4d5d769d4edaf9d83c size: 528
Build complete in 1.553868918s
Starting test...
Test complete in 4.755µs
changeme -> 10.31.244.225:5000/vfarcic/jx-go:0.0.1
[Pipeline] sh
+ cat VERSION
+ jx step post build --image 10.31.244.225:5000/vfarcic/jx-go:0.0.1
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Promote to Environments)
[Pipeline] dir
Running in /home/jenkins/go/src/github.com/vfarcic/jx-go/charts/jx-go
[Pipeline] {
[Pipeline] sh
+ cat ../../VERSION
+ jx step changelog --version v0.0.1
Using batch mode as inside a pipeline
Generating change log from git ref ac61663c66a30230f1fe2673564a7322b51b60ed => cf74c26c064005d5ccd359c821bb931f23e7b4c2
Failed to enrich commits with issues: User.jenkins.io "" is invalid: metadata.name: Required value: name or generateName is required
Failed to enrich commits with issues: User.jenkins.io "" is invalid: metadata.name: Required value: name or generateName is required
Finding issues in commit messages using git format
No release found for vfarcic/jx-go and tag v0.0.1 so creating a new release
Updated the release information at https://github.com/vfarcic/jx-go/releases/tag/v0.0.1
generated: /home/jenkins/go/src/github.com/vfarcic/jx-go/charts/jx-go/templates/release.yaml
Created Release jx-go-0-0-1 resource in namespace jx
Updating PipelineActivity vfarcic-jx-go-master-1 with version 0.0.1
Updated PipelineActivities vfarcic-jx-go-master-1 with release notes URL: https://github.com/vfarcic/jx-go/releases/tag/v0.0.1
[Pipeline] sh
+ jx step helm release
No $CHART_REPOSITORY defined so using the default value of: http://jenkins-x-chartmuseum:8080
Adding missing Helm repo: releases http://jenkins-x-chartmuseum:8080
Successfully added Helm repository releases.
Adding missing Helm repo: jenkins-x http://chartmuseum.jenkins-x.io
Successfully added Helm repository jenkins-x.
No $CHART_REPOSITORY defined so using the default value of: http://jenkins-x-chartmuseum:8080
Uploading chart file jx-go-0.0.1.tgz to http://jenkins-x-chartmuseum:8080/api/charts
Received 201 response: {"saved":true}
[Pipeline] sh
+ cat ../../VERSION
+ jx promote -b --all-auto --timeout 1h --version 0.0.1
prow based install so skip waiting for the merge of Pull Requests to go green as currently there is an issue with gettingstatuses from the PR, see https://github.com/jenkins-x/jx/issues/2410
Promoting app jx-go version 0.0.1 to namespace jx-staging
No changes made to the GitOps Environment source code. Code must be up to date!
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withCredentials
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```

```bash
# Cancel with ctrl+c after `Finished: SUCCESS`

jx get build logs -f jx-go # Available for a few hours

# The same output as `jx logs -k`

jx get pipelines
```

```
Name                                           URL LAST_BUILD STATUS DURATION
jenkins-x/dummy/master                         N/A N/A        N/A    N/A
vfarcic/environment-jx-rocks-production/master N/A N/A        N/A    N/A
vfarcic/environment-jx-rocks-staging/master    N/A N/A        N/A    N/A
vfarcic/jx-go/master                           N/A N/A        N/A    N/A
```

```bash
jx get build logs \
    -f environment-jx-rocks-staging # Available for a few hours
```

```
? Which build do you want to view the logs of?:   [Use arrows to move, type to filter]
  vfarcic/environment-jx-rocks-staging/PR-1 #1
> vfarcic/environment-jx-rocks-staging/master #1
```

NOTE: Select [GITHUB_USER]/environment-jx-rocks-staging/master

```bash
jx get applications
```

```
APPLICATION STAGING PODS URL
jx-go       0.0.1   1/1  http://jx-go.jx-staging.35.196.4.10.nip.io
```

```bash
JX_GO_ADDR=[...]

curl "$JX_GO_ADDR"
```

```
Hello from:  Jenkins X golang http example
```

```bash
kubectl -n cd get pods
```

```
NAME                                               READY   STATUS      RESTARTS   AGE
02411b9b-1f64-11e9-bdb9-0a580a1c0007-pod-48ea54    0/1     Completed   0          4m
115d0d0b-1f64-11e9-8eb4-0a580a1c010e-pod-1d6384    0/1     Completed   0          4m
942bbcf2-1f63-11e9-9ed1-30230373a07c-pod-29d7f5    0/1     Completed   0          7m
build-controller-6d8c58db8b-4m7tw                  1/1     Running     0          16m
buildnum-5cbf874c56-4nv4n                          1/1     Running     0          14m
crier-766b799476-wn672                             1/1     Running     0          14m
deck-c9f8cd879-9947t                               1/1     Running     1          14m
deck-c9f8cd879-llntj                               1/1     Running     1          14m
hook-7bdd7f86c9-mfq7l                              1/1     Running     0          14m
hook-7bdd7f86c9-wr5ct                              1/1     Running     0          14m
horologium-7cc979bd5c-hcrl6                        1/1     Running     0          14m
jenkins-x-chartmuseum-5b6f9fd646-vrw8c             1/1     Running     0          13m
jenkins-x-controllerbuild-7c6cf884f7-6hbhc         1/1     Running     0          13m
jenkins-x-controllercommitstatus-bdfb9f7c4-gnpwn   1/1     Running     0          13m
jenkins-x-controllerrole-66999f4c9c-mhm5g          1/1     Running     0          13m
jenkins-x-controllerteam-5656449cbf-87vlc          1/1     Running     0          13m
jenkins-x-controllerworkflow-5f4b8794f6-nfx45      1/1     Running     0          13m
jenkins-x-docker-registry-fb7878f76-pbqnb          1/1     Running     0          13m
jenkins-x-heapster-c6d44bc95-sq8zm                 2/2     Running     0          13m
jenkins-x-mongodb-7dd488d47b-cx45p                 1/1     Running     1          13m
jenkins-x-monocular-api-6fdbdf79fb-thlh9           1/1     Running     2          13m
jenkins-x-monocular-prerender-64f989797b-gn8zv     1/1     Running     0          13m
jenkins-x-monocular-ui-595fb68747-mpzxh            1/1     Running     0          13m
plank-554959d957-8q8gq                             1/1     Running     0          14m
prow-build-6864887c76-gxrgp                        1/1     Running     0          14m
sinker-6fb9f8dbdd-h6mb4                            1/1     Running     0          14m
tide-7dcb845485-qb476                              1/1     Running     0          14m
```

```bash
DECK_ADDR=$(kubectl -n cd \
    get ing deck \
    -o jsonpath="{.spec.rules[0].host}")

open "http://$DECK_ADDR"
```

NOTE: Use *admin* as both the username and the password

## Exploring CustomerResourceDefinitions

```bash
kubectl -n cd get crd
```

```
NAME                                      CREATED AT
apps.jenkins.io                           2019-03-24T18:56:00Z
backendconfigs.cloud.google.com           2019-03-24T18:54:26Z
buildpacks.jenkins.io                     2019-03-24T18:55:56Z
builds.build.knative.dev                  2019-03-24T19:00:09Z
buildtemplates.build.knative.dev          2019-03-24T19:00:09Z
clusterbuildtemplates.build.knative.dev   2019-03-24T19:00:09Z
commitstatuses.jenkins.io                 2019-03-24T18:55:57Z
environmentrolebindings.jenkins.io        2019-03-24T18:56:01Z
environments.jenkins.io                   2019-03-24T18:55:58Z
extensions.jenkins.io                     2019-03-24T18:55:59Z
facts.jenkins.io                          2019-03-24T18:56:03Z
gitservices.jenkins.io                    2019-03-24T18:56:02Z
images.caching.internal.knative.dev       2019-03-24T19:00:09Z
pipelineactivities.jenkins.io             2019-03-24T18:56:02Z
pipelinestructures.jenkins.io             2019-03-24T18:56:03Z
plugins.jenkins.io                        2019-03-24T18:56:01Z
prowjobs.prow.k8s.io                      2019-03-24T19:01:30Z
releases.jenkins.io                       2019-03-24T18:56:04Z
scalingpolicies.scalingpolicy.kope.io     2019-03-24T18:55:36Z
sourcerepositories.jenkins.io             2019-03-24T18:56:04Z
teams.jenkins.io                          2019-03-24T18:56:05Z
users.jenkins.io                          2019-03-24T18:56:06Z
workflows.jenkins.io                      2019-03-24T18:56:06Z
```

## Exploring KNative

```bash
kubectl -n cd \
  describe crd builds.build.knative.dev
```

```yaml
Name:         builds.build.knative.dev
Namespace:    
Labels:       <none>
Annotations:  helm.sh/hook: crd-install
API Version:  apiextensions.k8s.io/v1beta1
Kind:         CustomResourceDefinition
Metadata:
  Creation Timestamp:  2019-03-24T19:00:09Z
  Generation:          1
  Resource Version:    1667
  Self Link:           /apis/apiextensions.k8s.io/v1beta1/customresourcedefinitions/builds.build.knative.dev
  UID:                 0bbb8212-4e67-11e9-8717-42010a8e00be
Spec:
  Additional Printer Columns:
    JSON Path:  .status.conditions[?(@.type=="Succeeded")].status
    Name:       Succeeded
    Type:       string
    JSON Path:  .status.conditions[?(@.type=="Succeeded")].reason
    Name:       Reason
    Type:       string
    JSON Path:  .status.startTime
    Name:       StartTime
    Type:       date
    JSON Path:  .status.completionTime
    Name:       CompletionTime
    Type:       date
  Group:        build.knative.dev
  Names:
    Categories:
      all
      knative
    Kind:       Build
    List Kind:  BuildList
    Plural:     builds
    Singular:   build
  Scope:        Namespaced
  Version:      v1alpha1
  Versions:
    Name:     v1alpha1
    Served:   true
    Storage:  true
Status:
  Accepted Names:
    Categories:
      all
      knative
    Kind:       Build
    List Kind:  BuildList
    Plural:     builds
    Singular:   build
  Conditions:
    Last Transition Time:  2019-03-24T19:00:09Z
    Message:               no conflicts found
    Reason:                NoConflicts
    Status:                True
    Type:                  NamesAccepted
    Last Transition Time:  <nil>
    Message:               the initial names have been accepted
    Reason:                InitialNamesAccepted
    Status:                True
    Type:                  Established
  Stored Versions:
    v1alpha1
Events:  <none>
```

```bash
kubectl -n cd describe crd \
  buildtemplates.build.knative.dev
```

```yaml
Name:         buildtemplates.build.knative.dev
Namespace:    
Labels:       <none>
Annotations:  helm.sh/hook: crd-install
API Version:  apiextensions.k8s.io/v1beta1
Kind:         CustomResourceDefinition
Metadata:
  Creation Timestamp:  2019-03-24T19:00:09Z
  Generation:          1
  Resource Version:    1670
  Self Link:           /apis/apiextensions.k8s.io/v1beta1/customresourcedefinitions/buildtemplates.build.knative.dev
  UID:                 0bbee11a-4e67-11e9-8717-42010a8e00be
Spec:
  Additional Printer Columns:
    JSON Path:  .metadata.creationTimestamp
    Name:       Age
    Type:       date
  Group:        build.knative.dev
  Names:
    Categories:
      all
      knative
    Kind:       BuildTemplate
    List Kind:  BuildTemplateList
    Plural:     buildtemplates
    Singular:   buildtemplate
  Scope:        Namespaced
  Version:      v1alpha1
  Versions:
    Name:     v1alpha1
    Served:   true
    Storage:  true
Status:
  Accepted Names:
    Categories:
      all
      knative
    Kind:       BuildTemplate
    List Kind:  BuildTemplateList
    Plural:     buildtemplates
    Singular:   buildtemplate
  Conditions:
    Last Transition Time:  2019-03-24T19:00:09Z
    Message:               no conflicts found
    Reason:                NoConflicts
    Status:                True
    Type:                  NamesAccepted
    Last Transition Time:  <nil>
    Message:               the initial names have been accepted
    Reason:                InitialNamesAccepted
    Status:                True
    Type:                  Established
  Stored Versions:
    v1alpha1
Events:  <none>
```

```bash
kubectl -n cd get buildtemplates
```

```
NAME                        AGE
environment-apply           36m
environment-build           36m
jenkins-base                36m
jenkins-csharp              36m
jenkins-cwp                 36m
jenkins-elixir              36m
jenkins-go                  36m
jenkins-go-nodocker         36m
jenkins-go-script-bdd       36m
jenkins-go-script-ci        36m
jenkins-go-script-release   36m
jenkins-gradle              36m
jenkins-javascript          36m
jenkins-jenkins             36m
jenkins-maven               36m
jenkins-python              36m
jenkins-ruby                36m
jenkins-rust                36m
jenkins-scala               36m
jenkins-test                36m
knative-chart-ci            36m
knative-chart-release       36m
knative-deploy              36m
knative-maven-ci            36m
knative-maven-release       36m
```

```bash
kubectl -n cd get buildtemplates
```

```
NAME                        AGE
environment-apply           36m
environment-build           36m
jenkins-base                36m
jenkins-csharp              36m
jenkins-cwp                 36m
jenkins-elixir              36m
jenkins-go                  36m
jenkins-go-nodocker         36m
jenkins-go-script-bdd       36m
jenkins-go-script-ci        36m
jenkins-go-script-release   36m
jenkins-gradle              36m
jenkins-javascript          36m
jenkins-jenkins             36m
jenkins-maven               36m
jenkins-python              36m
jenkins-ruby                36m
jenkins-rust                36m
jenkins-scala               36m
jenkins-test                36m
knative-chart-ci            36m
knative-chart-release       36m
knative-deploy              36m
knative-maven-ci            36m
knative-maven-release       36m
```

```bash
kubectl -n cd \
  describe buildtemplate jenkins-go
```

```yaml
Name:         jenkins-go
Namespace:    cd
Labels:       <none>
Annotations:  <none>
API Version:  build.knative.dev/v1alpha1
Kind:         BuildTemplate
Metadata:
  Creation Timestamp:  2019-03-24T19:02:52Z
  Generation:          1
  Resource Version:    2483
  Self Link:           /apis/build.knative.dev/v1alpha1/namespaces/cd/buildtemplates/jenkins-go
  UID:                 6c7a085d-4e67-11e9-8717-42010a8e00be
Spec:
  Steps:
    Env:
      Name:   GIT_COMMITTER_EMAIL
      Value:  jenkins-x@googlegroups.com
      Name:   GIT_AUTHOR_EMAIL
      Value:  jenkins-x@googlegroups.com
      Name:   GIT_AUTHOR_NAME
      Value:  jenkins-x-bot
      Name:   GIT_COMMITTER_NAME
      Value:  jenkins-x-bot
      Name:   XDG_CONFIG_HOME
      Value:  /home/jenkins
      Name:   DOCKER_CONFIG
      Value:  /home/jenkins/.docker/
      Name:   _JAVA_OPTIONS
      Value:  -Xmx400m
      Name:   BUILD_NUMBER
      Value:  $BUILD_ID
      Name:   DOCKER_REGISTRY
      Value From:
        Config Map Key Ref:
          Key:   docker.registry
          Name:  jenkins-x-docker-registry
    Image:       gcr.io/jenkinsxio/jenkins-go:256.0.156
    Name:        jenkins
    Resources:
      Limits:
        Cpu:     3
        Memory:  5Gi
      Requests:
        Cpu:     0.5
        Memory:  1Gi
    Volume Mounts:
      Mount Path:  /home/jenkins/.docker
      Name:        jenkins-docker-cfg
      Mount Path:  /var/run/docker.sock
      Name:        docker-sock-volume
  Timeout:         60m
  Volumes:
    Name:  jenkins-docker-cfg
    Secret:
      Secret Name:  jenkins-docker-cfg
    Host Path:
      Path:  /var/run/docker.sock
    Name:    docker-sock-volume
Events:      <none>
```

```bash
kubectl -n cd get images
```

```
NAME                                   AGE
environment-apply-2475-00000           37m
environment-build-2476-00000           37m
git-init                               40m
jenkins-base-2477-00000                37m
jenkins-csharp-2478-00000              37m
jenkins-cwp-2479-00000                 37m
jenkins-elixir-2480-00000              37m
jenkins-go-2483-00000                  37m
jenkins-go-nodocker-2484-00000         37m
jenkins-go-script-bdd-2487-00000       37m
jenkins-go-script-bdd-2487-00001       37m
jenkins-go-script-ci-2488-00000        37m
jenkins-go-script-release-2491-00000   37m
jenkins-gradle-2492-00000              37m
jenkins-javascript-2493-00000          37m
jenkins-jenkins-2494-00000             37m
jenkins-maven-2495-00000               37m
jenkins-python-2496-00000              37m
jenkins-ruby-2497-00000                37m
jenkins-rust-2498-00000                37m
jenkins-scala-2499-00000               37m
jenkins-test-2500-00000                37m
knative-chart-ci-2501-00000            37m
knative-chart-release-2502-00000       37m
knative-deploy-2503-00000              37m
knative-maven-ci-2504-00000            37m
knative-maven-release-2505-00000       37m
nop                                    40m
```

```bash
kubectl -n cd get builds
```

```
NAME                                 SUCCEEDED REASON STARTTIME COMPLETIONTIME
35a7b872-4e69-11e9-b27c-acde48001122 True             15m       
de8f77c5-4e69-11e9-80d8-0a580a1c0008 True             10m       
ef5672ee-4e69-11e9-8a10-0a580a1c0208 True             9m        
```

```bash
BUILD_NAME=$(kubectl -n cd get builds \
    -l prow.k8s.io/refs.repo=jx-go \
    -o name | tail -1)

kubectl -n cd describe $BUILD_NAME
```

```yaml
Name:         35a7b872-4e69-11e9-b27c-acde48001122
Namespace:    cd
Labels:       created-by-prow=true
              prow.k8s.io/id=35a7b872-4e69-11e9-b27c-acde48001122
              prow.k8s.io/job=
              prow.k8s.io/refs.org=vfarcic
              prow.k8s.io/refs.repo=jx-go
              prow.k8s.io/type=postsubmit
Annotations:  prow.k8s.io/job: 
API Version:  build.knative.dev/v1alpha1
Kind:         Build
Metadata:
  Creation Timestamp:  2019-03-24T19:15:39Z
  Generation:          1
  Resource Version:    6199
  Self Link:           /apis/build.knative.dev/v1alpha1/namespaces/cd/builds/35a7b872-4e69-11e9-b27c-acde48001122
  UID:                 35c8825d-4e69-11e9-8717-42010a8e00be
Spec:
  Service Account Name:  knative-build-bot
  Source:
    Git:
      Revision:  master
      URL:       https://github.com/vfarcic/jx-go.git
  Template:
    Env:
      Name:   BRANCH_NAME
      Value:  master
      Name:   SOURCE_URL
      Value:  https://github.com/vfarcic/jx-go.git
      Name:   REPO_OWNER
      Value:  vfarcic
      Name:   REPO_NAME
      Value:  jx-go
      Name:   PULL_BASE_REF
      Value:  master
      Name:   PULL_BASE_SHA
      Name:   JOB_NAME
      Name:   BUILD_ID
      Value:  1
      Name:   PULL_REFS
      Value:  master:
      Name:   PROW_JOB_ID
      Value:  35a7b872-4e69-11e9-b27c-acde48001122
      Name:   JOB_TYPE
      Value:  postsubmit
      Name:   JOB_SPEC
      Value:  {"type":"postsubmit","buildid":"1","prowjobid":"35a7b872-4e69-11e9-b27c-acde48001122","refs":{"org":"vfarcic","repo":"jx-go","base_ref":"master"}}
    Name:     jenkins-go
  Timeout:    1h0m0s
Status:
  Builder:  Cluster
  Cluster:
    Namespace:  cd
    Pod Name:   35a7b872-4e69-11e9-b27c-acde48001122-pod-c18a19
  Conditions:
    Last Transition Time:  2019-03-24T19:19:09Z
    Status:                True
    Type:                  Succeeded
  Start Time:              2019-03-24T19:15:39Z
  Step States:
    Terminated:
      Container ID:  docker://fe59bc169ede6a42052cff56cf6b970154fe08f7ca2ba8164c71d1ef0d6aa315
      Exit Code:     0
      Finished At:   2019-03-24T19:19:06Z
      Reason:        Completed
      Started At:    2019-03-24T19:17:41Z
  Steps Completed:
    build-step-jenkins
Events:  <none>
```

## Exploring prow

- [ ] Job execution for testing, batch processing, artifact publishing.
- [ ] GitHub events are used to trigger post-PR-merge (postsubmit) jobs and on-PR-update (presubmit) jobs.
- [ ] Support for multiple execution platforms and source code review sites.
- [ ] Pluggable GitHub bot automation that implements /foo style commands and enforces configured policies/processes.
- [ ] GitHub merge automation with batch testing logic.
- [ ] Front end for viewing jobs, merge queue status, dynamically generated help information, and more.
- [ ] Automatic deployment of source control based config.
- [ ] Automatic GitHub org/repo administration configured in source control.
- [ ] Designed for multi-org scale with dozens of repositories. (The Kubernetes Prow instance uses only 1 GitHub bot token!)
- [ ] High availability as benefit of running on Kubernetes. (replication, load balancing, rolling updates...)
- [ ] JSON structured logs.
- [ ] Prometheus metrics.

## Exploring BuildTemplates

## Importing Static Projects Into Serverless Jenkins X

```bash
cd ../go-demo-6

jx import -b
```

```
No username defined for the current Git server!
performing pack detection in folder /Users/vfarcic/code/go-demo-6
--> Draft detected YAML (37.310749%)
--> Could not find a pack for YAML. Trying to find the next likely language match...
--> Draft detected Go (36.205487%)
selected pack: /Users/vfarcic/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs/go
existing Dockerfile, Jenkinsfile and charts folder found so skipping 'draft create' step
replacing placeholders in directory /Users/vfarcic/code/go-demo-6
app name: go-demo-6, git server: github.com, org: vfarcic, Docker registry org: vfarcic
skipping directory "/Users/vfarcic/code/go-demo-6/.git"
Creating GitHub webhook for vfarcic/go-demo-6 for url http://hook.jx.35.196.4.10.nip.io/hook

Watch pipeline activity via:    jx get activity -f go-demo-6 -w
Browse the pipeline log via:    jx get build logs vfarcic/go-demo-6/master
Open the Jenkins console via    jx console
You can list the pipelines via: jx get pipelines
When the pipeline is complete:  jx get applications

For more help on available commands see: https://jenkins-x.io/developing/browsing/

Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!
```

```bash
jx get activities -w
```

```
STEP                                           STARTED AGO DURATION STATUS
vfarcic/environment-jx-rocks-staging/master #1      25m51s     2m3s Succeeded 
  Credential Initializer                            25m51s       0s Succeeded 
  Git Source 0                                      25m50s       0s Succeeded https://github.com/vfarcic/environment-jx-rocks-staging.git
  Apply                                             24m45s      57s Succeeded 
vfarcic/environment-jx-rocks-staging/PR-1 #1        26m15s    1m39s Succeeded 
  Credential Initializer                            26m15s       1s Succeeded 
  Git Source 0                                      26m13s       1s Succeeded https://github.com/vfarcic/environment-jx-rocks-staging.git
  Build                                              25m7s      31s Succeeded 
vfarcic/go-demo-6/master #1                            54s          Running 
  Credential Initializer                               54s          Running 
  Git Source 0                                                      Pending https://github.com/vfarcic/go-demo-6.git
  Jenkins                                                           Pending 
vfarcic/jx-go/master #1                             29m20s    3m48s Succeeded Version: 0.0.1
  Checkout Source                                   29m20s       0s Succeeded 
  CI Build and push snapshot                        26m43s          NotExecuted https://github.com/vfarcic/jx-go.git
  Build Release                                     26m43s      16s Succeeded 
  Promote to Environments                           26m27s      53s Succeeded 
  Promote: staging                                  26m19s      45s Succeeded 
    PullRequest                                     26m19s      45s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-rocks-staging/pull/1 Merge SHA: 8455c860ec1b5fe975a01216f6fd56d5c93d4999
    Update                                          25m34s       0s Succeeded 
  Credential Initializer                            29m20s       0s Succeeded 
  Git Source 0                                      29m18s       1s Succeeded https://github.com/vfarcic/jx-go.git
  Jenkins                                           27m20s    1m48s Succeeded 
```

```bash
jx get build logs -f go-demo-6
```

```
Build logs for vfarcic/go-demo-6/master #1
Getting the pod log for pod 8e5c4b26-1f67-11e9-b9ab-30230373a07c-pod-b9d859 and init container build-step-credential-initializer
{"level":"warn","ts":1548286526.3888607,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548286526.390118,"logger":"fallback-logger","caller":"creds-init/main.go:40","msg":"Credentials initialized."}
Getting the pod log for pod 8e5c4b26-1f67-11e9-b9ab-30230373a07c-pod-b9d859 and init container build-step-git-source-0
{"level":"warn","ts":1548286528.0876548,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548286529.2002468,"logger":"fallback-logger","caller":"git-init/main.go:92","msg":"Successfully cloned \"https://github.com/vfarcic/go-demo-6.git\" @ \"master\" in path \"/workspace\""}
Getting the pod log for pod 8e5c4b26-1f67-11e9-b9ab-30230373a07c-pod-b9d859 and init container build-step-jenkins
Picked up _JAVA_OPTIONS: -Xmx400m
Started
Running in Durability level: PERFORMANCE_OPTIMIZED
  23.496 [id=35]        WARNING i.f.k.c.i.VersionUsageUtils#alert: The client is using resource type 'customresourcedefinitions' with unstable version 'v1beta1'
[Pipeline] node
Still waiting to schedule task
‘Jenkins’ doesn’t have label ‘jenkins-go’
```

NOTE: Stop the logs with *ctrl+c*

TODO: Stop the job

```bash
vim Jenkinsfile
```

* Change 

```groovy
  agent {
    label "jenkins-go"
  }
```

to

```groovy
  agent any
```

* Remove all `container` blocks

```bash
vim OWNERS

# Add `vfarcic` to both `approvers` and `reviewers`

git add .

git commit -m "Switched to serverless"

git push

jx get build logs -f go-demo-6

jx get build logs -f environment-jx-rocks-staging

GD6_ADDR=$(kubectl -n cd-staging \
    get ing go-demo-6 \
    -o jsonpath="{.spec.rules[0].host}")

echo $GD6_ADDR

curl "http://$GD6_ADDR/demo/hello"
```

NOTE: Use centralized logging

NOTE: GitHub only (for now)

```bash
kubectl -n cd describe cm plugins

git checkout -b prow

jx create issue -t "prow" \
    --body "Test prow support" \
    -b

ISSUE_ID=[...]

GH_USER=[...]

open "https://github.com/$GH_USER/go-demo-6/issues/$ISSUE_ID"

cat main.go | sed -e "s@hello, PR@hello, prow@g" | tee main_test.go

cat main.go | sed -e "s@hello, PR@hello, prow@g" | tee main.go

git add . && git commit -m "prow #$ISSUE_ID" && git push --set-upstream origin prow

# Create a PR

jx get activities -w

PR_ID=[...]

PR_ADDR=$(kubectl -n cd-$GH_USER-go-demo-6-pr-$PR_ID get ing go-demo-6 -o jsonpath="{.spec.rules[0].host}")

echo $PR_ADDR

curl "http://$PR_ADDR/demo/hello"

# Add `/assign` to the PR

open "https://github.com/$GH_USER/go-demo-6/pull/$PR_ID"

# Type `/meow` as the comment

# Type `/assign @vfarcic` as the comment

# I type `/lgtm` as the comment

# I type `/approve` as the comment

jx get activities -w
```

TODO: gh-pages branch

```bash
# If GKE
gcloud container clusters \
    delete jx-rocks \
    --zone us-east1-b \
    --quiet

# If GKE
# Remove unused disks to avoid reaching the quota (and save a bit of money)
gcloud compute disks delete \
    $(gcloud compute disks list \
    --filter="-users:*" \
    --format="value(id)")

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

hub delete -y $GH_USER/jx-go

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf jx-go

rm -f ~/.jx/jenkinsAuth.yaml
```