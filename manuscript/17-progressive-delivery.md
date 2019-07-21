## TODO

- [ ] Code
- [ ] Write
- [ ] Code review static GKE
- [ ] Code review serverless GKE
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
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Progressive Delivery

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

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

TODO: Viktor: This text is from some other change. Rewrite it.

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [TODO: Viktor](TODO: Viktor) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

TODO: Add a note that the Gists are different (added `gloo`, GKE VM size increased)

* Create a new static **GKE** cluster: [gke-jx-gloo.sh](TODO:)
* Create a new serverless **GKE** cluster: [gke-jx-serverless-gloo.sh](TODO:)
* Create a new static **EKS** cluster: [eks-jx-gloo.sh](TODO:)
* Create a new serverless **EKS** cluster: [eks-jx-serverless-gloo.sh](TODO:)
* Create a new static **AKS** cluster: [aks-jx-gloo.sh](TODO:)
* Create a new serverless **AKS** cluster: [aks-jx-serverless-gloo.sh](TODO:)
* Use an **existing** static cluster: [install-gloo.sh](TODO:)
* Use an **existing** serverless cluster: [install-serverless-gloo.sh](TODO:)

TODO: Viktor: Check whether `extension-model` or some other branch should be restored

I> The commands that follow will reset your *go-demo-6* `master` branch with the contents of the branch that contain all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

W> Depending on whether you're using static or serverless Jenkins X flavor, we'll need to restore one branch or the other. The commands that follow will restore `extension-model-jx` if you are using static Jenkins X, or `extension-model-cd` if you prefer the serverless flavor.

```bash
NAMESPACE=$(kubectl config view \
    --minify \
    --output jsonpath="{..namespace}")

cd go-demo-6

git pull

git checkout knative-$NAMESPACE

git merge -s ours master --no-edit

git checkout master

git merge knative-$NAMESPACE

git push

cd ..
```

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
cd go-demo-6

jx import --pack go --batch-mode

cd ..
```

## Requirement Installation

We can easily install Istio and Flagger with `jx`

NOTE: Addons are probably going to be merged into apps

```bash
jx create addon istio \
    --version 1.1.7
```

NOTE: the command may fail due to the order Helm applies CRD resources. Rerunning the command again should fix it.

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

The Flagger addon will enable Istio for all pods in the `jx-production` namespace so they send traffic metrics to Prometheus.
It will also configure an Istio ingress gateway to accept incoming external traffic through the ingress gateway service, but for it to reach the final service we must create Istio `VirtualServices`, the rules that manage the Istio routing. Flagger will do that for us.

## Flagger App Configuration

Let's say we want to deploy our new version to 10% of the users, and increase it another 10% every 10 seconds until we reach 50% of the users, then deploy to all users. We will examine two key metrics, whether more than 1% of the requests fail (5xx errors) or the request time is over 500ms. If these metrics fail 5 times we want to rollback to the old version.

This configuration can be done using Flagger's `Canary` objects, that we can add to our application helm chart under `charts/go-demo-6/templates/canary.yaml` 

```bash
cd go-demo-6

git checkout master

jx edit deploy \
    --kind default \
    --batch-mode

