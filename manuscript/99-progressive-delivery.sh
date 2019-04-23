# Links to gists for creating a cluster with jx
# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# eks-jx.sh: https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac
# aks-jx.sh: https://gist.github.com/6e01717c398a5d034ebe05b195514060
# install.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

open "https://github.com/vfarcic/go-demo-6"

GH_USER=[...]

git clone \
  https://github.com/$GH_USER/go-demo-6.git

cd go-demo-6

git checkout orig

git merge -s ours master --no-edit

git checkout master

git merge orig

rm -rf charts

git push

jx repo -b

ls -1

# import sets the Jenkinsfile ORG to carlossg, so it breaks because it doesn't match vfarcic
# need to add carlossg to OWNERS and OWNERS_ALIASES
jx import -b

ls -1

jx get activities -f go-demo-6 -w

STAGING_ADDR=[...]

# curl -kL to workaround bad ssl and follow redirect
curl "$STAGING_ADDR/demo/hello"

kubectl -n jx-staging logs \
    -l app=jx-staging-go-demo-6

kubectl -n jx-staging get pods

kubectl -n jx-staging \
    describe pod \
    -l app=jx-staging-go-demo-6

echo "go-demo-6-db:
  replicaSet:
    enabled: true
  usePassword: false
  podAnnotations:
    sidecar.istio.io/inject: \"false\"
" | tee -a charts/go-demo-6/values.yaml

sed '/^canary:/,/^ *[^:]*:/s/enable: false/enable: true/' helm/go-demo-6/values.yaml > helm/go-demo-6/values.yaml.bak
mv helm/go-demo-6/values.yaml.bak helm/go-demo-6/values.yaml

git commit -am "Enable canary deployments"

git push

jx get activities -f go-demo-6 -w

# wait for new version to be built

jx get applications

jx promote go-demo-6 --version 1.0.1 --env production

kubectl -n istio-system logs -f deploy/flagger

watch curl -skL "$STAGING_ADDR/demo/hello"


hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
