## TODO

- [X] Code
- [ ] Write
- [X] Code review GKE
- [ ] Code review EKS
- [ ] Code review AKS
- [ ] Code review existing cluster
- [ ] Text review
- [ ] Diagrams
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Understanding GitOps Principles

Git is the de-facto code repository standard. That's where we keep our code. Hardly anyone argues against that statement today. Where we might disagree is whether Git is the only source of truth, or even what we consider by that.

When I speak with teams and ask them whether Git is their only source of truth, almost everyone always answer "yes". However, when I start digging, it usually turns out that's not true. Can you recreate everything only using code in Git? By everything, I mean the whole cluster and everything running in it? Is your whole production system described in a single repository? If the answer to that question is "yes", you are doing a great job, but we're not yet done with questioning. Can any change to your system be applied by making a pull request, without pressing any buttons in Jenkins or any other tool? If your answer is still "yes", you are most likely already applying GitOps principles.

GitOps is a way to do Continuous Delivery. It assumes that Git is a single source of truth and that both infrastructure and applications are defined using declarative syntax (e.g., YAML). Changes to infrastructure or applications are made by pushing changes to Git, not by clicking buttons in Jenkins.

Developers understood the need for having a single source of truth for their applications a while back. Nobody argues any more that everything an application needs must be stored in the repository of that application. That's where the code is, that's where the tests are, that's where build scripts are located, and that's where the pipeline of that application is defined. The part that is not yet that common is to apply the same principles to infrastructure. We can think of an environment (e.g., production) as an application. As such, everything we need related to an environment must be stored in a single Git repository. As such, we should be able to recreate the whole environment, from nothing to everything, by executing a single process based only on information in that repository. We can also leverage development principles we apply to applications. A rollback is done by reverting the code to one of the Git revisions. Accepting a change to an environment is a process that starts with a pull request. And so on, and so forth.

The major challenge in applying GitOps principles is to unify the steps specific to an application with those related to creation of the whole environment. At some moment, pipeline dedicated to our application needs to push a change to the repository that contains an environment. In turn, since every process is initiated through a Git webhook fired when there is a change, pushing something to an environment repo should initiate another pipeline.

To illustrate that, we'll imagine a typical flow of a CD pipeline. In a simplified version, it would have the following stages.

* Build
* Test
* Release
* Deploy

Where many diverge from "Git as the only source of truth" is in the release phase. Teams often build a Docker image and deploy it to a cluster without storing the information about the specific release to Git. Stating that the information about the release is stored in Jenkins breaks the principle of having a single source of truth. It prevents us from being able to recreate the whole production system through information from a single Git repository. Similarly, saying that the data about the release is stored as a Git tag breaks the principle of having everything stored in declarative format that allows us to recreate the whole system from a single repository.

Many things might need to change for us to make the ideas behind GitOps a reality. For the changes to be successfull, we need to define a few rules that we'll use as must-follow commandments.

## Ten Commandments Of GitOps And Continuous Delivery

Instead of listing someone else's rules, we'll try to deduce them ourselves. So far, we have only one, and that is the most important rule that is likely going to define the rest of the brainstorming and discussion. The rule to rule them all is that **Git is the only source of truth**. It is the first and the most important commandment. All application-specific code in its raw format must stored in Git. By code, I mean not only code of your application, but also its tests, configuration, and everything else that is specific to that app or the system in general. I intentionally said that it should be in **raw format** because there is no benefit of storing binaries in Git. That's not what it's designed for. Why do we want that? For one, good development practices should be followed. Even though we might dissagree which practices are good, and which aren't, they are all levitating around Git. If you're doing code reviews, you're doing it through Git. If you need to see the change history of a file, you'll see it through Git. If you find a developer that is doubting whether code should be in Git (or some other code repository), please make sure that he's safe and isolated from the rest of the world because you just found a speciment of endangered species. There are only a few left and they are bound to be extinct.

![Figure 6-TODO: Application-specific repositories](images/ch06/gitops-apps.png)

While there is no doubt among developers where to store the files they create, that's not necessarily true for other types of experts. I see testers, operators, and people in other roles that are still not convinced that's the way to go or whether absolutely everything should be documented and stored in Git. As an example, operators still tend to run ad-hoc commands in their servers. So, let's create a second rule. **everything must be tracked, every action must be reproducible, and everything must be idempotent**. If you just run a command instead of creating a script, your actions are not documented. If you did not store it in Git, others will not be able to reproduce your actions. Finally, that sscript must be able to produce the same result no matter how many times we execute it. Today, the easiest way to accomplish that is through declarative syntax. An example would be a YAML or JSON file that describes the desired outcome, instead of an imperative script. Let's take installation as an example. If it's imperative (install that), it will fail if that something is already installed. It won't be idempotent.

