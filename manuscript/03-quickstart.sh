# Links to gists for creating a cluster with jx

# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# eks-jx.sh: https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac
# aks-jx.sh: https://gist.github.com/6e01717c398a5d034ebe05b195514060
# jx.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

jx console

jx create quickstart

jx create quickstart \
    --language go \
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

cat Jenkinsfile

open "https://github.com/$GH_USER/jx-go/settings/hooks"

jx console

jx get activities

jx get activities --filter jx-go --watch

jx get build logs

jx get build logs -f jx-go

jx get build logs $GH_USER/jx-go/master

jx get pipelines

jx get applications

jx get env

jx get applications -e staging

jx get applications -e production

open "https://github.com/$GH_USER/jx-go/releases"

ADDR=$(kubectl --namespace jx-staging \
    get ing jx-go \
    -o jsonpath="{.spec.rules[0].host}")

curl "http://$ADDR"

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

hub delete -y $GH_USER/jx-go

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

cd ..

rm -rf jx-go
