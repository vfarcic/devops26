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
jx upgrade ingress

# Use the default values

# Cancel with `n` at `? Using config values { 34.73.153.155.nip.io  Ingress  false}, ok? (Y/n)`
```

```
Looking for existing ingress rules in current namespace jx
? Existing ingress rules found in current namespace.  Confirm to delete and recreate them Yes
? Expose type Ingress
? Domain: 34.73.153.155.nip.io
? UrlTemplate (press <Enter> to keep the current value):
? Using config values { 34.73.153.155.nip.io  Ingress  false}, ok? No
```

```bash
# NOTE: Domain can be changed only if not in batch mode.

# Must be version 1.3.1068+.

jx get applications
```

The output is as follows.

```
APPLICATION STAGING PODS URL
go-demo-6   0.0.200 1/1  http://go-demo-6.jx-staging.35.243.161.174.nip.io
```

```bash
kubectl -n kube-system \
    get svc jxing-nginx-ingress-controller \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
```

```
35.243.161.174
```

```bash
# Change your DNS A records in your domain registrar

DOMAIN=[...]

jx upgrade ingress \
    --cluster true
    --domain $DOMAIN \
    --wait-for-certs true \
    -b
```

```
TODO: Output
```

```bash
jx get applications
```

```
TODO: Output
```

TODO: Confirm that new domains with certificates are working

```bash
jx upgrade ingress \
    --namespaces jx-staging \
    --skip-certmanager true \
    --urltemplate "{{.Service}}.staging.{{.Domain}}" \
    -b
```

```
Deleting ingress jx-staging/go-demo-6
using stable version 2.3.97 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Ingress rules recreated
Previous webhook endpoint http://jenkins.jx.35.243.161.174.nip.io/github-webhook/
Updated webhook endpoint http://jenkins.jx.35.243.161.174.nip.io/github-webhook/
Webhook URL unchanged. Use --force to force updating
```

```bash
jx get applications
```

```
APPLICATION STAGING PODS URL
go-demo-6   0.0.200 1/1  http://go-demo-6.staging.35.243.161.174.nip.io
```

```bash
VERSION=[...]

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    -b

jx get applications
```

```
APPLICATION STAGING PODS URL                                            PRODUCTION PODS URL
go-demo-6   0.0.200 1/1  http://go-demo-6.staging.35.243.161.174.nip.io 0.0.200    1/1  http://go-demo-6.jx-production.35.243.161.174.nip.io
```

```bash
PROD_ADDR=[...]

curl "$PROD_ADDR/demo/hello"
```

```
hello, PR!
```

```bash
jx upgrade ingress \
    --namespaces jx-production \
    --skip-certmanager true \
    --urltemplate "{{.Service}}.{{.Domain}}" \
    -b
```

```
Deleting ingress jx-production/go-demo-6
using stable version 2.3.97 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Ingress rules recreated
Previous webhook endpoint http://jenkins.jx.35.243.161.174.nip.io/github-webhook/
Updated webhook endpoint http://jenkins.jx.35.243.161.174.nip.io/github-webhook/
Webhook URL unchanged. Use --force to force updating
```

```bash
jx get applications
```

```
APPLICATION STAGING PODS URL                                            PRODUCTION PODS URL
go-demo-6   0.0.200 1/1  http://go-demo-6.staging.35.243.161.174.nip.io 0.0.200    1/1  http://go-demo-6.35.243.161.174.nip.io
```

```bash
PROD_ADDR=[...]

curl "$PROD_ADDR/demo/hello"
```

```
hello, PR!
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

git commit -m "Added Ingress"

git push

jx get activity -f go-demo-6 -w

jx get applications
```

```
APPLICATION STAGING PODS URL                                            PRODUCTION PODS URL
go-demo-6   0.0.201 1/1  http://go-demo-6.staging.35.243.161.174.nip.io 0.0.200    1/1  http://go-demo-6.play-with-jx.com
```

```bash
VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    -b

jx get applications

curl "http://$DOMAIN/demo/hello"

# NOTE: There are no certificates
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

rm -rf environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```