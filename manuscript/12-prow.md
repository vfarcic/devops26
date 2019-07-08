# Implementing ChatOps

W> The examples in this chapter work only with serverless Jenkins X.

Jenkins X main logic is based on applying GitOps principles. Every change must be recorded in Git, and only Git is allowed to initiate events that result in changes in our clusters. That logic is the cornerstone of Jenkins X, and it served us well so far. However, there are actions we might need to perform that do not result in changes to the source code or configurations.

We might need to assign a pull request to someone for review. That someone might have to review the changes and might need to run some manual tests if they are not fully automated. A pull request could need additional changes, and the committer might need to be notified about that. Someone might need to approve and merge a pull request or choose to cancel it altogether. The list of the actions that we might have to perform once a pull request is created can be quite extensive, and many of them do not result in changes to source code. The period starting with the creation of a pull request and until it is merged to master is mostly filled with communication, rather than changes to the project in question. As such, we need an effective way to facilitate that communication.

The communication and decision making that surrounds a pull request needs to be recorded. We need to be able to track who said what and who made which decision. Otherwise, we would not be able to capture the events that lead to a merge of a pull request to the master branch. We'd be running blind. That means that verbal communication must be discarded since it would not be recorded.

Given that such communication should be closely related to the pull request, we can discard emails and wiki pages as well, thus leading us back to Git. Almost every Git platform has a mechanism to create comments tied to pull requests. We can certainly use those comments to record the communication. But, communication by itself is useless if it does not result in concrete actions.

If we do need to document the communication surrounding a pull request, it would be a waste of effort to have to perform related actions separately. Ideally, communication should result in actions.

When we write a comment that a pull request should be assigned to a reviewer, it should trigger an action that will do the actual assignment and notify that person that there is a pending action. If we comment that a pull request should be labeled as "urgent", that comment should add the label. If a reviewer writes that a pull request should be canceled, that comment should close the pull request. Similarly, if a person with sufficient permissions comments that the pull request is approved, it should be merged automatically.

There are a couple of concepts that need to be tied together for our process surrounding pull request to be effective. We need to be able to communicate, and we already have comments for that. People with sufficient privileges need to be able to perform specific actions (e.g., merge a pull request). Git platforms already implement some form of RBAC (Role Based Authentication), so that part is already solved. Furthermore, we need to be notified that there is a pending action we should perform as well as that a significant milestone is reached. This is solved as well. Every Git flavor provides a notification mechanism. What we're missing is a process that will tie all that together by executing actions based on our comments.

We should be able to implement ChatOps principles if we manage to convert comments into actions controlled by RBAC and if we receive notifications when there is a pending task.

The idea behind ChatOps is to unify communication about the work that should be done with the history of what has been done. The expression of a desire (e.g., approve this pull request) becomes an action (execution of the approval process) and is at the same time recorded. ChatOps is similar to verbal communication or, to be more precise, commands we might give if we would have a butler. "Please make me a meal" is an expression of a desire. Your butler would transmit your wish to a cook, wait until the meal is ready, and bring it back to you. Given that we are obsessed (for a good reason) to record everything we do when developing software, verbal expressions are not good enough, so we need to write them down. Hence the idea of ChatOps.

I> ChatOps converts parts of communication into commands that are automatically executed and provides feedback of the results.

In a ChatOps environment, a chat client is the primary source of communication for ongoing work. However, since we adopted Git as the only source of truth, it should come as no surprise that the role of a chat client is given to Git. After all, it has comments, and that can be considered chat (of sorts). Some call it GitChat, but we'll stick with a more general term ChatOps.

If we assume that only Git should be able to initiate a change in our clusters, it stands to reason that such changes can be started either by a change in the source code, by writing comments in Git, or by creating an issue.

