# Progressive Delivery

Progressive Delivery is the next step after Continuous Delivery, a term including deployment strategies that try to avoid the pitfalls of all-or-nothing deployment strategies. Progressive Delivery encompasses methodologies such as blue-green and canary deployments, where new versions are deployed to a subset of users and are evaluated in terms of correctness and performance before rolling them to the totality of the users and rolled back if not matching some key metrics.

Blue-green consists of deploying a new version while keeping the old one running, and using load balancers or dns, send all users to one or another. Both old and new versions coexist until the new version is validated in production. If issues are found with the new deployment the load balancer or dns is pointed back to the old version.
Canary deployments deliver a new version to a subset of users, which is randomly chosen or based on some demographics like location. If no issues are found in production for this subset of users the deployment of the new version is dialed up gradually until reaching all the users. In other case it is just a matter of sending the users in the new version back to the old version.

We saw how easy it is with Jenkins X to promote applications from development to staging to production, using the concept of environments. But it is an all-or-nothing deployment process with manual intervention if a rollback is needed.

We will explore how Jenkins X integrates Flagger, Istio and Prometheus, projects that work together to create Canary deployments, where each deployment starts by getting a small percentage of the traffic and analysing metrics such as response errors and duration. If these metrics fit a predefined requirement the new deployment continues getting more and more traffic until 100% of it goes through the new service. If these metrics are not successful for any reason our deployment is rolled back and is marked as failure.

## Istio

Istio is service mesh that can run on top of Kubernetes. It has become very popular and allows traffic management, for example sending a percentage of the traffic to a different service and other advanced networking such as point to point security, policy enforcement or automated tracing, monitoring and logging.

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


TODO create cluster
TODO import project

## Requirement Installation

We can easily install Istio, Prometheus and Flagger with `jx`

```bash
jx create addon istio
jx create addon prometheus
jx create addon flagger
```

Then we need to enable Istio for all pods in the `jx-staging` and `jx-production` namespaces so it starts sending metrics to Prometheus.

```
kubectl label namespace jx-staging istio-injection=enabled
kubectl label namespace jx-production istio-injection=enabled
```

When installing Istio a new ingress gateway is created that can send all the incoming traffc to services based on Istio rules or `VirtualServices`. This achieves a similar functionality than that of the ingress controller, but using Istio configuration instead of ingresses, that allows us to create more advanced rules for incoming traffic.

We can find the external ip address of the ingress gateway and configure a wildcard DNS for it, so we can use multiple hostnames for different services.

TODO

In order for the Istio ingress gateway to accept incoming traffic we need to create a `Gateway` that processes all that external traffic through the Ingress Gateway.

A very permissive gateway that accepts traffic for any host name

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
 name: public-gateway
 namespace: istio-system
spec:
 selector:
   istio: ingressgateway
 servers:
 - port:
     number: 80
     name: http
     protocol: HTTP
   hosts:
   - "*"
```

Now our gateway will accept traffic for all hosts, but for it to reach the final service we must create `VirtualServices`, the rules that manage the Istio routing. But Flagger will do that for us.

TODO Note that Istio by default will block all outgoing traffic, 

## Flagger App Configuration

Let's say we want to deploy our new version to 10% of the users, and increase it another 10% every minute until we reach 50% of the users, then deploy to all users. We will examine two key metrics, whether more than 1% of the requests fail (5xx errors) or the request time is over 500ms. If these metrics fail 5 times we want to rollback to the old version.

This configuration can be done using Flagger's `Canary` objects, that we can add to our helm chart under `charts/demo6`.

```yaml
# We only want to enable canarying in production, not staging or preview environments
{{- if eq .Release.Namespace "jx-production" }}
apiVersion: flagger.app/v1alpha2
kind: Canary
metadata:
  # canary name must match deployment name
  name: jx-production-demo6
  namespace: jx-production
spec:
  # deployment reference
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: jx-production-demo6
  # HPA reference (optional)
  # autoscalerRef:
  #   apiVersion: autoscaling/v2beta1
  #   kind: HorizontalPodAutoscaler
  #   name: jx-production-demo6
  # the maximum time in seconds for the canary deployment
  # to make progress before it is rollback (default 600s)
  progressDeadlineSeconds: 60
  service:
    # container port
    port: 8080
    # Istio gateways (optional)
    gateways:
    - public-gateway.istio-system.svc.cluster.local
    # Istio virtual service host names (optional)
    hosts:
    # TODO this should be optional
    - croc-hunter.istio.us.g.csanchez.org
  canaryAnalysis:
    # schedule interval (default 60s)
    interval: 60s
    # max number of failed metric checks before rollback
    threshold: 5
    # max traffic percentage routed to canary
    # percentage (0-100)
    maxWeight: 50
    # canary increment step
    # percentage (0-100)
    stepWeight: 10
    metrics:
    - name: istio_requests_total
      # minimum req success rate (non 5xx responses)
      # percentage (0-100)
      threshold: 99
      interval: 60s
    - name: istio_request_duration_seconds_bucket
      # maximum req duration P99
      # milliseconds
      threshold: 500
      interval: 60s
{{- end }}
```

Once we commit and push this canary file in our repo master branch Jenkins X will build and deploy the application Helm chart to the staging environment. We need to promotion it to production one first time before we can do canarying.

```bash
jx get applications -e staging

