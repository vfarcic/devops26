# Links to gists for creating a cluster with jx

# gke-jx-serverless.sh: https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8
# eks-jx-serverless.sh: https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd
# aks-jx-serverless.sh: https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410
# install-serverless.sh: https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037

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
