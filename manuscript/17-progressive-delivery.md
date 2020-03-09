# Choosing The Right Deployment Strategy

> **Carlos Sanchez** co-authored this chapter.

So far, we performed many deployments of our releases. All those created from master branches were deployed to the staging environment, and a few reached production through manual promotions. On top of those, we deployed quite a few releases to preview environments. Nevertheless, except for serverless deployments with Knative, we did not have a say in how an application is deployed. We just assumed that the default method employed by Jenkins X is the correct one. As it happens, the default deployment process used by Jenkins X happens to be the default or, to be more precise, the most commonly used deployment process in Kubernetes. However, that does not necessarily mean that the default strategy is the right one for all our applications.

For many people, deploying applications is transparent or even irrelevant. If you are a developer, you might be focused on writing code and allowing magic to happen. By magic, I mean letting other people and departments figure out how to deploy your code. Similarly, you might be oblivious to deployments. You might be a tester, or you might have some other role not directly related to system administration, operations, or infrastructure. Now, I doubt that you are one of the oblivious. The chances are that you would not be even reading this if that's the case. If, against all bets, you do belong to the deployment-is-not-my-thing group, the only thing I can say is that you are wrong.

Generally speaking, there are two types of teams. The vast majority of us is still working in groups based on types of tasks and parts of application lifecycles. If you're wondering whether that's the type of the team you work in, ask yourself whether you are in development, testing, operations, or some other department? Is your team focused on a fraction of a lifecycle of an application? Are you handing your work to someone else? When you finish writing code, do you give it to the testing department to validate it? When you need to test a live application, are you giving it to operations to deploy it to an environment? Or, to formulate the question on a higher level, are you (your team) in charge only of a part of the lifecycle of your application? If the answer to any of those question is "yes", you are NOT working in a self-sufficient team. Now, I'm not going to tell you why that is wrong, nor I'm here to judge you. Instead, I'm only going to state that there is a high probability that you do not know in detail how your application is deployed. As a result, you don't know how to architecture it properly, you don't know how to test it well, and so on. That, of course, is not true if you are dedicated only to operations. But, in that case, you might not be aware of the architecture of the application. You might know how the application is deployed, but you might not know whether that is the optimum way to go.

On the other hand, you might be indeed working in a self-sufficient team. Your team might be fully responsible for each aspect of the application lifecycle, from requirements until it is running in production. If that's the case, your definition of done is likely defined as "it's running in production and nothing exploded." Being in a self-sufficient team has a distinct advantage of everyone being aware of every aspect of the application lifecycle. You know the architecture, you can read the code, you understand the tests, and you are aware of how it is deployed. That is not to say that you are an expert in all those and other areas. No one can know everything in depth, but everyone can have enough high-level knowledge of everything while being specialized in something.

Why am I rumbling about team organizations? The answer is simple. Deployment strategies affect everyone, no matter whether we are focused only on a single aspect of the application lifecycle or we are in full control. The way we deploy affects the architecture, testing, monitoring, and many other aspects. And not only that, but we can say that architecture, testing, and monitoring affect the way we deploy. All those things are closely related and affect each other in ways that might not be obvious on the first look.

We already learned many of the things Jenkins X does out-of-the-box and quite a few others that could be useful to customize it to behave as we want. But, so far, we mostly ignored deployment strategies. Excluding our brief exploration of serverless deployments with Knative, we always assumed that the application should be deployed using whichever strategy was defined in a build pack. Not only that, but we did not even question whether the types of resources defined in our Helm charts are the right ones. We'll fill at least one of those holes next.

The time has come to discuss different deployment strategies and answer a couple of questions. Is your application stateful or stateless? Does its architecture permit scaling? How do you roll back? How do you scale up and down? Do you need your application to run always? Should you use Kubernetes Deployments instead of, let's say, StatefulSets? Those are only a few of the questions you need to answer to choose the right deployment mechanism. But, answers to those questions will not serve much unless we are familiar with some of the most commonly used deployment strategies. Not only that knowledge will help us choose which one to pick, but they might even influence the architecture of our applications.

## What Do We Expect From Deployments?

Before we dive into some of the deployment strategies, we might want to set some expectations that will guide us through our choices. But, before we do that, let's try to define what a deployment is.

Traditionally, a deployment is a process through which we would install new applications into our servers or update those that are already running with new releases. That was, more or less, what we were doing from the beginning of the history of our industry, and that is in its essence what we're doing today. But, as we evolved, our requirements were changing as well. Today, say that all we expect is for our releases to run is an understatement. Today we want so much more, and we have technology that can help us fulfill those desires. So, what does "much more" mean today?

Depending on who you speak with, you will get a different list of "desires". So, mine might not be all-encompassing and include every single thing than anyone might need. What follows is what I believe is essential, and what I observed that the companies I worked typically put emphasis. Without further ado, the requirements, excluding the obvious that applications should be running inside the cluster, are as follows.

Applications should be **fault-tolerant.** If an instance of the application dies, it should be brought back up. If a node where an application is running dies, the application should be moved to a healthy node. Even if a whole data center goes down, the system should be able to move the applications that were running there into a healthy one. An alternative would be to recreate the failed nodes or even whole data centers with precisely the same apps that were running there before the outage. However, that is too slow and, frankly speaking, we moved away from that concept the moment we adopted schedulers. That does not mean that failed nodes and failed data centers should not recuperate, but rather that we should not wait for infrastructure to get back to normal. Instead, we should run failed applications (no matter the cause) on healthy nodes as long as there is enough available capacity.

Fault tolerance might be the most crucial requirement of all. If our application is not running, our users cannot use it. That results in dissatisfaction, loss of profit, churn, and quite a few other adverse outcomes. Still, we will not use fault tolerance as a criterion because Kubernetes makes (almost) everything fault-tolerant. As long as it has enough available capacity, our applications will run. So, even that is an essential requirement, it is off the table because we are fulfilling it no matter the deployment strategy we choose. That is not to say that there is no chance for an application not to recuperate from a failure but instead that Kubernetes provides a reasonable guarantee of fault tolerance. If things do go terribly wrong, we are likely going to have to do some manual actions no matter which deployment strategy we choose.

Long story short, fault-tolerance is a given with Kubernetes, and there's no need to think about it in terms of deployment strategies.

The next in line is **high availability**, and that a trickier one.

Being fault-tolerant means that the system will recuperate from failure, not that there will be no downtime. If our application goes down, a few moments later, it will be up-and-running again. Still, those few moments can result in downtime. Depending on many factors, "few moments" can be translated to milliseconds, seconds, minutes, hours, or even days. It is certainly not the same whether our application is unavailable during milliseconds as opposed to hours. Still, for the sake of brevity, we'll assume that any downtime is bad and look at things as black and white. Either there is, or there isn't downtime. Or, to be more precise, either there is a considerable downtime, or there isn't. What changed over time is what "considerable" means. In the past, having 99% availability was a worthy goal for many. Today, that figure is unacceptable. Today we are talking about how many nines there are after the decimal. For some, 99.99% uptime is acceptable. For others, that could be 99.99999%.

Now, you might say: "my business is important; therefore, I want 100% uptime." If anyone says that to you, feel free to respond with: "you have no idea what you're talking about." Hundred percent uptime is impossible, assuming that by that we mean "real" uptime, and not "my application runs all the time."

Making sure that our application is always running is not that hard. Making sure that not a single request is ever lost or, in other words, that our users perceive our application as being always available, is impossible. By the nature of HTTP, some requests will fail. Even if that never happens (as it will), network might go down, storage might fail, or some other thing might happen. Any of those is bound to produce at least one request without a response or with a 4xx or 5xx message.

All in all, high-availability means that our applications are responding to our users most of the time. By "most", we mean at least 99.99%. Even that is a very pessimistic number that would result in one failure for each ten thousand requests.

What are the common causes of unavailability? We already discussed those that tend to be the first associations (hardware and software failures). However, those are often not the primary causes of unavailability. You might have missed something in your tests, and that might cause a malfunction. More often than not, those are not failures caused by "obvious" bugs but rather by those that manifest themselves a while after a new release is deployed. I will not tell you that you should make sure that there are no bugs because that is impossible). Instead, I'll tell you that you should focus on detecting those that sneak into production. It's as important to try to avoid bugs as to minimize their effect to as few users as possible. So, our next requirement will be that our deployments should reduce the number of users affected by bugs. We'll call it **progressive rollout**. Don't worry if you never heard that term. We'll explain it in more depth later.

Progressive rollout, as you'll see later, does allow us to abort upgrades or, to be more precise, not to proceed with them, if something goes wrong. But that might not be enough. We might need not only to abort deployment of a new release but also to roll back what the one we had before. So, we'll add **rollback** as yet another requirement.

We'll probably find more requirements directly or indirectly related to high-availability or, to inverse it, to unavailability. For now, we'll leave those aside, and move to yet another vital aspect. We should strive to make our applications **responsive**, and there are many ways to accomplish that. We can design our apps in a certain way, we can avoid congestions and memory leaks, and we can do many other things. However, right now, that's not the focus. We're interested in things that are directly or indirectly related to deployments. With such a limited scope, scalability is the key to responsiveness. If we need more replicas of our application, it should scale up. Similarly, if we do not need as many, it should scale down and free the resources for some other processes if cost savings are not a good enough reason.

Finally, we'll add one more requirement. It would be nice if our applications do not use more resources than it is necessary. We can say that scalability provides that (it can scale up and down) but we might want to take it a step further and say that our applications should not use (almost) any resources when they are not in use. We can call that "nothing when idle" or, use a more commonly used term, serverless. 

I'll use this as yet another opportunity to express my disgust with that term given that it implies that there are no servers involved. But, since it is a commonly used one, we'll stick with it. After all, it's still better than calling it function-as-a-service since that is just as misleading as serverless, and it occupies more characters (it is a longer word). However, serverless is not the real goal. What matters is that our solution is **cost-effective**, so that will be our last requirement.

Are those all the requirements we care for. They certainly aren't. But, this text cannot contain an infinite number of words, and we need to focus on something. Those, in my experience, are the most important ones, so we'll stick with them, at least for now.

Another thing we might need to note is that those requirements or, to be more precise, that those features are all interconnected. More often than not, one cannot be accomplished without the other or, in some other cases, one facilitates the other and makes it easier to accomplish.

Another thing worth noting is that we'll focus only on automation. For example, I know perfectly well that anything can be rolled back through human intervention. I know that we can extend our pipelines with post-deployment tests followed with a rollback step in case they fail. As a matter of fact, anything can be done with enough time and manpower. But that's not what matters in this discussion. We'll ignore humans and focus only on the things that can be automated and be an integral part of deployment processes. I don't want you to scale your applications. I want the system to do it for you. I don't want you to roll back in case of a failure. I want the system to do that for you. I don't want you to waste your brain capacity on such trivial tasks. I wish you to spend your time on things that matter and leave the rest to machines.

After all that, we can summarize our requirements or features by saying that we'd like deployments to result in applications that are running and are:

* fault-tolerant
* highly available
* responsive
* rolling out progressively
* rolling back in case of a failure
* cost-effective

We'll remove *fault tolerance* from the future discussions since Kubernetes provides that out-of-the-box. As for the rest, we are yet to see whether we can accomplish them all and, if we can, whether a single deployment strategy will give us all those benefits.

There is a strong chance that there is no solution that will provide all those features. Even if we do find such a solution, the chances are that it might not be appropriate for your applications and their architecture. We'll worry about that later. For now, we'll explore some of the commonly used deployment strategies and see which of those requirements they fulfill.

Just as in any other chapter, we'll explore the subject in more depth through practical examples. For that, we need a working Jenkins X cluster as well as an application that we'll use it as a guinea pig on which we'll experiment with different deployment strategies.

## Creating A Kubernetes Cluster With Jenkins X And Creating A Sample Application

If you kept the cluster from the previous chapter, you can skip this section only if you were doubting my choice of VM sizes and make the nodes bigger than what I suggested. Otherwise, we'll need to create a new Jenkins X cluster.

We've been using the same cluster specifications for a while now. No matter the hosting vendor you chose in the past, if you created the cluster using my instructions, it is based on nodes with only 2 available CPUs or even less. We'll need more. Even if your cluster is set to autoscale, increasing the number of nodes will not help since one of the Istio components we'll use requires at least 2 CPUs available. Remember, even if you do have nodes with 2 CPUs, some computing power is reserved for system-level processes or Kubernetes daemons, so a 2 CPUs node does not result in 2 CPUs available.

We'll need to create a cluster with bigger nodes. The gists listed below will do just that. Those related to AKS, EKS, and GKE are now having nodes with 4 CPUs. If you are using your own cluster hosted somewhere else, the Gists are the same, and I will assume that the nodes have more than 2 available CPUs.

On top of all that, if you are using GKE, the gist now contains the command that installs **Gloo** which we explored in the previous chapter, and it sets the team deployment type to `knative`.

I> All the commands from this chapter are available in the [17-progressive-delivery.sh](https://gist.github.com/7af19b92299278f9b0f20beba9eba022) Gist.

The new Gists are as follows.

* Create a new serverless **GKE** cluster with Gloo: [gke-jx-serverless-gloo.sh](https://gist.github.com/cf939640f2af583c3a12d04affa67923)
* Create a new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd)
* Create a new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037)

Now that we have a cluster with Jenkins X, we'll create a sample application.

```bash
jx create quickstart \
    --filter golang-http \
    --project-name jx-progressive \
    --batch-mode
```

Now we can start exploring deployment strategies, with serverless being the first in line.

## Using Serverless Strategy With Gloo And Knative (GKE only)

Judging by the name of this section, you might be wondering why do we start with serverless deployments. The honest answer is that I did not try to put the deployment strategies in any order. We're starting with serverless simply because that is the one we used in the previous chapter. So, we'll start with what we have right now, at least for those who are running Jenkins X in GKE.

Another question you might be asking is why do we cover serverless with Knative in here given that we already discussed it in the previous chapter. The answer to that question lies in completeness. Serverless deployments are one of the essential options we have when choosing the strategy, and this chapter could not be complete without it. If you did go through the previous chapter, consider this one a refresher with a potential to find out something new. If nothing else, you'll get a better understanding of the flow of events with Knative as well as to see a few diagrams. In any case, the rest of the strategies will build on top of this one. On the other hand, you might be impatient and bored with repetition. If that's the case, feel free to skip this section altogether.

