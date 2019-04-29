# Going Serverless

We saw that Jenkins X packs a lot of useful tools and processes and that it is very different from the "traditional" Jenkins. However, there is one potentially significant problem that we still need to solve. Jenkins does not scale. If we need more power because the number of concurrent builds increased, we cannot scale Jenkins. We cannot hook it into Kubernetes HorizontalPodAutoscaler that would increase or decrease the number of replicas based on metrics like the number of concurrent builds.

Simply put, Jenkins does not scale. At times, our Jenkins is struggling under heavy load. At others, it is wasting resources when it is underutilized. As a result, we might need to increase its requested memory and CPU as well as its limits to cover the worst-case scenario. As a result, when fewer builds are running in parallel, it is wasting resources, and when more builds are running, it is slow due to insufficient amount of assigned resources. And if it reaches its memory limit, it'll be shut down and rerun (potentially on a different node), thus causing delays or failed builds.

![Figure 11-1: A single static Jenkins](images/ch11/serverless-static.png)

Truth be told, the need to scale Jenkins is smaller than for many other tools, since a significant part of the workload is delegated to agents which, in our case, are running inside disposable one-shot Pods. However, even though most of the tasks are executed inside agents, sooner or later you will reach the limits of what a single Jenkins can do without affecting performance and stability. That is, assuming that your workload is big enough. If you're having only a few projects and a limited number of concurrent builds, a single Jenkins will satisfy most of your needs.

![Figure 11-2: Static Jenkins with on-demand one-shot agent Pods](images/ch11/serverless-static-agents.png)

The only way we can prevent Jenkins from being overloaded is either to increase its memory and CPU or to create new instances. However, creating new instances does not produce the same results as scaling. If we define scaling as an increase (or a decrease) of the number of replicas of a single instance, having multiple replicas means that the load is shared across them. Since that is not possible with Jenkins, we need to increase the number of instances. That means that we cannot have all our pipelines defined in a single Jenkins, but that we can create different instances, each hosting different sets of pipelines.

![Figure 11-3: Workload split into multiple Jenkins instances](images/ch11/serverless-teams.png)

While it's true that we can accomplish resemblance of scaling by spinning multiple Jenkins instances, that does not tackle the problem of high availability. If every Jenkins instance runs only a single replica, what happens when it fails? The good news is that Kubernetes takes care of rerunning failed instances. The bad news is that a failure of a single-replica application inevitably produces downtime. The period from the moment an instance fails until it is recreated by Kubernetes and the processes inside it are fully operational is the period when Jenkins is not available. Whether that is a couple of seconds or a few minutes does not change the fact that it does not always work. No single-replica application can guarantee high-availability in modern terms (e.g., 99.999% availability).

What is the real problem if we do not have Jenkins available all the time? Do we care if every once in a while it stops working for a few minutes? The answer to those questions depends primarily on you. If you are a small company, a few minutes of unavailability that affects only developers (not the end-users) is often not a big deal. But, the real issues are coming from a different direction. What happens when we push code to Git which, in turn, triggers a webhook request? If there is no one to receive that request (e.g., Jenkins is down), no one will even know that a build was not triggered. We could be living in oblivion thinking that everything went fine and that a new release passed all validations and was deployed to staging or even production. When Jenkins fails, all the builds that were running at that time will fail as well. That's not a problem by itself since builds can fail for a variety of other reasons (e.g., a bug that results in a failed test). The issue is that we are notified of failed builds only when Jenkins is running. If it goes down (ungracefully), a build will stop abruptly, and the step that is supposed to notify us will never be executed. Nevertheless, if you are small to medium size company, avoiding those problems might be more expensive than the cost of fixing them, unless the solution is already available out of the box.

![Figure 11-4: Temporary downtime and broken builds due to a failed Jenkins instance](images/ch11/serverless-teams-recovery.png)