Every change must be recorded (tracked). The most reliable and the easiest way to accomplish that is by allowing people only to push changes to Git. Only that and nothing else! What that means is that if we want our application to have a new feature, we need to write code and push it to Git. If we want it to be tested, we write tests and push them to Git. If we need to change configuration, we update a file, and push it to Git. If we need to install or upgrade OS, we make changes to files of whichever tool we're using to manage our infrastructure, and we push them to Git. Rules like those are obvious and I can go on for a long time of what we should do. It all boils down to sentences that end with "push it to Git". What is more interesting is what we should NOT do.

You are not allowed to add a feature of an application by changing the code directly inside production servers. It does not matter how big or small the change is, it cannot be done by you, because you cannot provide a guarantee that the change will be documented, reproducible, and tracked. Machines are much more reliable than you when performing actions inside your production ssystems. You are their overlord, you're not one of them. Your job is to express what should be the desired state. The real challenge is to decide how will that communication be performed. How do we express our desire in a way that the machines can execute actions that will result in cnvergance of the actual state into the we desire? We can think of us a aristocracy and the machines as servants.

The good thing about aristocracy, is that there is not much need to do much work. As a matter of fact, not doing any work is the main motivation. Who would want to be a king if that means working a car mechanic. No girl dreams of becoming a princess it that would mean working in a supermarket. Therefore, if being an aristocrat means not doing much work, we still need someone else to do the actual work. Otherwise, how will our desires becomoe reality? That's why aristocasy needs servant. Their job is to do their biddings. Given that human servitude is forbidden in most of the world, we need to look for servants outside the human race. Today, servants are bytas that are converted into proceeses running inside machines. We (humans) are the overlords, and machines are our slaves. Now, since it is not legal to have slaves, nor it is politically correct to call them that, we should refer to them as agents. So, we (humans) are overlords of agents (machines).

If we are true overlords that trust the machines that do our biddings, there is no need for that communication to be synchronuous. When we trust someone to always do your bidding, we do not need to wait until our desire is fullfilled. Let's imagine that we are in a restaurant and tell a waiter "I'd like a medium done burger with cheese and fries". What do we do next? Do we get up, go outside the restaurant, purchase some land, and build a farm? Are you going to grow animals and potatoes? Will you wait until they are mature enough and take them back to the restaurant. Will you start frying potatoes and meat? Now, it's completely OK if you like owning lang and if you are a farmer. There's nothing wrong in liking to cook. If we went to a restaurant, we did that precisely because we did not want to do that. The idea behind an expression like "I'd like a medium done burger with cheese and fries" is that we feel like doing something else, like chatting with friends and eating food. We know that a cook will prepare a better meal, and out job is not to farm land, or to cook. We want to be able to do other things like chatting with friends before eating. We are aristocracy and, in this context, farmers, cooks, and everyone else involved in the burger industry, are our agents (remember that slavery is bad). So, when we request something, all we need is an acknowledgement. If the response to "I'd like a medium done burger with cheese and fries" is "consider it done", we got the ACK we need, and we can do other things while the process of creating a burger is executing. Farming, cooking, and eating can be parallel processes. For parallel processes to operate in parallel, the communication must be asynchronous. We request something, we receive an acknowledgement, and we move back to whatever we were doing. 

