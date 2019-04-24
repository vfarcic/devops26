# Implementing ChatOps With Jenkins X

Jenkins X main logic is based on applying GitOps principles. Every change must be recorded in Git, and only Git is allowed to initiate events that result in changes in our clusters. That logic is the cornerstone of Jenkins X, and it served us well so far. However, there are actions we might need to perform that do not result in changes to the source code or configurations.

We might need to assign a pull request to someone for review. That someone might have to review the changes and might need to run some manual tests if they are not fully automated. A pull request could need additional changes, and the committer might need to be notified about that. Someone might need to approve and merge a pull request or choose to cancel it altogether. The list of the actions that we might have to perform once a pull request is created can be quite extensive, and many of them do not result in changes to source code. The period starting with the creation of a pull request and until it is merged to master is mostly filled with communication, rather than changes to the project in question. As such, we need an effective way to facilitate that communication.

The communication and decision making that surrounds a pull request needs to be recorded. We need to be able to track who said what and who made which decision. Otherwise, we would not be able to capture the events that lead to a merge of a pull request to the master branch. We'd be running blind. That means that verbal communication must be discarded since it would not be recorded.

Given that such communication should be closely related to the pull request, we can discard emails and wiki pages as well, thus leading us back to Git. Almost every Git platform has a mechanism to create comments tied to pull requests. We can certainly use those comments to record the communication. But, communication by itself is useless if it does not result in concrete actions.

If we do need to document the communication surrounding a pull request, it would be a waste of effort to have to perform related actions separately. Ideally, communication should result in actions.

When we write a comment that a pull request should be assigned to a reviewer, it should trigger an action that will do the actual assignment and notify that person that there is a pending action. If we comment that a pull request should be labeled as "urgent", that comment should add the label. If a reviewer writes that a pull request should be canceled, that comment should close the pull request. Similarly, if a person with sufficient permissions comments that the pull request is approved, it should be merged automatically.

There are a couple of concepts that need to be tied together for our process surrounding pull request to be effective. We need to be able to communicate, and we already have comments for that. People with sufficient privileges need to be able to perform specific actions (e.g., merge a pull request). Git platforms already implement some form of RBAC (Role Based Authentication), so that part is already solved. Furthermore, we need to be notified that there is a pending action we should perform as well as that a significant milestone is reached. This is solved as well. Every Git flavor provides a notification mechanism. What we're missing is a process that will tie all that together by executing actions based on our comments.

We should be able to implement ChatOps principles if we manage to convert comments into actions controlled by RBAC and if we receive notifications when there is a pending task.

The idea behind ChatOps is to unify communication about the work that should be done with the history of what has been done. The expression of a desire (e.g., approve this pull request) becomes an action (execution of the approval process) and is at the same time recorded. ChatOps is similar to verbal communication or, to be more precise, commands we might give if we would have a butler. "Please make me a meal" is an expression of a desire. Your butler would transmit your wish to a cook, wait until the meal is ready, and bring it back to you. Given that we are obsessed (for a good reason) to record everything we do when developing software, verbal expressions are not good enough, so we need to write them down. Hence the idea of ChatOps.

> ChatOps converts parts of communication into commands that are automatically executed and provides feedback of the results.

In a ChatOps environment, a chat client is the primary source of communication for ongoing work. However, since we adopted Git as the only source of truth, it should come as no surprise that the role of a chat client is given to Git. After all, it has comments, and that can be considered chat (of sorts). Some call it GitChat, but we'll stick with a more general term ChatOps.

If we assume that only Git should be able to initiate a change in our clusters, it stands to reason that such changes can be started either by a change in the source code, by writing comments in Git, or by creating an issue.

We can define ChatOps as conversation driven development. Communication is essential for all but single-person teams. We need to communicate with others when the feature we're developing is ready. We need to ask others to review our changes. We might need to ask for permission to merge to the master branch. The list of the things we might need to communicate is infinite. That does not mean that all communication becomes ChatOps, but rather that parts of our communication does. It's up to the system to figure out what which parts of communication should result in actions, and what is a pure human-to-human messaging without tangible outcomes.

