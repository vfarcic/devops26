# Using Jenkins X To Define And Run Serverless Deployments

W> The examples in this chapter work both in **static** and **serverless** Jenkins X.

We already saw how we can run serverless flavor of Jenkins X. That helped with many things, better resource utilization and scalability being only a few of the advantages. Can we do something similar with our applications? Can we scale them to zero when noone uses them? Can we scale them up when the number of concurent requests increases? Can we make ouor applications serverless? Let's start from the begining and discuss serverless computing.

## What is Serverless Computing?

To understand serverless computing, one needs to understand the challenges we are facing with more "traditional" types of deployments of oour applications. A long time ago, most of us were deploying our applications directly to servers. We had to decide the size (memory and CPU) of the ndoes where our applications would run, we had to create those servers, and we had to maintain them. The situation improved with the emergence of cloud computing. We still had to do all those things, but now those tasks were much easier due to simplicity of the APIs and services cloud vendors gave us. Suddenly, we had (a perceptino of) infinite resources and all we had to do is run a command and a few minutes later the servers (VMs) we needed would materialize. Things become much easier and faster. But, that did not remove the tasks of creating and maintaining servers, but rather made them more straightforward. Concepts like immutability become mainstream as well. As a result, we got much needed reliability, reduced drastically lean time, and started to rip benefits of elasticity.

Still, some important questions were left ununswered. Should we keep our servers running even when our applications are not serving any requests? If we shouldn't, how can we ensure that they are readily available when we do need them? Who should be responsible for maintenance of those servers? Is it our infrastruture department, our clod provider, oor can we build a system that will do that for us without human intervention?

Things changed with the emergence fo containers and schedulers. After a few years of uncertainty created by having too many options on the table, the situation stabilized around Kubernetes that become de-facto standard. At roughly the same time, in parallel with the rise of popularity of containers and schedulers, solutions serverless computing concepts started to materialize. Those solutions were not related with each other or, to be more precise, were not during the first few years. Kubernetes provided us to run microservices as well as more traditional types of applications, while serverless focused on running functions (often only a few lines of code). For now, we'll focus on serverless computing or, as some call it function-as-a-service.

The name serverless is missleading by giving the impression that they are no servers involved. They are certainly still there, but the concept and the solutions implementing them allow us (users) to ignore their existence. The major cloud providers (AWS, Microsoft Azure, and Google) all came up with solutions for serverless computing. Developers could focus on writing functions with a few additional lines of code specific to our serverless computing vendor. Everything else required for running and scaling those functions become transparent.

But not everything is great in the serverless world. The number of use-cases that can be fullfilled with writing functions (as oposed to applications) is limited. Even when we do have enough use-cases to make serverless computing wortwhile effort, a bigger concern is lurking just around the corner. We are likely going to be locked to a vendor given that none of them implements any type of industry standard. No matter whether we choose AWS Labda, Azure Functions, or Google Cloud Functions, the code we write will not be portable from one vendor to another. That does not mean that there are no serverless frameworks that are not tied to a specific cloud provider. There are, but we'd need to maintain them ourselves, be it on-prem or inside clusters running in public cloud. That removes one of the most important benefits of the serverless concepts.

That's where Kuberentes comes into play.

## Serverless Deployments In Kubernetes

At this point, I must make an assumption that you, dear reader, might dissagree with. Most of the companies will run at least some (if not all) of their applications in Kubernetes. It is becoming (or it already is) a standard API that will be used by (almost) everyone. Why is that assumption important? If I am right, than (almost) everyone will have a Kubernetes cluster. Everyone will spend time maintaining it, and everyone will have some level of in-house knowledge of how it works. If that assumption is correct, it stands to reason that Kubernetes would be the best choice of a platform to run serverless applications as well. That would avoid vendor lock-in ginve that Kubernetes can run (almost) anywhere. A Kubernetes-based serverless computing would provide quite a few other benefits. We could be free to write our applications in any language, instead of being limited to what function-as-a-service provided by cloud providers offers. Also, we would be limited to writing only functions. A microservice, or even a monolith could run as a serverless application. We just need to find a solution to make that happen. After all, proprietary cloud-specific serverless solutions use containers (of sorts) as well, and the standard mechanism for running containers is Kubernetes.

