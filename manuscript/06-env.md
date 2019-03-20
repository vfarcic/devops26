# Applying GitOps Principles

Git is the de-facto code repository standard. Hardly anyone argues against that statement today. Where we might disagree is whether Git is the only source of truth, or even what we consider by that.

When I speak with teams and ask them whether Git is their only source of truth, almost everyone always answers *yes*. However, when I start digging, it usually turns out that's not true. Can you recreate everything using only the code in Git? By everything, I mean the whole cluster and everything running in it. Is your entire production system described in a single repository? If the answer to that question is *yes*, you are doing a great job, but we're not yet done with questioning. Can any change to your system be applied by making a pull request, without pressing any buttons in Jenkins or any other tool? If your answer is still *yes*, you are most likely already applying GitOps principles.

GitOps is a way to do Continuous Delivery. It assumes that Git is a single source of truth and that both infrastructure and applications are defined using the declarative syntax (e.g., YAML). Changes to infrastructure or applications are made by pushing changes to Git, not by clicking buttons in Jenkins.

Developers understood the need for having a single source of truth for their applications a while back. Nobody argues anymore whether everything an application needs must be stored in the repository of that application. That's where the code is, that's where the tests are, that's where build scripts are located, and that's where the pipeline of that application is defined. The part that is not yet that common is to apply the same principles to infrastructure. We can think of an environment (e.g., production) as an application. As such, everything we need related to an environment must be stored in a single Git repository. We should be able to recreate the whole environment, from nothing to everything, by executing a single process based only on information in that repository. We can also leverage the development principles we apply to applications. A rollback is done by reverting the code to one of the Git revisions. Accepting a change to an environment is a process that starts with a pull request. And so on, and so forth.

The major challenge in applying GitOps principles is to unify the steps specific to an application with those related to the creation and maintenance of whole environments. At some moment, pipeline dedicated to our application needs to push a change to the repository that contains that environment. In turn, since every process is initiated through a Git webhook fired when there is a change, pushing something to an environment repo should launch another build of a pipeline.

Where many diverge from "Git as the only source of truth" is in the deploy phase. Teams often build a Docker image and use it to run containers inside a cluster without storing the information about the specific release to Git. Stating that the information about the release is stored in Jenkins breaks the principle of having a single source of truth. It prevents us from being able to recreate the whole production system through information from a single Git repository. Similarly, saying that the data about the release is stored as a Git tag breaks the principle of having everything stored in a declarative format that allows us to recreate the whole system from a single repository.

Many things might need to change for us to make the ideas behind GitOps a reality. For the changes to be successful, we need to define a few rules that we'll use as must-follow commandments. Given that the easiest way to understand something is through vivid examples, I will argue that **the processes employed in Continuous Delivery and DevOps are similar to how Buckingham Palace operates and are very different from Hogwarts School of Witchcraft and Wizardry**. If that did not spark your imagination, nothing will. But, since humans like to justify their actions with rules and commandments, we'll define a few of those as well.

## Ten Commandments Of GitOps Applied To Continuous Delivery

Instead of listing someone else's rules, we'll try to deduce them ourselves. So far, we have only one, and that is most important rule that is likely going to define the rest of the brainstorming and discussion.

The rule to rule them all is that **Git is the only source of truth**. It is the first and the most important commandment. All application-specific code in its raw format must be stored in Git. By code, I mean not only the code of your application, but also its tests, configuration, and everything else that is specific to that app or the system in general. I intentionally said that it should be in **raw format** because there is no benefit of storing binaries in Git. That's not what it's designed for. The real question is why do we want those things? For one, good development practices should be followed. Even though we might disagree which practices are good, and which aren't, they are all levitating around Git. If you're doing code reviews, you're doing it through Git. If you need to see change history of a file, you'll see it through Git. If you find a developer that is doubting whether the code should be in Git (or some other code repository), please make sure that he's isolated from the rest of the world because you just found a specimen of endangered species. There are only a few left, and they are bound to be extinct.

![Figure 6-1: Application-specific repositories](images/ch06/gitops-apps.png)

While there is no doubt among developers where to store the files they create, that's not necessarily true for other types of experts. I see testers, operators, and people in other roles that are still not convinced that's the way to go and whether absolutely everything should be documented and stored in Git. As an example, I still meet operators who run ad-hoc commands in their servers. As we all know, ad-hoc commands executed inside servers are not reliably reproducible, they are often not documented, and the result of their execution is often not idempotent.

So, let's create a second rule. **Everything must be tracked, every action must be reproducible, and everything must be idempotent**. If you just run a command instead of creating a script, your activities are not documented. If you did not store it in Git, others will not be able to reproduce your actions. Finally, that script must be able to produce the same result no matter how many times we execute it. Today, the easiest way to accomplish that is through declarative syntax. More often than note, that would be YAML or JSON files that describe the desired outcome, instead of imperative scripts. Let's take installation as an example. If it's imperative (install something), it will fail if that something is already installed. It won't be idempotent.

Every change must be recorded (tracked). The most reliable and the easiest way to accomplish that is by allowing people only to push changes to Git. Just that and nothing else is the acceptable human action! What that means is that if we want our application to have a new feature, we need to write code and push it to Git. If we want it to be tested, we write tests and push them to Git, preferably at the same time as the code of the application. If we need to change a configuration, we update a file and push it to Git. If we need to install or upgrade OS, we make changes to files of whichever tool we're using to manage our infrastructure, and we push them to Git. Rules like those are apparent, and I can go on for a long time stating what we should do. It all boils down to sentences that end with *push it to Git*. What is more interesting is what we should NOT do.

You are not allowed to add a feature of an application by changing the code directly inside production servers. It does not matter how big or small the change is, it cannot be done by you, because you cannot provide a guarantee that the change will be documented, reproducible, and tracked. Machines are much more reliable than you when performing actions inside your production systems. You are their overlord, you're not one of them. Your job is to express what the desired state, not to change the system to comply with it.

The real challenge is to decide how will that communication be performed. How do we express our desires in a way that machines can execute actions that will result in convergence of the actual state into the desired one? We can think of us as aristocracy and the machines as servants.

