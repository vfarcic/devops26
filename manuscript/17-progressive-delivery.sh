# Source: https://gist.github.com/7af19b92299278f9b0f20beba9eba022

# Links to gists for creating a cluster with jx
# gke-jx-serverless-gloo.sh: https://gist.github.com/cf939640f2af583c3a12d04affa67923
# eks-jx-serverless.sh: https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd
# aks-jx-serverless.sh: https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410
# install-serverless.sh: https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037

jx create quickstart \
    --filter golang-http \
    --project-name jx-progressive \
    --batch-mode

cd jx-progressive

cat charts/jx-progressive/templates/ksvc.yaml

jx get activities \
    --filter jx-progressive \
    --watch

jx get activities \
    --filter environment-jx-rocks-staging/master \
    --watch

kubectl --namespace jx-staging \
    get pods

STAGING_ADDR=$(kubectl \
    --namespace jx-staging \
    get ksvc jx-progressive \
    --output jsonpath="{.status.url}")

curl "$STAGING_ADDR"

kubectl \
    --namespace jx-staging \
    get pods

kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
    -it --rm \
    -- --concurrent 300 --time 20S \
    "$STAGING_ADDR" \
    && kubectl \
    --namespace jx-staging \
    get pods

jx edit deploy \
    --kind default \
    --batch-mode

cat charts/jx-progressive/values.yaml \
    | grep knative

cd ..

cd jx-progressive

cat charts/jx-progressive/values.yaml \
    | sed -e \
    's@replicaCount: 1@replicaCount: 3@g' \
    | tee charts/jx-progressive/values.yaml

cat charts/jx-progressive/templates/deployment.yaml \
    | sed -e \
    's@  replicas:@  strategy:\
    type: Recreate\
  replicas:@g' \
    | tee charts/jx-progressive/templates/deployment.yaml

cat charts/jx-progressive/templates/deployment.yaml

git add .

git commit -m "Recreate strategy"

git push --set-upstream origin master

jx get activities \
    --filter jx-progressive/master \
    --watch

jx get activities \
    --filter environment-jx-rocks-staging/master \
    --watch

kubectl --namespace jx-staging \
    get pods

kubectl --namespace jx-staging \
    describe deployment jx-jx-progressive

kubectl --namespace jx-staging \
    get ing

echo "something" | tee README.md

git add .

git commit -m "Recreate strategy"

git push

kubectl --namespace jx-staging \
    get ing

cat main.go | sed -e \
    "s@example@recreate@g" \
    | tee main.go

git add .

git commit -m "Recreate strategy"

git push

export AWS_ACCESS_KEY_ID=[...]

export AWS_SECRET_ACCESS_KEY=[...]

export AWS_DEFAULT_REGION=us-east-1

jx get applications --env staging

STAGING_ADDR=[...]

while true
do
    curl "$STAGING_ADDR"
    sleep 0.2
done

cat charts/jx-progressive/templates/deployment.yaml \
    | sed -e \
    's@type: Recreate@type: RollingUpdate@g' \
    | tee charts/jx-progressive/templates/deployment.yaml

cat main.go | sed -e \
    "s@recreate@rolling update@g" \
    | tee main.go

git add .

git commit -m "Recreate strategy"

git push

while true
do
    curl "$STAGING_ADDR"
    sleep 0.2
done

kubectl --namespace jx-staging \
    describe deployment jx-jx-progressive

jx get applications --env staging

VERSION=[...]

jx promote jx-progressive \
    --version $VERSION \
    --env production \
    --batch-mode

jx get activities \
    --filter environment-jx-rocks-production/master \
    --watch

jx get applications --env production

PRODUCTION_ADDR=[...]

curl "$PRODUCTION_ADDR"

jx create addon istio

# If NOT EKS
ISTIO_IP=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

# If EKS
ISTIO_HOST=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# If EKS
export ISTIO_IP="$(dig +short $ISTIO_HOST \
    | tail -n 1)"

echo $ISTIO_IP

jx create addon flagger

kubectl --namespace istio-system \
    get pods

kubectl describe namespace \
    jx-production

kubectl describe namespace \
    jx-staging

kubectl label namespace jx-staging \
    istio-injection=enabled \
    --overwrite

kubectl describe namespace \
    jx-staging

cat charts/jx-progressive/templates/canary.yaml

cat charts/jx-progressive/values.yaml

cd ..

rm -rf environment-jx-rocks-staging

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-staging.git

cd environment-jx-rocks-staging

STAGING_ADDR=staging.jx-progressive.$ISTIO_IP.nip.io

echo "jx-progressive:
  canary:
    enabled: true
    host: $STAGING_ADDR" \
    | tee -a env/values.yaml

git add .

git commit \
    -m "Added progressive deployment"

git push

cd ../jx-progressive

git add .

git commit \
    -m "Added progressive deployment"

git push

jx get activities \
    --filter jx-progressive/master \
    --watch

jx get activities \
    --filter environment-jx-rocks-staging/master \
    --watch

curl $STAGING_ADDR/demo/hello

kubectl \
    --namespace jx-staging \
    get pods

kubectl --namespace jx-staging \
    get canary

kubectl --namespace jx-staging \
    get virtualservices.networking.istio.io

kubectl \
    --namespace istio-system logs \
    --selector app.kubernetes.io/name=flagger

cat main.go | sed -e \
    "s@rolling update@progressive@g" \
    | tee main.go

git add .

git commit \
    -m "Added progressive deployment"

git push

echo $STAGING_ADDR

STAGING_ADDR=[...]

while true
do
    curl "$STAGING_ADDR"
    sleep 0.2
done

kubectl --namespace jx-staging \
    get pods

kubectl --namespace jx-staging \
    get virtualservice.networking.istio.io \
    jx-jx-progressive \
    --output yaml

kubectl --namespace jx-staging \
    get canary

kubectl --namespace jx-staging \
    describe canary jx-jx-progressive

# If NOT EKS
LB_IP=$(kubectl \
    --namespace kube-system \
    get svc jxing-nginx-ingress-controller \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

# If EKS
LB_HOST=$(kubectl \
    --namespace kube-system \
    get svc jxing-nginx-ingress-controller \
    --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# If EKS
export LB_IP="$(dig +short $LB_HOST \
    | tail -n 1)"

echo $LB_IP

echo "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: flagger-grafana
  namespace: istio-system
spec:
  rules:
  - host: flagger-grafana.$LB_IP.nip.io
    http:
      paths:
      - backend:
          serviceName: flagger-grafana
          servicePort: 80
" | kubectl create -f -

open "http://flagger-grafana.$LB_IP.nip.io"

cd ..

GH_USER=[...]

hub delete -y \
    $GH_USER/environment-jx-rocks-staging

hub delete -y \
    $GH_USER/environment-jx-rocks-production

hub delete -y \
    $GH_USER/jx-progressive

rm -rf environment-jx-rocks-staging

rm -rf $GH_USER/jx-progressive
