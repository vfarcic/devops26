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

# Domains

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

TODO: Rewrite

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [09-promote.sh](https://gist.github.com/345da6a87564078b84d30eccfd3037c9) Gist.

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

Now we can promote our last release to production.

## Changing domains

```bash
# TODO: Upgrade UrlTemplate for the whole cluster

# Must be version 1.3.1068+.

jx upgrade ingress \
    --cluster true \
    --skip-certmanager true \
    --urltemplate "{{.Namespace}}.{{.Service}}.{{.Domain}}" \
    -b

jx get applications

VERSION=0.0.196

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    -b

jx get applications

PROD_ADDR=[...]

curl "$PROD_ADDR/demo/hello"

jx upgrade ingress \
    --namespaces jx-production \
    --skip-certmanager true \
    --urltemplate "{{.Service}}.{{.Domain}}" \
    -b

jx get applications

PROD_ADDR=[...]

curl "$PROD_ADDR/demo/hello"

echo '{{- if eq .Release.Namespace "jx-production" }}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: go-demo-6
  annotations:
    kubernetes.io/ingress.class: "nginx"
    ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: go-demo-6.com
    http:
      paths:
      - backend:
          serviceName: go-demo-6
          servicePort: 80
{{- end }}
' | tee charts/go-demo-6/templates/ing.yaml

# Add `if` to service.yaml as well

git add .

git commit -m "Added Ingress"

git push

jx get activity -f go-demo-6 -w

jx get applications

VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    -b

jx get applications

ADDR=[...] # Convert to a `kubectl` query

curl -H "Host: go-demo-6.com" \
    "http://$ADDR/demo/hello"

# TODO: Cert Manager
```

## What Now?

TODO: Conclusion

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

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```