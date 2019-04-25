## TODO

- [ ] Code
- [ ] Write
- [ ] Code review GKE
- [ ] Code review EKS
- [ ] Code review AKS
- [ ] Code review existing cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Extending Jenkins X Through Addons

So far, Jenkins X provided everything we need for continuous delivery out of the box. But, that might not always be the case. The chances are that sooner or later we'll need more tools that those that are included in the default installation. In such a case, we will have to add more tools to the cluster. We could do that by installing additional Helm charts or we can let Jenkins X help us with that as well. Since this is not the time and place to teach you Helm (I assume you already know how it works), we'll focus on the latter. We'll add a couple of additional tools to the cluster and explore how they can help us improve our processes.

But, before we do that, we might need to create a Jenkins X cluster.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [10-addons.sh](TODO:) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

We'll continue using the *go-demo-6* application. Please enter the local copy of the repository, unless you're there already.

```bash
cd go-demo-6
```

I> The commands that follow will reset your `master` with the contents of the `pr` branch that contains all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

```bash
git pull

git checkout pr

git merge -s ours master --no-edit

git checkout master

git merge pr

git push
```

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
jx import -b

jx get activities -f go-demo-6 -w
```

Please wait until the activity of the application shows that all the steps were executed successfully, and stop the watcher by pressing *ctrl+c*.

Now we can extend our cluster with additional tools.

## Using Addons To Extend Jenkins X

Jenkins X can be extended through addons and the first action we should perform is to check which ones are currently available.

```bash
jx get addons
```

My output is as follows.

```
NAME               CHART                         ENABLED STATUS VERSION
ambassador         datawire/ambassador
anchore            stable/anchore-engine
cb                 cb/core
flagger            flagger/flagger
gitea              jenkins-x/gitea
grafana            stable/grafana
istio              install/kubernetes/helm/istio
jx-build-templates jenkins-x/jx-build-templates
jx-prow            jenkins-x/prow
jx-sso-dex         jenkins-x/dex
jx-sso-operator    jenkins-x/sso-operator
knative-build      jenkins-x/knative-build
kubeless           incubator/kubeless
prometheus         stable/prometheus
tekton             jenkins-x/tekton
vault-operator     jenkins-x/vault-operator
```

As you can see, there are quite a few available addons. By the time you're reading this, the list will likely be bigger than those you can observe from my output. That should not matter much since our goal is not to go through all of them, but rather a only a few. We'll explore how to create (install) an addon that can be useful in our pipelines as well as to prepare for the objectives we'll define in the next chapter. Creating addons follows the same pattern, so knowing how to deal with a few should provide enough information to work with any.

The first addon we'll create is Prometheus.

## Prometheus

TODO: Continue code

```bash
# echo "extraScrapeConfigs: |
#   - job_name: anchore-api
#     scrape_interval: 15s
#     scrape_timeout: 10s
#     metrics_path: /metrics
#     scheme: http
#     static_configs:
#     - targets:
#       - anchore-anchore-engine:8228
#     basic_auth:
#       username: admin
#       password: anchore
# " | tee prom-values.yaml

# jx create addon prometheus \
#   -f prom-values.yaml

jx create addon prometheus

# TODO: Explore how to customize it.

PROM_ADDR=$(kubectl -n jx \
    get ing prometheus-server \
    -o jsonpath="{.spec.rules[0].host}")

open "http://$PROM_ADDR"

# Use *admin* as the username and the password

# jx create addon grafana

# GRAF_ADDR=$(kubectl -n jx \
#     get ing     prometheus-server \
#     -o jsonpath="{.spec.rules[0].host}")

# open "http://$GRAF_ADDR"
```

TODO: Continue code

## Istio

NOTE: Except GKE

```bash
jx create addon istio
```

NOTE: GKE

```bash
gcloud beta container clusters \
    update jx-rocks \
    --update-addons=Istio=ENABLED \
    --istio-config=auth=MTLS_STRICT

kubectl -n istio-system \
    get pods,services
```

TODO: Code

## Flagger

TODO: Code

## Permanent Addons

TODO: Code

```bash
jx edit addon
```

## What Now?

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
```