What can we do when faced with two options, and none of them are acceptable? We can come up with a third one. If Jenkins cannot scale, and the only way to share the load is by splitting the pipelines across multiple instances, then maybe we can go to the other extreme and dedicate a Jenkins instance to each build. All we'd have to do is create a highly available API that would accept incoming webhooks, and let it spin up a new Jenkins instance for each build. That could not be a generic Jenkins, but a customized one that would contain not only the engine but all the tools that a build needs. It would need to be something similar to a combination of a Jenkins master and a pipeline specific agent.

But that poses a few new challenges. First of all, what should we use as a highly available API? How will it spin up new Jenkins instances that contain pipeline-specific tools? Will it be fast enough? Is Jenkins designed to work like that, or should we use something else? The answer to those questions requires a more in-depth analysis. For now, what matters is that Jenkins X solved those problems. There is now a highly available API that accepts webhook requests. There is a mechanism that will translate your pipelines into a set of tasks that are created and run on-demand, and destroyed when finished.

If we spin up pipeline-runners on demand and we destroy them when builds are finished, we can say that we'd get a serverless solution. Each request from a webhook would result in one or more new processes that would run all the steps defined in a pipeline. As long as the API that accepts webhook requests is highly available and knows how to spin up and destroy processes required for each pipeline build, we should have a highly-available and fault-tolerant solution that uses only the resources it needs.

I> I really dislike the word "serverless" because it is misleading. It makes you believe that there are no servers involved. It should rather be called servers-not-managed-by-us. Nevertheless, I will continue using the word serverless to describe processes that are spin-up on demand and destroyed when not used anymore, simply because that is the most commonly used name today.

