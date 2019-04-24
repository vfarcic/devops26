# Implementing ChatOps With Jenkins X

Jenkins X main logic is based on applying GitOps principles. Every change must be recorded in Git, and only Git is allowed to initiate events that result in changes in our clusters. That logic is the cornerstone of Jenkins X, and it served us well so far. However, there are actions we might need to perform that do not result in changes to the source code or configurations. Hence the emergence of ChatOps.

The idea behind ChatOps is to unify communication about the work that should be done with the history of what has been done. The expression of a desire (e.g., approve this pull request) becomes an action (execution of the approval process) and is at the same time recorded. ChatOps is similar to verbal communication or, to be more precise, commands we might give if we would have a butler. "Please make me a meal" is an expression of a desire. Your butler would transmit your wish to a cook, wait until the meal is ready, and bring it back to you. Given that we are obsessed (for a good reason) to record everything we do when developing software, verbal expressions are not good enough, so we need to write them down. Hence the idea of ChatOps.

> ChatOps converts parts of communication into commands that are automatically executed and provides feedback of the results.

We can define ChatOps as conversation driven development. Communication is essential for all but single-person teams. We need to communicate with others when the feature we're developing is ready. We need to ask others to review our changes. We might need to ask for permission to merge to the master branch. The list of the things we might need to communicate is infinite. That does not mean that all communication becomes ChatOps, but rather that parts of our communication does. It's up to the system to figure out what which parts of communication should result in actions, and what is a pure human-to-human messaging without tangible outcomes.

Without further ado, we'll take a look how Jenkins X implements ChatOps.

## A Quick Practical Demonstration

We'll need a Kubernetes cluster with serverless flavor of Jenkins X. If you don't have one at hand, feel free to use one of the Gists that follow to create a new cluster or install Jenkins X in an existing one. Bear in mind that the Gists also contain the command that will let you destroy the cluster when you're finished "playing".

> You will need to install `jx` first. Please follow the instructions from [Get jx](https://jenkins-x.io/getting-started/install/) if you don't have it already.

* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

> If in doubt, I recomment GKE (Google Kubernetes Engine) as being the most stable and feature rich managed Kubernetes solution.

The best way to explore the integration Jenkins X provides between Git, Prow, and the rest of the system is through practical examples. The first thing we'll need is a project, so we'll create a new one.

```bash
jx create quickstart \
  -l go \
  -p jx-prow \
  -b

cd jx-prow
```

Since ChatOpts is mostly related to pull requests, we need to define who is allowed to review and who can approve them. We can do that by modifying the `OWNERS` file generated when we created the project through the Jenkins X quickstart. Since it would be insecure to allow a person who made the PR to change that file, the one that counts is the `OWNERS` file in the master branch. So, that's the one we'll explore and modify.

```bash
cat OWNERS
```

The output is as follows.

```yaml
approvers:
- vfarcic
reviewers:
- vfarcic
```

The `OWNERS` contains the list of users responsible for the codebase of this repository. It is split between `approvers` and `reviewers` sections. Such split is useful if we'd like to implement a two-phase code review process in which different people would be in charge of reviewing and approving pull requests. However, more often than not, those two roles are performed by the same people so Jenkins X comes without two-phase review process out of the box (it can be changed though).

To proceed, we need a real GitHub user (other than yours) so please contact a colleague or a friend and ask him to give you a hand. Tell her that you'll need her help to complete some of the steps of the exercises that follow. Also, let her know that you need to know her GitHub user.

We'll define two environment variables that will help us create a new version of the `OWNERS` file. `GH_USER` will hold your username, while `GH_APPROVER` will contain the user of the person that will be allowed to review and approve your pull requests. Typically, we would have more than one approver so that the review and approval tasks are distributed across the team. For demo purposes, the two of you should be more than enough.

W> Before executing the commands that follow, please replace the first `[...]` with your GitHub user and the second with the user of the person that will approve your PR.

```bash
GH_USER=[...]

GH_APPROVER=[...]
```

Now we can create a new version of the `OWNERS` file. As already discussed, we'll use the same users as both reviewers and approvers.

```bash
echo "approvers:
- $GH_USER
- $GH_APPROVER
reviewers:
- $GH_USER
- $GH_APPROVER
" | tee OWNERS
```

All that's left, related to the `OWNERS` file, is to push the changes to the repository.

```bash
git add .

git commit -m "Added an owner"

git push
```

Even though the `OWNERS` file defines who can review and approve pull requests, that would be useless if those users are not allowed to collaborate on your project. We need to tell GitHub that your colleague works with you by adding a collaborator (other Git platforms might call it differently).

```bash
open "https://github.com/$GH_USER/jx-prow/settings/collaboration"
```

Please login if you're asked to do so. Type the user and click the *Add collaborator* button.

![Figure 12-4: GitHub collaborators screen](images/ch12/prow-collaborator.png)

Your colleague should receive an email with an invitation to join the project as a collaborator. Make sure that she accepts the invitation.

I> Not all collaborators must be in the `OWNERS` file. You might have people who collaborate on your project but are not allowed to review or approve pull requests.

Since most of the ChatOps features apply to pull requests, we need to create one.

```bash
git checkout -b chat-ops

echo "ChatOps" | tee README.md

git add .

git commit -m "My first PR with prow"

git push --set-upstream origin chat-ops
```

We created a new branch `chat-ops`, we made a silly change to `README.md`, and we pushed the commit.

Now that we have the branch with the change to the source code, we should create a pull request. We could do that by going to GitHub UI. There is a better way though. `jx` allows us to do that through the command line. Given that I prefer terminal screen over UIs (and you don't have a say in that matter), we'll go with the latter option.

```bash
jx create pr \
    -t "PR with prow" \
    --body "What I can say?" \
    -b
```

We created a pull request and are presented with a confirmation message with a link. Please open it in your favorite browser.

Given that no PR should be approved without a kitten, we'll add one.

Please type the following PR comment and press the *Comment* button.

```
No PR should be without a kitten

/meow
```

You should see a picture of a cat. We did not really need it, but it was a good demonstration of a communication through comments that results in automatically executed actions.

When we created a pull request, it was automatically assigned to one of the approvers. Your colleague should have received a notification email. Please let her know that she should go to the pull request (instructions are in the email), type `/lgtm` (looks good to me), and click the *Comment* button.

I> Please note that `/approve` and `/lgtm` have the same purpose in this context. We're switching from one to another only to show that both result in the pull request being merged to the master branch.

After a while, the PR will be merged, and a build of the pipeline will be executed. That, as you hopefully know, results in a new release being validated and deployed to the staging environment (thanks to Jenkins X pipelines).

You will notice that email notifications are flying back and forth between you and the approver. Not only that we are applying ChatOps principles, but we are at the same time solving the need for notifications that let each involved know what's going on as well as whether there are pending actions. Those notifications are sent by Git itself as a reaction to specific actions. The way to control who receives which notifications is particular to each Git platform and I hope that you already know how to subscribe, unsubscribe, or modify Git notifications you're receiving.

As an example, the email sent as the result of approving the PR is as follows.

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

All in all, the pull request is approved. As a result, Prow merged it to the master branch, and that initiated a pipeline build that ended with the deployment of the new release to the staging environment.

![Figure 12-5: Merged pull request](images/ch12/prow-pr-merged.png)

Please wait until the *All checks have passed* message appears in the PR.

That was a very quick overview of ChatOps in Jenkins X. We only scratched the surface. Now it's up to you to roll up your sleeves and explore everything Prow, Tekton, Jenkins X Pipeline Operator and other tools offered through the serverless Jenkins X bundle.