## TODO

- [X] Code
- [ ] Write
- [X] Code review GKE
- [X] Code review EKS
- [X] Code review AKS
- [-] Code review existing cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

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
```

```
STEP                      STARTED AGO DURATION STATUS
vfarcic/jx-prow/master #1                      Running Version: 0.0.1
  Release                      36m47s     1m0s Succeeded
  Promote: staging             35m47s      29s Succeeded
    PullRequest                35m47s      28s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/2 Merge SHA: 29cce039c92898be8f5107a8d41a28eda026032e
    Update                     35m19s       1s Succeeded
```

```bash
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
```

```
Created PullRequest #1 at https://github.com/vfarcic/jx-prow/pull/1
```


```bash
# Observe the checks

# Explain the approval process
```

![Figure 12-TODO: TODO:](images/ch12/prow-pr.png)

```bash
# Wait the *PR built and available in a preview environment...* message

# Wait and observe *serverless-jenkins — All Tasks have completed executing* and *tide Pending — Not mergeable. Needs approved label.*

# Type `/assign` as the comment and click the *Comment* button

# Observe that the PR is assigned (might need to refresh)
```

![Figure 12-TODO: TODO:](images/ch12/prow-assign.png)

```bash
# Type `/unassign` as the comment and click the *Comment* button

# Observe that the PR is unassigned
```

![Figure 12-TODO: TODO:](images/ch12/prow-unassign.png)

```bash
# Type `/assign @$GH_USER` as the comment and click the *Comment* button

# Type `/lgtm` as the comment and click the *Comment* button

# You might need to refresh your screen
```

![Figure 12-TODO: TODO:](images/ch12/prow-lgtm-own-pr.png)

```bash
# It could be `/lgtm cancel`

# Type `/unassign` as the comment and click the *Comment* button

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

open "https://github.com/$GH_USER/jx-prow/settings/collaboration"

# Login if asked

# Type the user and click the *Add collaborator* button
```

![Figure 12-TODO: TODO:](images/ch12/prow-collaborator.png)

```bash
# `$GH_APPROVER` should receive an email. Make sure that he accepts the invitation.

# Go back to the PR and make sure that you are signed in (not the friend).

# Type `/assign @$GH_APPROVER` as the comment and click the *Comment* button

# Login as `$GH_APPROVER`

# Open the PR and type `/approve` as the comment and click the *Comment* button (NOTE: `/approve` is the same as `/lgtm`)

# Could be `/approve cancel`

# After a while, the PR will be merged and a build of the pipeline will be executed
```

```bash
# Observe the email to the approver
```

```
[APPROVALNOTIFIER] This PR is APPROVED

This pull-request has been approved by: vfarciccb

The full list of commands accepted by this bot can be found here.

The pull request process is described here

Needs approval from an approver in each of these files:
OWNERS [vfarciccb]
Approvers can indicate their approval by writing /approve in a comment
Approvers can cancel approval by writing /approve cancel in a comment
```

![Figure 12-TODO: TODO:](images/ch12/prow-pr-merged.png)

```bash
# Wait until the *All checks have passed* message
```

```bash
jx get activities \
    -f $GH_USER/jx-prow/master \
    -w
```

```
STEP                      STARTED AGO DURATION STATUS
vfarcic/jx-prow/master #1                      Running Version: 0.0.1
  Release                     1h13m9s     1m0s Succeeded
  Promote: staging            1h12m9s      29s Succeeded
    PullRequest               1h12m9s      28s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/2 Merge SHA: 29cce039c92898be8f5107a8d41a28eda026032e
    Update                   1h11m41s       1s Succeeded
vfarcic/jx-prow/master #2                      Running Version: 0.0.2
  Release                      22m59s     1m0s Succeeded
  Promote: staging             21m59s      47s Succeeded
    PullRequest                21m59s      47s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/3 Merge SHA: 492a97bfb9952fb50b1ffbe72404a7de05dacd83
    Update                     21m12s       0s Succeeded
    Promoted                   21m12s       0s Succeeded  Application is at: http://jx-prow.cd-staging.35.164.205.224.nip.io
vfarcic/jx-prow/master #3                      Running Version: 0.0.3
  Release                      22m36s     1m0s Succeeded
  Promote: staging             21m36s    1m18s Succeeded
    PullRequest                21m36s    1m18s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/4 Merge SHA: d5a904cd69e5ea27d6488f676e0f56327be32b6a
    Update                     20m18s       0s Succeeded
    Promoted                   20m18s       0s Succeeded  Application is at: http://jx-prow.cd-staging.35.164.205.224.nip.io
```

```bash
# Press *ctrl+c*

git checkout master

git pull

git checkout -b my-pr

echo "My PR" | tee README.md

git add .

git commit -m "My first PR with prow"

git push --set-upstream origin my-pr

jx create pullrequest \
    -t "My PR" \
    --body "What I can say?" \
    -b
```

```
Created PullRequest #2 at https://github.com/vfarcic/jx-prow/pull/2
```

```bash
# Open the link as you (not the reviewer)

# Observe that the reviewer is automatically assigned
```

![Figure 12-TODO: TODO:](images/ch12/prow-pr-reviewer-auto-assigned.png)

```bash
# Observe the *size/XS* label

# Type `/hold` as the comment and click the *Comment* button

# Observe the *do-not-merge/hold* label
```

![Figure 12-TODO: TODO:](images/ch12/prow-pr-label-hold.png)

```bash
# Type `/hold cancel` as the comment and click the *Comment* button

# Observe that the *do-not-merge/hold* label was removed

# Type `/close` as the comment and click the *Comment* button

# Observe that the status of the PR is *Closed*
```

![Figure 12-TODO: TODO:](images/ch12/prow-pr-closed.png)

```bash
# Type `/reopen` as the comment and click the *Comment* button

# Observe that the status of the PR is *Open*

# Type `/lifecycle frozen` as the comment and click the *Comment* button

# Observe the *lifecycle/frozen* label

# Type `/meow` as the comment and click the *Comment* button

# Type `/meow caturday` as the comment and click the *Comment* button

# Type `/meowvie clothes` as the comment and click the *Comment* button

# Login as `$GH_APPROVER`

# Type `/lgtm` as the comment and click the *Comment* buttons
```

TODO: Notifications?

```bash
jx open deck

# Use *admin* as the username and password
```

![Figure 12-TODO: TODO:](images/ch12/prow-deck.png)

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