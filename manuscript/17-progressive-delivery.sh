# Links to gists for creating a Jenkins X cluster
# gke-jx-gloo.sh: https://gist.github.com/dfaaca2e89676ee1848d2b4499c63709)
# gke-jx-serverless-gloo.sh: https://gist.github.com/72b77eb4846eac10a91ca139274bd06c)
# eks-jx-gloo.sh: https://gist.github.com/97184bedebfdc91628b87da7c0f07d43)
# eks-jx-serverless-gloo.sh: https://gist.github.com/3fc23136cb76ff5518ae27c47308d28a)
# aks-jx-gloo.sh: https://gist.github.com/378193008889f5c71f00b7df005cf4eb)
# aks-jx-serverless-gloo.sh: https://gist.github.com/1164ac0b9a16f07905afcf98725ae103)
# install.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
# install-serverless.sh: https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

NAMESPACE=$(kubectl config view \
    --minify \
    --output jsonpath="{..namespace}")

cd go-demo-6

git pull

# If GKE
BRANCH=knative-$NAMESPACE

# If NOT GKE
BRANCH=extension-model-$NAMESPACE

git checkout $BRANCH

git merge -s ours master --no-edit

git checkout master

git merge $BRANCH

git push

cd ..

# If GKE
cd go-demo-6

# If GKE
cat charts/go-demo-6/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/go-demo-6/Makefile

# If GKE
cat charts/preview/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/preview/Makefile

# If GKE
cat skaffold.yaml \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee skaffold.yaml

# If GKE
git add .

# If GKE
git commit -m "Fixed the project"

# If GKE
git push

# If GKE
cd ..

cd go-demo-6

jx import --pack go --batch-mode

cd ..

# If GKE
cd go-demo-6

# If GKE
cat charts/go-demo-6/templates/ksvc.yaml

# If GKE
jx get activities \
    --filter go-demo-6 \
    --watch

# If GKE and serverless Jenkins X
jx get activities \
    --filter environment-tekton-staging/master \
    --watch

# If GKE
kubectl \
    --namespace $NAMESPACE-staging \
    get pods

# If GKE
STAGING_ADDR=$(kubectl \
    --namespace $NAMESPACE-staging \
    get ksvc go-demo-6 \
    --output jsonpath="{.status.domain}")

# If GKE
curl "http://$STAGING_ADDR/demo/hello"

# If GKE
kubectl \
    --namespace $NAMESPACE-staging \
    get pods

# If GKE
kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- --concurrent 300 --time 20S \
     "$STAGING_ADDR/demo/hello" \
     && kubectl \
     --namespace $NAMESPACE-staging \
    get pods

# If GKE
jx edit deploy \
    --kind default \
    --batch-mode

# If GKE
cat charts/go-demo-6/values.yaml \
    | grep knative

# If GKE
cd ..

cd go-demo-6

cat charts/go-demo-6/templates/deployment.yaml \
    | sed -e \
    's@  replicas:@  strategy:\
    type: Recreate\
  replicas:@g' \
    | tee charts/go-demo-6/templates/deployment.yaml

cat charts/go-demo-6/templates/deployment.yaml

git add .

git commit -m "Recreate strategy"

git push

jx get activities \
    --filter go-demo-6/master \
    --watch

# If serverless Jenkins X
jx get activities \
    --filter environment-tekton-staging/master \
    --watch

kubectl \
    --namespace $NAMESPACE-staging \
    get pods

kubectl \
    --namespace $NAMESPACE-staging \
    describe deployment jx-go-demo-6

kubectl \
    --namespace $NAMESPACE-staging \
    get ing

echo "something" | tee README.md

git add .

git commit -m "Recreate strategy"

git push

kubectl \
    --namespace $NAMESPACE-staging \
    get ing

cat main.go | sed -e \
    "s@hello, PR@hello, recreate@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@hello, PR@hello, recreate@g" \
    | tee main_test.go

git add .

git commit -m "Recreate strategy"

git push

# Open a second terminal window.

# If EKS
export AWS_ACCESS_KEY_ID=[...]

# If EKS
export AWS_SECRET_ACCESS_KEY=[...]

# If EKS
export AWS_DEFAULT_REGION=us-east-1

jx get applications --env staging

STAGING_ADDR=[...]

while true
do
    curl "$STAGING_ADDR/demo/hello"
    sleep 0.2
done

# Go to the first terminal

cat charts/go-demo-6/templates/deployment.yaml \
    | sed -e \
    's@type: Recreate@type: RollingUpdate@g' \
    | tee charts/go-demo-6/templates/deployment.yaml

cat main.go | sed -e \
    "s@hello, recreate@hello, rolling update@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@hello, recreate@hello, rolling update@g" \
    | tee main_test.go

git add .

git commit -m "Recreate strategy"

git push

# Go to the second terminal

while true
do
    curl "$STAGING_ADDR/demo/hello"
    sleep 0.2
done

# Go to the first terminal

kubectl \
    --namespace $NAMESPACE-staging \
    describe deployment jx-go-demo-6

jx get applications --env staging

VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode

# If serverless Jenkins X
jx get activities \
    --filter environment-tekton-production/master \
    --watch

jx get applications --env production

PRODUCTION_ADDR=[...]

