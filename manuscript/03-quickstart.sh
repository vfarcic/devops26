# Links to gists for creating a cluster with jx

# gke-jx-serverless.sh: https://gist.github.com/a04269d359685bbd00a27643b5474ace)
# eks-jx-serverless.sh: https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
# aks-jx-serverless.sh: https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
# install-serverless.sh: https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

jx create quickstart

jx create quickstart \
    --filter golang-http \
    --project-name jx-go \
    --batch-mode

open "https://github.com/jenkins-x-quickstarts"

ls -1 ~/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs

ls -1 ~/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs/go

GH_USER=[...]

open "https://github.com/$GH_USER/jx-go"

cd jx-go

ls -1

cat Makefile

cat Dockerfile

cat skaffold.yaml

ls -1 charts

ls -1 charts/jx-go

cat jenkins-x.yml

open "https://github.com/$GH_USER/jx-go/settings/hooks"

jx get activities

jx get activities --filter jx-go --watch

jx get build logs

jx get build logs --filter jx-go

jx get build logs \
    --filter $GH_USER/jx-go/master

jx get pipelines

jx get applications

jx get env

jx get applications --env staging

jx get applications --env production

open "https://github.com/$GH_USER/jx-go/releases"

ADDR=$(kubectl --namespace jx-staging \
    get ingress jx-go \
    -o jsonpath="{.spec.rules[0].host}")

curl "http://$ADDR"

cd ..

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

hub delete -y $GH_USER/jx-go

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf jx-go
