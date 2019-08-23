## TODO

- [X] Code
- [ ] Write
- [X] Code review static GKE
- [X] Code review serverless GKE
- [ ] Code review static EKS
- [X] Code review serverless EKS
- [X] Code review static AKS
- [X] Code review serverless AKS
- [-] Code review existing static cluster
- [-] Code review existing serverless cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Choosing The Right Deployment Strategy

W> The examples in this chapter work with any Jenkins X flavor (static or serverless) and with any hosting vendor (e.g., AWS, AKS, GKE, on-prem, etc.).

So far, we performed many deployments of our releases. All those created from master branches were deployed to the staging environment and a few reached production through manual promotions. Nevertheless, with exception of serverless deployments with Knative, we did not have a say in how an application is deployed. We just assumed that the default method employed by Jenkins X is the correct one. As it happens, the default deployment process used by Jenkins X happens to be the default or, to be more precise, the most commonly used deployment process in Kubernetes. However, that does not necessarily mean that the default deployment is the right deployment for all your applications.

For many people, deploying applications is transparent or even irrelevant. If you are a developer, you might be focused on writing code and allowing magic to happen. By magic, I mean letting other people and departments figuring out how to deploy your code. Similarly, you might be oblivious to deployments if you are a tester or you have some other role not directly related to system administration, operations, or infrastructure. Now, I doubt that you are one of the oblivious. The chances are that you would not be even reading this if that's the case. If, against all chances, you do belong to the deployment-is-not-my-thing group, the only thing I can say is that you are terribly wrong.

Generally speaking, there are two types of teams. Wast majority is still working in teams based on types of tasks and parts of application lifecycles. If you're wondering whether that's the type of the team you work in, ask youself whether you are in a development, testing, operations, or some other department focused on a fraction of a lifecycle of an application. Are you handing your work to someone else? When you finish writing code, do you give it to the testing department to validate it? When you need to test a live application, are you giving it to operations to deploy it to an environment? Or, to formulate the question on a higher level, are you (your team) in charge only of a part of the lifecycle of your application? If the answer to any of those question is "yes", you are NOT working in a self-sufficient team. Now, I'm not going to tell you why that is wrong nor I'm here to judge you. Instead, I'm only going to state that there is a high probability that you do not know in detail how your application is deployed. As a result, you don't know how to architecture it properly, you don't know how to test it well, and so on and so forth. That, ofcourse, is not true if you are dedicated only on operations. But, in that case, you might not be aware of the architecture of the application. You might know how the application is deployed but you might not know whether that is the optimum way to go.

On the other hand, you might be indeed working in a self-sufficient team that is fully responsible for each aspect of application's lifecycle, from requirements all the way until it is running in production. If that's the case, your definition of done is likely defined as "it's running in production and nothing exploded." Being in a self-sufficient team has a distinct advantage of everyone being aware of every aspect of application's lifecycle. You know the architecture, you know the code, you understand the tests, and you are aware how it is deployed. That is not to say that you are an expert in all those and other areas. No one can know everything in depth, you everyone can have enough high-level knowledge of everything, while being specialized in something.

Why am I rumbling about team organizations? The answer is simple. Deployment strategies affect everyone, no matter whether we are focused only on a single aspect of application's lifecycle or we are in full control. The way we deploy affects the architecture, testing, monitoring, and many other aspects. And not only that, but we can say that architecture, testing, and monitoring affect the way we deploy. All those things are closely related and affect each others in way that might not be obvious on the first look.

We already learned many of the things Jenkins X does out-of-the-box and quite a few others that could be useful to customize it to behave as we want. But, so far, we mostly ignored deployment strategies. If we exclude our brief exploration of serverless deployments with Knative, we always assumed that the application will be deployed using whichever strategy was defined in a build pack. Not only that, but we did not even question whether the type of the resource defined in our Helm charts are the right ones. We'll fill that hole next.

The time has come to discuss different deployment strategies and answer a couple of questions. Is your application stateful or stateless? Does its architecture permit scaling? How do your roll back? How do you scale up and down? Do you need our application to run constantly? Should you use Kubernetes Deployments instead of, let's say, StatefulSets? Those are only a few of the questions you need to answer in order to choose the right deployment mechanism. But, answers to those questions will not serve much purpose unless we are familiar with some of the most commonly used deployment strategies. Not only that knowledge will help us choose which one to pick, but they might even influence the architecture of our applications.

## What Do We Expect From Deployments?

Before we dive into some of the deployment strategies, we might want to set some expectations that will guide us through our choices. But, before we do that, let's try to define what a deployment is.

Traditionally, a deployment is a process through which we would install new applications into our servers or update those that are already running with new releases. That was, more or less, what we were doing from the begining of the history of our industry, and that is in its essence what we're doing today. But, as we evolved our requirements were evolving as well. Today, say that all we expect is for our releases to run is an understatement. Today we want so much more and we have technology that can help us fulfil those desired. So, what does "much more" mean today?

Depending on who you speak with, you will get a different list of "desires", so mine might not be all encompasing and include every single thing than anyone might need. What follows is what I believe is important and what I observed that the companies I worked typically put emphasis. Without further ado, the requirements, excluding the obvious that applications should be running inside the cluster, are as follows.

Applications should be fault tolerant. If an instance of the application dies, it should be brought back up. If a node where an application is running dies, the application should be moved to a healthy node. Even if a whole datacenter goes down, the system should be able to move the applications that were running there into a healthy one. An alternative would be to recreate the failed nodes or even whole datacenters with exactly the same applications that were running there before the outage. However, that is too slow and, frankly speaking, we moved away from that concept the moment we adopted schedulers. That does not mean that failed nodes and failed datacenters should not recuperate, but rather that we should not wait for everything to get back to normal. Instead, we should run failed applications (no matter the cause) on healthy nodes as long as there is enough available capacity.

Fault tolerance might be the most important requirement of all. If our application is not running, our users cannot use it, and that results in dissatisfaction, loss of profit, churn, and quite a few other negative outcomes. Still, we will not use fault tolerance as a criteria because everything we do is now in Kuberentes which makes (almost) everything fault tolerant. As long as it has enough available capacity, our applications will run. So, even that is an important requirement, it is off the table because we are fulfiling it no matter the deployment strategy we choose. That is not to say that there is no change for an application not to recuperate from a failure but rather that Kubernetes provides a reasonable guarantee of fault tolerance. If things do go terribly wrong we are likely going to have to do some manual actions no matter which deployment strategy we choose.

The next in line is high availability, and that a trickier one.

Being fault tolerant means that the system will recuperate from a failure, not that there will be no downtime. If our application goes down, a few moments later it will be up-and-running again. Still, those few moments can result in downtime. Depending on many factors, "few moments" can be translated to miliseconds, seconds, minutes, hours, or even days. While it is certainly not the same whether our application is unavailable during miliseconds as apposed to hours, for the sake of brevity, we'll assume that any downtime is bad and look at things as black and white. Either there is or there isn't downtime. Or, to be more precise, either there is a considerable downtime or there isn't. What changed is what "considerable" means. In the past, having 99% availability was a worthy goal for many. Today, that figure is unaceptable. Today we are taking about how many nines there are after the decimal. For some, 99.99% uptime is aceptable. For others, that could be 99.99999%.

Now, you might say "my business is important, therefore I want 100% uptime." If anyone says that to you, feel free to respond with "you have no idea what you're talking about". A hundred percent uptime is impossible, assuming that by that we mean "real" uptime, and not "my application runs all the time".

Making sure that our application is always running is not that hard. Making sure that not a single request is ever lost or, in other words, our users perceive our application as being always available, is impossible. By the nature of HTTP, some requests will fail. Even if that never happens (as it will), network might go down, storage might fail, or some other thing might happen that will produce at least one request without response.

All in all, high-availability means that our applications are responsive to our users most of the time, and by most we mean at least 99.99%. Even that is a very pesimistic number that would result in 1 failure for ten thousand successes.