VERSION=[...]

jx promote go-demo-6 --version $VERSION --env production -b
```

After detecting a new `Canary` object Flagger will automatically create some other objects to manage the canary deployment:

* deployment.apps/jx-production-demo6-primary
* service/jx-production-demo6
* service/jx-production-demo6-canary
* service/jx-production-demo6-primary
* virtualservice.networking.istio.io/jx-production-demo6

The primary and canary deployments manage the incumbent and new version of the deploy respectively. Flagger will have both running during the canary process and create the `VirtualService` that sends traffic to one or another. Initially all traffic is sent to the primary deoloyment. Lets make a new deployment and see how it is being canaried.

Create some trivial change in the demo application, and merge it to master so you get a new version in the staging environment.

```
TODO
```

Now in another terminal let's tail Flagger logs so we can get insights in the deployment process, run

```
kubectl -n istio-system -f deploy/flagger
```

Get the applications running

```
jx get applications
```

Promote to production the new version

```
jx promote demo6 --env production --version=[...] -b
```

Now Jenkins X will update the GitOps production environment repository to the new version by creating a pull request to change the version. After a little bit it will deploy the new version Helm chart that will update the `Deployment` object in the `jx-production` environment.

Flagger will detedct this deployment change and then update the `jx-production-demo6-canary` deployment to the new version while keeping `jx-production-demo6-primary` in the previous one. It will then update the Istio `VirtualService` as follows.

```
TODO
```

This change will make Istio send 10% of the traffic to the `jx-production-demo6-canary` deployment pods. We can test this by accessing our application using the dns we previously created for the Istio gateway.

Every minute 10% more traffic will be directed to our new version if the metrics are successful.

Describing the canary object will also give us information about the deployment progress.

```
kubectl -n jx-production describe canary/jx-production-demo6
Events:
  Type     Reason  Age   From     Message
  ----     ------  ----  ----     -------
  Normal   Synced  3m    flagger  New revision detected jx-production-demo6.jx-production
  Normal   Synced  3m    flagger  Scaling up jx-production-demo6.jx-production
  Warning  Synced  3m    flagger  Waiting for jx-production-demo6.jx-production rollout to finish: 0 of 1 updated replicas are available
  Normal   Synced  3m    flagger  Advance jx-production-demo6.jx-production canary weight 10
  Normal   Synced  2m    flagger  Advance jx-production-demo6.jx-production canary weight 20
```

If the metrics fail we would see events similar to the following

```
kubectl -n jx-production describe canary/jx-production-demo6

Status:
  Canary Revision:  16695041
  Failed Checks:    10
  State:            failed
Events:
  Type     Reason  Age   From     Message
  ----     ------  ----  ----     -------
  Normal   Synced  3m    flagger  Starting canary deployment for jx-production-demo6.jx-production
  Normal   Synced  3m    flagger  Advance jx-production-demo6.jx-production canary weight 10
  Normal   Synced  3m    flagger  Halt jx-production-demo6.jx-production advancement success rate 69.17% < 99%
  Normal   Synced  2m    flagger  Halt jx-production-demo6.jx-production advancement success rate 61.39% < 99%
  Normal   Synced  2m    flagger  Halt jx-production-demo6.jx-production advancement success rate 55.06% < 99%
  Normal   Synced  2m    flagger  Halt jx-production-demo6.jx-production advancement success rate 47.00% < 99%
  Normal   Synced  2m    flagger  (combined from similar events): Halt jx-production-demo6.jx-production advancement success rate 38.08% < 99%
  Warning  Synced  1m    flagger  Rolling back jx-production-demo6.jx-production failed checks threshold reached 10
  Warning  Synced  1m    flagger  Canary failed! Scaling down jx-production-demo6.jx-production
```


## Why Did We Do All That?

Testing the 100% of an application is impossible, so we can use techniques like Canary or Blue-Green, covered by the recently coined term of Progressive Delivery, to provide a safety net in our deployments.
Jenkins X can provide automatic Canary deployments, gradually exposing our new deployments to a percentage of our users and rolling back on the event of errors. Human steps are no longer needed. This makes it really easy to adopt Canarying and the benefits it provides. 


## What Now?

Now is a good time for you to take a break.

If you created a cluster only for the purpose of the exercises we executed, please destroy it. We'll start the next, and each other chapter from scratch as a way to save you from running your cluster longer than necessary and pay more than needed to your hosting vendor. If you created the cluster or installed Jenkins X using one of the Gists from the beginning of this chapter, you'll find the instructions on how to destroy the cluster or uninstall everything at the bottom.

If you did choose to destroy the cluster or to uninstall Jenkins X, please remove the repositories we created as well as the local files. You can use the commands that follow for that. Just remember to replace `[...]` with your GitHub user.

```bash
hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```

Finally, you might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just keep reading.
