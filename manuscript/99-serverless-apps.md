## TODO

- [X] Code
- [ ] Write
- [ ] Code review static GKE
- [X] Code review serverless GKE
- [ ] Code review static EKS
- [ ] Code review serverless EKS
- [ ] Code review static AKS
- [ ] Code review serverless AKS
- [ ] Code review existing static cluster
- [ ] Code review existing serverless cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to workshop slides
- [ ] Add to talk slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com
- [ ] Convert https://www.devopstoolkitseries.com to Knative
- [ ] Create a PR to add the app to `jx get applications`

TODO: https://github.com/jenkins-x/jx/issues/4668

# Using Jenkins X To Define And Run Serverless Deployments

W> The examples in this chapter work both in **static** and **serverless** Jenkins X.

We already saw how we can run serverless flavor of Jenkins X. That helped with many things, better resource utilization and scalability being only a few of the advantages. Can we do something similar with our applications? Can we scale them to zero when noone uses them? Can we scale them up when the number of concurent requests increases? Can we make ouor applications serverless? Let's start from the begining and discuss serverless computing.

## What is Serverless Computing?

To understand serverless computing, one needs to understand the challenges we are facing with more "traditional" types of deployments of our applications. A long time ago, most of us were deploying our apps directly to servers. We had to decide the size (memory and CPU) of the nodes where our applications would run, we had to create those servers, and we had to maintain them. The situation improved with the emergence of cloud computing. We still had to do all those things, but now those tasks were much easier due to the simplicity of the APIs and services cloud vendors gave us. Suddenly, we had (a perception of) infinite resources and all we had to do is run a command, and a few minutes later the servers (VMs) we needed would materialize. Things become much easier and faster. But, that did not remove the tasks of creating and maintaining servers. Instead, that made them more straightforward. Concepts like immutability become mainstream as well. As a result, we got much-needed reliability, reduced drastically lean time, and started to rip benefits of elasticity.

Still, some important questions were left unanswered. Should we keep our servers running even when our applications are not serving any requests? If we shouldn't, how can we ensure that they are readily available when we do need them? Who should be responsible for the maintenance of those servers? Is it our infrastructure department, our cloud provider, or can we build a system that will do that for us without human intervention?

Things changed with the emergence of containers and schedulers. After a few years of uncertainty created by having too many options on the table, the situation stabilized around Kubernetes that become the de-facto standard. At roughly the same time, in parallel with the rise of popularity of containers and schedulers, solutions for serverless computing concepts started to materialize. Those solutions were not related to each other or, to be more precise, they were not during the first few years. Kubernetes provided us with means to run microservices as well as more traditional types of applications, while serverless focused on running functions (often only a few lines of code).

The name serverless is misleading by giving the impression that they are no servers involved. They are certainly still there, but the concept and the solutions implementing them allow us (users) to ignore their existence. The major cloud providers (AWS, Microsoft Azure, and Google) all came up with solutions for serverless computing. Developers could focus on writing functions with a few additional lines of code specific to our serverless computing vendor. Everything else required for running and scaling those functions become transparent.

But not everything is excellent in the serverless world. The number of use-cases that can be fulfilled with writing functions (as opposed to applications) is limited. Even when we do have enough use-cases to make serverless computing worthwhile effort, a more significant concern is lurking just around the corner. We are likely going to be locked to a vendor given that none of them implements any type of industry standard. No matter whether we choose AWS Lambda, Azure Functions, or Google Cloud Functions, the code we write will not be portable from one vendor to another. That does not mean that there are no serverless frameworks that are not tied to a specific cloud provider. There are, but we'd need to maintain them ourselves, be it on-prem or inside clusters running in a public cloud. That removes one of the most essential benefits of serverless concepts.

That's where Kuberentes comes into play.

## Serverless Deployments In Kubernetes

At this point, I must make an assumption that you, dear reader, might dissagree with. Most of the companies will run at least some (if not all) of their applications in Kubernetes. It is becoming (or it already is) a standard API that will be used by (almost) everyone. Why is that assumption important? If I am right, then (almost) everyone will have a Kubernetes cluster. Everyone will spend time maintaining it, and everyone will have some level of in-house knowledge of how it works. If that assumption is correct, it stands to reason that Kubernetes would be the best choice of a platform to run serverless applications as well. That would avoid vendor lock-in since Kubernetes can run (almost) anywhere.

Kubernetes-based serverless computing would provide quite a few other benefits. We could be free to write our applications in any language, instead of being limited by those supported by function-as-a-service solutions offered by cloud vendors. Also, we would not be limited to writing only functions. A microservice or even a monolith could run as a serverless application. We just need to find a solution to make that happen. After all, proprietary cloud-specific serverless solutions use containers (of sorts) as well, and the standard mechanism for running containers is Kubernetes.

There is an increasing number of Kubernetes platforms that allow us to run serverless applications. We won't go into all of those, but fastrack the conversation by me stating that Knative is likely going to become the de-facto standard how to deploy serverless load to Kubernetes.

