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

Progressive Delivery is the next step after Continuous Delivery, a term including deployment strategies that try to avoid the pitfalls of all-or-nothing deployment strategies. Progressive Delivery encompasses methodologies such as blue-green and canary deployments, where new versions are deployed to a subset of users and are evaluated in terms of correctness and performance before rolling them to the totality of the users and rolled back if not matching some key metrics.

Blue-green consists of deploying a new version while keeping the old one running, and using load balancers or dns, send all users to one or another. Both old and new versions coexist until the new version is validated in production. If issues are found with the new deployment the load balancer or dns is pointed back to the old version.
Canary deployments deliver a new version to a subset of users, which is randomly chosen or based on some demographics like location. If no issues are found in production for this subset of users the deployment of the new version is dialed up gradually until reaching all the users. In other case it is just a matter of sending the users in the new version back to the old version.

Testing the 100% of an application is impossible, so we can use techniques like Canary or Blue-Green, covered under Progressive Delivery, to provide a safety net in our deployments.

We saw how easy it is with Jenkins X to promote applications from development to staging to production, using the concept of environments. But it is an all-or-nothing deployment process with manual intervention if a rollback is needed.

We will explore how Jenkins X integrates Flagger, Istio and Prometheus, projects that work together to create Canary deployments, where each deployment starts by getting a small percentage of the traffic and analysing metrics such as response errors and duration. If these metrics fit a predefined requirement the new deployment continues getting more and more traffic until 100% of it goes through the new service. If these metrics are not successful for any reason our deployment is rolled back and is marked as failure.

## Istio

Istio is a service mesh that can run on top of Kubernetes. It has become very popular and allows traffic management, for example sending a percentage of the traffic to a different service and other advanced networking such as point to point security, policy enforcement or automated tracing, monitoring and logging.

When Istio is enabled for a service it deploys an Envoy proxy alongside with it as a sidecar container. These proxies mediate in all network communication between services.

We could write a full book about Istio, so we will focus on the traffic shifting and metric gathering capabilities of Istio and how we use those to enable Canary deployments.

## Prometheus

Prometheus is the monitoring and alerting system of choice for Kubernetes clusters. It stores time series data that can be queried using PromQL, its query language. Time series collection happens via pull over HTTP.
Many systems integrate with Prometheus as data store for their metrics.

When Istio is enabled for a service it sends a number of metrics to Prometheus with no need to adapt our aplication. We will focus on the response times and status codes.

## Flagger

Flagger is a project sponsored by WeaveWorks using Istio to automate canarying and rollbacks using metrics from Prometheus. It goes beyond what Istio provides, automating the promotion of canary deployments using Istio for traffic shifting and Prometheus metrics for canary analysis, allowing progressive rollouts and rollbacks based on metrics.