There is an increasing number of Kubernetes platforms that allow us to run serverless applications. We won't go into all of those, but fastrack the conversation by me stating that Knative is likely going to become the de-fasco standard how to deploy serverless load to Kubernetes.

[Knative](https://knative.dev/) is an open source project that delivers components used to build and run serverless applications on Kubernetes. We can use it to scale-to-zero, autoscale, in-cluster builds, and eventing framework for applications on Kubernetes. That part of the project we're interested in right now is it's ability to convert our applicatins into serverless deployments. That should allow us both to save resources (memory and CPU) when oour applications are idle, as well as to scale them fast when trafic increases.

Now that we discussed what is serverless and that I made an outlandish statement that Kubernetes is the platform where your serverless applications are running, let's discuss which types of scenarios are a good fit for serverless deployments.

## Which Types Of Applications Should Run As Serverless?

Initially, the idea was only for functions to run as serverless. Those would be single-purpose pieces of code that contain only a small number of lines of code. A typical example of a serverless application would be image processing function that responds to a single request and can run to a limited period. Those restrictions are imposed by implementations of serverless computing in cloud providers. But, if we adopt Kubernetes as the platform to run serverless deployments, those restrictions might not be valid any more. We can say that any application that can be packaged into a container image can run as a serverless deployment in Kubernetes. That, however, does not mean that any container is as good of a candidate as any other. The smaller the application or, to be more precise, the faster its boot-up time is, the better the candidate for serverless deployments. However, things are not as straight forward as they may seem. Not being a good candidate does not mean that one should not compete at all. Knative, as many other serverless frameworks do allow us to fine tune configurations. We can, for example, specify with Knative that there should never be less than one replica of an application. That would solve the problem of slow boot-up while still maintaining some of the benefits of serverless deployments. In such a case, there would always be at least one replica to handle request, while we would benefit from having elasticity serverless providers.

The size and the booot-up time are not the only criteria we can use to decide whether an application should be serverless or not. We might want to consider traffic as well. If, for example, our application has high traffic and it receives requests throughout the whole day, we might never need to scale it down to zero replicas. Similarly, our application might not be designed in a way that every request is processes by a different replica. After all, most of the applications can handle a huge number of requests by a single replica. In such cases, serverless computing implemented by cloud vendors and based on function-as-a-service might not be a good choice. But, as we already discussed, there are other serverless platforms and those based on Kubernetes do not follow those rules. Since we can run any container as serverless, any type of application can be deployed as such, and that means that a single replica can handle as many requests as its design allows. Also, Knative and other platforms do can be configured to have a minimum number of replicas, so they might be well suited even for the applications with constant flow of traffic.

All in all, if it can run in a container, it can be converted into a serverless deployment, while still understanding that smaller applications with faster boot-up times are better candidates than others. If there is a rule one should follow when deciding whether to run an application as serverless is its state. Or, to be more precise, the luck of it. If an application is stateless, it might be a good candidate for serverless computing.

Now, let us imagine that you have an application that is not a good candidate to be serverless. Does that mean that we cannot rip any benefit from frameworks like Knative? We can, since there is still the question of deployments to different environments. Normally, we have permanent and temporary environments. The examples of the former would be staging and production. If we do not want our application to be serverless in production, we will probably not want it to be any different in staging. Otherwise, the behavior would be different and we could not say that we tested exactly the same behavior as the one we expect to run in production. So, in most cases, if an application should not be serverless in production, it should not be serverless in any other permanent environment. But, that does not mean that it shouldn't be serverless in temporary environments.

Let's take as an example a temporary environment in which we deploy an application as a result of making a pull request. It would be a temporary environment since we'd remove it the moment that pull request is closed. It's timespan is relatively short. It could exist for a few minutes, but sometimes that could be days or even weeks. It all depends no how fast we are in closing pull requests. Nevertheless, the is a high chance that the application deployed in such temporary environment will have low trafic. We would normally run a set of automated tests when the pull request is created or when we make changes to it. That would certainly result in traffic spike. But, after that, the traffic would be mucch lower and most of the time non-existent. We might open the application to have a look at it, we might run some manual tests, and then we would wait for the pull request to be approved or for someone to push additional changes if we found some issues or inconsistencies. That means that the deployment in question would be unused most of the time. Still, if it would be a "traditional" deployment, it would oocupy resources for no particular reason. That might even discourage us from making temporary environments due to high costs.

Given that pull requests deployments are not the final verifiations before deploying to production (that's what permanent environments are for), we do not need to insist that they are the same as production. On the other hand, the applications in such environments are mostly unused. Those facts lead us to conclude that temporary (often pull-request based) environments are a great candidate for serverless deployments, no matter the deployment type we use in permanent environments (e.g., staging and production).

Now that we saw some of the use cases for serverless computing, there is still an important one that we did not discuss.

## Why Do We Need Jenkins X To Be Serverless?

There are quite a few problems with the traditional Jenkins. Most of use already know them so I'll repeat them only briefly. Jenkins (without X) does not scale, it is not fault tolerant, it's resource usage is heavy, it is slow, it is not API-driven, and so on. To put it in other words, it was not designed yesterday, but when those things were not as important as they are today. Jenkins had to go away for Jenkins X to take its place. Initially, Jenkins X had a stripped-down version of Jenkins but, since the release 2, not a single line of the traditional Jenkins is left in Jenkins X. Now it is fully serverless thanks to Tekton and a lot of custom code written from scratch to support the need for a modern Kubernetes-based solution. Excluding a very thin later that mostly acts as an API gateway, Jenkins X is fully serverless. Nothing runs when there are no builds, and it scales to accomodate any load. And that might be the best example of serverless computing we can have.

Coontinuous integration and continuous delivery flows are temporary by their nature. When we make a change to a Git repository, it notifies the cluster, and a set of processes are spun. Each Git webhook requests results in a pipeline run that builds, validates, and deploys a new release and, once those processes are finished, it dissapears from the system. Nothing is executing when there are no pipeline runs, and we can have as many of them in parallel as we need. It is elastic and resource efficient, and the heavy lifting is done by Tekton.

## What Is Tekton?

Those of you using serverless Jenkins X already experienced Knative, of sorts. Tekton is a spin-off project of Knative and it is an important component in the solution. It is in charge of creating pipeline runs (special type of Pods) when needed, and destroying them when finished. Thanks to Tekton the total footprint of serverless Jenkins X is very small when idle. Similarly, it allowes the solution to scale to almost any size, when that is needed.

Tekton, however, is designed only for "special" type of processes, mostly those associated with continuous integration and continuous delivery pipelines. It is not, however, suited for long-running applications designed to handle requests. So, why am I talking about Tekton if it does not allow us run our applications as serverless? The answer lies in Tekton's father.

Tekton is a Knative spin-off. It's forked from it in hopes to provide CI/CD capabilities. Or, to be more precise, Tekton was born out of the [Knative Build](TODO:) component. But, Knative still stays the most promising way to run serverless applications in Kubernetes. It is the father of Tekton, which we've been using for a while now given that it is an integral part of serverless Jenkins X.

Now, I could walk you through the details of Knative definitions, but that would be out of the scope of this book. It's about Jenkins X, not about Knative and other platforms for running serverless application. But, my unwilingness to show you ups and downs of Knative does not mean that we cannot use it. As a matter of fact, Jenkins X already provides means to select whether we want to create a quickstart or import an existing project that will be deployed as a serverless application using Knative. We just need to let Jenkins X know that's what we want, and it'll do the heavy lifing of creating the definition (YAML file) that we need.

Now, let's take a look at Jenkins X as an example of both a set of serverless applications, as well as a tool that allows us to convert our existing applications into serverless deployments.

Installing serverless flavor of Jenkins X is as easy as execution of a single command. That problem is solved, but you might be wondering how to convert your applications into serverless deployments. Fortunatelly, Jenkins X has you covered for that as well.

But, before we proceed further, we'll need a cluster with any flavor of Jenkins X.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

TODO: Rewrite

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [14-upgrade.sh](https://gist.github.com/00404a74924beadda4143ac26e8fbaa1) Gist.

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

Now we are ready to work on create a first serverless application using Knative.

## Installing Gloo and Knative

TODO: Is this the first time we're using addons? If it is, explain them.

We could visit Knative documentation and follow the instructions how to install it and configure it. Then we could reconfigure Jenkins X to use it. But we won't do any of that, because Jenkins X already comes with a method to install and integrate Knative. To be more precise, Jenkins X allows us to install Gloo addon which, in turn, will install Knative.

[Gloo](https://gloo.solo.io/) is a Kubernetes ingress controller, and API gateway. The main reason for using it in our context is because of its ability to route requests to applications managed and autoscaled by Knative. The alternative to Gloo would be Istio which, even though is very popular is too heavy and complex.

Now that we know the "elevator pitch" for Gloo, we can proceed and install it.

```bash
jx create addon gloo
```

Judging from the output, we can see that the process checked whether `glooctl` is installed and, if it isn't, it set it up for us. The command line tool has quite a few features but the only one that matters (for now) is that it installs Knative. Furter on, the process installed Gloo and Knative in our cluster and it configured our team to use `knative` as the default deployment kind. What that means is that, from now on, every new application we add through a quickstart or by importing an existing project will be deployed as Knative.

The default deployment mechanism can be changed at any time.

Let's take a closer look at what we got by exploring the Namespaces.

```bash
kubectl get namespaces
```

The output is as follows.

```
NAME              STATUS   AGE
cd                Active   66m
cd-production     Active   59m
cd-staging        Active   59m
default           Active   67m
gloo-system       Active   2m1s
knative-serving   Active   117s
kube-public       Active   67m
kube-system       Active   67m
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

TODO: Continue text

TODO: Limit the output to knative Pods

```bash
kubectl --namespace cd-staging get pods
```

The output, limited to the `jx-knative`, is as follows.

```
NAME                                          READY   STATUS    RESTARTS   AGE
...
jx-knative-svtns-deployment-cb88ffb5d-cwtc5   2/2     Running   0          20s
```

TODO: What is the second container?

```bash
kubectl --namespace cd-staging get all
```

```
NAME                                READY   STATUS    RESTARTS   AGE
pod/jx-go-demo-6-765d76bd99-22xvb   1/1     Running   3          59m
pod/jx-go-demo-6-765d76bd99-56445   1/1     Running   3          59m
pod/jx-go-demo-6-765d76bd99-hkghz   1/1     Running   2          59m
pod/jx-go-demo-6-db-arbiter-0       1/1     Running   0          59m
pod/jx-go-demo-6-db-primary-0       1/1     Running   0          59m
pod/jx-go-demo-6-db-secondary-0     1/1     Running   0          59m

NAME                               TYPE           CLUSTER-IP      EXTERNAL-IP                                           PORT(S)           AGE
service/go-demo-6                  ClusterIP      10.31.246.121   <none>                                                80/TCP            59m
service/jx-go-demo-6-db            ClusterIP      10.31.240.129   <none>                                                27017/TCP         59m
service/jx-go-demo-6-db-headless   ClusterIP      None            <none>                                                27017/TCP         59m
service/jx-knative                 ExternalName   <none>          istio-ingressgateway.istio-system.svc.cluster.local   <none>            48m
service/jx-knative-svtns-service   ClusterIP      10.31.240.93    <none>                                                80/TCP,9090/TCP   48m

NAME                                          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jx-go-demo-6                  3         3         3            3           59m
deployment.apps/jx-knative-svtns-deployment   0         0         0            0           48m

NAME                                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/jx-go-demo-6-765d76bd99                 3         3         3       59m
replicaset.apps/jx-knative-svtns-deployment-cb88ffb5d   0         0         0       48m

NAME                                         DESIRED   CURRENT   AGE
statefulset.apps/jx-go-demo-6-db-arbiter     1         1         59m
statefulset.apps/jx-go-demo-6-db-primary     1         1         59m
statefulset.apps/jx-go-demo-6-db-secondary   1         1         59m

NAME                                   NAME         VERSION    GIT URL
release.jenkins.io/go-demo-6-1.0.221   go-demo-6    v1.0.221   https://github.com/vfarcic/go-demo-6
release.jenkins.io/jx-knative-0.0.2    jx-knative   v0.0.2     https://github.com/vfarcic/jx-knative

NAME                                                              READY   REASON
podautoscaler.autoscaling.internal.knative.dev/jx-knative-svtns   False   NoTraffic

NAME                                                        AGE
image.caching.internal.knative.dev/jx-knative-svtns-cache   48m

NAME                                                                                        READY   REASON
clusteringress.networking.internal.knative.dev/route-3cdfc09b-9d44-11e9-8bb1-42010a8e0064   True

NAME                                   DOMAIN                                        READY   REASON
route.serving.knative.dev/jx-knative   jx-knative.cd-staging.35.243.171.144.nip.io   True

NAME                                     DOMAIN                                        LATESTCREATED      LATESTREADY        READY   REASON
service.serving.knative.dev/jx-knative   jx-knative.cd-staging.35.243.171.144.nip.io   jx-knative-svtns   jx-knative-svtns   True

NAME                                           LATESTCREATED      LATESTREADY        READY   REASON
configuration.serving.knative.dev/jx-knative   jx-knative-svtns   jx-knative-svtns   True

NAME                                            SERVICE NAME               GENERATION   READY   REASON
revision.serving.knative.dev/jx-knative-svtns   jx-knative-svtns-service   1            True
```

```bash
jx get applications --env staging
```

```
APPLICATION STAGING PODS URL
go-demo-6   1.0.221 3/3  http://go-demo-6.cd-staging.35.190.185.247.nip.io
knative     svtns
```

```bash
ADDR=$(kubectl --namespace cd-staging \
    get ksvc jx-knative \
    --output jsonpath="{.status.domain}")

echo $ADDR
```

```
jx-knative.cd-staging.35.243.171.144.nip.io
```

```bash
curl "$ADDR"

# It might takes a while if the Pod is not running
```

```
Hello from:  Jenkins X golang http example
```

```bash
kubectl --namespace cd-staging get pods
```

```
NAME                                          READY   STATUS    RESTARTS   AGE
jx-go-demo-6-765d76bd99-22xvb                 1/1     Running   3          63m
jx-go-demo-6-765d76bd99-56445                 1/1     Running   3          63m
jx-go-demo-6-765d76bd99-hkghz                 1/1     Running   2          63m
jx-go-demo-6-db-arbiter-0                     1/1     Running   0          63m
jx-go-demo-6-db-primary-0                     1/1     Running   0          63m
jx-go-demo-6-db-secondary-0                   1/1     Running   0          63m
jx-knative-svtns-deployment-cb88ffb5d-5fflx   2/2     Running   0          100s
```

```bash
# Wait for a while, around 7 minutes for the first Pod, less for those that follow.

kubectl --namespace cd-staging get pods
```

```
NAME                            READY   STATUS    RESTARTS   AGE
jx-go-demo-6-765d76bd99-22xvb   1/1     Running   3          69m
jx-go-demo-6-765d76bd99-56445   1/1     Running   3          69m
jx-go-demo-6-765d76bd99-hkghz   1/1     Running   2          69m
jx-go-demo-6-db-arbiter-0       1/1     Running   0          69m
jx-go-demo-6-db-primary-0       1/1     Running   0          69m
jx-go-demo-6-db-secondary-0     1/1     Running   0          69m
```

```bash
kubectl --namespace cd-staging \
    describe ksvc jx-knative
```

```
Name:         jx-knative
Namespace:    cd-staging
Labels:       chart=jx-knative-0.0.2
              jenkins.io/chart-release=jx
              jenkins.io/version=9
Annotations:  jenkins.io/chart: env
              kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"serving.knative.dev/v1alpha1","kind":"Service","metadata":{"annotations":{"jenkins.io/chart":"env"},"labels":{"chart":"jx-k...
              serving.knative.dev/creator: system:serviceaccount:cd:tekton-bot
              serving.knative.dev/lastModifier: system:serviceaccount:cd:tekton-bot
API Version:  serving.knative.dev/v1alpha1
Kind:         Service
Metadata:
  Creation Timestamp:  2019-07-03T03:40:01Z
  Generation:          1
  Resource Version:    25813
  Self Link:           /apis/serving.knative.dev/v1alpha1/namespaces/cd-staging/services/jx-knative
  UID:                 3cd75478-9d44-11e9-8a0a-42010a8e006e
Spec:
  Run Latest:
    Configuration:
      Revision Template:
        Metadata:
          Creation Timestamp:  <nil>
        Spec:
          Container:
            Image:              gcr.io/devops26/jx-knative:0.0.2
            Image Pull Policy:  IfNotPresent
            Liveness Probe:
              Http Get:
                Path:                 /
                Port:                 0
              Initial Delay Seconds:  60
              Period Seconds:         10
              Success Threshold:      1
              Timeout Seconds:        1
            Name:                     
            Readiness Probe:
              Http Get:
                Path:             /
                Port:             0
              Period Seconds:     10
              Success Threshold:  1
              Timeout Seconds:    1
            Resources:
              Limits:
                Cpu:     100m
                Memory:  256Mi
              Requests:
                Cpu:        80m
                Memory:     128Mi
          Timeout Seconds:  300
Status:
  Address:
    Hostname:  jx-knative.cd-staging.svc.cluster.local
  Conditions:
    Last Transition Time:        2019-07-03T03:40:09Z
    Status:                      True
    Type:                        ConfigurationsReady
    Last Transition Time:        2019-07-03T03:40:09Z
    Status:                      True
    Type:                        Ready
    Last Transition Time:        2019-07-03T03:40:09Z
    Status:                      True
    Type:                        RoutesReady
  Domain:                        jx-knative.cd-staging.35.243.171.144.nip.io
  Domain Internal:               jx-knative.cd-staging.svc.cluster.local
  Latest Created Revision Name:  jx-knative-svtns
  Latest Ready Revision Name:    jx-knative-svtns
  Observed Generation:           1
  Traffic:
    Percent:        100
    Revision Name:  jx-knative-svtns
Events:
  Type    Reason   Age                From                Message
  ----    ------   ----               ----                -------
  Normal  Created  59m                service-controller  Created Configuration "jx-knative"
  Normal  Created  59m                service-controller  Created Route "jx-knative"
  Normal  Updated  59m (x5 over 59m)  service-controller  Updated Service "jx-knative"
```

```bash
kubectl --namespace knative-serving \
    describe configmap config-autoscaler
```

```
Name:         config-autoscaler
Namespace:    knative-serving
Labels:       serving.knative.dev/release=devel
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"v1","data":{"_example":"################################\n#                              #\n#    EXAMPLE CONFIGURATION     ...

Data
====
_example:
----
################################
#                              #
#    EXAMPLE CONFIGURATION     #
#                              #
################################

# This block is not actually functional configuration,
# but serves to illustrate the available configuration
# options and document them in a way that is accessible
# to users that `kubectl edit` this config map.
#
# These sample configuration options may be copied out of
# this block and unindented to actually change the configuration.

# The Revision ContainerConcurrency field specifies the maximum number
# of requests the Container can handle at once. Container concurrency
# target percentage is how much of that maximum to use in a stable
# state. E.g. if a Revision specifies ContainerConcurrency of 10, then
# the Autoscaler will try to maintain 7 concurrent connections per pod
# on average. A value of 0.7 is chosen because the Autoscaler panics
# when concurrency exceeds 2x the desired set point. So we will panic
# before we reach the limit.
container-concurrency-target-percentage: "1.0"

# The container concurrency target default is what the Autoscaler will
# try to maintain when the Revision specifies unlimited concurrency.
# Even when specifying unlimited concurrency, the autoscaler will
# horizontally scale the application based on this target concurrency.
#
# A value of 100 is chosen because it's enough to allow vertical pod
# autoscaling to tune resource requests. E.g. maintaining 1 concurrent
# "hello world" request doesn't consume enough resources to allow VPA
# to achieve efficient resource usage (VPA CPU minimum is 300m).
container-concurrency-target-default: "100"

# When operating in a stable mode, the autoscaler operates on the
# average concurrency over the stable window.
stable-window: "60s"

# When observed average concurrency during the panic window reaches 2x
# the target concurrency, the autoscaler enters panic mode. When
# operating in panic mode, the autoscaler operates on the average
# concurrency over the panic window.
panic-window: "6s"

# Max scale up rate limits the rate at which the autoscaler will
# increase pod count. It is the maximum ratio of desired pods versus
# observed pods.
max-scale-up-rate: "10"

# Scale to zero feature flag
enable-scale-to-zero: "true"

# Tick interval is the time between autoscaling calculations.
tick-interval: "2s"

# Dynamic parameters (take effect when config map is updated):

# Scale to zero grace period is the time an inactive revision is left
# running before it is scaled to zero (min: 30s).
scale-to-zero-grace-period: "30s"

Events:  <none>
```

TODO: Rewrite
Algorithm
Knative Serving autoscaling is based on the average number of in-flight requests per pod (concurrency). The system has a default target concurrency of 100 but we used 10 for our service. We loaded the service with 50 concurrent requests so the autoscaler created 5 pods (50 concurrent requests / target of 10 = 5 pods)

TODO: Rewrite
Panic
The autoscaler calculates average concurrency over a 60 second window so it takes a minute for the system to stablize at the desired level of concurrency. However the autoscaler also calculates a 6 second panic window and will enter panic mode if that window reached 2x the target concurrency. In panic mode the autoscaler operates on the shorter, more sensitive panic window. Once the panic conditions are no longer met for 60 seconds, the autoscaler will return to the initial 60 second stable window.

```bash
kubectl --namespace cd-staging \
     get pods

# Repeat if `jx-knative-*` Pod is still running

# Apache Benchmark (ab) doesn't work with HTTP 1.1

kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- -c 300 -b -t 20S "http://$ADDR/" \
     && kubectl \
     --namespace cd-staging \
     get pods
```

```
f you don't see a command prompt, try pressing enter.

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
NAME                                           READY   STATUS    RESTARTS   AGE
jx-go-demo-6-b4cc65cf8-rkrwv                   1/1     Running   3          9h
jx-go-demo-6-b4cc65cf8-rlqgn                   1/1     Running   3          9h
jx-go-demo-6-b4cc65cf8-tck4j                   1/1     Running   3          9h
jx-go-demo-6-db-arbiter-0                      1/1     Running   0          9h
jx-go-demo-6-db-primary-0                      1/1     Running   0          9h
jx-go-demo-6-db-secondary-0                    1/1     Running   0          9h
jx-knative-gx5qh-deployment-66dd9d8d79-7lwds   2/2     Running   0          19s
jx-knative-gx5qh-deployment-66dd9d8d79-cjljb   2/2     Running   0          17s
jx-knative-gx5qh-deployment-66dd9d8d79-gr65d   2/2     Running   0          21s
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
vfarcic/environment-tekton-staging/master #6                1m5s     1m3s Succeeded
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
jx-knative   jx-knative.cd-staging.35.196.158.54.nip.io   jx-knative-64brz   jx-knative-64brz   True
```

```bash
kubectl --namespace cd-staging get pods
```

```
NAME                                           READY   STATUS    RESTARTS   AGE
jx-go-demo-6-b4cc65cf8-rkrwv                   1/1     Running   3          9h
jx-go-demo-6-b4cc65cf8-rlqgn                   1/1     Running   3          9h
jx-go-demo-6-b4cc65cf8-tck4j                   1/1     Running   3          9h
jx-go-demo-6-db-arbiter-0                      1/1     Running   0          9h
jx-go-demo-6-db-primary-0                      1/1     Running   0          9h
jx-go-demo-6-db-secondary-0                    1/1     Running   0          9h
jx-knative-gx5qh-deployment-66dd9d8d79-gr65d   2/2     Running   0          11m
```

```bash
# Repeat if `jx-knative-*` Pods of the last release are still running
# The old release might still be running

kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- -c 18 -b -t 30S "http://$ADDR/" \
     && kubectl \
     --namespace cd-staging \
     get pods
```

```
If you don't see a command prompt, try pressing enter.

Lifting the server siege...      done.

Transactions:                      0 hits
Availability:                   0.00 %
Elapsed time:                  29.34 secs
Data transferred:               0.00 MB
Response time:                  0.00 secs
Transaction rate:               0.00 trans/sec
Throughput:                     0.00 MB/sec
Concurrency:                    0.00
Successful transactions:           0
Failed transactions:               0
Longest transaction:            0.00
Shortest transaction:           0.00

FILE: /var/log/siege.log
You can disable this annoying message by editing
the .siegerc file in your home directory; change
the directive 'show-logfile' to false.
Session ended, resume using 'kubectl attach siege -c siege -i -t' command when the pod is running
pod "siege" deleted
NAME                                           READY   STATUS    RESTARTS   AGE
jx-go-demo-6-b4cc65cf8-rkrwv                   1/1     Running   3          9h
jx-go-demo-6-b4cc65cf8-rlqgn                   1/1     Running   3          9h
jx-go-demo-6-b4cc65cf8-tck4j                   1/1     Running   3          9h
jx-go-demo-6-db-arbiter-0                      1/1     Running   0          9h
jx-go-demo-6-db-primary-0                      1/1     Running   0          9h
jx-go-demo-6-db-secondary-0                    1/1     Running   0          9h
jx-knative-64brz-deployment-5d676d69d6-64922   2/2     Running   0          8s
jx-knative-64brz-deployment-5d676d69d6-9m7hr   2/2     Running   0          30s
jx-knative-64brz-deployment-5d676d69d6-bc95p   2/2     Running   0          30s
jx-knative-64brz-deployment-5d676d69d6-lbnhn   2/2     Running   0          31s
jx-knative-64brz-deployment-5d676d69d6-vg27f   2/2     Running   0          30s
jx-knative-gx5qh-deployment-66dd9d8d79-gr65d   2/2     Running   0          14m
```

```bash
# Wait for a while (e.g., 2 min)

kubectl --namespace cd-staging get pods
```

```
NAME                                           READY   STATUS    RESTARTS   AGE
jx-go-demo-6-b4cc65cf8-rkrwv                   1/1     Running   3          9h
jx-go-demo-6-b4cc65cf8-rlqgn                   1/1     Running   3          9h
jx-go-demo-6-b4cc65cf8-tck4j                   1/1     Running   3          9h
jx-go-demo-6-db-arbiter-0                      1/1     Running   0          9h
jx-go-demo-6-db-primary-0                      1/1     Running   0          9h
jx-go-demo-6-db-secondary-0                    1/1     Running   0          9h
jx-knative-64brz-deployment-5d676d69d6-lbnhn   2/2     Running   0          2m4s
jx-knative-gx5qh-deployment-66dd9d8d79-gr65d   2/2     Running   0          16m
```

```bash
# Wait for a while (e.g., 5-10 min)

kubectl --namespace cd-staging get pods
```

```
NAME                           READY   STATUS    RESTARTS   AGE
jx-go-demo-6-b4cc65cf8-rkrwv   1/1     Running   3          9h
jx-go-demo-6-b4cc65cf8-rlqgn   1/1     Running   3          9h
jx-go-demo-6-b4cc65cf8-tck4j   1/1     Running   3          9h
jx-go-demo-6-db-arbiter-0      1/1     Running   0          9h
jx-go-demo-6-db-primary-0      1/1     Running   0          9h
jx-go-demo-6-db-secondary-0    1/1     Running   0          9h
```

```bash
cat charts/jx-knative/templates/ksvc.yaml \
    | sed -e \
    's@autoscaling.knative.dev/target: "3"@autoscaling.knative.dev/target: "3"\
            autoscaling.knative.dev/minScale: "1"@g' \
    | tee charts/jx-knative/templates/ksvc.yaml
```

```
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

kubectl --namespace cd-staging get pods
```

```
NAME                                          READY   STATUS    RESTARTS   AGE
jx-go-demo-6-b4cc65cf8-rkrwv                  1/1     Running   3          10h
jx-go-demo-6-b4cc65cf8-rlqgn                  1/1     Running   3          10h
jx-go-demo-6-b4cc65cf8-tck4j                  1/1     Running   3          10h
jx-go-demo-6-db-arbiter-0                     1/1     Running   0          10h
jx-go-demo-6-db-primary-0                     1/1     Running   0          10h
jx-go-demo-6-db-secondary-0                   1/1     Running   0          10h
jx-knative-d7msk-deployment-cbdbb9fbb-g2n88   2/2     Running   0          14m51s
```

```bash
# NOTE: Should send logs to a central location (https://knative.dev/v0.5-docs/serving/installing-logging-metrics-traces/)

cd ../go-demo-6

git checkout -b serverless

ls -1 charts/go-demo-6/templates

# NOTE: If ksvc.yaml is not there, the project was created long time ago and it does not support KNative

TODO: Delete the application
TODO: Copy the chartss directory to charts-orig
TODO: Delete the chart
TODO: Import the application
TODO: Diff the changes

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
cat jenkins-x.yml \
  | sed '$ d' \
  | tee jenkins-x.yml
```

```
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

jx create pullrequest \
    --title "Serverless with Knative" \
    --body "What I can say?" \
    --batch-mode
```

```
Created Pull Request: https://github.com/vfarcic/go-demo-6/pull/109
```

```bash
BRANCH=[...] # e.g., `PR-109`
```

## TODO

* Combining serverless with "normal" (e.g. MongoDB)
* Pull requests or only pull requests
* Logging to a centralized location (https://knative.dev/docs/serving/accessing-logs/, https://knative.dev/v0.5-docs/serving/samples/telemetry-go/index.html)
* Metrics (https://knative.dev/docs/serving/accessing-metrics/)
* Convert https://www.devopstoolkitseries.com to Knative
* Create a PR to add the app to `jx get applications`


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