Jenkins X  in serverless mode uses [Prow](https://github.com/kubernetes/test-infra/tree/master/prow) as highly available API that receives webhook requests. Jenkins is replaced with Jenkins X Pipeline Operator and [Tekton](https://cloud.google.com/tekton/). It translates the events coming to Prow into Tekton pipelines. Given that Tekton is very low-level and its pipelines are hard to define, Pipeline operator translates Jenkins pipelines into Tekton Pipelines which, in turn, spin up Tekton Tasks, one for each step of the pipeline. Those pipelines are defined in jenkins-x.yml.

![Figure 11-5: Serverless flavor of Jenkins X](images/ch11/serverless.png)

One of the things you'll notice is that there is no Jenkins in that diagram. It's gone or, to be more precise, replaced with other components, more suitable for today's challenges. But, introducing entirely new components poses a new set of challenges, especially for those already experienced with Jenkins.

Learning that new components like Prow, Pipeline Operator, and Tekton might make you feel uncomfortable unless you already used them. If that's the case, you can rest at ease. Jenkins X makes their usage transparent. You can go deep into their inner workings, or just ignore their existence since Jenkins X does all the heavy lifting and integration between them.

What matters is that serverless Jenkins X is here and it brings a whole new set of opportunities and advantages compared to other solutions. It is the first continuous delivery solution designed specifically for Kubernetes. It is cloud-native and based on serverless principles, and it is fault-tolerant and highly-available. It scales to meet any demand, and it does not waste resources. And all that is done in a way transparent to the user and without the need to spend eternity trying to figure out how to assemble all the pieces of a very complex machine.

In this chapter, we will explore how to increase the number of Jenkins instances, as well as how to transition into a serverless solution. By understanding both options (multi-instance Jenkins, and serverless on-demand pipelines), you should be able to make a decision which direction to take.

First things first. We need a cluster with Jenkins X up-and-running, just as we had it in all the previous chapters.

## Creating A Kubernetes Cluster With Jenkins X

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [11-serverless.sh](https://gist.github.com/855b8d70f3fa49b42d930144ed1606f1) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

We will not need *go-demo-6* so you can skip importing it.

Now we can explore how to scale Jenkins.

## Scaling Jenkins Through Teams

If you need to scale Jenkins, and knowing that it cannot scale "properly" by increasing the number of replicas, the only option left is to increase the number of instances. There are two ways we can do that. We can execute yet another `jx install` command. In such a case, as a minimum, we would need to specify a different Namespace through the `--namespace` argument. The major problem with that approach is that we would get a separate copy of everything, including ChartMuseum, Nexus, Docker Registry, and other tools used for storing artifacts. The alternative is to use `jx create team` command that creates a new instance of Jenkins while reusing registries from the first team. That is a much better option, but we are not going to explore it.

If you want to scale Jenkins and you have a good reason not to adopt the serverless, feel free to "play" with `jx create team` and related commands. However, I believe that is the dead-end. First of all, creating separate Jenkins instances is not a good solution to the problem. We need to be able to scale it when we need more and downscale it when we don't. We need our solution to be highly available. Jenkins is not designed to do those things. It is a much better solution to go down the serverless route.

So, if you have a good reason not to explore the serverless option, I urge you to create a team, but without my help. Still, before you go down that road, I recommend you suppress that urge for a while and see the benefits serverless solution brings to the table. There are many other advantages we did not yet discuss.

In this and the next few chapters, we'll explore what serverless gives us, and if you still feel that it does not fit your needs, you should indeed go down the route of having multiple Jenkins teams.

## Installing Serverless Jenkins X Inside An Existing Cluster {#serverless-existing}

What you've seen so far is Jenkins X first generation, and now we're moving into the second.

W> At the time of this writing, serverless Jenkins X works only with GitHub repository. At least, that is the status in April 2019. The community is working on extending the support for other Git providers, and I will update the book as soon as that happens.

I> For practice purposes, GitHub should not be an issue since all the examples we used so far were using GitHub.

We are about to install serverless Jenkins X inside an existing cluster. It will run in parallel with the static Jenkins we created earlier. That way we can see not only how serverless works, but also demonstrate that both can be combined inside the same cluster. At the same time, you can think of the exercise that follows as a way to refresh your knowledge how to install any Jenkins X flavor inside an existing cluster (unless that's what you've been doing all along).

I> If your Kubernetes does not use Cluster Autoscaler, you might experience problems due to insufficient capacity. If that happens, please increase the number of nodes.

Before we execute the actual installation of serverless Jenkins X, we'll need to retrieve some information about our cluster. Namely, we'll need the IP of the external load balancer through which we're accessing the cluster, a domain, the Namespace where Ingress resides, as well as the name of the Ingress Deployment.

What should be the values of those variables depends on your Kuberentes cluster and how you installed Jenkins X. If you created the cluster using one of the Gists (`gke-jx.sh`, `eks-jx.sh`, or `aks-jx.sh`), the commands that will define most of the variables we need are as follows. If, on the other hand, you installed Jenkins X using `install.sh` Gist, you should already have those variables defined, and you can skip executing the commands that follow. Finally, if you created the cluster and installed Jenkins X in any other way, you'll have to rewrite the commands so that they assign the correct values. The comments above the commands provide a description of each variable.

```bash
# External IP
LB_IP=$(kubectl -n kube-system \
  get svc jxing-nginx-ingress-controller \
  -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

# The domain through which 
# we can access the applications
DOMAIN=serverless.$LB_IP.nip.io

# The Namespace where Ingress is running
INGRESS_NS=kube-system

# The name of the NGINX Ingress Deployment
INGRESS_DEP=jxing-nginx-ingress-controller
```

The last variable we'll need is the provider.

W> Please replace `[...]` with the name of your Kubernetes provider (e.g., `gke`, `eks`, `aks`, etc.). You can execute `jx install --help | grep "provider="` to retrieve the list of the providers if you're unsure which one to set. Use `kubernetes` as the provider if none from the list match yours.

```bash
PROVIDER=[...]
```

At the time of this writing (April 2019), serverless Jenkins X has problems with container registry services like ECR and Azure Container Registry. Since it works correctly with Docker Registry running inside a cluster, we'll force it by adding `docker-registry` entry in `myvalues.yaml`.

```bash
echo "nexus:
  enabled: false
docker-registry:
  enabled: true
" | tee myvalues.yaml
```

Now we can install the serverless flavor of Jenkins X.

```bash
jx install \
    --provider $PROVIDER \
    --external-ip $LB_IP \
    --domain $DOMAIN \
    --default-admin-password=admin \
    --ingress-namespace $INGRESS_NS \
    --ingress-deployment $INGRESS_DEP \
    --default-environment-prefix tekton \
    --git-provider-kind github \
    --namespace cd \
    --prow \
    --tekton \
    -b
```

Most of the arguments we're using are the same as with the static version. The difference is that this time the environment prefix is `tekton` and we'll install the platform inside the `cd` Namespace. That way, our serverless installation will be separated from the static one running in the `jx` Namespace.

The "magic" is accomplished through the arguments `--prow` and `--tekton`. The former (`prow`) will be the receptor of the webhooks, and it provides ChatOps capabilities we'll explore later. The latter (`tekton`) is the mechanism that allows us to have serverless builds.

If we look at the logs, there are a few differences when compared with what we experienced before.

We can see that it installed [Knative](https://cloud.google.com/knative/) which provides serverless capabilities in Kubernetes clusters.

Further on, we can see that [Tekton](https://cloud.google.com/tekton/) is installed as well. Just like Jenkins X, it is a member of the [Continuous Delivery Foundation](https://cd.foundation/) and can be described as *Kubernetes-native open-source framework for creating continuous integration and delivery (CI/CD) systems*. It is not meant to be the end-user solution. It is too low-level for most of us. Instead, Tekton is a building block, and you'll see later how Jenkins X assembles it as part of the solution.

Further on, we got yet another new tool called [Prow](https://github.com/kubernetes/test-infra/tree/master/prow). We'll use it as the receptor of Git webhooks, as well as for Git-related automation, policy enforcement, ChatOps, and a few other features. It deserves a chapter on its own, so we'll explore it in more detail later.

After a while, the platform should be up and running, and we can start using it through the already familiar `jx` commands. But, how do we switch from one to another? How do we make sure that we are issuing commands to a specific platform? We can use the concept of *teams* for that.

## Exploring Jenkins X Teams

Every Jenkins X installation becomes a team referencing the idea that each team in a company could have its own Jenkins X, no matter whether it is in the same or a different cluster. If we create a new cluster through the `jx create cluster` commands, it creates a team. Throughout the chapters we explored so far, we always had a team called `jx` (the default name of a team).

We can create new teams by executing the `jx create team` command. If we do that, we'll get another set of Namespaces (e.g., `dev`, `staging`, `production`) dedicated to the new team we want to onboard. As stated earlier, we will not go through exercises of creating teams in that way. The process is simple, and I'm sure that you can figure it out yourself.

The third way to create a team is through the process we just executed. Every time we run `jx install`, we are creating yet another team.

While the first team we created (`jx`) is based on static Jenkins, the one we created a few minutes ago is serverless.

Let's take a look at the teams we're having right now.

```bash
jx get teams
```

The output is as follows.

```
NAME
cd
jx
```

We can see that there are currently two teams, corresponding to Namespaces of the two Jenkins X installations.

We can switch from one team to another through the `jx team` command.

```bash
jx team jx
```

We can see from the output that we are `now using team 'jx'`. Each `jx` CLI command we execute from now on would work against the `jx` team that uses static Jenkins. Similarly, if we'd like to switch to the `cd` team (Jenkins X running in the `cd` Namespace), all we have to do is execute the command that follows.

```bash
jx team cd
```

The question you might be asking is whether we need teams at all. If you are a small company with only a few development teams, a single Jenkins X should fit all your needs. However, if you are bigger, you might indeed benefit from having multiple platforms. One can be dedicated to each team in your company, or you might group them into logical entities. The reason for separation into teams is performance and security. There is a limit to how much a single Jenkins instance can do. If we keep adding pipelines, sooner or later it will reach a threshold beyond which Jenkins becomes too slow and unstable. Creating new instances (teams) helps with that problem. But, as you are about to find out, the serverless flavor of Jenkins X can scale. The only limit is in the amount of computing resources we have in the cluster. New processes will be created for each build and destroyed when they are finished. There will be no static Jenkins. Almost everything is dynamic and serverless. That is the reason why we are not dedicating time to explore teams. They are mostly used with static Jenkins.

The second, and often more critical reason for having teams is security-related separation. We might want to separate one team from another into Namespaces or even separate clusters. Or, we might want to run staging and development environments in one cluster, and production in another. That is indeed a subject that would benefit from a chapter on its own, so we'll treat it as such. We'll explore separation in more detail later.

For now, we have two Jenkins X installations. One is serverless, and the other is static. Each is running in its own Namespaces, has separate environment repositories, and can be distinguished as teams.

In a "real" life situation, you might end up with some jobs running in static while others in serverless Jenkins X flavor. Or, you might have all your jobs in static, and you want to move to serverless gradually. In those cases, running two separate instances (teams) is a must.

Now that we have a serverless platform up-and-running, we can explore whether there are any differences when we create a new quickstart project.

## Creating New Quickstart Project With Serverless Jenkins X

Instead of talking about the advantages Serverless Jenkins X provides, we'll explore them through practical examples. We'll start with a new quickstart project, just as we did at the very beginning with static Jenkins.

We'll create a Go-based project called *jx-serverless*.

W> Make sure that you are not inside an existing repository before executing the command that follows.

```bash
jx create quickstart \
  -l go \
  -p jx-serverless \
  -b
```

Judging from the output, there are no differences between creating a quickstart project with static and serverless Jenkins X. So, let's take a look at the files that were created for us.

```bash
cd jx-serverless

ls -l
```

If you take a closer look at the files, you'll notice that there is no Jenkinsfile. Instead, we got `jenkins-x.yaml`. Is that just a different name for the same thing? Let's take a look.

```bash
cat jenkins-x.yml
```

The output is a single line `buildPack: go`. Now that is much shorter than what we observed before with Jenkinsfile. The definition of our pipeline is now hidden from us. It inherits the pipeline from the buildpack `go`. That dramatically simplifies the work we need to do, at the expense of control. We do not need to deal with the entire pipeline anymore, but we also do not have direct visibility into its definition. If we'd want to see the details of the pipeline, we'd need to explore `pipeline.yaml` in the buildpack repository.

Our buildpacks (or those from the community) should provide most of the standard configurations and code through the assumption that projects based on the same language and frameworks should use the same tools and the same pipeline. That's why project pipelines now extend those fro buildpacks, instead of creating a copy in a similar way static Jenkins creates Jenkinsfile with the full definition of a pipeline.

Single-line pipeline defined in `jenkins-x.yml` is shorter than its Jenkinsfile equivalent, but there will be almost certain need to customize it. We might need to add unit tests, functional tests, and other types of validations that are not included in the buildpack. While we could certainly do that in a custom buildpack and let `jenkins-x.yml` inherit it, sooner or later we will be faced with the need to add a step that is specific to a project and, therefore, not a good candidate for the buildpack. Consequently, we will need to figure out how to extend pipelines based on buildpacks, or to write a completely new pipeline from scratch. We'll explore both of those options in one of the subsequent chapters. For now, remember that `jenkins-x.yml` contains a reference to the pipeline in a specific buildpack and that it can be extended with custom steps or even rewritten from scratch.

There is a lot to be said about the new format for Jenkins X pipelines. While Jenkinsfile-based pipelines used a lot of steps that did not exist before Jenkins X, the format itself is still the same old Jenkinsfile. `jenkins-x.yml` is an entirely new format for defining pipelines.

While it might be tempting to jump straight into the new pipeline format, we'll postpone that since our current goal is to explore serverless Jenkins X on a very high level. We'll go deeper soon. For now, please note that the new pipeline contains the same steps, even though the mechanism that executes them is quite different.

Now that we discovered the first change introduced through serverless Jenkins X, let's see whether we can spot a difference by observing the activities.

```bash
jx get activities \
    --filter jx-serverless \
    --watch
```

The output is the same as with static Jenkins X, so there's nothing new there.

Please cancel the activity watcher by pressing *ctrl+c*.

```bash
kubectl -n cd get pods
```

The output is as follows.

```
NAME                                  READY STATUS    RESTARTS AGE
crier-...                             1/1   Running   0        12m
deck-...                              1/1   Running   0        12m
deck-...                              1/1   Running   0        12m
hook-...                              1/1   Running   0        12m
hook-...                              1/1   Running   0        12m
horologium-...                        1/1   Running   0        12m
jenkins-x-chartmuseum-...             1/1   Running   0        12m
jenkins-x-controllerbuild-...         1/1   Running   0        11m
jenkins-x-controllercommitstatus-...  1/1   Running   0        11m
jenkins-x-controllerrole-...          1/1   Running   0        11m
jenkins-x-controllerteam-...          1/1   Running   0        11m
jenkins-x-controllerworkflow-...      1/1   Running   0        11m
jenkins-x-docker-registry-...         1/1   Running   0        11m
jenkins-x-heapster-...                2/2   Running   0        11m
jenkins-x-mongodb-...                 1/1   Running   1        11m
jenkins-x-monocular-api-...           1/1   Running   2        11m
jenkins-x-monocular-prerender-...     1/1   Running   0        11m
jenkins-x-monocular-ui-...            1/1   Running   0        11m
pipeline-...                          1/1   Running   0        12m
pipelinerunner-...                    1/1   Running   0        12m
plank-...                             1/1   Running   0        12m
prow-build-...                        1/1   Running   0        12m
sinker-...                            1/1   Running   0        12m
tekton-pipelines-controller-...       1/1   Running   0        14m
tekton-pipelines-webhook-...          1/1   Running   0        14m
tide-...                              1/1   Running   0        12m
vfarcic-environment-tekton-stag-1-... 0/1   Completed 0        6m
vfarcic-environment-tekton-stag-2-... 0/1   Completed 0        5m
vfarcic-jx-serverless-master-1-...    0/1   Completed 0        8m
```

There are quite a few tools that we haven't seen before.

Those starting with `jenkins-x` are still the same. We still have ChartMuseum for storing Helm charts, Docker Registry for storing container images (unless you're using a service for that), Monocular as Helm registry UI, and so on. But what about `crier`, `deck`, `hook`, `pipeline`, `pipeline-runner`, `plank`, `prow`, `sinker`, `tekton`, and `tide`? What are they and why do we have them? What about the `completed` Pods with names that match the pipelines we have in the system? And not only that we got a bunch of new tools, but one is missing. Jenkins is nowhere to be found. What happened to it?

I will keep you in suspense for now with the promise that I will answer those and many other questions soon. For now, we'll focus on exploring whether there are other functional differences between static and serverless Jenkins X. For example, can we still retrieve the pipelines?

```bash
jx get pipelines
```

The output is as follows.

```
Name                                         URL LAST_BUILD STATUS DURATION
jenkins-x/dummy/master                       N/A N/A        N/A    N/A
vfarcic/environment-tekton-production/master N/A N/A        N/A    N/A
vfarcic/environment-tekton-staging/master    N/A N/A        N/A    N/A
vfarcic/jx-serverless/master                 N/A N/A        N/A    N/A
```

We can see that we can still retrieve the names of the pipelines, but not the additional information. One noticeable difference is that there is no URL of the pipelines. Does that mean that there is no UI? Well, the answer is both yes and no. There is no "traditional" Jenkins anymore, so the URL that would normally open a Jenkins UI screen with a pipeline is no more. If you don't believe me, we can make a quick test by trying to open the Jenkins console.

```bash
jx console
```

The output states that `no Jenkins App services` were `found`. But not everything is lost. The fact that there is no static Jenkins and therefore there is no Jenkins UI does not mean that Jenkins X does not have a UI. There is one, and it is entirely new. It was designed and written from scratch to work with serverless Jenkins X. But, just as with the few other explorations we're postponing for the subsequent chapters, the new UI will be explained later.

Now, let's take a look whether logs are still available.

```bash
jx get build logs
```

You will be presented with a choice between logs of the builds we run so far. Please choose `jx-serverless`.

As you can see, the logs are available, but they are not in the same format as before. While with static Jenkins the logs were in plain text, now they are in JSON format. While that might be harder to read on the screen, it is a better format considering that we should centralize logging by shipping log entries to a database like ElasticSearch or a service like CloudWatch (AWS), Stackdriver (GCP), Azure Log Analytics, or [Papertrail](https://papertrailapp.com/). When logs are in JSON format, there is no need to write parsers that will split them into separate fields. Unfortunately, only the part of the logs is in JSON making the logs confusing at times. Hopefully, a more unified logging output will arrive soon.

As you can see, from the `jx` CLI perspective, almost everything is the same no matter whether we are using static or serverless Jenkins X. The significant differences are in the way it works in the background and in non-functional benefits like resource consumption and scaling.

There is a lot to be said about the new format for Jenkins pipelines, and we will explore them in more detail soon. For now, we'll focus on the architecture of the new solution. We'll explore the new components added when we installed serverless Jenkins X.

## Exploring Prow, Jenkins X Pipeline Operator, And Tekton

The serverless flavor of Jenkins X or, as some call it, Jenkins X Next Generation, is an attempt to redefine how we do continuous delivery and GitOps inside Kubernetes clusters. It does that by combining quite a few tools into a single easy-to-use bundle. As a result, most people will not have a need to understand intricacies of how the pieces work independently, nor how they are all integrated. Instead, many will merely push a change to Git and let the system do the rest. But, there are always those who would like to know what's happening behind the hood. To satisfy those craving for insight, we'll explore the processes and the components involved in the serverless Jenkins X platform. Understanding the flow of an event initiated by a Git webhook will give us insight into how the solution works and help us later on when we go deeper into each of the new components.

I> The description that follows might be too much for some people. I will not think less of you if you choose to skip it and enjoy using serverless Jenkins X without knowing its inner workings. After all, the main objective of Jenkins X is to abstract the details and let people practice continuous delivery without spending months trying to learn the intricacies of complex systems like Kubernetes and Jenkins X.

Just as with static Jenkins, everything starts with a push to a Git repository which, in turn, sends a webhook request to the cluster. Where things differ is that there is no Jenkins to accept those requests. Instead, we have [Prow](https://github.com/kubernetes/test-infra/tree/master/prow). It does quite a few things but, in the context of webhooks, its job is to receive requests and decide what to do next. Those requests are not limited only to push events, but also include slash commands (e.g., `/approve`) we can specify through pull request comments.

Prow consists of a few distinct components (e.g., Deck, Hook, Crier, Tide, and a few more). However, we won't go into the roles of each of them just yet. For now, the vital thing to note is that Prow is the entry point to the cluster. It receives Git requests generated either by Git actions (e.g., `push`) or through slash commands in comments.

![Figure 11-6: The role of Prow in serverless Jenkins X](images/ch11/serverless-flow-prow.png)

Prow might do quite a few things upon receiving a request. If it comes from a command from a Git comment, it might re-run tests, merge a pull request, assign a person, or one of the many other Git related actions. If a webhook informs it that a new push was made, it will send a request to the Jenkins X Pipeline Operator which will make sure that a build corresponding to a defined pipeline is run. Finally, Prow also reports the status of a build back to Git.

Those features are not the only types of actions Prow might perform but, for now, you probably got the general Gist. Prow is in charge of communication between Git and the processes inside our cluster.

![Figure 11-7: The relations between Git, Prow, and Pipeline Operator](images/ch11/serverless-flow-pipeline-operator.png)

When a Prow Hook receives a request from a Git webhook, it forwards it to Jenkins X Pipeline Operator. The role of the operator is to fetch jenkins-x.yml file from the repository that initiated the process and to transform it into Tekton Tasks and Pipelines. They, in turn, define the complete pipeline that should be executed as a result of pushing a change to Git.

The reason for the existence of the Pipeline Operator is to simplify definitions of our continuous delivery processes. Tekton does the heavy lifting, but it is a very low-level solution. It is not meant to be used directly. Writing Tekton definitions can be quite painful and complicated. Pipeline Operator simplifies that through easy to learn and use YAML format for defining pipelines.

![Figure 11-8: The relations between Git, Prow, and Pipeline Operator](images/ch11/serverless-flow-tekton.png)

Tekton creates a PipelineRun for each build initiated by each push to one of the associated branches (e.g., `master` branch, PRs, etc.). It performs all the steps we need to validate a push. It runs tests, stores binaries in registries (e.g., Docker Registry, Nexus, and ChartMuseum), and it deploys a release to a temporary (PR) or a permanent (staging or production) environment.

The complete flow can be seen in the diagram 11-9.

![Figure 11-9: The complete flow of events in serverless Jenkins X](images/ch11/serverless-flow.png)

I> You might notice the same diagram in [jenkins-x.io](https://jenkins-x.io/architecture/diagram/). The community thought that it is useful, so I contributed it.

As I already mentioned, not everyone needs to understand the flow of events nor to have a deep understanding of all the components involved in the process. For most users, the only important thing to understand is that pushing changes to Git will result in the execution of the builds defined in jenkins-x.yml pipeline. That's the beauty of Jenkins X. It simplifies our lives by making complicated processes simple.

If, on the other hand, you are interested in details, we will cover each of the components in more details in the next chapters.

## To Serverless Or Not To Serverless?

Should we switch to the serverless model or stick with the static flavor we've been exploring in the previous chapters? The answer to that question is not as straightforward as it might seem. On the one hand, the serverless flavor is the present and the future. That's the model Jenkins X will be pushing, and that's the one that will receive most contributions. Judging by the previous sentence, you might conclude that it is an easy decision after all. Why would we use something old (static), when we can choose the new (serverless)? The reason why you might want to stick with the static version (for now) lies in the red lines.

Today (April 2019), serverless Jenkins X supports only GitHub. So, if you are not using GitHub (e.g., if, for example, you prefer GitLab), you are forced to wait with the adoption. The good news is that the team is working hard on making serverless Jenkins X work with all the popular Git providers. With that in mind, even if you cannot adopt it just yet, it might be a good idea to start learning it right away. If that's what you're planning to do, you'll be glad to know that the next few chapters are dedicated to serverless Jenkins X. After we master it, we'll explore the subjects that work in both flavors, and I'll make sure to stress any differences you might experience.

Nevertheless, do not make the decision just yet. There are many benefits of serverless that we did not even mention. My job is to show you both solutions with their pros and cons. It's up to you to choose which one works better for you and your team.

## What Now?

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you chose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> This time we have more repositories to remove, so the instructions that follow are different than those you used in the previous chapters.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

hub delete -y \
  $GH_USER/environment-tekton-staging

hub delete -y \
  $GH_USER/environment-tekton-production

hub delete -y $GH_USER/jx-serverless

rm -rf jx-serverless

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*
```