curl "$PRODUCTION_ADDR/demo/hello"

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
    $NAMESPACE-production

kubectl describe namespace \
    $NAMESPACE-staging

kubectl label namespace \
    $NAMESPACE-staging \
    istio-injection=enabled \
    --overwrite

kubectl describe namespace \
    $NAMESPACE-staging

echo "{{- if .Values.canary.enable }}
apiVersion: flagger.app/v1alpha2
kind: Canary
metadata:
  name: {{ template \"fullname\" . }}
spec:
  provider: {{.Values.canary.provider}}
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ template \"fullname\" . }}
  progressDeadlineSeconds: 60
  service:
    port: {{.Values.service.internalPort}}
{{- if .Values.canary.service.gateways }}
    gateways:
{{ toYaml .Values.canary.service.gateways | indent 4 }}
{{- end }}
{{- if .Values.canary.service.hosts }}
    hosts:
{{ toYaml .Values.canary.service.hosts | indent 4 }}
{{- end }}
  canaryAnalysis:
    interval: {{ .Values.canary.canaryAnalysis.interval }}
    threshold: {{ .Values.canary.canaryAnalysis.threshold }}
    maxWeight: {{ .Values.canary.canaryAnalysis.maxWeight }}
    stepWeight: {{ .Values.canary.canaryAnalysis.stepWeight }}
{{- if .Values.canary.canaryAnalysis.metrics }}
    metrics:
{{ toYaml .Values.canary.canaryAnalysis.metrics | indent 4 }}
{{- end }}
{{- end }}
" | tee charts/go-demo-6/templates/canary.yaml

echo "
canary:
  enable: false
  provider: istio
  service:
    hosts:
    - go-demo-6.$ISTIO_IP.nip.io
    gateways:
    - jx-gateway.istio-system.svc.cluster.local
  canaryAnalysis:
    interval: 30s
    threshold: 5
    maxWeight: 70
    stepWeight: 20
    metrics:
    - name: request-success-rate
      threshold: 99
      interval: 120s
    - name: request-duration
      threshold: 500
      interval: 120s
" | tee -a charts/go-demo-6/values.yaml

cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@go-demo-6-db:@go-demo-6-db:\
  podAnnotations:\
    sidecar.istio.io/inject: "false"@g' \
    | tee charts/go-demo-6/values.yaml

cd ..

# If static Jenkins X
ENVIRONMENT=jx-rocks

# If serverless Jenkins X
ENVIRONMENT=tekton

rm -rf environment-$ENVIRONMENT-staging

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-$ENVIRONMENT-staging.git

cd environment-$ENVIRONMENT-staging

STAGING_ADDR=staging.go-demo-6.$ISTIO_IP.nip.io

echo "go-demo-6:
  canary:
    enable: true
    service:
      hosts:
      - $STAGING_ADDR" \
    | tee -a env/values.yaml

git add .

git commit \
    -m "Added progressive deployment"

git push

cd ../go-demo-6

git add .

git commit \
    -m "Added progressive deployment"

git push

jx get activities \
    --filter go-demo-6/master \
    --watch

# If serverless Jenkins X
jx get activities \
    --filter environment-tekton-staging/master \
    --watch

curl $STAGING_ADDR/demo/hello

kubectl \
    --namespace $NAMESPACE-staging \
    get pods

kubectl \
    --namespace $NAMESPACE-staging \
    get canary

kubectl \
    --namespace $NAMESPACE-staging \
    get virtualservice.networking.istio.io

kubectl \
    --namespace istio-system logs \
    --selector app.kubernetes.io/name=flagger

cat main.go | sed -e \
    "s@hello, rolling update@hello, progressive@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@hello, rolling update@hello, progressive@g" \
    | tee main_test.go

git add .

git commit \
    -m "Added progressive deployment"

git push

echo $STAGING_ADDR

# Go to the second terminal

STAGING_ADDR=[...]

while true
do
    curl "$STAGING_ADDR/demo/hello"
    sleep 0.2
done

# Go to the first terminal

kubectl \
    --namespace $NAMESPACE-staging \
    get pods

kubectl \
    --namespace $NAMESPACE-staging \
    get virtualservice.networking.istio.io \
    jx-go-demo-6 \
    --output yaml

kubectl -n $NAMESPACE-staging \
    get canary

kubectl \
    --namespace $NAMESPACE-staging \
    describe canary jx-go-demo-6

cat main.go | sed -e \
    "s@Everything is still OK@Everything is still OK with progressive delivery@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@Everything is still OK@Everything is still OK with progressive delivery@g" \
    | tee main_test.go

git add .

git commit \
    -m "Added progressive deployment"

git push

# Go to the second terminal

while true
do
    curl "$STAGING_ADDR/demo/random-error"
    sleep 0.2
done

# Go to the first terminal

kubectl \
    --namespace $NAMESPACE-staging \
    describe canary jx-go-demo-6

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

# If serverless
ENVIRONMENT=tekton

# If static
ENVIRONMENT=jx-rocks

hub delete -y \
    $GH_USER/environment-$ENVIRONMENT-staging

hub delete -y \
    $GH_USER/environment-$ENVIRONMENT-production

rm -rf ~/.jx/environments/$GH_USER/environment-$ENVIRONMENT-*

rm -rf environment-$ENVIRONMENT-staging
