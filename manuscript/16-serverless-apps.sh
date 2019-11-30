# Links to gists for creating a Jenkins X cluster
# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# gke-jx-serverless.sh: https://gist.github.com/a04269d359685bbd00a27643b5474ace)

NAMESPACE=$(kubectl config view \
    --minify \
    --output jsonpath="{..namespace}")

cd go-demo-6

git pull

git checkout extension-model-$NAMESPACE

git merge -s ours master --no-edit

git checkout master

git merge extension-model-$NAMESPACE

git push

cd ..

cd go-demo-6

jx import --pack go --batch-mode

cd ..

glooctl install knative \
    --install-knative-version=0.9.0

kubectl get namespaces

jx edit deploy \
    --team \
    --kind default \
    --batch-mode

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
    --filter environment-tekton-staging/master \
    --watch

kubectl \
    --namespace $NAMESPACE-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl \
    --namespace $NAMESPACE-staging \
    describe pod \
    --selector serving.knative.dev/service=jx-knative

kubectl \
    --namespace $NAMESPACE-staging \
    get all

jx get applications --env staging

ADDR=$(kubectl \
    --namespace $NAMESPACE-staging \
    get ksvc jx-knative \
    --output jsonpath="{.status.domain}")

echo $ADDR

curl "$ADDR"

kubectl \
    --namespace $NAMESPACE-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl --namespace cd-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl --namespace knative-serving \
    describe configmap config-autoscaler

kubectl \
    --namespace $NAMESPACE-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- --concurrent 300 --time 20S \
     "$ADDR" \
     && kubectl \
     --namespace $NAMESPACE-staging \
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

git push

jx get activities \
    --filter jx-knative \
    --watch

jx get activities \
    --filter environment-tekton-staging/master \
    --watch

curl "http://$ADDR/"

kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- --concurrent 400 --time 60S \
     "$ADDR" \
     && kubectl \
     --namespace $NAMESPACE-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl \
    --namespace $NAMESPACE-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl \
    --namespace $NAMESPACE-staging \
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
    --filter environment-tekton-staging/master \
    --watch

kubectl \
    --namespace $NAMESPACE-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

kubectl \
    --namespace $NAMESPACE-staging \
    get pods \
    --selector serving.knative.dev/service=jx-knative

cd ../go-demo-6

git checkout -b serverless

ls -1 charts/go-demo-6/templates

echo "knativeDeploy: false" \
    | tee -a charts/go-demo-6/values.yaml

echo "{{- if .Values.knativeDeploy }}
{{- else }}
$(cat charts/go-demo-6/templates/deployment.yaml)
{{- end }}" \
    | tee charts/go-demo-6/templates/deployment.yaml

echo "{{- if .Values.knativeDeploy }}
{{- else }}
$(cat charts/go-demo-6/templates/service.yaml)
{{- end }}" \
    | tee charts/go-demo-6/templates/service.yaml

echo '{{- if .Values.knativeDeploy }}
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
{{- if .Values.service.name }}
  name: {{ .Values.service.name }}
{{- else }}
  name: {{ template "fullname" . }}
{{- end }}
  labels:
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
            imagePullPolicy: {{ .Values.image.pullPolicy }}
            env:
            - name: DB
              value: {{ template "fullname" . }}-db
            livenessProbe:
              httpGet:
                path: {{ .Values.probePath }}
              initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
              periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
              successThreshold: {{ .Values.livenessProbe.successThreshold }}
              timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
            readinessProbe:
              httpGet:
                path: {{ .Values.probePath }}
              periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
              successThreshold: {{ .Values.readinessProbe.successThreshold }}
              timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
            resources:
{{ toYaml .Values.resources | indent 14 }}
{{- end }}' \
    | tee charts/go-demo-6/templates/ksvc.yaml

jx edit deploy knative

cat charts/go-demo-6/values.yaml \
    | grep knative

cat charts/go-demo-6/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/go-demo-6/Makefile

cat charts/preview/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/preview/Makefile

cat skaffold.yaml \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee skaffold.yaml

cat jenkins-x.yml \
  | sed '$ d' \
  | tee jenkins-x.yml

curl -o Jenkinsfile \
    https://gist.githubusercontent.com/vfarcic/56c986a29e0753076e08163a7c6a2051/raw/a8be26f33c877c0927e833b015c5620d150712d6/Jenkinsfile

git add .

git commit -m "Added Knative"

git push \
    --set-upstream origin serverless

jx create pullrequest \
    --title "Serverless with Knative" \
    --body "What I can say?" \
    --batch-mode

BRANCH=[...] # e.g., `PR-109`

jx get activities \
    --filter go-demo-6/$BRANCH \
    --watch

GH_USER=[...]

PR_NAMESPACE=$(\
  echo $NAMESPACE-$GH_USER-go-demo-6-$BRANCH \
  | tr '[:upper:]' '[:lower:]')

echo $PR_NAMESPACE

kubectl --namespace $PR_NAMESPACE \
    get pods

PR_ADDR=$(kubectl \
    --namespace $PR_NAMESPACE \
    get ksvc go-demo-6 \
    --output jsonpath="{.status.domain}")

echo $PR_ADDR

curl "$PR_ADDR/demo/hello"

kubectl --namespace cd-staging get pods

jx repo

git checkout master

git branch -d serverless

git pull

jx get activities \
    --filter go-demo-6/master \
    --watch

jx get activities \
    --filter environment-tekton-staging/master \
    --watch

kubectl \
    --namespace $NAMESPACE-staging \
    get pods

ADDR=$(kubectl \
    --namespace $NAMESPACE-staging \
    get ksvc go-demo-6 \
    --output jsonpath="{.status.domain}")

echo $ADDR

curl "$ADDR/demo/hello"

# If serverless Jenkins X
STAGING_ENV=environment-tekton-staging

# If static Jenkins X
STAGING_ENV=environment-jx-rocks-staging

cd ..

rm -rf $STAGING_ENV

git clone https://github.com/$GH_USER/$STAGING_ENV.git

cd $STAGING_ENV

echo "go-demo-6:
  knativeDeploy: false" \
    | tee -a env/values.yaml

git add .

git commit -m "Removed Knative"

git pull

git push

cd ../go-demo-6

echo "go-demo-6 rocks" \
    | tee README.md

git add .

git commit -m "Removed Knative"

git pull

git push

jx get activities \
    --filter go-demo-6/master \
    --watch

jx get activities \
    --filter environment-tekton-staging/master \
    --watch

kubectl \
    --namespace $NAMESPACE-staging \
    get pods

ADDR=$(kubectl \
    --namespace $NAMESPACE-staging \
    get ing go-demo-6 \
    --output jsonpath="{.spec.rules[0].host}")

echo $ADDR

curl "$ADDR/demo/hello"

cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/$STAGING_ENV

hub delete -y \
  $GH_USER/jx-knative

# If serverless
rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*

# If static
rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf jx-knative

rm -rf $STAGING_ENV