echo "{{- if eq .Release.Namespace \"$NAMESPACE-production\" }}
{{- if .Values.canary.enable }}
apiVersion: flagger.app/v1alpha2
kind: Canary
metadata:
  name: {{ template \"fullname\" . }}
spec:
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
{{- end }}
" | tee charts/go-demo-6/templates/canary.yaml
```

And the `canary` section added to our chart values file in `charts/go-demo-6/values.yaml`. Remember to set the correct domain name for our Istio gateway instead of `go-demo-6.$ISTIO_IP.nip.io`.

```bash
echo "
canary:
  enable: true
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
    - name: istio_requests_total
      threshold: 99
      interval: 120s
    - name: istio_request_duration_seconds_bucket
      threshold: 500
      interval: 120s
" | tee -a charts/go-demo-6/values.yaml
```

Explanation of the values in the configuration:

* `canary.service.hosts` list of host names that Istio will send to our application.
* `canary.service.gateways` list of Istio gateways that will send traffic to our application. `jx-gateway.istio-system.svc.cluster.local` is the gateway created by the Flagger addon on installation.
* `canary.canaryAnalysis.threshold` number of times a metric must fail before aborting the rollout.
* `canary.canaryAnalysis.maxWeight` max percentage sent to the canary deployment, when reached all traffic is sent to the new new version.
* `canary.canaryAnalysis.stepWeight` increase the percentage this much in each interval (20%, 40%, 60%, etc).
* `canary.canaryAnalysis.metrics` metrics from Prometheus, some are automatically populated by Istio and you can add your own from your application.
  * `istio_requests_total` minimum request success rate (non 5xx responses) percentage (0-100).
  * `istio_request_duration_seconds_bucket` maximum request duration in milliseconds, in the 99th percentile.

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

# NOTE: Increasing the number of replicas to see how progressive delivery handles rolling updates
# TODO: Do we need to increase the number of replicas?
# cat charts/go-demo-6/values.yaml \
#     | sed -e \
#     's@replicaCount: .@replicaCount: 5@g' \
#     | tee charts/go-demo-6/values.yaml

git add .

git commit \
    -m "Added progressive deployment"

git push

jx get activities \
    --filter go-demo-6 \
    --watch

# Press *ctrl+c* when the activity is finished

jx get activities \
    --filter environment-tekton-staging/master \
    --watch

# Press *ctrl+c* when the activity is finished
```

NOTE: Nothing happens since it is automatically promoted to staging and `{{- if eq .Release.Namespace "jx-production" }}` applies only to production.

## Canary Deployments

On the first build of our app, Jenkins X will build and deploy the application Helm chart to the staging environment. We need to promotion it to production one first time before we can do canarying.

```bash
jx get applications --env staging

VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode

ISTIO_IP=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo $ISTIO_IP

curl "go-demo-6.$ISTIO_IP.nip.io/demo/hello"

# Repeat if `no healthy upstream`

kubectl \
    --namespace $NAMESPACE-production \
    get all

kubectl \
    --namespace $NAMESPACE-production \
    get virtualservice.networking.istio.io
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
kubectl --namespace istio-system logs \
    --selector app.kubernetes.io/name=flagger \
    --follow
```

NOTE: Stop with *ctrl+c*

And once the new version is built we can promote it to production.

```bash
cat main.go | sed -e \
    "s@hello, PR@hello, progressive@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@hello, PR@hello, progressive@g" \
    | tee main_test.go

git add .

git commit \
    -m "Added progressive deployment"

git push

jx get activities \
    --filter go-demo-6 \
    --watch

# Press *ctrl+c* when the activity is finished

jx get activities \
    --filter environment-tekton-staging/master \
    --watch

# Press *ctrl+c* when the activity is finished

jx get applications --env staging

VERSION=[...]

# Open a second terminal

# In a second terminal
ISTIO_IP=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

# In the second terminal
echo $ISTIO_IP

# In the second terminal
for i in {1..1000}
do
    curl "go-demo-6.$ISTIO_IP.nip.io/demo/hello"
    sleep 0.5
done

# Go back to the first terminal
jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode

kubectl \
    --namespace $NAMESPACE-production \
    get pods
```

Now Jenkins X will update the GitOps production environment repository to the new version by creating a pull request to change the version. After a little bit it will deploy the new version Helm chart that will update the `deployment.apps/jx-go-demo-6` object in the `jx-production` environment.

Flagger will detect this deployment change update the Istio `VirtualService` to send 10% of the traffic to the new version service `service/jx-go-demo-6` while 90% is sent to the previous version `service/jx-go-demo-6-primary`. We can see this Istio configuration with `kubectl -n jx-production get virtualservice/jx-go-demo-6 -o yaml` under the http route weight parameter.

```bash
kubectl \
    --namespace $NAMESPACE-production \
    get virtualservice.networking.istio.io \
    jx-go-demo-6 \
    --output yaml
```

```yaml
...
spec:
  gateways:
  - jx-gateway.istio-system.svc.cluster.local
  - mesh
  hosts:
  - go-demo-6.$ISTIO_IP.nip.io
  - jx-go-demo-6
  http:
  - route:
    - destination:
        host: jx-go-demo-6-primary
        port:
          number: 8080
      weight: 90
    - destination:
        host: jx-go-demo-6
        port:
          number: 8080
      weight: 10
```

We can test this by accessing our application using the dns we previously created for the Istio gateway. For instance running `curl "http://go-demo-6.${ISTIO_IP}.nip.io/demo/hello"` will give us the response from the previous version around 90% of the times, and the current version the other 10%.

Describing the canary object will also give us information about the deployment progress.

```bash
kubectl \
    --namespace $NAMESPACE-production \
    get ing

# TODO: We should probably remove the Ingress. Is there a reason for its existence?

kubectl \
    --namespace $NAMESPACE-production \
    describe canary jx-go-demo-6
```

```
  Last Transition Time:  2019-06-30T05:50:57Z
  Phase:                 Progressing
  Tracked Configs:
Events:
  Type     Reason  Age                From     Message
  ----     ------  ----               ----     -------
  Warning  Synced  11m (x6 over 12m)  flagger  Halt advancement jx-go-demo-6-primary.cd-production waiting for rollout to finish: 0 of 3 updated replicas are available
  Warning  Synced  11m                flagger  Halt advancement jx-go-demo-6-primary.cd-production waiting for rollout to finish: 1 of 3 updated replicas are available
  Normal   Synced  11m                flagger  Initialization done! jx-go-demo-6.cd-production
  Normal   Synced  60s                flagger  New revision detected! Scaling up jx-go-demo-6.cd-production
  Normal   Synced  50s                flagger  Starting canary analysis for jx-go-demo-6.cd-production
  Normal   Synced  50s                flagger  Advance jx-go-demo-6.cd-production canary weight 20
  Warning  Synced  40s                flagger  Halt advancement no values found for metric istio_requests_total probably jx-go-demo-6.cd-production is not receiving traffic
  Normal   Synced  30s                flagger  Advance jx-go-demo-6.cd-production canary weight 40
  Normal   Synced  20s                flagger  Advance jx-go-demo-6.cd-production canary weight 60
  Normal   Synced  10s                flagger  Advance jx-go-demo-6.cd-production canary weight 80
  Normal   Synced  0s                 flagger  Promotion completed! Scaling down jx-go-demo-6.cd-production
```

Every 10 seconds 10% more traffic will be directed to our new version if the metrics are successful. Note that we had to generate some traffic (with the curl loop above) otherwise Flagger will assume something is wrong with our deployment that is preventing traffic and will automatically roll back.


## Automated Rollbacks

Flagger will automatically rollback if any of the metrics we set fail the number of times set on the threshold configuration option, or if there are no metrics, as Flagger assumes something is very wrong with our application.

Let's show what would happen if we promote to production the previous version with no traffic.

```bash
# TODO: Roll forward

cat main.go | sed -e \
    "s@hello, progressive@hello, no one@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@hello, progressive@hello, no one@g" \
    | tee main_test.go

git add .

git commit \
    -m "Added progressive deployment"

git push

jx get activities \
    --filter go-demo-6 \
    --watch

# Press *ctrl+c* when the activity is finished

jx get activities \
    --filter environment-tekton-staging/master \
    --watch

jx get applications -e staging

VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode

jx get activities \
    --filter environment-tekton-production/master \
    --watch

# Not sending any requests

# After a few minutes

kubectl -n $NAMESPACE-production \
  describe canary jx-go-demo-6

Events:
  Type     Reason  Age                From     Message
  ----     ------  ----               ----     -------
  Warning  Synced  19m                flagger  Halt advancement jx-go-demo-6-primary.jx-production waiting for rollout to finish: 0 out of 1 new replicas have been updated
  Normal   Synced  18m                flagger  New revision detected! Scaling up jx-go-demo-6.jx-production
  Normal   Synced  17m                flagger  Starting canary analysis for jx-go-demo-6.jx-production
  Normal   Synced  17m                flagger  Advance jx-go-demo-6.jx-production canary weight 10
  Warning  Synced  12m (x5 over 16m)  flagger  Halt advancement no values found for metric istio_requests_total probably jx-go-demo-6.jx-production is not receiving traffic
  Warning  Synced  11m                flagger  Rolling back jx-go-demo-6.jx-production failed checks threshold reached 5
  Warning  Synced  11m                flagger  Canary failed! Scaling down jx-go-demo-6.jx-production
```

Now let's try again and show what happens when the application returns http errors.

NOTE: as the time of writing `jx get applications` will show versions that are out of sync from the ones actually deployed after a promotion failure. You can see the versions actually deployed with `kubectl -n jx-production get deploy -o wide`. For that same reason you can't try to immediately promote again a version that was rolled back by Flagger, as that version is already the one in the GitOps environment repo and will not trigger any deployment because there are no changes to the git files.


```bash
# Wait until it rolls back

curl "go-demo-6.$ISTIO_IP.nip.io/demo/hello"

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

jx get activities \
    --filter go-demo-6 \
    --watch

# Press *ctrl+c* when the activity is finished

jx get activities \
    --filter environment-tekton-staging/master \
    --watch

jx get applications -e staging

kubectl -n $NAMESPACE-production \
    get deploy -o wide

# use a different version than the one in the previous failed deployment
VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode

jx get activities \
    --filter environment-tekton-production/master \
    --watch

# Lets generate some http 500 errors (10% of the requests)

# NOTE: Go to the second terminal
for i in {1..1000}
do
    curl "go-demo-6.$ISTIO_IP.nip.io/demo/random-error"
done

kubectl -n $NAMESPACE-production \
  describe canary jx-go-demo-6

Events:
  Type     Reason  Age    From     Message
  ----     ------  ----   ----     -------
  Normal   Synced  5m47s  flagger  New revision detected! Scaling up jx-go-demo-6.jx-production
  Normal   Synced  5m17s  flagger  Advance jx-go-demo-6.jx-production canary weight 10
  Normal   Synced  5m17s  flagger  Starting canary analysis for jx-go-demo-6.jx-production
  Normal   Synced  4m47s  flagger  Advance jx-go-demo-6.jx-production canary weight 20
  Normal   Synced  4m17s  flagger  Advance jx-go-demo-6.jx-production canary weight 30
  Normal   Synced  3m47s  flagger  Advance jx-go-demo-6.jx-production canary weight 40
  Warning  Synced  3m17s  flagger  Halt jx-go-demo-6.jx-production advancement success rate 90.09% < 99%
  Warning  Synced  2m47s  flagger  Halt jx-go-demo-6.jx-production advancement success rate 88.57% < 99%
  Warning  Synced  2m17s  flagger  Halt jx-go-demo-6.jx-production advancement success rate 91.49% < 99%
  Warning  Synced  107s   flagger  Halt jx-go-demo-6.jx-production advancement success rate 96.00% < 99%
  Warning  Synced  77s    flagger  Halt jx-go-demo-6.jx-production advancement success rate 87.72% < 99%
  Warning  Synced  47s    flagger  Canary failed! Scaling down jx-go-demo-6.jx-production
  Warning  Synced  47s    flagger  Rolling back jx-go-demo-6.jx-production failed checks threshold reached 5
```

## Visualizing the Rollout

Flagger includes a Grafana dashboard where we can visually see metrics in our canary rollout process. By default is not accessible, so we need to create an ingress object pointing to the Grafana service running in the cluster.

TODO: vfarcic is $PROD_IP the correct ip ? Do we want to delete the ingress later?

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
  - host: flagger-grafana.jx.$PROD_IP.nip.io
    http:
      paths:
      - backend:
          serviceName: flagger-grafana
          servicePort: 80
" | kubectl create -f -
```

Then we can access Grafana at `http://flagger-grafana.jx.$PROD_IP.nip.io/d/flagger-istio/istio-canary?refresh=5s&orgId=1&var-namespace=jx-production&var-primary=jx-go-demo-6-primary&var-canary=jx-go-demo-6` using `admin/admin` credentials.
If not displayed directly, we should go to the `Istio Canary` dashboard and select

* namespace: `jx-production`
* primary: `jx-go-demo-6-primary`
* canary: `jx-go-demo-6`

to see metrics side by side of the previous version and the new version, such as request volume, request success rate, request duration, CPU and memory usage,...


## What Now?

TODO: Viktor: Rewrite

Now is a good time for you to take a break.

If you created a cluster only for the purpose of the exercises we executed, please destroy it. We'll start the next, and each other chapter from scratch as a way to save you from running your cluster longer than necessary and pay more than needed to your hosting vendor. If you created the cluster or installed Jenkins X using one of the Gists from the beginning of this chapter, you'll find the instructions on how to destroy the cluster or uninstall everything at the bottom.

If you did choose to destroy the cluster or to uninstall Jenkins X, please remove the repositories we created as well as the local files. You can use the commands that follow for that. Just remember to replace `[...]` with your GitHub user.

```bash
cd ..

GH_USER=[...]

# If static
hub delete -y \
  $GH_USER/environment-jx-rocks-staging

# If static
hub delete -y \
  $GH_USER/environment-jx-rocks-production

# If serverless
hub delete -y \
  $GH_USER/environment-tekton-staging

# If serverless
hub delete -y \
  $GH_USER/environment-tekton-production

# If static
rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

# If serverless
rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*
```

Finally, you might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just keep reading.