As we already saw, four elements need to be combined into a process. We need communication (comments), permissions (RBAC), notifications (email), and actions. All but the last are already solved in every Git platform. We just need to figure out how to combine comments, permissions, and notifications into concrete actions. We'll do that by introducing Prow to our solution.

[Prow](https://github.com/kubernetes/test-infra/tree/master/prow) is a project created by the team managing continuous delivery processes for [Kubernetes](https://kubernetes.io/) projects. It does quite a few things, but we will not use everything it offers because there are better ways to accomplish some of its tasks. The parts of Prow we are primarily interested in are those related to communication between Git and processes running in our cluster. We'll use it to capture Git events created through *slash commands* written in comments. When such events are captured, Prow will either forward them to other processes running in the cluster (e.g., execute pipeline builds), or perform Git actions (e.g., merge a pull request).

Since this might be the first time you hear the term slash commands, so a short explanation might be in order.

Slash commands act as shortcuts for specific actions. Type a slash command in the Git comment field, click the button, and that's it. You executed a task or a command. Of course, our comments are not limited to slash commands. Instead, they are often combined with "conversational" text. Unfortunately, commands and the rest of communication must be in separate lines. A command must be at the start of a line, and the whole line is considered a single command. We could, for example, write the following text.


```
This PR looks OK.

/lgtm
```

Prow parses each line and will deduce that there is a slash command `/lgtm`.

Slash commands are by no means specific to Git and are widely used in other tools. Slack, for example, is known for its wide range of supported slash commands and the ability to extend them. But, since we are focused on Git, we'll limit our ChatOps experience with Slash commands to what Prow offers as the mechanism adopted by Jenkins X (and by Kubernetes community).

All in all, Prow will be our only entry point to the cluster. Since it accepts only requests from Git webhooks or slash commands, the only way we will be able to change something in our cluster is by changing the source code or by writing commands in Git comments. At the same time, Prow is highly available (unlike static Jenkins), so we'll use it to solve yet another problem.

I> At the time of this writing (April 2019), Prow only supports GitHub. The community is working hard on adding support for other Git platforms. Until that is finished, we are restricted to GitHub. If you do use a different Git platform (e.g., GitLab), I still recommend going through the exercises in this chapter. They will provide a learning experience. The chances are that, by the time you start using Jenkins X in production, support for other Git flavors will be finished.

W> Due to the current limitation, you cannot use Prow with anything but GitHub, and serverless Jenkins X doesn't work without Prow. Please take that into account if you are planning to use it in your organization (until the support for other Git providers is added to Prow).

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

We created a new branch `chat-ops`, we make a silly change to `README.md`, and we pushed the commit.

Now that we have the branch with the change to the source code, we should create a pull request. We could do that by going to GitHub UI but, as you already know from the [Working With Pull Requests And Preview Environments][#pr] chapter, `jx` already allows us to do that through the command line. Given that I prefer terminal screen over UIs (and you don't have a say in that matter), we'll go with the latter option.

```bash
jx create pr \
    -t "PR with prow" \
    --body "What I can say?" \
    -b
```

Type the following comment and press the *Comment* button.

```
No PR should be without a kitten

/meow
```

The approver should receive a notification email. Please let her know that she should go to the pull request (instructions are in the email), type `/lgtm` (looks good to me), and click the *Comment* button.

I> Please note that `/approve` and `/lgtm` have the same purpose in this context. We're switching from one to another only to show that both result in the pull request being merged to the master branch.

After a while, the PR will be merged, and a build of the pipeline will be executed. That, as you already know, results in a new release being validated and deployed to the staging environment.

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

We already know from past that a merge to the master branch initiates yet another build. That did not change with the introduction of ChatOps. When we approved the PR, Prow merged it to the master branch, and from there the same processes were executed as if we merged manually.