What are common causes of unavailability? We already discussed those that tend to be the first associations (hardware and softwar failures). However, those are often not the primary causes of unavaibility. You might have missed something in your tests and that might cause a failure. More often than not, those are not failures caused by "obvious" bugs but rather those that manifest itself a while after a new release is deployed. I will not tell you that you should make sure that there are no bugs (that's impossible), but rather focus on detecting those that sneak into production and how to minimize their affect to as few users as possible. So, our next requirement will be that our deployments should reduce the number of users affected by bugs. We'll call it progressive rollout. Don't worry if you never heard that term. We'll explain it in more depth later.

Progressive rollout, as you'll see later, does allow us to abort upgrades or, to be more precise, not to proceed with them, if something goes wrong. But that might not be enough. We might need not only to abort deployment of a new release, but also to roll back what the one we had before. So, we'll add rollback as yet another requirement.

We'll probably find more requirements directly or indirectly related to high-available or, to inverse it, to unavailability. For now, we'll leave those aside, and move to yet another important aspect. We should strive to make our applications responsive. Now, there are many ways to accomplish that. We can design our applications in a certain way, we can avoid congestions and memory leaks, and we can do many other things. However, right now that's not the focus. We're interested in things that are directly or indirectly related to deployments. With such a limited scope, scalability is the key to responsiveness. If we need more replicas of our application, it should scale up. Similarly, if we do not need as many, it should scale down and free the resources for some other processes if cost savings are not a good enough reason.

Finally, we'll add one more requirement. It would be nice if our applications do not use more resources than it is necessary. We can say that scalability provides that (it can scale up and down) but we might want to take it a step further and say that our applications should not use (almost) any resources when they are not in use. We'll call that "nothing when idle" or, to use a more commonly used term, serverless. I'll use this as yet another opportunity to express my discust with that term given that it implies that there are no servers involved. But, since it is a commonly used one, we'll stick with it. After all, it's still better than call it function-as-a-service since that is just as missleading as serverless, and it occupies more characters (it is a longer word). However, serverless is not the real goal. What really matters is that our solution is cost effective, so that will be our last requirement.

Are those all the requirements we care about. They certainly aren't. Yet, this text cannot contain infinite number of words and we need to focus on something. Those, in my experience, are the most important ones, so we'll stick with them, at least for now.

Another thing we might need to note is that those requirements or, to be more precise, features are all interconnected. More often than note, one cannot be accomplished without the other or, in some other cases, one facilitates the other and makes it easier to accomplish.

Another thing worth noting is that we'll focus only on automation. For example, I know perfectly well that anything can be rolled back through a human intervention. As a matter of fact, anything can be done with enough time and man power. But that's not what matters in this discussion. We'll ignore humans and focus only on the things that can be automated. I don't want you to scale your applications. I want the system to do it for you. I don't want you to roll back in case of a failure, I want the system to do that for you. I don't want you to waste your brain capacity on such trivial tasks. I want to you spend your time on things that matter and leave the rest to machines.

After all that, we can summarize our requirements or features by saying that we'd like deployments to result in applications that are running and are:

* fault tolerant
* highly available
* responsive
* rolling out progressivelly
* rolling back in case of a failure
* cost effective

We'll remove *fault tolerance* from the future discussions since Kubernetes providees that out-of-the-box. It's yet to be seen whether we'll accomplish the rest and, if we do, how we'll do that.

Given that there is a strong chance that there is no solution that will provide all those features. Even if we do find such a solution, the chances are that it might not be appropriate for your applications and their architecture. Instead, we'll explore some of the commonly used deployment strategies and see which of those requirements they fullfil.

Just as in any other chapter, we'll explore the subject in more depth through practical examples. For that, we need a working Jenkins X cluster as well as the *go-demo-6* application since we'll use it to demonstrate different deployment strategies.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

If you kept the cluster from the previous chapter, you can skip this section only if you were doubting my choice of VM sizes and make the nodes bigger than what I suggested. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [TODO: Viktor](TODO: Viktor) Gist.

We've been using the same cluster specifications for a while now. No matter the hosting vendor you choose in the past, if you created the cluster using my instructions if is based on nodes with only 2 available CPUs or even smaller. We'll need more. Even if your cluster is set to autoscale, increasing the number of nodes will not help since one of the Istio components we'll use requires at least 2 CPU available. Remember, even if you do have nodes with 2 CPUs, some computing power is reserved for system-level processes or Kubernetes daemons. So, we'll need to create a cluster with bigger nodes. The gists listed below will do just that. Those related to AKS, EKS, and GKE are now having nodes with 4 CPUs. If you are using your own cluster hosted somewhere else, the Gists are the same and I will assume that the nodes have at least 2 CPUs available.

On top of all that, if you are using GKE, the gists now contain the command that installs Gloo which we explored in the previous chapter.

The new Gists, excluding those installing Jenkins X in an existing cluster, are as follows.

* Create a new static **GKE** cluster: [gke-jx-gloo.sh](TODO:)
* Create a new serverless **GKE** cluster: [gke-jx-serverless-gloo.sh](TODO:)
* Create a new static **EKS** cluster: [eks-jx-gloo.sh](TODO:)
* Create a new serverless **EKS** cluster: [eks-jx-serverless-gloo.sh](TODO:)
* Create a new static **AKS** cluster: [aks-jx-gloo.sh](TODO:)
* Create a new serverless **AKS** cluster: [aks-jx-serverless-gloo.sh](TODO:)
* Use an **existing** static cluster: [install.sh](TODO:)
* Use an **existing** serverless cluster: [install-serverless.sh](TODO:)

I> The commands that follow will reset your *go-demo-6* `master` branch with the contents of the branch that contain all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

W> Depending on whether you're using static or serverless Jenkins X flavor, we'll need to restore one branch or the other. To make things more complicated, those of you running GKE will have to use the branch based on the previous chapter while others are still stuck with those from before. The commands that follow will restore `knative-cd` if you are using GKE and serverless Jenkins X and `knative-jx` if you're in GKE but with static Jenkins X. For everyone else, `extension-model-jx` is the branch if you are using static Jenkins X and `extension-model-cd` if you prefer the serverless flavor. In the commands listed below you will see `# If GKE` and `# If NOT GKE`. Execute only one command or the other depending on whether you use GKE or something else.

```bash
NAMESPACE=$(kubectl config view \
    --minify \
    --output jsonpath="{..namespace}")

cd go-demo-6

git pull

# If GKE
BRANCH=knative-$NAMESPACE

# If NOT GKE
BRANCH=extension-model-$NAMESPACE

git checkout $BRANCH

git merge -s ours master --no-edit

git checkout master

git merge $BRANCH

git push

cd ..
```

Now the branch with the last known good state is restored (if you choose to do that). What comes next should be executed only by GKE users.

W> Please execute the commands that follow only if you are using **GKE** and if you restored the branch using the commands above. Those commands will replace `vfarcic` with the GCP project you used to created the GKE Jenkins X cluster.

```bash
cd go-demo-6

cat charts/go-demo-6/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/go-demo-6/Makefile

cat charts/preview/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/preview/Makefile

cat skaffold.yaml \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee skaffold.yaml

git add .

git commit -m "Fixed the project"

git push

cd ..
```

There isn't much mystery in the commands we executed. They replaced `vfarcic` with the name of your Google project in two Makefile files and in `skaffold.yaml`.

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
cd go-demo-6

jx import --pack go --batch-mode

cd ..
```

Now we can start exploring deployment strategies, with serverless being the first in line.

## Using Serverless Deployments As The Preferable Deployment Strategy (GKE only)

Judging by the name of this section, you might be wondering why do we start with serverless deployments. The honest answer is that I did not try to put the deployment strategies in any order. We're starting with serverless simply because that is the one we used in the previous chapter. So, we'll start with what we have right now, at least for those who are running Jenkins X in GKE.

Another question you might be asking is why do we cover serverless with Knative in here given that we already discussed it in the previous chapter. The answer to that question lies in completeness. Serverless deployments are one of the important options we have when choosing the strategy and this chapter could not be complete without it. If you did go through the previous chapter, consider this one a refresher with a potential to find out something new. If nothing else, you'll might get a better understanding of the flow of events with Knative as well as to see a few diagrams. In any case, the rest of the strategies will build on top of this one. Or you might be impatient and bored with repetion. If that's the case, feel free to skip this section all together.

W> At the time of this writing (August 2019), serverless deployments with Knative work out-of-the-box only in GKE. That does not mean that Knative does not work in other Kubernetes flavors, but rather that Jenkins X installation of Knative works only in GKE. I encourage you to set it up and enable yourself to follow along in your Kubernetes flavor. Or you can skip this section if you're using a different vendor. Still, I suggest to stick around even if you cannot run the examples. I'll do my best to be brief and only provide an overview and pros and cons.

Instead of discussing pros and cons first, we'll start each strategy with an example, observe the results, and, based on that, comment their advantages and dissadvantages as well as the scenarios when they might be a good fit. In that spirit, let's create a serverless deployment first and see what we got.

W> At the time of this writing (August 2019), the examples in this section work only in a **GKE** cluster. Feel free to monitor [the issue 4668](https://github.com/jenkins-x/jx/issues/4668) for more info.

When we imported *go-demo-6* it was already running in Knative mode, so there is nothing for us to do to enable it. Thanks to what we did in the previous chapter, *go-demo-6* is already running as serverless or, to be more precise, a part of it is.

Let's go into the project directory and take a quick look at the definition that makes the application serverless.

```bash
cd go-demo-6

cat charts/go-demo-6/templates/ksvc.yaml
```

We won't go into details of Knative specification. It was briefly explained in the [Using Jenkins X To Define And Run Serverless Deployments](#knative) chapter and details can be found in the [official docs](https://knative.dev). What matters in the context of the current discussion is that the YAML you see in front of you defined a serverless deployment using Knative.

By now, if you created a new cluster the application we imported should be up-and-running. But, to be on the safe side, we'll confirm that by taking a quick look at the *go-demo-6* activities.

W> There's no need to inspect the activities to confirm whether the build is finished if you are reusing the cluster from the previous chapter. The application we deployed previously should still be running.

```bash
jx get activities \
    --filter go-demo-6 \
    --watch
```

Once you confirm that the build is finished press *ctrl+c* to stop watching the activities.

If you are using **serverless Jenkins X**, as you probably already know, the activity of an application does not wait until the release is promoted to the staging environment. So, we'll confirm that the build initiated by changes to the *environment-tekton-staging* repository is finished as well.

W> Please execute the command that follows only if you are using **serverless Jenkins X**.

```bash
jx get activities \
    --filter environment-tekton-staging/master \
    --watch
```

Just as before, feel free to press *ctrl+c* once you confirm that the build was finished.

Finally, the last verification we'll do is to confirm that the Pods are running.

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

The output is as follows.

```
NAME                           READY STATUS  RESTARTS AGE
go-demo-6-lbxwr-deployment-... 2/2   Running 0        26s
jx-go-demo-6-db-arbiter-0      1/1   Running 0        27s
jx-go-demo-6-db-primary-0      1/1   Running 0        27s
jx-go-demo-6-db-secondary-0    1/1   Running 0        27s
```

In your case, `go-demo-6` deployment might not be there. If that's the case, it's been a while since you used the application and Knative made the decision to scale it to zero replicas. We'll go through scaling-to-zero example later. For now, imagine that you do have that Pod running.

On the first look, everything looks "normal", as if the application is deployed as any other. The only "strange" thing we can observe by looking at the Pods is the name of the one created through the *go-demo-6* Deployment and that it contains two containers instead of one. We'll ignore the "naming strangeness" and focus on the latter observation.

Knative injected a container into our Pod. It contains `queue-proxy` that, as the name suggests, serves as a proxy responsible for request queue parameters. It also reports metrics to the Autoscaler through which it might to scale up or down depending on the number of different parameters. Request are reaching our application through this container.

Besides the Pod controlled by Knative, we can also observe that the MongoDB is there as well. It is not serverless but running in the same way it was running throughout the rest of the book. While we could make it serverless as well, MongoDB is probably not a good candidate for that and even if it would be, I wanted to demonstrate that different types of deployments can coexist happily.

Now, let's confirm that the application is indeed accessible just as if we did not make it serverless.

```bash
STAGING_ADDR=$(kubectl \
    --namespace $NAMESPACE-staging \
    get ksvc go-demo-6 \
    --output jsonpath="{.status.domain}")

curl "http://$STAGING_ADDR/demo/hello"
```

We retrieved the address through which we can reach the application running in the staging environment and we used `curl` to send a request. The output should be `hello, PR!` which is the message we defined in one of the previous chapters. 

So far, the major difference when compared with "normal" Kubernetes deployments is that the access to the application is not controlled through Ingress any more but through a new resource type abbreviated as `ksvc` (short for Knative Service). Apart from that, everything else seems to be the same, except if you left the application unused for a while. In such a case, you still got the same output, but there was a slight delay between sending the request and receiving the response. The reason for such a delay lies in Knative's scaling capabilities. It saw that the application is not used and scaled it to zero replicas. But, the moment we sent a request, it noticed that zero replicas is not the desired state and scaled it back to one replica. So, in such a case, the request entered into a gateway (in our case served by Gloo Envoy) and waited there until a new replica was created and initialized. After that, it forwarded the request to it, and the rest is the "standard" process of our application responding and that response being forwarded to us (back to `curl`).

![Figure 17-TODO: TODO:](images/ch17/knative-request.png)

So far, from the process perspective, there is no significant difference when compared with "normal" Kubernetes deployments, except for the `queue-proxy`. If that's everything Knative does, we could just as well replace the gateway with nginx or any other Ingress. But there's more.

Given that I couldn't be sure whether your serverless deployment indeed scaled to zero or it didn't, we'll use a bit of patience to validate that it does indeed scale to nothing after a bit of inactivity. All we have to do is wait for five to ten minutes. Go get a coffee or some snack.

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

Assuming that sufficient time passed, the output should be as follows.

```
NAME                        READY STATUS  RESTARTS AGE
jx-go-demo-6-db-arbiter-0   1/1   Running 0        6m21s
jx-go-demo-6-db-primary-0   1/1   Running 0        6m21s
jx-go-demo-6-db-secondary-0 1/1   Running 0        6m21s
```

The database is there but the application is now gone. If we ignore other resources and focus only on Pods, it seems like the application is wiped out completely. That is true in terms that nothing specific to the application is running. All that's left are a few Knative definitions and the common resources used for all applications (not specific to ours).

I> If you still see that application, all I can say is that you are inpatient and you did not wait long enough. If that's what happened, wait for a while longer and repeat the `get pods` command.

Using telemetry collected from all the Pods deployed as Knative applications, Gloo detected that no requests were sent to *go-demo-6* for a while and decided that the time has come to scale it down. It sent a notification to Knative that executed a series of actions which resulted in our application being scaled to zero replicas.

![Figure 17-TODO: TODO:](images/ch17/knative-scale-to-zero.png)

Bear in mind that the actual procees is more complicated than that and that there are quite a few other components involved. Nevertheless, for the sake of brevity, the simplistic view we presented should suffice. I'll leave it up to you to go deeper into Gloo and Knative or accept it as magic. In either case, our application was successfully scaled to zero (removed) thus saving resources that could be better used by other applications and save us some costs in the process.

If you never used serverless deployments and specifically never worked with Knative, you might think that your users would not be able to access it any more since the application is not running. Or you might think that it will be scaled up once requests start coming in but you might be scared that you'll loose those sent before the new replica start running. Or you might have read the previous chapter and know that those fears are unfounded. In any case, we'll put that to the test by sending three hundred concurrent requests during twenty seconds.

```bash
kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- --concurrent 300 --time 20S \
     "http://$STAGING_ADDR/demo/hello" \
     && kubectl \
     --namespace $NAMESPACE-staging \
    get pods
```

We won't go into details about Siege. Read the previous chapter if you want to know more. What matters is that we finished sending a lot of requests and that the previous command output the Pods in the staging namespace. That output is as follows.

```
NAME                           READY STATUS  RESTARTS AGE
go-demo-6-lbxwr-deployment-... 2/2   Running 0        20s
go-demo-6-lbxwr-deployment-... 2/2   Running 0        14s
go-demo-6-lbxwr-deployment-... 2/2   Running 0        14s
jx-go-demo-6-db-arbiter-0      1/1   Running 0        6m59s
jx-go-demo-6-db-primary-0      1/1   Running 0        6m59s
jx-go-demo-6-db-secondary-0    1/1   Running 0        6m59s
```

Our application is up-and-running again. Few moments the application was not running and now it is. Not only that but it was scaled to three replicas to accomodate the elevated number of concurrent requests.

![Figure 17-TODO: TODO:](images/ch17/knative-scale-to-three.png)

What did we learn from serverless deployments in the context of our quest to find one that fits our needs the best?

Highly availability is easy in Kuberentes, as long as our applications are designed with that in mind. What that means is that our applications should be scalable and should not contain state. If they cannot be scaled, they cannot be highly available. When a replica fails (not that I did not say if but when), no matter how fast Kubernetes is to reschedule it somewhere else, there will be downtime, unless other replicas take over its load. If there are no other replicas, we are bound to have downtime both due to failures but also whenever we deploy a new release. So, scalability (running more than one replica) is the prerequisite for high availability. At least, that's what logic might make us think.

In case of serverless deployments with Knative, not having replicas that can respond to user requests is not an issue, at least not from high availability point of view. While in a "normal" situation the requests would fail to receive a response, in our case they were queued in the gateway and forwarded only after the application is up-and-running. So, even if the application is scaled to zero replicas (nothing is running), we are still highly available. The major downside are potential delays between receiving the first requests and until the first replica of the application is responsive.

The problem with might have with serverless deployments, at least when used in Kubernetes, is responsiveness. If we keep the default settings, our application will scale to zero if there are no incoming requests. As a result, when someone does send a request to our application it might take longer until the response is received. That could be a couple of milliseconds, a few seconds, or much longer. It all depends on the size of container image, whether it is already cached on the node where the Pod is scheduled, the amount of time the application needs to initialize, and quite a few other criteria. If we do things right, that delay can be short. Still, a delay reduces the responsivenes of our application. What we need to do compare pros and cons where results will differ from one application to another.

Let's take the static Jenkins as an example. In many organizations, it is under heavy usage throughout working hours, and with low or no usage at nights. We can say that half of the day it is not used. What that really means is that we are paying double to our hosting vendor. We could have shut it down over night. Even if the price is not an issue, surely those resources used by inactive Jenkins could be better used by some other processes. Shutting down the application would be an improvement but it would also produce potentially very negative effects. What if someone is working over night and pushes a change to Git. A webhook would fire trying to notify Jenkins that it should run a build. But, such webhook would fail since there would be no Jenkins to handle the request. A build would never be executed. Unless we set up a policy that says "you are never allowed to work after 6pm, even if the whole system crashed", having a non-responsive system is unacceptable.

Another issue would be to figure out when is our system not in use. If we continue using the "traditional" Jenkins as an example, we could say that it should shut-down at 9pm. If our official working hours end at 6pm, that would provide three hours margin for those who do stay in the office longer. That would still be an suboptimal solution. During much of those three hours Jenkins would not be used and it would continue wasting resources. On the other hand, there is still no guarantee that no one will ever push a change after 9pm.

Knative solves those and quite a few other problems. Instead of shutting down our applications at predefined hours and hope that no one is using them while they are unavailable, we can let Knative (together with Gloo or Istio) monitor requests. It would scale down if certain period of inactivity passed. On the other hand, it would scale back up if a request is sent to it. Such requests would not be lost but queued until the application becomes available again.

All in all, I cannot say that Knative might result in non-responsiveness but that it might produce slower responses in some cases (between having none and more replicas). Such periodical slower responsiveness might produce less negative effect than the good it brings. Is it really such a bad thing if static Jenkins takes aditional 15 seconds to start building something after a whole night of inactivity? In that particular case, the upside outweight the downsides. Still, there are even better examples of the advantages of serverless deployments than Jenkins.

Preview environments might be the best example of wasted resources. Every time we create a pull request, a release is deployed in a temporary environment. That, by itself, is not a waste since the benefits of being able to test and review an application before merging it to master outweight the fact that most of the time we are not using those applications. Nevertheless, we can do better. Just as we explained in the previous chapter, we can use Knative to deploy to preview environments, no matter whether we use it for permanent environments like staging and production. After all, preview environments are not meant to provide a place to test something before promoting it to production (staging does that), but rather to have relative certainty that what we'll merge to the master branch is likely code that works well.

If the response delay caused by scaling up from zero replicas is unacceptable in certain situations, we can still configure Knative to have one or replicas as a minimum. In such a case, we'd still benefit from Knative capabilities. For example, the metrics it uses to decide when to scale might be easier or better than those provided by HorizontalPodAutoscaler (HPA). Nevertheless, the result of having Knative deployment with a minimum number of replicas above zero is similar to the one we'd have with using HPA so we'll ignore such situations since our applications would not be serverless. That is not to say that Knative is not useful if it doesn't scale to zero, but rather that we'll treat those situations separately and stick to serverless features in this section.

What's next in our list of deployment requirements?

Even though we did not demonstrate it through examples, serverless deployments with Knative do not produce downtime when deploying new releases. All new requests will be handled by a new release, while the old one will be available to process all those that were initiated before the new deployment started rolling out. Similarly, if we have health checks, it will stop the rollout if the fail and never succeed. In that aspect, we can say that rollout is progressive. On the other hand, it is not true progressive rollout but similar to those we get with rolling updates. Knative, by itself, cannot choose whether to continue progressing based on arbitrary metrics. Similarly, it cannot roll back automatically if pre-defined criteria is met. Similarly like rolling updates, it will stop the rollout if health checks fail. If those health checks fail with the first replica, even though there is no rollback, all the requests will continue being served with the old release. Still, there are too many ifs in those statements. We can only say that serverless deployments with Knative (without additional tooling) partially fullfill progressive rollout and are incapable of automated rollbacks.

Finally, the last requirement is that our deployment strategy should be cost effective. Serverless deployments, at least those implemented with Knative, are probably the most cost effective deployments we can have. Unlike vendor-specific serverless implementations like AWS Lambda, Azure Functions, and Google Cloud's serverless platform, we are in (almost) full control. We can define how many requests are served by a single replica. We control the size of our applications given that anything that can run in a container can be serverless (but is not necesarrily a good candidate). We control which metrics are used to make decisions and what are the thresholds. That might be more complicated than using vendor-specific serverless implementations and its up to us to decide whether additional complications with Knative outweight the benefits it brings. I'll leave such a decision in your hands.

So, what did we conclude? Do serverless deployments with Knative fullfull all our requirements? The answer to that question is a resounding "no". No deployment is perfect. Serverless deployments provide **huge benefits** with **high-availability* and *cost-effectiveness**. They are **relatively responsive and provide certain level of progressive rollouts**. The major drawback is the **lack automated rollaback**.

|Requirement        |Fullfilled|
|-------------------|----------|
|High-availability  |Fully     |
|Responsiveness     |Partly    |
|Progressive rollout|Partly    |
|Rollback           |Not       |
|Cost effectiveness |Fully     |

Please note that we used Gloo in conjunction with Knative to perform serverless deployments. We could have used Istio instead of Gloo. Similarly, we could have used OpenFaaS instead of Knative. Or we could have opted for something completely different. There are many different solutions we could assemble with the goal of making our applications serverless. Still, the goal was not to compare them all and choose the best one, but rather to explore serverless deployments as one possible strategy we could employ. I do believe that Knative is the most promising one, but we are still in early stages with those concepts and it would be impossible to be certain what will prevail. Similarly, for many Istio would be the service mesh of choice due to it's high popularity. Yet, I choose Gloo mostly because of its simplicity and its small footprint. For those of you who prefer Istio, all I can say is that we will use it for different purposes later on in this chapter.

Finally, I made a decision to present only one serverless implementation mostly because it would take much more than a single chapter to compare all those that are popular. The same can be said for service mesh (Gloo). Both are very interesting subject that I might explore in the next book. But, at this moment I cannot make that promise because I honestly do not know plan a new book before the one I'm writing (this one) is finished.

What matters is that we're finished with a very high-level exploration of pros and cons of using serverless deployments and now we can move onto the next one. But, before we do that, we'll revert our chart to the good old Kubernetes Deployment.

```bash
jx edit deploy \
    --kind default \
    --batch-mode

cat charts/go-demo-6/values.yaml \
    | grep knative
```

We edited the deployment strategy by setting it to `default` (it was `knative` so far) and we output the `knative` variable to confirm that it is now set to `false`.

The last thing we'll do is go out of the local copy of the *go-demo-6* directory so that we are in the same place as those who could not follow the exaples because their cluster cannot yet run Knative or those who were too lazy to set it up.

```bash
cd ..
```

## Going Old-School With the Recreate Deployment Strategy

*A long time ago in a galaxy far, far away...* most of the applications were deployed with what today we call the *recreate* strategy. We'll discuss it shortly. For now, we'll focus on implementing it and observing the outcome.

By default, Kubernetes Deployments use the RollingUpdate strategy. If we do not specify any, that's the one that is implied. We'll get to that one later. For now, what we need to do is ad the `strategy` into the `deployment.yaml` file that defines the Deployment.

```bash
cd go-demo-6

cat charts/go-demo-6/templates/deployment.yaml \
    | sed -e \
    's@  replicas:@  strategy:\
    type: Recreate\
  replicas:@g' \
    | tee charts/go-demo-6/templates/deployment.yaml
```

We entered the local copy of the *go-demo-6* repository and used a bit of `sed` magic to add the `strategy` entry just above `replicas`. If you are not a `sed` ninja, that command might have been confusing, so let's output the file and see what we got.

```bash
cat charts/go-demo-6/templates/deployment.yaml
```

The output, limited to the relevant section, is a follows.

```yaml
...
spec:
  strategy:
    type: Recreate
...
```

Now that we changed our deployment strategy to `recreate`, all that's left is to push it to GitHub, wait until it is deployed, and observe the outcome. Right?

```bash
git add .

git commit -m "Recreate strategy"

git push

jx get activities \
    --filter go-demo-6 \
    --watch
```

We pushed the changes and started watching the activities. Please press *ctrl+c* to cancel the watcher once you confirm that the newly started build is finished.

If you're using serverless Jenkins X, the build of an application does not wait for the activity associated with automatic promotion to finish so we'll confirm whether that is done as well.

W> Please execute the command that follows only if you are using **serverless Jenkins X**.

```bash
jx get activities \
    --filter environment-tekton-staging/master \
    --watch
```

You know what needs to be done. Press *ctrl+c* when the build is finished.

Let's take a look at the Pods we got.

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

The output is as follows

```
NAME                        READY STATUS  RESTARTS AGE
jx-go-demo-6-94b4bb9b6-...  1/1   Running 0        36s
jx-go-demo-6-94b4bb9b6-...  1/1   Running 0        36s
jx-go-demo-6-94b4bb9b6-...  1/1   Running 0        36s
jx-go-demo-6-db-arbiter-0   1/1   Running 0        15m
jx-go-demo-6-db-primary-0   1/1   Running 0        15m
jx-go-demo-6-db-secondary-0 1/1   Running 0        15m
```

There's nothing new here. Judging by the look of the Pods, if you did not change the strategy to `recreate` you would probably think that it is still the default `RollingUpdate`.

The only difference we could notice is in the description of the Deployment, so let's output it.

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    describe deployment jx-go-demo-6
```

The output, limited to the relevant part, is as follows.

```yaml
...
StrategyType:       Recreate
...
Events:
  Type   Reason            Age  From                  Message
  ----   ------            ---- ----                  -------
...
  Normal ScalingReplicaSet 20s  deployment-controller Scaled up replica set jx-go-demo-6-589c47878f to 3
```

So, we confirmed that the `StrategyType` is now `Recreate`. That's not a surprise. What is more interesting is the last entry in the `Events` section. It scaled replicas of the new release to three. Why is that a surprise? Isn't that the logical action when deploying the first release with the new strategy? Well... It is indeed logical for the first release so we'll have to make another release and deploy it to see what's really going on.

If you had Knative deployment running before, there is a small nuasance we need to fix. Ingress is missing and I can prove that.

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get ing
```

The output claims that `no resources` were `found`.

W> Non-Knative users will have Ingress running and will not have to execute the workaround we are about to do. Feel free to skip the few commands that follow. Alternatively, you can run them as well. No harm will be done. Just remember that their purpose is to create Ingress that is already running and there will be no visible effect.

What happened? Why isn't there Ingress when we saw it countless times before in previous execises?

Jenkins X creates Ingress resources automatically unless we tell it otherwise. You know that already. What you might not know is that there is a bug (undocummented feature) because of which Ingress is not created the first time we change the deployment type from Knative to plain-old Kubernetes Deployments. Given that that happens only when we switch and not in consecutive deployments of new releases, all we have to do is deploy a new release and the second time Jenkins X will pick it up correctly and create missing Ingress resource. Without it we won't be able to access the application from outside the cluster. So, all we have to do is make a trivial change and push it to GitHub. That will trigger yet another pipeline activity that will result in creation of a new release and its deployment to the staging environment.

```bash
echo "something" | tee README.md

git add .

git commit -m "Recreate strategy"

git push
```

We made a silly change, we pushed it to GitHub, and that triggered yet a new build. All we have to do is wait or, even better, watch the activities of *go-demo-6* and the staging environment pipelines to confirm that everything was executed correctly. I'll skip showing you the `jx get activities` commands given that I'm sure you already know them by heart.

Assuming that you were patient enough and waited until the new release is deployed, now we can confirm that the Ingress was indeed created.

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get ing
```

The output is as follows.

```
NAME      HOSTS                                      ADDRESS        PORTS AGE
go-demo-6 go-demo-6.cd-staging.35.237.194.237.nip.io 35.237.194.237 80    61s
```

That's the same output that those that did not run Knative before saw after the first release.

All in all, the application is now running in staging, and it was deployed using the `recreate` strategy.

Next, we'll make yet another simple change to the code. This time, we'll change the output message of the application. That will allow us to easily see how it before and after the new release is deployed.

```bash
cat main.go | sed -e \
    "s@hello, PR@hello, recreate@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@hello, PR@hello, recreate@g" \
    | tee main_test.go

git add .

git commit -m "Recreate strategy"

git push
```

We changed the message. As a result, our current release is outputting `hello, PR` while the new release, once its deployed, will return `hello, recreate`.

Now we need to be **very fast** and start sending requests to our application before the new release is rolled out. If you're unsude why we need to do that, it will become evident in a few moments.

Please open a second terminal window.

Given that **EKS** requires access key ID and secret access key as authentication, we'll need to declare a few environment variables in the new terminal session. Those are the same ones we used to create the cluster, so you should not have any trouble recreating them.

W> Please execute the commands that follow **only** if your cluster is running in **EKS**. You'll have to replace the first `[...]` with your access key ID, and the second with the secret access key.

```bash
export AWS_ACCESS_KEY_ID=[...]

export AWS_SECRET_ACCESS_KEY=[...]

export AWS_DEFAULT_REGION=us-west-2
```

Let's find out the address of our application running in staging.

```bash
jx get applications --env staging
```

The output should be similar to the one that follows.

```
APPLICATION STAGING PODS URL
go-demo-6   9.0.30  3/3  http://go-demo-6.cd-staging.35.237.194.237.nip.io
```

Copy the `go-demo-6` URL and paste it instead of `[...]` in the command that follows.

```bash
STAGING_ADDR=[...]
```

That's it. Now we can start bombing our application with requests.

```bash
while true
do
    curl "$STAGING_ADDR/demo/hello"
    sleep 0.2
done
```

We created an infinite loop inside which we're sending requests to the application running in staging. To avoid burning your laptop, we also added a short delay of `0.2` seconds.

If you were fast enough, the output should consist of an endless list of `hello, PR!`. If that's what you're getting, it means that the deployment of the new release did not yet start. If that's what you're seeing, all we have to do is wait.

At one moment, `hello, PR!` messages will turn into `502` or `503` responses. Our application is down. If this would be a "real world" situation, our users would experience outage. Some of them might even be so dissapointed that they will choose not to stick around to see whether we'll recuperate and instead switch to a competing product. I know that I, at least, have a very short tollerance threshold. If something does not work and I do not have a strong dependency on it, I move somewhere else almost instantly. If I'm commited to a service or an application, my tollerance might be a bit more forgiving but it is not indefinite. I might forgive you one outage, maybe even two, but the third time I cannot consume something I will start considering an anlternative. Than again, that's only me and your users might be more forgiving. Still, even if you do have loyal customers, downtime is not a good thing and we should avoid it.

While you were reading the previous paragraph, the message probably changed again. Now it should be end endless loop of `hello, recreate!`. Our application recuperated and is now operational again. It's even showing us the results of the new release. If we could erase from our memory the `502` and `503` messages, that would be awesome.

All in all, the output, limited to the relevant parts, should be as follows.

```
...
hello, PR!
hello, PR!
...
<html>
<head><title>502 Bad Gateway</title></head>
<body>
<center><h1>502 Bad Gateway</h1></center>
<hr><center>openresty/1.15.8.1</center>
</body>
</html>
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>openresty/1.15.8.1</center>
</body>
</html>
...
hello, recreate!
hello, recreate!
...
```

If all you ever saw was only the loop of `hello, recreate!`, all I can say is that you were too slow and you'll have to trust me that there were some nesty messages in between the old and the new release.

That was enough looping for now. Please press *ctrl+c* to stop it and give your laptop a rest. Leave the second terminal open and back to the first one. We'll need both later on.

What happened was not pretty nor desirable. Even if you are not familiar with the `RollingUpdate` strategy (the default one for Kubernetes Deployments), you already experienced it countless times before. You probably did not see those 5xx message in the previous exercises and that might make you wonder why did we switch to `Recreate`. Would anyone want that? Now, the answer to that question is that no one desires such outcomes, but many are having them anyway. I'll explain soon why we want to use the `Recreate` strategy even though it produces outage. To answer why would anyone want something like that, we'll first explore why was the outage produced in the first place.

When we deployed the second release using the `Recreate` strategy, Kubernetes first shut down all the instances of the old release and only when they all ceased to work, it deployed the new release in its place. The downtime we experienced existed between the time the old release was shut down and the time the new one became fully operational. The downtime lasted for only a couple of seconds, but that's because our application (*go-demo-6*) boots up very fast. Some other applications might be much slower and the downtime would be much longer. It's not uncommon for the downtime in such cases to take minutes and sometimes even hours.

We can think of the `Recreate` strategy as "Big Bang". There is no transition period, there are no rolling updates, nor there is any other of the "modern" deployment practices. The old release is shut down and the new one is put in its place. It's simple and straightforward, but it results in inevitable downtime.

![Figure 17-TODO: TODO: Recreate deployments and downtime](images/ch17/TODO:.png)

Still, the initial question stands. Who would ever want to use the `Recreate` strategy? The answer is not that much who wants it, but rather who must use it.

Let's take another look at static Jenkins. It is a stateful application that cannot scale. So, replacing one replica at a time as a way to avoid downtime is out of question. When applications cannot scale, there is no way we could ever accomplish deployments without downtime. Two replicas are a minimum. Otherwise, if only one replica is allowed to run at any given moment, we have to shut it down to make room for the other replica (the one from the new release). So, when there is no scaling, there is no high availability. Downtime, at least related to new releases, is unavoidable.

Why static Jenkins cannot scale? There can be many answers to that question, but the main culprit is its state. It is a stateful application unable to share that state across multiple instances. Even if you deploy multiple Jenkins instances, they would operate independenly from each other. Each would have a different state and manage different pipelines. That, dear reader, is not scaling. Having multiple independent instances of an application is not replication. For an application to be scalable, each replica needs to work together with others and share the load. As a rule of thumb, for an application to be scalable it needs to be stateless (e.g., *go-demo-6*) or to be able to replicate state across all replicas (e.g,. MongoDB). Jenkins does not fullfil either of the two criteria and, therefore, it cannot scale. Each instance has its own file storage where it keeps the state unique to that instance. The best we can do with static Jenkins is to give an instance to each team. That solves quite a few Jenkins-specific problems, but it does not make it scalable. As a result, it is impossible to upgrade Jenkins without downtime.

Upgrades are not the only source of downtime with unscalable applications. If we have only one replica, when it fails Kubernetes will recreate it. But that will also result in downtime. As a matter of fact, failure and upgrades of single-replica applicaions are more or less the same. In both cases the only replica is shut down and the new one is put in its place. Between the two there is downtime.

![Figure 17-TODO: TODO: Downtime introduced by failure of a single-replica application](images/ch17/TODO:.png)

All that might leads you to conclude that only single-replica applications should use the `Recreate` strategy. That's not true. There are many other reasons while "big bang" deployment strategy should be used. We won't have time to discuss all the reasons so I'll mention only one more.

The only way to avoid downtime when upgrading applications is to run multiple replicas and start replacing them one by one or in batches. It does not matter much how many replicas we shut down and replace with those with the new release, just as long as long as there is at least one replica of the application running. What that means is that we are likely going to run the new release in parallel with the old for a while. We'll go through that scenario soon. For now, trust me when I say that running multiple releases of an application in parallel is unavoidable if we are to perform deployments without downtime. That means that our releases must be backwards compatible, that our applications need to version APIs, and that clients need to take that versioning into account when working with our applications. That backwards compatibility is usually the main stumbling block that prevents teams to apply zero-downtime deployments. It extends everywhere. Database schemas, APIs, clients, and many other components need to be backwards compatible.

All in all, lack of backwards compatibility and quite a few other things might prevent us from running two releases in parallel and without that, we are forced to use the `Recreate` strategy or something similar.

So, the real question is not whether anyone wants to use the `Recreate` strategy, but rether who is forced to apply it due to the problems usually related to architecture of an application. If you are having a stateful application, the chances are the you have to use that strategy. Similarly, if your application cannot scale, you are probably forced to use it.

Given that deployment with the `Recreate` strategy inevitably produce downtime, most teams tend to have less frequent releases. The impact of, lets say, one minute of downtime is not that big if we produce it only a couple of times a year. But, if we would increase the release frequency, that negative impact would increase as well. Having downtime a couple of times a year is much better than once a month. High velocity iterations are out of question. We couldn't deploy a release once a week, once a day, or even multiple times a day if we'll experience downtime each time we do that. In other words, zero-downtime deployments are a prerequisite for high-frequency releases to production. Given that the `Recreate` strategy does produce downtime, it stands to reason that it fosters less frequent releases to production as a way to reduce the impact.

Before we proceed, it might be important to note that there was no particular reason to use the `Recreate` deployment strategy. The application is scalable and it is designed to be backwards compatible. Any other strategy would be better suited given that downtime produced by deployments is probably the most important requirement we can have. We used it only to demonstrate how that deployment type works and to be consistent with other examples in this chapter.

Now that we saw how the `Recreate` strategy works, let's see which requirement did it fullfil, and which it failed to address. As you can probably guess, what follows is not going to be a pretty picture.

When there is downtime, there is no high-availability. One excludes the other, so we failed with that one.

Is our application responsive? If we used an application more appropriate for that type of deployment, we would probably discover that it would not be responsive or that it would be very expensive, if not both. If we go back to static Jenkins as a good example for the `Recreate` deployment strategy, we would quickly discover that it is expensive to have it. Now, I do not mean expensive in terms of licencing costs but rather in resource usage. We'd need to set it up to you memory and CPU required for its peak load. We'd probably take a look at metrics and try to figure out how much memory and CPU it uses when the most concurrent builds are running, increase those values just to be on the safe side, and set them as requested resources. What that would mean is that we'd use CPU and memory required for the peak load, even if most of the time we need much less. In some other cases, we'd let it scale up and down and, in that way, balance the load while using only the resources it needs. But, if that would be possible, we would not use the `Recreate` strategy. Instead, we'd waste resources just to be on the safe side knowing that it can handle any load. That's costly. The alternative would be to be cheaper and give it less resources than the peak load. However, in that case it would not be responsive given that the builds at the peak load would need to be queue. Or, even worse, it would just bleed out and fail under a lot of pressure. In any case, a typical application used with the `Recreate` deployment strategy is either not responsive or it is expensive or both.

The only thing left is to see whether that deployment type allows progressive rollout and rollbacks. In both cases, the answer is a resounding no. Given that most of the times there only one replica is allowed to run, progressive rollout is impossible. On the other hand, there is no mechanism to roll back in case of a failure. That is not to say that it is not possible to do that, but rather that it is not incorporated into the deployment process itself. We'd need to modify our pipelines to accomplish that. Given that we're focused only on deployment strategy, rollbacks are not available.

The summary of the fullfillement of our requirements for the `Recreate` deployment strategy is as follows.

|Requirement        |Fullfilled|
|-------------------|----------|
|High-availability  |Not       |
|Responsiveness     |Not       |
|Progressive rollout|Not       |
|Rollback           |Not       |
|Cost effectiveness |Not       |

As you can see, that was a very depressing outcome. Yet, architecture of our applications often forces us to apply it and we need to learn to live with it, at least until the day we are allowed to redesign those applications or throw them to thrash and start over.

I hope that you never worked with such applications. If you didn't, you are either very young, or you always worked in awesome companies. I, for example, spent most of my cerreer with applications that had to be put down for hours every time we deploy a new release. I had to come to the office for weekends because that's then the least number of users were using our applications and spend hours or even days doing deployments. I spent too many nights sleeping in the office over weekends. Luckily, that was years ago and we had only a few releases a year. Those days now feel like nightmare that I never want to experience again. That might be the reason why I got interested in automation and architecture. I wanted to make sure that I replace myself with scripts.

So far, we saw two deployment strategies. We probably started with the inverted order, at least from the historical perspective. We can say that serverless deployments are one of the most advanced and modern strategies, while `Recreate` or, to use a better name, "big bang" deployments are the gosts of the past that are still haunting us. It's no wonder that Kubernetes does not use it as a default deployment type.

From here on, the situation can be only more positive. Brace yourself for an increased level of happiness.

## Using Rolling Updates Deployment Strategy

We explored one of the only two strategies we can use with Kubernetes Deployment resource. As we saw, the non-default `Recreate` is meant to serve legacy applications that are typically stateful and often do not scale. Next, we'll see what Kubernetes community thinks should be the default way we should deploy our software.

I> Please bear in mind that both in the previous and in this section we are focused on what Kubernetes Deployment offers. We could have just as well used StatefulSet for stateful applications or DeamonSet for those that should be running in each node of the cluster. However, even though those behave differently, they are still based on similar principles. Given that I do not want to convert this chapter into a neverending flow of rambling, we'll ignore those and focus only on Kubernetes Deployment resource before we go yet again outside of what Kubernetes offers out-of-the-box.

Now, let's get back to to the topic.

To make our Deployment use the `RollingUpdate` strategy, we can either remove the whole `strategy` entry given that is the default, or we can change the type. We'll go with the latter since the command to accomplish that is easier.

```bash
cat charts/go-demo-6/templates/deployment.yaml \
    | sed -e \
    's@type: Recreate@type: RollingUpdate@g' \
    | tee charts/go-demo-6/templates/deployment.yaml
```

TODO: Continue text

```yaml
{{- if .Values.knativeDeploy }}
{{- else }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "fullname" . }}
  labels:
    draft: {{ default "draft-app" .Values.draft }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
spec:
  strategy:
    type: RollingUpdate
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        draft: {{ default "draft-app" .Values.draft }}
        app: {{ template "fullname" . }}
{{- if .Values.podAnnotations }}
      annotations:
{{ toYaml .Values.podAnnotations | indent 8 }}
{{- end }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        env:
        - name: DB
          value: {{ template "fullname" . }}-db
        ports:
        - containerPort: {{ .Values.service.internalPort }}
        livenessProbe:
          httpGet:
            path: {{ .Values.probePath }}
            port: {{ .Values.service.internalPort }}
          initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
          periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
          successThreshold: {{ .Values.livenessProbe.successThreshold }}
          timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
        readinessProbe:
          httpGet:
            path: {{ .Values.probePath }}
            port: {{ .Values.service.internalPort }}
          periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
          successThreshold: {{ .Values.readinessProbe.successThreshold }}
          timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
        resources:
{{ toYaml .Values.resources | indent 12 }}
      terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
{{- end }}
```

```bash
cat main.go | sed -e \
    "s@hello, recreate@hello, rolling update@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@hello, recreate@hello, rolling update@g" \
    | tee main_test.go

git add .

git commit -m "Recreate strategy"

git push

# Go to the second terminal

while true
do
    curl "$STAGING_ADDR/demo/hello"
    sleep 0.2
done
```

```
...
hello, recreate!
hello, recreate!
hello, rolling update!
hello, rolling update!
...
```

```bash
# Press *ctrl+c* to stop the loop

# NOTE: It could result in mixed responses from two releases

# Back to the first terminal

kubectl \
    --namespace $NAMESPACE-staging \
    describe deployment jx-go-demo-6
```

```
Name:                   jx-go-demo-6
Namespace:              cd-staging
CreationTimestamp:      Fri, 16 Aug 2019 14:35:19 -0700
Labels:                 chart=go-demo-6-9.0.32
                        draft=draft-app
                        jenkins.io/chart-release=jx
                        jenkins.io/namespace=cd-staging
                        jenkins.io/version=5
Annotations:            deployment.kubernetes.io/revision: 4
                        jenkins.io/chart: env
                        kubectl.kubernetes.io/last-applied-configuration:
                          {"apiVersion":"extensions/v1beta1","kind":"Deployment","metadata":{"annotations":{"jenkins.io/chart":"env"},"labels":{"chart":"go-demo-6-9...
Selector:               app=jx-go-demo-6,draft=draft-app
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:  app=jx-go-demo-6
           draft=draft-app
  Containers:
   go-demo-6:
    Image:      gcr.io/devops-26/go-demo-6:9.0.32
    Port:       8080/TCP
    Host Port:  0/TCP
    Limits:
      cpu:     100m
      memory:  256Mi
    Requests:
      cpu:      80m
      memory:   128Mi
    Liveness:   http-get http://:8080/demo/hello%3Fhealth=true delay=60s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get http://:8080/demo/hello%3Fhealth=true delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:
      DB:    jx-go-demo-6-db
    Mounts:  <none>
  Volumes:   <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   jx-go-demo-6-658f88478b (3/3 replicas created)
Events:
  Type    Reason             Age                From                   Message
  ----    ------             ----               ----                   -------
  Normal  ScalingReplicaSet  15m                deployment-controller  Scaled up replica set jx-go-demo-6-94b4bb9b6 to 3
  Normal  ScalingReplicaSet  10m                deployment-controller  Scaled down replica set jx-go-demo-6-94b4bb9b6 to 0
  Normal  ScalingReplicaSet  10m                deployment-controller  Scaled up replica set jx-go-demo-6-8b5698864 to 3
  Normal  ScalingReplicaSet  6m24s              deployment-controller  Scaled down replica set jx-go-demo-6-8b5698864 to 0
  Normal  ScalingReplicaSet  6m17s              deployment-controller  Scaled up replica set jx-go-demo-6-77b6455c87 to 3
  Normal  ScalingReplicaSet  80s                deployment-controller  Scaled up replica set jx-go-demo-6-658f88478b to 1
  Normal  ScalingReplicaSet  80s                deployment-controller  Scaled down replica set jx-go-demo-6-77b6455c87 to 2
  Normal  ScalingReplicaSet  80s                deployment-controller  Scaled up replica set jx-go-demo-6-658f88478b to 2
  Normal  ScalingReplicaSet  72s                deployment-controller  Scaled down replica set jx-go-demo-6-77b6455c87 to 1
  Normal  ScalingReplicaSet  71s (x2 over 72s)  deployment-controller  (combined from similar events): Scaled down replica set jx-go-demo-6-77b6455c87 to 0
```

## Blue-Green Deployments

```bash
jx get applications --env staging
```

```
APPLICATION STAGING PODS URL
go-demo-6   1.0.339 3/3  http://go-demo-6.jx-staging.35.237.112.210.nip.io
```

```bash
VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode
```

```
WARNING: prow based install so skip waiting for the merge of Pull Requests to go green as currently there is an issue with gettingstatuses from the PR, see https://github.com/jenkins-x/jx/issues/2410
Promoting app go-demo-6 version 1.0.373 to namespace cd-production
pipeline vfarcic/go-demo-6/master
WARNING: No $BUILD_NUMBER environment variable found so cannot record promotion activities into the PipelineActivity resources in kubernetes
Created Pull Request: https://github.com/vfarcic/environment-tekton-production/pull/1
Added label  to Pull Request https://github.com/vfarcic/environment-tekton-production/pull/1
pipeline vfarcic/go-demo-6/master
WARNING: No $BUILD_NUMBER environment variable found so cannot record promotion activities into the PipelineActivity resources in kubernetes
Pull Request https://github.com/vfarcic/environment-tekton-production/pull/1 is merged at sha 1df4e1ed4a7c1573034aff679f96fd62f7c068c2
Pull Request merged but we are not waiting for the update pipeline to complete!
WARNING: Could not find the service URL in namespace cd-production for names go-demo-6, cd-production-go-demo-6, cd-production-go-demo-6
```

```bash
# If serverless
jx get activities \
    --filter environment-tekton-production/master \
    --watch

# Stop with *ctrl+c*

jx get applications --env production
```

```
PPLICATION PRODUCTION PODS URL
go-demo-6   1.0.339    3/3  http://go-demo-6.cd-production.35.237.112.210.nip.io
```

```bash
# Repeat if *No applications found in environments production*

PRODUCTION_ADDR=[...]

curl "$PRODUCTION_ADDR/demo/hello"
```

```
hello, rolling update!
```

```bash
# Repeat if *503 Service Temporarily Unavailable*
```

## Progressive Delivery

The necessity to test new releases before deploying them to production is as old as our industry. Over time, we developed elaborate processes aimed at ensuring that our software is ready for production. We test it locally and deploy it to a testing environment and test some more. When we're comfortable with the quality we'd deploy it to the integration or pre-production environment for the final round of validations. You probably see the pattern. The closer we get to releasing something to production, the more our environments would be similar to production. That was a lengthy process that would last for months, sometimes even years.

Why did we move our releases through different environments (e.g., servers or clusters)? The answer lies in the difficulties in maintaining production-like environments. It took a lot of effort to manage environments and the more they looked like production, the more work they required. Later on we adopted configuration management tools like CFEngine, Chef, Puppet, Ansible, and quite a few others. They simplified management of our environments, but we kept the practice of moving our software from one to another as if it was an abandoned child moving from one foster family to another. The main reason why configuration management tools did not solve much lies in misunderstanding the root-cause of the problem. What made management of environments difficult is not that we had many of them, nor that production-like clusters are complicated. Rather, the issue was in mutability. No matter how much effort we put in maintaining the state of our clusters, differences would pile up over time and we could not say that one environment is truly the same as the other. Without that guarantee, we could not claim that what was tested in one environment would work in another. The risk of experiencing failure after deploying to production was still too high.

Over time, we adopted immutability. We learned that things shouldn't be modified at runtime, but rather created anew whenever we need to update something. We started creating VM images that contained new releases and applying rolling updates that would gradually replace the old. But that was slow. It takes time to create a new VM image, and it takes time to instantiate them. There were many other problems with them, but this is neither time nor place to explore them both. Still, immutability applied to the VM level brought quite a few improvements. Our environments became stable and it was easy to have as many production-like environments as we needed.

Then came containers that took immutability to the next level. They allowed us the ability to say that something running in my laptop is the same as something running in a test environment that happens to behave in the same way as in production. Simply put, creating a container based on an image produces the same result no matter where it runs. to be honest, that's not 100% true, but when compared to what we had in the past, containers bring us as close to repeatability as we can get today.

So, if containers provide a reasonable guarantee that a release will behave the same no matter the environment it runs in, we can safely say that if it works in staging, it should work in production. That is especially true if both environments are in the same cluster. In such a case, hardware, networking, storage, and other infrastructure components are the same and the only difference is the Namespace something runs in. That should provide a reasonable guarantee that a release tested in staging should work correctly when promoted to production. Don't you agree?

Actually, even if environments are just different Namespaces in the same cluster and our releases are immutable container images, there is still a reasonable chance that we will detect issues only after we promote releases to production. No matter how well our performance tests are, production load cannot be reliably replicated. No matter how good we became writing functional tests, real users are unpredictable and that cannot be reflected in test automation. Tests look for errors we already know about, and we just can't test what we don't know about. I can go on and on about the differences between production and non-production environments, but it all boils down to one having real users, and the other running simulations of what we think "real" people would do.

Considering that production with real users and non-production with I-hope-this-is-what-real-people-do type of simulations are not the same, we can only conclude that the only final and definitive confirmation that a release is successful can come from observing how well received it is by "real" users while running in production. That leads us to the fact that we need to monitor our production systems and observe user behaviors, error rates, response times, and a lot of other metrics. Based on that data we can conclude whether a new release is truly successful or not. We keep it if it is. If it isn't, we might need to roll back or, even better, roll forward with improvements and bug fixes. That's where Progressive Delivery kicks in.

## Progressive Delivery Explained

TODO: Continue with text

TODO: Is it progressive delivery or progressive deployment, or both?

Progressive Delivery is a term that includes deployment strategies that try to avoid the pitfalls of all-or-nothing deployment strategies. New versions being deployed do not replace existing versions but run in parallel for an amount of time receiving live production traffic, and are evaluated in terms of correctness and performance before the rollout is considered successful.

Progressive Delivery encompasses methodologies such as rolling updates, blue-green or canary deployments. What is common to all of them is that monitoring and metrics are used to evaluate whether the new version is "safe" or needs to be rolled back.

Using rolling updates not all the instances of our application are updated at the same time, but they are incrementally. If you have several instances (containers, virtual machines,...) of your application you would update one at a time and check the metrics of that one before updating the next and so on. In case of issues you would remove them from the pool and increase the number of instances running the previous version.

Blue-green deployments temporarily create a parallel duplicate set of your application with both the old and new version running at the same time, and using a load balancer or DNS all traffic is sent to the new application. Both versions coexist until the new version is validated in production. If there are problems with the new version, the load balancer or DNS is just pointed back to the previous version.

With Canary deployments new versions are deployed and a subset of users are directed to it using traffic rules in a load balancer or more advanced solutions like service mesh. Users of the new version can be chosen randomly as a percentage of the total users or using other criteria such as geographic location, headers, employees vs general users, etc. The new version is evaluated in terms of correctness and performance and, if successful, more users are gradually directed to the new version. If there are issues with the new version or if it doesn't match the expected metrics the traffic rules are updated to send all traffic back to the previous version.

**Progressive Delivery makes it easier to adopt Continuous Delivery**, reducing the risk of new deployments limiting the blast radius of any possible issues, known or unknown, and providing automated ways to rollback to an existing working version.
Testing the 100% of an application is impossible, so we can use these techniques to provide a safety net for our deployments.


We saw how easy it is with Jenkins X to promote applications from development to staging to production, using the concept of environments. But it is an all-or-nothing deployment process with manual intervention if a rollback is needed.

We will explore how Jenkins X integrates Flagger, Istio, and Prometheus, projects that work together to create Canary deployments, where each deployment starts by getting a small percentage of the traffic and analyzing metrics such as response errors and duration. If these metrics fit a predefined requirement the new deployment continues getting more and more traffic until 100% of it goes through the new service. If these metrics are not successful for any reason our deployment is rolled back and is marked as failure.

## Istio

Istio is a service mesh that can run on top of Kubernetes. It has become very popular and allows traffic management, for example sending a percentage of the traffic to a different service and other advanced networking such as point to point security, policy enforcement or automated tracing, monitoring and logging.

Istio already includes its own Prometheus deployment. When Istio is enabled for a service it sends a number of metrics to this Prometheus with no need to adapt our application. We will focus on the response times and status codes.

We could write a full book about Istio, so we will focus on the traffic shifting and metric gathering capabilities of Istio and how we use those to enable Canary deployments.

## Prometheus

Prometheus is the monitoring and alerting system of choice for Kubernetes clusters. It stores time series data that can be queried using PromQL, its query language. Time series collection happens via pull over HTTP.
Many systems integrate with Prometheus as data store for their metrics.

Istio already includes its own Prometheus deployment. When Istio is enabled for a service it sends a number of metrics to this Prometheus with no need to adapt our application. We will focus on the response times and status codes.

## Flagger

Flagger is a project sponsored by WeaveWorks using Istio to automate canarying and rollbacks using metrics from Prometheus. It goes beyond what Istio provides, automating the promotion of canary deployments using Istio for traffic shifting and Prometheus metrics for canary analysis, allowing progressive rollouts and rollbacks based on metrics.


[Flagger](https://github.com/stefanprodan/flagger) is a **Kubernetes** operator that automates the promotion of canary deployments using **Istio** routing for traffic shifting and **Prometheus** metrics for canary analysis.

Flagger requires Istio, plus the installation of the Flagger controller itself. It also offers a Grafana dashboard to monitor the deployment progress.

The deployment rollout is defined by a Canary object that will generate primary and canary Deployment objects. When the Deployment is edited, for instance to use a new image version, the Flagger controller will shift the loads from 0% to 50% with 10% increases every minute, then it will shift to the new deployment or rollback if response errors and request duration metrics fail.

## Requirement Installation

We can easily install Istio and Flagger with `jx`

NOTE: Addons are probably going to be merged into apps

```bash
jx create addon istio \
    --version 1.1.7
```

NOTE: the command may fail due to the order Helm applies CRD resources. Re-running the command again should fix it.

NOTE: Istio is resource heavy and the cluster is likely going to scale up. That might slow down some activities.

When installing Istio a new ingress gateway service is created that can send all the incoming traffic to services based on Istio rules or `VirtualServices`. This achieves a similar functionality than that of the ingress controller, but using Istio configuration instead of ingresses, that allows us to create more advanced rules for incoming traffic.

We can find the external ip address of the ingress gateway service and configure a wildcard DNS for it, so we can use multiple hostnames for different services.
Note the ip from the output of `jx create addon istio` or find it with this command, we will refer to it as `ISTIO_IP`.

```bash
# If not EKS
ISTIO_IP=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

# If EKS
ISTIO_HOST=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# If EKS
export ISTIO_IP="$(dig +short $ISTIO_HOST \
    | tail -n 1)"

echo $ISTIO_IP
```

Let's continue with the other addons

NOTE: Prometheus is already installed with Istio

```bash
jx create addon flagger
```

```
WARNING: failed to create system vault in namespace cd due to no "jx-vault-vfarcic" vault found in namespace "cd"


Enabling Istio in namespace cd-production
Creating Istio gateway: jx-gateway
```

```bash
kubectl --namespace istio-system \
    get pods
```

```
NAME                                      READY   STATUS      RESTARTS   AGE
flagger-5bdbccc7f4-qx5wt                  1/1     Running     0          110s
flagger-grafana-5c88686d56-tr9l5          1/1     Running     0          78s
istio-citadel-7f447d4d4b-4t6zj            1/1     Running     0          3m22s
istio-galley-84749d54b7-2pjql             1/1     Running     0          4m46s
istio-ingressgateway-6b79f895d6-wfvtr     1/1     Running     0          4m40s
istio-init-crd-10-62c64                   0/1     Completed   0          5m8s
istio-init-crd-11-27xq5                   0/1     Completed   0          5m7s
istio-pilot-76899788b6-ws6lq              2/2     Running     0          3m35s
istio-policy-578bcb878f-pp7ql             2/2     Running     6          4m38s
istio-sidecar-injector-6895997989-gn85h   1/1     Running     0          3m14s
istio-telemetry-5448cbd995-bp7ms          2/2     Running     6          4m38s
prometheus-5977597c75-p5dn6               1/1     Running     0          3m28s
```

```bash
kubectl describe namespace \
    $NAMESPACE-production
```

```yaml
Name:         cd-production
Labels:       env=production
              istio-injection=enabled
              team=cd
Annotations:  <none>
Status:       Active

Resource Quotas
 Name:                       gke-resource-quotas
 Resource                    Used  Hard
 --------                    ---   ---
 count/ingresses.extensions  0     100
 count/jobs.batch            0     5k
 pods                        0     1500
 services                    0     500

No resource limits.
```

```bash
kubectl describe namespace \
    $NAMESPACE-staging
```

```yaml
Name:         cd-staging
Labels:       env=staging
              team=cd
Annotations:  jenkins-x.io/created-by: Jenkins X
Status:       Active

Resource Quotas
 Name:                       gke-resource-quotas
 Resource                    Used  Hard
 --------                    ---   ---
 count/ingresses.extensions  1     100
 count/jobs.batch            0     5k
 pods                        6     1500
 services                    3     500

No resource limits.
```

```bash
kubectl label namespace \
    $NAMESPACE-staging \
    istio-injection=enabled \
    --overwrite
```

```
namespace/cd-staging labeled
```

```bash
kubectl describe namespace \
    $NAMESPACE-staging
```

```yaml
Name:         cd-staging
Labels:       env=staging
              istio-injection=enabled
              team=cd
Annotations:  jenkins-x.io/created-by: Jenkins X
Status:       Active

Resource Quotas
 Name:                       gke-resource-quotas
 Resource                    Used  Hard
 --------                    ---   ---
 count/ingresses.extensions  1     100
 count/jobs.batch            0     5k
 pods                        6     1500
 services                    3     500

No resource limits.
```

The Flagger addon will enable Istio for all pods in the `jx-production` namespace so they send traffic metrics to Prometheus.
It will also configure an Istio ingress gateway to accept incoming external traffic through the ingress gateway service, but for it to reach the final service we must create Istio `VirtualServices`, the rules that manage the Istio routing. Flagger will do that for us.

## Flagger App Configuration

Let's say we want to deploy our new version to 10% of the users, and increase it another 10% every 10 seconds until we reach 50% of the users, then deploy to all users. We will examine two key metrics, whether more than 1% of the requests fail (5xx errors) or the request time is over 500ms. If these metrics fail 5 times we want to rollback to the old version.

This configuration can be done using Flagger's `Canary` objects, that we can add to our application helm chart under `charts/go-demo-6/templates/canary.yaml` 

```bash
echo "{{- if .Values.canary.enable }}
apiVersion: flagger.app/v1alpha2
kind: Canary
metadata:
  name: {{ template \"fullname\" . }}
spec:
  provider: {{.Values.canary.provider}}
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ template \"fullname\" . }}
  progressDeadlineSeconds: 60
  service:
    port: {{.Values.service.internalPort}}
{{- if .Values.canary.service.gateways }}
    gateways:
{{ toYaml .Values.canary.service.gateways | indent 4 }}
{{- end }}
{{- if .Values.canary.service.hosts }}
    hosts:
{{ toYaml .Values.canary.service.hosts | indent 4 }}
{{- end }}
  canaryAnalysis:
    interval: {{ .Values.canary.canaryAnalysis.interval }}
    threshold: {{ .Values.canary.canaryAnalysis.threshold }}
    maxWeight: {{ .Values.canary.canaryAnalysis.maxWeight }}
    stepWeight: {{ .Values.canary.canaryAnalysis.stepWeight }}
{{- if .Values.canary.canaryAnalysis.metrics }}
    metrics:
{{ toYaml .Values.canary.canaryAnalysis.metrics | indent 4 }}
{{- end }}
{{- end }}
" | tee charts/go-demo-6/templates/canary.yaml
```

```yaml
{{- if .Values.canary.enable }}
apiVersion: flagger.app/v1alpha2
kind: Canary
metadata:
  name: {{ template "fullname" . }}
spec:
  provider: {{.Values.canary.provider}}
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ template "fullname" . }}
  progressDeadlineSeconds: 60
  service:
    port: {{.Values.service.internalPort}}
{{- if .Values.canary.service.gateways }}
    gateways:
{{ toYaml .Values.canary.service.gateways | indent 4 }}
{{- end }}
{{- if .Values.canary.service.hosts }}
    hosts:
{{ toYaml .Values.canary.service.hosts | indent 4 }}
{{- end }}
  canaryAnalysis:
    interval: {{ .Values.canary.canaryAnalysis.interval }}
    threshold: {{ .Values.canary.canaryAnalysis.threshold }}
    maxWeight: {{ .Values.canary.canaryAnalysis.maxWeight }}
    stepWeight: {{ .Values.canary.canaryAnalysis.stepWeight }}
{{- if .Values.canary.canaryAnalysis.metrics }}
    metrics:
{{ toYaml .Values.canary.canaryAnalysis.metrics | indent 4 }}
{{- end }}
{{- end }}
```

And the `canary` section added to our chart values file in `charts/go-demo-6/values.yaml`. Remember to set the correct domain name for our Istio gateway instead of `go-demo-6.$ISTIO_IP.nip.io`.

```bash
echo "
canary:
  enable: false
  provider: istio
  service:
    hosts:
    - go-demo-6.$ISTIO_IP.nip.io
    gateways:
    - jx-gateway.istio-system.svc.cluster.local
  canaryAnalysis:
    interval: 30s
    threshold: 5
    maxWeight: 70
    stepWeight: 20
    metrics:
    - name: request-success-rate
      threshold: 99
      interval: 120s
    - name: request-duration
      threshold: 500
      interval: 120s
" | tee -a charts/go-demo-6/values.yaml
```

```yaml
canary:
  enable: false
  provider: istio
  service:
    hosts:
    - go-demo-6.34.73.8.113.nip.io
    gateways:
    - jx-gateway.istio-system.svc.cluster.local
  canaryAnalysis:
    interval: 30s
    threshold: 5
    maxWeight: 70
    stepWeight: 20
    metrics:
    - name: request-success-rate
      threshold: 99
      interval: 120s
    - name: request-duration
      threshold: 500
      interval: 120s
```

Explanation of the values in the configuration:

* `canary.service.hosts` list of host names that Istio will send to our application.
* `canary.service.gateways` list of Istio gateways that will send traffic to our application. `jx-gateway.istio-system.svc.cluster.local` is the gateway created by the Flagger addon on installation.
* `canary.canaryAnalysis.threshold` number of times a metric must fail before aborting the rollout.
* `canary.canaryAnalysis.maxWeight` max percentage sent to the canary deployment, when reached all traffic is sent to the new new version.
* `canary.canaryAnalysis.stepWeight` increase the percentage this much in each interval (20%, 40%, 60%, etc).
* `canary.canaryAnalysis.metrics` metrics from Prometheus, some are automatically populated by Istio and you can add your own from your application.
  * `request-success-rate` minimum request success rate (non 5xx responses) percentage (0-100).
  * `request-duration` maximum request duration in milliseconds, in the 99th percentile.

TODO: Carlos: Shouldn't we change `service.annotations.fabric8.io/expose` to `false` in `charts/go-demo-6/values.yaml`?

Mongodb will not work by default with Istio because it runs under a non root `securityContext`, you would get this error in the `istio-init` init container.

```
iptables v1.6.0: can't initialize iptables table `nat': Permission denied (you must be root)
```

In order to simplify things we will just enable Istio for the main web service, disabling automatic Istio sidecar injection for our mongodb deployment by setting the `sidecar.istio.io/inject: "false"` annotation.

Under `go-demo-6` entry, add the `podAnnotations` section with `sidecar.istio.io/inject` set to `"false"`.

```bash
cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@go-demo-6-db:@go-demo-6-db:\
  podAnnotations:\
    sidecar.istio.io/inject: "false"@g' \
    | tee charts/go-demo-6/values.yaml
```

```yaml
# Default values for Go projects.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
replicaCount: 3
image:
  repository: draft
  tag: dev
  pullPolicy: IfNotPresent
service:
  name: go-demo-6
  type: ClusterIP
  externalPort: 80
  internalPort: 8080
  annotations:
    fabric8.io/expose: "true"
    fabric8.io/ingress.annotations: "kubernetes.io/ingress.class: nginx"
resources:
  limits:
    cpu: 100m
    memory: 256Mi
  requests:
    cpu: 80m
    memory: 128Mi
probePath: /demo/hello?health=true
livenessProbe:
  initialDelaySeconds: 60
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
readinessProbe:
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
terminationGracePeriodSeconds: 10
go-demo-6-db:
  podAnnotations:
    sidecar.istio.io/inject: "false"
  replicaSet:
    enabled: true


  usePassword: false
knativeDeploy: false




canary:
  enable: false
  provider: istio
  service:
    hosts:
    - go-demo-6.34.73.8.113.nip.io
    gateways:
    - jx-gateway.istio-system.svc.cluster.local
  canaryAnalysis:
    interval: 30s
    threshold: 5
    maxWeight: 70
    stepWeight: 20
    metrics:
    - name: request-success-rate
      threshold: 99
      interval: 120s
    - name: request-duration
      threshold: 500
      interval: 120s
```

```bash
cd ..

# If serverless
ENVIRONMENT=tekton

# If static
ENVIRONMENT=jx-rocks

rm -rf environment-$ENVIRONMENT-staging

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-$ENVIRONMENT-staging.git

cd environment-$ENVIRONMENT-staging

STAGING_ADDR=staging.go-demo-6.$ISTIO_IP.nip.io

echo "go-demo-6:
  canary:
    enable: true
    service:
      hosts:
      - $STAGING_ADDR" \
    | tee -a env/values.yaml
```

```yaml
go-demo-6:
  canary:
    enable: true
    service:
      hosts:
      - staging.go-demo-6.34.73.8.113.nip.io
```

```bash
git add .

git commit \
    -m "Added progressive deployment"

git push

cd ../go-demo-6

git add .

git commit \
    -m "Added progressive deployment"

git push

jx get activities \
    --filter go-demo-6/master \
    --watch

# Press *ctrl+c* when the activity is finished

# If serverless
jx get activities \
    --filter environment-tekton-staging/master \
    --watch

# Press *ctrl+c* when the activity is finished
```

## Canary Deployments

```bash
curl $STAGING_ADDR/demo/hello
```

```
hello, rolling update!
```

```bash
# Repeat if `no healthy upstream` (DB is not yet up and running)

kubectl \
    --namespace $NAMESPACE-staging \
    get all
```

```
NAME                                        READY   STATUS    RESTARTS   AGE
pod/jx-go-demo-6-db-arbiter-0               1/1     Running   0          69s
pod/jx-go-demo-6-db-primary-0               1/1     Running   0          65s
pod/jx-go-demo-6-db-secondary-0             1/1     Running   0          65s
pod/jx-go-demo-6-primary-7d5755576c-6kjjv   2/2     Running   0          65s
pod/jx-go-demo-6-primary-7d5755576c-9wsqw   2/2     Running   1          65s
pod/jx-go-demo-6-primary-7d5755576c-c7xv6   2/2     Running   1          65s
NAME                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
service/go-demo-6                  ClusterIP   10.31.250.55    <none>        80/TCP      97m
service/jx-go-demo-6               ClusterIP   10.31.253.52    <none>        8080/TCP    67s
service/jx-go-demo-6-canary        ClusterIP   10.31.243.175   <none>        8080/TCP    67s
service/jx-go-demo-6-db            ClusterIP   10.31.244.152   <none>        27017/TCP   117m
service/jx-go-demo-6-db-headless   ClusterIP   None            <none>        27017/TCP   117m
service/jx-go-demo-6-primary       ClusterIP   10.31.250.21    <none>        8080/TCP    67s
NAME                                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jx-go-demo-6           0         0         0            0           102m
deployment.apps/jx-go-demo-6-primary   3         3         3            3           68s
NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/jx-go-demo-6-55f699d857           0         0         0       75s
replicaset.apps/jx-go-demo-6-658f88478b           0         0         0       88m
replicaset.apps/jx-go-demo-6-77b6455c87           0         0         0       93m
replicaset.apps/jx-go-demo-6-8b5698864            0         0         0       97m
replicaset.apps/jx-go-demo-6-94b4bb9b6            0         0         0       102m
replicaset.apps/jx-go-demo-6-primary-7d5755576c   3         3         3       68s
NAME                                         DESIRED   CURRENT   AGE
statefulset.apps/jx-go-demo-6-db-arbiter     1         1         117m
statefulset.apps/jx-go-demo-6-db-primary     1         1         117m
statefulset.apps/jx-go-demo-6-db-secondary   1         1         117m
NAME                                  NAME        VERSION   GIT URL
release.jenkins.io/go-demo-6-9.0.33   go-demo-6   v9.0.33   https://github.com/vfarcic/go-demo-6
NAME                              STATUS        WEIGHT   LASTTRANSITIONTIME
canary.flagger.app/jx-go-demo-6   Initialized   0        2019-08-16T23:17:03Z
```

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get virtualservice.networking.istio.io
```

```
NAME           GATEWAYS                                      HOSTS                                                 AGE
jx-go-demo-6   [jx-gateway.istio-system.svc.cluster.local]   [staging.go-demo-6.34.73.8.113.nip.io jx-go-demo-6]   1m
```

After detecting a new `Canary` object Flagger will automatically create some other objects to manage the canary deployment:

* deployment.apps/jx-go-demo-6-primary
* service/jx-go-demo-6
* service/jx-go-demo-6-canary
* service/jx-go-demo-6-primary
* virtualservice.networking.istio.io/jx-go-demo-6

The primary and canary deployments manage the incumbent and new version of the deploy respectively. Flagger will have both running during the canary process and create the Istio `VirtualService` that sends traffic to one or another. Initially all traffic is sent to the primary deployment. Lets make a new deployment and see how it is being canaried.

We are going to create a trivial change in the demo application, replacing `hello, PR!` in `main.go` to `hello, progressive!`. Then we will commit and merge it to master to get a new version in the staging environment. 

Let's tail Flagger logs so we can get insights in the deployment process.

```bash
kubectl \
    --namespace istio-system logs \
    --selector app.kubernetes.io/name=flagger \
    --follow
```

```
{"level":"info","ts":"2019-08-16T23:16:33.564Z","caller":"canary/deployer.go:48","msg":"Scaling down jx-go-demo-6.cd-staging","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:33.829Z","caller":"router/kubernetes.go:122","msg":"Service jx-go-demo-6.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:33.913Z","caller":"router/kubernetes.go:122","msg":"Service jx-go-demo-6-canary.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:33.990Z","caller":"router/kubernetes.go:122","msg":"Service jx-go-demo-6-primary.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:34.052Z","caller":"router/istio.go:77","msg":"DestinationRule jx-go-demo-6-canary.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:34.170Z","caller":"router/istio.go:77","msg":"DestinationRule jx-go-demo-6-primary.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:34.295Z","caller":"router/istio.go:205","msg":"VirtualService jx-go-demo-6.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:34.302Z","caller":"controller/controller.go:271","msg":"Halt advancement jx-go-demo-6-primary.cd-staging waiting for rollout to finish: 0 of 3 updated replicas are available","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:17:03.415Z","caller":"canary/deployer.go:48","msg":"Scaling down jx-go-demo-6.cd-staging","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:17:03.524Z","caller":"controller/controller.go:261","msg":"Initialization done! jx-go-demo-6.cd-staging","canary":"jx-go-demo-6.cd-staging"}
```

NOTE: Stop with *ctrl+c*

And once the new version is built we can promote it to production.

```bash
cat main.go | sed -e \
    "s@hello, rolling update@hello, progressive@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@hello, rolling update@hello, progressive@g" \
    | tee main_test.go

git add .

git commit \
    -m "Added progressive deployment"

git push

echo $STAGING_ADDR

# Copy the output

# Go to the second terminal

STAGING_ADDR=[...]

while true
do
    curl "$STAGING_ADDR/demo/hello"
    sleep 0.2
done
```

```
...
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, progressive!
hello, rolling update
...
hello, rolling update!
hello, progressive!
hello, progressive!
hello, progressive!
hello, rolling update!
hello, progressive!
hello, rolling update!
hello, rolling update!
...
```

```bash
# Go back to the first terminal when approx 50% of requests are from the new release

kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

```
NAME                                    READY   STATUS    RESTARTS   AGE
jx-go-demo-6-68f6ff77cb-rqkk8           2/2     Running   0          116s
jx-go-demo-6-db-arbiter-0               1/1     Running   0          6m58s
jx-go-demo-6-db-primary-0               1/1     Running   0          6m54s
jx-go-demo-6-db-secondary-0             1/1     Running   0          6m54s
jx-go-demo-6-primary-7d5755576c-6kjjv   2/2     Running   0          6m54s
jx-go-demo-6-primary-7d5755576c-9wsqw   2/2     Running   1          6m54s
jx-go-demo-6-primary-7d5755576c-c7xv6   2/2     Running   1          6m54s
```

Now Jenkins X will update the GitOps production environment repository to the new version by creating a pull request to change the version. After a little bit it will deploy the new version Helm chart that will update the `deployment.apps/jx-go-demo-6` object in the `jx-production` environment.

Flagger will detect this deployment change update the Istio `VirtualService` to send 10% of the traffic to the new version service `service/jx-go-demo-6` while 90% is sent to the previous version `service/jx-go-demo-6-primary`. We can see this Istio configuration with `kubectl -n jx-production get virtualservice/jx-go-demo-6 -o yaml` under the http route weight parameter.

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get virtualservice.networking.istio.io \
    jx-go-demo-6 \
    --output yaml
```

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  creationTimestamp: "2019-08-16T23:16:34Z"
  generation: 1
  name: jx-go-demo-6
  namespace: cd-staging
  ownerReferences:
  - apiVersion: flagger.app/v1alpha3
    blockOwnerDeletion: true
    controller: true
    kind: Canary
    name: jx-go-demo-6
    uid: dee033ef-c07b-11e9-9aa4-42010a8e00b0
  resourceVersion: "39679"
  selfLink: /apis/networking.istio.io/v1alpha3/namespaces/cd-staging/virtualservices/jx-go-demo-6
  uid: e38d47b2-c07b-11e9-9aa4-42010a8e00b0
spec:
  gateways:
  - jx-gateway.istio-system.svc.cluster.local
  hosts:
  - staging.go-demo-6.34.73.8.113.nip.io
  - jx-go-demo-6
  http:
  - route:
    - destination:
        host: jx-go-demo-6-primary
      weight: 40
    - destination:
        host: jx-go-demo-6-canary
      weight: 60
```

We can test this by accessing our application using the dns we previously created for the Istio gateway. For instance running `curl "http://go-demo-6.${ISTIO_IP}.nip.io/demo/hello"` will give us the response from the previous version around 90% of the times, and the current version the other 10%.

Describing the canary object will also give us information about the deployment progress.

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get ing
```

```
NAME        HOSTS                                        ADDRESS          PORTS   AGE
go-demo-6   go-demo-6.cd-staging.35.237.194.237.nip.io   35.237.194.237   80      103m
```

```bash
# TODO: We should probably remove the Ingress. Is there a reason for its existence?

kubectl -n $NAMESPACE-staging \
    get canary
```

```
NAME           STATUS       WEIGHT   LASTTRANSITIONTIME
jx-go-demo-6   Progressing  60       2019-08-16T23:24:03Z
```

```bash
# The status will be `Succeeded` when finished

kubectl \
    --namespace $NAMESPACE-staging \
    describe canary jx-go-demo-6
```

```yaml
Name:         jx-go-demo-6
Namespace:    cd-staging
Labels:       jenkins.io/chart-release=jx
              jenkins.io/namespace=cd-staging
              jenkins.io/version=8
Annotations:  jenkins.io/chart: env
              kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"flagger.app/v1alpha2","kind":"Canary","metadata":{"annotations":{"jenkins.io/chart":"env"},"labels":{"jenkins.io/chart-rele...
API Version:  flagger.app/v1alpha3
Kind:         Canary
Metadata:
  Creation Timestamp:  2019-08-16T23:16:26Z
  Generation:          1
  Resource Version:    40026
  Self Link:           /apis/flagger.app/v1alpha3/namespaces/cd-staging/canaries/jx-go-demo-6
  UID:                 dee033ef-c07b-11e9-9aa4-42010a8e00b0
Spec:
  Canary Analysis:
    Interval:    30s
    Max Weight:  70
    Metrics:
      Interval:               120s
      Name:                   request-success-rate
      Threshold:              99
      Interval:               120s
      Name:                   request-duration
      Threshold:              500
    Step Weight:              20
    Threshold:                5
  Progress Deadline Seconds:  60
  Provider:                   istio
  Service:
    Gateways:
      jx-gateway.istio-system.svc.cluster.local
    Hosts:
      staging.go-demo-6.34.73.8.113.nip.io
    Port:  8080
  Target Ref:
    API Version:  apps/v1
    Kind:         Deployment
    Name:         jx-go-demo-6
Status:
  Canary Weight:  0
  Conditions:
    Last Transition Time:  2019-08-16T23:24:33Z
    Last Update Time:      2019-08-16T23:24:33Z
    Message:               Canary analysis completed successfully, promotion finished.
    Reason:                Succeeded
    Status:                True
    Type:                  Promoted
  Failed Checks:           0
  Iterations:              0
  Last Applied Spec:       1289860333710986770
  Last Promoted Spec:      1289860333710986770
  Last Transition Time:    2019-08-16T23:24:33Z
  Phase:                   Succeeded
  Tracked Configs:
Events:
  Type     Reason  Age    From     Message
  ----     ------  ----   ----     -------
  Warning  Synced  8m31s  flagger  Halt advancement jx-go-demo-6-primary.cd-staging waiting for rollout to finish: 0 of 3 updated replicas are available
  Normal   Synced  8m2s   flagger  Initialization done! jx-go-demo-6.cd-staging
  Normal   Synced  3m32s  flagger  New revision detected! Scaling up jx-go-demo-6.cd-staging
  Normal   Synced  3m2s   flagger  Starting canary analysis for jx-go-demo-6.cd-staging
  Normal   Synced  3m2s   flagger  Advance jx-go-demo-6.cd-staging canary weight 20
  Normal   Synced  2m32s  flagger  Advance jx-go-demo-6.cd-staging canary weight 40
  Normal   Synced  2m2s   flagger  Advance jx-go-demo-6.cd-staging canary weight 60
  Normal   Synced  92s    flagger  Advance jx-go-demo-6.cd-staging canary weight 80
  Normal   Synced  92s    flagger  Copying jx-go-demo-6.cd-staging template spec to jx-go-demo-6-primary.cd-staging
  Normal   Synced  62s    flagger  Routing all traffic to primary
  Normal   Synced  32s    flagger  (combined from similar events): Promotion completed! Scaling down jx-go-demo-6.cd-staging
```

Every 10 seconds 10% more traffic will be directed to our new version if the metrics are successful. Note that we had to generate some traffic (with the curl loop above) otherwise Flagger will assume something is wrong with our deployment that is preventing traffic and will automatically roll back.

```bash
# Wait until the event `Promotion completed! Scaling down jx-go-demo-6.cd-staging` appears

# Go back to the second terminal

# Stop with *ctrl+c*

# Go back to the first terminal
```

## Automated Rollbacks

Flagger will automatically rollback if any of the metrics we set fail the number of times set on the threshold configuration option, or if there are no metrics, as Flagger assumes something is very wrong with our application.

Let's show what would happen if we promote to production the previous version with no traffic.

```bash
# # NOTE: Make sure that some time passed (e.g., 15 min), otherwise it will get the old metrics and think that the requests are coming in

# cat main.go | sed -e \
#     "s@hello, progressive@hello, no one@g" \
#     | tee main.go

# cat main_test.go | sed -e \
#     "s@hello, progressive@hello, no one@g" \
#     | tee main_test.go

# git add .

# git commit \
#     -m "Added progressive deployment"

# git push

# jx get activities \
#     --filter go-demo-6 \
#     --watch

# # Press *ctrl+c* when the activity is finished

# jx get activities \
#     --filter environment-tekton-staging/master \
#     --watch

# # Press *ctrl+c* when the activity is finished

# # Not sending any requests

# # After a few minutes

# kubectl -n $NAMESPACE-staging \
#     get canary
```

Now let's try again and show what happens when the application returns http errors.

NOTE: as the time of writing `jx get applications` will show versions that are out of sync from the ones actually deployed after a promotion failure. You can see the versions actually deployed with `kubectl -n jx-production get deploy -o wide`. For that same reason you can't try to immediately promote again a version that was rolled back by Flagger, as that version is already the one in the GitOps environment repo and will not trigger any deployment because there are no changes to the git files.


```bash
# kubectl \
#     --namespace $NAMESPACE-staging \
#     get pods

# curl "$STAGING_ADDR/demo/hello"

# # Wait until it rolls back

# curl "$STAGING_ADDR/demo/hello"

cat main.go | sed -e \
    "s@Everything is still OK@Everything is still OK with progressive delivery@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@Everything is still OK@Everything is still OK with progressive delivery@g" \
    | tee main_test.go

git add .

git commit \
    -m "Added progressive deployment"

git push

# jx get activities \
#     --filter go-demo-6 \
#     --watch

# jx get activities \
#     --filter environment-tekton-staging/master \
#     --watch

# NOTE: Go to the second terminal

while true
do
    curl "$STAGING_ADDR/demo/random-error"
    sleep 0.2
done
```

```
...
ERROR: Something, somewhere, went wrong!
Everything is still OK with progressive delivery
Everything is still OK
Everything is still OK
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK
ERROR: Something, somewhere, went wrong!
Everything is still OK
Everything is still OK
Everything is still OK
Everything is still OK
Everything is still OK
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK
...
```

```bash
# NOTE: Go to the first terminal while in progress

kubectl \
    --namespace $NAMESPACE-staging \
    get virtualservice.networking.istio.io \
    jx-go-demo-6 \
    --output yaml
```

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  creationTimestamp: "2019-08-16T23:16:34Z"
  generation: 1
  name: jx-go-demo-6
  namespace: cd-staging
  ownerReferences:
  - apiVersion: flagger.app/v1alpha3
    blockOwnerDeletion: true
    controller: true
    kind: Canary
    name: jx-go-demo-6
    uid: dee033ef-c07b-11e9-9aa4-42010a8e00b0
  resourceVersion: "56484"
  selfLink: /apis/networking.istio.io/v1alpha3/namespaces/cd-staging/virtualservices/jx-go-demo-6
  uid: e38d47b2-c07b-11e9-9aa4-42010a8e00b0
spec:
  gateways:
  - jx-gateway.istio-system.svc.cluster.local
  hosts:
  - staging.go-demo-6.34.73.8.113.nip.io
  - jx-go-demo-6
  http:
  - route:
    - destination:
        host: jx-go-demo-6-primary
      weight: 40
    - destination:
        host: jx-go-demo-6-canary
      weight: 60
```

```bash
kubectl -n $NAMESPACE-staging \
    get canary
```

```
NAME           STATUS        WEIGHT   LASTTRANSITIONTIME
jx-go-demo-6   Progressing   60       2019-08-17T00:21:33Z
```

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    describe canary jx-go-demo-6
```

```
...
  Warning  Synced  3m17s  flagger  Halt jx-go-demo-6.jx-staging advancement success rate 90.09% < 99%
  Warning  Synced  2m47s  flagger  Halt jx-go-demo-6.jx-staging advancement success rate 88.57% < 99%
  Warning  Synced  2m17s  flagger  Halt jx-go-demo-6.jx-staging advancement success rate 91.49% < 99%
  Warning  Synced  107s   flagger  Halt jx-go-demo-6.jx-staging advancement success rate 96.00% < 99%
  Warning  Synced  77s    flagger  Halt jx-go-demo-6.jx-staging advancement success rate 87.72% < 99%
  Warning  Synced  47s    flagger  Canary failed! Scaling down jx-go-demo-6.jx-staging
  Warning  Synced  47s    flagger  Rolling back jx-go-demo-6.jx-staging failed checks threshold reached 5
```

```bash
# NOTE: Go to the second terminal
```

```
...
Everything is still OK
Everything is still OK
Everything is still OK
Everything is still OK
ERROR: Something, somewhere, went wrong!
Everything is still OK
ERROR: Something, somewhere, went wrong!
...
```

```bash
# Stop with *ctrl+c*

# Go back to the first terminal
```

## Visualizing the Rollout

Flagger includes a Grafana dashboard where we can visually see metrics in our canary rollout process. By default is not accessible, so we need to create an ingress object pointing to the Grafana service running in the cluster.

```bash
# If not EKS
LB_IP=$(kubectl \
    --namespace kube-system \
    get svc jxing-nginx-ingress-controller \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

# If EKS
LB_HOST=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# If EKS
export LB_IP="$(dig +short $LB_HOST \
    | tail -n 1)"

echo $LB_IP
```

```
35.237.194.237
```

```bash
echo "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: flagger-grafana
  namespace: istio-system
spec:
  rules:
  - host: flagger-grafana.$LB_IP.nip.io
    http:
      paths:
      - backend:
          serviceName: flagger-grafana
          servicePort: 80
" | kubectl create -f -
```

```
ingress.extensions/flagger-grafana created
```

```bash
open "http://flagger-grafana.$LB_IP.nip.io"
```

Then we can access Grafana at `http://flagger-grafana.jx.$PROD_IP.nip.io/d/flagger-istio/istio-canary?refresh=5s&orgId=1&var-namespace=jx-production&var-primary=jx-go-demo-6-primary&var-canary=jx-go-demo-6` using `admin/admin` credentials.
If not displayed directly, we should go to the `Istio Canary` dashboard and select

* namespace: `jx-staging`
* primary: `jx-go-demo-6-primary`
* canary: `jx-go-demo-6`

to see metrics side by side of the previous version and the new version, such as request volume, request success rate, request duration, CPU and memory usage,...

NOTE: We should change the production environment as well

## What Now?

TODO: Viktor: Rewrite

Now is a good time for you to take a break.

If you created a cluster only for the purpose of the exercises we executed, please destroy it. We'll start the next, and each other chapter from scratch as a way to save you from running your cluster longer than necessary and pay more than needed to your hosting vendor. If you created the cluster or installed Jenkins X using one of the Gists from the beginning of this chapter, you'll find the instructions on how to destroy the cluster or uninstall everything at the bottom.

If you did choose to destroy the cluster or to uninstall Jenkins X, please remove the repositories we created as well as the local files. You can use the commands that follow for that. Just remember to replace `[...]` with your GitHub user.

```bash
cd ..

GH_USER=[...]

# If serverless
ENVIRONMENT=tekton

# If static
ENVIRONMENT=jx-rocks

hub delete -y \
    $GH_USER/environment-$ENVIRONMENT-staging

hub delete -y \
    $GH_USER/environment-$ENVIRONMENT-production

rm -rf ~/.jx/environments/$GH_USER/environment-$ENVIRONMENT-*

rm -rf environment-$ENVIRONMENT-staging
```

Finally, you might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just keep reading.
