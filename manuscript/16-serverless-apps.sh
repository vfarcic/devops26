# Links to gists for creating a Jenkins X cluster
# gke-jx-serverless.sh: https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8

glooctl install knative \
    --install-knative-version=0.9.0

KNATIVE_IP=$(kubectl \
    --namespace gloo-system \
    get service knative-external-proxy \
    --output jsonpath="{.status.loadBalancer.ingress[0].ip}")

KNATIVE_HOST=$(kubectl \
    --namespace gloo-system \
    get service knative-external-proxy \
    --output jsonpath="{.status.loadBalancer.ingress[0].hostname}")

export KNATIVE_IP="$(dig +short $KNATIVE_HOST \
    | tail -n 1)"

echo $KNATIVE_IP

echo "apiVersion: v1
kind: ConfigMap
metadata:
  name: config-domain
  namespace: knative-serving
data:
  $KNATIVE_IP.nip.io: \"\"" \
    | kubectl apply --filename -

kubectl get namespaces

jx edit deploy \
    --team \
    --kind knative \
    --batch-mode

jx create quickstart \
    --filter golang-http \
    --project-name jx-knative \
    --batch-mode

cd jx-knative

cat charts/jx-knative/values.yaml

ls -1 charts/jx-knative/templates

cat charts/jx-knative/templates/deployment.yaml

cat charts/jx-knative/templates/ksvc.yaml

jx get activities \
    --filter jx-knative \
    --watch

jx get activities \
    --filter environment-jx-rocks-staging/master \
    --watch

kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl \
    --namespace jx-staging \
    describe pod \
    --selector serving.knative.dev/service=jx-knative

kubectl \
    --namespace jx-staging \
    get all

jx get applications --env staging

ADDR=$(kubectl \
    --namespace jx-staging \
    get ksvc jx-knative \
    --output jsonpath="{.status.url}")

echo $ADDR

curl "$ADDR"

kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl --namespace knative-serving \
    describe configmap config-autoscaler

kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- --concurrent 300 --time 20S \
     "$ADDR" \
     && kubectl \
     --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

cat charts/jx-knative/templates/ksvc.yaml \
    | sed -e \
    's@revisionTemplate:@revisionTemplate:\
        metadata:\
          annotations:\
            autoscaling.knative.dev/target: "3"\
            autoscaling.knative.dev/maxScale: "5"@g' \
    | tee charts/jx-knative/templates/ksvc.yaml

git add .

git commit -m "Added Knative target"

git push --set-upstream origin master

jx get activities \
    --filter jx-knative \
    --watch

jx get activities \
    --filter environment-jx-rocks-staging/master \
    --watch

curl "$ADDR/"

kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- --concurrent 400 --time 60S \
     "$ADDR" \
     && kubectl \
     --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

cat charts/jx-knative/templates/ksvc.yaml \
    | sed -e \
    's@autoscaling.knative.dev/target: "3"@autoscaling.knative.dev/target: "3"\
            autoscaling.knative.dev/minScale: "1"@g' \
    | tee charts/jx-knative/templates/ksvc.yaml

git add .

git commit -m "Added Knative minScale"

git push

jx get activities \
    --filter jx-knative \
    --watch

jx get activities \
    --filter environment-jx-rocks-staging/master \
    --watch

kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl \
    --namespace jx-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

git checkout -b serverless

echo "A silly change" | tee README.md

git add .

git commit -m "Made a silly change"

git push --set-upstream origin serverless

jx create pullrequest \
    --title "A silly change" \
    --body "What I can say?" \
    --batch-mode

BRANCH=[...] # e.g., `PR-1`

jx get activities \
    --filter jx-knative/$BRANCH \
    --watch

GH_USER=[...]

PR_NAMESPACE=$(\
  echo jx-$GH_USER-jx-knative-$BRANCH \
  | tr '[:upper:]' '[:lower:]')

echo $PR_NAMESPACE

kubectl --namespace $PR_NAMESPACE \
    get pods

PR_ADDR=$(kubectl \
    --namespace $PR_NAMESPACE \
    get ksvc jx-knative \
    --output jsonpath="{.status.url}")

echo $PR_ADDR

curl "$PR_ADDR"

cd ..

rm -rf environment-jx-rocks-staging

git clone https://github.com/$GH_USER/environment-jx-rocks-staging.git

cd environment-jx-rocks-staging

echo "jx-knative:
  knativeDeploy: false" \
    | tee -a env/values.yaml

git add .

git commit -m "Removed Knative"

git pull

git push

cd ../jx-knative

git checkout master

echo "jx-knative rocks" \
    | tee README.md

git add .

git commit -m "Removed Knative"

git pull

git push

jx get activities \
    --filter jx-knative/master \
    --watch

jx get activities \
    --filter environment-jx-rocks-staging/master \
    --watch

kubectl \
    --namespace jx-staging \
    get pods

kubectl \
    --namespace jx-staging \
    get all \
    | grep jx-knative

ADDR=$(kubectl \
    --namespace jx-staging \
    get ing jx-knative \
    --output jsonpath="{.spec.rules[0].host}")

echo $ADDR

curl "http://$ADDR"

cd ..

GH_USER=[...]

hub delete -y $GH_USER/environment-jx-rocks-staging

hub delete -y $GH_USER/environment-jx-rocks-production

hub delete -y $GH_USER/jx-knative

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf jx-knative

rm -rf environment-jx-rocks-staging