[Knative](https://knative.dev/) is an open source project that delivers components used to build and run serverless applications on Kubernetes. We can use it to scale-to-zero, to autoscale, for in-cluster builds, and as an eventing framework for applications on Kubernetes. The part of the project we're interested in right now is its ability to convert our applications into serverless deployments. That should allow us both to save resources (memory and CPU) when our applications are idle, as well as to scale them fast when trafic increases.

Now that we discussed what is serverless and that I made an outlandish statement that Kubernetes is the platform where your serverless applications should be running, let's talk which types of scenarios are a good fit for serverless deployments.

## Which Types Of Applications Should Run As Serverless?

Initially, the idea was to have only functions running as serverless loads. Those would be single-purpose pieces of code that contain only a small number of lines of code. A typical example of a serverless application would be an image processing function that responds to a single request and can run for a limited period. Restrictions like the size of applications (functions) and their maximum duration are imposed by implementations of serverless computing in cloud providers. But, if we adopt Kubernetes as the platform to run serverless deployments, those restrictions might not be valid anymore. We can say that any application that can be packaged into a container image can run as a serverless deployment in Kubernetes. That, however, does not mean that any container is as good of a candidate as any other. The smaller the application or, to be more precise, the faster its boot-up time is, the better the candidate for serverless deployments.

However, things are not as straight forward as they may seem. Not being a good candidate does not mean that one should not compete at all. Knative, as many other serverless frameworks do allow us to fine-tune configurations. We can, for example, specify with Knative that there should never be less than one replica of an application. That would solve the problem of slow boot-up while still maintaining some of the benefits of serverless deployments. In such a case, there would always be at least one replica to handle requests, while we would benefit from having the elasticity of serverless providers.

The size and the booot-up time are not the only criteria we can use to decide whether an application should be serverless or not. We might want to consider traffic as well. If, for example, our app has high traffic and it receives requests throughout the whole day, we might never need to scale it down to zero replicas. Similarly, our application might not be designed in a way that every request is processed by a different replica. After all, most of the apps can handle a vast number of requests by a single replica. In such cases, serverless computing implemented by cloud vendors and based on function-as-a-service might not be the right choice. But, as we already discussed, there are other serverless platforms, and those based on Kubernetes do not follow those rules. Since we can run any container as serverless, any type of applications can be deployed as such, and that means that a single replica can handle as many requests as its design allows. Also, Knative and other platforms can be configured to have a minimum number of replicas, so they might be well suited even for the applications with a constant flow of traffic.

All in all, if it can run in a container, it can be converted into a serverless deployment, as long as we understand that smaller applications with faster boot-up times are better candidates than others. If there is a rule we should follow when deciding whether to run an application as serverless, it is related to the state. Or, to be more precise, the luck of it. If an application is stateless, it might be the right candidate for serverless computing.

Now, let us imagine that you have an application that is not the right candidate to be serverless. Does that mean that we cannot rip any benefit from frameworks like Knative? We can since there is still the question of deployments to different environments.

Typically, we have permanent and temporary environments. The examples of the former would be staging and production. If we do not want our application to be serverless in production, we will probably not want it to be any different in staging. Otherwise, the behavior would be different, and we could not say that we tested precisely the same behavior as the one we expect to run in production. So, in most cases, if an application should not be serverless in production, it should not be serverless in any other permanent environment. But, that does not mean that it shouldn't be serverless in temporary environments.

Let's take an environment in which we deploy an application as a result of making a pull request as an example. It would be a temporary environment since we'd remove it the moment that pull request is closed. Its time span is relatively short. It could exist for a few minutes, but sometimes that could be days or even weeks. It all depends on how fast we are in closing pull requests.

Nevertheless, there is a high chance that the application deployed in such temporary environment will have low trafic. We would typically run a set of automated tests when the pull request is created or when we make changes to it. That would certainly result in a traffic spike. But, after that, the traffic would be much lower and most of the time non-existent. We might open the application to have a look at it, we might run some manual tests, and then we would wait for the pull request to be approved or for someone to push additional changes if we found some issues or inconsistencies. That means that the deployment in question would be unused most of the time. Still, if it would be a "traditional" deployment, it would oocupy resources for no particular reason. That might even discourage us from making temporary environments due to high costs.

Given that  deployments based on pull requests are not used for final validations before deploying to production (that's what permanent environments are for), we do not need to insist that they are the same as production. On the other hand, the applications in such environments are mostly unused. Those facts lead us to conclude that temporary (often pull-request based) environments are a great candidate for serverless deployments, no matter the deployment type we use in permanent environments (e.g., staging and production).

Now that we saw some of the use cases for serverless computing, there is still an important one that we did not discuss.

## Why Do We Need Jenkins X To Be Serverless?

There are quite a few problems with the traditional Jenkins. Most of us already know them, so I'll repeat them only briefly. Jenkins (without X) does not scale, it is not fault-tolerant, it's resource usage is heavy, it is slow, it is not API-driven, and so on. In other words, it was not designed yesterday, but when those things were not as important as they are today. Jenkins had to go away for Jenkins X to take its place.

Initially, Jenkins X had a stripped-down version of Jenkins but, since the release 2, not a single line of the traditional Jenkins is left in Jenkins X. Now it is fully serverless thanks to Tekton and a lot of custom code written from scratch to support the need for a modern Kubernetes-based solution. Excluding a very thin layer that mostly acts as an API gateway, Jenkins X is fully serverless. Nothing runs when there are no builds, and it scales to accommodate any load. And that might be the best example of serverless computing we can have.

Coontinuous integration and continuous delivery flows are temporary by their nature. When we make a change to a Git repository, it notifies the cluster, and a set of processes are spun. Each Git webhook request results in a pipeline run that builds, validates, and deploys a new release and, once those processes are finished, it dissapears from the system. Nothing is executing when there are no pipeline runs, and we can have as many of them in parallel as we need. It is elastic and resource-efficient, and the heavy lifting is done by Tekton.

Continuous integration and continuous delivery tools are probably one of the best examples of a use-case that fits well in serverless computing concepts.

## What Is Tekton And How Does It Fix Jenkins X?

Those of you using serverless Jenkins X already experienced Knative, of sorts. Tekton is a spin-off project of Knative, and it is the essential component in the solution. It is in charge of creating pipeline runs (a special type of Pods) when needed and destroying them when finished. Thanks to Tekton, the total footprint of serverless Jenkins X is very small when idle. Similarly, it allows the solution to scale to almost any size when that is needed.

Tekton is designed only for "special" type of processes, mostly those associated with continuous integration and continuous delivery pipelines. It is not, however, suited for long-running applications designed to handle requests. So, why am I talking about Tekton if it does not allow us to run our applications as serverless? The answer lies in Tekton's father.

Tekton is a Knative spin-off. It was forked from it in hopes to provide better CI/CD capabilities. Or, to be more precise, Tekton was born out of the [Knative Build](https://knative.dev/docs/build/) component, which is now considered deprecated. But, Knative still stays the most promising way to run serverless applications in Kubernetes. It is the father of Tekton, which we've been using for a while now given that it is an integral part of serverless Jenkins X.

Now, I could walk you through the details of Knative definitions, but that would be out of the scope of this subject. It's about Jenkins X, not about Knative and other platforms for running serverless application. But, my unwilingness to show you the ups and downs of Knative does not mean that we cannot use it. As a matter of fact, Jenkins X already provides means to select whether we want to create a quickstart or import an existing project that will be deployed as a serverless application using Knative. We just need to let Jenkins X know that's what we want, and it'll do the heavy lifing of creating the definition (YAML file) that we need.

So, Jenkins X is an excellent example of both a set of serverless applications that constitute the solution, as well as a tool that allows us to convert our existing applications into serverless deployments. All we have to do to accomplish the latter is to express that as our desire, and Jenkins X will do all the heavy lifting of creating the correct definitions for our applications as well as to move them through their life cycles.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [TODO:](TODO:) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new static **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new static **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new static **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** static cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

I> The commands that follow will reset your *go-demo-6* `master` branch with the contents of the branch that contain all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

W> Depending on whether you're using static or serverless Jenkins X flavor, we'll need to restore one branch or the other. The commands that follow will restore `extension-model-jx` if you are using static Jenkins X, or `extension-model-cd` if you prefer the serverless flavor.

```bash
NAMESPACE=$(kubectl config view \
    --minify \
    --output jsonpath="{..namespace}")

cd go-demo-6

git pull

git checkout extension-model-$NAMESPACE

git merge -s ours master --no-edit

git checkout master

git merge extension-model-$NAMESPACE

git push

cd ..
```

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
cd go-demo-6

jx import --pack go --batch-mode

cd ..
```

Now we are ready to work on creating the first serverless application using Knative.

## Installing Gloo and Knative

TODO: Is this the first time we're using addons? If it is, explain them.

We could visit Knative documentation and follow the instructions how to install it and configure it. Then we could reconfigure Jenkins X to use it. But we won't do any of that, because Jenkins X already comes with a method to install and integrate Knative. To be more precise, Jenkins X allows us to install Gloo addon which, in turn, will install Knative.

[Gloo](https://gloo.solo.io/) is a Kubernetes ingress controller, and API gateway. The main reason for using it in our context is because of its ability to route requests to applications managed and autoscaled by Knative. The alternative to Gloo would be Istio which, even though is very popular is too heavy and complex.

Now that we know the "elevator pitch" for Gloo, we can proceed and install it.

```bash
jx create addon gloo
```

W> TODO: EKS: waiting for external IP on Gloo cluster ingress proxy service clusteringress-proxy in namespace gloo-system ...

Judging from the output, we can see that the process checked whether `glooctl` is installed and, if it isn't, it set it up for us. The command line tool has quite a few features but the only one that matters (for now) is that it installs Knative. Furter on, the process installed Gloo and Knative in our cluster and it configured our team to use `knative` as the default deployment kind. What that means is that, from now on, every new application we add through a quickstart or by importing an existing project will be deployed as Knative.

The default deployment mechanism can be changed at any time.

Let's take a closer look at what we got by exploring the Namespaces.

```bash
kubectl get namespaces
```

The output is as follows.

I> The outputs are from serverless Jenkins X running in GKE. If you're using a different combination, you might experience some differences when comparing the output from this book with the one on your screen.

```
NAME            STATUS AGE
cd              Active 66m
cd-production   Active 59m
cd-staging      Active 59m
default         Active 67m
gloo-system     Active 2m1s
knative-serving Active 117s
kube-public     Active 67m
kube-system     Active 67m
```

We can see that we got a two new Namespaces. As you can probably guess, `gloo-system` contains Gloo components, while Knative runs in `knative-serving`. Keep in mind that we did not get all the Knative components, but only `serving`, which is in charge of running Pods as serverless loads.

Now, I could go into details and explan the function of every Pod, service, CRD, and other components running in `gloo-system` and `knative-serving` Namespaces. But I feel that would be a waste of time. You can get that information yourself by exploring Kubernetes resources running in those Namespaces, or by going through the official documentation. What matters, for now, is that we got everything Jenkins X needs to convert your applications into serverless deplooyments.

From now on, all our new projects will be running as serverless deployments. Later on, I'll show you how to switch one project from being serverless to "traditional", and vice versa. But, for now, we'll imagine that we do not want new projects to be serverless by default. We can ractify that by editing deployment settings for the whole team (Jenkins X installation).

```bash
jx edit deploy \
    --team \
    --kind default \
    --batch-mode
```

The output should confirm that `the team deploy kind` was set to `default`. That happens to be a very bad name that really means "traditional" non-serverless deployments.

But what if we made a mistake and we do want all new projects to be serverless, unless the author specifies something different? As you can probably guess, all we have to do is execute a similar command, but with the different value for the `kind` argument.

```bash
jx edit deploy \
    --team \
    --kind knative \
    --batch-mode
```

From this moment on, all new projects will be serverless, unless we say otherwise. So, let's create a new project and check it out.

## Creating A New Project With A Serverless Application

Jenkins X does its best to be easy for everyone and not to introduce unnecessary complexity. True to that goal, there is nothing "special" users need to do to create a new project with serverless deployments. There is no additinal command, nor there are any extra arguments. The `jx edit deploy` command already told Jenkins X that we want all new projects to be serverless by default, so all there is for us to do is to create a new quick start.

```bashs
jx create quickstart \
    --language go \
    --project-name jx-knative \
    --batch-mode
```

As you can see, that command was no different than any other quick start we created earlier. We needed a project with a unique name so that only (irrelevant) change is that this noe is called `jx-knative`.

If you look at the output, there is nothing new there either. If someone else changed team's deployment kind, you would not even know that quick start will end with the first release running in the staging environment in serverless fashion.

There is one different though, and we need too enter the project directory to find it.

```bash
cd jx-knative
```

Now, there is only one value that matters, and it is located in `values.yaml`.

```bash
cat charts/jx-knative/values.yaml
```

The output, limited to the relevant parts, is as follows.

```yaml
...
# enable this flag to use knative serve to deploy the app
knativeDeploy: true
...
```

As you can see, the `knativeDeploy` variable is set to `true`. All the past projects, at least those created after May 2019, had that value set to `false`, simply because we did not have the Gloo addon installed and our team deployment setting was set to `default` instead of `knative`. But, now that we changed that, `knativeDeploy` will be set to `true` for all the new projects, unless chanrge the deployment setting again.

Now, you might be thinking to yourself that a Helm variable does not mean much by itself unless it is used. If that's what's passing through your head, you are right. It is only a variable, and we are yet to discover the reason for its existence.

Let's take a look at what we have in the Chart's templates directory.

```bash
ls -1 charts/jx-knative/templates
```

The output is as follows.

```
NOTES.txt
_helpers.tpl
deployment.yaml
ksvc.yaml
service.yaml
```

We are already familiar with `deployment.yaml` and `service.yaml` files, but we might have missed a crucial detail. So, let's take a look at what's inside one of them.

```bash
cat charts/jx-knative/templates/deployment.yaml
```

The output, limited to the top and the bottom parts, is as follows.

```yaml
{{- if .Values.knativeDeploy }}
{{- else }}
...
{{- end }}
```

We have the `{{- if .Values.knativeDeploy }}` that immediatelly continues into `{{- else }}`, while the whole definition of the deployment is between `{{- else }}` and `{{- end }}`. While that might look strange at the first look, it actually means that the Deployment resource should be created only if `knativeDeploy` is set to `false`. If you take a look at the `service.yaml` file you'll notice the same pattern. In both cases, the resources are created only if we did not select to use Knative deployments. And that brings us to the `ksvc.yaml` file.

```bash
cat charts/jx-knative/templates/ksvc.yaml
```

The output is as follows.

```yaml
{{- if .Values.knativeDeploy }}
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
{{- if .Values.service.name }}
  name: {{ .Values.service.name }}
{{- else }}
  name: {{ template "fullname" . }}
{{- end }}
  labels:
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
            imagePullPolicy: {{ .Values.image.pullPolicy }}
            env:
{{- range $pkey, $pval := .Values.env }}
            - name: {{ $pkey }}
              value: {{ quote $pval }}
{{- end }}
            livenessProbe:
              httpGet:
                path: {{ .Values.probePath }}
              initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
              periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
              successThreshold: {{ .Values.livenessProbe.successThreshold }}
              timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
            readinessProbe:
              httpGet:
                path: {{ .Values.probePath }}
              periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
              successThreshold: {{ .Values.readinessProbe.successThreshold }}
              timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
            resources:
{{ toYaml .Values.resources | indent 14 }}
{{- end }}
```

To begin with, you can see that the conditional logic is reversed. The resource defined in that file will be created only if the `knativeDeploy` is set to `true`.

We won't go into details of the specification. I'll only say that it is similar to what we'd define as a Pod specification, and leave you to explore [Knative Serving API spec](https://github.com/knative/serving/blob/master/docs/spec/spec.md#resource-yaml-definitions) on your own. Where Knative definition differs greatly from what we're used when, let's say, we work with Deployments and StatefulSets, is that we do not need to specify many of the things. There is no need for creating a Deployment, that defines a ReplicaSet, that defines Pod templates. There is no definition of a Service associated with the Pods. Knative will create all the objects required to convert our Pods into a scalable solution accessible to our users.

We can think of the Knative definition as being more developer-friendly than other Kubernetes resources. It greatly simplifies things by making some assumptions. All the Kubernetes resources we're used to seeing (e.g., Deployment, ReplicaSet, Service) will still be created together with quite a few others. The major difference is not only in what will be running in Kubernetes, but also in how we define what we need. By focusing only on what really matters, Knative removes clutter from YAML files we normally tend to create.

Now, let's see whether the activity of the pipeline run initiated by pushing the initial commit to the newly created repository is finished.

```bash
jx get activities \
    --filter jx-knative \
    --watch
```

Unless you are the fastest reader on earth, the pipeline run should have finished and you'll notice that the is no difference in the steps. It is the same no matter whether we are using serverless or any other type of deployment. So, feel free to stop the activity by pressing *ctrl+c*, and we'll take a look at the Pods and see whether that shows anything interesting.

Before we take a look at the Pod of the new application deployed to the staging environment, we'll confirm that the latest run of the staging environment pipeline is finished.

```bash
jx get activities \
    --filter environment-tekton-staging/master \
    --watch
```

Feel free to press *ctrl+c* when the staging environment pipeline run is finished.

Now we can have a look at the Pod running as part of our serverless application.

```bash
kubectl --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

The output is as follows.

```
NAME           READY STATUS  RESTARTS AGE
jx-knative-... 2/2   Running 0        84s
```

W> If the output states that `no resources` were `found`, the Pod enough time passed without any traffic and the application was scaled to zero replicas. We'll see a similar effect and comment on it a few more times. Just keep in mind that the next command that describes the Pod will not work since it was already removed.

The Pod is there, as we expected. The strange thing is the number of Pods. There are two, even though our application needs only one. Let's describe the Pod and see what we'll get.

```bash
kubectl --namespace cd-staging \
    describe pod \
    --selector serving.knative.dev/service=jx-knative
```

The output, limited to the relevant parts, is as follows.

```yaml
...
Containers:
  ...
  queue-proxy:
    ...
    Image:     gcr.io/knative-releases/github.com/knative/serving/cmd/queue@sha256:...
    ,,,
```

The `queue-proxy` container was "injected" into the Pod. It serves as a proxy responsible for request queue parameters, and it reports metrics to the Autoscaler. In other words, request are reaching our application through this container. Later on, when we explore scaling our Knative-based applicatins, that container will be the one responsible for providing metrics used to make scaling-related decisions.

Let's see which other resources were created for us.

```bash
kubectl --namespace cd-staging get all
```

The output, limited to the relevant parts, is as follows.

```
...
service/jx-knative               ...
service/jx-knative-svtns-service ...
...
deployment.apps/jx-knative-...
...
replicaset.apps/jx-knative-...
...
podautoscaler.autoscaling.internal.knative.dev/jx-knative-...
...
image.caching.internal.knative.dev/jx-knative-...
...
clusteringress.networking.internal.knative.dev/route-...
...
route.serving.knative.dev/jx-knative ...
...
service.serving.knative.dev/jx-knative ...
...
configuration.serving.knative.dev/jx-knative ...
...
revision.serving.knative.dev/jx-knative-...
```

As you can see, quite a few resources were created from a single YAML definition with a (`serving.knative.dev`) `Service`. There are some core Kuberentes resources we are likely already familiar with, like Deployment, ReplicaSet, Pod, Service. Even if that would be all we've got, we could already conclude that Knative service simplifies things since it would take us approximately double the lines in YAML to define the same things (Deployment and Service, the rest was created by those) ourselves. But, we got so much more. There are sevven or more resources created from Knative specific Custom Resource Definitions (CRDs). Their responsabilities differ. One (`podautoscaler.autoscaling`) is in charge of scaling based on the number of requests or other metrics, the other (`image.caching`) of caching of the image so that boot-up time is faster, a few are making sure that networking is working as expected, and so on and so forth. We'll get more familiar with those features later.

There is one inconvenience though. As of today (July 7), `get applications` does not report Knative-based applications correctly. 

```bash
jx get applications --env staging
```

The output is as follows.

```
APPLICATION STAGING PODS URL
go-demo-6   1.0.221 3/3  http://go-demo-6.cd-staging.35.190.185.247.nip.io
knative     svtns
```

The `go-demo-6` application is reported correctly, but the one based on Knative is not. Hopefully, that will be fixed soon. Until then, feel free to monitor the progress through the [issue 4635](https://github.com/jenkins-x/jx/issues/4635).

Knative defines its own Service that, just like those available in the Kubernetes core, can be queried to get the domain through which we can access the application. We can query it just as we would query the "normal" Service, the main difference being that it is called `ksvc`, instead of `svc`. We'll use it to retrieve the domain through which we can access and, therefore, test whether the newly deployed serverless application works as expected.

```bash
ADDR=$(kubectl --namespace cd-staging \
    get ksvc jx-knative \
    --output jsonpath="{.status.domain}")

echo $ADDR
```

The output should be similar to the one that follows.

```
jx-knative.cd-staging.35.243.171.144.nip.io
```

As you can see, the pattern is the same no matter whether it is a "normal" or a Knative service. Jenkins X is making sure that the URLTemplate we explored in the [Changing URL Patterns](#upgrade-url-template) subchapter is applied no matter the type of the Service or the Ingress used to route external requests to the application. In this case, it is the default one that combines the name of the service (`jx-knative`) with the environment (`cd-staging`) and the cluster domain (`35.243.171.144.nip.io`).

Now comes the moment of truth. Is our application working. Can we access it?

```bash
curl "$ADDR"
```

The good news is that we did get the `Hello` greeting as the output, so the application is working. But, that might have been the slowest response you ever saw from such a simple application. Why did it take so long? The answer to that questions lies in the scaling nature of serverless applications. Since no one sent a request to the application before, there was no need to it to run any replica. The moment we sent the first request, Knative detected it and initiated scaling that, after a while, resulted in the first replica running inside the cluster. As a result, we received the familiar greeting, only after the image is pulled, the Pod was started, and the application inside it was initiated. Don't worry about that "slowness" since it manifests itself only initially before Knative creates the cache. You'll see soon that the boot-up time will be very fast from now on.

So, let's take a look at that "famous" Pod that was created out of thin air.

```bash
kubectl --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

The output is as follows.

```
NAME           READY STATUS  RESTARTS AGE
jx-knative-... 2/2   Running 0        24s
```

We can see a single Pod created shortwhile ago. Now, let's observe what we'll get with a little bit of patience.

Please wait for seven minutes, or more, berfore executing the command that follows.

```bash
kubectl --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

The output shows that `no resources` were `found`. The Pod is gone. No one was using our application so Knative removed it to save resources. It scaled it down to zero replicas.

If you're anything like me, you must be wondering about the conofiguration. What are the parameters governing Knative scaling decisions? Can they be fine tuned?

The configuration that governs scaling is stored in `config-autoscaler` ConfigMap.

```bash
kubectl --namespace knative-serving \
    describe configmap config-autoscaler
```

The output is tooo big to be presented in a book. It is a well documented configuration example that explains what we'd need to do too change any aspect of Knative's scaling logic.

In a nutshel, Knative's scaling algorythm is based no the average number of concurrent requests. By default, it will try to target hundred parallel requests served by a single Pod. That would mean that if there are three hundred concurent requests, the system should scale to three replicas so that each can handle a hundred.

Now, the calculation for the number of Pods is not as simple as the number of concurent requests divided by hundred (or whatever we defined the `container-concurrency-target-default` to be). The Knative scaler calculated average number of parallel requests over a sixty seconds window so it takes a minute for the system to stablize at the desired level of concurrency. There is also a six seconds window that might make the system enter into the panic mode if during that period the number of requests is more than double of the target concurrency.

I'll let you goo through the documentation and explore the details. What matters, for now, is that the system, as it is now, should scale the number of Pod if we send it more than a hundred parallel requests. But, before we do that, we'll check whether the application scaled down to zero replicas.

```bash
kubectl --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

If the output states that `no resources` were `found`, the Pods are gone, and we can proceed. Otherwise, wait for a while longer and repeat the previous command.

We ensured that no Pods are running only to simplify the "experiment" that follow. When nothing is running, the calculation is as simple as the number of concurent requests divided by the target concurrency equals the number of replicas. Otherwise, the calculation would be more complicated than that and our "experiment" would need to be more elaborated.

So, we want to see what happens when we send hundreds of parallel requests to the application. We'll use [siege](https://github.com/JoeDog/siege) for that. It is a small and simple tool that TODO:.

TODO: Rewrite
Siege is an open source regression test and benchmark utility. It can stress test a single URL with a user defined number of simulated users, or it can read many URLs into memory and stress them simultaneously. The program reports the total number of hits recorded, bytes transferred, response time, concurrency, and return status. Siege supports HTTP/1.0 and 1.1 protocols, the GET and POST directives, cookies, transaction logging, and basic authentication. Its features are configurable on a per user basis.

TODO: Rewrite
Most features are configurable with command line options which also include default values to minimize the complexity of the program's invocation. Siege allows you to stress a web server with n number of users t number of times, where n and t are defined by the user. It records the duration time of the test as well as the duration of each single transaction. It reports the number of transactions, elapsed time, bytes transferred, response time, transaction rate, concurrency and the number of times the server responded OK, that is status code 200.

TODO: Rewrite
Siege was designed and implemented by Jeffrey Fulmer in his position as Webmaster for Armstrong World Industries. It was modeled in part after Lincoln Stein's torture.pl and it's data reporting is almost identical. But torture.pl does not allow one to stress many URLs simultaneously; out of that need siege was born....

TODO: Rewrite
When a HTTP server is being hit by the program, it is said to be "under siege."

```bash
kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- -c 300 -t 20S "http://$ADDR/" \
     && kubectl \
     --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

TODO: Continue text

```
If you don't see a command prompt, try pressing enter.

Lifting the server siege...      done.

Transactions:                   4920 hits
Availability:                 100.00 %
Elapsed time:                  19.74 secs
Data transferred:               0.20 MB
Response time:                  1.16 secs
Transaction rate:             249.24 trans/sec
Throughput:                     0.01 MB/sec
Concurrency:                  289.50
Successful transactions:        4920
Failed transactions:               0
Longest transaction:            6.25
Shortest transaction:           0.14

FILE: /var/log/siege.log
You can disable this annoying message by editing
the .siegerc file in your home directory; change
the directive 'show-logfile' to false.
Session ended, resume using 'kubectl attach siege -c siege -i -t' command when the pod is running
pod "siege" deleted
NAME                                          READY   STATUS    RESTARTS   AGE
jx-knative-cvl52-deployment-9bb9f458c-46v8q   2/2     Running   0          18s
jx-knative-cvl52-deployment-9bb9f458c-76hw6   2/2     Running   0          20s
jx-knative-cvl52-deployment-9bb9f458c-9hd86   2/2     Running   0          18s
```

```bash
cat charts/jx-knative/templates/ksvc.yaml \
    | sed -e \
    's@revisionTemplate:@revisionTemplate:\
        metadata:\
          annotations:\
            autoscaling.knative.dev/target: "3"\
            autoscaling.knative.dev/maxScale: "5"@g' \
    | tee charts/jx-knative/templates/ksvc.yaml
```

```yaml
{{- if .Values.knativeDeploy }}
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
{{- if .Values.service.name }}
  name: {{ .Values.service.name }}
{{- else }}
  name: {{ template "fullname" . }}
{{- end }}
  labels:
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
spec:
  runLatest:
    configuration:
      revisionTemplate:
        metadata:
          annotations:
            autoscaling.knative.dev/target: "3"
            autoscaling.knative.dev/maxScale: "5"
        spec:
          container:
            image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
            imagePullPolicy: {{ .Values.image.pullPolicy }}
            env:
{{- range $pkey, $pval := .Values.env }}
            - name: {{ $pkey }}
              value: {{ quote $pval }}
{{- end }}
            livenessProbe:
              httpGet:
                path: {{ .Values.probePath }}
              initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
              periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
              successThreshold: {{ .Values.livenessProbe.successThreshold }}
              timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
            readinessProbe:
              httpGet:
                path: {{ .Values.probePath }}
              periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
              successThreshold: {{ .Values.readinessProbe.successThreshold }}
              timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
            resources:
{{ toYaml .Values.resources | indent 14 }}
{{- end }}
```

```bash
# The default `taget` is 100

git add .

git commit -m "Added Knative target"

git push

jx get activities \
    --filter jx-knative \
    --watch
```

```
...
vfarcic/jx-knative/master #2                               2m10s     2m7s Succeeded Version: 0.0.2
  from build pack                                          2m10s     2m7s Succeeded
    Credential Initializer Lpzvs                           2m10s       0s Succeeded
    Working Dir Initializer 4h879                           2m9s       0s Succeeded
    Place Tools                                             2m8s       0s Succeeded
    Git Source Vfarcic Jx Knative Master Relea Kb46s        2m7s       0s Succeeded https://github.com/vfarcic/jx-knative
    Git Merge                                               2m6s       0s Succeeded
    Setup Jx Git Credentials                                2m6s       1s Succeeded
    Build Make Build                                        2m6s      19s Succeeded
    Build Container Build                                   2m6s      23s Succeeded
    Build Post Build                                        2m6s      24s Succeeded
    Promote Changelog                                       2m5s      26s Succeeded
    Promote Helm Release                                    2m5s      32s Succeeded
    Promote Jx Promote                                      2m5s     2m2s Succeeded
  Promote: staging                                         1m29s    1m26s Succeeded
    PullRequest                                            1m29s    1m25s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/3 Merge SHA: fd329619a16ff1d524e0d7ce9666ae1c2e04e9e9
    Update                                                    4s       1s Succeeded
```

```bash
# Cancel with *ctrl+c*

jx get activities \
    --filter environment-tekton-staging/master \
    --watch
```

```
...
vfarcic/environment-tekton-staging/master #3                1m5s     1m3s Succeeded
  from build pack                                           1m5s     1m3s Succeeded
    Credential Initializer 45xmk                            1m5s       0s Succeeded
    Working Dir Initializer Vf8cm                           1m4s       0s Succeeded
    Place Tools                                             1m3s       0s Succeeded
    Git Source Vfarcic Environment Tekton Stag Z6m6s        1m2s       0s Succeeded https://github.com/vfarcic/environment-tekton-staging
    Git Merge                                               1m2s       1s Succeeded
    Setup Jx Git Credentials                                1m2s       2s Succeeded
    Build Helm Apply                                        1m1s      59s Succeeded
```

```bash
# Cancel with *ctrl+c*

kubectl --namespace cd-staging get ksvc
```

```
NAME         DOMAIN                                       LATESTCREATED      LATESTREADY        READY   REASON
jx-knative   jx-knative.cd-staging.35.196.111.72.nip.io   jx-knative-2mjq9   jx-knative-2mjq9   True
```

```bash
curl "http://$ADDR/"
```

```bash
# Repeat if `jx-knative-*` Pods of the last release are still running

kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- -c 500 -t 60S "http://$ADDR/" \
     && kubectl \
     --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

```
If you don't see a command prompt, try pressing enter.

Lifting the server siege...      done.

Transactions:                  19078 hits
Availability:                 100.00 %
Elapsed time:                  59.63 secs
Data transferred:               0.78 MB
Response time:                  1.04 secs
Transaction rate:             319.94 trans/sec
Throughput:                     0.01 MB/sec
Concurrency:                  332.52
Successful transactions:       19078
Failed transactions:               0
Longest transaction:            8.29
Shortest transaction:           0.01

FILE: /var/log/siege.log
You can disable this annoying message by editing
the .siegerc file in your home directory; change
the directive 'show-logfile' to false.
Session ended, resume using 'kubectl attach siege -c siege -i -t' command when the pod is running
pod "siege" deleted
NAME                                           READY   STATUS    RESTARTS   AGE
jx-knative-bqj68-deployment-777b9bdc4d-59w95   2/2     Running   0          58s
jx-knative-bqj68-deployment-777b9bdc4d-5l8pb   2/2     Running   0          58s
jx-knative-bqj68-deployment-777b9bdc4d-8qm52   2/2     Running   0          61s
jx-knative-bqj68-deployment-777b9bdc4d-c52fb   2/2     Running   0          58s
jx-knative-bqj68-deployment-777b9bdc4d-j4p8h   2/2     Running   0          58s
```

```bash
# Wait for a while (e.g., 1 min)

kubectl --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

```
NAME                                          READY   STATUS    RESTARTS   AGE
jx-knative-2mjq9-deployment-677989b59-qknmj   2/2     Running   0          2m32s
```

```bash
# Wait for a while (e.g., 5-10 min)

kubectl --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

```
No resources found.
```

```bash
cat charts/jx-knative/templates/ksvc.yaml \
    | sed -e \
    's@autoscaling.knative.dev/target: "3"@autoscaling.knative.dev/target: "3"\
            autoscaling.knative.dev/minScale: "1"@g' \
    | tee charts/jx-knative/templates/ksvc.yaml
```

```yaml
{{- if .Values.knativeDeploy }}
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
{{- if .Values.service.name }}
  name: {{ .Values.service.name }}
{{- else }}
  name: {{ template "fullname" . }}
{{- end }}
  labels:
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
spec:
  runLatest:
    configuration:
      revisionTemplate:
        metadata:
          annotations:
            autoscaling.knative.dev/target: "3"
            autoscaling.knative.dev/minScale: "1"
            autoscaling.knative.dev/maxScale: "5"
        spec:
          container:
            image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
            imagePullPolicy: {{ .Values.image.pullPolicy }}
            env:
{{- range $pkey, $pval := .Values.env }}
            - name: {{ $pkey }}
              value: {{ quote $pval }}
{{- end }}
            livenessProbe:
              httpGet:
                path: {{ .Values.probePath }}
              initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
              periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
              successThreshold: {{ .Values.livenessProbe.successThreshold }}
              timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
            readinessProbe:
              httpGet:
                path: {{ .Values.probePath }}
              periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
              successThreshold: {{ .Values.readinessProbe.successThreshold }}
              timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
            resources:
{{ toYaml .Values.resources | indent 14 }}
{{- end }}
```

```bash
# It could use HPA metrics

git add .

git commit -m "Added Knative minScale"

git push

jx get activities \
    --filter jx-knative \
    --watch

# Cancel with *ctrl+c*

jx get activities \
    --filter environment-tekton-staging/master \
    --watch

# Cancel with *ctrl+c*

kubectl --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

```
NAME                                           READY   STATUS    RESTARTS   AGE
jx-knative-7j9xm-deployment-5887cfdf96-hz528   2/2     Running   0          34s
```

```bash
# Wait for 10+ minutes

kubectl --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

```
NAME                                           READY   STATUS    RESTARTS   AGE
jx-knative-7j9xm-deployment-5887cfdf96-hz528   2/2     Running   0          12m
```

## Converting Existing Projects Into Serverless Applications

```bash
# NOTE: Should send logs to a central location and monitor with Prometheus (https://knative.dev/v0.5-docs/serving/installing-logging-metrics-traces/)

cd ../go-demo-6

git checkout -b serverless

ls -1 charts/go-demo-6/templates
```

```
NOTES.txt
_helpers.tpl
deployment.yaml
service.yaml
```

```bash
# NOTE: If ksvc.yaml is not there, the project was created long time ago and it does not support KNative

TODO: Continue code

# If old
echo "knativeDeploy: false" \
    | tee -a charts/go-demo-6/values.yaml

# If old
echo "{{- if .Values.knativeDeploy }}
{{- else }}
$(cat charts/go-demo-6/templates/deployment.yaml)
{{- end }}" \
    | tee charts/go-demo-6/templates/deployment.yaml

# If old
echo "{{- if .Values.knativeDeploy }}
{{- else }}
$(cat charts/go-demo-6/templates/service.yaml)
{{- end }}" \
    | tee charts/go-demo-6/templates/service.yaml

# If old
echo '{{- if .Values.knativeDeploy }}
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
{{- if .Values.service.name }}
  name: {{ .Values.service.name }}
{{- else }}
  name: {{ template "fullname" . }}
{{- end }}
  labels:
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
            imagePullPolicy: {{ .Values.image.pullPolicy }}
            env:
            - name: DB
              value: {{ template "fullname" . }}-db
            livenessProbe:
              httpGet:
                path: {{ .Values.probePath }}
              initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
              periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
              successThreshold: {{ .Values.livenessProbe.successThreshold }}
              timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
            readinessProbe:
              httpGet:
                path: {{ .Values.probePath }}
              periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
              successThreshold: {{ .Values.readinessProbe.successThreshold }}
              timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
            resources:
{{ toYaml .Values.resources | indent 14 }}
{{- end }}' \
    | tee charts/go-demo-6/templates/ksvc.yaml

cat charts/go-demo-6/values.yaml \
    | grep knative
```

```
knativeDeploy: false
```

```bash
jx edit deploy knative
```

```
modified the helm file: /Users/vfarcic/code/go-demo-6/charts/go-demo-6/values.yaml
```

```bash
cat charts/go-demo-6/values.yaml \
    | grep knative
```

```
knativeDeploy: true
```

```bash
# If GKE
cat charts/preview/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/preview/Makefile

cat jenkins-x.yml
```

```yaml
buildPack: go
pipelineConfig:
  pipelines:
    pullRequest:
      build:
        preSteps:
        - command: make unittest
      promote:
        steps:
        - command: ADDRESS=`jx get preview --current 2>&1` make functest
```

```bash
cat jenkins-x.yml \
  | sed '$ d' \
  | tee jenkins-x.yml
```

```yaml
buildPack: go
pipelineConfig:
  pipelines:
    pullRequest:
      build:
        preSteps:
        - command: make unittest
```

```bash
# Repeat until the output does not contain the `promote` lifecycle

git add .

git commit -m "Added Knative"

git push \
    --set-upstream origin serverless
```

## Using Serverless Deployments With Pull Requests

```bash
jx create pullrequest \
    --title "Serverless with Knative" \
    --body "What I can say?" \
    --batch-mode
```

```
Created Pull Request: https://github.com/vfarcic/go-demo-6/pull/109
```

```bash
PR_GH_ADDR=[...] # e.g., https://github.com/vfarcic/go-demo-6/pull/109

BRANCH=[...] # e.g., `PR-109`

jx get activities \
    --filter go-demo-6/$BRANCH \
    --watch
```

```
vfarcic/go-demo-6/PR-115 #1                                1m31s    1m28s Succeeded
  from build pack                                          1m31s    1m28s Succeeded
    Credential Initializer 84rtk                           1m31s       1s Succeeded
    Working Dir Initializer Hvxnq                          1m30s       1s Succeeded
    Place Tools                                            1m29s       0s Succeeded
    Git Source Vfarcic Go Demo 6 Pr 115 Server Hvj28       1m28s       2s Succeeded https://github.com/vfarcic/go-demo-6
    Git Merge                                              1m27s       5s Succeeded
    Build Step2                                            1m27s      29s Succeeded
    Build Make Linux                                       1m27s      31s Succeeded
    Build Container Build                                  1m27s      35s Succeeded
    Postbuild Post Build                                   1m27s      36s Succeeded
    Promote Make Preview                                   1m26s      59s Succeeded
    Promote Jx Preview                                     1m26s    1m23s Succeeded
  Preview                                                     4s           https://github.com/vfarcic/go-demo-6/pull/115
    Preview Application                                       4s           http://go-demo-6.cd-vfarcic-go-demo-6-pr-115.34.73.141.184.nip.io
```

```bash
# Cancel with *ctrl+c*

GH_USER=[...]

PR_NAMESPACE=$(\
  echo $NAMESPACE-$GH_USER-go-demo-6-$BRANCH \
  | tr '[:upper:]' '[:lower:]')

echo $PR_NAMESPACE
```

```
cd-vfarcic-go-demo-6-pr-115
```

```bash
kubectl --namespace $PR_NAMESPACE \
    get pods
```

```
NAME                                          READY   STATUS    RESTARTS   AGE
go-demo-6-ng479-deployment-5c46757fbf-cdql8   2/2     Running   2          6m44s
preview-preview-db-856f5d4cb-ljqjw            1/1     Running   0          6m44s
```

```bash
PR_ADDR=$(kubectl --namespace $PR_NAMESPACE \
    get ksvc go-demo-6 \
    --output jsonpath="{.status.domain}")

echo $PR_ADDR
```

```
go-demo-6.cd-vfarcic-go-demo-6-pr-115.34.73.141.184.nip.io
```

```bash
curl "$PR_ADDR/demo/hello"

# NOTE: We could have clicked the *here* link in the PR and added `/demo/hello` to the end of the address

kubectl --namespace cd-staging get pods
```

```
NAME                                           READY   STATUS    RESTARTS   AGE
jx-go-demo-6-56fdbcb4c7-b5rjm                  1/1     Running   2          4h12m
jx-go-demo-6-56fdbcb4c7-whw47                  1/1     Running   1          4h12m
jx-go-demo-6-56fdbcb4c7-wn645                  1/1     Running   1          4h12m
jx-go-demo-6-db-arbiter-0                      1/1     Running   0          4h12m
jx-go-demo-6-db-primary-0                      1/1     Running   0          4h12m
jx-go-demo-6-db-secondary-0                    1/1     Running   0          4h12m
jx-knative-txdl5-deployment-7456cfddc4-n5459   2/2     Running   0          27m
```

```bash
jx repo

# Navigate to the pull request

# Merge the PR

git checkout master

git pull

jx get activities \
    --filter go-demo-6/master \
    --watch

# Cancel with *ctrl+c*

jx get activities \
    --filter environment-tekton-staging/master \
    --watch

# Cancel with *ctrl+c*

kubectl --namespace cd-staging get pods
```

```
...
vfarcic/environment-tekton-staging/master #5                     37s      36s Succeeded
  from build pack                                                37s      36s Succeeded
    Credential Initializer X988p                                 37s       0s Succeeded
    Working Dir Initializer 5kqbg                                37s       0s Succeeded
    Place Tools                                                  36s       0s Succeeded
    Git Source Vfarcic Environment Tekton Stag L8969 5cr         35s       1s Succeeded https://github.com/vfarcic/environment-tekton-staging
    Git Merge                                                    35s       1s Succeeded
    Setup Jx Git Credentials                                     35s       2s Succeeded
    Build Helm Apply                                             34s      33s Succeeded
```

```bash
kubectl --namespace cd-staging get pods
```

```
NAME                                           READY   STATUS    RESTARTS   AGE
go-demo-6-fnjp9-deployment-6b7cb5bdd8-snlpz    2/2     Running   0          65s
jx-go-demo-6-db-arbiter-0                      1/1     Running   0          4h21m
jx-go-demo-6-db-primary-0                      1/1     Running   0          4h21m
jx-go-demo-6-db-secondary-0                    1/1     Running   0          4h21m
jx-knative-txdl5-deployment-7456cfddc4-n5459   2/2     Running   0          36m
```

```bash
ADDR=$(kubectl --namespace cd-staging \
    get ksvc go-demo-6 \
    --output jsonpath="{.status.domain}")

echo $ADDR
```

```
go-demo-6.cd-staging.34.73.141.184.nip.io
```

```bash
curl "$ADDR/demo/hello"
```

```
hello, PR!
```

## Limiting Serverless Deployments Only To Pull Requests

```bash
cd ..

# If Tekton
git clone https://github.com/$GH_USER/environment-tekton-staging

# If Tekton
cd environment-tekton-staging

echo "go-demo-6:
  knativeDeploy: false" \
    | tee -a env/values.yaml

git add .

git commit -m "Removed Knative"

git pull

git push

cd ../go-demo-6

# NOTE: ing is not recreated on environment changes

echo "go-demo-6 rocks" \
    | tee README.md

git add .

git commit -m "Removed Knative"

git pull

git push

jx get activities \
    --filter go-demo-6/master \
    --watch
```

```
...
vfarcic/go-demo-6/master #3                                    1m42s    1m38s Succeeded Version: 1.0.251
  from build pack                                              1m42s    1m38s Succeeded
    Credential Initializer 5kb6g                               1m42s       0s Succeeded
    Working Dir Initializer R6hkz                              1m41s       0s Succeeded
    Place Tools                                                1m40s       0s Succeeded
    Git Source Vfarcic Go Demo 6 Master Releas Kxxgh Q47       1m39s       0s Succeeded https://github.com/vfarcic/go-demo-6
    Git Merge                                                  1m39s       1s Succeeded
    Setup Jx Git Credentials                                   1m39s       2s Succeeded
    Build Make Build                                           1m39s      20s Succeeded
    Build Container Build                                      1m38s      24s Succeeded
    Build Post Build                                           1m38s      24s Succeeded
    Promote Changelog                                          1m38s      31s Succeeded
    Promote Helm Release                                       1m37s      41s Succeeded
    Promote Jx Promote                                         1m37s    1m33s Succeeded
  Promote: staging                                               51s      47s Succeeded
    PullRequest                                                  51s      45s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/6 Merge SHA: 115c4b1b9c5d96054e88cab09619a800c72e233b
    Update                                                        5s       1s Succeeded
```

```bash
# Cancel with *ctrl+c*

jx get activities \
    --filter environment-tekton-staging/master \
    --watch
```

```
...
vfarcic/environment-tekton-staging/master #7                     38s      36s Succeeded
  from build pack                                                38s      36s Succeeded
    Credential Initializer 84xn4                                 38s       0s Succeeded
    Working Dir Initializer Fb46q                                37s       0s Succeeded
    Place Tools                                                  36s       0s Succeeded
    Git Source Vfarcic Environment Tekton Stag Dbj7k Rxz         35s       0s Succeeded https://github.com/vfarcic/environment-tekton-staging
    Git Merge                                                    35s       1s Succeeded
    Setup Jx Git Credentials                                     35s       1s Succeeded
    Build Helm Apply                                             34s      32s Succeeded
```

```bash
# Cancel with *ctrl+c*

kubectl --namespace cd-staging get pods
```

```
NAME                                           READY   STATUS    RESTARTS   AGE
jx-go-demo-6-598fbb4b48-flzbq                  1/1     Running   0          65s
jx-go-demo-6-598fbb4b48-tccpk                  1/1     Running   0          55s
jx-go-demo-6-598fbb4b48-tlqgb                  1/1     Running   0          65s
jx-go-demo-6-db-arbiter-0                      1/1     Running   0          4h32m
jx-go-demo-6-db-primary-0                      1/1     Running   0          4h32m
jx-go-demo-6-db-secondary-0                    1/1     Running   0          4h32m
jx-knative-txdl5-deployment-7456cfddc4-n5459   2/2     Running   0          48m
```

```bash
ADDR=$(kubectl --namespace cd-staging \
    get ing go-demo-6 \
    --output jsonpath="{.spec.rules[0].host}")

echo $ADDR

curl "$ADDR/demo/hello"

# NOTE: There's no need for instructins how to do the same with the prod env.
```

## What Now?

TODO: Rewrite

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-tekton-staging

hub delete -y \
  $GH_USER/environment-tekton-production

hub delete -y \
  $GH_USER/jx-knative

rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*

rm -rf jx-knative
```