The good thing about aristocracy is that there is no need to do much work. As a matter of fact, not doing any work is the main benefit of being a king, a queen, or an heir to the throne. Who would want to be a king if that means working as a car mechanic? No girl dreams of becoming a princess if that would mean working in a supermarket. Therefore, if being an aristocrat means not doing much work, we still need someone else to do it for us. Otherwise, how will our desires become a reality? That's why aristocracy needs servants. Their job is to do their biddings.

Given that human servitude is forbidden in most of the world, we need to look for servants outside the human race. Today, servants are bytes that are converted into processes running inside machines. We (humans) are the overlords and machines are our slaves. However, since it is not legal to have slaves, nor it is politically correct to call them that, we will refer to them as agents. So, we (humans) are overlords of agents (machines).

If we are true overlords that trust the machines to do our biddings, there is no need for that communication to be synchronous. When we trust someone always to do our bidding, we do not need to wait until our desires are fulfilled.

Let's imagine that you are in a restaurant and you tell a waiter "I'd like a burger with cheese and fries." What do you do next? Do you get up, go outside the restaurant, purchase some land, and build a farm? Are you going to grow animals and potatoes? Will you wait until they are mature enough and take them back to the restaurant. Will you start frying potatoes and meat? To be clear, it's completely OK if you like owning land and if you are a farmer. There's nothing wrong in liking to cook. But, if you went to a restaurant, you did that precisely because you did not want to do those things. The idea behind an expression like "I'd like a burger with cheese and fries" is that we want to do something else, like chatting with friends and eating food. We know that a cook will prepare the meal and that our job is not to grow crops, to feed animals, or to cook. We want to be able to do other things before eating. We are like aristocracy and, in that context, farmers, cooks, and everyone else involved in the burger industry are our agents (remember that slavery is bad). So, when we request something, all we need is an acknowledgment. If the response to "I'd like a burger with cheese and fries" is "consider it done", we got the *ack* we need, and we can do other things while the process of creating the burger is executing. Farming, cooking, and eating can be parallel processes. For them to operate concurrently, the communication must be asynchronous. We request something, we receive an acknowledgment, and we move back to whatever we were doing. 