W> At the time of this writing (September 2019), serverless deployments with Knative work out-of-the-box only in GKE ([issue 4668](https://github.com/jenkins-x/jx/issues/4668)). That does not mean that Knative does not work in other Kubernetes flavors, but rather that Jenkins X installation of Knative works only in GKE. I encourage you to set up Knative yourself and follow along in your Kubernetes flavor. If you cannot run Knative, I still suggest you stick around even if you cannot run the examples. I'll do my best to be brief and to make the examples clear even for those not running them.

Instead of discussing the pros and cons first, we'll start each strategy with an example. We'll observe the results, and, based on that, comment on their advantages and disadvantages as well as the scenarios when they might be a good fit. In that spirit, let's create a serverless deployment first and see what we'll get.

Let's go into the project directory and take a quick look at the definition that makes the application serverless.

```bash
cd jx-progressive

cat charts/jx-progressive/templates/ksvc.yaml
```

We won't go into details of Knative specification. It was briefly explained in the [Using Jenkins X To Define And Run Serverless Deployments](#knative) chapter and details can be found in the [official docs](https://knative.dev). What matters in the context of the current discussion is that the YAML you see in front of you defined a serverless deployment using Knative.

By now, if you created a new cluster, the application we imported should be up-and-running. But, to be on the safe side, we'll confirm that by taking a quick look at the *jx-progressive* activities.

W> There's no need to inspect the activities to confirm whether the build is finished if you are reusing the cluster from the previous chapter. The application we deployed previously should still be running.

```bash
jx get activities \
    --filter jx-progressive \
    --watch
```

Once you confirm that the build is finished press *ctrl+c* to stop watching the activities.

As you probably already know, the activity of an application does not wait until the release is promoted to the staging environment. So, we'll confirm that the build initiated by changes to the *environment-jx-rocks-staging* repository is finished as well.

```bash
jx get activities \
    --filter environment-jx-rocks-staging/master \
    --watch
```

Just as before, feel free to press *ctrl+c* once you confirm that the build was finished.

Finally, the last verification we'll do is to confirm that the Pods are running.

```bash
kubectl --namespace jx-staging \
    get pods
```

The output is as follows.

```
NAME                  READY STATUS  RESTARTS AGE
jx-jx-progressive-... 1/1   Running 0        45s
```

In your case, `jx-progressive` deployment might not be there. If that's the case, it's been a while since you used the application and Knative made the decision to scale it to zero replicas. We'll go through a scaling-to-zero example later. For now, imagine that you do have that Pod running.

On the first look, everything looks "normal". It as if the application was deployed like any other. The only "strange" thing we can observe by looking at the Pods is the name of the one created through the *jx-progressive* Deployment and that it contains two containers instead of one. We'll ignore the "naming strangeness" and focus on the latter observation.

Knative injected a container into our Pod. It contains `queue-proxy` that, as the name suggests, serves as a proxy responsible for request queue parameters. It also reports metrics to the Autoscaler through which it might scale up or down depending on the number of different parameters. Requests are not going directly to our application but through this container.

Now, let's confirm that the application is indeed accessible from outside the cluster.

```bash
STAGING_ADDR=$(kubectl \
    --namespace jx-staging \
    get ksvc jx-progressive \
    --output jsonpath="{.status.url}")

curl "$STAGING_ADDR"
```

We retrieved the address through which we can reach the application running in the staging environment, and we used `curl` to send a request. The output should be `hello, PR!` which is the message we defined in one of the previous chapters. 

So far, the significant difference when compared with "normal" Kubernetes deployments is that the access to the application is not controlled through Ingress any more. Instead, it goes through a new resource type abbreviated as `ksvc` (short for Knative Service). Apart from that, everything else seems to be the same, except if we left the application unused for a while. If that's the case, we still got the same output, but there was a slight delay between sending the request and receiving the response. The reason for such a delay lies in Knative's scaling capabilities. It saw that the application is not used and scaled it to zero replicas. But, the moment we sent a request, it noticed that zero replicas is not the desired state and scaled it back to one replica. All in all, the request entered into a gateway (in our case served by Gloo Envoy) and waited there until a new replica was created and initialized, unless one was already running. After that, it forwarded the request to it, and the rest is the "standard" process of our application responding and that response being forwarded to us (back to `curl`).

![Figure 17-1: The flow of a request with API gateway](images/ch17/knative-request.png)

I cannot be sure whether your serverless deployment indeed scaled to zero or it didn't. So, we'll use a bit of patience to validate that it does indeed scale to nothing after a bit of inactivity. All we have to do is wait for five to ten minutes. Get a coffee or some snack.

```bash
kubectl --namespace jx-staging \
    get pods
```

Assuming that sufficient time passed, the output should be as follows state that `no resources` were `found` in the namespace, unless you have other applications there. The application is now gone. If we ignore other resources and focus only on Pods, it seems like the application is wiped out completely. That is true in terms that nothing application-specific is running. All that's left are a few Knative definitions and the common resources used for all applications (not specific to *jx-progressive*).

I> If you still see the *jx-progressive* Pod, all I can say is that you are impatient and you did not wait long enough. If that's what happened, wait for a while longer and repeat the `get pods` command.

Using telemetry collected from all the Pods deployed as Knative applications, Gloo detected that no requests were sent to *jx-progressive* for a while and decided that the time has come to scale it down. It sent a notification to Knative that executed a series of actions which resulted in our application being scaled to zero replicas.

![Figure 17-2: Knative's ability to scale to zero replicas](images/ch17/knative-scale-to-zero.png)

Bear in mind that the actual process is more complicated than that and that there are quite a few other components involved. Nevertheless, for the sake of brevity, the simplistic view we presented should suffice. I'll leave it up to you to go deeper into Gloo and Knative or accept it as magic. In either case, our application was successfully scaled to zero replicas. We started saving resources that could be better used by other applications and save us some costs in the process.

If you never used serverless deployments and if you never worked with Knative, you might think that your users would not be able to access it anymore since the application is not running. Or you might think that it will be scaled up once requests start coming in, but you might be scared that you'll lose those sent before the new replica starts running. Or you might have read the previous chapter and know that those fears are unfounded. In any case, we'll put that to the test by sending three hundred concurrent requests for twenty seconds.

```bash
kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
    -it --rm \
    -- --concurrent 300 --time 20S \
    "$STAGING_ADDR" \
    && kubectl \
    --namespace jx-staging \
    get pods
```

We won't go into details about Siege. Read the previous chapter if you want to know more. What matters is that we finished sending a lot of requests and that the previous command retrieved the Pods in the staging namespace. That output is as follows.

```
...
NAME                                READY STATUS  RESTARTS AGE
jx-progressive-dzghl-deployment-... 2/2   Running 0        19s
jx-progressive-dzghl-deployment-... 2/2   Running 0        16s
jx-progressive-dzghl-deployment-... 2/2   Running 0        18s
jx-progressive-dzghl-deployment-... 2/2   Running 0        16s
```

Our application is up-and-running again. A few moments ago, the application was not running, and now it is. Not only that, but it was scaled to three replicas to accommodate the high number of concurrent requests.

![Figure 17-3: Knative's ability to scale from zero to multiple replicas](images/ch17/knative-scale-to-three.png)

What did we learn from serverless deployments in the context of our quest to find one that fits our needs the best?

High availability is easy in Kubernetes, as long as our applications are designed with that in mind. What that means is that our apps should be scalable and should not contain state. If they cannot be scaled, they cannot be highly available. When a replica fails (note that I did not say *if* but *when*), no matter how fast Kubernetes will reschedule it somewhere else, there will be downtime, unless other replicas take over its load. If there are no other replicas, we are bound to have downtime both due to failures but also whenever we deploy a new release. So, scalability (running more than one replica) is the prerequisite for high availability. At least, that's what logic might make us think.

In the case of serverless deployments with Knative, not having replicas that can respond to user requests is not an issue, at least not from the high availability point of view. While in a "normal" situation, the requests would fail to receive a response, in our case, they were queued in the gateway and forwarded after the application is up-and-running. So, even if the application is scaled to zero replicas (if nothing is running), we are still highly available. The major downside is in potential delays between receiving the first requests and until the first replica of the application is responsive.

The problem we might have with serverless deployments, at least when used in Kubernetes, is responsiveness. If we keep the default settings, our application will scale to zero if there are no incoming requests. As a result, when someone does send a request to our app, it might take longer than usual until the response is received. That could be a couple of milliseconds, a few seconds, or much longer. It all depends on the size of the container image, whether it is already cached on the node where the Pod is scheduled, the amount of time the application needs to initialize, and quite a few other criteria. If we do things right, that delay can be short. Still, any delay reduces the responsiveness of our application, no matter how short or long it is. What we need to do is compare the pros and cons. The results will differ from one app to another.

Let's take the static Jenkins as an example. In many organizations, it is under heavy usage throughout working hours, and with low or no usage at nights. We can say that half of the day it is not used. What that means is that we are paying double to our hosting vendor. We could have shut it down overnight and potentially remove a node from the cluster due to decreased resource usage. Even if the price is not an issue, surely those resources reserved by inactive Jenkins could be better used by some other processes. Shutting down the application would be an improvement, but it would also produce potentially very adverse effects.

What if someone is working overnight and pushes a change to Git. A webhook would fire trying to notify Jenkins that it should run a build. But, such webhook would fail if there is no Jenkins to handle the request. A build would never be executed. Unless we set up a policy that says "you are never allowed to work after 6 pm, even if the whole system crashed", having a non-responsive system is unacceptable.

Another issue would be to figure out when is our system not in use. If we continue using the "traditional" Jenkins as an example, we could say that it should shut-down at 9 pm. If our official working hours end at 6 pm, that will provide three hours margin for those who do stay in the office longer. But, that would still be a suboptimal solution. During much of those three hours, Jenkins would not be used, and it would continue wasting resources. On the other hand, there is still no guarantee that no one will ever push a change after 9 pm.

Knative solves those and quite a few other problems. Instead of shutting down our applications at predefined hours and hoping that no one is using them while they are unavailable, we can let Knative (together with Gloo or Istio) monitor requests. It would scale down if a certain period of inactivity passed. On the other hand, it would scale back up if a request is sent to it. Such requests would not be lost but queued until the application becomes available again.

All in all, I cannot say that Knative might result in non-responsiveness. What I can say is that it might produce slower responses in some cases (between having none and having some replicas). Such periodical slower responsiveness might produce less negative effect than the good it brings. Is it such a bad thing if static Jenkins takes an additional ten seconds to start building something after a whole night of inactivity? Even a minute or two of delay is not a big deal. On the other hand, in that particular case, the upside outweighs the downsides. Still, there are even better examples of the advantages of serverless deployments than Jenkins.

Preview environments might be the best example of wasted resources. Every time we create a pull request, a release is deployed into a temporary environment. That, by itself, is not a waste. The benefits of being able to test and review an application before merging it to master outweigh the fact that most of the time we are not using those applications. Nevertheless, we can do better. Just as we explained in the previous chapter, we can use Knative to deploy to preview environments, no matter whether we use it for permanent environments like staging and production. After all, preview environments are not meant to provide a place to test something before promoting it to production (staging does that). Instead, they provide us with relative certainty that what we'll merge to the master branch is likely code that works well.

If the response delay caused by scaling up from zero replicas is unacceptable in certain situations, we can still configure Knative to have one or more replicas as a minimum. In such a case, we'd still benefit from Knative capabilities. For example, the metrics it uses to decide when to scale might be easier or better than those provided by HorizontalPodAutoscaler (HPA). Nevertheless, the result of having Knative deployment with a minimum number of replicas above zero is similar to the one we'd have with using HPA. So, we'll ignore such situations since our applications would not be serverless. That is not to say that Knative is not useful if it doesn't scale to zero. What it means is that we'll treat those situations separately and stick to serverless features in this section.

What's next in our list of deployment requirements?

Even though we did not demonstrate it through examples, serverless deployments with Knative do not produce downtime when deploying new releases. During the process, all new requests are handled by the new release. At the same time, the old ones are still available to process all those requests that were initiated before the new deployment started rolling out. Similarly, if we have health checks, it will stop the rollout if they fail. In that aspect, we can say that rollout is progressive.

On the other hand, it is not "true" progressive rollout but similar to those we get with rolling updates. Knative, by itself, cannot choose whether to continue progressing with a deployment based on arbitrary metrics. Similarly, it cannot roll back automatically if predefined criteria are met. Just like rolling updates, it will stop the rollout if health checks fail, and not much more. If those health checks fail with the first replica, even though there is no rollback, all the requests will continue being served with the old release. Still, there are too many ifs in those statements. We can only say that serverless deployments with Knative (without additional tooling) partially fulfills the progressive rollout requirement and that they are incapable of automated rollbacks.

Finally, the last requirement is that our deployment strategy should be cost-effective. Serverless deployments, at least those implemented with Knative, are probably the most cost-effective deployments we can have. Unlike vendor-specific serverless implementations like AWS Lambda, Azure Functions, and Google Cloud's serverless platform, we are in (almost) full control. We can define how many requests are served by a single replica. We control the size of our applications given that anything that can run in a container can be serverless (but is not necessarily a good candidate). We control which metrics are used to make decisions and what are the thresholds. Truth be told, that is likely more complicated than using vendor-specific serverless implementations. It's up to us to decide whether additional complications with Knative outweigh the benefits it brings. I'll leave such a decision in your hands.

So, what did we conclude? Do serverless deployments with Knative fulfill all our requirements? The answer to that question is a resounding "no". No deployment strategy is perfect. Serverless deployments provide **huge benefits** with **high-availability** and **cost-effectiveness**. They are **relatively responsive and offer a certain level of progressive rollouts**. The major drawback is the **lack of automated rollbacks**.

|Requirement        |Fullfilled|
|-------------------|----------|
|High-availability  |Fully     |
|Responsiveness     |Partly    |
|Progressive rollout|Partly    |
|Rollback           |Not       |
|Cost-effectiveness |Fully     |

Please note that we used Gloo in conjunction with Knative to perform serverless deployments. We could have used Istio instead of Gloo. Similarly, we could have used OpenFaaS instead of Knative. Or we could have opted for something completely different. There are many different solutions we could assemble to make our applications serverless. Still, the goal was not to compare them all and choose the best one. Instead, we explored serverless deployments in general as one possible strategy we could employ. I do believe that Knative is the most promising one, but we are still in early stages with serverless in general and especially in Kubernetes. It would be impossible to be sure of what will prevail. Similarly, for many engineers, Istio would be the service mesh of choice due to its high popularity. I chose Gloo mostly because of its simplicity and its small footprint. For those of you who prefer Istio, all I can say is that we will use it for different purposes later on in this chapter.

Finally, I decided to present only one serverless implementation mostly because it would take much more than a single chapter to compare all those that are popular. The same can be said for service mesh (Gloo). Both are fascinating subjects that I might explore in the next book. But, at this moment I cannot make that promise because I do not plan a new book before the one I'm writing (this one) is finished.

What matters is that we're finished with a very high-level exploration of the pros and cons of using serverless deployments and now we can move into the next one. But, before we do that, we'll revert our chart to the good old Kubernetes Deployment.

```bash
jx edit deploy \
    --kind default \
    --batch-mode

cat charts/jx-progressive/values.yaml \
    | grep knative
```

We edited the deployment strategy by setting it to `default` (it was `knative` so far). Also, we output the `knative` variable to confirm that it is now set to `false`.

The last thing we'll do is go out of the local copy of the *jx-progressive* directory. That way we'll be in the same place as those who could not follow the examples because their cluster cannot yet run Knative or those who were too lazy to set it up.

```bash
cd ..
```

## Using Recreate Strategy With Standard Kubernetes Deployments

*A long time ago in a galaxy far, far away,* most of the applications were deployed with what today we call the *recreate* strategy. We'll discuss it shortly. For now, we'll focus on implementing it and observing the outcome.

By default, Kubernetes Deployments use the `RollingUpdate` strategy. If we do not specify any, that's the one that is implied. We'll get to that one later. For now, what we need to do is ad the `strategy` into the `deployment.yaml` file that defines the Deployment.

```bash
cd jx-progressive

cat charts/jx-progressive/values.yaml \
    | sed -e \
    's@replicaCount: 1@replicaCount: 3@g' \
    | tee charts/jx-progressive/values.yaml

cat charts/jx-progressive/templates/deployment.yaml \
    | sed -e \
    's@  replicas:@  strategy:\
    type: Recreate\
  replicas:@g' \
    | tee charts/jx-progressive/templates/deployment.yaml
```

We entered the local copy of the *jx-progressive* repository, and we used a bit of `sed` magic to increase the number of replicas in `values.yaml` and to add the `strategy` entry just above `replicas` in `deployment.yaml`. If you are not a `sed` ninja, that command might have been confusing, so let's output the file and see what we got.

```bash
cat charts/jx-progressive/templates/deployment.yaml
```

The output, limited to the relevant section, is as follows.

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

git push --set-upstream origin master

jx get activities \
    --filter jx-progressive/master \
    --watch
```

We pushed the changes, and we started watching the activities. Please press *ctrl+c* to cancel the watcher once you confirm that the newly launched build is finished.

If you're using serverless Jenkins X, the build of an application does not wait for the activity associated with automatic promotion to finish. So, we'll confirm whether that is done as well.

W> Please execute the command that follows only if you are using **serverless Jenkins X**.

```bash
jx get activities \
    --filter environment-jx-rocks-staging/master \
    --watch
```

You know what needs to be done. Press *ctrl+c* when the build is finished.

Let's take a look at the Pods we got.

```bash
kubectl --namespace jx-staging \
    get pods
```

The output is as follows

```
NAME                  READY STATUS  RESTARTS AGE
jx-jx-progressive-... 1/1   Running 0        2m
jx-jx-progressive-... 1/1   Running 0        2m
jx-jx-progressive-... 1/1   Running 0        2m
```

There's nothing new here. Judging by the look of the Pods, if we did not change the strategy to `Recreate`, you would probably think that it is still the default one. The only difference we can notice is in the description of the Deployment, so let's output it.

```bash
kubectl --namespace jx-staging \
    describe deployment jx-jx-progressive
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
  Normal ScalingReplicaSet 20s  deployment-controller Scaled up replica set jx-progressive-589c47878f to 3
```

Judging by the output, we can confirm that the `StrategyType` is now `Recreate`. That's not a surprise. What is more interesting is the last entry in the `Events` section. It scaled replicas of the new release to three. Why is that a surprise? Isn't that the logical action when deploying the first release with the new strategy? Well... It is indeed logical for the first release so we'll have to create and deploy another to see what's really going on.

If you had Knative deployment running before, there is a small nuisance we need to fix. Ingress is missing, and I can prove that.

```bash
kubectl --namespace jx-staging \
    get ing
```

The output claims that `no resources` were `found`.

W> Non-Knative users will have Ingress running and will not have to execute the workaround we are about to do. Feel free to skip the few commands that follow. Alternatively, you can run them as well. No harm will be done. Just remember that their purpose is to create the missing Ingress that is already running and that there will be no visible effect.

What happened? Why isn't there Ingress when we saw it countless times before in previous exercises?

Jenkins X creates Ingress resources automatically unless we tell it otherwise. You know that already. What you might not know is that there is a bug (undocumented feature) that prevents Ingress from being created the first time we change the deployment type from Knative to plain-old Kubernetes Deployments. That happens only when we switch and not in consecutive deployments of new releases. So, all we have to do is deploy a new release, and Jenkins X will pick it up correctly and create the missing Ingress resource the second time. Without it we won't be able to access the application from outside the cluster. So, all we have to do is make a trivial change and push it to GitHub. That will trigger yet another pipeline activity that will result in creation of a new release and its deployment to the staging environment.

```bash
echo "something" | tee README.md

git add .

git commit -m "Recreate strategy"

git push
```

We made a silly change, we pushed it to GitHub, and that triggered yet another build. All we have to do is wait. Or, even better, we can watch the activities of *jx-progressive* and the staging environment pipelines to confirm that everything was executed correctly. I'll skip showing you the `jx get activities` commands given that I'm sure you already know them by heart.

Assuming that you were patient enough and waited until the new release is deployed, now we can confirm that the Ingress was indeed created.

```bash
kubectl --namespace jx-staging \
    get ing
```

The output is as follows.

```
NAME           HOSTS                                          ADDRESS       PORTS AGE
jx-progressive jx-progressive.jx-staging.35.196.143.33.nip.io 35.196.143.33 80    3m56s
```

That's the same output that those that did not run Knative before saw after the first release. Now we are all on the same page.

All in all, the application is now running in staging, and it was deployed using the `recreate` strategy.

Next, we'll make yet another simple change to the code. This time we'll change the output message of the application. That will allow us to easily see how it behaves before and after the new release is deployed.

```bash
cat main.go | sed -e \
    "s@example@recreate@g" \
    | tee main.go

git add .

git commit -m "Recreate strategy"

git push
```

We changed the message. As a result, our current release is outputting `Hello from: Jenkins X golang http example`, while the new release, once it's deployed, will return `Hello from: Jenkins X golang http recreate`.

Now we need to be **very fast** and start sending requests to our application before the new release is rolled out. If you're unsure why we need to do that, it will become evident in a few moments.

Please open a **second terminal** window.

Given that **EKS** requires access key ID and secret access key as authentication, we'll need to declare a few environment variables in the new terminal session. Those are the same ones we used to create the cluster, so you shouldn't have any trouble recreating them.

W> Please execute the commands that follow **only** if your cluster is running in **EKS**. You'll have to replace the first `[...]` with your access key ID, and the second with the secret access key.

```bash
export AWS_ACCESS_KEY_ID=[...]

export AWS_SECRET_ACCESS_KEY=[...]

export AWS_DEFAULT_REGION=us-east-1
```

Let's find out the address of our application running in staging.

```bash
jx get applications --env staging
```

The output should be similar to the one that follows.

```
APPLICATION    STAGING PODS URL
jx-progressive 0.0.4   3/3  http://jx-progressive.jx-staging.35.196.143.33.nip.io
```

Copy the `jx-progressive` URL and paste it instead of `[...]` in the command that follows.

```bash
STAGING_ADDR=[...]
```

That's it. Now we can start bombing our application with requests.

```bash
while true
do
    curl "$STAGING_ADDR"
    sleep 0.2
done
```

We created an infinite loop inside which we're sending requests to the application running in staging. To avoid burning your laptop, we also added a short delay of `0.2` seconds.

If you were fast enough, the output should consist of an endless list of `Hello from:  Jenkins X golang http example` messages. If that's what you're getting, it means that the deployment of the new release did not yet start. In such a case, all we have to do is wait.

At one moment, `Hello from:  Jenkins X golang http example` messages will turn into 5xx responses. Our application is down. If this were a "real world" situation, our users would experience an outage. Some of them might even be so disappointed that they would choose not to stick around to see whether we'll recuperate and instead switch to a competing product. I know that I, at least, have a very low tolerance threshold. If something does not work and I do not have a strong dependency on it, I move somewhere else almost instantly. If I'm committed to a service or an application, my tolerance might be a bit more forgiving, but it is not indefinite. I might forgive you one outage. I might even forgive two. But, the third time I cannot consume something, I will start considering an alternative. Then again, that's me, and your users might be more forgiving. Still, even if you do have loyal customers, downtime is not a good thing, and we should avoid it.

While you were reading the previous paragraph, the message probably changed again. Now it should be an endless loop of `Hello from:  Jenkins X golang http recreate`. Our application recuperated and is now operational again. It's showing us the output from the new release. If we could erase from our memory the 5xx messages, that would be awesome.

All in all, the output, limited to the relevant parts, should be as follows.

```
...
Hello from:  Jenkins X golang http example
Hello from:  Jenkins X golang http example
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
Hello from:  Jenkins X golang http recreate
Hello from:  Jenkins X golang http recreate
...
```

If all you ever saw was only the loop of `Hello from:  Jenkins X golang http recreate`, all I can say is that you were too slow. If that's the case, you'll have to trust me that there were some nasty messages in between the old and the new release.

That was enough looping for now. Please press *ctrl+c* to stop it and give your laptop a rest. Leave the second terminal open and go **back to the first one**.

What happened was neither pretty nor desirable. Even if you are not familiar with the `RollingUpdate` strategy (the default one for Kubernetes Deployments), you already experienced it countless times before. You probably did not see those 5xx messages in the previous exercises, and that might make you wonder why did we switch to `Recreate`. Why would anyone want it? The answer to that question is that no one desires such outcomes, but many are having them anyway. I'll explain soon why we want to use the `Recreate` strategy even though it produces downtime. To answer why would anyone want something like that, we'll first explore why was the outage created in the first place.

When we deployed the second release using the `Recreate` strategy, Kubernetes first shut down all the instances of the old release. Only when they all ceased to work, it deployed the new release in its place. The downtime we experienced existed between the time the old release was shut down, and the time the new one became fully operational. The downtime lasted only for a couple of seconds, but that's because our application (*go-demo-6*) boots up very fast. Some other apps might be much slower, and the downtime would be much longer. It's not uncommon for the downtime in such cases to take minutes and sometimes even hours.

Alternatively, you might not have seen a single 5xx error. If that's the case, you were fortunate because that means that the old release was shut down and the new was up-and-running within 200 milliseconds (iteration between two requests in the loop9. If that's what happened to you, rest assured that it is highly unlikely it'll happen again. You just experienced once in a lifetime event. As you can probably guess, we cannot rely on users being that lucky.

We can think of the `Recreate` strategy as a "big bang". There is no transition period, there are no rolling updates, nor there are any other"modern" deployment practices. The old release is shut down, and the new one is put in its place. It's simple and straightforward, but it results in inevitable downtime.

![Figure 17-4: The recreate deployments strategy](images/ch17/recreate.png)

Still, the initial question stands. Who would ever want to use the `Recreate` strategy? The answer is not that much who wants it, but rather who must use it.

Let's take another look at static Jenkins. It is a stateful application that cannot scale. So, replacing one replica at a time as a way to avoid downtime is out of the question. When applications cannot scale, there is no way we could ever accomplish deployments without downtime. Two replicas are a minimum. Otherwise, if only one replica is allowed to run at any given moment, we have to shut it down to make room for the other replica (the one from the new release). So, when there is no scaling, there is no high availability. Downtime, at least related to new releases, is unavoidable.

Why can static Jenkins not scale? There can be many answers to that question, but the main culprit is its state. It is a stateful application unable to share that state across multiple instances. Even if you deploy various Jenkins instances, they will operate independently from each other. Each would have a different state and manage different pipelines. That, dear reader, is not scaling. Having multiple independent instances of an application is not replication. For an application to be scalable, each replica needs to work together with others and share the load. As a rule of thumb, for an application to be scalable, it needs to be stateless (e.g., *go-demo-6*) or to be able to replicate state across all replicas (e.g., MongoDB). Jenkins does not fulfill either of the two criteria and, therefore, it cannot scale. Each instance has its separate file storage where it keeps the state unique to that instance. The best we can do with static Jenkins is to give an instance to each team. That solves quite a few Jenkins-specific problems, but it does not make it scalable. As a result, it is impossible to upgrade Jenkins without downtime.

Upgrades are not the only source of downtime with unscalable applications. If we have only one replica, Kubernetes will recreate it when it fails. But that will also result in downtime. As a matter of fact, failure and upgrades of single-replica applications are more or less the same processes. In both cases, the only replica is shut down, and a new one is put in its place. There is downtime between those two actions.

All that might leads you to conclude that only single-replica applications should use the `Recreate` strategy. That's not true. There are many other reasons while the "big bang" deployment strategy should be applied. We won't have time to discuss all. Instead, I'll mention only one more example.

The only way to avoid downtime when upgrading applications is to run multiple replicas and start replacing them one by one or in batches. It does not matter much how many replicas we shut down and replace with those of the new release. We should be able to avoid downtime as long as there is at least one replica running. So, we are likely going to run new releases in parallel with the old ones, at least for a while. We'll go through that scenario soon. For now, trust me when I say that running multiple releases of an application in parallel is unavoidable if we are to perform deployments without downtime. That means that our releases must be backward compatible, that our applications need to version APIs, and that clients need to take that versioning into account when working with our apps. Backward compatibility is usually the main stumbling block that prevents teams from applying zero-downtime deployments. It extends everywhere. Database schemas, APIs, clients, and many other components need to be backward compatible.

All in all, inability to scale, statefulness, lack of backward compatibility, and quite a few other things might prevent us from running two releases in parallel. As a result, we are forced to use the `Recreate` strategy or something similar.

So, the real question is not whether anyone wants to use the `Recreate` strategy, but rather who is forced to apply it due to the problems usually related to the architecture of an application. If you have a stateful application, the chances are that you have to use that strategy. Similarly, if your application cannot scale, you are probably forced to use it as well.

Given that deployment with the `Recreate` strategy inevitably produces downtime, most teams tend to have less frequent releases. The impact of, let's say, one minute of downtime is not that big if we produce it only a couple of times a year. But, if we would increase the release frequency, that negative impact would increase as well. Having downtime a couple of times a year is much better than once a month, which is still better than if we'd have it once a day. High-velocity iterations are out of the question. We cannot deploy releases frequently if we experience downtime each time we do that. In other words, zero-downtime deployments are a prerequisite for high-frequency releases to production. Given that the `Recreate` strategy does produce downtime, it stands to reason that it fosters less frequent releases to production as a way to reduce the impact of downtime.

Before we proceed, it might be important to note that there was no particular reason to use the `Recreate` deployment strategy. The *jx-progressive* application is scalable, stateless, and it is designed to be backward compatible. Any other strategy would be better suited given that zero-downtime deployment is probably the most important requirement we can have. We used the `Recreate` strategy only to demonstrate how that deployment type works and to be consistent with other examples in this chapter.

Now that we saw how the `Recreate` strategy works, let's see which requirements it fulfills, and which it fails to address. As you can probably guess, what follows is not going to be a pretty picture.

When there is downtime, there is no high-availability. One excludes the other, so we failed with that one.

Is our application responsive? If we used an application that is more appropriate for that type of deployment, we would probably discover that it would not be responsive or that it would be using more resources than it needs. Likely we'd experience both side effects.

If we go back to static Jenkins as an excellent example for the `Recreate` deployment strategy, we would quickly discover that it is expensive to run it. Now, I do not mean expensive in terms of licensing costs but rather in resource usage. We'd need to set it up to always use memory and CPU required for its peak load. We'd probably take a look at metrics and try to figure out how much memory and CPU it uses when the most concurrent builds are running. Then, we'd increase those values to be on the safe side and set them as requested resources. That would mean that we'd use more CPU and memory than what is required for the peak load, even if most of the time we need much less. In the case of some other applications, we'd let them scale up and down and, in that way, balance the load while using only the resources they need. But, if that would be possible with Jenkins, we would not use the `Recreate` strategy. Instead, we'd have to waste resources to be on the safe side, knowing that it can handle any load. That's very costly. The alternative would be to be cheaper and give it fewer resources than the peak load. However, in that case, it would not be responsive given that the builds at the peak load would need to be queued. Or, even worse, it would just bleed out and fail under a lot of pressure. In any case, a typical application used with the `Recreate` deployment strategy is often unresponsive, or it is expensive. More often than not, it is both.

The only thing left is to see whether the `Recreate` strategy allows progressive rollout and automated rollbacks. In both cases, the answer is a resounding no. Given that most of the time only one replica is allowed to run, progressive rollout is impossible. On the other hand, there is no mechanism to roll back in case of a failure. That is not to say that it is not possible to do that, but that it is not incorporated into the deployment process itself. We'd need to modify our pipelines to accomplish that. Given that we're focused only on deployments, we can say that rollbacks are not available.

What's the score? Does the `Recreate` strategy fulfill all our requirements? The answer to that question is a huge "no". Did we manage to get at least one of the requirements? The answer is still no. "Big bang" deployments do **not provide high-availability**. They are **not cost-effective**. They are **rarely responsive**. There is **no possibility to perform progressive rollouts**, and they come with **no automated rollbacks**.

The summary of the fulfillment of our requirements for the `Recreate` deployment strategy is as follows.

|Requirement        |Fulfilled|
|-------------------|----------|
|High-availability  |Not       |
|Responsiveness     |Not       |
|Progressive rollout|Not       |
|Rollback           |Not       |
|Cost-effectiveness |Not       |

As you can see, that was a very depressing outcome. Still, the architecture of our applications often forces us to apply it. We need to learn to live with it, at least until the day we are allowed to redesign those applications or throw them to thrash and start over.

I hope that you never worked with such applications. If you didn't, you are either very young, or you always worked in awesome companies. I, for example, spent most of my career with applications that had to be put down for hours every time we deploy a new release. I had to come to the office during weekends because that's then the least number of people were using our applications. I had to spend hours or even days doing deployments. I spent too many nights sleeping in the office over weekends. Luckily, we had only a few releases a year. Those days now feel like a nightmare that I never want to experience again. That might be the reason why I got interested in automation and architecture. I wanted to make sure that I replace myself with scripts.

So far, we saw two deployment strategies. We probably started with the inverted order, at least from the historical perspective. We can say that serverless deployments are one of the most advanced and modern strategies. At the same time, `Recreate` or, to use a better name, "big bang" deployments are the ghosts of the past that are still haunting us. It's no wonder that Kubernetes does not use it as a default deployment type.

From here on, the situation can only be more positive. Brace yourself for an increased level of happiness.

## Using RollingUpdate Strategy With Standard Kubernetes Deployments

We explored one of the only two strategies we can use with Kubernetes Deployment resource. As we saw, the non-default `Recreate` is meant to serve legacy applications that are typically stateful and often do not scale. Next, we'll see what the Kubernetes community thinks is the default way we should deploy our software.

I> Please bear in mind that, both in the previous and in this section, we are focused on what Kubernetes Deployments offer. We could have just as well used StatefulSet for stateful applications or DeamonSet for those that should be running in each node of the cluster. However, even though those behave differently, they are still based on similar principles. We'll ignore those and focus only on Kubernetes Deployment resource, given that I do not want to convert this chapter into a neverending flow of rambling. Later on, we'll go yet again outside of what Kubernetes offers out-of-the-box.

Now, let's get back to to the topic.

To make our Deployment use the `RollingUpdate` strategy, we can either remove the whole `strategy` entry given that is the default, or we can change the type. We'll go with the latter since the command to accomplish that is easier.

```bash
cat charts/jx-progressive/templates/deployment.yaml \
    | sed -e \
    's@type: Recreate@type: RollingUpdate@g' \
    | tee charts/jx-progressive/templates/deployment.yaml
```

All we did was to change the `strategy.type` to `RollingUpdate`. You should see the full definition of the Deployment on the screen.

Next, we'll change the application's return message so that we can track the change easily from one release to the other.

```bash
cat main.go | sed -e \
    "s@recreate@rolling update@g" \
    | tee main.go

git add .

git commit -m "Recreate strategy"

git push
```

We made the changes and pushed them to the GitHub repository. Now, all that's left is to execute another loop. We'll keep sending requests to the application and display the output.

W> Please go to the **second terminal** before executing the command that follows.

```bash
while true
do
    curl "$STAGING_ADDR"
    sleep 0.2
done
```

The output should be a long list of `Hello from:  Jenkins X golang http recreate` messages. After a while, when the new release is deployed, it will suddenly switch to `Hello from:  Jenkins X golang http rolling update!`. The relevant part of the output should be as follows.

```
...
Hello from:  Jenkins X golang http recreate
Hello from:  Jenkins X golang http recreate
Hello from:  Jenkins X golang http rolling update!
Hello from:  Jenkins X golang http rolling update!
...
```

As you can see, this time, there was no downtime. The application switched from one release to another, or so it seems. But, if that's what happened, we would have seen some downtime, unless that switch happened exactly in those 0.2 seconds between the two requests. To understand better what happened, we'll describe the deployment and explore its events.

W> Please stop the loop with *ctrl+c* and return to the **first terminal**.

```bash
kubectl --namespace jx-staging \
    describe deployment jx-jx-progressive
```

The output, limited to the events section, is as follows.

```
...
Events:
  Type    Reason             Age   From                  Message
  ----    ------             ----  ----                  -------
...
  Normal  ScalingReplicaSet  6m24s deployment-controller Scaled down replica set jx-progressive-8b5698864 to 0
  Normal  ScalingReplicaSet  6m17s deployment-controller Scaled up replica set jx-progressive-77b6455c87 to 3
  Normal  ScalingReplicaSet  80s   deployment-controller Scaled up replica set jx-progressive-658f88478b to 1
  Normal  ScalingReplicaSet  80s   deployment-controller Scaled down replica set jx-progressive-77b6455c87 to 2
  Normal  ScalingReplicaSet  80s   deployment-controller Scaled up replica set jx-progressive-658f88478b to 2
  Normal  ScalingReplicaSet  72s   deployment-controller Scaled down replica set jx-progressive-77b6455c87 to 1
  Normal  ScalingReplicaSet  70s   deployment-controller Scaled up replica set jx-progressive-658f88478b to 3
  Normal  ScalingReplicaSet  69s   deployment-controller Scaled down replica set jx-progressive-77b6455c87 to 0
```

From those events, we can see what happened to the Deployment so far. The first entry in my output (the one that happened over 6 minutes ago) we can see that it scaled one replica set to `0` and the other to `3`. That was the rollout of the new release we created when we used the `Recreate` strategy. Everything was shut down before the new release was put in its place. That was the cause of downtime.

Now, with the `RollingUpdate` strategy, we can see that the system was gradually increasing replicas of one ReplicaSet (`jx-progressive-658f88478b`) and decreasing the other (`jx-progressive-77b6455c87`). As a result, instead of having "big bang" deployment, the system was gradually replacing the old release with the new one, one replica at the time. That means that there was not a single moment without one or the other release available and, during a brief period, both were running in parallel.

![Figure 17-5: The RollingUpdate deployment strategy](images/ch17/rolling-update.png)

You saw from the output of the loop that the messages switched from the old to the new release. In "real world" scenarios, you are likely going to have mixed outputs from both releases. For that reason, it is paramount that releases are backward compatible.

Let's take a database as an example. If we updated schema before initiating the deployment of the application, we could assume that for some time both releases would use the new schema. If the change is not backward compatible, we could end up in a situation where some requests fail because the old release running in parallel with the new is incapable of operating with the new schema. If that were to happen, the result would be similar as if we used the `Recreate` strategy. Some requests would fail. Or, even worse, everything might seem to be working correctly from the end-user point of view, but we would end up with inconsistent data. That could be even worse than downtime.

There are quite a few other things that could go wrong with `RollingUpdates`, but most of them can be resolved by answering positively to two crucial questions. Is our application scalable? Are our releases backward compatible? Without scaling (multiple replicas), `RollingUpdate` is impossible, and without backward compatibility, we can expect errors caused by serving requests through multiple versions of our software.

So, what did we learn so far? Which requirements did we fulfill with the `RollingUpdate` strategy?

Our application was highly available at all times. By running multiple replicas, we are safe from downtime that could be caused by one or more of them failing. Similarly, by gradually rolling out new releases, we are avoiding downtime that we experienced with the `Recreate` strategy.

Even though we did not use HorizontalPodAutoscaler (HPA) in our example, we should add it our solution. With it, we can make our application scale up and down to meet the changes in traffic. The effect would be similar as if we'd use serverless deployments (e.g., with Knative). Still, since HPA does not scale to zero replicas, it would be even more responsive given that there would be no response delay while the system is going from nothing to something (from zero replicas to whatever is needed). On the other hand, this approach comes at a higher cost. We'd have to run at least one replica even if our application is receiving no traffic. Also, some might argue that setting up HPA might be more complicated given that Knative comes with some sensible scaling defaults. That might or might not be an issue, depending on the knowledge one has with deployments and Kubernetes in general. While with Knative HPA and quite a few other resources are implied, with Deployments and the `RollingUpdate` strategy, we do need to define it ourselves. We can say that Knative is more developer-friendly given its simpler syntax and that there is less need to change the defaults.

The only two requirements left to explore are progressive rollout and rollback.

Just as with serverless deployments, `RollingUpdate` kind of works. As you already saw, it does roll out replicas of the new release progressively, one or more at the time. However, the best we can do is make it stop the progress based on very limiting health checks. We can do much better on this front and later we'll see how.

Rollback feature does not exist with the `RollingUpdate` strategy. It can, however, stop rolling forward and that, in some cases, we might end up with only one non-functional replica of the new release. From the user's perspective, that might seem like only the old release is running. But there is no guarantee for such behavior given that in many occasions a problem might be detected after the second, third, or some other replica is rolled out. Automated rollbacks are the only requirement that wasn't fulfilled by any of the deployment strategies we employed so far. Bear in mind that, just as before, by automated rollback, I'm referring to what deployments offer us. I'm excluding situations in which you would do them inside your Jenkins X pipelines. Anything can be rolled back with a few tests and scripts executed if they fail, but that's not our current goal.

So, what did we conclude? Do rolling updates fulfill all our requirements? Just as with other deployment strategies, the answer is still "no". Still, `RollingUpdate` is much better than what we experienced with the `Recreate` strategy. Rolling updates provide **high-availability** and **responsiveness**. They are getting us **half-way towards progressive rollouts**, and they are **more or less cost-effective**. The major drawback is the **lack of automated rollbacks**.

The summary of the fulfillment of our requirements for the `RollingUpdate` deployment strategy is as follows.

|Requirement        |Fulfilled|
|-------------------|----------|
|High-availability  |Fully     |
|Responsiveness     |Fully     |
|Progressive rollout|Partly    |
|Rollback           |Not       |
|Cost-effectiveness |Partly    |

The next in line is blue-green deployment.

## Evaluating Whether Blue-Green Deployments Are Useful

Blue-green deployment is probably the most commonly mentioned "modern" deployment strategy. It was made known by Martin Fowler.

The idea behind blue-green deployments is to run two production releases in parallel. If, for example, the current release is called "blue", the new one would be called "green", and vice versa. Assuming that the load balancer (LB) is currently pointing to the blue release, all we'd need to do to start redirecting users to the new one would be to change the LB to point to green.

We can describe the process through three different stages.

1. Let's say that, right now, all the requests are forwarded to the current release. Let's that that's the blue release with the version v2. We'll also imagine that the release before it is running as green and that the version is v1. The green release lays dormant, mostly wasting resources.
2. When we decide to deploy a new release, we do it by replacing the inactive (dormant) instances. In our case, that would be green instances which are currently running v1 and will be replaced with v3.
3. When all the green instances are running the new release, all that's left is to reconfigure the LB to forward all the requests to green instead of the blue instances. Now the blue release is dormant (unused) and will be the target of the next deployment.

![Figure 17-6: Blue-green deployment strategy](images/ch17/blue-green.png)

If we'd like to revert the release, all we'd have to do is change the LB to point from the active to the inactive set of instances. Or, to use different terminology, we switch it one color to another.

Blue-green deployments made a lot of sense before. If each of the replicas of our application were running in a separate VM, rolling updates would be much harder to accomplish. On top of that, rolling back (manual or automated) is indeed relatively easy with blue-green given that both releases are running in parallel. All we'd have to do is to reconfigure the LB to point to the old release.

However, we do not live in the past. We are not deploying binaries to VMs but containers to Kubernetes which schedules them inside virtual machines that constitute the cluster. Running any release is easy and fast. Rolling back containers is as easy as reconfiguring the LB.

When compared to the serverless deployments and the `RollingUpdate` strategy, blue-green does not bring anything new to the table. In all the cases, multiple replicas are running in parallel, even though that might not be that obvious with blue-green deployments.

People tend to think that switching from blue to green deployment is instant, but that is far from the truth. The moment we change the load balancer to point to the new release, both are being accessed by users, at least for a while. The requests initiated before the switch will continue being processed by the old release, and the new ones will be handled by the new. In that aspect, blue-green deployments are no different from the `RollingUpdate` strategy. The significant difference is in the cost.

Let's imagine that we have five replicas of our application. If we're using rolling updates, during the deployment process, we will have six, unless we configure it differently. A replica of the new release is created so we have six replicas. After that, a replica of the old release is destroyed, so we're back to five. And so on, the process keeps alternating between five and six replicas, until the whole new release is rolled out and the old one is destroyed. With blue-green deployments, the number of replicas is duplicated. If we keep with five replicas as the example, during the deployment process, we'd have ten (five of the old and five of the new). As you can imagine, the increase in resource consumption is much lower if we increase the number of replicas by one than if we double them. Now, you can say that the increase is not that big given that it lasts only for the duration of the deployment process, but that would not necessarily be true.

One of the cornerstones of blue-green strategy is the ability to roll back by reconfiguring the load balancer to point to the old release. For that, we need the old release to be always up-and-running, and thus have the whole infrastructure requirements doubled permanently. Now, I do not believe that's the reason good enough today. Replacing a container based on one image with a container based on another is almost instant. Instead of running two releases in parallel, we can just as easily and rapidly roll forward to the old release. Today, running two releases in parallel forever and ever is just a waste of resources for no good reason.

Such a waste of resources (for no good reason) is even more evident if we're dealing with a large scale. Imagine that your application requires hundreds of CPU and hundreds of gigabytes of memory. Do you want to double that knowing that rolling updates give you all the same benefits without such a high cost associated with it?

Frankly, I think that blue-green was a short blink in the history of deployments. They were instrumental, and they provided the base from which others like rolling updates and canaries were born. Both are much better implementations of the same objectives. Nevertheless, blue-green is so popular that there is a high chance that you will not listen to me and that you want it anyways. I will not show you how to do "strict" blue-green deployments. Instead, I will argue that you were already doing a variation of it through quite a few chapters. I will assume that you want to deploy to production what you already tested so no new builds of binaries should be involved. I will also expect that you do understand that there is no need to keep the old release running so that you can roll back to it. Finally, I will assume that you do not want to have any downtime during the deployment process. With all that in mind, let's do a variation of blue-green deployments without actually employing any new strategy or using any additional tools.

Now, let's take a look at what's running in the staging environment.

```bash
jx get applications --env staging
```

The output is as follows.

```
APPLICATION    STAGING PODS URL
jx-progressive 0.0.7   3/3  http://jx-progressive.jx-staging...
```

For now, we'll assume that whatever is running in production is our blue release and that staging is green. At this moment, you can say that both releases should be running in production to qualify for blue-green deployments. If that's what's going through your brain, remember that "staging" is just the name. It is running in the same cluster as production unless you choose to run Jenkins X environments in different clusters. The only thing that makes the release in staging different from production (apart from different Namespaces) is that it might not be using the production database or to be connected with other applications in production, but to their equivalents in staging. Even that would be an exaggeration since you are (and should be) running in staging the same setup as production. The only difference should be that one has production candidates while the other is the "real" production. If that bothers you, you can easily change the configuration so that an application in staging is using the database in production, be connected with other applications in production, and whatever else you have there.

With the differences between production and staging out of the way, we can say that the application running in staging is the candidate to be deployed in production. We can just as easily call one blue (production) and the other one green (staging).

Now, what comes next will be a slight deviation behind the idea of blue-green deployments. Instead of changing the load balancer (in our case Ingress) to point to the staging release (green), we'll promote it to production.

I> Please replace `[...]` with the version from the previous output.

```bash
VERSION=[...]

jx promote jx-progressive \
    --version $VERSION \
    --env production \
    --batch-mode
```

After a while, the promotion will end, and the new (green) release will be running in production. All that's left, if you're running serverless Jenkins X, is to confirm that by watching the activities associated with the production repository.

```bash
jx get activities \
    --filter environment-jx-rocks-production/master \
    --watch
```

Please press *ctrl+c* to stop watching the activity once you confirm that the build initiated by the previous activity's push of the changes to the master branch.

Now we can take a look at the applications running in production.

```bash
jx get applications --env production
```

The output should not be a surprise since you already saw the promotion process quite a few times before. It shows that the release version we have in staging is now running in production and that it is accessible through a specific address.

Finally, we'll confirm that the release is indeed running correctly by sending a request.

I> Please replace `[...]` with the address of the release in production. You can get it from the output of the previous command.

```bash
PRODUCTION_ADDR=[...]

curl "$PRODUCTION_ADDR"
```

Surprise, surprise... The output is `Hello from:  Jenkins X golang http rolling update`. If you got `503 Service Temporarily Unavailable`, the application is not yet fully operational because you probably did not have anything running in production before the promotion. If that's the case, please wait for a few moments and re-run the `curl` command.

Was that blue-green deployment? It was, of sorts. We had a release (in staging) running in precisely the same way as if it would run in production. We had the opportunity to test it. We switched our production load from the old to the new release without downtime. The significant difference is that we used `RollingUpdate` for that, but that's not a bad thing. Quite the contrary.

What we did has many of the characteristics of blue-green deployments. On the other hand, we did not strictly follow the blue-green deployment process. We didn't because I believe that it is silly. Kubernetes opened quite a few new possibilities that make blue-green deployments obsolete, inefficient, and wasteful.

Did that make you mad? Are you disappointed that I bashed blue-green deployments? Did you hope to see examples of the "real" blue-green process? If that's what's going through your mind, the only thing I can say is to stick with me for a while longer. We're about to explore progressive delivery and the tools we'll explore can just as well be used to perform blue-green deployments. By the end of this chapter, all you'll have to do is read a bit of documentation and change a few things in a YAML file. You'll have "real" blue-green deployment. However, by the time you finish reading this chapter, especially what's coming next, the chances are that you will discard blue-green as well. 

Given that we did not execute "strict" blue-green process and that what we used is `RollingUpdate` combined with promotion from one environment to another, we will not discuss the pros and cons of the blue-green strategy. We will not have the table that evaluates which requirements we fulfilled. Instead, we'll jump into progressive delivery as a way to try to address progressive rollout and automated rollbacks. Those are the only two requirements we did not yet obtain fully.

## About The World We Lived In

The necessity to test new releases before deploying them to production is as old as our industry. Over time, we developed elaborate processes aimed at ensuring that our releases are ready for production. We were testing them locally and deploying them to testing environments where we would test them more. When we were comfortable with the quality, we were deploying those release to integration and pre-production environments for the final round of validations. Typically, the closer we were getting to releasing something to production, the more similar our environments were to production. That was a lengthy process that would last for months, sometimes even years.

Why are we moving our releases through different environments (e.g., servers or clusters)? The answer lies in the difficulties in maintaining production-like environments.

In the past, it took a lot of effort to manage environments, and the more they looked like production, the more work they required. Later on, we adopted configuration management tools like CFEngine, Chef, Puppet, Ansible, and quite a few others. They simplified the management of our environments. Still, we kept the practice of moving our software from one to another as if it was an abandoned child moving from one foster family to another. The main reason why configuration management tools did not solve many problems lies in a misunderstanding of the root cause of the problem. What made the management of environments challenging is not that we had many of them, nor that production-like clusters are complicated. Instead, the issue was in mutability. No matter how much effort we put in maintaining the state of our clusters, differences would pile up over time. We could not say that one environment is genuinely the same as the other. Without that guarantee, we could not claim that what was tested in one environment would work in another. The risk of experiencing failure after deploying to production was still too high.

Over time, we adopted immutability. We learned that things shouldn't be modified at runtime, but instead created anew whenever we need to update something. We started creating VM images that contained new releases and applying rolling updates that would gradually replace the old. But that was slow. It takes time to create a new VM image, and it takes time to instantiate them. There were many other problems with them, but this is neither time nor place to explore them all. What matters is that immutability applied to the VM level brought quite a few improvements, but also some challenges. Our environments became stable, and it was easy to have as many production-like environments as we needed, even though that approach revealed quite a few other issues.

Then came containers that took immutability to the next level. They gave us the ability to say that something running in a laptop is the same as something running in a test environment that happens to behave in the same way as in production. Creating a container based on an image produces the same result no matter where it runs. That's not 100% true, but when compared to what we had in the past, containers bring us as close to repeatability as we can get today.

So, if containers provide a reasonable guarantee that a release will behave the same no matter the environment it runs in, we can safely say that if it works in staging, it should work in production. That is especially true if both environments are in the same cluster. In such a case, hardware, networking, storage, and other infrastructure components are the same, and the only difference is the Kubernetes Namespace something runs in. That should provide a reasonable guarantee that a release tested in staging should work correctly when promoted to production. Don't you agree?

Even if environments are just different Namespaces in the same cluster, and if our releases are immutable container images, there is still a reasonable chance that we will detect issues only after we promote releases to production. No matter how well our performance tests are, production load cannot be reliably replicated. No matter how good we became writing functional tests, real users are unpredictable, and that cannot be reflected in test automation. Tests look for errors we already know about, and we can't test what we don't know. I can go on and on about the differences between production and non-production environments. It all boils down to one having real users, and the other running simulations of what we think "real" people would do.

I'll assume that we agree that production with real users and non-production with I-hope-this-is-what-real-people-do type of simulations are not the same. We can conclude that the only final and definitive confirmation that a release is successful can come from observing how well it is received by "real" users while running in production. That leads us to the need to monitor our production systems and observe user behavior, error rates, response times, and a lot of other metrics. Based on that data, we can conclude whether a new release is truly successful or not. We keep it if it is and we roll back if it isn't. Or, even better, we roll forward with improvements and bug fixes. That's where progressive delivery kicks in.

## A Short Introduction To Progressive Delivery

Progressive delivery is a term that includes a group of deployment strategies that try to avoid the pitfalls of the all-or-nothing approach. New versions being deployed do not replace existing versions but run in parallel for some time while receiving live production traffic. They are evaluated in terms of correctness and performance before the rollout is considered successful.

Progressive Delivery encompasses methodologies such as rolling updates, blue-green or canary deployments. We already used rolling updates for most of our deployments so you should be familiar with at least one flavor of progressive delivery. What is common to all of them is that monitoring and metrics are used to evaluate whether a new version is "safe" or needs to be rolled back. That's the part that our deployments were missing so far or, at least, did not do very well. Even though we did add tests that run during and after deployments to staging and production environments, they were not communicating findings to the deployment process. We did manage to have a system that can decide whether the deployment was successful or not, but we need more. We need a system that will run validations during the deployment process and let it decide whether to proceed, to halt, or to roll back. We should be able to roll out a release to a fraction of users, evaluate whether it works well and whether the users are finding it useful. If everything goes well, we should be able to continue extending the percentage of users affected by the new release. All in all, we should be able to roll out gradually, let's say ten percent at a time, run some tests and evaluate results, and, depending on the outcome, choose whether to proceed or to roll back.

To make progressive delivery easier to grasp, we should probably go through the high-level process followed for the three most commonly used flavors.

With rolling updates, not all the instances of our application are updated at the same time, but they are rolled out incrementally. If we have several replicas (containers, virtual machines, etc.) of our application, we would update one at a time and check the metrics before updating the next. In case of issues, we would remove them from the pool and increase the number of instances running the previous version.

Blue-green deployments temporarily create a parallel duplicate set of our application with both the old and new version running at the same time. We would reconfigure a load balancer or a DNS to start routing all traffic to the new release. Both versions coexist until the new version is validated in production. In some cases, we keep the old release until it is replaced with the new. If there are problems with the new version, the load balancer or DNS is just pointed back to the previous version.

With canary deployments, new versions are deployed, and only a subset of users are directed to it using traffic rules in a load balancer or more advanced solutions like service mesh. Users of the new version can be chosen randomly as a percentage of the total users or using other criteria such as geographic location, headers, employees instead of general users, etc. The new version is evaluated in terms of correctness and performance and, if successful, more users are gradually directed to the new version. If there are issues with the new version or if it doesn't match the expected metrics, the traffic rules are updated to send all traffic back to the previous one.

Canary releases are very similar to rolling updates. In both cases, the new release is gradually rolled out to users. The significant difference is that canary deployments allow us more control over the process. They allow us to decide who sees the new release and who is using the old. They allow us to gradually extend the reach based on the outcome of validations and on evaluating metrics. There are quite a few other differences we'll explore in more detail later through practical examples. For now, what matters is that canary releases bring additional levers to continuous delivery.

**Progressive delivery makes it easier to adopt continuous delivery**. It reduces risks of new deployments by limiting the blast radius of any possible issues, known or unknown. It also provides automated ways to rollback to an existing working version. No matter how much we test a release before deploying it to production, we can never be entirely sure that it will work. Our tests could never fully simulate "real" users behavior. So, if being 100% certain that a release is valid and will be well received by our users is impossible, the best we can do it to provide a safety net in the form of gradual rollout to production that depends on results of tests, evaluation of metrics, and observation how users receive the new release.

There are quite a few ways we can implement canary deployments, ranging from custom scripts to using ready-to-go tools that can facilitate the process. Given that we do not have time or space to evaluate all the tools we could use, we'll have to pick a combination.

We will explore how Jenkins X integrates with Flagger, Istio, and Prometheus which, when combined, can be used to facilitate canary deployments. Each will start by getting a small percentage of the traffic and analyzing metrics such as response errors and duration. If these metrics fit a predefined requirement, the deployment of the new release will continue, and more and more traffic will be forwarded to it until everything goes through the new release. If these metrics are not successful for any reason, our deployment will be rolled back and marked as a failure. To do all that, we'll start with a rapid overview of those tools. Just remember that what you'll read next is a high-level overview, not an in-depth description. A whole book can be written on Istio alone, and this chapter is already too big.

## A Quick Introduction To Istio, Prometheus, Flagger, And Grafana

[Istio](https://istio.io) is a service mesh that runs on top of Kubernetes. Quickly after the project was created, it became one of the most commonly used in Kubernetes. It allows traffic management that enables us to control the flow of traffic and other advanced networking such as point to point security, policy enforcement, automated tracing, monitoring, and logging.

We could write a full book about Istio. Instead, we'll focus on the traffic shifting and metric gathering capabilities of Istio and how we can use those to enable Canary deployments.

We can configure Istio to expose metrics that can be pulled by specialized tools. [Prometheus](https://prometheus.io) is a natural choice, given that it is the most commonly used application for pulling, storing, and querying metrics. Its format for defining metrics can be considered the de-facto standard in Kubernetes. It stores time-series data that can be queried using its query language PromQL. We just need to make sure that Istio and Prometheus are integrated.

[Flagger](https://github.com/stefanprodan/flagger) is a project sponsored by WeaveWorks. It can use service mesh solutions like Istio, Linkerd, Gloo (which we used with Knative), and quite a few others. Together with a service mesh, we can use Flagger to automate deployments and rollback using a few different strategies. Even though the focus right now is canary deployments, you should be able to adapt the examples that follow into other strategies as well. To make things easier, Flagger even offers a Grafana dashboard to monitor the deployment progress.

[Grafana](https://grafana.com) provides a user interface that allows us to visualize metrics through dashboards. Just like the other tools we chose, it is probably the most commonly used among the solutions we can run inside our Kubernetes clusters.

I> Please note that we could have used Gloo instead of Istio, just as we did in the [Using Jenkins X To Define And Run Serverless Deployments](#knative) chapter. But, I thought that this would be an excellent opportunity to introduce you to Istio. Also, you should be aware that none of the tools are the focus of the book and that the main goal is to show you one possible implementation of canary deployments. Once you understand the logic behind it, you should be able to switch to whichever toolset you prefer.

I> This book is dedicated to continuous delivery with Jenkins X. All the other tools we use are chosen mostly to demonstrate integrations with Jenkins X. We are not providing an in-depth analysis of those tools beyond their usefulness to continuous delivery.

## Installing Istio, Prometheus, Flagger, And Grafana

We'll install all the tools we need as Jenkins X addons. They are an excellent way to install and integrate tools. However, addons might not provide you with all the options you can use to tweak those tools to your specific needs. Later on, once you adopt Jenkins X in production, you should evaluate whether you want to continue using the addons or you prefer to set up those tools in some other way. The latter might give you more freedom. For now, addons are the easiest way to set up what we need so we'll roll with them.

Let's start with Istio.

```bash
jx create addon istio
```

W> In some cases, the previous command may fail due to the order Helm applies CRD resources. If that happens, re-run the command again to fix the issue.

I> Istio is resource-heavy. It is the reason why we increased the size of the VMs that compose our cluster.

When installing Istio, a new Ingress gateway service is created. It is used for sending all the incoming traffic to services based on Istio rules (`VirtualServices`). That achieves a similar functionality as the one provided by Ingress. While Ingress has the advantage of being simple, it is also very limited in its capabilities. Istio, on the other hand, allows us to create advanced rules for incoming traffic, and that's what we'll need for canary deployments.

For now, we need to find the external IP address of the Istio Ingress gateway service. We can get it from the output of the `jx create addon istio` command. But, given that I don't like copying and pasting outputs, we'll use the commands that follow to retrieve the address and store it in environment variable `ISTIO_IP`.

Just as with Ingress, the way to retrieve the IP differs depending on whether you're using EKS or some other Kubernetes flavor.

W> Please run the command that follows only if you are **NOT** using **EKS** (e.g., GKE, AKS, etc.).

```bash
ISTIO_IP=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

W> Please run the commands that follow only if you are using **EKS**.

```bash
ISTIO_HOST=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')

export ISTIO_IP="$(dig +short $ISTIO_HOST \
    | tail -n 1)"
```

To be on the safe side, we'll output the environment variable to confirm that the IP does indeed looks to be correct.

```bash
echo $ISTIO_IP
```

When we created the `istio` addon, Prometheus was installed alongside it, so the only tool left for us to add is Flagger. Later on, we'll see why I skipped Grafana.

```bash
kubectl apply \
    --kustomize github.com/weaveworks/flagger/kustomize/istio
```

Now, let's take a quick look at the Pods that were created through those two addons.

```bash
kubectl --namespace istio-system \
    get pods
```

The output is as follows.

```
NAME                       READY STATUS    RESTARTS AGE
flagger-5bdbccc7f4-...     1/1   Running   0        110s
flagger-grafana-...        1/1   Running   0        78s
istio-citadel-...          1/1   Running   0        3m22s
istio-galley-...           1/1   Running   0        4m46s
istio-ingressgateway-...   1/1   Running   0        4m40s
istio-init-crd-10-...      0/1   Completed 0        5m8s
istio-init-crd-11-...      0/1   Completed 0        5m7s
istio-pilot-...            2/2   Running   0        3m35s
istio-policy-...           2/2   Running   6        4m38s
istio-sidecar-injector-... 1/1   Running   0        3m14s
istio-telemetry-...        2/2   Running   6        4m38s
prometheus-...             1/1   Running   0        3m28s
```

We won't go into details of what each of those Pods does. I expect you to consult the documentation if you are curious. For now, we'll note that Flagger, Istio, and Prometheus Pods were created in the `istio-system` Namespace and that, by the look of it, they are all running. If any of those are in the pending state, you either need to increase the number of nodes in your cluster or none of the nodes is big enough to meet the demand of the requested resources. The former case should be solved with the Cluster Autoscaler if you have it running in your Kubernetes cluster. The latter, on the other hand, probably means that you did not follow the instructions to create a cluster with bigger VMs. In any case, the next step would be to describe the pending Pod, see the root cause of the issue, and act accordingly.

There's still one thing missing. We need to tell Istio to auto-inject sidecar proxy containers to all the Pods in the `jx-production` Namespace.

```bash
kubectl label namespace jx-production \
    istio-injection=enabled \
    --overwrite
```

We got a new label `istio-injection=enabled`. That one tells Istio to inject the sidecar containers into our Pods. Without it, we'd need to perform additional manual steps, and you already know that's not something I like doing.

Whichever deployment strategy we use, it should be the same in all the permanent environments. Otherwise, we do not have parity between applications running in production and those running in environments meant to be used for testing (e.g., staging). The more similar, if not the same, those environments are, the more confident we are to promote something to production. Otherwise, we can end up in a situation where someone could rightfully say that what was tested is not the same as what is being deployed to production.

So, let's take a look at the labels in the staging environment.

```bash
kubectl describe namespace \
    jx-staging
```

The output, limited to the relevant parts, is as follows.

```yaml
Name:         jx-staging
Labels:       env=staging
              team=jx
...
```

As we can see, the staging environment does not have the `istio-injection=enabled` label, so Istio will not inject sidecars and, as a result, it will not work there. Given that we already elaborated that staging and production should be as similar as possible, if not the same, we'll add the missing label so that Istio works in both.

```bash
kubectl label namespace jx-staging \
    istio-injection=enabled \
    --overwrite
```

Let's have another look at the staging environment to confirm that the label was indeed added correctly.

```bash
kubectl describe namespace \
    jx-staging
```

The output, limited to the relevant parts, is as follows.

```yaml
Name:         jx-staging
Labels:       env=staging
              istio-injection=enabled
              team=jx
...
```

The `istio-injection=enabled` is there, and we can continue while knowing that whatever Istio will do in the staging environment will be the same as in production.

## Creating Canary Resources With Flagger

Let's say we want to deploy our new release only to 20% of the users and that we will monitor metrics for 60 seconds. During that period, we'll be validating whether the error rate is within a predefined threshold and whether the time it takes to process requests is within some limits. If everything seems right, we'll increase the percentage of users who can use our new release for another 20%, and continue monitoring metrics to decide whether to proceed. The process should repeat until the new release is rolled out to everyone, twenty percent at a time every thirty seconds.

Now that we have a general idea of what we want to accomplish and that all the tools are set up, all that's missing is to create Flagger `Canary` definition.

Fortunately, canary deployments with Flagger are available in Jenkins X build packs since January 2020. So, there's not much work to do to convert our application to use the canary deployment process.

Let's take a look at the `Canary` resource definition already available in our project.

```bash
cat charts/jx-progressive/templates/canary.yaml
```

The output is as follows.

```yaml
{{- if .Values.canary.enabled }}
apiVersion: flagger.app/v1alpha3
kind: Canary
metadata:
  name: {{ template "fullname" . }}
  labels:
    draft: {{ default "draft-app" .Values.draft }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
spec:
  provider: istio
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ template "fullname" . }}
  progressDeadlineSeconds: {{ .Values.canary.progressDeadlineSeconds }}
  {{- if .Values.hpa.enabled }}
  autoscalerRef:
    apiVersion: autoscaling/v2beta1
    kind: HorizontalPodAutoscaler
    name: {{ template "fullname" . }}
  {{- end }}
  service:
    port: {{ .Values.service.externalPort }}
    targetPort: {{ .Values.service.internalPort }}
    gateways:
    - {{ template "fullname" . }}
    hosts:
    - {{ .Values.canary.host }}
  analysis:
    interval: {{ .Values.canary.canaryAnalysis.interval }}
    threshold: {{ .Values.canary.canaryAnalysis.threshold }}
    maxWeight: {{ .Values.canary.canaryAnalysis.maxWeight }}
    stepWeight: {{ .Values.canary.canaryAnalysis.stepWeight }}
    metrics:
    - name: request-success-rate
      threshold: {{ .Values.canary.canaryAnalysis.metrics.requestSuccessRate.threshold }}
      interval: {{ .Values.canary.canaryAnalysis.metrics.requestSuccessRate.interval }}
    - name: request-duration
      threshold: {{ .Values.canary.canaryAnalysis.metrics.requestDuration.threshold }}
      interval: {{ .Values.canary.canaryAnalysis.metrics.requestDuration.interval }}

---

apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: {{ template "fullname" . }}
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: {{ .Values.service.externalPort }}
      name: http
      protocol: HTTP
    hosts:
    - {{ .Values.canary.host }}
{{- end }}
```

The whole definition is inside an `if` statement so that `Canary` is created only if the value `canary.enabled` is set to `true`. That way, by default, we will not use canary deployments at all. Instead, we'll have to specify when and under which circumstances they will be created. That might spark the question "why do we go into the trouble of making sure that canary deployments are enabled only in certain cases?" Why not use them always?

By their nature, it takes much more time to execute a canary deployment than most of the other strategies. Canaries roll out progressively and are pausing periodically to allow us to validate the result on a subset of users. That increased duration can be anything from seconds to hours or even days or weeks. In some cases, we might have an important release that we want to test with our users progressively over a whole week. Such prolonged periods might be well worth the wait in production and staging, which should use the same processes. But, waiting for more than necessary to deploy a release in a preview environment is a waste. Those environments are not supposed to provide the "final stamp" before promoting to production, but rather to flash out most of the errors. After all, not using canaries in preview environments might not be the only difference. As we saw in the previous chapter, we might choose to make them serverless while keeping permanent environments using different deployment strategies. Long story short, the `if` statement allows us to decide when we'll do canary deployments. We are probably not going to employ it in all environments.

The `apiVersion`, `kind`, and `metadata` should be self-explanatory if you have minimal experience with Kubernetes and Helm templating.

The exciting entry is `spec.provider`. As the name suggests, it allows us to specify which provider we'll use. In our case, it'll be Istio, but I wanted to make sure that you can easily switch to something else like, for example, Gloo. If you are using GKE, you already have Gloo running. While exploring different solutions is welcome while learning, later on, you should probably use one or the other, not necessarily both.

The `spec.targetRef` tells `Canary` which Kubernetes object it should manipulate. Unlike serverless Deployments with Knative, which replace Kubernetes Deployments, `Canary` runs on top of whichever Kubernetes resource we're using to run our software. For *jx-progressive*, that's `Deployment`, but it could just as well be a `StatefulSet` or something else.

The next in line is `spec.progressDeadlineSeconds`. Think of it as a safety net. If the system cannot progress with the deployment for the specified period (expressed in seconds), it will initiate a rollback to the previous release.

The `spec.service` entry provides the information on how to access the application, both internally (`port`) and externally (`gateways`), as well as the `hosts` through which the end-users can communicate with the app.

The `spec.analysis` entries are probably the most interesting ones. They define the analysis that should be done to decide whether to progress with the deployment or to roll back. Earlier I mentioned that the interval between progress iterations is thirty seconds. That's specified in the `interval` entry. The `threshold` defined how many failed metric checks are allowed before rolling back. The `maxWeight` sets the percentage of requests routed to the canary deployment before it gets converted to the primary. After that percentage is reached, all users will see the new release. More often than not, we do not need to wait until the process reaches 100% through smaller increments. We can say that, for example, when 50% of users are using the new release, there is no need to proceed with validations of the metrics. The system can move forward and make the new release available to everyone right away. The `stepWeight` entry defines how big roll out increments should be (e.g., 20% at a time). Finally, `metrics` can host an array of entries, one for each metric and threshold that should be evaluated continuously during the process.

The second definition is a "standard" Istio `Gateway`. We won't go into it in detail since that would derail us from our mission by leading us into a vast subject of Istio. For now, think of the `Gateway` as being equivalent to nginx Ingress we've been using so far. It allows Istio-managed applications to be accessible from outside the cluster.

As you noticed, many of the values are not hard-coded into the `Canary` and `Gateway` definitions. Instead, we defined them as Helm values. That way, we can change all those that should be tweaked from `charts/jx-progressive/values.yaml`. So, let's take a look at them.

```bash
cat charts/jx-progressive/values.yaml
```

The relevant parts of the output are as follows.

```yaml
...
# Canary deployments
# If enabled, Istio and Flagger need to be installed in the cluster
canary:
  enabled: false
  progressDeadlineSeconds: 60
  analysis:
    interval: "1m"
    threshold: 5
    maxWeight: 60
    stepWeight: 20
    # WARNING: Canary deployments will fail and rollback if there is no traffic that will generate the below specified metrics.
    metrics:
      requestSuccessRate:
        threshold: 99
        interval: "1m"
      requestDuration:
        threshold: 1000
        interval: "1m"
  # The host is using Istio Gateway and is currently not auto-generated
  # Please overwrite the `canary.host` in `values.yaml` in each environment repository (e.g., staging, production)
  host: acme.com
...
```

We can set the address through which the application should be accessible through the `host` entry at the bottom of the `canary` section. The feature of creating Istio Gateway addresses automatically, like Jenkins X is doing with Ingress, is not available. So, we'll need to define the address of our application for each of the environments. We'll do that later. 

The `analysis` sets the interval to `1m`. So, it will progress with the rollout every minute. Similarly, it will roll back it encounters failures (e.g., reaches metrics thresholds) `5` times. It will finish rollout when it reaches `60` percent of users (`maxWeight`), and it will increase the number of requests forwarded to the new release with increments of `20` percent (`stepWeight`).

Finally, it will use two metrics to validate rollouts and decide whether to proceed, to halt, or to roll back. The first metric is `requestSuccessRate` (`request-success-rate`) calculated throughout `1m`. If less than `99` percent of requests are successful (are not 5xx responses), it will be considered an error. Remember, that does not necessarily mean that it will rollback right away since the `analysis.threshold` is set to `5`. There must be five failures for the rollback to initiate. The second metric is `requestDuration` (`request-duration`). It is also measured throughout `1m` with the threshold of a second (`1000` milliseconds). It does not take into account every request but rather the 99th percentile.

We added the `istio-injection=enabled` label to the staging and the production environment Namespaces. As a result, everything running in those Namespaces will automatically use Istio for networking.

Assuming that the default values suit our needs, there are only two changes we need to make to the values. We need to define the `host` for staging (and later for production), and we'll have to enable canary deployment. Remember, it is disabled by default.

The best place to add staging-specific values is the staging repository. We'll have to clone it, so let's get out of the local copy of the *jx-progressive* repo.

```bash
cd ..
```

Now we can clone the staging repository.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
rm -rf environment-jx-rocks-staging

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-staging.git

cd environment-jx-rocks-staging
```

We removed the local copy of the environment repo just in case it was a leftover from the exercises in the previous chapters. After that, we cloned the repository and entered inside the local copy.

Next, we need to enable `Canary` deployments for the staging environment and to define the address through which *jx-progressive* be accessible.

```bash
STAGING_ADDR=staging.jx-progressive.$ISTIO_IP.nip.io

echo "jx-progressive:
  canary:
    enabled: true
    host: $STAGING_ADDR" \
    | tee -a env/values.yaml
```

All we did was to add a few variables associated with `jx-progressive`.

Now we can push the changes to the staging repository.

```bash
git add .

git commit \
    -m "Added progressive deployment"

git push
```

With the staging-specific values defined, we can go back to the *jx-progressive* repository and push the changes we previously did over there.

```bash
cd ../jx-progressive

git add .

git commit \
    -m "Added progressive deployment"

git push
```

We should not see a tangible change to the deployment process with the first release. So, all there is to do, for now, is to confirm that the activities initiated by pushing the changes to the repository were executed successfully.

```bash
jx get activities \
    --filter jx-progressive/master \
    --watch
```

Press *ctrl+c* to cancel the watcher once you confirm that the newly started build is finished.

```bash
jx get activities \
    --filter environment-jx-rocks-staging/master \
    --watch
```

Press *ctrl+c* to cancel the watcher once you confirm that the newly started build is finished.

Now we're ready with the preparations for `Canary` deployments, and we can finally take a closer look at the process itself as well as the benefits it brings.

## Using Canary Strategy With Flager, Istio, And Prometheus

Before we start exploring `Canary` deployments, let's take a quick look at what we have so far to confirm that the first release using the new definition worked.

Is our application accessible through the Istio gateway?

```bash
curl $STAGING_ADDR
```

The output should say `Hello from:  Jenkins X golang http rolling update`.

Now that we confirmed that the application released with the new definition is accessible through the Istio gateway, we can take a quick look at the Pods running in the staging Namespace.

```bash
kubectl \
    --namespace jx-staging \
    get pods
```

The output is as follows.

```
NAME                          READY STATUS  RESTARTS AGE
jx-jx-progressive-primary-... 2/2   Running 0        42s
jx-jx-progressive-primary-... 2/2   Running 0        42s
jx-jx-progressive-primary-... 2/2   Running 0        42s
```

There is a change at least in the naming of the Pods belonging to *jx-progressive*. Now they contain the word `primary`. Given that we deployed only one release using `Canary`, those Pods represent the main release accessible to all the users. As you can imagine, the Pods were created by the corresponding `jx-jx-progressive-primary` ReplicaSet which, in turn, was created by the `jx-jx-progressive-primary` Deployment. As you can probably guess, there is also the `jx-jx-progressive-primary` Service that allows communication to those Pods, even though sidecar containers injected by Istio further complicate that. Later on, we'll see why all those are important.

What might matter more is the `canary` resource, so let's take a look at it.

```bash
kubectl --namespace jx-staging \
    get canary
```

The output is as follows.

```
NAME              STATUS      WEIGHT LASTTRANSITIONTIME
jx-jx-progressive Initialized 0      2019-12-01T21:35:32Z
```

There's not much going on there since we have only the first `Canary` release running. For now, please note that `canary` can give us additional insight into the process.

You saw that we set the `Canary` gateway to `jx-gateway.istio-system.svc.cluster.local`. As a result, when we deployed the first `Canary` release, it created the gateway for us. We can see it by retrieving `virtualservice.networking.istio.io` resources.

```bash
kubectl --namespace jx-staging \
    get virtualservices.networking.istio.io
```

The output is as follows.

```
NAME              GATEWAYS                                    HOSTS                                                            AGE
jx-jx-progressive [jx-gateway.istio-system.svc.cluster.local] [staging.jx-progressive.104.196.199.98.nip.io jx-jx-progressive] 3m
```

We can see from the output that the gateway `jx-gateway.istio-system.svc.cluster.local` is handling external requests coming from `staging.jx-progressive.104.196.199.98.nip.io` as well as `jx-jx-progressive`. We'll focus on the former host and ignore the latter.

Finally, we can output Flagger logs if we want to see more details about the deployment process.

```bash
kubectl \
    --namespace istio-system logs \
    --selector app.kubernetes.io/name=flagger
```

I'll leave it to you to interpret those logs. Don't get stressed if you don't understand what each event means. We'll explore what's going on in the background as soon as we deploy the second release.

To see `Canary` deployments in action, we'll create a trivial change in the demo application by replacing `hello, rolling update!` in `main.go` to `hello, progressive!`. Then, we will commit and merge it to master to get a new version in the staging environment.

```bash
cat main.go | sed -e \
    "s@rolling update@progressive@g" \
    | tee main.go

git add .

git commit \
    -m "Added progressive deployment"

git push
```

Those were such trivial and commonly used commands that there is no need explaining them.

Just as with previous deployment strategies, now we need to be fast.

```bash
echo $STAGING_ADDR
```

Please copy the output and go to the **second terminal**.

I> Replace `[...]` in the command that follows with the copied address of *jx-progressive* in the staging environment.

```bash
STAGING_ADDR=[...]

while true
do
    curl "$STAGING_ADDR"
    sleep 0.2
done
```

As with the other deployment types, we initiated a loop that continuously sends requests to the application. That will allow us to see whether there is deployment-caused downtime. It will also provide us with the first insight into how canary deployments work.

Until the pipeline starts the deployment, all we're seeing is the `hello, rolling update!` message coming from the previous release. Once the first iteration of the rollout is finished, we should see both `hello, rolling update!` and `hello, progressive!` messages alternating. Since we specified that `stepWeight` is `20`, approximately twenty percent of the requests should go the new release while the rest will continue receiving the requests from the old. Thirty seconds later (the `interval` value), the balance should change. We should have reached the second iteration, with forty percent of requests coming from the new release and the rest from the old.

Based on what we can deduce so far, `Canary` deployments are behaving in a very similar way as `RollingUpdate`. The significant difference is that our rolling update examples did not specify any delay, so the process looked almost as if it was instant. If we did specify a delay in rolling updates and if we had five replicas, the output would be nearly the same.

As you might have guessed, we would not go into the trouble of setting up `Canary` deployments if their behavior is the same as with the `RollingUpdate` strategy. There's much more going on. We'll have to go back to the first terminal to see the other effects better.

Leave the loop running and go back to the **first terminal** 

Let's see which Pods do we have in the staging Namespace.

```bash
kubectl --namespace jx-staging \
    get pods
```

The output is as follows.

```
NAME                          READY STATUS  RESTARTS AGE
jx-jx-progressive-...         2/2   Running 0        22s
jx-jx-progressive-...         2/2   Running 0        22s
jx-jx-progressive-...         2/2   Running 0        22s
jx-jx-progressive-primary-... 2/2   Running 0        9m
jx-jx-progressive-primary-... 2/2   Running 0        9m
jx-jx-progressive-primary-... 2/2   Running 0        9m
```

Assuming that the process did not yet finish, we should see that besides the `jx-jx-progressive-primary` we also got `jx-jx-progressive` (without `-primary`). If you take a closer look at the `AGE`, you should notice that all the Pods were created a while ago except `jx-progressive`. That's the new release, and we'll call it "canary Pod". Flagger has both releases running during the deployment process. Initially, all traffic was being sent to the `primary` Pods. But, when the deployment process was initiated, `VirtualService` started sending traffic to one or another, depending on the iteration and the `stepWeight`. To be more precise, the percentage of requests being sent to the new release is equivalent to the iteration multiplied with `stepWeight`. Behind the scenes, Flagger is updating Istio `VirtualService` with the percentage of requests that should be sent to one group of Pods or another. It is updating `VirtualService` telling it how many requests should go to the Service associated with primary and how many should go to the one associated with "canary" Pods.

Given that much of the action is performed by the `VirtualService`, we'll take a closer look at it and see whether we can gain some additional insight.

I> Your outputs will probably differ from mine depending on the deployment iteration (stage) you're in right now. Follow my explanations of the outputs even if they are not the same as what you'll see on your screen.

```bash
kubectl --namespace jx-staging \
    get virtualservice.networking.istio.io \
    jx-jx-progressive \
    --output yaml
```

The output, limited to the relevant parts, is as follows.

```yaml
...
spec:
  gateways:
  - jx-gateway.istio-system.svc.cluster.local
  hosts:
  - staging.jx-progressive.104.196.199.98.nip.io
  - jx-jx-progressive
  http:
  - route:
    - destination:
        host: jx-jx-progressive-primary
      weight: 20
    - destination:
        host: jx-jx-progressive-canary
      weight: 80
```

The interesting part is the `spec` section. In it, besides the `gateways` and the `hosts`, is `http` with two `routes`. The first one points to `jx-progressive-primary`, which is the old release. Currently, at least in my case, it has the `weight` of `40`. That means that the `primary` (the old) release is currently receiving forty percent of requests. On the other hand, the rest of sixty percent is going to the `jx-progressive-canary` (the new) release. Gradually, Flagger was increasing the `weight` of `canary` and decreasing the `primary`, thus gradually shifting more and more requests from the old to the new release. Still, so far all that looks just a "fancy" way to accomplish what rolling updates are already doing. If that thought is still passing through your head, soon you'll see very soon that there's so much more.

An easier and more concise way to see the progress is to retrieve the `canary` resource.

```bash
kubectl --namespace jx-staging \
    get canary
```

The output is as follows.

```
NAME              STATUS      WEIGHT LASTTRANSITIONTIME
jx-jx-progressive Progressing 60     2019-08-16T23:24:03Z
```

In my case, the process is still `progressing` and, so far, it reached `60` percent. In your case, the `weight` is likely different, or the `status` might be `succeeded`. In the latter case, the process is finished successfully. All the requests are now going to the new release. The deployment rolled out fully.

If we describe that `canary` resource, we can get more insight into the process by observing the events.

```bash
kubectl --namespace jx-staging \
    describe canary jx-jx-progressive
```

The output, limited to the `events` initiated by the latest deployment, is as follows.

```
...
Events:
  Type    Reason Age   From    Message
  ----    ------ ----  ----    -------
...
  Normal  Synced 3m32s flagger New revision detected! Scaling up jx-jx-progressive.jx-staging
  Normal  Synced 3m2s  flagger Starting canary analysis for jx-jx-progressive.jx-staging
  Normal  Synced 3m2s  flagger Advance jx-progressive.jx-staging canary weight 20
  Normal  Synced 2m32s flagger Advance jx-progressive.jx-staging canary weight 40
  Normal  Synced 2m2s  flagger Advance jx-progressive.jx-staging canary weight 60
  Normal  Synced 92s   flagger Advance jx-progressive.jx-staging canary weight 80
  Normal  Synced 92s   flagger Copying jx-progressive.jx-staging template spec to jx-progressive-primary.jx-staging
  Normal  Synced 62s   flagger Routing all traffic to primary
  Normal  Synced 32s   flagger Promotion completed! Scaling down jx-progressive.jx-staging
```

If one of the last two events does not state `promotion completed`, please wait for a while longer for the process to finish and re-run the `kubectl describe` command.

We can see that when the deployment was initiated, Flagger detected that there is a new `revision` (a new release). As a result, it started scaling the application. A while later, it initiated the analysis that consists of evaluations of the metrics (`request-success-rate` and `request-duration`) against the thresholds we defined earlier. Further on, we can see that it was increasing the weight every thirty seconds until it reached `80` percent. That number is vital given that it is the first iteration with the `weight` equal to or above the `maxWeight` which we set to `70` percent. After that, it did not wait for another thirty seconds. Instead, it replaced the definition of the `primary` template to the one used for `canary`. From that moment on, the `primary` was updated to the new release and all the traffic is being routed to it. Finally, the last event was the message that the `promotion` was `completed` and that the `canary` (`jx-progressive.jx-staging`) was scaled down to zero replicas. The last two events happened at the same time, so in your case, their order might be reverted.

![Figure 17-7: Canary deployment rollout](images/ch17/canary-rollout.png)

We finally found a big difference between `Canary` and `RollingUpdate` deployments. That difference was in the evaluation of the metrics as a way to decide whether to proceed or not with the rollout. Given that everything worked correctly. We are yet to see what would happen if one of the metrics reached the threshold.

We're finished exploring the happy path, and we can just as well stop the loop. There's no need, for now, to continue sending requests. But, before we do that, I should explain that there was a reason for the loop beside the apparent need to see the progress.

If we were not sending requests to the application, there would be no metrics to collect. In such a case, Flagger would think that there's something fishy with the new release. Maybe it was so bad that no one could send a request to our application. Or maybe there was some other reason. In any case, lack of metrics used to validate the release is considered a problem. For now, we wanted to see the happy path with the new release fully rolled out. The stream of requests was there to ensure that there are sufficient metrics for Flagger to say: "everything's fine; let's move on."

With that out of the way, please go back to the **second terminal**, stop the loop by pressing *ctrl+c*, and go back again to the **first terminal**.

Next, we'll see how does the "unhappy" path look.

## Rolling Back Canary Deployments

Here's the good news. Flagger will automatically roll back if any of the metrics we set fails the number of times set as the `threshold` configuration option. Similarly, it will also roll back if there are no metrics.

In our case, there are at least three ways we can run an example that would result in a rollback. We could start sending requests that would generate errors until we reach the `threshold` of the `request-success-rate` metric. Or we can create some slow requests so that `request-duration` is messed up (above `500` milliseconds). Finally, we could not send any request and force Flagger to interpret lack of metrics as an issue.

We won't do a practical exercise that would demonstrate canary deployment roll backs. To begin with, the quickstart application we're using does not have a mechanism to produce slow responses or "fake" errors. Also, such an exercise would be mostly repetion of the practices we already explored. Finally, the last reason for avoiding rollbacks lies in the scope of the subject. Canary deployments with Istio, Flaggger, Prometheus, and a few other tools are a huge subject that deserves more space than a part of a chapter. It is a worthy subject though and I will most likely release a set of articles, a book, or a course that would dive deeper into those tools and the process of canary deployments. Stay tuned.

So, you'll have to trust me when I say that if any metrics defined in the canary resource fail a few times, the result would be rollback to the previous version.

Finally, I will not show you how to implement canary deployments in production. All you have to do is follow the same logic as the one we used with *jx-progressive* in the staging environment. All you'd need to do is set the `jx-progressive.canary.enable` variable to `true` inside the `values.yaml` file in the production environment repository. The production host is already set in the chart itself.

## To Canary Or Not To Canary?

We saw one possible implementation of canary deployments with Flagger, Istio, and Prometheus. As we discussed, we could have used other tools. We could have just as well created more complex formulas that would be used to decide whether to proceed or roll back a release. Now the time has come to evaluate canary deployments and see how they fit the requirements we defined initially.

Canary deployments are, in a way, an extension of rolling updates. As such, all of the requirements fulfilled by one are fulfilled by the other.

The deployments we did using the canary strategy were highly available. The process itself could be qualified as rolling updates on steroids. New releases are initially being rolled out to a fraction of users and, over time, we were increasing the reach of the new release until all requests were going there. From that perspective, there was no substantial difference between rolling updates and canary releases. However, the process behind the scenes was different.

While rolling updates are increasing the number of Pods of the new release and decreasing those from the old, canaries are leaving the old release untouched. Instead, a new Pod (or a set of Pods) is spin up, and service mesh (e.g., Istio) is making sure to redirect some requests to the new and others to the old release. While rolling updates are becoming available to users by changing how many Pods of the new release are available, canaries are accomplishing the same result through networking. As such, canaries allow us to have much greater control over the process.

Given that with canary deployments we are in control over who sees what, we can fine-tune it to meet our needs better. We are less relying on chance and more on instructions we're giving to Flagger. That allows us to create more complicated calculations. For example, we could let only people from one country see the new release, check their reactions, and decide whether to proceed with the rollout to everyone else.

All in all, with canary deployments, we have as much high-availability as with rolling updates. Given that our applications are running in multiple replicas and that we can just as easily use HorizontalPodAutoscaler or any other Kubernetes resource type, canary deployments also make our applications as responsive as rolling updates.

Where canary deployments genuinely shine and make a huge difference is in the progressive rollout. While, as we already mentioned, rolling updates give us that feature as well, the additional control of the process makes canary deployments true progressive rollout.

On top of all that, canary deployments were the only ones that had a built-in mechanism to roll back. While we could extend our pipelines to run tests during and after the deployment and roll back if they fail, the synergy provided by canary deployments is genuinely stunning. The process itself decides whether to roll forward, to temporarily halt the process, or to roll back. Such tight integration provides benefits which would require considerable effort to implement with the other deployment strategies. I cannot say that only canary deployments allow us to roll back automatically. But, it is the only deployment strategy that we explored that has rollbacks integrated into the process. And that should come as no surprise given that canary deployments rely on using a defined set of rules to decide when to progress with rollouts. It would be strange if the opposite is true. If a machine can decide when to move forward, it can just as well decide when to move back.

Judging by our requirements, the only area where the `Canary` deployment strategy is not as good or better than any other is cost-effectiveness. If we want to save on resources, serverless deployments are in most cases the best option. Even rolling updates are cheaper than canaries. With rolling updates, we replace one Pod at the time (unless we specify differently). However, with `Canary` deployments, we keep running the full old release throughout the whole process, and add the new one in parallel. In that aspect, canaries are similar to blue-green deployments, except that we do not need to duplicate everything. Running a fraction (e.g., one) of the Pods with the new release should be enough.

All in all, canaries are expensive or, at least, more expensive than other strategies, excluding blue-green that we already discarded.

All in all, canary deployments, at least the version we used, provide **high-availability**. They are **responsive**, and they give us **progressive rollout** and **automatic rollbacks**. The major downside is that they are **not** as **cost-effective** as some other deployment strategies.

The summary of the fulfillment of our requirements for the `Recreate` deployment strategy is as follows.

|Requirement        |Fullfilled|
|-------------------|----------|
|High-availability  |Fully     |
|Responsiveness     |Fully     |
|Progressive rollout|Fully     |
|Rollback           |Fully     |
|Cost-effectiveness |Not       |

The last piece of the canary puzzle is to figure out how to visualize canary deployments.

## Visualizing Rollouts Of Canary Deployments

Jenkins X Flagger addon includes Grafana with a dashboard that we can use to see metrics related to canary deployments visually. However, there is a tiny problem. Grafana Ingress was not created so, for now, Grafana's UI is not accessible. We'll fix that easily by creating an Ingress pointing to the Grafana service. For that, first we need to find out the IP of the Ingress controller.

Please note that the commands that follow will differ depending on whether you are using EKS or some other Kubernetes provider.

W> Please run the command that follows only if you are **NOT** using **EKS** (e.g., **GKE**, **AKS**, etc.).

```bash
LB_IP=$(kubectl \
    --namespace kube-system \
    get svc jxing-nginx-ingress-controller \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```

W> Please run the commands that follow only if you are using **EKS**.

```bash
LB_HOST=$(kubectl \
    --namespace kube-system \
    get svc jxing-nginx-ingress-controller \
    --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')

export LB_IP="$(dig +short $LB_HOST \
    | tail -n 1)"
```

Finally, you might not be using Ingress controller installed by Jenkins X. For example, you might be using the "official" NGINX Ingress (the one from Jenkins X is a variation of it). If that's the case, you'll have to modify the command(s) to fit your situation.

No matter how we retrieved the IP of the external load balancer, we'll output it as a way to have a visual confirmation that it looks OK.

```bash
echo $LB_IP
```

Now that we have the IP, we can create the missing Ingress.

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

I> Do not create resources with ad-hoc commands like the one we just executed. That is undocumented and hard to reproduce. Store everything in a declarative format (e.g., YAML) in a Git repository and let Jenkins X deal with its deployment. We did what we did only to make it easy, not as a suggestion to follow the same practice in "real world" situations.

With Ingress defined, we can, finally, open Grafana UI.

```bash
open "http://flagger-grafana.$LB_IP.nip.io"
```

Just as Istio is not the main subject of this book, neither is Grafana. So, we won't go into details. I expect you to figure them out yourself. Instead, we'll take a quick look at the predefined Flagger dashboard.

Please select *Dashboards* from the left-hand menu, click the *Manage* button, and select *Istio Canary*,

The dashboard is in front of us, and I'll leave you to explore it. But, before I go, please note that to visualize the process, you should make yet another change to the source code, push it to GitHub, and wait until the pipeline-initiated canary deployment starts. From there on, please select `jx-staging` as the *namespace*, choose `jx-progressive-primary` as *primary* and `jx-progressive` as *canary*. Now you should be able to visualize the process.

![Figure 17-9: The dashboard with visualizations related to canary deployments](images/ch17/canary-grafana.png)

That's all I'm going to say about Grafana. It's not the focus of this book, so you're on your own if you're not already familiar with it. Right now, we are left with the last and potentially the most important discussion.

## Which Deployment Strategy Should We Choose?

We saw some of the deployment strategies. There are others, and this chapter does not exclude you from exploring them. Please do that. The more you learn, the more educated decisions you'll make. Still, until you figure out all the other strategies and variations you can do, we accumulated enough material to talk summarize what we learned so far.

Can we conclude that canary deployments are the best and that everyone should use them for all their applications? Certainly not. To begin with, if an application is not eligible for rolling updates (e.g., a single replica app), it is almost certainly not suitable for canary deployments. If we think of canaries as extensions of rolling updates, if an app is not a good candidate for the latter, it will also not be fit for the former. In other words, there is a good use case for using the `Recreate` strategy in some cases, specifically for those applications that cannot (or shouldn't) use one of the other strategies.

So, if both `Canary` and `Recreate` strategies have their use cases, can we discard rolling updates and serverless?

Rolling updates should, in most cases, we replaced with canary deployments. The applications eligible for one deployment strategy qualify for the other, and canaries provide so much more. If nothing else, they give us a bigger safety net. The exceptions would be tiny clusters serving small teams. In those cases, the resource overhead added by a service mesh (e.g., Istio) and metrics collector and database (e.g., Prometheus) might be too much. Another advantage of rolling updates is simplicity. There are no additional components to install and manage, and there are no additional YAML files. Long story short, canary deployments could easily replace all your rolling updates, as long as the cost (on resources and operations) is not too high for your use case.

That leaves us with serverless (e.g., Knative). It would be hard for me to find a situation in which there is no use for serverless deployments. It has fantastic scaling capabilities on its own that can be combined with HorizontalPodAutoscaler. It saves us money by shutting (almost) everything down when our applications are not in use.

Knative ticks all the boxes, and the only downside is the deployment process itself, which is more elaborated with canaries. The more important potential drawback is that scaling from nothing to something can introduce a delay from the user's perspective. Nevertheless, that is rarely a problem. If an application is unused for an extended period, users rarely complain when they need to wait for an additional few seconds for the app to wake up.

So, we are in a situation where one solution (`Canary`) provides better capabilities for the deployment process itself, while the other (serverless) might be a better choice as a model for running applications. Ultimately, you'll need to make a choice. What matters more? Is it operational cost (use serverless) or deployment safety net (use canary)? You might be able to combine the two but, at the time of this writing (August 2019), that is not that easy since the integration is not available in Flagger or other similar tools.

What is essential, though, is that it is not the winner-takes-all type of a decision. We can use `Recreate` with some applications, `RollingUpdate` with others, and so on. But it goes beyond choosing a single deployment strategy for a single application. Deployment types can differ from one environment to the other. Canaries, for example, are not a good choice for preview environments. All we'd get is increased time required to terminate the deployment process and potential failures due to the lack of metrics.

Let's make a quick set of rules when to use one deployment strategy over the other. Bear in mind that what follows is not a comprehensive list but rather elevator pitch for each deployment type.

Use the **recreate** strategy when working with legacy applications that often do not scale, that are stateful without replication, and are lacking other features that make them not cloud-native.

Use the **rolling update** strategy with cloud-native applications which, for one reason or another, cannot use canary deployments.

Use the **canary** strategy instead of **rolling update** when you need the additional control when to roll forward and when to roll back.

Use **serverless** deployments in permanent environments when you need excellent scaling capabilities or when an application is not in constant use.

Finally, use **serverless** for all the deployments to preview environments, no matter which strategy you're using in staging and production.

Finally, remember that your Kubernetes cluster might not support all those choices, so choose among those that you can use.

## What Now?

We dived into quite a few deployment strategies. Hopefully, you saw both the benefits and the limitations of each. You should be able to make a decision on which route to take.

Parts of this chapter might have been overwhelming if you do not have practical knowledge of the technologies we used. That is especially true for Istio. Unfortunately, we could not dive into it in more detail since that would derail us from Jenkins X. Knative, Istio, and others each deserve a book or a series of articles themselves.

I> If you are eager to learn more about Istio, Flagger, and Prometheus in the context of canary deployments, you might want to explore the [Canary Deployments To Kubernetes Using Istio and Friends](https://www.udemy.com/course/canary-deployments-to-kubernetes-using-istio-and-friends/?referralCode=75549ECDBC41B27D94C4) course in Udemy. Occasionally, I will be posting coupons with discounts on my [Twitter](https://twitter.com/vfarcic) and [LinkedIn](https://www.linkedin.com/in/viktorfarcic/) accounts, so you might want to subscribe to one of those (if you're not already).

That's it. That was a long chapter, and you deserve a break.

If you created a cluster only for the exercises we executed, please destroy it. We'll start the next, and each other chapter from scratch as a way to save you from running your cluster longer than necessary and pay more than needed to your hosting vendor. If you created the cluster or installed Jenkins X using one of the Gists from the beginning of this chapter, you'll find the instructions on how to destroy the cluster or uninstall everything at the bottom of those Gists.

If you did choose to destroy the cluster or to uninstall Jenkins X, please remove the repositories we created as well as the local files. You can use the commands that follow for that. Just remember to replace `[...]` with your GitHub user and pay attention to the comments.

```bash
cd ..

GH_USER=[...]

hub delete -y \
    $GH_USER/environment-jx-rocks-staging

hub delete -y \
    $GH_USER/environment-jx-rocks-production

hub delete -y \
    $GH_USER/jx-progressive

rm -rf environment-jx-rocks-staging

rm -rf $GH_USER/jx-progressive
```

Finally, you might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just keep reading.