[Flagger](https://github.com/stefanprodan/flagger) is a **Kubernetes** operator that automates the promotion of canary deployments using **Istio** routing for traffic shifting and **Prometheus** metrics for canary analysis.

Flagger requires Istio and Prometheus installed, plus the installation of the Flagger controller itself. It also offers a Grafana dashboard to monitor the deployment progress.

The deployment rollout is defined by a Canary object that will generate primary and canary Deployment objects. When the Deployment is edited, for instance to use a new image version, the Flagger controller will shift the loads from 0% to 50% with 10% increases every minute, then it will shift to the new deployment or rollback if response errors and request duration metrics fail.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

TODO: Viktor: This text is from some other change. Rewrite it.

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [TODO: Viktor](TODO: Viktor) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new static **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new static **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new static **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** static cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

TODO: Viktor: Check whether `versioning` or some other branch should be restored

I> The commands that follow will reset your *go-demo-6* `master` branch with the contents of the `versioning` branch that contains all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

```bash
cd go-demo-6

git pull

git checkout versioning

git merge -s ours master --no-edit

git checkout master

git merge versioning

git push

cd ..
```

Please wait until the activity of the application shows that all the steps were executed successfully, and stop the watcher by pressing *ctrl+c*.

Now we can promote our last release to production.

## Requirement Installation

We can easily install Istio, Prometheus and Flagger with `jx`

```bash
# TODO: Replace with `jx add app` when `app` are finished.
jx create addon istio
```

When installing Istio a new ingress gateway servie is created that can send all the incoming traffic to services based on Istio rules or `VirtualServices`. This achieves a similar functionality than that of the ingress controller, but using Istio configuration instead of ingresses, that allows us to create more advanced rules for incoming traffic.

We can find the external ip address of the ingress gateway service and configure a wildcard DNS for it, so we can use multiple hostnames for different services.
Note the ip from the output of `jx create addon istio` or find it with this command, we will refer to it as `ISTIO_IP`.

```bash
ISTIO_IP=$(kubectl --namespace istio-system \
    get service istio-ingressgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo $ISTIO_IP
```

Let's continue with the other addons

```bash
jx create addon prometheus

jx create addon flagger
```

The Flagger addon will enable Istio for all pods in the `jx-production` namespace so they send traffic metrics to Prometheus.
It will also configure an Istio ingress gateway to accept incoming external traffic through the ingress gateway service, but for it to reach the final service we must create Istio `VirtualServices`, the rules that manage the Istio routing. Flagger will do that for us.

## Flagger App Configuration

Let's say we want to deploy our new version to 10% of the users, and increase it another 10% every minute until we reach 50% of the users, then deploy to all users. We will examine two key metrics, whether more than 1% of the requests fail (5xx errors) or the request time is over 500ms. If these metrics fail 5 times we want to rollback to the old version.

This configuration can be done using Flagger's `Canary` objects, that we can add to our application helm chart under `charts/go-demo-6/templates/canary.yaml` 

```bash
cd go-demo-6

# Only if not reusing the cluster from the previous chapter
jx import --batch-mode

# Only if not reusing the cluster from the previous chapter
jx get activities \
    --filter go-demo-6 \
    --watch

# Only if not reusing the cluster from the previous chapter
# Press *ctrl+c* when the activity is finished

# Only if the application was not already promoted to production
jx get applications -e staging

# Only if the application was not already promoted to production
VERSION=[...]

# Only if the application was not already promoted to production
jx promote go-demo-6 \
    --version $VERSION \
    --env production º
    --batch-mode

# TODO: Carlos: Shouldn't we test canary in staging first (probably much faster though)?

echo '{{- if eq .Release.Namespace "jx-production" }}
{{- if .Values.canary.enable }}
apiVersion: flagger.app/v1alpha2
kind: Canary
metadata:
  name: {{ template "fullname" . }}
spec:
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
{{- end }}
' | tee charts/go-demo-6/templates/canary.yaml
```

And the `canary` section added to our chart values file in `charts/go-demo-6/values.yaml`. Remember to set the correct domain name for our Istio gateway instead of `go-demo-6.ISTIO_IP.nip.io`.

```bash
# TODO: Carlos: If canary can be enabled on any environment, than we should probably have `canary.enable` and `canary.service.hosts` set in the values.yaml inside the env. repo. That would also remove the need for `{{- if eq .Release.Namespace "jx-production" }}` in `canary.yaml`.

echo "
canary:
  enable: true
  service:
    hosts:
    - go-demo-6.$ISTIO_IP.nip.io
    gateways:
    - jx-gateway.istio-system.svc.cluster.local
  canaryAnalysis:
    interval: 60s
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
    - name: istio_requests_total
      threshold: 99
      interval: 60s
    - name: istio_request_duration_seconds_bucket
      threshold: 500
      interval: 60s
" | tee -a charts/go-demo-6/values.yaml
```

Explanation of the values in the configuration:

* `canary.service.hosts` list of host names that Istio will send to our application.
* `canary.service.gateways` list of Istio gateways that will send traffic to our application. `jx-gateway.istio-system.svc.cluster.local` is the gateway created by the Flagger addon on installation.
* `canary.canaryAnalysis.threshold` number of times a metric must fail before aborting the rollout.
* `canary.canaryAnalysis.maxWeight` max percentage sent to the canary deployment, when reached all traffic is sent to the new new version.
* `canary.canaryAnalysis.stepWeight` increase the percentage this much in each interval (10%, 20%, 30%, 40%).
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
```


## Canary Deployments

On the first build of our app, Jenkins X will build and deploy the application Helm chart to the staging environment. We need to promotion it to production one first time before we can do canarying.

```bash
jx get applications -e staging

VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode
```

After detecting a new `Canary` object Flagger will automatically create some other objects to manage the canary deployment:

* deployment.apps/jx-go-demo-6-primary
* service/jx-go-demo-6
* service/jx-go-demo-6-canary
* service/jx-go-demo-6-primary
* virtualservice.networking.istio.io/jx-go-demo-6

The primary and canary deployments manage the incumbent and new version of the deploy respectively. Flagger will have both running during the canary process and create the Istio `VirtualService` that sends traffic to one or another. Initially all traffic is sent to the primary deployment. Lets make a new deployment and see how it is being canaried.

We are going to create a trivial change in the demo application, replacing `hello, PR!` in `main.go` to `hello canary, PR!`. Then we will commit and merge it to master to get a new version in the staging environment. 

Now in another terminal let's tail Flagger logs so we can get insights in the deployment process.

```
kubectl -n istio-system -f deploy/flagger
```

And once the new version is built we can promote to production the new version.

```bash
jx get applications -e staging

VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode
```

Now Jenkins X will update the GitOps production environment repository to the new version by creating a pull request to change the version. After a little bit it will deploy the new version Helm chart that will update the `deployment.apps/jx-go-demo-6` object in the `jx-production` environment.

Flagger will detect this deployment change update the Istio `VirtualService` to send 10% of the traffic to the new version service `service/jx-go-demo-6` while 90% is sent to the previous version `service/jx-go-demo-6-primary`. We can see this Istio configuration with `kubectl -n jx-production get virtualservice/jx-go-demo-6 -o yaml` under the http route weight parameter.

```
...
spec:
  gateways:
  - jx-gateway.istio-system.svc.cluster.local
  - mesh
  hosts:
  - go-demo-6.ISTIO_IP.nip.io
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

We can test this by accessing our application using the dns we previously created for the Istio gateway. For instance running `curl -skL "http://go-demo-6.${ISTIO_IP}.nip.io/demo/hello"` will give us the response from the previous version around 90% of the times, and the current version the other 10%.

Describing the canary object will also give us information about the deployment progress.

```
kubectl -n jx-production describe canary/jx-go-demo-6

Events:
  Type     Reason  Age   From     Message
  ----     ------  ----  ----     -------
  Normal   Synced  3m    flagger  New revision detected jx-go-demo-6.jx-production
  Normal   Synced  3m    flagger  Scaling up jx-go-demo-6.jx-production
  Warning  Synced  3m    flagger  Waiting for jx-go-demo-6.jx-production rollout to finish: 0 of 1 updated replicas are available
  Normal   Synced  3m    flagger  Advance jx-go-demo-6.jx-production canary weight 10
  Normal   Synced  2m    flagger  Advance jx-go-demo-6.jx-production canary weight 20
```

Every minute 10% more traffic will be directed to our new version if the metrics are successful. Note that we need to generate some traffic otherwise Flagger will assume something is wrong with our deployment that is preventing traffic and will automatically roll back.

```
kubectl -n jx-production describe canary/jx-go-demo-6

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

If the metrics fail we would see events similar to the following

```
kubectl -n jx-production describe canary/jx-go-demo-6

Status:
  Canary Revision:  16695041
  Failed Checks:    10
  State:            failed
Events:
  Type     Reason  Age   From     Message
  ----     ------  ----  ----     -------
  Normal   Synced  3m    flagger  Starting canary deployment for jx-go-demo-6.jx-production
  Normal   Synced  3m    flagger  Advance jx-go-demo-6.jx-production canary weight 10
  Normal   Synced  3m    flagger  Halt jx-go-demo-6.jx-production advancement success rate 69.17% < 99%
  Normal   Synced  2m    flagger  Halt jx-go-demo-6.jx-production advancement success rate 61.39% < 99%
  Normal   Synced  2m    flagger  Halt jx-go-demo-6.jx-production advancement success rate 55.06% < 99%
  Normal   Synced  2m    flagger  Halt jx-go-demo-6.jx-production advancement success rate 47.00% < 99%
  Normal   Synced  2m    flagger  (combined from similar events): Halt jx-go-demo-6.jx-production advancement success rate 38.08% < 99%
  Warning  Synced  1m    flagger  Rolling back jx-go-demo-6.jx-production failed checks threshold reached 10
  Warning  Synced  1m    flagger  Canary failed! Scaling down jx-go-demo-6.jx-production
```

## Visualizing the Rollout

Flagger includes a Grafana dashboard where we can visually see metrics in our canary rollout process. To access it we need to create a tunnel to the Grafana service running in the cluster as it is not publicly exposed.

```bash
kubectl --namespace istio-system port-forward deploy/flagger-grafana 3000
```

Then we can access Grafana at [http://localhost:3000](http://localhost:3000) using `admin/admin` credentials.
Going to the `canary-analysis` dashboard we should select

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

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
```

Finally, you might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just keep reading.