We can define ChatOps as conversation driven development. Communication is essential for all but single-person teams. We need to communicate with others when the feature we're developing is ready. We need to ask others to review our changes. We might need to ask for permission to merge to the master branch. The list of the things we might need to communicate is infinite. That does not mean that all communication becomes ChatOps, but rather that parts of our communication does. It's up to the system to figure out which parts of communication should result in actions, and what is a pure human-to-human messaging without tangible outcomes.

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

As always, we need a cluster with Jenkins X to explore things through hands-on exercises.

## Creating A Kubernetes Cluster With Jenkins X

W> You might be used to the fact that until now we were always using the same Gists to create a cluster or install Jenkins X in an existing one. Those that follow are different.

If you kept the cluster from the previous chapter and it contains serverless Jenkins X, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [12-prow.sh](https://gist.github.com/3ce238a85ff5537919d394bb9ec57e8e) Gist.

For your convenience, the Gists that will create a new Jenkins X cluster or install it inside an existing one are as follows.

* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

You'll notice that there are not many differences between the Gists we're using now and those we used to create a cluster with static Jenkins X. The major difference is that we're using a different environment prefix and the namespace just in case you're running both flavors in parallel. The "real" difference is in the addition of `--prow` and `--tekton` arguments to `jx create cluster` and `jx install` commands.

We will not need the `jx-serverless` project we created in the previous chapter. If you are reusing the cluster and Jenkins X installation, you might want to remove it and save a bit of resources.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
GH_USER=[...]

jx delete application \
    $GH_USER/jx-serverless \
    --batch-mode
```

Now we can explore Prow inside the serverless Jenkins X bundle.

## Exploring The Basic Pull Request Process Through ChatOps

The best way to explore the integration Jenkins X provides between Git, Prow, and the rest of the system is through practical examples. The first thing we'll need is a project, so we'll create a new one.

W> Make sure that you are not inside an existing repository before executing the command that follows.

```bash
jx create quickstart \
  --language go \
  --project-name jx-prow \
  --batch-mode

cd jx-prow

jx get activities \
    --filter jx-prow --watch
```

We created a Go-based project called `jx-prow`, entered into the local copy of the Git repository `jx` created for us, and started watching the activity. After a while, all the steps in the output will be in the `Succeeded` status, and we can stop the watcher by pressing *ctrl+c*.

When we created a new project, Git sent a webhook to Prow which, in turn, notified the system that it should run a pipeline build. Even though different processes are running builds in serverless Jenkins (e.g., Pipeline Operator and Tekton), they are functionally the same as they were before with the static flavor. We'll explore those processes later. We'll conclude that the build was successful and, as a result, we got the application deployed to the staging environment just as before when we used static Jenkins X. For now, we're mostly interested in ChatOps (or GitChat) features available through Prow.

Since most of the ChatOps features apply to pull requests, we need to create one.

```bash
git checkout -b chat-ops

echo "ChatOps" | tee README.md

git add .

git commit \
    --message "My first PR with prow"

git push --set-upstream origin chat-ops
```

We created a new branch `chat-ops`, we made a silly change to `README.md`, and we pushed the commit.

Now that we have the branch with the change to the source code, we should create a pull request. We could do that by going to GitHub UI but, as you already know from the [Working With Pull Requests And Preview Environments](#pr) chapter, `jx` already allows us to do that through the command line. Given that I prefer terminal screen over UIs (and you don't have a say in that matter), we'll go with the latter option.

```bash
jx create pullrequest \
    --title "PR with prow" \
    --body "What I can say?" \
    --batch-mode
```

We created a pull request and are presented with a confirmation message with a link. Please open it in your favorite browser.

You will notice a few things right away. A comment was created describing the process we should follow with pull requests. In a nutshell, the PR needs to be approved. Someone should review the changes we are proposing. That might mean going through the code, performing additional manual tests, or anything else that the approver might think is needed before he gives his OK.

Near the bottom, you'll see that a few checks are running. The *serverless-jenkins* process is executing the part of the pipeline dedicated to pull requests. At the end of the process, the application will be deployed to a temporary PR-specific environment just as it did when we explored pull requests with static Jenkins X. The pipeline is the same. What's different are the rules that we need to follow before we merge to master and the communication happening between Git and Prow.

The second activity is called *tide*. It will be in the *pending* state until we complete the process described in the comment.

Tide is one of the Prow components. It is in charge of merging the pull request to the master branch, and it is configured to do so only after we send it the `/approve` command. Alternatively, Tide might close the pull request if it receives `/approve cancel`. We'll explore both soon.

![Figure 12-1: The message that explains the rules governing the pull request process](images/ch12/prow-pr.png)

Next, we'll wait until the Jenkins X build initiated by the creation of the PR is finished. Once it's done, you'll see a comment stating *PR built and available in a preview environment.* Feel free to click the link next to it to open the application in a browser.

The "real" indication that the build is finished is the *serverless-jenkins — All Tasks have completed executing* message in the *checks* section near the bottom of the screen. When we created the PR, a webhook request was sent to Prow which, in turn, notified the system that it should run a build of the associated pipeline (the one defined in `jenkins-x.yml`). Not only that Prow initiated the build, but it also monitored its progress. Once the build was finished, Prow communicated the outcome to GitHub.

If you take another look at the description of the pull request process, you'll see that you can assign it to someone. We could, as you probably already know, do that through the standard GitHub process by clicking a few buttons. Since we're trying to employ the ChatOps process, we'll write a comment with a slash command instead.

Please type `/assign` as the comment. Feel free to add any text above or below the command. You can, for example, write something similar to the following text.

```
/assign

This PR is urgent, so please review it ASAP
```

The text does not matter. It is only informative, and you are free to write anything you want. What matters is the slash command `/assign`. When we create the comment, GitHub will notify Prow. It will parse it, it will process all slash commands, and it will discard the rest. Please click the *Comment* button once you're done writing a charming humanly readable message that contains `/assign`. Just remember that you cannot mix commands and text in the same line.

I> GitHub might not refresh automatically. If you do not see the expected result, try reloading the screen.

 A moment after we created the comment, the list of assignees in the right-hand menu changed. Prow automatically assigned the PR to you. Now, that might seem silly at first. Why would you assign it to yourself? We need someone to review it, and that someone could be anybody but you. You already know what is inside the PR and you are confident that it most likely work as expected. Otherwise, you wouldn't create it. What we need is the second pair of eyes. However, we do not yet have any collaborators on the project, so you're the only one Prow could assign it to. We'll change that soon.

![Figure 12-2: Assigned pull request](images/ch12/prow-assign.png)

Just as we can assign a PR to someone, we can also unassign it through a slash command. Please type `/unassign` as a new comment and click the *Comment* button. A moment later your name will disappear from the list of assignees.

I> From now on, I'll skip surrounding slash commands with humanly-readable text. It's up to you to choose whether to make it pretty or just type bare-bones commands like in the examples. From the practical perspective, the result will be the same since Prow cares only about the commands and it discards the rest of the text. Just remember that a command and text cannot be mixed in the same line.

When we issued the command `/assign`, and since we were not specific, Prow made a decision who should it be assigned to. We can, instead, be more precise and choose who should review our pull request. Since you are currently the only collaborator on the project, we have limited possibilities, but we'll try it out nevertheless.

Please type `/assign @YOUR_GITHUB_USER` as the comment. Make sure to replace `YOUR_GITHUB_USER` with your user (keep `@`). Once you're done, click the *Comment* button. The result should be the same as when we issued the `/assign` command without a specific user simply because there is only one collaborator this pull request can be assigned to. If we'd have more (as we will soon), we could have assigned it to someone else.

Next, a reviewer would go through the code changes and confirm that everything works correctly. The fact that *serverless-jenkins* check completed without issues provides an indication that all the validations executed as part of the pipeline build were successful. If still in doubt, a reviewer can always open the application deployed to the PR-specific temporary environment by clicking the link next to the *PR built and available in a preview environment* comment.

We'll assume that you (acting as a reviewer) believe that the change is safe to merge to the master branch. You already know that will initiate another pipeline build that will end with the deployment of the new release to the staging environment.

As you already saw by reading the description of the PR process, all we have to do is type `/approve`. But we won't do that. Instead, we'll use the `lgtm` abbreviation that stands for *looks good to me*. Originally, `/lgtm` is meant to provide a label that is typically used to gate merging. It is an indication that a reviewer confirmed that the pull request can be approved. However, Jenkins X implementation sets it to act as approval as well. Therefore, both `/approve` and `/lgtm` commands serve the same purpose. Both can be used to approve PRs. We'll use the latter mostly because I like how it sounds.

So, without further ado, please type `/lgtm` and click the *Comment* button.

A moment later, we should receive a notification (a comment) saying that *you cannot LGTM your own PR* (remember that you might need to refresh your screen). That makes sense, doesn't it? Why would you review your own code? There is no benefit in that since it would neither result in knowledge sharing nor additional validations. The system is protecting us from ourselves and from making silly mistakes.

![Figure 12-3: Rejected lgtm attempt](images/ch12/prow-lgtm-own-pr.png)

If we are to proceed, we'll need to add a collaborator to the project. Before we do that, I should comment that if `/lgtm` worked, we could use `/lgtm cancel` command. I'm sure you can guess what it does.

Before we explore how to add collaborators, approvers, and reviewers, we'll remove you from the list of assignees. Since you cannot approve your own PR, it doesn't make sense for it to be assigned to you.

Please type `/unassign` and click the *Comment* button. You'll notice that your name disappeared from the list of assignees.

We need to define who is allowed to review and who can approve our pull requests. We can do that by modifying the `OWNERS` file generated when we created the project through the Jenkins X quickstart. Since it would be insecure to allow a person who made the PR to change that file, the one that counts is the `OWNERS` file in the master branch. So, that's the one we'll explore and modify.

```bash
git checkout master

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

I> Feel free to ask someone for help in [DevOps20](http://slack.devops20toolkit.com/) Slack if you do not have a GitHub friend around. I'm sure that someone will be happy to act as a reviewer and an approver of your pull request.

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

git commit \
    --message "Added an owner"

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

Now we can assign the pull request to the newly added approver. Please go to the pull request screen and make sure that you are logged in (as you, not as the approver). Type `/assign @[...]` as the comment, where `[...]` is replaced with the username of the approver. Click the *Comment* button.

The approver should receive a notification email. Please let her know that she should go to the pull request (instructions are in the email), type `/approve`, and click the *Comment* button.

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

## Exploring Additional Slash Commands

We saw some a few of the most commonly employed slash commands used through a typical pull request process. We'll expand on that next by creating a new PR and experimenting with a few other commands.

```bash
git checkout master

git pull

git checkout -b my-pr
```

We created a new branch called `my-pr`.

Next, we'll make a minor change to the source code and push it to the newly created branch. Otherwise, GitHub would not allow us to make a pull request if nothing changed.

```bash
echo "My PR" | tee README.md

git add .

git commit \
    --message "My second PR with prow"

git push --set-upstream origin my-pr
```

We are finally ready to create a pull request.

```bash
jx create pullrequest \
    --title "My PR" \
    --body "What I can say?" \
    --batch-mode
```

Please open the link from the output in your favorite browser.

You will notice that this time your colleague is automatically assigned as a reviewer. Prow took the list of reviewers from the `OWNERS` file and saw that there are only two available. Since you made the pull request, it decided to assign the other user as the reviewer. If wouldn't make sense to assign it to you anyways.

We can also observe that the system automatically added a label *size/XS*. It deduced that the changes we're proposing in this pull request are *extra small*. That is done through the Prow plugin `size`. While some plugins (e.g., `approve`) react to slash commands, others (e.g., `size`) are used as a reaction to other events (e.g., creation of a pull request).

Size labels are applied based on the total number of changed lines. Both new and deleted lines are counted, and the thresholds are as follows.

* size/XS: 0-9
* size/S: 10-29
* size/M: 30-99
* size/L: 100-499
* size/XL: 500-999
* size/XXL: 1000+

Since we rewrote `README.md` with a single line, the number of changed lines is one plus whatever was the number of lines in the file before we overwrote it. We know that up to nine lines were changed in total since we got the label *size/XS*.

Sometimes we might use a code generator and might want to exclude from the calculation the files it creates. In such a case, all we'd need to do is place `.generated_files` to the project root.

Let's imagine that we reviewed the pull request and that we decided that we do not want to proceed in the near future. In such a case, we probably do not want to close it, but we still want to make sure that everyone is aware that it is on hold.

Please type `/hold` and click the *Comment* button. You'll see that the *do-not-merge/hold* label was added. Now it should be clear to everyone that the PR should not be merged. Hopefully, we would also add a comment that would explain the reasons behind such a decision. I will let your imagination kick in and let you compose it.

![Figure 12-6: Pull request with Prow-creted labels](images/ch12/prow-pr-label-hold.png)

At this moment, you might wonder whether it is more efficient to create comments with slash commands that add labels, instead of merely creating them directly. It is not. We could just as easily create a label using GitHub console. But the reason for applying ChatOps principles is not primarily efficiency. Instead, it is more focused on documenting and executing actions. When we write a comment with the `/hold` command, we did not only create a label, but we also recorded who did that (the person who wrote the comment), as well as when it was done. The comments serve as a ledger and can be used to infer the flow of actions and decisions. We can find everything that happened to a pull request by reading the comments from top to bottom.

Now, let's say that the situation changed and that the pull request should not be on hold anymore. Many of the slash commands can be written with `cancel`. So, to remove the label, all we have to do is to write a new comment with `/hold cancel`. Try it out and confirm that the *do-not-merge/hold* label is removed.

All commonly performed actions with pull requests are supported. We can, for example, `/close` and `/reopen` a pull request. Both belong to the *lifecycle* plugin which also supports `/lifecycle frozen`, `/lifecycle stale`, and `/lifecycle rotten` commands that add appropriate labels. To remove those labels, all we have to do is add `remove` as the prefix (e.g., `/remove-lifecycle stale`).

Finally, if you want to bring a bit of life to your comments, try the `/meow` command.

Once you're done experimenting with the commands, please tell the approver to write a comment with the `/lgtm` command and the pull request will be merged to the master branch which, in turn, will initiate yet another Jenkins X build that will deploy a new release to the staging environment.

By now, you hopefully see the benefits of ChatOps, but you are probably wondering how to know which commands are available. We'll explore that next.

## How Do We Know Which Slash Commands Are Available?

The list of Prow plugins and their configuration is stored in ConfigMap `plugins`. Let's describe it and see what we'll get.

```bash
kubectl -n cd describe cm plugins
```

The interesting part is the `plugins` section. We can see that each repository we imported into Jenkins X contains a list of plugins. Jenkins X makes sure that the list is always up-to-date with the imported projects.

The output limited to `jx-prow` is as follows.

```yaml
...
plugins.yaml:
----
...
plugins:
  ...
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
...
```

We already used many of the available plugins (e.g., `approve`). The others (e.g., `config-updater`) do not react to slash commands but are triggered automatically. Feel free to explore the plugins we're using through the [Prow Plugin Catalog](https://prow.k8s.io/plugins) documentation. The details of the commands provided through the plugins are available in [Command Help](https://prow.k8s.io/command-help).

## What Now?

There is at least one crucial Prow-related subject we did not yet explore. We need to figure out how to change the Prow plugins we're using, as well as to find out how to modify the rules that govern the pull request process. We'll go through those and a few other Prow and ChatOps related subjects later. For now, we know how to use ChatOps capabilities that Jenkins X provides out of the box. That is a notable improvement by itself, so we'll leave tweaking for one of the next chapters.

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
```
