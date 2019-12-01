# Using Jenkins X To Define And Run Serverless Deployments {#knative}

TODO: Rewrite
W> At the time of this writing (July 2019), the examples in this chapter work only in a **GKE** cluster. Feel free to monitor [the issue 4668](https://github.com/jenkins-x/jx/issues/4668) for more info.

We already saw how we could run the serverless flavor of Jenkins X. That helped with many things, with better resource utilization and scalability being only a few of the benefits. Can we do something similar with our applications? Can we scale them to zero when no one is using them? Can we scale them up when the number of concurrent requests increases? Can we make our applications serverless?

Let's start from the beginning and discuss serverless computing.

## What is Serverless Computing?

To understand serverless computing, we need to understand the challenges we are facing with more "traditional" types of deployments of our applications.

A long time ago, most of us were deploying our apps directly to servers. We had to decide the size (memory and CPU) of the nodes where our applications would run, we had to create those servers, and we had to maintain them. The situation improved with the emergence of cloud computing. We still had to do all those things, but now those tasks were much easier due to the simplicity of the APIs and services cloud vendors gave us. Suddenly, we had (a perception of) infinite resources and all we had to do is run a command, and a few minutes later the servers (VMs) we needed would materialize. Things become much easier and faster. However, that did not remove the tasks of creating and maintaining servers. Instead, that made them more straightforward. Concepts like immutability become mainstream as well. As a result, we got much-needed reliability, we reduced drastically lean time, and we started to rip the benefits of elasticity.

Still, some important questions were left unanswered. Should we keep our servers running even when our applications are not serving any requests? If we shouldn't, how can we ensure that they are readily available when we do need them? Who should be responsible for the maintenance of those servers? Is it our infrastructure department, is it our cloud provider, or can we build a system that will do that for us without human intervention?

Things changed with the emergence of containers and schedulers. After a few years of uncertainty created by having too many options on the table, the situation stabilized around Kubernetes that become the de-facto standard. At roughly the same time, in parallel with the rise of popularity of containers and schedulers, solutions for serverless computing concepts started to materialize. Those solutions were not related to each other or, to be more precise, they were not during the first few years. Kubernetes provided us with means to run microservices as well as more traditional types of applications, while serverless focused on running functions (often only a few lines of code).

The name serverless is misleading by giving the impression that they are no servers involved. They are certainly still there, but the concept and the solutions implementing them allow us (users) to ignore their existence. The major cloud providers (AWS, Microsoft Azure, and Google) all came up with solutions for serverless computing. Developers could focus on writing functions with a few additional lines of code specific to the serverless computing vendor we choose. Everything else required for running and scaling those functions become transparent.

But not everything is excellent in the serverless world. The number of use-cases that can be fulfilled with functions (as opposed to applications) is limited. Even when we do have enough use-cases to make serverless computing a worthwhile effort, a more significant concern is lurking just around the corner. We are likely going to be locked into a vendor given that none of them implements any type of industry standard. No matter whether we choose AWS Lambda, Azure Functions, or Google Cloud Functions, the code we write will not be portable from one vendor to another. That does not mean that there are no serverless frameworks that are not tied to a specific cloud provider. There are, but we'd need to maintain them ourselves, be it on-prem or inside clusters running in a public cloud, and that removes one of the most essential benefits of serverless concepts.

That's where Kubernetes comes into play.

## Serverless Deployments In Kubernetes

At this point, I must make an assumption that you, dear reader, might disagree with. Most of the companies will run at least some (if not all) of their applications in Kubernetes. It is becoming (or it already is) a standard API that will be used by (almost) everyone. Why is that assumption important? If I am right, then (almost) everyone will have a Kubernetes cluster. Everyone will spend time maintaining it, and everyone will have some level of in-house knowledge of how it works. If that assumption is correct, it stands to reason that Kubernetes would be the best choice for a platform to run serverless applications as well. As an added bonus, that would avoid vendor lock-in since Kubernetes can run (almost) anywhere.

Kubernetes-based serverless computing would provide quite a few other benefits. We could be free to write our applications in any language, instead of being limited by those supported by function-as-a-service solutions offered by cloud vendors. Also, we would not be limited to writing only functions. A microservice or even a monolith could run as a serverless application. We just need to find a solution to make that happen. After all, proprietary cloud-specific serverless solutions use containers (of sorts) as well, and the standard mechanism for running containers is Kubernetes.

There is an increasing number of Kubernetes platforms that allow us to run serverless applications. We won't go into all of those but fast-track the conversation by me stating that Knative is likely going to become the de-facto standard how to deploy serverless load to Kubernetes. Or, maybe, it already is the most widely accepted standard by the time you read this.

[Knative](https://knative.dev/) is an open-source project that delivers components used to build and run serverless applications on Kubernetes. We can use it to scale-to-zero, to autoscale, for in-cluster builds, and as an eventing framework for applications on Kubernetes. The part of the project we're interested in right now is its ability to convert our applications into serverless deployments, and that means auto-scaling down until zero, and up to whatever an application needs. That should allow us both to save resources (memory and CPU) when our applications are idle, as well as to scale them fast when traffic increases.

Now that we discussed what is serverless and that I made an outlandish statement that Kubernetes is the platform where your serverless applications should be running, let's talk which types of scenarios are a good fit for serverless deployments.

## Which Types Of Applications Should Run As Serverless?

Initially, the idea was to have only functions running as serverless loads. Those would be single-purpose pieces of code that contain only a small number of lines of code. A typical example of a serverless application would be an image processing function that responds to a single request and can run for a limited period. Restrictions like the size of applications (functions) and their maximum duration are imposed by implementations of serverless computing in cloud providers. But, if we adopt Kubernetes as the platform to run serverless deployments, those restrictions might not be valid anymore. We can say that any application that can be packaged into a container image can run as a serverless deployment in Kubernetes. That, however, does not mean that any container is as good of a candidate as any other. The smaller the application or, to be more precise, the faster its boot-up time, the better the candidate for serverless deployments.

However, things are not as straight forward as they may seem. Not being a good candidate does not mean that one should not compete at all. Knative, as many other serverless frameworks do allow us to fine-tune configurations. We can, for example, specify with Knative that there should never be less than one replica of an application. That would solve the problem of slow boot-up while still maintaining some of the benefits of serverless deployments. In such a case, there would always be at least one replica to handle requests, while we would benefit from having the elasticity of serverless providers.

The size and the boot-up time are not the only criteria we can use to decide whether an application should be serverless. We might want to consider traffic as well. If, for example, our app has high traffic and it receives requests throughout the whole day, we might never need to scale it down to zero replicas. Similarly, our application might not be designed in a way that every request is processed by a different replica. After all, most of the apps can handle a vast number of requests by a single replica. In such cases, serverless computing implemented by cloud vendors and based on function-as-a-service might not be the right choice. But, as we already discussed, there are other serverless platforms, and those based on Kubernetes do not follow those rules. Since we can run any container as a serverless, any type of applications can be deployed as such, and that means that a single replica can handle as many requests as the design of the app allows. Also, Knative and other platforms can be configured to have a minimum number of replicas, so they might be well suited even for the applications with a mostly constant flow of traffic since every application does (or should) need scaling sooner or later. The only way to avoid that need is to overprovision applications and give them as much memory and CPU as their peak loads require.

All in all, if it can run in a container, it can be converted into a serverless deployment, as long as we understand that smaller applications with faster boot-up times are better candidates than others. However, boot-up time is not the only rule, nor it is the most important one. If there is a rule we should follow when deciding whether to run an application as serverless, it is related to the state. Or, to be more precise, the lack of it. If an application is stateless, it might be the right candidate for serverless computing.

Now, let us imagine that you have an application that is not the right candidate to be serverless. Does that mean that we cannot rip any benefits from frameworks like Knative? We can, since there is still the question of deployments to different environments.

Typically, we have permanent and temporary environments. The examples of the former would be staging and production. If we do not want our application to be serverless in production, we will probably not want it to be any different in staging. Otherwise, the behavior would be different, and we could not say that we tested precisely the same behavior as the one we expect to run in production. So, in most cases, if an application should not be serverless in production, it should not be serverless in any other permanent environment. But, that does not mean that it shouldn't be serverless in temporary environments.

Let's take an environment in which we deploy an application as a result of making a pull request as an example. It would be a temporary environment since we'd remove it the moment that pull request is closed. Its time span is relatively short. It could exist for a few minutes, but sometimes that could be days or even weeks. It all depends on how fast we are in closing pull requests.

Nevertheless, there is a high chance that the application deployed in such a temporary environment will have low traffic. We would typically run a set of automated tests when the pull request is created or when we make changes to it. That would certainly result in a traffic spike. But, after that, the traffic would be much lower and most of the time non-existent. We might open the application to have a look at it, we might run some manual tests, and then we would wait for the pull request to be approved or for someone to push additional changes if some issues or inconsistencies were found. That means that the deployment in question would be unused most of the time. Still, if it would be a "traditional" deployment, it would occupy resources for no particular reason. That might even discourage us from making temporary environments due to high costs.

Given that deployments based on pull requests are not used for final validations before deploying to production (that's what permanent environments are for), we do not need to insist that they are the same as production. On the other hand, the applications in such environments are mostly unused. Those two facts lead us to conclude that temporary (often pull-request based) environments are a great candidate for serverless computing, no matter the deployment type we use in permanent environments (e.g., staging and production).

Now that we saw some of the use cases for serverless computing, there is still an important one that we did not discuss.

## Why Do We Need Jenkins X To Be Serverless?

There are quite a few problems with the traditional Jenkins. Most of us already know them, so I'll repeat them only briefly. Jenkins (without X) does not scale, it is not fault-tolerant, its resource usage is heavy, it is slow, it is not API-driven, and so on. In other words, it was not designed yesterday, but when those things were not as important as they are today.

I> Jenkins had to go away for Jenkins X to take its place.

Initially, Jenkins X had a stripped-down version of Jenkins but, since the release 2, not a single line of the traditional Jenkins is left in Jenkins X. Now it is fully serverless thanks to Tekton and a lot of custom code written from scratch to support the need for a modern Kubernetes-based solution.

Excluding very thin layer that mostly acts as an API gateway, Jenkins X is fully serverless. Nothing runs when there are no builds, and it scales to accommodate any load. That might be the best example of serverless computing we can have.

Continuous integration and continuous delivery pipeline runs are temporary by their nature. When we make a change to a Git repository, it notifies the cluster, and a set of processes are spun. Each Git webhook request results in a pipeline run that builds, validates, and deploys a new release and, once those processes are finished, it disappears from the system. Nothing is executing when there are no pipeline runs, and we can have as many of them in parallel as we need. It is elastic and resource-efficient, and the heavy lifting is done by Tekton.

I> Continuous integration and continuous delivery tools are probably one of the best examples of a use-case that fits well in serverless computing concepts.

## What Is Tekton And How Does It Fit Jenkins X?

Those of you using serverless Jenkins X already experienced Knative, of sorts. Tekton is a spin-off project of Knative, and it is the essential component in Jenkins X. It is in charge of creating pipeline runs (a special type of Pods) when needed and destroying them when finished. Thanks to Tekton, the total footprint of serverless Jenkins X is very small when idle. Similarly, it allows the solution to scale to almost any size when that is needed.

Tekton is designed only for "special" type of processes, mostly those associated with continuous integration and continuous delivery pipelines. It is not, however, suited for applications designed to handle requests, and those are most of the applications we are developing. So, why am I talking about Tekton if it does not allow us to run our applications as serverless? The answer lies in Tekton's father.

Tekton is a Knative spin-off. It was forked from it in hopes to provide better CI/CD capabilities. Or, to be more precise, Tekton was born out of the [Knative Build](https://knative.dev/docs/build/) component, which is now considered deprecated. Nevertheless, Knative continues being the most promising way to run serverless applications in Kubernetes. It is the father of Tekton, which we've been using for a while now given that it is an integral part of serverless Jenkins X.

Now, I could walk you through the details of Knative definitions, but that would be out of the scope of this subject. It's about Jenkins X, not about Knative and other platforms for running serverless application. But, my unwillingness to show you the ups and downs of Knative does not mean that we cannot use it. As a matter of fact, Jenkins X already provides means to select whether we want to create a quickstart or import an existing project that will be deployed as a serverless application using Knative. We just need to let Jenkins X know that's what we want, and it'll do the heavy lifting of creating the definition (YAML file) that we need.

So, Jenkins X is an excellent example of both a set of serverless applications that constitute the solution, as well as a tool that allows us to convert our existing applications into serverless deployments. All we have to do to accomplish the latter is to express that as our desire. Jenkins X will do all the heavy lifting of creating the correct definitions for our applications as well as to move them through their life-cycles.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [16-serverless-apps.sh](https://gist.github.com/0052bb2c765509474c3c1e5671230804) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create a new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8)
TODO: Test
* Create a new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd)
TODO: Test
* Create a new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410)
TODO: Test
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037)

I> The commands that follow will reset your *go-demo-6* `master` branch with the contents of the branch that contain all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

W> Depending on whether you're using static or serverless Jenkins X flavor, we'll need to restore one branch or the other. The commands that follow will restore `extension-model-jx` if you are using static Jenkins X, or `extension-model-cd` if you prefer the serverless flavor.

```bash
cd go-demo-6

git pull

git checkout extension-model-cd

git merge -s ours master --no-edit

git checkout master

git merge extension-model-cd

git push

cd ..
```

W> Please execute the commands that follow only if you are using **GKE** and if you ever restored a branch at the beginning of a chapter (like in the snippet above).

```bash
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
```

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
cd go-demo-6

jx import --pack go --batch-mode

cd ..
```

Now we are ready to work on creating the first serverless application using Knative.

## Installing Gloo and Knative

We could visit Knative documentation and follow the instructions to install it and configure it. Then we could reconfigure Jenkins X to use it. But we won't do any of that, because Jenkins X already comes with a method to install and integrate Knative. To be more precise, Jenkins X allows us to install Gloo addon which, in turn, will install Knative.

[Gloo](https://gloo.solo.io/) is a Kubernetes ingress controller, and API gateway. The main reason for using it in our context is because of its ability to route requests to applications managed and autoscaled by Knative. The alternative to Gloo would be Istio which, even though it's very popular, is too heavy and complex.

Now that we know the "elevator pitch" for Gloo, we can proceed by installing the `glooctl` CLI.

Please follow the [Install command line tool (CLI)](https://docs.solo.io/gloo/latest/installation/knative/#install-command-line-tool-cli) instructions.

Now we can use Gloo to install Knative.

```bash
glooctl install knative \
    --install-knative-version=0.9.0
```

The process Knative in our cluster.

There's one more thing missing for us to be able to run serverless applications using Knative. We need to configure it to use a domain (in this case `nip.io`). So, the first step is to get the IP of the Knative service. However, the command differ depending on whether you're using EKS or some other Kubernetes flavor.

W> Please run the command that follows only if you are **NOT** using **EKS** (e.g., GKE, AKS, etc.).

```bash
KNATIVE_IP=$(kubectl \
    --namespace gloo-system \
    get service knative-external-proxy \
    --output jsonpath="{.status.loadBalancer.ingress[0].ip}")
```

W> Please run the commands that follow only if you are using **EKS**.

```bash
KNATIVE_HOST=$(kubectl \
    --namespace gloo-system \
    get service knative-external-proxy \
    --output jsonpath="{.status.loadBalancer.ingress[0].hostname}")

export KNATIVE_IP="$(dig +short $KNATIVE_HOST \
    | tail -n 1)"
```

To be on the safe side, we'll output the retrieved IP.

```bash
echo $KNATIVE_IP
```

If the output is an IP, everything is working smoothly so far.

Now we can change Knative configuration.

```bash
echo "apiVersion: v1
kind: ConfigMap
metadata:
  name: config-domain
  namespace: knative-serving
data:
  $KNATIVE_IP.nip.io: \"\"" \
    | kubectl apply --filename -
```

We used the IP of the LoadBalancer Service that was created during the Knative installation as a `nip.io` address in the Knative configuration. From now on, all applications deployed using Knative will be exposed using that address.

Let's take a closer look at what we got by exploring the Namespaces.

```bash
kubectl get namespaces
```

The output is as follows.

```
NAME            STATUS AGE
default         Active 67m
gloo-system     Active 2m1s
jx              Active 66m
jx-production   Active 59m
jx-staging      Active 59m
knative-serving Active 117s
kube-public     Active 67m
kube-system     Active 67m
```

We can see that we got two new Namespaces. As you can probably guess, `gloo-system` contains Gloo components, while Knative runs in `knative-serving`. Keep in mind that we did not get all the Knative components, but only `serving`, which is in charge of running Pods as serverless loads.

Now, I could go into details and explain the function of every Pod, service, CRD, and other components running in `gloo-system` and `knative-serving` Namespaces. But I feel that would be a waste of time. You can get that information yourself by exploring Kubernetes resources running in those Namespaces, or by going through the official documentation. What matters, for now, is that we got everything Jenkins X needs to convert your applications into serverless deployments.

We're almost done with the setup. Knative is installed in our cluster, but we still need to tell Jenkins X to use it as a default deployment mechanism. We can do that with the command that follows.

```bash
jx edit deploy \
    --team \
    --kind knative \
    --batch-mode
```

From this moment on, all new projects will be serverless, unless we say otherwise. If you choose to change your mind, please re-run the same command, with the `default` kind instead of `knative`.

Let's create a new project and check it out.

## Creating A New Serverless Application Project

Jenkins X does its best to be easy for everyone and not to introduce unnecessary complexity. True to that goal, there is nothing "special" users need to do to create a new project with serverless deployments. There is no additional command, nor there are any extra arguments. The `jx edit deploy` command already told Jenkins X that we want all new projects to be serverless by default, so all there is for us to do is to create a new quick start.

```bash
jx create quickstart \
    --filter golang-http \
    --project-name jx-knative \
    --batch-mode
```

As you can see, that command was no different than any other quick start we created earlier. We needed a project with a unique name, so the only (irrelevant) change is that this one is called `jx-knative`.

If you look at the output, there is nothing new there either. If someone else changed the team's deployment kind, you would not even know that a quick start will end with the first release running in the staging environment in the serverless fashion.

There is one difference though, and we need to enter the project directory to find it.

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

As you can see, the `knativeDeploy` variable is set to `true`. All the past projects, at least those created after May 2019, had that value set to `false`, simply because we did not have the Gloo addon installed and our team deployment setting was set to `default` instead of `knative`. But, now that we changed that, `knativeDeploy` will be set to `true` for all the new projects unless we change the deployment setting again.

Now, you might be thinking to yourself that a Helm variable does not mean much by itself unless it is used. If that's what's passing through your head, you are right. It is only a variable, and we are yet to discover the reason for its existence.

Let's take a look at what we have in the Chart's `templates` directory.

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

We have the `{{- if .Values.knativeDeploy }}` instruction that immediately continues into `{{- else }}`, while the whole definition of the deployment is between `{{- else }}` and `{{- end }}`. While that might look strange at the first look, it actually means that the Deployment resource should be created only if `knativeDeploy` is set to `false`. If you take a look at the `service.yaml` file you'll notice the same pattern. In both cases, the resources are created only if we did not select to use Knative deployments. That brings us to the `ksvc.yaml` file.

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

To begin with, you can see that the conditional logic is reversed. The resource defined in that file will be created only if the `knativeDeploy` variable is set to `true`.

We won't go into details of the specification. I'll only say that it is similar to what we'd define as a Pod specification, and leave you to explore [Knative Serving API spec](https://github.com/knative/serving/blob/master/docs/spec/spec.md#resource-yaml-definitions) on your own. Where Knative definition differs significantly from what we're used to when, let's say, we work with Deployments and StatefulSets, is that we do not need to specify many of the things. There is no need for creating a Deployment, that defines a ReplicaSet, that defines Pod templates. There is no definition of a Service associated with the Pods. Knative will create all the objects required to convert our Pods into a scalable solution accessible to our users.

We can think of the Knative definition as being more developer-friendly than other Kubernetes resources. It dramatically simplifies things by making some assumptions. All the Kubernetes resources we're used to seeing (e.g., Deployment, ReplicaSet, Service) will still be created together with quite a few others. The significant difference is not only in what will be running in Kubernetes but also in how we define what we need. By focusing only on what really matters, Knative removes clutter from YAML files we usually tend to create.

Now, let's see whether the activity of the pipeline run initiated by pushing the initial commit to the newly created repository is finished.

```bash
jx get activities \
    --filter jx-knative \
    --watch
```

Unless you are the fastest reader on earth, the pipeline run should have finished, and you'll notice that there is no difference in the steps. It is the same no matter whether we are using serverless or any other type of deployment. So, feel free to stop the activity by pressing *ctrl+c*, and we'll take a look at the Pods and see whether that shows anything interesting.

Before we take a look at the Pods of the new application deployed to the staging environment, we'll confirm that the latest run of the staging environment pipeline is finished as well.

```bash
jx get activities \
    --filter environment-tekton-staging/master \
    --watch
```

Feel free to press *ctrl+c* when the staging environment pipeline run is finished.

Now we can have a look at the Pods running as part of our serverless application.

```bash
kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

The output is as follows.

```
NAME           READY STATUS  RESTARTS AGE
jx-knative-... 2/2   Running 0        84s
```

W> If the output states that `no resources` were `found`, enough time passed without any traffic, and the application was scaled to zero replicas. We'll see a similar effect and comment on it a few more times. Just keep in mind that the next command that describes the Pod will not work if the Pod was already removed.

The Pod is there, as we expected. The strange thing is the number of containers. There are two, even though our application needs only one.

Let's describe the Pod and see what we'll get.

```bash
kubectl \
    --namespace jx-staging \
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
    Image: gcr.io/knative-releases/github.com/knative/serving/cmd/queue@sha256:...
    ...
```

The `queue-proxy` container was "injected" into the Pod. It serves as a proxy responsible for request queue parameters, and it reports metrics to the Autoscaler. In other words, request are reaching our application through this container. Later on, when we explore scaling our Knative-based applications, that container will be the one responsible for providing metrics used to make scaling-related decisions.

Let's see which other resources were created for us.

```bash
kubectl \
    --namespace jx-staging \
    get all
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

As you can see, quite a few resources were created from a single YAML definition with a (`serving.knative.dev`) `Service`. There are some core Kubernetes resources we are likely already familiar with, like Deployment, ReplicaSet, Pod, Service. Even if that would be all we've got, we could already conclude that Knative service simplifies things since it would take us approximately double the lines in YAML to define the same resources (Deployment and Service, the rest was created by those) ourselves. But we got so much more. There are seven or more resources created from Knative specific Custom Resource Definitions (CRDs). Their responsibilities differ. One (`podautoscaler.autoscaling`) is in charge of scaling based on the number of requests or other metrics, the other (`image.caching`) of caching of the image so that boot-up time is faster, a few are making sure that networking is working as expected, and so on and so forth. We'll get more familiar with those features later.

There is one inconvenience, though. As of today (July 7), `get applications` does not report Knative-based applications correctly. 

```bash
jx get applications --env staging
```

The output is as follows.

```
APPLICATION STAGING PODS URL
go-demo-6   1.0.221 3/3  http://go-demo-6.jx-staging.35.190.185.247.nip.io
knative     svtns
```

The `go-demo-6` application is reported correctly since it is not deployed with Knative, but the serverless one is not. Hopefully, that will be fixed soon. Until then, feel free to monitor the progress through the [issue 4635](https://github.com/jenkins-x/jx/issues/4635).

Knative defines its own Service that, just like those available in the Kubernetes core, can be queried to get the domain through which we can access the application. We can query it just as we would query the "normal" Service, the main difference being that it is called `ksvc`, instead of `svc`. We'll use it to retrieve the address through which we can access and, therefore, test whether the newly deployed serverless application works as expected.

TODO: Apply to the rest of the chapters

```bash
ADDR=$(kubectl \
    --namespace jx-staging \
    get ksvc jx-knative \
    --output jsonpath="{.status.url}")

echo $ADDR
```

The output should be similar to the one that follows.

```
jx-knative.jx-staging.35.243.171.144.nip.io
```

As you can see, the pattern is the same no matter whether it is a "normal" or a Knative service. Jenkins X is making sure that the URLTemplate we explored in the [Changing URL Patterns](#upgrade-url-template) subchapter is applied no matter the type of the Service or the Ingress used to route external requests to the application. In this case, it is the default one that combines the name of the service (`jx-knative`) with the environment (`jx-staging`) and the cluster domain (`35.243.171.144.nip.io`).

Now comes the moment of truth. Is our application working? Can we access it?

```bash
curl "$ADDR"
```

The good news is that we did get the `Hello` greeting as the output, so the application is working. But that might have been the slowest response you ever saw from such a simple application. Why did it take so long? The answer to that questions lies in the scaling nature of serverless applications. Since no one sent a request to the app before, there was no need to it to run any replica, and Knative scaled it down to zero a few minutes after it was deployed. The moment we sent the first request, Knative detected it and initiated scaling that, after a while, resulted in one replica running inside the cluster. As a result, we received the familiar greeting, only after the image is pulled, the Pod was started, and the application inside it was initiated. Don't worry about that "slowness" since it manifests itself only initially before Knative creates the cache. You'll see soon that the boot-up time will be very fast from now on.

So, let's take a look at that "famous" Pod that was created out of thin air.

```bash
kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

The output is as follows.

```
NAME           READY STATUS  RESTARTS AGE
jx-knative-... 2/2   Running 0        24s
```

We can see a single Pod created a short while ago. Now, let's observe what we'll get with a little bit of patience.

Please wait for seven minutes or more before executing the command that follows.

```bash
kubectl --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

The output shows that `no resources` were `found`. The Pod is gone. No one was using our application, so Knative removed it to save resources. It scaled it down to zero replicas.

If you're anything like me, you must be wondering about the configuration. What are the parameters governing Knative scaling decisions? Can they be fine-tuned?

The configuration that governs scaling is stored in the `config-autoscaler` ConfigMap.

```bash
kubectl --namespace knative-serving \
    describe configmap config-autoscaler
```

The output is a well-documented configuration example that explains what we'd need to do to change any aspect of Knative's scaling logic. It is too big to be presented in a book, so I'll leave it to you to explore it.

In a nutshell, Knative's scaling algorithm is based on the average number of concurrent requests. By default, it will try to target a hundred parallel requests served by a single Pod. That would mean that if there are three hundred concurrent requests, the system should scale to three replicas so that each can handle a hundred.

Now, the calculation for the number of Pods is not as simple as the number of concurrent requests divided by hundred (or whatever we defined the `container-concurrency-target-default` variable). The Knative scaler calculated the average number of parallel requests over a sixty seconds window, so it takes a minute for the system to stabilize at the desired level of concurrency. There is also a six seconds window that might make the system enter into the panic mode if during that period the number of requests is more than double of the target concurrency.

I'll let you go through the documentation and explore the details. What matters, for now, is that the system, as it is now, should scale the number of Pods if we send it more than a hundred parallel requests.

Before we test Knative's scaling capabilities, we'll check whether the application scaled down to zero replicas.

```bash
kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

If the output states that `no resources` were `found`, the Pods are gone, and we can proceed. Otherwise, wait for a while longer and repeat the previous command.

We ensured that no Pods are running only to simplify the "experiment" that follows. When nothing is running, the calculation is as simple as the number of concurrent requests divided by the target concurrency equals the number of replicas. Otherwise, the calculation would be more complicated than that, and our "experiment" would need to be more elaborated. We won't go into those details since I'm sure that you can gather such info from the Knative's documentation. Instead, we'll perform a simple experiment and check what happens when nothing is running.

So, we want to see what result of sending hundreds of parallel requests to the application. We'll use [Siege](https://github.com/JoeDog/siege) for that. It is a small and simple tool that allows us to stress test a single URL. It does that by sending parallel requests to a specific address.

Since I want to save you from installing yet-another-tool, we'll run Siege inside a Pod with a container based on the [yokogawa/siege](https://hub.docker.com/r/yokogawa/siege) image. Now, we're interested in finding out how Knative deployments scale based on the number of requests, so we'll also need to execute `kubectl get pod` command to see how many Pods were created. But, since Knative scales both up and down, we'll need to be fast. We have to make sure that the Pods are retrieved as soon as the siege is finished. We'll accomplish that by concatenating the two commands into one.

```bash
kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- --concurrent 300 --time 20S \
     "$ADDR" \
     && kubectl \
     --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

We executed three hundred concurrent requests (`-c 300`) for twenty seconds (`-t 20S`). Immediatelly after that we retrieved the Pods related to the `jx-knative` Deployment. The combined output is as follows.

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
NAME                            READY STATUS  RESTARTS AGE
jx-knative-cvl52-deployment-... 2/2   Running 0        18s
jx-knative-cvl52-deployment-... 2/2   Running 0        20s
jx-knative-cvl52-deployment-... 2/2   Running 0        18s
```

The `siege` output shows us that it successfully executed `4920` requests within `19.74` seconds and all that was done with the concurrency of almost three hundred.

What is more interesting is that we got three Pods of the `jx-knative` application. If we go back to the values in the ConfigMap `config-autoscaler`, we'll see that Knative tries to maintain one replica for every hundred concurrent requests. Since we sent almost triple that number of concurrent requests, we got three Pods. Later on, we'll see what Knative does when that concurrency changes. For now, we'll focus on "fine-tuning" Knative's configuration specific to our application.

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

We modified the `ksvc.yaml` file by adding a few annotations. Specifically, we set the `target` to `3` and `maxScale` to `5`. The former should result in Knative scaling our application with every three concurrent requests. The latter, on the other hand, will prevent the system from having more than `5` replicas. As a result, we'll have better-defined parameters that will be used to decide when to scale, but we'll also be protected from the danger of "getting more than we are willing to have."

Now, let's push the changes to the GitHub repository and confirm that the pipeline run that will be triggered by that will complete successfully.

```bash
git add .

git commit -m "Added Knative target"

git push

jx get activities \
    --filter jx-knative \
    --watch
```

Feel free to press the *ctrl+c* key to stop watching the activities when the run is finished.

As before, we'll also confirm that the new release was deployed to the staging environment by monitoring the activities of the `environment-tekton-staging` pipeline runs.

```bash
jx get activities \
    --filter environment-tekton-staging/master \
    --watch
```

Please press *ctrl+c* to cancel the watcher once the new activity is finished.

Finally, the last step we'll execute before putting the application under siege is to double-check that it is still reachable by sending a single request.

```bash
curl "http://$ADDR/"
```

You should see the familiar message, and now we're ready to put the app under siege. Just as before, we'll concatenate the command that will output the Pods related to the `jx-knative` app.

```bash
kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- --concurrent 400 --time 60S \
     "$ADDR" \
     && kubectl \
     --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

We sent a stream of four hundred (`-c 400`) concurrent requests over one minute (`-t 60S`). The output is as follows.

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
NAME           READY STATUS  RESTARTS AGE
jx-knative-... 2/2   Running 0        58s
jx-knative-... 2/2   Running 0        58s
jx-knative-... 2/2   Running 0        61s
jx-knative-... 2/2   Running 0        58s
jx-knative-... 2/2   Running 0        58s
```

If we'd focus only on the `target` annotation we set to `3`, we would expect to have over one hundred Pods, one for every three concurrent requests. But, we also set the `maxScale` annotation to `5`. As a result, only five Pods were created. Knative started scaling the application to accommodate three requests per Pod rule, but it capped at five to match the `maxScale` annotation.

Now, let's see what happens a while later. Please execute the command that follows a minute (but not much more) after than the previous command.

```bash
kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

The output is as follows.

```
NAME           READY STATUS  RESTARTS AGE
jx-knative-... 2/2   Running 0        2m32s
```

As we can see, Knative scaled-down the application to one replica short while after the burst of requests stopped. It intentionally did not scale down to zero right away to avoid potentially slow boot-up time. Now, that will change soon as well, so let's see what happens after another short pause.

Please wait for some five to ten minutes more before executing the command that follows.

```bash
kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

This time the output states that `no resources` were `found`. Knative observed that no traffic was coming to the application for some time and decided that it should scale down the application to zero replicas. As you already saw, that will change again as soon as we send additional requests to the application. For now, we'll focus on one more annotation.

In some cases, we might not want to allow Knative to scale to zero replicas. Our application's boot-time might be too long, and we might not want to risk our users waiting for too long. Now, that would not happen often since such situations would occur only if there is no traffic for a prolonged time. Still, some applications might take seconds or even minutes to boot up. I'll skip a discussion in which I would try to convince you that you should not have such applications or that, if you do, you should redesign them or even throw them to thrash and start over. Instead, I'll just assume that you do have an app that is slow to boot up but that you still see the benefits in adopting Knative for, let's say, scaling up. So, how do we prevent it from scaling to zero replicas, and yet allow it to scale to any other number?

Let's give it a try with the command that follows.

```bash
cat charts/jx-knative/templates/ksvc.yaml \
    | sed -e \
    's@autoscaling.knative.dev/target: "3"@autoscaling.knative.dev/target: "3"\
            autoscaling.knative.dev/minScale: "1"@g' \
    | tee charts/jx-knative/templates/ksvc.yaml
```

We used `sed` to add `minScale` annotation set to `1`. You can probably guess how it will behave, but we'll still double-check that everything works as expected.

Before we proceed, please note that we used only a few annotations and that Knative offers much more fine-tuning. As an example, we could tell Knative to use HorizontalPodAutoscaler for scaling decisions. I'll leave it up to you too to check out the project's documentation, and we'll get back to our task of preventing Knative from scaling our application to zero replicas.

```bash
git add .

git commit -m "Added Knative minScale"

git push

jx get activities \
    --filter jx-knative \
    --watch
```

We pushed changes to the GitHub repository, and we started watching the `jx-native` activity created as a result of making changes to our source code.

Feel free to stop watching the activities (press *ctrl+c*) once you confirm that the newly started pipeline run completed successfully.

Just as before, we'll also confirm that the pipeline run of the staging environment completed successfully as well.

```bash
jx get activities \
    --filter environment-tekton-staging/master \
    --watch
```

Just as a few moments ago, press *ctrl+c* when the new pipeline run is finished.

Now, let's see how many Pods we have.

```bash
kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

The output should show that only one Pod is running. However, that might not be definitive proof that, from now on, Knative will never scale our app to zero replicas. To confirm that "for real", please wait for, let's say, ten minutes, before retrieving the Pods again.

```bash
kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative
```

The output is still the same single Pod we saw earlier. That proves that our application's minimum number of replicas is maintained at `1`, even if it does not receive any requests for a prolonged time.

There's probably no need to give you instructions on how to check whether the application scales up if we start sending it a sufficient number of concurrent requests. Similarly, we should know by now that it will also scale down if the number of simultaneous requests decreases. Everything is the same as it was, except that the minimum number of replicas is now `1` (it is zero by default).

This last exercise of adding the `minScale` annotation converted our application from serverless to a microservice or whichever other architecture our app had.

Now that we saw how to create new projects with serverless deployments, you are probably wondering what you might need to do with your applications that are already running in Jenkins X.

## Converting Existing Projects Into Serverless Applications

We've been using the *go-demo-6* app throughout most of the chapters, and you should know by now that it does not behave as if it is serverless. Let's see whether we can change that by exploring how to convert applications already managed by Jenkins X into Knative-controlled deployments. We'll also use this opportunity to explore how we can use serverless deployments with pull requests as well as to discuss whether deployment type should be the same in all environments.

As every good developer, we'll start by creating a new branch.

```bash
cd ../go-demo-6

git checkout -b serverless
```

Next, we'll check which files we have in the `templates` directory.

```bash
ls -1 charts/go-demo-6/templates
```

Now, the output will vary depending on the date when we imported our application to Jenkins X for the first time.

You should see four or five files. The additional file is `ksvc.yaml`. If you see it, you imported *go-demo-6* after the support for Knative was added to Jenkins X (somewhere around May 2019). If that's the case and if you did not restore any of my branches, you're in luck, and you should skip to the [Turning On Knative Support](#serverless-turning-on) section, or you can continue reading but without executing the commands listed in [Adding Knative Support Manually](#serverless-manual). Even if you already have Knative support in all your Knative projects, it might be a good idea to refresh your memory about the parts of the chart that are related to it.

### Adding Knative Support Manually {#serverless-manual}

W> Follow the instructions in this section only if you imported the project for the first time before May 2019 and if you did not restore any of my branches. You'll know whether you did if you do not have `ksvc.yaml` file in the `charts/go-demo-6/templates` directory.

If we created a Jenkins X project a while ago and it does not include the `ksvc.yaml` file and a few other things required for Knative deployments, we have to make a choice between two strategies that might remedy the issue. We could delete the Jenkins x project, delete the `charts` directory, and import the repository again. That would solve the problem by creating the new chart based on a newer build pack version. As a result, we would have a Knative-ready chart. But, that might cause other problems.

If you modified the chart after the initial import, the before-mentioned strategy would fail, and you would need to tweak the newly created chart again. We, for example, added MongoDb as a dependency. In such a case, the "real" question is whether it would take us less time to make the custom changes to the chart again or to add the Knative-related changes. We'll opt for the latter option, simply because it is easy to add Knative to the chart while, on the other hand, it might take a while until we find out all the custom changes we made to the chart over time.

There are four files we need to change. We need to add a variable to the `values.yaml` file, conditionals to `deployment.yaml` and `service.yaml`, and, finally, we need to create the `ksvc.yaml` file. Let's get down to it.

```bash
echo "knativeDeploy: false" \
    | tee -a charts/go-demo-6/values.yaml
```

We added the `knativeDeploy` variable to `values.yaml`. That will allow us to switch between Knative and "normal" deployment types. The value is set to `false` mostly because, for now, we do not yet want to enable Knative, but rather to have that as an option.

Next, we'll add the conditional we already explored before.

```bash
echo "{{- if .Values.knativeDeploy }}
{{- else }}
$(cat charts/go-demo-6/templates/deployment.yaml)
{{- end }}" \
    | tee charts/go-demo-6/templates/deployment.yaml

echo "{{- if .Values.knativeDeploy }}
{{- else }}
$(cat charts/go-demo-6/templates/service.yaml)
{{- end }}" \
    | tee charts/go-demo-6/templates/service.yaml
```

We added an `if` statement with the empty `else` so that if `knativeDeploy` is set to `true` neither the Deployment nor the Service is created. Similarly, we had to close the statement with the `end` instruction at the end.

Now comes the crucial part. We'll add a file that defines the Knative `Service`.

```bash
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
```

The content of that file is almost the same as the file we'd get from any build pack. The only difference is that we added the environment variable `DB` that will let our application know how to reach Mongo, which we defined a long time ago.

Now our Chart is the same as if we created it after Knative support was added, and we can continue to the next section.

### Turning On Knative Support {#serverless-turning-on}

As you already saw previously, Knative support is already included in all buildpacks. All we have to do is to turn it on, so that's what we'll do.

```bash
jx edit deploy knative
```

The output tells us that it modified the `values.yaml` file, so let's confirm whether the `knativeDeploy` variable was indeed updated correctly.

```bash
cat charts/go-demo-6/values.yaml \
    | grep knative
```

The output should show that the `knativeDeploy` variable is set to `true`.

All we're missing is to push the changes to the repository. From there on, it will behave as a serverless application. But, before we do that, we'll make a few other changes.

### Adding The Final Touches

If you ever restored a branch at the beginning of a chapter, the chances are that there is a reference to my user (`vfarcic`). We'll change that to Google project since that's what Knative will expect to be the location of the container images.

W> Please execute the commands that follow only if you are using **GKE** and if you ever restored a branch at the beginning of a chapter.

```bash
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
```

There isn't much mystery in the commands we executed. They replaced `vfarcic` with the name of your Google project in two Makefile files and in `skaffold.yaml`.

While we're cleaning up and updating things, we might want to remove functional tests as well. They serve no purpose in this chapter, and they won't be used in those that follow, so the only thing they're doing is wasting our time. Since functional tests are at the bottom of `jenkins-x.yml`, we'll execute a command that removes the last line, and we'll repeat it a couple of times until functional tests are gone entirely.

The steps we need to execute will vary depending on Jenkins X flavor we're using, so please pay attention to warnings that will tell you which one to run.

W> Please run the command that follows only if you are using serverless Jenkins X.

```bash
cat jenkins-x.yml \
  | sed '$ d' \
  | tee jenkins-x.yml
```

Please repeat the previous command until the output is as follows.

```yaml
buildPack: go
pipelineConfig:
  pipelines:
    pullRequest:
      build:
        preSteps:
        - command: make unittest
```

Similarly, we'll revert Jenkinsfile to a simpler version. Since the changes to steps to remove functional tests are a bit more complicated than with `jenkins-x.yml`, I created a Gist that we can simply download.

W> Please run the command that follows only if you are using static Jenkins X.

```bash
curl -o Jenkinsfile \
    https://gist.githubusercontent.com/vfarcic/56c986a29e0753076e08163a7c6a2051/raw/a8be26f33c877c0927e833b015c5620d150712d6/Jenkinsfile
```

The only thing left, for now, is to push the changes to the GitHub repository.

```bash
git add .

git commit -m "Added Knative"

git push \
    --set-upstream origin serverless
```

## Using Serverless Deployments With Pull Requests

So far, all the changes we made were pushed to a branch. That was on purpose since one of my goals was to show you the benefits of using serverless deployments with pull requests.

The percentage of the apps running as serverless inevitably varies. Some might have all the stateless applications running as serverless, while others might have none. Between those two extremes can be all shades of gray. While I cannot predict how many apps you should run as serverless deployments, what I can guess with a high level of certainty is that you'll use Knative much more in temporary environments like those created for pull requests than in permanent ones like staging and production. The reason for such a bold statement lies in the differences in purpose for running applications.

An application running in a preview environment is to validate (automatically and/or manually) that a change we'd like to merge to the master branch is most likely a good one and that it is relatively safe to merge it with production code. However, the validations we're running against a release in a preview environment are often not the final ones. A preview environment is often not the same as production. It might differ in size, it might not be integrated with all the other applications, it might not have all the data we need, and so on and so forth. That's why we have the staging and other non-production permanent environments. Their primary purpose is often to provide a production-like environment where we can run the final set of validations before promoting to production. If we'd do that for each preview environment, our resource usage would probably go through the roof.

Imagine having hundreds or even thousands of open pull requests and that each is deployed to a preview environment. Now, imagine also that each pull request is a full-blown system. How much CPU and memory that would require? That was a rhetorical question I do not expect you to answer with a precise number. Saying that the answer is "a lot" or "much more than I can afford" should suffice. For that reason, our preview environments used with pull requests usually contain only the application in question. We might add one or two essential applications it integrates with, but we seldom deploy the full system there. Instead, we use mocks and stubs to test applications in those environments. That, by itself, should save a lot of resources, while still maintaining the advantages of preview environments. Nevertheless, we can do better than that.

Preview environments are one of the best use-cases for serverless loads. We might choose to run our application as serverless in production, or we might decide not to do so. The decision will depend on many factors, user experience being one of the most important ones. If our application scales to zero replicas due to lack of traffic, when a request does come, it might take a while until the process is in the newly spun replica is fully initialized. It should be obvious why forcing our users to wait for more than a second or two before receiving the first response is a bad idea. They are impatient and are likely to go somewhere else if they are unhappy with us. Also, our production traffic is likely going to be more demanding and less volatile than the one exercised over deployments in preview environments.

When a preview environment is created as a result of creating a pull request, our application is deployed to a unique Namespace. Typically, we would run some automated tests right after the deployment. But what happens after that? The answer is "mostly nothing". A while later (a minute, an hour, a day, or even a week) someone might open the deployment associated with the pull request and do some manual validations. Those might result in the need for new issues or validations. As a result, that pull request is likely going to be idle for a while, before it is used again. So, we have mostly unused deployments wasting our memory and CPU. 

Given that we established how preview environments represent a colossal waste in resources, we can easily conclude that deployments initiated by pull request are one of the best candidates for serverless computing. But, that would also assume that we do not mind to wait for a while until an application is scaled from zero to one or more replicas. In my experience, that is (almost) never a problem. We cannot put users of our production releases and pull request reviewers on the same level. It should not be a problem if a person who decides to review a pull request and validate the release candidate manually has to wait for a second or even a minute until the application is scaled up. That loss in time is more than justified with much better usage of resources. Before and after the review, our app would use no resources unless it has dependencies (e.g., database) that cannot be converted into serverless deployments. We can gain a lot, even in those cases when only some of the deployments are serverless. A hundred percent of deployments in preview environments running as serverless is better than, let's say, fifty percent. Still, fifty percent is better than nothing.

I> Databases in preview or even in permanent environments can be serverless as well. As long as their state is safely stored in a network drive, that should be able to continue operating when scaled from zero to one or more replicas. Nevertheless, databases tend to be slow to boot, especially when having a lot of data. Even though they could be serverless, they are probably not the right candidate. The fact that we can do something does not mean that we should.

Now, let's create a pull request with all the changes we did to *go-demo-6* and see how it behaves.

```bash
jx create pullrequest \
    --title "Serverless with Knative" \
    --body "What I can say?" \
    --batch-mode
```

Next, since Jenkins X treats pull requests as yet-another-branch, we'll store the name of that branch in an environment variable.

W> Please replace `[...]` with `PR-[PR_ID]` (e.g., PR-109). You can extract the ID from the last segment of the pull request address.

```bash
BRANCH=[...] # e.g., `PR-109`
```

Now, let's double-check that the pull request was processed successfully.

```bash
jx get activities \
    --filter go-demo-6/$BRANCH \
    --watch
```

Feel free to press *ctrl+c* to stop watching the activities when all the steps in the pipeline run were executed correctly.

To see what was deployed to the preview environment, we need to discover the Namespace Jenkins X created for us. Fortunately, it uses a predictable naming convention so we can reconstruct the Namespace name easily using the base Namespace, GitHub user, application name, and the branch.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
GH_USER=[...]

PR_NAMESPACE=$(\
  echo jx-$GH_USER-go-demo-6-$BRANCH \
  | tr '[:upper:]' '[:lower:]')

echo $PR_NAMESPACE
```

In my case, the output of the last command was `jx-vfarcic-go-demo-6-pr-115`. Yours should be different but still follow the same logic.

Now we can take a look at the Pods running in the preview Namespace.

```bash
kubectl --namespace $PR_NAMESPACE \
    get pods
```

The output is as follows.

```
NAME                   READY STATUS  RESTARTS AGE
go-demo-6-ng479-...    2/2   Running 2        6m44s
preview-preview-db-... 1/1   Running 0        6m44s
```

We can see two interesting details just by observing the number of containers in those Pods.

In normal circumstances, both the application and the database are single-container Pods. But, in this case, the app has two containers, while the database still has only one. Given that we know that Knative injects a container to all the Pods managed by it, we can easily conclude that only the application (`go-demo-6`) was converted into serverless, while the database is still left intact. If we leave the application inactive for a while, it will scale to zero replicas and save us some resources.

To be on the safe side, we'll confirm that the application deployed in the preview environment is indeed working as expected. To do that, we need to construct the auto-assigned address through which we can access the application.

```bash
PR_ADDR=$(kubectl \
    --namespace $PR_NAMESPACE \
    get ksvc go-demo-6 \
    --output jsonpath="{.status.url}")

echo $PR_ADDR
```

The output should be similar to the one that follows.

```
go-demo-6.jx-vfarcic-go-demo-6-pr-115.34.73.141.184.nip.io
```

I> Please note that we did not have to "discover" the address. We could have gone to the GitHub pull request screen and clicked the *here* link. We'd need to add `/demo/hello` to the address, but that could still be easier than what we did. Still, I am "freak" about automation and doing everything from a terminal screen, and I have the right to force you to do things my way, at least while you're following the exercises I prepared.

Now comes the moment of truth.

```bash
curl "$PR_ADDR/demo/hello"
```

The output should be already familiar `hello, PR!` message. If by the time we sent the request there was already a replica, it was simply forwarded there. If there wasn't, Knative created one.

Now, let's see what do we have in the staging environment.

```bash
kubectl --namespace jx-staging get pods
```

The output is as follows.

```
NAME                         READY STATUS  RESTARTS AGE
jx-go-demo-6-56fdbcb4c7-...  1/1   Running 2        4h12m
jx-go-demo-6-56fdbcb4c7-...  1/1   Running 1        4h12m
jx-go-demo-6-56fdbcb4c7-...  1/1   Running 1        4h12m
jx-go-demo-6-db-arbiter-0    1/1   Running 0        4h12m
jx-go-demo-6-db-primary-0    1/1   Running 0        4h12m
jx-go-demo-6-db-secondary-0  1/1   Running 0        4h12m
jx-knative-txdl5-...         2/2   Running 0        27m
```

As we can see, the `jx-knative` runs as a serverless application, but `go-demo-6` doesn't. We imported the project into Jenkins X while it was "normal", and we did not yet merge the changes that configure it as serverless. We'll change that next, and the first step is to open the GitHub repository.

```bash
jx repo
```

You might be asked to confirm whether you want to use your GitHub user, and after that, you'll be presented with the repository in your favorite browser. Please navigate to the pull request and merge it using whichever method suits you the best. At this point, I usually delete the branch that was merged to master, but that's not mandatory so feel free to leave it if you believe you'll need it (or if you're lazy).

```bash
git checkout master

git branch -d serverless

git pull

jx get activities \
    --filter go-demo-6/master \
    --watch
```

We switched to the master branch in our local copy of the repository, deleted the local copy of the branch, pulled the latest version, and started observing the activities.

Once the newly run activity is finished successfully, you can press *ctrl+c* to stop watching it.

Next, as we already did a few times before, we'll confirm that the activity associated with the staging environment finished as well.

```bash
jx get activities \
    --filter environment-tekton-staging/master \
    --watch
```

Just as before, press *ctrl+c* to stop watching the activity when you see what all the steps were executed successfully.

Let's see which Pods do we have now in the staging Namespace.

```bash
kubectl \
    --namespace jx-staging \
    get pods
```

The output is as follows.

```
NAME                        READY STATUS  RESTARTS AGE
go-demo-6-fnjp9-...         2/2   Running 0        65s
jx-go-demo-6-db-arbiter-0   1/1   Running 0        4h21m
jx-go-demo-6-db-primary-0   1/1   Running 0        4h21m
jx-go-demo-6-db-secondary-0 1/1   Running 0        4h21m
jx-knative-txdl5-...        2/2   Running 0        36m
```

As you can see, this time, both applications (`jx-knative` and `go-demo-6`) are deployed as serverless. The moment we merged to the master branch, the changes that enable Knative, Jenkins X executed the pipeline, and the end result is a change in how the application is deployed to staging.

You probably already noticed that the database used by `go-demo-6` still runs as a non-serverless application. That is normal since we did not enable Knative support for it or, to be more precise, we still have the `mongo` dependency left intact.

Just as before, we'll send a request to the new release of `go-demo-6` and confirm that it still works as expected. But, to do that, we need to consult `ksvc` to find the domain on which it is running.

```bash
ADDR=$(kubectl \
    --namespace jx-staging \
    get ksvc go-demo-6 \
    --output jsonpath="{.status.url}")

echo $ADDR

curl "$ADDR/demo/hello"
```

The output of the last command should be `hello, PR!`, and with that we confirmed that the application running as serverless deployment in the staging environment works as expected.

Now, the question is whether we want `go-demo-6` to be serverless when running in permanent environments (e.g., staging and production).

## Limiting Serverless Deployments To Pull Requests

I already explained that running applications as serverless deployments in preview (pull request) environments is highly beneficial. As a result, you might have the impression that an application must be serverless in all environments. That is certainly not the case. We can, for example, choose to run some applications as serverless deployments in preview environment and run them as "normal" apps in those that are permanent.

To be fair, we could have more complicated arrangements with, for example, running a serverless application in the staging environment but non-serverless in production. However, that would mean that we do not test what we're deploying to production. After all, serverless applications do not behave in the same way as other types of deployments.

Now, you could argue that preview environments are used for testing so they should be the same as production. While it is true that testing is the primary function of preview environments, they are not used for the final round of testing. By their nature, preview environments are more lightweight and do not contain the whole system, but only the parts required to (partly) validate pull requests. The "real" or "final" testing is performed in the staging environment if we are performing continuous delivery, or in production, if we are practicing continuous deployment. The latter option would require some form of progressive delivery, which we might explore later. For now, I'll assume that you are following the continuous delivery model and, therefore, staging environment (or whatever you call it) is the one that should be production-like.

All in all, we'll explore how to make an application serverless only in preview environments, and continue being whatever it was before in permanent ones.

Since our *go-demo-6* application is already serverless by default, we'll go with the least possible effort and leave it as-is, but disable `knativeDeploy` in values for the staging in production environments.

So, our first order of business to is clone the staging environment repository. Given that it is called differently depending on whether you're using serverless or static Jenkins X and I want us to run the same commands as much as possible, we'll store the name of the repository in an environment variable.

W> Please execute the command that follows only if you are running **serverless Jenkins X**.

```bash
STAGING_ENV=environment-tekton-staging
```

W> Please execute the command that follows only if you are running **static Jenkins X**.

```bash
STAGING_ENV=environment-jx-rocks-staging
```

Now we can clone the staging environment repository.

```bash
cd ..

rm -rf $STAGING_ENV

git clone https://github.com/$GH_USER/$STAGING_ENV.git

cd $STAGING_ENV
```

We removed a local copy of the staging repository just in case there is a left-over from one of the previous chapters, we cloned the repo, and we entered inside the local copy.

Now, changing the way an application is deployed to a specific repository is as easy as changing the value of the `knativeDeploy` variable. But, since an environment defines all the applications running in it, we need to specify for which one we're changing the value. Or, to be more precise, since all the apps in an environment are defined as dependencies in `requirements.yaml`, we need to prefix the value with the alias of the dependency. In our case, we have at least `jx-knative` and `go-demo-6`, and the latter is the one we want to ensure is not running as serverless in the staging environment.

```bash
echo "go-demo-6:
  knativeDeploy: false" \
    | tee -a env/values.yaml
```

Now that we added the `go-demo-6.knativeDeploy` variable set to `false`, we can push the changes and let Jenkins X do the job for us.

```bash
git add .

git commit -m "Removed Knative"

git pull

git push
```

Now, even though that push will trigger a new deployment, that will not recreate the required Ingress resource, so we'll need to make a (trivial) change to the application as well. That should result in the new deployment with everything we need for our *go-demo-6* application to behave in the staging environment as it did before we started converting it to serverless.

```bash
cd ../go-demo-6

echo "go-demo-6 rocks" \
    | tee README.md

git add .

git commit -m "Removed Knative"

git pull

git push
```

Just as before, we'll check the activities of the project pipeline to confirm that it executed successfully.

```bash
jx get activities \
    --filter go-demo-6/master \
    --watch
```

Feel free to stop watching the activities with *ctrl+c*, so that we double-check that the activity triggered by making changes to the staging environment repository is finished as well.

```bash
jx get activities \
    --filter environment-tekton-staging/master \
    --watch
```

You know what to do now. Press *ctrl+c* when the newly spun activity is finished.

Now, let's check whether the application was indeed deployed as non-serverless to staging.

```bash
kubectl \
    --namespace jx-staging \
    get pods
```

The output is as follows.

```
NAME                        READY STATUS  RESTARTS AGE
jx-go-demo-6-598fbb4b48-    1/1   Running 0        65s
jx-go-demo-6-598fbb4b48-    1/1   Running 0        55s
jx-go-demo-6-598fbb4b48-    1/1   Running 0        65s
jx-go-demo-6-db-arbiter-0   1/1   Running 0        4h32m
jx-go-demo-6-db-primary-0   1/1   Running 0        4h32m
jx-go-demo-6-db-secondary-0 1/1   Running 0        4h32m
jx-knative-txdl5-...        2/2   Running 0        48m
```

As you can see, the *go-demo-6* Pods are back to the shape they were before we converted the application to serverless deployments.

Since you know that I have a paranoid nature, you won't be surprised that we'll double-check whether the application works by sending a request and observing the output.

```bash
ADDR=$(kubectl \
    --namespace jx-staging \
    get ing go-demo-6 \
    --output jsonpath="{.spec.rules[0].host}")

echo $ADDR

curl "$ADDR/demo/hello"
```

If you got the familiar message, the application works and is back to its non-serverless form.

Right now, our preview (pull requests) and production environments feature serverless deployments of *go-demo-6*, while staging is back to the "normal" deployment. We should make a similar change to the production repository, but I will not provide instructions for that since they are the same as for the staging environment. Think of that as a (trivial) challenge that you should complete alone.

## What Now?

As you saw, converting our applications into serverless deployments with Knative is trivial. The same can be said for all the projects we start from now on. Jenkins X buildpacks already contain everything we need and the only action on our part is either to change the `knativeDeploy` variable or to use the `jx edit deploy` command to make Knative deployments default for all new projects.

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you chose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> Please replace the first `[...]` with your GitHub user. Also, please note that two commands have a comment to distinguish that one that should be executed if you use serverless or static Jenkins X. You can run both if you do not mind seeing an error and ignoring it.

```bash
cd ..

GH_USER=[...]

hub delete -y $GH_USER/$STAGING_ENV

hub delete -y $GH_USER/jx-knative

# If serverless
rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*

# If static
rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf jx-knative

rm -rf $STAGING_ENV
```

Finally, you might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just keep reading.