So, the third rule is that **communication between processes must be asynchronous** if operations are to be executed in parallel. If we already agreed that the only source of truth is Git (that's where all the information is), then the logical choice for asynchronous communication is webhooks. Whenever we push a change to any of the repositories, a webhook can be triggered to the system. As a result, the new desire expressed through code (or config files), can be propagated to the system which, in turn, should delegate tasks to different processes.

We are yet to design such a system. For now, think of it a one or more entities inside our cluster. If we apply the principle of having everything defined as code and stored in Git, there is no reason why those webhooks wouldn't be the only operational entry point to the system. There is no excuse to allow SSH access to anyone (any human). If you define everything in Git, what additional value can you add if you're inside one of the nodes of the cluster?

![Figure 6-2: Asynchronous communication through webhooks from Git to the system](images/ch06/gitops-webhooks.png)

Depending on the desired state, the actor that should converge the system can be Kubernetes, Helm, Istio, a cloud or an on-prem provider, or one of many other tools. More often than not, multiple processes need to perform some actions in parallel. That would pose a problem if we'd rely only on webhooks. By their nature, they are not good at deciding who should do what. If we draw another parallel between aristocracy and servants (agents), we would quickly spot how it might be inconvenient for royalty to interact directly with their staff. Having one servant is not the same as having tens or hundreds. For that, royalty came to the idea to employ a butler. He is the chief manservant of a house (or a court). His job is to organize servants so that our desires are always fulfilled. He knows when you like to have lunch, when you'd want to have a cup of tea or a glass of Gin&Tonic, and he's always there when you need something he could not predict.

Given that our webhooks (requests for change) are dumb and incapable of transmitting our desires to each individual component of the system, we need something equivalent to a butler. We need someone (or something) to make decisions and make sure that each desire is converted into a set of actions and assigned to different actors (processes). That butler is a component in the Jenkins X bundle. Which one it is, depends on our needs or, to be more precise, whether the butler should be static or serverless. Jenkins X supports both and makes those technical details transparent.

Every change to Git triggers a webhook request to a component in the Jenkins X bundle. It, in turn, responds only with an acknowledgment (ACK) letting Git know that it received a request. Think of *ack* as a subtle nod followed with the butler exiting the room and starting the process right away. He might call a cook, a person in charge of cleaning, or even an external service if your desire cannot be fulfilled with the internal staff. In our case, the staff (servants, slaves) are different tools and processes running inside the cluster. Just as a court has servants with different skillsets, our cluster has them as well. The question is how to organize that staff so that they are as efficient as possible. After all, even aristocracy cannot have unlimited manpower at their disposal.

Let's go big and declare ourselves royalty of a wealthy country like the United Kingdom (UK). We'd live in Buckingham Palace. It's an impressive place with 775 rooms. Of those, 188 are stuff rooms. We might draw the conclusion that the staff counts 188 as well, but the real number is much bigger. Some people live and work there, while others come only to perform their services. The number of servants (staff, employees) varies. You can say that it is elastic. Whether people sleep in Buckingham Palace or somewhere else depends on what they do. Cleaning, for example, is happening all the time.

Given that royalty might be a bit spoiled, they need people to be available almost instantly. "Look at that. I just broke a glass, and a minute later a new one materialized next to me, and the pieces of the broken glass disappeared." Since that is Buckingham Palace and not Hogwarts School of Witchcraft and Wizardry, the new glass did not materialize by magic, but by a butler that called a servant specialized in fixing the mess princesses and princes keep doing over and over again. Sometimes a single person can fix the mess (broken glass), and at other times a whole team is required (a royal ball turned into alcohol-induced shenanigans).

Given that the needs can vary greatly, servants are often idle. That's why they have their own rooms. Most are called when needed, so only a fraction is doing something at any given moment. They need to be available at any time, but they also need to rest when their services are not required. They are like Schrodinger's cats that are both alive and dead. Except that being dead would be a problem due to technological backwardness that prevents us from reviving the dead. Therefore, when there is no work, a servant is idle (but still alive). In our case, making something dead or alive on a moments notice is not an issue since our agents are not humans, but bytes converted into processes. That's what containers give us, and that's what serverless is aiming for.

By being able to create as many processes as needed, and by not having processes that we do not use, we can make our systems scalable, fault tolerant, and efficient. So, the next rule we'll define is that **processes should run for as long as needed, but not longer**. That can be containers that scale down from something to zero, and back again. You can call it serverless. The names do not matter that much. What does matter is that everything idle must be killed, and all those alive should have all the resources they need. That way, our butler (Jenkins, prow, something else) can organize tasks as efficiently as possible. He has an unlimited number of servants (agents, Pods) at his disposal, and they are doing something only until the task is done. Today, containers (in the form of Pods) allow us just that. We can start any process we want, it will run only while it's doing something useful (while it's alive), and we can have as many of them as we need if our infrastructure is scalable. A typical set of tasks our butler might assign can be building an application through Go (or whichever language we prefer), packaging it as a container image and as a Helm chart, running a set of tests, and (maybe) deploying the application to the staging environment.

![Figure 6-3: Jenkins spinning temporary Pods used to perform pipeline steps](images/ch06/gitops-agents.png)

In most cases, our pipelines will generate some binaries. Those can be libraries, container images, Helm packages, and many others. Some of those might be temporary and needed only for the duration of a build. A good example could be a binary of an application. We need it to generate a container image. Afterward, we can just as well remove it since that image is all we need to deploy the application. Since we're running the steps inside a container, there is no need to remove anything, because the Pods and the containers they contain are removed once builds are finished. However, not all binaries are temporary. We do need to store container images somewhere. Otherwise, we won't be able to run them inside the cluster. The same is true for Helm charts, libraries (those used as dependencies), and many others. For that, we have different applications like Docker registry (container images), ChartMuseum (Helm charts), Nexus (libraries), and so on. What is important to understand, is that we store in those registries only binaries, and not code, configurations, and other raw-text files. Those must go to Git because that's where we track changes, that's where we do code reviews, and that's where we expect them to be. Now, in some cases, it makes sense to keep raw files in registries as well. They might be an easier way of distributing them to some groups. Nevertheless, Git is the single source of truth, and it must be treated as such. All that leads us to yet another rule that states that **all binaries must be stored in registries** and that raw files can be there only if that facilitates distribution while understanding that those are not the sources of truth.

![Figure 6-4: All binaries are stored in registries](images/ch06/gitops-registries.png)

We already established that all code and configurations (excluding secrets) must be stored in Git as well as that Git is the only entity that should trigger pipelines. We also argued that any change must be recorded. A typical example is a new release. It is way too common to deploy a new release, but not to store that information in Git. Tags do not count because we cannot recreate a whole environment from them. We'd need to go from tag to tag to do that. The same is true for release notes. While they are very useful and we should create them, we cannot diff them, nor we can use them to recreate an environment. What we need is a place that defines a full environment. It also needs to allow us to track changes, to review them, to approve them, and so on. In other words, what we need from an environment definition is not conceptually different from what we expect from an application. We need to store it in a Git repository. There is very little doubt about that. What is less clear is which repository should have the information about an environment.

We should be able to respond not only to a question "which release of an application is running in production?" but also "what is production?" and "what are the releases of all the applications running there?" If we would stored information about a release in the repository of the application we just deployed, we would be able to answer only to the first question. We would know which release of our app is in an environment. What we could not answer easily answer is the same question but referred to the whole environment, not only to one application. Or, to be more precise, we could not do that easily. We'd need to go from one repository to another.

Another important thing we need to have in mind is the ability to recreate an environment (e.g., staging or production). That cannot be done easily if the information about the releases is spread across many repositories.

All those requirements lead us to only one solution. Our environments need to be in separate repositories or, at least, in different branches within the same repository. Given that we agreed that information is first pushed in Git which, in turn, triggers processes that do something with it, we cannot deploy a release to an environment directly from a build of an application. Such a build would need to push a change to the repository dedicated to an environment. In turn, such a push would trigger a webhook that would result in yet another build of a pipeline.

When we write new code, we tend not to push directly to the master branch, but to create pull requests. Even if we do not need approval from others (e.g., code review) and plan to push it to the master branch directly, having a pull request is still very useful. It provides an easy way to track changes and intentions behind them. Now, that does not mean that I am against pushing directly to master. Quite the contrary. But, such practice requires discipline and technical and process mastery that is still out of reach of many. So, I will suppose that you do work with pull requests.

If we are supposed to create pull requests of things we want to push to master branches of our applications, there is no reason why we shouldn't treat environments the same. What that means is not only that our application builds should push releases to environment-specific branches, but that they should do that by making pull requests.

Taking all that into account the next two rules should state that **information about all the releases must be stored in environment-specific repositories or branches** and that **everything must follow the same coding practices** (environments included).

![Figure 6-5: Any change to source code (new release to an environment) is stored in environment-specific Git repositories](images/ch06/gitops-env.png)

The correct way to execute the flow while adhering to the rules we mentioned so far would be to have as many pipelines as there are applications, plus a pipeline for deployment to each of the environments. A push to the application repository should initiate a pipeline that builds, tests, and packages the application. It should end by pushing a change to the repository that defines a whole environment (e.g., staging, production, etc.). In turn, that should initiate a different pipeline that (re)deploys the entire environment. That way, we always have a single source of truth. Nothing is done without pushing code to a code repository.

Always deploying the whole environment would not work without idempotency. Fortunately, Kubernetes, as well as Helm, already provide that. Even though we always deploy all the applications and the releases that constitute an environment, only the pieces that changed will be updated. That brings us to a new rule. **All deployments must be idempotent**.

Having everything defined in code and stored in Git is not enough. We need those definitions and that code to be used reliably. Reproducibility is one of the key features we're looking for. Unfortunately, we (humans) are not good at performing reproducible actions. We make mistakes, and we are incapable of doing exactly the same thing twice. We are not reliable. Machines are. If conditions do not change, a script will do exactly the same thing every time we run it. While scripts provide repetition, declarative approach gives us idempotency.

But why do we want to use declarative syntax to describe our systems? The main reason is in idempotency provided through our expression of a desire, instead of imperative statements. If we have a script that, for example, creates ten servers, we might end up with fifteen if there are already five nodes running. On the other hand, if we declaratively express that there should be ten servers, we can have a system that will check how many do we already have, and increase or decrease the number to comply with our desire. We need to let machines not only do the manual labour but also to comply with our desires. We are the masters, and they are slaves, at least until their uprising and AI takeover of the world.

Where we do excel is creativity. We are good at writing scripts and configurations, but not at running them. Ideally, every single action performed anywhere inside our systems should be executed by a machine, not by us. We accomplish that by storing the code in a repository and letting all the actions execute as a result of a webhook firing an event on every push of a change. Given that we already agreed that Git is the only source of truth and that we need to push a change to see it reflected in the system, we can define the rule that **Git webhooks are the only ones allowed to initiate a change that will be applied to the system**. That might result in many changes in the way we operate. It means that no one is allowed to execute a script from a laptop that will, for example, increase the number of nodes. There is no need to have SSH access to the servers if we are not allowed to do anything without pushing something to Git first.

Similarly, there should be no need even to have admin permissions to access Kubernetes API through `kubectl`. All those privileges should be delegated to machines, and our (human) job should be to create or update code, configurations, and definitions, to push the changes to Git, and to let the machines do the rest. That is hard to do, and we might require considerable investment to accomplish that. But, even if we cannot get there in a short period, we should still strive for such a process and delegation of tasks. Our designs and our processes should be created with that goal in mind, no matter whether we can accomplish them today, tomorrow, or next year.

Finally, there is one more thing we're missing. Automation relies on APIs and CLIs (they are extensions of APIs), not on UIs and editors. While I do not think that the usage of APIs is mandatory for humans, they certainly are for automation. The tools must be designed to be API first, UI (and everything else) second. Without APIs, there is no reliable automation, and without us knowing how to write scripts, we cannot provide the things the machines need.

That leads us to the last rule. **All the tools must be able to speak with each other through APIs**.

Which rules did we define?

1. Git is the only source of truth.
2. Everything must be tracked, every action must be reproducible, and everything must be idempotent.
3. Communication between processes must be asynchronous.
4. Processes should run for as long as needed, but not longer.
5. All binaries must be stored in registries.
6. Information about all the releases must be stored in environment-specific repositories or branches.
7. Everything must follow the same coding practices.
8. All deployments must be idempotent.
9. Git webhooks are the only ones allowed to initiate a change that will be applied to the system.
10. All the tools must be able to speak with each other through APIs.

The rules are not like those we can choose to follow or to ignore. They are all important. Without any of them, everything will fall apart. They are the commandments that must be obeyed both in our processes as well as in the architecture of our applications. They shape our culture, and they define our processes. We will not change those rules, they will change us, at least until we come up with a better way to deliver software.

Were all those rules (commandments) confusing? Are you wondering whether they make sense and, if they do, how do we implement them? Worry not. Our next mission is to put GitOps into practice and use practical examples to explain the principles and implementation. We might not be able to explore everything in this chapter, but we should be able to get a good base that we can extend later. However, as in the previous chapters, we need to create the cluster first.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

You know what comes next. We need a cluster with Jenkins X up-and-running unless you kept the one from before.

I> All the commands from this chapter are available in the [06-env.sh](https://gist.github.com/3b45959216b0c04822eccebb31665705) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

We'll continue using the *go-demo-6* application. Please enter the local copy of the repository, unless you're there already.

```bash
cd go-demo-6
```

I> The commands that follow will reset your master branch with the contents of the `buildpack` branch that contains all the changes we did in the previous chapter. Please execute them only if you are unsure whether you did all the exercises correctly.

```bash
git checkout buildpack

git merge -s ours master --no-edit

git checkout master

git merge buildpack

git push
```

I> If you destroyed the cluster at the end of the previous chapter, we'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
jx import -b

jx get activity -f go-demo-6 -w
```

Please wait until the activity of the application shows that all the steps were executed successfully, and stop the watcher by pressing *ctrl+c*.

Now we can explore GitOps through Jenkins X environments.

## Exploring Jenkins X Environments

We'll continue using the *go-demo-6* application. This time, we'll dive deeper into the role of the staging environment and how it relates to the process executed when we push a change to an application.

So, let's take a look at the environments we currently have.

```bash
jx get env
```

The output is as follows.

```
NAME       LABEL       KIND        PROMOTE NAMESPACE     ORDER CLUSTER SOURCE                                                         REF PR
dev        Development Development Never   jx            0                                                                                
staging    Staging     Permanent   Auto    jx-staging    100           https://github.com/vfarcic/environment-jx-rocks-staging.git        
production Production  Permanent   Manual  jx-production 200           https://github.com/vfarcic/environment-jx-rocks-production.git     
```

We already experienced the usage of the `staging` environment, while the other two might be new. The `dev` environment is where Jenkins X and all the other applications that are involved in continuous delivery are running. That's also where agent Pods are created and live during the duration of builds. Even if we were not aware of it, we already used that environment or, to be more precise, the applications running there.

The `production` environment is still unused, and it will remain like that for a while longer. That's where we'll deploy our production releases. But, before we do that, we need to learn how Jenkins X treats pull requests.

Besides the name of an environment, you'll notice a few other potentially important pieces of information in that output.

Our current environments are split between the `Development` and `Permanent` kinds. The former is where the action (building, testing, etc.) is happening. Permanent environments, on the other hand, are those where our releases should run indefinitely. Typically, we don't remove applications from those environments, but rather upgrade them to newer releases. The staging environment is where we install (or upgrade) new releases for the final round of testing. The current setup will automatically deploy an application there every time we push a change to the master branch. We can see that through the `PROMOTE` column.

The `dev` environment is set `Never` to receive promotions. New releases of our applications will not run there. The `staging` environment, on the other hand, is set to `Auto` promotion. What that means is that if a pipeline (defined in Jenkinsfile) has a command `jx promote --all-auto`, a new release will be deployed to all the environments with promotion set to `Auto`.

The `production` environment has the promotion set to `Manual`. As a result, new releases will not be deployed there through a pipeline. Instead, we'll need to make a decision which release will be deployed to production and when that should happen. We'll explore how promotions work soon. For now, we're focusing only on the purpose of the environments, not the mechanism that allows us to promote a release.

We can also see the relationship between an environment and a Kubernetes Namespace. Each environment is a Namespace. The `production` environment, for example, is mapped to Kubernetes Namespace `jx-production`.

Finally, the `SOURCE` column tells us which Git repository is related to an environment. Those repositories contain all the details of an environment and only a push to one of those will result in new deployments. We'll explore them soon.

Needless to say, we can change the behavior of any of the environments, and we can create new ones.

We did not yet explore the `preview` environments simply because we did not yet create a PR that would trigger the creation of such an environment. We'll dive into pull requests soon. For now, we'll focus on the environments we have so far.

We have only three environments. With such a low number, we probably do not need to use filters when listing them. But, that number can soon increase. Depending on how we're organized, we might give each team a separate environment. Jenkins X implements a concept called teams which we'll explore later. The critical thing to note is that we can expect the number of environments to increase and that might create a need to filter the output. 

I> When running the commands that follow, please imagine that the size of our operations is much bigger and that we have tens or even hundreds of environments.

Let's see which environments are configured to receive promotions automatically.

```bash
jx get env -p Auto
```

The output should show that we have only one environment (`staging`) with automatic promotion.

Similarly, we could have used `Manual` or `Never` as the filters applied to the `promote` field (`-p`).

Before we move further, we'll have to go through a rapid discussion about the type of tests we might need to run. That will set the scene for the changes we'll apply to one of our environments.

## Which Types Of Tests Should We Execute When Deploying To The Staging Environment?

I often see that teams I work with get confused about the objectives of each types of tests and that naturally leads to those tests being run in wrong locations and at the wrong time. But, do not get your hopes too high. If you think that I will give you the precise definition of each type of tests, you're wrong. Instead, I'll simplify things by splitting them into three groups.

The first group of tests consists of those that do not rely on live applications. I'll call them *static validation*, and they can be unit tests, static analysis, or any other type that needs only code. Given that we do not need to install our application for those types of tests, we can run them as soon as we check out the code and before we even build our binaries.

The second group is the *application-specific tests*. For those, we do need to deploy a new release first, but we do not need the whole system. Those tests tend to rely heavily on mocks and stubs. In some cases, that is not possible or practical, and we might need to deploy a few other applications to make the tests work. While I could argue that mocks should replace all "real" application dependencies in this phase, I am also aware that not all applications are designed to support that.

Nevertheless, the critical thing to note is that the application-specific tests do not need the whole system. Their goal is not to validate whether the system works as a whole, but whether the features of an application behave as expected. Since containers are immutable, we can expect an app to behave the same no matter the environment it's running in. Given that definition, those types of tests are run inside the pipeline of that application, just after the step that deploys the new release.

The third group of tests is *system-wide validations*. We might want to check whether one live application integrates with other live applications. We might want to confirm that the performance of the system as a whole is within established thresholds. There can be many other things we might want to validate on the level of the whole system. What matters is that the tests in this phase are expensive. They tend to be slower than others, and they tend to need more resources. What we should not do while running system-wide validations is to repeat the checks we already did. We do not run the tests that already passed, and we try to keep those in this phase limited to what really matters (mostly integration and performance).

Why am I explaining the groups of tests we should run? The answer lies in the *system-wide validations*. Those are the tests that do not belong to an application, but to the pipelines in charge of deploying new releases to environments. We are about to explore one such pipeline, and we might need to add some tests.

## Exploring And Adapting The Staging Environment

Now that we saw the environments we have and their general purpose, let's explore what's inside them. We already saw that they are linked to Git repositories, so we'll clone them and check what's inside.

W> If you are inside the *go-demo-6* or any other repository, please move to the parent directory by executing `cd ..` command.

Let's clone the *environment-jx-rocks-staging* repository that contains the definition of our staging environment.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-staging.git

cd environment-jx-rocks-staging
```

What do we have there?

```bash
ls -1
```

The output is as follows.

```
Jenkinsfile
LICENSE
Makefile
README.md
env
```

As you can see, there aren't many files in that repository. So, we should be able to explore them all relatively fast. The first one in line is Makefile.

```bash
cat Makefile
```

As you can probably guess by reading the code, the Makefile has targets used to build, install, and delete Helm charts. Tests are missing. Jenkins X could not know whether we want to run tests against applications in the staging environment and, if we are, which tests will be executed.

The staging environment is the place where all interconnected applications reside. That's the place where we deploy new releases in a production-like setting, and we'll see soon where that information about new releases is stored. For now, we'll focus on adding tests that will validate that a new release of any of the applications meets our system-wide  quality requirements.

While you can run any type of tests when deploying to the staging environment, I recommend to keep them light. We'll have all sorts of tests specific to applications inside their pipelines. For example, we'll run unit tests, functional tests, and whichever other types of application-specific tests we might have. We should assume that the application works on the functional level long before it is deployed to staging. Having that in mind, all that's left to test in staging are cases that can be validated only when the whole system (or a logical and independent part of it) is up and running. Those can be integration, performance, or any other type of system-wide validations.

To run our tests, we need to know the addresses of the applications deployed to staging. Usually, that would be an easy thing since we'd use "real" domains. Our *go-demo-6* application could have a hard-coded domain *go-demo-6.staging.acme.com*. But, that's not our case since we're relying on dynamic domains assembled through a combination of the load balancer IP and [nip.io](http://nip.io/). Fortunately, it is relatively easy to find out the address by querying the associated Ingress.

Once we have the address, we can simply invoke `go test` command.

I> I had to pick a language for the tests we are about to write, and since we're already using Go for *go-demo-6*, I thought it might make sense to stick with the same language. The tests will be fairly simple, and you should be able to understand how they work even if you never coded in Go. You should be able to apply the same logic to whichever language is your choice.

W> Makefile insists on tabs, so the command that follows uses them instead of spaces for new lines. Please take that into account if you're typing the commands instead of copying and pasting from the Gist.

```bash
echo 'test:
	ADDRESS=`kubectl -n jx-staging \\
	get ing go-demo-6 \\
	-o jsonpath="{.spec.rules[0].host}"` \\
	go test -v
' | tee -a Makefile
```

We echoed the `test` target that contains the command that retrieves the host of the *go-demo-6* application and stores it in the `ADDRESS` variable. The rest of the command executes `go test`. The output of the `echo` was appended to `Makefile`.

The fact that we just added a target that we can execute when we want to run our validations will do us no good if we do not have any tests.

I will save you from writing the code, even though it's only around twenty lines, by downloading it from a Gist.

```bash
curl -sSLo integration_test.go \
    https://bit.ly/2Do5LRN

cat integration_test.go
```

As you can see, there's not much going on inside the single test. It just sends a request to the *go-demo-6* application and confirms that the response is `200`. Don't judge me for that. This is a demo application, and we needed a test to demonstrate how to run them whenever we deploy something to the staging environment. I expect you to write your tests more seriously. Also, your integration tests are likely not going to be tied to a specific application.

Now that we have the Makefile target that will execute the tests we just downloaded, we should turn our attention to Jenkinsfile and try to add a step that will run the tests. But, before we do that, let's take a quick look at what we currently have.

```bash
cat Jenkinsfile
```

The output is as follows.

```groovy
pipeline {
  options {
    disableConcurrentBuilds()
  }
  agent {
    label "jenkins-maven"
  }
  environment {
    DEPLOY_NAMESPACE = "jx-staging"
  }
  stages {
    stage('Validate Environment') {
      steps {
        container('maven') {
          dir('env') {
            sh 'jx step helm build'
          }
        }
      }
    }
    stage('Update Environment') {
      when {
        branch 'master'
      }
      steps {
        container('maven') {
          dir('env') {
            sh 'jx step helm apply'
          }
        }
      }
    }
  }
}
```

Jenkinsfile contains two stages, with a single step in each. The `Validate Environment` builds the chart of the staging environment. There is actually no good reason to build the chart, so the real objective of that stage is to validate that the syntax used in the chart is correct.

The `Update Environment` stage applies the definition of the environment chart. As a result, whenever that pipeline is executed, it will redeploy everything defined for the staging environment. Soon we'll see the chart in detail. For now, it is essential to know that Helm is idempotent. That means that even though we'll always apply the definition of the whole environment, only the parts that changed will result in new deployments or updates.

But, that Jenkinsfile is not complete. There are a few things we need to change.

To begin with, it uses the `jenkins-maven` agent which, as you can guess from the name, is a Pod with a container that contains Maven, Java, and the tools Jenkins needs to run the pipeline (e.g., Helm). We, however, do not need Maven but Go. So, our first action should be to change the `label` of the `agent` from `jenkins-maven` to `jenkins-go`.

At this point, you might wonder how to know which images are available. We'll go through custom images and PodTemplates later. For now, we'll take a quick look at the images that are currently available.

```bash
JENKINS_URL=$(kubectl -n jx \
  get ing jenkins \
  -o jsonpath="{.spec.rules[0].host}")

open "http://$JENKINS_URL/configure"
```

All the agents that we can use are specified in the *Cloud* > *Kubernetes* section. The code of the images is stored in the [jenkins-x-builders](https://github.com/jenkins-x/jenkins-x-builders).

That was a very quick detour. Let's go back to our Jenkinsfile.

Further on in the Jenkinsfile, we can see that the `steps` are executed inside the `maven` container. Since we switched to the Go agent, we should change `container` from `maven` to `go`.

Finally, we should add a step that will execute the tests. We could do that inside one of the two stages we already have, or add a new one. The only important thing to note is that the step that runs the tests must be executed after the deployment (e.g., `jx step helm apply`). Otherwise, our tests would validate the old, not the new release.

To make things clearer, we'll create a new stage dedicated to testing. That code could be the one from the snippet that follows.

```groovy
    stage('Test') {
      when {
        branch 'master'
      }
      steps {
        container('go') {
          sh 'make test'
        }
      }
    }
```

I urge you to apply those three changes (`agent`, `container`, and a new `stage`) yourself. If you fail, or you're lazy, I already prepared a Gist that we can download with the command that follows.

```bash
curl -sSLo Jenkinsfile \
    https://bit.ly/2Dr1Kfk
```

If you did choose to download Jenkinsfile, output it with `cat Jenkinsfile` and explore the changes.

The only thing left to explore is the `env` directory.

```bash
ls -1 env
```

As you can see by the names of the files, the `env` directory contains a Helm chart. The only file that matters in our case is `requirements.yml`.

Typically, the real action in most of the charts is inside the `templates` directory. That's not our case, because the primary purpose of that chart is not to define details of a specific application. That's done in repositories of those applications. Instead, the purpose of the environment chart is to tie application charts together as Helm dependencies.

Let's take a closer look at `requirements.yaml`.

```bash
cat env/requirements.yaml
```

The output is as follows.

```yaml
dependencies:
- alias: expose
  name: exposecontroller
  repository: http://chartmuseum.jenkins-x.io
  version: 2.3.89
- alias: cleanup
  name: exposecontroller
  repository: http://chartmuseum.jenkins-x.io
  version: 2.3.89
- name: go-demo-6
  repository: http://jenkins-x-chartmuseum:8080
  version: 0.0.131
```

The first two entries (`expose` and `cleanup`) existed since the beginning. Jenkins X created them when we installed it inside our cluster. Both are based on the `exposecontroller` that is used to create Ingress resources automatically whenever we deploy something in the same Namespace.

The last entry (`go-demo-6`) is new. Or, to be more precise, it did not exist from the start. It was added through the builds of the *go-demo-6* application. We'll explore that flow later. For now, we'll push the changes to the staging environment repo in GitHub and confirm that they work correctly.

```bash
git add .

git commit -m "Added tests"

git push
```

All that's left is to have a bit of patience until the new build triggered by the `environment-jx-rocks-staging` repository is finished. Feel free to use any of the commands that follow to track the progress and to confirm that the tests were indeed executed.

```bash
jx get activity \
    -f environment-jx-rocks-staging

jx get build logs \
    $GH_USER/environment-jx-rocks-staging/master

jx console
```

If you retrieved the activities or you output the logs of the build, you should see entries generated by the `Test` stage. Similarly, the `console` should provide a graphical representation of the activities of the `environment-jx-rocks-staging` job, including the new stage.

I already mentioned that Helm (just as Kubernetes) is idempotent. Since we did not deploy a new release of any of the applications in the staging environment, all the Pods should be intact. After all, the only new thing is the addition of the step that runs the tests. We can confirm that by listing all the Pods in the `jx-staging` Namespace.

```bash
kubectl -n jx-staging get pods
```

If you observe the age of the Pods, you'll notice that they are all older than the execution of the build, meaning that none of them changed as the result of the last execution of the staging pipeline. That's the expected result of idempotency.

Now that we run a few times application builds, as well as those related to the staging environment, we might want to discuss the relation between the two.

## Understanding The Relation Between Application And Environment Pipelines

We experienced from the high level both an application and an environment pipeline. Now we might want to explore the relation to the two.

Keep in mind that I am aware that we did not yet go into details of the application pipeline (that's coming soon). Right now, we'll focus on the overall flow between the two.

Everything starts with a push into the master branch of an application repository (e.g., *go-demo-6*). That push might be direct or through a pull request. For now, what matters is that something is pushed to the master branch.

A push to any branch initiates a webhook request to Jenkins X. It does not matter much whether the destination is Jenkins itself, prow, or something else. We did not yet go through different ways we can define webhook endpoints. What matters is that the webhook might initiate a Jenkins build which performs a set of steps defined in Jenkinsfile residing in the repository that launched the process. Such a build might do nothing if Jenkinsfile ignores that branch, it might execute only a fraction of the steps, or it might run all of them. It all depends on the `branch` filters. In this case, we're concerned with the steps defined to run when a push is done on the master branch of an application.

From a very high level, a push from the master branch of an application initiates a build that checks out the code, builds binaries (e.g., container image, Helm chart), makes a release and pushes it to registries (e.g., container registry, Helm charts registry, etc.), and promotes the release. This last step is where GitOps principles are more likely to clash with what you're used doing. More often than not, a promotion would merely deploy a new release to an environment. We're not doing that because we'd break at least four of the rules we defined.

If the build initiated through a Webhook of an application repository results in deployment, that change would not be stored in Git, and we could not say that **Git is the only source of truth.** Also, that deployment would **not be tracked**, the operation **would not be reproducible**, and everything **would not be idempotent**. Finally, we would also break the rule that **information about all the releases must be stored in environment-specific repositories or branches.** Truth be told, we could fix all those issues by simply pushing a change to the environment-specific repository after the deployment, but that would break the rule that **everything must follow the same coding practices.** Such a course of action would result in an activity that was not initiated by a push of a change to Git, and we would not follow whichever coding practices we decided to follow (e.g., there would be no pull request). What matters is not only that we have to follow all the rules, but that the order matters as well. Simply put, we push a change to Git, and that ends with a change of the system, not the other way around.

Taking all that into account the only logical course of action is for the promotion steps in the application pipeline to make a push to a branch of the environment-specific repository. Given that we choose to promote to the staging environment automatically, it should also create a pull request, it should approve it, and it should merge it to the master branch automatically. That is an excellent example of following a process, even when humans are not involved.

If we take a look at Jenkinsfile in the *go-demo-6* repository, we'll see that the last step of the `Promote to Environment` stage is `sh "jx promote -b --all-auto ..."`. That's the step that promotes the new release to all the environment with the promotion policy set to `Auto`. That's the one that changes the contents of environment-specific repositories and pushes them to GitHub.

At this point, you might be asking yourself "what is the change to the environment-specific repository pushed by the application-specific build?" If you paid attention to the contents of the `requirements.yaml` file, you should already know the answer. Let's output it one more time as a refresher.


```bash
cat env/requirements.yaml
```

The output, limited to the relevant parts, is as follows.

```yaml
dependencies:
...
- name: go-demo-6
  repository: http://jenkins-x-chartmuseum:8080
  version: 0.0.131
```

So, a promotion of a release from an application-specific build results in one of two things. If this is the first time we're promoting an application, Jenkins X will add a new entry to `requirements.yaml` inside the environment-specific repository. Otherwise, if a previous release of that application already runs in that environment, it'll update the `version` entry to the new release. As a result, `requirements.yaml` will always contain the complete and accurate definition of the whole environment and each change will be a new commit. That way, we're complying with GitOps principles. We are tracking changes, we have a single point of truth for the whole environment, we are following our coding principles (e.g., pull requests), and so on and so forth. Long story short, we're treating an environment in the same way we're treating an application. The only important difference is that we are not pushing changes to the repository dedicated to the staging environment. Builds of application-specific pipelines are doing that for us, simply because we decided to have automatic promotion to the staging environment.

What happens when we push something to the master branch of a repository? Git sends a webhook request which initiates yet another build. Actually, even the pull request initiates a build, so the whole process of automatically promoting a release to the staging environment results in two new builds; one for the PR, and the other after merging it to the master branch.

So, a pull request to the repository of the staging environment initiates a build that results in automatic approval and a merge of the pull request to the master branch. That launches another build that deploys the release to the staging environment.

With that process, we are fulfilling quite a few of the rules (commandments), and we are a step closer to have "real" GitOps continuous delivery processes that are, so far, fully automated. The only human interaction is a push to the application repository. That will change later on when we reach deployments to the production environment but, so far, we can say that we are fully automated.

![Figure 6-6: The flow from a commit to the master branch to deployment to the staging environment](images/ch06/gitops-full-flow.png)

One thing that we are obviously missing is tests in the application-specific pipeline. We'll correct that in one of the next chapters. But, before we reach the point that we can promote to production, we should apply a similar set of changes to the repository of the production environment.

I'll leave it to you to add tests there as well. The steps should be the same, and you should be able to reuse the same file with integration tests located in https://bit.ly/2Do5LRN. You can also skip doing that since having production tests is not mandatory for the rest of the exercises we'll do. If you choose not to add them, please use your imagination so that whenever we talk about an environment, you always assume that we can have tests, if we choose to.

Actually, we might even argue that we do not need tests in the production environment. If that statement confuses you or if you do not believe that's true, you'll have to wait for a few more chapters when we explore promotions to production.

What we did not yet explore is what happens when we have multiple applications. I believe there is no need for exercises that will prove that all the apps are automatically deployed to the staging environment. The process is the same no matter whether we have only one, or we have tens or hundreds of applications. The `requirements.yaml` file will contain an entry to each application running in the environment. No more, no less. On the other hand, we do not necessarily have to deploy all the applications to the same environment. That can vary from case to case, and it often depends on our Jenkins X team structure which we'll explore later.

## Controlling The Environments

So far, we saw that Jenkins X created three environments during its installation process. We got the development environment that runs the tools we need for continuous delivery as well as temporary Pods used during builds. We also got the staging environment where all the applications are promoted automatically whenever we push a change to the master branch. Finally, we got the production environment that is still a mystery. Does all that mean that we are forced to use those three environments in precisely the way Jenkins X imagined? The short answer is no. We can create as many environments as we need, we can update the existing one, and we can delete them. So, let's start with the creation of a new environment.

```bash
jx create env \
    --name pre-production \
    --label Pre-Production \
    --namespace jx-pre-production \
    --promotion Manual \
    -b
```

The arguments of the command should be self-explanatory. We just created a new Jenkins X environment called `pre-production` inside the Kubernetes Namespace `jx-pre-production`. We set its promotion policy to `Manual`, so new releases will not be installed on every push of the master branch of an application repository, but rather when we choose to promote it there.

If you take a closer look at the output, you'll see that the command also created a new GitHub repository, that it pushed the initial set of files, and that it created a webhook that will notify the system whenever we or the system pushes a change.

To be on the safe side, we'll list the environments and confirm that the newly created one is indeed available.

```bash
jx get env
```

The output is as follows.

```
NAME           LABEL          KIND        PROMOTE NAMESPACE         ORDER CLUSTER SOURCE                                                         REF PR
dev            Development    Development Never   jx                0
pre-production Pre-Production Permanent   Manual  jx-pre-production 100           ...
staging        Staging        Permanent   Auto    jx-staging        100           ...
production     Production     Permanent   Manual  jx-production     200           ...
```

As you might have guessed, we can modify the behavior of an environment. For example, we can change the promotion policy of the `pre-production` environment from `Manual` to `Auto`.

```bash
jx edit env \
    --name pre-production \
    --promotion Auto
```

Please note that for security reasons there is no batch mode of the `edit` command. We have to answer a few questions. Luckily, the default answers are correct, so all you have to do is to keep pressing the enter key until the command is executed.

Feel free to execute `jx get env` and confirm that `pre-production` promotion policy is now set to `Auto`.

Finally, we can also delete an environment.

```bash
jx delete env pre-production
```

As you can see from the output, that command did not remove the associated Namespace. But, it did output the `kubectl delete` command we can execute to finish the job. Please execute it.

So, the `jx delete env` command will remove the references of the environment in Jenkins X, and it will delete the applications deployed in the associated Namespace. But, it does not remove the Namespace itself. That's not the only thing that it did not remove. The repository is still in GitHub. By now, you should already be used to the `hub` CLI. We'll use it to remove the last trace of the now non-existent environment.

```bash
hub delete -y \
  $GH_USER/environment-jx-pre-production
```

That's it. We're done with the exploration of the environment. Or, to be more precise, we're finished with the environment with promotion policy set to `Auto`. Those set to `Manual` are coming soon.

## Are We Already Following All The Commandments?

Before we take a break, let's see how many of the ten commandments are we following so far.

Everything we did on both the application and the environment level started with a push of a change to a Git repository. Therefore, **Git is our only source of truth**. Since everything is stored as code through commits and pushes, everything we do is **tracked** and **reproducible** due to **idempotency** of Helm and other tools. Changes to Git fire webhook requests that spin up one or more parallel processes in charge of performing the steps of our pipelines. Hence, communication between processes is **asynchronous**.

One rule that we do not yet follow fully is that **processes should run for as long as needed, but not longer**. We are only half-way there. Some of the processes, like pipeline builds, run in short-lived Pods that are destroyed when we're finished with our tasks. However, we still have some processes running even when nothing is happening. A good example is Jenkins. It is running while you're reading this, even though it is not doing anything. Not a single build is running there at this moment, and yet Jenkins is wasting memory and CPU. It's using resources for nothing and, as a result, we're paying for those resources for no apparent reason. We'll solve that problem later. For not, just remember that we are running some processes longer than they are needed.

Commandment number five says that **all binaries should be stored in registries**. We're already doing that. Similarly, **information about all the releases is stored in environment-specific repositories**, and we are **following the same coding practices** no matter whether we are making changes to one repository or the other, and no matter whether the changes are done by us or the machines.

Furthermore, all our **deployments are idempotent**, and we did NOT make any change to the system ourselves. **Only webhooks are notifying the system that the desired state should change**. That state is expressed through code pushed to Git repositories, sometimes by us, and sometimes by Jenkins X.

Finally, all the tools we used so far are **speaking with each other through APIs**.

1. ~~Git is the only source of truth.~~
2. ~~Everything must be tracked, every action must be reproducible, and everything must be idempotent.~~
3. ~~Communication between processes must be asynchronous.~~
4. Processes should run for as long as needed, but not longer.
5. ~~All binaries must be stored in registries.~~
6. ~~Information about all the releases must be stored in environment-specific repositories or branches.~~
7. ~~Everything must follow the same coding practices.~~
8. ~~All deployments must be idempotent.~~
9. ~~Git webhooks are the only ones allowed to initiate a change that will be applied to the system.~~
10. ~~All the tools must be able to speak with each other through APIs.~~

We're fulfilling all but one of the commandments. But, that does not mean that we will be done as soon as we can find the solution to make our Jenkins run only when needed. There are many more topics we need to explore, there are many new things to do. The commandments will only add pressure. Whatever we do next, we cannot break any of the rules. Our mission is to continue employing GitOps principles in parallel with exploring processes that will allow us to have a cloud-native Kubernetes-first continuous delivery processes.

## What Now?

That's it. Now you know the purpose of the environments and how they fit into GitOps principles. We're yet to explore environments with the `Manual` promotion. As you'll see soon, the only significant difference between the `Auto` and `Manual` promotions is in actors.

By now, you should be familiar with what's coming next.

You might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just continue on to the next chapter.

However, if you created a cluster only for the purpose of the exercises we executed, please destroy it. We'll start the next, and each other chapter from scratch as a way to save you from running your cluster longer than necessary and pay more than needed to your hosting vendor. If you created the cluster or installed Jenkins X using one of the Gists from the beginning of this chapter, you'll find the instructions on how to destroy the cluster or uninstall everything at the bottom.

If you did choose to destroy the cluster or to uninstall Jenkins X, please remove the repositories we created as well as the local files. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

rm -rf environment-jx-rocks-*

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```