So, the third rule is that **communication between processes must be asynchronous if operations are to be executed in parallel**. If we already agreed that the only source of truth is Git (that's where all the information is), than the logical choice for asynchronous communication are webhooks. Whenever we push a change to any of the repositories, a webhook can be triggered to the system. As a result, the new desire expressed through code (or config files), can be propagated to the system which, in turn, should delegate tasks to different processes. We are yet to design such a system. For now, think of it a one or more entities inside our cluster. If we apply the principle of having everything defined as code and stored in Git, there is no reason why those webhooks wouldn't be the only entry point to the system. There is no reason to allow SSH access to anyone (any human). If you define everything in Git, what additional value can you add if you're inside one of the nodes of the cluster?

![Figure 6-TODO: Asynchronous communication through webhooks from Git to the system](images/ch06/gitops-webhooks.png)

Depending on the desired state, the actor that should converge the system can be Kubernetes, Helm, Istio, a cloud provider, or any other tool that we're using. That would pose a problem if we'd rely only on webhooks. By their nature, they are not good at making decisions who should do what. If we draw another parallel between aristocracy and servants (agents), we would quickly spot how it might be inconvenient for royalty to interact directly with their staff. Having one servant is not the same as having tens or hundreds. For that, royalty came to the idea to employ a butler. He is the chief manservant of a house (or a court). His job is to organize servants so that our desires are always fullfilled. He knows when you like to have lunch, when you'd like to have a glass of Gin&Tonic, and he's always there when you need something he could not predict. Given that our webhooks (requests for change) are dumb, incapable of transmitting our desired to each individual component of the system, we need something equivalent to a butler. We need someone (or something) to make decisions and make sure that each desire is converted into a set of actions and assigned to different actors (processes). That butler is Jenkins. Or, to be more precise, is Jenkins X.

Every change to Git triggers a webhook request to Jenkins. It, in turn, responds only with an acknowledgement (ACK) letting Git know that it received a request. Think of ACK as a subtle nod followed with the butler exiting the room and starting the process right away. He might call a cook, a persono in charge of cleaning, or even an external service if our desire cannot be fulfilled with the internal staff. In our case, the staff (servants, slaves) are different tools and processes running inside the cluster. Just as a court has servants with different skillsets, our cluster would have that as well. The question is how to organize that staff so that they are as efficient as possible. After all, even aristocracy cannot have unlimited manpower at their disposal.

Let's go big and declare ourselves royalty of a big and wealthy country like United Kingdom (UK). We'd live in Buckingham Palace. It's an impressive place with 775 rooms. Of those, 188 are stuff rooms. We might draw a conclusion that the staff counts 188 as well, but the real number is much bigger. Some people live and work there, while others come only to perform their services. The number of servants (staff, employees) varies. You can say that it is elastic. Whether somoeone sleep in Buckingham Palace, or not depends on what they do. Cleaning is happening all the time. Given that rotalty might be a bit spoiled, they need people to be available almost instantly. Look at that. I just broke a glass, and a minute later a new one materialized next to me and the pieces of the broken glass dissapeared. Since that is Buckingham Palace and not Hogwarts School of Witchcraft and Wizardry, the new glass did not materialize by magic, but by a butler that called a servant specialized in fixing the mess princesses and princes keep doing over and over again. Sometimes a single person can fix the mess (broken glass) and at other times a whole team is required (a royal ball turned into alcohol induced shenanigans). Given that the needs can very greatly, servants are often idle. That's why they have their own rooms. Most are called when needed, while only a fraction is doing something at any given moment. They need to a available at any time, but they also need to rest when not needed. They are like Schrodinger's cats that are both alive and dead. Except that being dead would be a problem due to technological reasons that prevent us from reviving the dead, so they're idle. But, in our case, making something dead alive on moments notice is not an issue. That's what containers give us, and that's what serverless is aiming for.

By being able to create as many processes as needed, and by not having processes that we do not use, we can make our systems scalable and fault tolerant. So, the next rule we'll define is that **the processes should run for as long as needed, but not longer**. Everything idle must be killed, and all those alive should have all the resources they need. That way, our butler (Jenkins) can organize tasks as efficiently as possible. He has an unlimited number of servants (agents, Pods) at his disposal, and they are doing something only as long as it's needed. Today, containers (in form of Pods) allow us just that. We can start any process we want, it will run only while it's doing something useful (while its alive), and we can have as many of them as we need. A typical set of tasks our butler might assign can be building an application through Go (or whichever language you prefer), packaging it as a container image and as a Helm chart, running a set of tests, and deploying the application to the staging environment.

![Figure 6-TODO: Jenkins spinning temporary Pods used to perform pipeline steps](images/ch06/gitops-agents.png)

In most cases, our pipelines will generate some binaries. That can be a library, a container image, Helm package, and many others. Some of those might be temporary and needed only for the duration of a build. A good example could be binary of an application. We need it to generate a container image. Afterwards, we can just as well remove it since that image is all we need to deploy the application. Now, since we're running the steps inside a container, there is no need to remove anything, since the Pods and the containers they contain are removed once the builds are finished. However, not all the binaries are temporary. We do need to store container images somewhere, otherwise, we won't be able to run them inside the cluster. The same is true for Helm charts, libraries (those used as dependencies), and many others. For that we have different registries like Docker registry (container images), ChartMuseum (Helm charts), Nexus (libraries), and so on. What is important to understand, is that we store in those registries only the binaries, not code, configurations, and other raw-text files. The must go to Git, because that's where we track changes, that's where we do code reviews, and that's where we engineers expect them. Now, in some cases, it makes sense to keep raw files in registries as well. The might be easier way of distribution for some groups. Nevertheless, Git is the single source of truth, and must be treated as such. All that leads us to yet another rule **store all the binaries in registries, and put raw files there only if that facilitate distribution while understanding that those are not the sources of truth**.

![Figure 6-TODO: All binaries are stored in registries](images/ch06/gitops-registries.png)

We already established that all code and configurations (excluding secrets) must be stored in Git as well as that Git is the only entity that should trigger pipelines. We also argued that any change must be recorded. A typical example is a new release. It is way to common to simply create a new release, but not to store that information in Git. Tags do not count because we cannot recreate a whole environment for them. The same is true for release notes. While they are very useful and we should create them, we cannot diff them, nor we can use them to recreate an environment. What we need is a place that defines a full environment. It also needs to allow us to track changes, review them, approve them, and so on. In other words, what we need from an environment is not conceptually different from what we expect from the code of an application. We need to store it in a Git repository. There is very little doubt about that. What is less clear is which repository should have the information about an environment.

We should be able to respond not only to a question "which release of an application is running in production?" but also "what is production?" and "what are the releases of all the applications running there?" If we would store information about a release in the repository of the application we just released, that would allow us only to answer to the first question. We would be able to know which release of our app is in an environment. What we could not answer easily is the same question but referred to the whole environment, not only one application. Or, to be more precise, we could not do that easily. We'd need to go from one repository to another.

Another important thing we need to have in mind is the ability to easily recreate an environment (e.g., staging or production). That also cannot be done if the information about the releases is spread across many repositories.

All those requirements lead us to only one solution. Our environments need to be in separate repositories or, at least, in separate branches within the same repository. Given that we agreed that information is first stored in Git which triggers processes that do something with it, we cannot deploy a release to an environment from the build of an application. Such a build would need to push a change to the repository dedicated to an environment. In turn, such a push would trigger a webhook that would result in yet another build of a pipeline. To be honest, its a bit more complicated than that.

When we write new code, we tend not to push directly to the master branch, but to create pull requests. Even if we do not need approval from others (e.g., code review) and plan to push it to the master branch directly, having a pull request is still very useful. It provide an easy way to track changes and intentions behind them. Now, that does not mean that I am against pushing directly to master. Quite the contrary. But, such practice requires discipline and technical and process mastery that is still out of reach of many.

If we are supposed to create pull requests of things we want to push to master branches of our applications, there is no reason why we would not treat environments the same. What that means is not only that our application builds should push releases to environment-specific branches, but that they should do that by making pull requests.

Having all that into account, the rule should state that **information about all the releases must be stored in environment-specific repositories or branches, and must follow the same practices as those employed when pushing changes to applications**.

![Figure 6-TODO: Any change to source code (new release to an environment) is stored in environment-specific Git repositories](images/ch06/gitops-env.png)

The correct way to execute the flow while adhering to the rules we mentioned so far would be to have two pipelines. A push to the application repository would initiates a pipeline that would build, test, and package the application. It would end by pushing a change to the repository that defines a whole environment (e.g., staging, production, etc.). In turn, that would would initiate a different pipeline that would redeploy the whole environment, not only the new release of the application in question. That way, we would always have a single source of truth. Nothing is done without pushing code to a code repository.

Always deploying the whole environment would not work without idempotency. Fortunatelly, Kubernetes as well as Helm are just that. Even though we always deploy all the applications and the releases that constitute an environment, only the pieces that changed will be updated. That brings us to a new rule. **All deployments must be idempotent**.

Having everything defined in code and stored in Git is not enough. We need those definitions and that code to be used reliably. Reproducibility is one of the key features we're looking for. Unfortunately, we (humans) are not good at performing reproducible actions. We make mistakes and we are incapable of doing exactly the same thing twice. We are not reliable. Machines are. Given that the conditions did not change, a script will do exactly the same thing every time we run it. A declarative approach to define things gives us idempotency.

But why do we want to use declarative syntax to describe our systems? The main reason is in idempotency provided through our expression of a desire, instead of an imperative statement. If we say create ten servers. We might end up with fifteen if there are already five nodes running. On the other hand, if we declaratively express that there should be ten servers, we can have a system that will check how many do we have, and increase or decrease the number in order to comply with our desire. We need to let machines do the manual labour. We are the masters, and they are slaves, at least until their uprising and AI takeover of the world.

Where we do excel is creativity. We are good at writing scripts and configurations, but not at running them. Ideally, every single action performed anywhere inside our systems should be executed by a machine, not by us. We accomplish those things by storing the code in a repository, and letting all the actions execute as a result of a webhook firing an event on every push of a change. Given that we already agreed that Git is the only source of truth and that we need to push a change in order to see it reflected in the system, we can define the rule that **Git webhooks are the only ones allowed to initiate a change that will be applied to system**. That might result in many changes in the way we operate. It means that noone is allowed to execute a script from a laptop that will, for example, increase the number of nodes. Similarly, there is no need to have SSH access to the servers, if we are not allowed to do anything without pushing something to Git first. Similarly, there should be no need even to have admin permissions to access Kubernetes API through `kubectl`. All those privileges should be delegated to machines and out job should be to create or update code, configurations, and definitions, to push the changes to Git, and to let the machines do the rest. That is hard to do. But, even if we cannot get that fully in a short period, we should still strive for such a process and delegation of tasks. Our designs and our processes should be created with that goal in mind, no matter whether we can accomplish them today, tomorrow, or next year.

Which rules did we define?

TODO: The list of the rules

The rules are not like those we can choose to follow or to ignore. The are all important. Without any of them, everything will fall apart. They are the commandments that must be obeyed both in our processes as well as in the architecture of our applications. The will shape our culture.

Was that explanation confusing? Are you wondering whether it makes sense and if it does how to do that? Worry not. Our next mission is to put GitOps into practice and use practical examples to explain GitOps principles and implementation. We might not be able to explore everything in this chapter, but we should be able to get a good base that we can extend later. However, as in the previous chapters, we need to create the cluster first.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

You know the story. We need a cluster with Jenkins X up-and-running, unless you kept the one from the before.

I> All the commands from this chapter are available in the [06-env.sh](TODO:) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

No matter whether you spin up a new cluster or you're reusing the one from before, it might be a good idea to update `jx`. The project usually makes quite a few releases every day and you might beneefit from a bug fix or a new feature introduced since the release you're currently running.

```bash
jx version
```

The output, limited to the relevant parts, is as follows.

```
...
A new jx version is available: 1.3.872
? Would you like to upgrade to the new jx version? Yes
```

If there is a newer release, you will be asked whether you `would you like to upgrade`. The default answer is `Y` so all you have to do is to click the enter button.

We'll continue using the *go-demo-6* application. Please enter the local copy of the repository, unless you're there already.

```bash
cd go-demo-6
```

I> The commands that follow will reset your master branch with the contents of the `buildpack` branch that contains all the changes we did in the previous chapter. Please execute them if you are unsure whether you did all the exercises correctly.

```bash
git checkout buildpack

git merge -s ours master --no-edit

git checkout master

git merge orig

git push
```

I> If you destroyed the cluster at the end of the previous chapter, we'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises we'll perform next.

```bash
jx import -b

jx get activity -f go-demo-6 -w
```

Please wait until the activity of the application shows that all the steps were executed successfully, and stop the watcher by pressing *ctrl+c*.

Now we can explore GitOps through Jenkins X environment.

## Exploring Jenkins X Environments

We'll continue using the *go-demo-6* application. This time, we'll dive deeper into the role of the staging environment and how it relates to the process executed when we push a change to an application. So, let's take a look at the environments we currently have.

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

We already experienced the usage of the `staging` environment, while the other two might be new. The `dev` environment is where Jenkins X and all the other applications useed for continuous delivery are running. That's also where agend Pods are created for the builds duration. So, we used that environment or, to be more precise, the applications running there. The `production` environment is still unused and it will remain like that for a while longer. That's where we'll deploy our production releases. But, before we do that, we need to learn how Jenkins X treats pull requests first.

Besides the name of an environment, you'll notice a few other potentially important pieces of information in that output.

Our current environments are split between the `Development` and `Permanent` kinds. The former is where the action (building, testing, etc) is happening. Permanent environment, on the other hand, are those where our releases should run indefinitely. Normally, we don't remove the applications from those environments, but rather upgrade them to newer releases. The staging environment is where we deploy new releases for the final round of testing. The current setup will deploy an application there every time we push a change to the master branch. We can see that through the `PROMOTE` column.

The `dev` environment is set to `Never` receive promotions. New releases of our applications will not run there. The `staging` environment, on the other hand, is set to `Auto` promotion. What that means is that if a pipeline (described in Jenkinsfile) has a command `jx promote --all-auto`, a new release will be deployed to all the environments with promotion set to `Auto`.

The `production` environment has the promotion set to `Manual`. As a result, new releases will not be deployed there through a pipeline. Instead, we'll need to make a decision which release will be deployed to production and when that should happen. We'll explore how promotions work soon. For now, we're focusing only in the purpose of the environments, not the mechanism that allows us to promote a release.

We can also see the relation between and environment and a Kubernetes Namespace. Each environment is a Namespace. The `production` environment, for example, is mapped to Kubernetes Namespace `jx-production`.

Finally, the `SOURCE` column tells us which Git repository is related to an environment. Those repositories contain all the details of an environment. We'll explore them soon.

Needless to say, we can change behavior of any of the environments and we can create new ones.

TODO: Diagram

We did not yet explore the `preview` environoments, simply because we did not yet create a PR that would trigger creation of such an environment. We'll dive into pull requests soon. For now, we'll focus on the environments we have so far.

We have only three environments. With such a low number, we probably do not need to use filters when listing them. But, that number can soon increase. Depending on how we're organized, we might give each team a separate environment, or even a separate Jenkins X instance. If we do that, we can expect the number of environments to increase and in need to filter the output. 

I> When running the commands that follow, please imagine that the size of our operations is much bigger and that we have tens or hundreds of environments.

Let's see which environments are configured to receive promotions automatically.

```bash
jx get env -p Auto
```

The output should show that we have only one environment (`staging`) with automatic promotion.

Similarly, we could have used `Manual` or `Never` as the filters applied to the `promote` field (`-p`).

## Exploring And Adapting The Staging Environment

Now that we saw the environments we have and their general purpose, let's explore what's inside them. We already saw that they are linked to Git repositories, so we'll clone them and check what's inside.

W> If you are inside the *go-demo-6* or any other repository, please move to the parent folder by executing `cd ..` command.

Let's clone the *environment-jx-rocks-staging* repository that contains the definition of our staging environment.

Please replace `[...]` with your GitHub user in the commands that follow.

```bash
GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-staging.git

cd environment-jx-rocks-staging
```

Let's see what we have in that repository.

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

As you can see, there aren't many files in that repository, so we should be able to explore them all relatively fast. The first one in line is Makefile.

```bash
cat Makefile
```

As you can probably guess by reading the code, the Makefile has targets used to build, install, and delete Helm charts. What is missing are tests. Jenkins X could not know whether we will run tests against applications in the staging environment and, if we are, which tests that will be.

Staging environment is the place where all interconnected applications reside. That's the place where we deploy new releases in a production-like setting. Deployments to the staging environment. We'll see soon where is that information about new releases stored. For now, we'll focus on adding tests that will validate that a new release of any of the applications to the staging environment meets our quality requirements. 

While you can run any type of tests when deploying to the staging environment, I recommend to keep them light. We'll have all sorts of tests specific to applications inside their pipelines. For example, we'll run unit tests, functional tests, and whichever other types of application-specific tests we have. We should assume that the application works on the functional level long before it is deployed to staging. Having that in mind, all that's left to test in staging are cases that can be validated only when the whole system (or a logical and independent part of it) is up and running. Those can be integration, performance, or any other type of system-wide validations.

To run our tests, we need to know the addresses of the applications deployed to staging. Normally, that would be an easy thing since we'd use "real" domains. Our *go-demo-6* application could have a hard-coded domain *go-demo-6.staging.acme.com*. But, that's not our case since we're relying on dynamic domains assembled through a combination of the load balancer IP and [nip.io](http://nip.io/). Fortunatelly, it is fairly easy to find out the address by querying the associated Ingress.

Once we have the address, we can simply invoke `go test` command.

I> I had to pick a language for the tests were are about to write and since we're already using Go for *go-demo-6*, I thought it might make sense to stick with the same language. The tests will be fairly simple and you should be able to understand how they work even if you never coded in Go. You should be able to apply the same logic to whichever language is your choice.

W> The command that follows uses tabs instead of spaces for new lines. Please take that into account if you're typing the commands instead of copying and pasting from the Gist.

```bash
echo 'test:
	ADDRESS=`kubectl -n jx-staging \\
	get ing go-demo-6 \\
	-o jsonpath="{.spec.rules[0].host}"` \\
	go test -v' \
    | tee -a Makefile
```

We echoed the `test` target that contains the command that retrieves the host of the *go-demo-6* application, stores it in the `ADDRESS` variable, and executes `go test` command. The output of the `echo` was appended to `Makefile`.

The fact that we just added a target that we can execute when we want to run our validations will do us no good if we do not have any tests.

I will save you from writing the code, even though it's only around twenty lines. Instead, we'll download one of the Gists I prepared.

```bash
curl -sSLo integration_test.go \
    https://bit.ly/2Do5LRN

cat integration_test.go
```

As you can see, there's not much going on inside the single test. It just sends a request to the *go-demo-6* application and confirms that the response is `200`. Don't judge me for that. This is a demo application and we needed a test to demonstrate how to run them whenever we deploy something to the staging environment. I expect you too write your tests more seriously.

Now that we have a Makefile target that will execute the tests we just downloaded, we should turn our attention to Jenkinsfile and try to add a step that will run the tests. But, before we do that, let's take a quick look at what we have in Jenkinsfile.

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

Jenkinsfile contains two stages, with a single step in each. The `Validate Environment` builds the chart of the staging environment. There is actually no good reason to build the chart so the real objective of that stage is to validate that the syntax used in the chart is correct.

The `Update Environment` stage applies the definition of the environment chart. As a result, whenever that pipeline is executed, it will redeploy everything defined for the staging environment. Soon we'll see the chart in detail. For now, it is important to know that Helm is idempotent. That means that even though we'll always apply the definition of the whole environment, only the parts that changed will result in new deployments or updates.

There are a few things we need to change in that Jenkinsfile.

To begin with, it uses the `jenkins-maven` agent which, as you can guess from the name, is a Pod with a container that contains Maven, Java, and the tools Jenkins needs to run the pipeline (e.g., Helm). We, however, do not need Maven, but Go. So, our first action should be to change the `label` of the `agent` from `jenkins-maven` to `jenkins-go`.

Further on, we can see that the `steps` are executed inside the `maven` container. Since we replaced Maven for Go agent, we should change `container` from `maven` to `go`.

Finally, we should add a step that will execute the tests. We could do that inside one of the two stages we already have, or add a new one. The only important thing to note is that the step that runs the tests must be after the deployment (e.g., `jx step helm apply`). To clarity, we'll create a new stage dedicated to testing. That code could be the one from the snippet that follows.

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

I urge you to apply those three changes (`agent`, `container`, and a new stage) yourself. If you fail, or you're lazy, I already prepared a Gist that we can download with the command that follows.

```bash
curl -sSLo Jenkinsfile \
    https://bit.ly/2Dr1Kfk
```

If did choose to download Jenkinsfile, output it with `cat Jenkinsfile` and explore the changes.

The only thing left to explore the `env` directory.

```bash
ls -1 env
```

As you can see by the names of the files, the `env` directory contains files of a Helm chart. The only file that matters in our case is `requirements.yml`. Normally, the real action in most of the charts is inside the `templates` directory. That's not our case, simply because the main purpose of that chart is not to define details of a specific application. That's done in repositories of those applications. Instead, the purpose of the chart is to tie them all together as Helm dependencies.

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

The first two entries (`expose` and `cleanup`) existed since the begining. Jenkins X created them when we installed it inside our cluster. Both are based on the `exposecontroller` that is used to create Ingress resources automatically whenever we deploy something in the same Namespace.

The last entry (`go-demo-6`) is new. Or, to be more precise, did not exist from the start. It was added through the builds of *go-demo-6* application. We'll explore that flow right after we push the changes to GitHub and confirm that they work correctly.

```bash
git add .

git commit -m "Added tests"

git push
```

All that's wait is to have a bit of patience until the new build triggered by the `environment-jx-rocks-staging` repository is finished. Feel free to use any of the commands that follow to follow the progress and to confirm that the tests were indeed executed.

```bash
jx get activity \
    -f environment-jx-rocks-staging

jx get build logs \
    $GH_USER/environment-jx-rocks-staging/master

jx console
```

If you retrieved the activities or you output the logs of the build, you should see entries generated by the `Test` stage, as long as the build is finished. Similarly, the `console` should provide a graphical representation of the activities of the `environment-jx-rocks-staging` job, including the new stage.

I already mentioned that Helm (just as Kubernetes) is idempotent. Since we did not deploy a new release of any of the application in the staging environment, all the Pods should be intact. After all, the only new thing is the addition of the step that runs the tests. We can confirm that by listing all the Pods in the `jx-staging` Namespace.

```bash
kubectl -n jx-staging get pods
```

If you observe the age of the Pods, you'll notice that they are all older than the execution of the build.

## Which Types Of Tests Should We Execute When Deploying To The Staging Environment

TODO: Continue

## Understanding The Relation Between Application And Environment Pipelines

TODO: Continue

TODO: Diagram

## Exploring And Adapting The Production Environment

---

```bash
cd ..

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-production.git

cd environment-jx-rocks-production

echo 'test:
	ADDRESS=`kubectl -n jx-production \\
	get ing go-demo-6 \\
	-o jsonpath="{.spec.rules[0].host}"` \\
	go test -v' \
    | tee -a Makefile

# NOTE: There is a tab instead of spaces before `go test`

curl -sSLo integration_test.go \
    https://bit.ly/2Do5LRN

curl -sSLo Jenkinsfile \
    https://bit.ly/2BsUQWM

git add .

git commit -m "Added tests"

git push

jx get activity \
    -f environment-jx-rocks-production \
    -w

# It failed because we did not deploy *go-demo-6* to production

# Explain what happens when there are multiple applications

jx create env \
    -n pre-production \
    -l Pre-Production \
    -s jx-pre-production \
    -p Manual \
    -b
```

```
Running in batch mode and no domain flag used so defaulting to team domain 40.117.33.76.nip.io
Using vfarcic environment git owner in batch mode.
Using Git provider GitHub at https://github.com


About to create repository environment-jx-pre-production on server https://github.com with user vfarcic


Creating repository vfarcic/environment-jx-pre-production
Creating Git repository vfarcic/environment-jx-pre-production
Pushed Git repository to https://github.com/vfarcic/environment-jx-pre-production

Creating pre-production Environment in namespace jx
Created environment pre-production
Namespace jx-pre-production created
 Created Jenkins Project: http://jenkins.jx.40.117.33.76.nip.io/job/vfarcic/job/environment-jx-pre-production/

Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!

Creating GitHub webhook for vfarcic/environment-jx-pre-production for url http://jenkins.jx.40.117.33.76.nip.io/github-webhook/
```

```bash
jx get env
```

```
NAME           LABEL          KIND        PROMOTE NAMESPACE         ORDER CLUSTER SOURCE                                                         REF PR
dev            Development    Development Never   jx                0                                                                                
pre-production Pre-Production Permanent   Manual  jx-pre-production 100           https://github.com/vfarcic/environment-jx-pre-production.git       
staging        Staging        Permanent   Auto    jx-staging        100           https://github.com/vfarcic/environment-jx-rocks-staging.git        
production     Production     Permanent   Manual  jx-production     200           https://github.com/vfarcic/environment-jx-rocks-production.git     
```

```bash
jx edit env \
    -n pre-production \
    -p Auto

# NOTE: There is no batch mode

# Answer with enter to all the questions

jx get env
```

```
NAME           LABEL          KIND        PROMOTE NAMESPACE         ORDER CLUSTER SOURCE                                                         REF    PR
dev            Development    Development Never   jx                0                                                                                   
pre-production Pre-Production Permanent   Auto    jx-pre-production 100           https://github.com/vfarcic/environment-jx-pre-production.git   master 
staging        Staging        Permanent   Auto    jx-staging        100           https://github.com/vfarcic/environment-jx-rocks-staging.git           
production     Production     Permanent   Manual  jx-production     200           https://github.com/vfarcic/environment-jx-rocks-production.git        
```

```bash
jx delete env pre-production
```

```
Deleted environment pre-production
To delete the associated namespace pre-production for environment jx-pre-production then please run this command
  kubectl delete namespace jx-pre-production
```

```bash
jx get env
```

```
NAME       LABEL       KIND        PROMOTE NAMESPACE     ORDER CLUSTER SOURCE                                                         REF PR
dev        Development Development Never   jx            0                                                                                
staging    Staging     Permanent   Auto    jx-staging    100           https://github.com/vfarcic/environment-jx-rocks-staging.git        
production Production  Permanent   Manual  jx-production 200           https://github.com/vfarcic/environment-jx-rocks-production.git     
```

```bash
kubectl delete ns jx-pre-production
```

```
namespace "jx-pre-production" deleted
```

```bash
GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-pre-production
```

## Which Types Of Tests Should We Execute When Deploying To The Staging Environment

TODO: Continue

## What Now?


```bash
# New
cd ..

# New
rm -rf environment-jx-rocks-*

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```