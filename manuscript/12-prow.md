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

## Creating A Kubernetes Cluster With Jenkins X

TODO: Rewrite

NOTE: New Gists

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [11-scaling.sh](https://gist.github.com/855b8d70f3fa49b42d930144ed1606f1) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new **GKE** cluster: [gke-jx-serverless.sh](TODO:)
* Create new **EKS** cluster: [eks-jx-serverless.sh](TODO:)
* Create new **AKS** cluster: [aks-jx-serverless.sh](TODO:)
* Use an **existing** cluster: [install-serverless.sh](TODO:)

```bash
GH_USER=[...]

jx delete application \
    $GH_USER/jx-serverless \
    -b
```

Now we can explore Prow.

## Quickstart

```bash
jx create quickstart \
  -l go \
  -p jx-prow \
  -b

cd jx-prow

jx get activities -f jx-prow -w

# Cancel with *ctrl+c*
```

## Prow

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
        environment-tekton-production:
          required_status_checks:
            contexts:
            - promotion-build
        environment-tekton-staging:
          required_status_checks:
            contexts:
            - promotion-build
        jx-prow:
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
  - agent: tekton
    branches:
    - master
    context: ""
    name: release
  vfarcic/environment-tekton-production:
  - agent: tekton
    branches:
    - master
    context: ""
    name: promotion
  vfarcic/environment-tekton-staging:
  - agent: tekton
    branches:
    - master
    context: ""
    name: promotion
  vfarcic/jx-prow:
  - agent: tekton
    branches:
    - master
    context: ""
    name: release
presubmits:
  jenkins-x/dummy:
  - agent: tekton
    always_run: true
    context: serverless-jenkins
    name: serverless-jenkins
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
  vfarcic/environment-tekton-production:
  - agent: tekton
    always_run: true
    context: promotion-build
    name: promotion-build
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
  vfarcic/environment-tekton-staging:
  - agent: tekton
    always_run: true
    context: promotion-build
    name: promotion-build
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
  vfarcic/jx-prow:
  - agent: tekton
    always_run: true
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
    - vfarcic/jx-prow
  - missingLabels:
    - do-not-merge
    - do-not-merge/hold
    - do-not-merge/work-in-progress
    - needs-ok-to-test
    - needs-rebase
    repos:
    - jenkins-x/dummy-environment
    - vfarcic/environment-tekton-staging
    - vfarcic/environment-tekton-production
  target_url: http://deck.cd.35.231.199.237.nip.io

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
  - vfarcic/environment-tekton-staging
  require_self_approval: true
- lgtm_acts_as_approve: true
  repos:
  - vfarcic/environment-tekton-production
  require_self_approval: true
- lgtm_acts_as_approve: true
  repos:
  - vfarcic/jx-prow
  require_self_approval: true
blunderbuss: {}
cat: {}
cherry_pick_unapproved: {}
config_updater: {}
external_plugins:
  jenkins-x/dummy: null
  vfarcic/environment-tekton-production: null
  vfarcic/environment-tekton-staging: null
  vfarcic/jx-prow: null
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
  vfarcic/environment-tekton-production:
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
  vfarcic/environment-tekton-staging:
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
  vfarcic/jx-prow:
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
  - vfarcic/environment-tekton-staging
  trusted_org: vfarcic
- repos:
  - vfarcic/environment-tekton-production
  trusted_org: vfarcic
- repos:
  - vfarcic/jx-prow
  trusted_org: vfarcic
welcome:
- message_template: Welcome

Events:  <none>
```

```bash
git checkout -b chat-ops

echo "ChatOps" | tee README.md

git add .

git commit -m "My first PR with prow"

git push --set-upstream origin chat-ops

jx create pullrequest \
    -t "PR with prow" \
    --body "What I can say?" \
    -b

# Open the link

# Observer the checks and the *PR built and available in a preview environment...* message

# Type `/assign` as the comment and click the *Comment* button

# Type `/unassign` as the comment and click the *Comment* button

# Type `/assign @[...]` as the comment and click the *Comment* button

# Type `/lgtm` as the comment and click the *Comment* button

# It could be `/lgtm cancel`

git checkout master

cat OWNERS

cat OWNERS_ALIASES

GH_USER=[...]

GH_APPROVER=[...]

echo "approvers:
- $GH_USER
- $GH_APPROVER
reviewers:
- $GH_USER
- $GH_APPROVER
" | tee OWNERS

git add .

git commit -m "Added an owner"

git push

# TODO: Switch to `hub`
open "https://github.com/$GH_USER/jx-prow/settings/collaboration"

# Type `/assign @$GH_APPROVER` as the comment and click the *Comment* button

# Add `$GH_APPROVER` as the collaborator

# Tell `$GH_APPROVER` to accept

# Login as `$GH_APPROVER`

# Type `/approve` as the comment and click the *Comment* button (NOTE: `/approve` is the same as `/lgtm`)

# Could be `/approve cancel`

# Observe the emails (both to the approver and the one who created the PR)

# Wait until the *All checks have passed* message

jx get activities \
    -f $GH_USER/jx-prow/master \
    -w

# NOTE: Explain the approval process

# TODO: Continue

git checkout -b my-pr

echo "My PR" | tee README.md

git add .

git commit -m "My first PR with prow"

git push --set-upstream origin my-pr

jx create pullrequest \
    -t "My PR" \
    --body "What I can say?" \
    -b

# Type `/hold` as the comment and click the *Comment* button

# Type `/hold cancel` as the comment and click the *Comment* button

# Type `/close` as the comment and click the *Comment* button

# Type `/reopen` as the comment and click the *Comment* button

# Type `/lifecycle frozen` as the comment and click the *Comment* button

# NOTE: Notice the *size/XS* label

# Type `/retest` as the comment and click the *Comment* button

# Type `/test this` as the comment and click the *Comment* button

# Type `/meow` as the comment and click the *Comment* button

# Type `/meow caturday` as the comment and click the *Comment* button

# Type `/meowvie clothes` as the comment and click the *Comment* button

# Login as `$GH_APPROVER`

# Type `/lgtm` as the comment and click the *Comment* buttonss
```

TODO: Issues
TODO: Where is the PR message comming from?
TODO: Change the PR approval rules
TODO: Change prow plugins
TODO: Notifications?

NOTE: It triggered the build

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

hub delete -y $GH_USER/jx-prow

rm -rf jx-prow

rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*

rm -f ~/.jx/jenkinsAuth.yaml
```