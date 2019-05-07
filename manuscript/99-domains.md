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

# Upgrading

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

TODO: Fix `upgrade_ingress.go` so that GH user can be used besides the organization.

TODO: https://github.com/jenkins-x/jx/pull/3527

TODO: https://github.com/jenkins-x/jx/issues/3115

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [09-promote.sh](https://gist.github.com/345da6a87564078b84d30eccfd3037c9) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new static **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new static **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new static **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** static cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

TODO: Check whether `versioning` should be restored

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

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
cd go-demo-6

jx import --batch-mode

jx get activities \
    --filter go-demo-6 \
    --watch

cd ..
```

Please wait until the activity of the application shows that all the steps were executed successfully, and stop the watcher by pressing *ctrl+c*.

Now we can promote our last release to production.

## Upgrading The Cluster

```bash
open "https://github.com/jenkins-x/jenkins-x-versions/blob/master/charts/jenkins-x/jenkins-x-platform.yml"

jx upgrade --help

jx upgrade platform --help

# It should be `jx upgrade platform --version ...`, just as version should be specified in `jx create cluster` or `jx install`.

jx upgrade platform

jx get addons

jx upgrade addons prow

jx get apps

jx upgrade app [...]

jx upgrade binaries

jx upgrade binaries

jx upgrade cli

jx upgrade crd

jx upgrade extensions

# jx upgrade ingress?
```

## Adding TLS Certificates

```bash
jx get applications

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"

kubectl -n kube-system \
    get svc jxing-nginx-ingress-controller \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}"

# Change your DNS A records in your domain registrar

DOMAIN=[...]

ping $DOMAIN

jx upgrade ingress --help

# Switch to the batch mode
jx upgrade ingress \
    --cluster true \
    --domain $DOMAIN

# NOTE: It takes a while...

kubectl --namespace cert-manager \
    logs --selector app=cert-manager

jx get applications

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"

# Wait in case of an error.
# TODO: It does not work

jx console

cd go-demo-6

jx repo --batch-mode

# Settings > Webhooks
```

## Changing Domain Patterns

```bash
jx get applications

jx upgrade ingress \
    --namespaces jx-staging \
    --urltemplate "{{.Service}}.staging.{{.Domain}}" \
    --batch-mode

jx get applications

VERSION=[...]

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"

jx get applications

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode

jx get env

PROD_ADDR=[...]

curl "$PROD_ADDR/demo/hello"

jx upgrade ingress \
    --namespaces jx-production \
    --skip-certmanager true \
    --urltemplate "{{.Service}}.{{.Domain}}" \
    -b
```

```bash
jx get applications
```

```bash
PROD_ADDR=[...]

curl "$PROD_ADDR/demo/hello"
```

```bash
# `urltemplate` could be `{{.Service}}.com`

echo "{{- if eq .Release.Namespace \"jx-production\" }}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: go-demo-6-prod
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: $DOMAIN
    http:
      paths:
      - backend:
          serviceName: go-demo-6
          servicePort: 80
{{- end }}
" | tee charts/go-demo-6/templates/ing.yaml

git add .

git commit \
    --message "Added Ingress"

git push

jx get activity -f go-demo-6 -w

jx get applications
```

```bash
VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode

jx get applications

curl "http://$DOMAIN/demo/hello"

# NOTE: There are no certificates
```

## What Now?

TODO: Rewrite

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you chose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
```