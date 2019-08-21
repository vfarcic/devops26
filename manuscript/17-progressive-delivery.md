## TODO

- [X] Code
- [ ] Write
- [X] Code review static GKE
- [X] Code review serverless GKE
- [ ] Code review static EKS
- [ ] Code review serverless EKS
- [X] Code review static AKS
- [X] Code review serverless AKS
- [ ] Code review existing static cluster
- [ ] Code review existing serverless cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Choosing The Right Deployment Strategy



## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

TODO: Viktor: This text is from some other change. Rewrite it.

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [TODO: Viktor](TODO: Viktor) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

NOTE: istio-telemetry requires 2 CPUs
NOTE: Add a note that the Gists are different (added `gloo` to GKE, VM sizes increased in all)

* Create a new static **GKE** cluster: [gke-jx-gloo.sh](TODO:)
* Create a new serverless **GKE** cluster: [gke-jx-serverless-gloo.sh](TODO:)
* Create a new static **EKS** cluster: [eks-jx-gloo.sh](TODO:)
* Create a new serverless **EKS** cluster: [eks-jx-serverless-gloo.sh](TODO:)
* Create a new static **AKS** cluster: [aks-jx-gloo.sh](TODO:)
* Create a new serverless **AKS** cluster: [aks-jx-serverless-gloo.sh](TODO:)
* Use an **existing** static cluster: [install.sh](TODO:)
* Use an **existing** serverless cluster: [install-serverless.sh](TODO:)

TODO: Viktor: Check whether `extension-model` or some other branch should be restored

I> The commands that follow will reset your *go-demo-6* `master` branch with the contents of the branch that contain all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

W> Depending on whether you're using static or serverless Jenkins X flavor, we'll need to restore one branch or the other. The commands that follow will restore `extension-model-jx` if you are using static Jenkins X, or `extension-model-cd` if you prefer the serverless flavor.

```bash
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
```

W> Please execute the commands that follow only if you are using **GKE** and if you restored the branch using the commands above.

```bash
cd go-demo-6

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

git add .

git commit -m "Fixed the project"

git push

cd ..
```

There isn't much mystery in the commands we executed. They replaced `vfarcic` with the name of your Google project in two Makefile files and in `skaffold.yaml`.

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
cd go-demo-6

jx import --pack go --batch-mode

jx get activities \
    --filter go-demo-6 \
    --watch

# Wait until it is finished and press *ctrl+c* to exit the watcher

cd ..
```

## Serverless (GKE only)

W> At the time of this writing (August 2019), the examples in this section work only in a **GKE** cluster. Feel free to monitor [the issue 4668](https://github.com/jenkins-x/jx/issues/4668) for more info.

```bash
cd go-demo-6

cat charts/go-demo-6/templates/ksvc.yaml
```

```yaml
{{- if .Values.knativeDeploy }}
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
{{- end }}
```

```bash
jx get activities \
    --filter go-demo-6 \
    --watch

# Press *ctrl+c* when the activity is finished.

# If serverless
jx get activities \
    --filter environment-tekton-staging/master \
    --watch

# Press *ctrl+c* when the activity is finished

kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

```
NAME                                          READY   STATUS              RESTARTS   AGE
go-demo-6-lbxwr-deployment-6688f7c956-xzjk5   2/2     Running             0          26s
jx-go-demo-6-db-arbiter-0                     1/1     Running             0          27s
jx-go-demo-6-db-primary-0                     1/1     Running             0          27s
jx-go-demo-6-db-secondary-0                   1/1     Running             0          27s
```

```bash
# NOTE: Wait until all the containers are running

STAGING_ADDR=$(kubectl \
    --namespace $NAMESPACE-staging \
    get ksvc go-demo-6 \
    --output jsonpath="{.status.domain}")

echo $STAGING_ADDR
```

```
go-demo-6.cd-staging.35.231.84.74.nip.io
```

```bash
curl "http://$STAGING_ADDR/demo/hello"
```

```
hello, PR!
```

```bash
# Wait for a while (5-10 min.)

kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

```
NAME                          READY   STATUS    RESTARTS   AGE
jx-go-demo-6-db-arbiter-0     1/1     Running   0          6m21s
jx-go-demo-6-db-primary-0     1/1     Running   0          6m21s
jx-go-demo-6-db-secondary-0   1/1     Running   0          6m21s
```

```bash
kubectl run siege \
    --image yokogawa/siege \
    --generator "run-pod/v1" \
     -it --rm \
     -- --concurrent 300 --time 20S \
     "http://$STAGING_ADDR/demo/hello" \
     && kubectl \
     --namespace $NAMESPACE-staging \
    get pods
```

```
NAME                                          READY   STATUS    RESTARTS   AGE
go-demo-6-lbxwr-deployment-6688f7c956-j9r8h   2/2     Running   0          20s
go-demo-6-lbxwr-deployment-6688f7c956-js29z   2/2     Running   0          14s
go-demo-6-lbxwr-deployment-6688f7c956-kt9ns   2/2     Running   0          14s
jx-go-demo-6-db-arbiter-0                     1/1     Running   0          6m59s
jx-go-demo-6-db-primary-0                     1/1     Running   0          6m59s
jx-go-demo-6-db-secondary-0                   1/1     Running   0          6m59s
```

```bash
cd ..
```

## Recreate

```bash
cd go-demo-6

jx edit deploy \
    --kind default \
    --batch-mode
```

```
modified the helm file: /Users/vfarcic/code/go-demo-6/charts/go-demo-6/values.yaml
```

```bash
cat charts/go-demo-6/values.yaml \
    | grep knative
```

```
knativeDeploy: false
```

```bash
# If the output is empty, the chart was created before Knative was introduced to build packs.

cat charts/go-demo-6/templates/deployment.yaml \
    | sed -e \
    's@  replicas:@  strategy:\
    type: Recreate\
  replicas:@g' \
    | tee charts/go-demo-6/templates/deployment.yaml

cat charts/go-demo-6/templates/deployment.yaml
```

```yaml
{{- if .Values.knativeDeploy }}
{{- else }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "fullname" . }}
  labels:
    draft: {{ default "draft-app" .Values.draft }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
spec:
  strategy:
    type: Recreate
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        draft: {{ default "draft-app" .Values.draft }}
        app: {{ template "fullname" . }}
{{- if .Values.podAnnotations }}
      annotations:
{{ toYaml .Values.podAnnotations | indent 8 }}
{{- end }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        env:
        - name: DB
          value: {{ template "fullname" . }}-db
        ports:
        - containerPort: {{ .Values.service.internalPort }}
        livenessProbe:
          httpGet:
            path: {{ .Values.probePath }}
            port: {{ .Values.service.internalPort }}
          initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
          periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
          successThreshold: {{ .Values.livenessProbe.successThreshold }}
          timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
        readinessProbe:
          httpGet:
            path: {{ .Values.probePath }}
            port: {{ .Values.service.internalPort }}
          periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
          successThreshold: {{ .Values.readinessProbe.successThreshold }}
          timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
        resources:
{{ toYaml .Values.resources | indent 12 }}
      terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
{{- end }}
```

```bash
git add .

git commit -m "Recreate strategy"

git push

jx get activities \
    --filter go-demo-6 \
    --watch

# Press *ctrl+c* when the activity is finished

# If serverless
jx get activities \
    --filter environment-tekton-staging/master \
    --watch

# Press *ctrl+c* when the activity is finished

kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

```
NAME                                          READY   STATUS        RESTARTS   AGE
jx-go-demo-6-94b4bb9b6-bs2bc                  1/1     Running       0          36s
jx-go-demo-6-94b4bb9b6-c5pg7                  1/1     Running       0          36s
jx-go-demo-6-94b4bb9b6-czd56                  1/1     Running       0          36s
jx-go-demo-6-db-arbiter-0                     1/1     Running       0          15m
jx-go-demo-6-db-primary-0                     1/1     Running       0          15m
jx-go-demo-6-db-secondary-0                   1/1     Running       0          15m
```

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    describe deployment jx-go-demo-6
```

```yaml
Name:               jx-go-demo-6
Namespace:          cd-staging
CreationTimestamp:  Fri, 16 Aug 2019 14:35:19 -0700
Labels:             chart=go-demo-6-9.0.29
                    draft=draft-app
                    jenkins.io/chart-release=jx
                    jenkins.io/namespace=cd-staging
                    jenkins.io/version=2
Annotations:        deployment.kubernetes.io/revision: 1
                    jenkins.io/chart: env
                    kubectl.kubernetes.io/last-applied-configuration:
                      {"apiVersion":"extensions/v1beta1","kind":"Deployment","metadata":{"annotations":{"jenkins.io/chart":"env"},"labels":{"chart":"go-demo-6-9...
Selector:           app=jx-go-demo-6,draft=draft-app
Replicas:           3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:       Recreate
MinReadySeconds:    0
Pod Template:
  Labels:  app=jx-go-demo-6
           draft=draft-app
  Containers:
   go-demo-6:
    Image:      gcr.io/devops-26/go-demo-6:9.0.29
    Port:       8080/TCP
    Host Port:  0/TCP
    Limits:
      cpu:     100m
      memory:  256Mi
    Requests:
      cpu:      80m
      memory:   128Mi
    Liveness:   http-get http://:8080/demo/hello%3Fhealth=true delay=60s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get http://:8080/demo/hello%3Fhealth=true delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:
      DB:    jx-go-demo-6-db
    Mounts:  <none>
  Volumes:   <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   jx-go-demo-6-94b4bb9b6 (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  13m   deployment-controller  Scaled up replica set jx-go-demo-6-57b5b5bf78 to 3
  Normal  ScalingReplicaSet  31s   deployment-controller  Scaled down replica set jx-go-demo-6-57b5b5bf78 to 0
  Normal  ScalingReplicaSet  20s   deployment-controller  Scaled up replica set jx-go-demo-6-589c47878f to 3
```

```bash
# If Knative before
kubectl \
    --namespace $NAMESPACE-staging \
    get ing
```

```
No resources found.
```

```bash
# If Knative before
# The first deployment after switching away from knative does not create a Ingress resources.

# If Knative before
echo "something" | tee README.md

# If Knative before
git add .

# If Knative before
git commit -m "Recreate strategy"

# If Knative before
git push

# If Knative before
jx get activities \
    --filter go-demo-6 \
    --watch

# Press *ctrl+c* when the activity is finished

# If Knative before
jx get activities \
    --filter environment-$ENVIRONMENT-staging/master \
    --watch

# Press *ctrl+c* when the activity is finished

# If Knative before
kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

```
NAME                                          READY   STATUS        RESTARTS   AGE
jx-go-demo-6-8b5698864-hhvqh                  1/1     Running       0          12s
jx-go-demo-6-8b5698864-jw6sp                  1/1     Running       0          12s
jx-go-demo-6-8b5698864-kv6w7                  1/1     Running       0          12s
jx-go-demo-6-db-arbiter-0                     1/1     Running       0          20m
jx-go-demo-6-db-primary-0                     1/1     Running       0          20m
jx-go-demo-6-db-secondary-0                   1/1     Running       0          20m
```

```bash
# If Knative before
kubectl \
    --namespace $NAMESPACE-staging \
    get ing
```

```
NAME        HOSTS                                        ADDRESS          PORTS   AGE
go-demo-6   go-demo-6.cd-staging.35.237.194.237.nip.io   35.237.194.237   80      61s
```

```bash
cat main.go | sed -e \
    "s@hello, PR@hello, recreate@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@hello, PR@hello, recreate@g" \
    | tee main_test.go

git add .

git commit -m "Recreate strategy"

git push

# Open a second terminal

# If EKS
export AWS_ACCESS_KEY_ID=[...] # Replace [...] with the AWS Access Key ID

# If EKS
export AWS_SECRET_ACCESS_KEY=[...] # Replace [...] with the AWS Secret Access Key

# If EKS
export AWS_DEFAULT_REGION=us-west-2

jx get applications --env staging
```

```
APPLICATION STAGING PODS URL
go-demo-6   9.0.30  3/3  http://go-demo-6.cd-staging.35.237.194.237.nip.io
```

```bash
STAGING_ADDR=[...]

while true
do
    curl "$STAGING_ADDR/demo/hello"
    sleep 0.2
done
```

```
...
hello, PR!
hello, PR!
...
<html>
<head><title>502 Bad Gateway</title></head>
<body>
<center><h1>502 Bad Gateway</h1></center>
<hr><center>openresty/1.15.8.1</center>
</body>
</html>
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>openresty/1.15.8.1</center>
</body>
</html>
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>openresty/1.15.8.1</center>
</body>
</html>
...
hello, recreate!
hello, recreate!
...
```

```bash
# Press *ctrl+c* to stop the loop

# Back to the first terminal
```

## Rolling Updates

```bash
cat charts/go-demo-6/templates/deployment.yaml \
    | sed -e \
    's@type: Recreate@type: RollingUpdate@g' \
    | tee charts/go-demo-6/templates/deployment.yaml
```

```yaml
{{- if .Values.knativeDeploy }}
{{- else }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "fullname" . }}
  labels:
    draft: {{ default "draft-app" .Values.draft }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
spec:
  strategy:
    type: RollingUpdate
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        draft: {{ default "draft-app" .Values.draft }}
        app: {{ template "fullname" . }}
{{- if .Values.podAnnotations }}
      annotations:
{{ toYaml .Values.podAnnotations | indent 8 }}
{{- end }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        env:
        - name: DB
          value: {{ template "fullname" . }}-db
        ports:
        - containerPort: {{ .Values.service.internalPort }}
        livenessProbe:
          httpGet:
            path: {{ .Values.probePath }}
            port: {{ .Values.service.internalPort }}
          initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
          periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
          successThreshold: {{ .Values.livenessProbe.successThreshold }}
          timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
        readinessProbe:
          httpGet:
            path: {{ .Values.probePath }}
            port: {{ .Values.service.internalPort }}
          periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
          successThreshold: {{ .Values.readinessProbe.successThreshold }}
          timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
        resources:
{{ toYaml .Values.resources | indent 12 }}
      terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
{{- end }}
```

```bash
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
```

```
...
hello, recreate!
hello, recreate!
hello, rolling update!
hello, rolling update!
...
```

```bash
# Press *ctrl+c* to stop the loop

# NOTE: It could result in mixed responses from two releases

# Back to the first terminal

kubectl \
    --namespace $NAMESPACE-staging \
    describe deployment jx-go-demo-6
```

```
Name:                   jx-go-demo-6
Namespace:              cd-staging
CreationTimestamp:      Fri, 16 Aug 2019 14:35:19 -0700
Labels:                 chart=go-demo-6-9.0.32
                        draft=draft-app
                        jenkins.io/chart-release=jx
                        jenkins.io/namespace=cd-staging
                        jenkins.io/version=5
Annotations:            deployment.kubernetes.io/revision: 4
                        jenkins.io/chart: env
                        kubectl.kubernetes.io/last-applied-configuration:
                          {"apiVersion":"extensions/v1beta1","kind":"Deployment","metadata":{"annotations":{"jenkins.io/chart":"env"},"labels":{"chart":"go-demo-6-9...
Selector:               app=jx-go-demo-6,draft=draft-app
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:  app=jx-go-demo-6
           draft=draft-app
  Containers:
   go-demo-6:
    Image:      gcr.io/devops-26/go-demo-6:9.0.32
    Port:       8080/TCP
    Host Port:  0/TCP
    Limits:
      cpu:     100m
      memory:  256Mi
    Requests:
      cpu:      80m
      memory:   128Mi
    Liveness:   http-get http://:8080/demo/hello%3Fhealth=true delay=60s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get http://:8080/demo/hello%3Fhealth=true delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:
      DB:    jx-go-demo-6-db
    Mounts:  <none>
  Volumes:   <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   jx-go-demo-6-658f88478b (3/3 replicas created)
Events:
  Type    Reason             Age                From                   Message
  ----    ------             ----               ----                   -------
  Normal  ScalingReplicaSet  15m                deployment-controller  Scaled up replica set jx-go-demo-6-94b4bb9b6 to 3
  Normal  ScalingReplicaSet  10m                deployment-controller  Scaled down replica set jx-go-demo-6-94b4bb9b6 to 0
  Normal  ScalingReplicaSet  10m                deployment-controller  Scaled up replica set jx-go-demo-6-8b5698864 to 3
  Normal  ScalingReplicaSet  6m24s              deployment-controller  Scaled down replica set jx-go-demo-6-8b5698864 to 0
  Normal  ScalingReplicaSet  6m17s              deployment-controller  Scaled up replica set jx-go-demo-6-77b6455c87 to 3
  Normal  ScalingReplicaSet  80s                deployment-controller  Scaled up replica set jx-go-demo-6-658f88478b to 1
  Normal  ScalingReplicaSet  80s                deployment-controller  Scaled down replica set jx-go-demo-6-77b6455c87 to 2
  Normal  ScalingReplicaSet  80s                deployment-controller  Scaled up replica set jx-go-demo-6-658f88478b to 2
  Normal  ScalingReplicaSet  72s                deployment-controller  Scaled down replica set jx-go-demo-6-77b6455c87 to 1
  Normal  ScalingReplicaSet  71s (x2 over 72s)  deployment-controller  (combined from similar events): Scaled down replica set jx-go-demo-6-77b6455c87 to 0
```

## Blue-Green Deployments

```bash
jx get applications --env staging
```

```
APPLICATION STAGING PODS URL
go-demo-6   1.0.339 3/3  http://go-demo-6.jx-staging.35.237.112.210.nip.io
```

```bash
VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode
```

```
Promoting app go-demo-6 version 1.0.339 to namespace jx-production
pipeline vfarcic/go-demo-6/master
Created Pull Request: https://github.com/vfarcic/environment-tekton-production/pull/1
Added label  to Pull Request https://github.com/vfarcic/environment-tekton-production/pull/1
pipeline vfarcic/go-demo-6/master
WARNING: Failed to query the Pull Request last commit status for https://github.com/vfarcic/environment-tekton-production/pull/1 ref eca68ffd65f2341e44ae0084a123fe03e50b35d8 Could not find a status for repository vfarcic/environment-tekton-production with ref eca68ffd65f2341e44ae0084a123fe03e50b35d8
WARNING: Failed to query the Pull Request last commit status for https://github.com/vfarcic/environment-tekton-production/pull/1 ref eca68ffd65f2341e44ae0084a123fe03e50b35d8 Could not find a status for repository vfarcic/environment-tekton-production with ref eca68ffd65f2341e44ae0084a123fe03e50b35d8
Pull Request https://github.com/vfarcic/environment-tekton-production/pull/1 is merged at sha b36fd6f4644e6b5986ae32b37a349be33c281537
Merge commit has not yet any statuses on repo vfarcic/environment-tekton-production merge sha b36fd6f4644e6b5986ae32b37a349be33c281537
merge status: pending for URL https://api.github.com/repos/vfarcic/environment-tekton-production/statuses/b36fd6f4644e6b5986ae32b37a349be33c281537 with target: http://jenkins.jx.35.237.112.210.nip.io/job/vfarcic/job/environment-tekton-production/job/master/2/display/redirect description: This commit is being built
merge status: success for URL https://api.github.com/repos/vfarcic/environment-tekton-production/statuses/b36fd6f4644e6b5986ae32b37a349be33c281537 with target: http://jenkins.jx.35.237.112.210.nip.io/job/vfarcic/job/environment-tekton-production/job/master/2/display/redirect description: This commit looks good
Merge status checks all passed so the promotion worked!
```

```bash
jx get applications --env production
```

```
PPLICATION PRODUCTION PODS URL
go-demo-6   1.0.339    3/3  http://go-demo-6.cd-production.35.237.112.210.nip.io
```

```bash
# Repeat if *No applications found in environments production*

PRODUCTION_ADDR=[...]

curl "$PRODUCTION_ADDR/demo/hello"
```

```
hello, rolling update!
```

```bash
# Repeat if *503 Service Temporarily Unavailable*
```

## Progressive Delivery

The necessity to test new releases before deploying them to production is as old as our industry. Over time, we developed elaborate processes aimed at ensuring that our software is ready for production. We test it locally and deploy it to a testing environment and test some more. When we're comfortable with the quality we'd deploy it to the integration or pre-production environment for the final round of validations. You probably see the pattern. The closer we get to releasing something to production, the more our environments would be similar to production. That was a lengthy process that would last for months, sometimes even years.

Why did we move our releases through different environments (e.g., servers or clusters)? The answer lies in the difficulties in maintaining production-like environments. It took a lot of effort to manage environments and the more they looked like production, the more work they required. Later on we adopted configuration management tools like CFEngine, Chef, Puppet, Ansible, and quite a few others. They simplified management of our environments, but we kept the practice of moving our software from one to another as if it was an abandoned child moving from one foster family to another. The main reason why configuration management tools did not solve much lies in misunderstanding the root-cause of the problem. What made management of environments difficult is not that we had many of them, nor that production-like clusters are complicated. Rather, the issue was in mutability. No matter how much effort we put in maintaining the state of our clusters, differences would pile up over time and we could not say that one environment is truly the same as the other. Without that guarantee, we could not claim that what was tested in one environment would work in another. The risk of experiencing failure after deploying to production was still too high.

Over time, we adopted immutability. We learned that things shouldn't be modified at runtime, but rather created anew whenever we need to update something. We started creating VM images that contained new releases and applying rolling updates that would gradually replace the old. But that was slow. It takes time to create a new VM image, and it takes time to instantiate them. There were many other problems with them, but this is neither time nor place to explore them both. Still, immutability applied to the VM level brought quite a few improvements. Our environments became stable and it was easy to have as many production-like environments as we needed.

Then came containers that took immutability to the next level. They allowed us the ability to say that something running in my laptop is the same as something running in a test environment that happens to behave in the same way as in production. Simply put, creating a container based on an image produces the same result no matter where it runs. to be honest, that's not 100% true, but when compared to what we had in the past, containers bring us as close to repeatability as we can get today.

So, if containers provide a reasonable guarantee that a release will behave the same no matter the environment it runs in, we can safely say that if it works in staging, it should work in production. That is especially true if both environments are in the same cluster. In such a case, hardware, networking, storage, and other infrastructure components are the same and the only difference is the Namespace something runs in. That should provide a reasonable guarantee that a release tested in staging should work correctly when promoted to production. Don't you agree?

Actually, even if environments are just different Namespaces in the same cluster and our releases are immutable container images, there is still a reasonable chance that we will detect issues only after we promote releases to production. No matter how well our performance tests are, production load cannot be reliably replicated. No matter how good we became writing functional tests, real users are unpredictable and that cannot be reflected in test automation. Tests look for errors we already know about, and we just can't test what we don't know about. I can go on and on about the differences between production and non-production environments, but it all boils down to one having real users, and the other running simulations of what we think "real" people would do.

Considering that production with real users and non-production with I-hope-this-is-what-real-people-do type of simulations are not the same, we can only conclude that the only final and definitive confirmation that a release is successful can come from observing how well received it is by "real" users while running in production. That leads us to the fact that we need to monitor our production systems and observe user behaviors, error rates, response times, and a lot of other metrics. Based on that data we can conclude whether a new release is truly successful or not. We keep it if it is. If it isn't, we might need to roll back or, even better, roll forward with improvements and bug fixes. That's where Progressive Delivery kicks in.

## Progressive Delivery Explained

TODO: Continue with text

TODO: Is it progressive delivery or progressive deployment, or both?

Progressive Delivery is a term that includes deployment strategies that try to avoid the pitfalls of all-or-nothing deployment strategies. New versions being deployed do not replace existing versions but run in parallel for an amount of time receiving live production traffic, and are evaluated in terms of correctness and performance before the rollout is considered successful.

Progressive Delivery encompasses methodologies such as rolling updates, blue-green or canary deployments. What is common to all of them is that monitoring and metrics are used to evaluate whether the new version is "safe" or needs to be rolled back.

Using rolling updates not all the instances of our application are updated at the same time, but they are incrementally. If you have several instances (containers, virtual machines,...) of your application you would update one at a time and check the metrics of that one before updating the next and so on. In case of issues you would remove them from the pool and increase the number of instances running the previous version.

Blue-green deployments temporarily create a parallel duplicate set of your application with both the old and new version running at the same time, and using a load balancer or DNS all traffic is sent to the new application. Both versions coexist until the new version is validated in production. If there are problems with the new version, the load balancer or DNS is just pointed back to the previous version.

With Canary deployments new versions are deployed and a subset of users are directed to it using traffic rules in a load balancer or more advanced solutions like service mesh. Users of the new version can be chosen randomly as a percentage of the total users or using other criteria such as geographic location, headers, employees vs general users, etc. The new version is evaluated in terms of correctness and performance and, if successful, more users are gradually directed to the new version. If there are issues with the new version or if it doesn't match the expected metrics the traffic rules are updated to send all traffic back to the previous version.

**Progressive Delivery makes it easier to adopt Continuous Delivery**, reducing the risk of new deployments limiting the blast radius of any possible issues, known or unknown, and providing automated ways to rollback to an existing working version.
Testing the 100% of an application is impossible, so we can use these techniques to provide a safety net for our deployments.


We saw how easy it is with Jenkins X to promote applications from development to staging to production, using the concept of environments. But it is an all-or-nothing deployment process with manual intervention if a rollback is needed.

We will explore how Jenkins X integrates Flagger, Istio, and Prometheus, projects that work together to create Canary deployments, where each deployment starts by getting a small percentage of the traffic and analyzing metrics such as response errors and duration. If these metrics fit a predefined requirement the new deployment continues getting more and more traffic until 100% of it goes through the new service. If these metrics are not successful for any reason our deployment is rolled back and is marked as failure.

## Istio

Istio is a service mesh that can run on top of Kubernetes. It has become very popular and allows traffic management, for example sending a percentage of the traffic to a different service and other advanced networking such as point to point security, policy enforcement or automated tracing, monitoring and logging.

Istio already includes its own Prometheus deployment. When Istio is enabled for a service it sends a number of metrics to this Prometheus with no need to adapt our application. We will focus on the response times and status codes.

We could write a full book about Istio, so we will focus on the traffic shifting and metric gathering capabilities of Istio and how we use those to enable Canary deployments.

## Prometheus

Prometheus is the monitoring and alerting system of choice for Kubernetes clusters. It stores time series data that can be queried using PromQL, its query language. Time series collection happens via pull over HTTP.
Many systems integrate with Prometheus as data store for their metrics.

Istio already includes its own Prometheus deployment. When Istio is enabled for a service it sends a number of metrics to this Prometheus with no need to adapt our application. We will focus on the response times and status codes.

## Flagger

Flagger is a project sponsored by WeaveWorks using Istio to automate canarying and rollbacks using metrics from Prometheus. It goes beyond what Istio provides, automating the promotion of canary deployments using Istio for traffic shifting and Prometheus metrics for canary analysis, allowing progressive rollouts and rollbacks based on metrics.


[Flagger](https://github.com/stefanprodan/flagger) is a **Kubernetes** operator that automates the promotion of canary deployments using **Istio** routing for traffic shifting and **Prometheus** metrics for canary analysis.

Flagger requires Istio, plus the installation of the Flagger controller itself. It also offers a Grafana dashboard to monitor the deployment progress.

The deployment rollout is defined by a Canary object that will generate primary and canary Deployment objects. When the Deployment is edited, for instance to use a new image version, the Flagger controller will shift the loads from 0% to 50% with 10% increases every minute, then it will shift to the new deployment or rollback if response errors and request duration metrics fail.

## Requirement Installation

We can easily install Istio and Flagger with `jx`

NOTE: Addons are probably going to be merged into apps

```bash
jx create addon istio \
    --version 1.1.7
```

NOTE: the command may fail due to the order Helm applies CRD resources. Re-running the command again should fix it.

NOTE: Istio is resource heavy and the cluster is likely going to scale up. That might slow down some activities.

When installing Istio a new ingress gateway service is created that can send all the incoming traffic to services based on Istio rules or `VirtualServices`. This achieves a similar functionality than that of the ingress controller, but using Istio configuration instead of ingresses, that allows us to create more advanced rules for incoming traffic.

We can find the external ip address of the ingress gateway service and configure a wildcard DNS for it, so we can use multiple hostnames for different services.
Note the ip from the output of `jx create addon istio` or find it with this command, we will refer to it as `ISTIO_IP`.

```bash
# If not EKS
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
```

Let's continue with the other addons

NOTE: Prometheus is already installed with Istio

```bash
jx create addon flagger
```

```
WARNING: failed to create system vault in namespace cd due to no "jx-vault-vfarcic" vault found in namespace "cd"


Enabling Istio in namespace cd-production
Creating Istio gateway: jx-gateway
```

```bash
kubectl --namespace istio-system \
    get pods
```

```
NAME                                      READY   STATUS      RESTARTS   AGE
flagger-5bdbccc7f4-qx5wt                  1/1     Running     0          110s
flagger-grafana-5c88686d56-tr9l5          1/1     Running     0          78s
istio-citadel-7f447d4d4b-4t6zj            1/1     Running     0          3m22s
istio-galley-84749d54b7-2pjql             1/1     Running     0          4m46s
istio-ingressgateway-6b79f895d6-wfvtr     1/1     Running     0          4m40s
istio-init-crd-10-62c64                   0/1     Completed   0          5m8s
istio-init-crd-11-27xq5                   0/1     Completed   0          5m7s
istio-pilot-76899788b6-ws6lq              2/2     Running     0          3m35s
istio-policy-578bcb878f-pp7ql             2/2     Running     6          4m38s
istio-sidecar-injector-6895997989-gn85h   1/1     Running     0          3m14s
istio-telemetry-5448cbd995-bp7ms          2/2     Running     6          4m38s
prometheus-5977597c75-p5dn6               1/1     Running     0          3m28s
```

```bash
kubectl describe namespace \
    $NAMESPACE-production
```

```yaml
Name:         cd-production
Labels:       env=production
              istio-injection=enabled
              team=cd
Annotations:  <none>
Status:       Active

Resource Quotas
 Name:                       gke-resource-quotas
 Resource                    Used  Hard
 --------                    ---   ---
 count/ingresses.extensions  0     100
 count/jobs.batch            0     5k
 pods                        0     1500
 services                    0     500

No resource limits.
```

```bash
kubectl describe namespace \
    $NAMESPACE-staging
```

```yaml
Name:         cd-staging
Labels:       env=staging
              team=cd
Annotations:  jenkins-x.io/created-by: Jenkins X
Status:       Active

Resource Quotas
 Name:                       gke-resource-quotas
 Resource                    Used  Hard
 --------                    ---   ---
 count/ingresses.extensions  1     100
 count/jobs.batch            0     5k
 pods                        6     1500
 services                    3     500

No resource limits.
```

```bash
kubectl label namespace \
    $NAMESPACE-staging \
    istio-injection=enabled \
    --overwrite
```

```
namespace/cd-staging labeled
```

```bash
kubectl describe namespace \
    $NAMESPACE-staging
```

```yaml
Name:         cd-staging
Labels:       env=staging
              istio-injection=enabled
              team=cd
Annotations:  jenkins-x.io/created-by: Jenkins X
Status:       Active

Resource Quotas
 Name:                       gke-resource-quotas
 Resource                    Used  Hard
 --------                    ---   ---
 count/ingresses.extensions  1     100
 count/jobs.batch            0     5k
 pods                        6     1500
 services                    3     500

No resource limits.
```

The Flagger addon will enable Istio for all pods in the `jx-production` namespace so they send traffic metrics to Prometheus.
It will also configure an Istio ingress gateway to accept incoming external traffic through the ingress gateway service, but for it to reach the final service we must create Istio `VirtualServices`, the rules that manage the Istio routing. Flagger will do that for us.

## Flagger App Configuration

Let's say we want to deploy our new version to 10% of the users, and increase it another 10% every 10 seconds until we reach 50% of the users, then deploy to all users. We will examine two key metrics, whether more than 1% of the requests fail (5xx errors) or the request time is over 500ms. If these metrics fail 5 times we want to rollback to the old version.

This configuration can be done using Flagger's `Canary` objects, that we can add to our application helm chart under `charts/go-demo-6/templates/canary.yaml` 

```bash
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
```

```yaml
{{- if .Values.canary.enable }}
apiVersion: flagger.app/v1alpha2
kind: Canary
metadata:
  name: {{ template "fullname" . }}
spec:
  provider: {{.Values.canary.provider}}
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ template "fullname" . }}
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
```

And the `canary` section added to our chart values file in `charts/go-demo-6/values.yaml`. Remember to set the correct domain name for our Istio gateway instead of `go-demo-6.$ISTIO_IP.nip.io`.

```bash
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
```

```yaml
canary:
  enable: false
  provider: istio
  service:
    hosts:
    - go-demo-6.34.73.8.113.nip.io
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
```

Explanation of the values in the configuration:

* `canary.service.hosts` list of host names that Istio will send to our application.
* `canary.service.gateways` list of Istio gateways that will send traffic to our application. `jx-gateway.istio-system.svc.cluster.local` is the gateway created by the Flagger addon on installation.
* `canary.canaryAnalysis.threshold` number of times a metric must fail before aborting the rollout.
* `canary.canaryAnalysis.maxWeight` max percentage sent to the canary deployment, when reached all traffic is sent to the new new version.
* `canary.canaryAnalysis.stepWeight` increase the percentage this much in each interval (20%, 40%, 60%, etc).
* `canary.canaryAnalysis.metrics` metrics from Prometheus, some are automatically populated by Istio and you can add your own from your application.
  * `request-success-rate` minimum request success rate (non 5xx responses) percentage (0-100).
  * `request-duration` maximum request duration in milliseconds, in the 99th percentile.

TODO: Carlos: Shouldn't we change `service.annotations.fabric8.io/expose` to `false` in `charts/go-demo-6/values.yaml`?

Mongodb will not work by default with Istio because it runs under a non root `securityContext`, you would get this error in the `istio-init` init container.

```
iptables v1.6.0: can't initialize iptables table `nat': Permission denied (you must be root)
```

In order to simplify things we will just enable Istio for the main web service, disabling automatic Istio sidecar injection for our mongodb deployment by setting the `sidecar.istio.io/inject: "false"` annotation.

Under `go-demo-6` entry, add the `podAnnotations` section with `sidecar.istio.io/inject` set to `"false"`.

```bash
cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@go-demo-6-db:@go-demo-6-db:\
  podAnnotations:\
    sidecar.istio.io/inject: "false"@g' \
    | tee charts/go-demo-6/values.yaml
```

```yaml
# Default values for Go projects.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
replicaCount: 3
image:
  repository: draft
  tag: dev
  pullPolicy: IfNotPresent
service:
  name: go-demo-6
  type: ClusterIP
  externalPort: 80
  internalPort: 8080
  annotations:
    fabric8.io/expose: "true"
    fabric8.io/ingress.annotations: "kubernetes.io/ingress.class: nginx"
resources:
  limits:
    cpu: 100m
    memory: 256Mi
  requests:
    cpu: 80m
    memory: 128Mi
probePath: /demo/hello?health=true
livenessProbe:
  initialDelaySeconds: 60
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
readinessProbe:
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
terminationGracePeriodSeconds: 10
go-demo-6-db:
  podAnnotations:
    sidecar.istio.io/inject: "false"
  replicaSet:
    enabled: true


  usePassword: false
knativeDeploy: false




canary:
  enable: false
  provider: istio
  service:
    hosts:
    - go-demo-6.34.73.8.113.nip.io
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
```

```bash
cd ..

# If serverless
ENVIRONMENT=tekton

# If static
ENVIRONMENT=jx-rocks

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
```

```yaml
go-demo-6:
  canary:
    enable: true
    service:
      hosts:
      - staging.go-demo-6.34.73.8.113.nip.io
```

```bash
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

# Press *ctrl+c* when the activity is finished

# If serverless
jx get activities \
    --filter environment-tekton-staging/master \
    --watch

# Press *ctrl+c* when the activity is finished
```

## Canary Deployments

```bash
curl $STAGING_ADDR/demo/hello
```

```
hello, rolling update!
```

```bash
# Repeat if `no healthy upstream` (DB is not yet up and running)

kubectl \
    --namespace $NAMESPACE-staging \
    get all
```

```
NAME                                        READY   STATUS    RESTARTS   AGE
pod/jx-go-demo-6-db-arbiter-0               1/1     Running   0          69s
pod/jx-go-demo-6-db-primary-0               1/1     Running   0          65s
pod/jx-go-demo-6-db-secondary-0             1/1     Running   0          65s
pod/jx-go-demo-6-primary-7d5755576c-6kjjv   2/2     Running   0          65s
pod/jx-go-demo-6-primary-7d5755576c-9wsqw   2/2     Running   1          65s
pod/jx-go-demo-6-primary-7d5755576c-c7xv6   2/2     Running   1          65s
NAME                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
service/go-demo-6                  ClusterIP   10.31.250.55    <none>        80/TCP      97m
service/jx-go-demo-6               ClusterIP   10.31.253.52    <none>        8080/TCP    67s
service/jx-go-demo-6-canary        ClusterIP   10.31.243.175   <none>        8080/TCP    67s
service/jx-go-demo-6-db            ClusterIP   10.31.244.152   <none>        27017/TCP   117m
service/jx-go-demo-6-db-headless   ClusterIP   None            <none>        27017/TCP   117m
service/jx-go-demo-6-primary       ClusterIP   10.31.250.21    <none>        8080/TCP    67s
NAME                                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jx-go-demo-6           0         0         0            0           102m
deployment.apps/jx-go-demo-6-primary   3         3         3            3           68s
NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/jx-go-demo-6-55f699d857           0         0         0       75s
replicaset.apps/jx-go-demo-6-658f88478b           0         0         0       88m
replicaset.apps/jx-go-demo-6-77b6455c87           0         0         0       93m
replicaset.apps/jx-go-demo-6-8b5698864            0         0         0       97m
replicaset.apps/jx-go-demo-6-94b4bb9b6            0         0         0       102m
replicaset.apps/jx-go-demo-6-primary-7d5755576c   3         3         3       68s
NAME                                         DESIRED   CURRENT   AGE
statefulset.apps/jx-go-demo-6-db-arbiter     1         1         117m
statefulset.apps/jx-go-demo-6-db-primary     1         1         117m
statefulset.apps/jx-go-demo-6-db-secondary   1         1         117m
NAME                                  NAME        VERSION   GIT URL
release.jenkins.io/go-demo-6-9.0.33   go-demo-6   v9.0.33   https://github.com/vfarcic/go-demo-6
NAME                              STATUS        WEIGHT   LASTTRANSITIONTIME
canary.flagger.app/jx-go-demo-6   Initialized   0        2019-08-16T23:17:03Z
```

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get virtualservice.networking.istio.io
```

```
NAME           GATEWAYS                                      HOSTS                                                 AGE
jx-go-demo-6   [jx-gateway.istio-system.svc.cluster.local]   [staging.go-demo-6.34.73.8.113.nip.io jx-go-demo-6]   1m
```

After detecting a new `Canary` object Flagger will automatically create some other objects to manage the canary deployment:

* deployment.apps/jx-go-demo-6-primary
* service/jx-go-demo-6
* service/jx-go-demo-6-canary
* service/jx-go-demo-6-primary
* virtualservice.networking.istio.io/jx-go-demo-6

The primary and canary deployments manage the incumbent and new version of the deploy respectively. Flagger will have both running during the canary process and create the Istio `VirtualService` that sends traffic to one or another. Initially all traffic is sent to the primary deployment. Lets make a new deployment and see how it is being canaried.

We are going to create a trivial change in the demo application, replacing `hello, PR!` in `main.go` to `hello, progressive!`. Then we will commit and merge it to master to get a new version in the staging environment. 

Let's tail Flagger logs so we can get insights in the deployment process.

```bash
kubectl \
    --namespace istio-system logs \
    --selector app.kubernetes.io/name=flagger \
    --follow
```

```
{"level":"info","ts":"2019-08-16T23:16:33.564Z","caller":"canary/deployer.go:48","msg":"Scaling down jx-go-demo-6.cd-staging","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:33.829Z","caller":"router/kubernetes.go:122","msg":"Service jx-go-demo-6.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:33.913Z","caller":"router/kubernetes.go:122","msg":"Service jx-go-demo-6-canary.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:33.990Z","caller":"router/kubernetes.go:122","msg":"Service jx-go-demo-6-primary.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:34.052Z","caller":"router/istio.go:77","msg":"DestinationRule jx-go-demo-6-canary.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:34.170Z","caller":"router/istio.go:77","msg":"DestinationRule jx-go-demo-6-primary.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:34.295Z","caller":"router/istio.go:205","msg":"VirtualService jx-go-demo-6.cd-staging created","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:16:34.302Z","caller":"controller/controller.go:271","msg":"Halt advancement jx-go-demo-6-primary.cd-staging waiting for rollout to finish: 0 of 3 updated replicas are available","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:17:03.415Z","caller":"canary/deployer.go:48","msg":"Scaling down jx-go-demo-6.cd-staging","canary":"jx-go-demo-6.cd-staging"}
{"level":"info","ts":"2019-08-16T23:17:03.524Z","caller":"controller/controller.go:261","msg":"Initialization done! jx-go-demo-6.cd-staging","canary":"jx-go-demo-6.cd-staging"}
```

NOTE: Stop with *ctrl+c*

And once the new version is built we can promote it to production.

```bash
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

# Copy the output

# Go to the second terminal

STAGING_ADDR=[...]

while true
do
    curl "$STAGING_ADDR/demo/hello"
    sleep 0.2
done
```

```
...
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, rolling update!
hello, progressive!
hello, rolling update
...
hello, rolling update!
hello, progressive!
hello, progressive!
hello, progressive!
hello, rolling update!
hello, progressive!
hello, rolling update!
hello, rolling update!
...
```

```bash
# Stop with *ctrl+c*

# Go back to the first terminal when approx 50% of requests are from the new release

kubectl \
    --namespace $NAMESPACE-staging \
    get pods
```

```
NAME                                    READY   STATUS    RESTARTS   AGE
jx-go-demo-6-68f6ff77cb-rqkk8           2/2     Running   0          116s
jx-go-demo-6-db-arbiter-0               1/1     Running   0          6m58s
jx-go-demo-6-db-primary-0               1/1     Running   0          6m54s
jx-go-demo-6-db-secondary-0             1/1     Running   0          6m54s
jx-go-demo-6-primary-7d5755576c-6kjjv   2/2     Running   0          6m54s
jx-go-demo-6-primary-7d5755576c-9wsqw   2/2     Running   1          6m54s
jx-go-demo-6-primary-7d5755576c-c7xv6   2/2     Running   1          6m54s
```

Now Jenkins X will update the GitOps production environment repository to the new version by creating a pull request to change the version. After a little bit it will deploy the new version Helm chart that will update the `deployment.apps/jx-go-demo-6` object in the `jx-production` environment.

Flagger will detect this deployment change update the Istio `VirtualService` to send 10% of the traffic to the new version service `service/jx-go-demo-6` while 90% is sent to the previous version `service/jx-go-demo-6-primary`. We can see this Istio configuration with `kubectl -n jx-production get virtualservice/jx-go-demo-6 -o yaml` under the http route weight parameter.

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get virtualservice.networking.istio.io \
    jx-go-demo-6 \
    --output yaml
```

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  creationTimestamp: "2019-08-16T23:16:34Z"
  generation: 1
  name: jx-go-demo-6
  namespace: cd-staging
  ownerReferences:
  - apiVersion: flagger.app/v1alpha3
    blockOwnerDeletion: true
    controller: true
    kind: Canary
    name: jx-go-demo-6
    uid: dee033ef-c07b-11e9-9aa4-42010a8e00b0
  resourceVersion: "39679"
  selfLink: /apis/networking.istio.io/v1alpha3/namespaces/cd-staging/virtualservices/jx-go-demo-6
  uid: e38d47b2-c07b-11e9-9aa4-42010a8e00b0
spec:
  gateways:
  - jx-gateway.istio-system.svc.cluster.local
  hosts:
  - staging.go-demo-6.34.73.8.113.nip.io
  - jx-go-demo-6
  http:
  - route:
    - destination:
        host: jx-go-demo-6-primary
      weight: 20
    - destination:
        host: jx-go-demo-6-canary
      weight: 80
```

We can test this by accessing our application using the dns we previously created for the Istio gateway. For instance running `curl "http://go-demo-6.${ISTIO_IP}.nip.io/demo/hello"` will give us the response from the previous version around 90% of the times, and the current version the other 10%.

Describing the canary object will also give us information about the deployment progress.

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    get ing
```

```
NAME        HOSTS                                        ADDRESS          PORTS   AGE
go-demo-6   go-demo-6.cd-staging.35.237.194.237.nip.io   35.237.194.237   80      103m
```

```bash
# TODO: We should probably remove the Ingress. Is there a reason for its existence?

kubectl -n $NAMESPACE-staging \
    get canary
```

```
NAME           STATUS       WEIGHT   LASTTRANSITIONTIME
jx-go-demo-6   Progressing  80       2019-08-16T23:24:03Z
```

```bash
# The status will be `Succeeded` when finished

kubectl \
    --namespace $NAMESPACE-staging \
    describe canary jx-go-demo-6
```

```yaml
Name:         jx-go-demo-6
Namespace:    cd-staging
Labels:       jenkins.io/chart-release=jx
              jenkins.io/namespace=cd-staging
              jenkins.io/version=8
Annotations:  jenkins.io/chart: env
              kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"flagger.app/v1alpha2","kind":"Canary","metadata":{"annotations":{"jenkins.io/chart":"env"},"labels":{"jenkins.io/chart-rele...
API Version:  flagger.app/v1alpha3
Kind:         Canary
Metadata:
  Creation Timestamp:  2019-08-16T23:16:26Z
  Generation:          1
  Resource Version:    40026
  Self Link:           /apis/flagger.app/v1alpha3/namespaces/cd-staging/canaries/jx-go-demo-6
  UID:                 dee033ef-c07b-11e9-9aa4-42010a8e00b0
Spec:
  Canary Analysis:
    Interval:    30s
    Max Weight:  70
    Metrics:
      Interval:               120s
      Name:                   request-success-rate
      Threshold:              99
      Interval:               120s
      Name:                   request-duration
      Threshold:              500
    Step Weight:              20
    Threshold:                5
  Progress Deadline Seconds:  60
  Provider:                   istio
  Service:
    Gateways:
      jx-gateway.istio-system.svc.cluster.local
    Hosts:
      staging.go-demo-6.34.73.8.113.nip.io
    Port:  8080
  Target Ref:
    API Version:  apps/v1
    Kind:         Deployment
    Name:         jx-go-demo-6
Status:
  Canary Weight:  0
  Conditions:
    Last Transition Time:  2019-08-16T23:24:33Z
    Last Update Time:      2019-08-16T23:24:33Z
    Message:               Canary analysis completed successfully, promotion finished.
    Reason:                Succeeded
    Status:                True
    Type:                  Promoted
  Failed Checks:           0
  Iterations:              0
  Last Applied Spec:       1289860333710986770
  Last Promoted Spec:      1289860333710986770
  Last Transition Time:    2019-08-16T23:24:33Z
  Phase:                   Succeeded
  Tracked Configs:
Events:
  Type     Reason  Age    From     Message
  ----     ------  ----   ----     -------
  Warning  Synced  8m31s  flagger  Halt advancement jx-go-demo-6-primary.cd-staging waiting for rollout to finish: 0 of 3 updated replicas are available
  Normal   Synced  8m2s   flagger  Initialization done! jx-go-demo-6.cd-staging
  Normal   Synced  3m32s  flagger  New revision detected! Scaling up jx-go-demo-6.cd-staging
  Normal   Synced  3m2s   flagger  Starting canary analysis for jx-go-demo-6.cd-staging
  Normal   Synced  3m2s   flagger  Advance jx-go-demo-6.cd-staging canary weight 20
  Normal   Synced  2m32s  flagger  Advance jx-go-demo-6.cd-staging canary weight 40
  Normal   Synced  2m2s   flagger  Advance jx-go-demo-6.cd-staging canary weight 60
  Normal   Synced  92s    flagger  Advance jx-go-demo-6.cd-staging canary weight 80
  Normal   Synced  92s    flagger  Copying jx-go-demo-6.cd-staging template spec to jx-go-demo-6-primary.cd-staging
  Normal   Synced  62s    flagger  Routing all traffic to primary
  Normal   Synced  32s    flagger  (combined from similar events): Promotion completed! Scaling down jx-go-demo-6.cd-staging
```

Every 10 seconds 10% more traffic will be directed to our new version if the metrics are successful. Note that we had to generate some traffic (with the curl loop above) otherwise Flagger will assume something is wrong with our deployment that is preventing traffic and will automatically roll back.


## Automated Rollbacks

Flagger will automatically rollback if any of the metrics we set fail the number of times set on the threshold configuration option, or if there are no metrics, as Flagger assumes something is very wrong with our application.

Let's show what would happen if we promote to production the previous version with no traffic.

```bash
# # NOTE: Make sure that some time passed (e.g., 15 min), otherwise it will get the old metrics and think that the requests are coming in

# cat main.go | sed -e \
#     "s@hello, progressive@hello, no one@g" \
#     | tee main.go

# cat main_test.go | sed -e \
#     "s@hello, progressive@hello, no one@g" \
#     | tee main_test.go

# git add .

# git commit \
#     -m "Added progressive deployment"

# git push

# jx get activities \
#     --filter go-demo-6 \
#     --watch

# # Press *ctrl+c* when the activity is finished

# jx get activities \
#     --filter environment-tekton-staging/master \
#     --watch

# # Press *ctrl+c* when the activity is finished

# # Not sending any requests

# # After a few minutes

# kubectl -n $NAMESPACE-staging \
#     get canary
```

Now let's try again and show what happens when the application returns http errors.

NOTE: as the time of writing `jx get applications` will show versions that are out of sync from the ones actually deployed after a promotion failure. You can see the versions actually deployed with `kubectl -n jx-production get deploy -o wide`. For that same reason you can't try to immediately promote again a version that was rolled back by Flagger, as that version is already the one in the GitOps environment repo and will not trigger any deployment because there are no changes to the git files.


```bash
# kubectl \
#     --namespace $NAMESPACE-staging \
#     get pods

# curl "$STAGING_ADDR/demo/hello"

# # Wait until it rolls back

# curl "$STAGING_ADDR/demo/hello"

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

# jx get activities \
#     --filter go-demo-6 \
#     --watch

# jx get activities \
#     --filter environment-tekton-staging/master \
#     --watch

# NOTE: Go to the second terminal

while true
do
    curl "$STAGING_ADDR/demo/random-error"
    sleep 0.2
done
```

```
...
ERROR: Something, somewhere, went wrong!
Everything is still OK with progressive delivery
Everything is still OK
Everything is still OK
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK
ERROR: Something, somewhere, went wrong!
Everything is still OK
Everything is still OK
Everything is still OK
Everything is still OK
Everything is still OK
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK with progressive delivery
Everything is still OK
...
```

```bash
# NOTE: Go to the first terminal

kubectl \
    --namespace $NAMESPACE-staging \
    get virtualservice.networking.istio.io \
    jx-go-demo-6 \
    --output yaml
```

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  creationTimestamp: "2019-08-16T23:16:34Z"
  generation: 1
  name: jx-go-demo-6
  namespace: cd-staging
  ownerReferences:
  - apiVersion: flagger.app/v1alpha3
    blockOwnerDeletion: true
    controller: true
    kind: Canary
    name: jx-go-demo-6
    uid: dee033ef-c07b-11e9-9aa4-42010a8e00b0
  resourceVersion: "56484"
  selfLink: /apis/networking.istio.io/v1alpha3/namespaces/cd-staging/virtualservices/jx-go-demo-6
  uid: e38d47b2-c07b-11e9-9aa4-42010a8e00b0
spec:
  gateways:
  - jx-gateway.istio-system.svc.cluster.local
  hosts:
  - staging.go-demo-6.34.73.8.113.nip.io
  - jx-go-demo-6
  http:
  - route:
    - destination:
        host: jx-go-demo-6-primary
      weight: 40
    - destination:
        host: jx-go-demo-6-canary
      weight: 60
```

```bash
kubectl -n $NAMESPACE-staging \
    get canary
```

```
NAME           STATUS        WEIGHT   LASTTRANSITIONTIME
jx-go-demo-6   Progressing   60       2019-08-17T00:21:33Z
```

```bash
kubectl \
    --namespace $NAMESPACE-staging \
    describe canary jx-go-demo-6
```

```
...
  Warning  Synced  3m17s  flagger  Halt jx-go-demo-6.jx-staging advancement success rate 90.09% < 99%
  Warning  Synced  2m47s  flagger  Halt jx-go-demo-6.jx-staging advancement success rate 88.57% < 99%
  Warning  Synced  2m17s  flagger  Halt jx-go-demo-6.jx-staging advancement success rate 91.49% < 99%
  Warning  Synced  107s   flagger  Halt jx-go-demo-6.jx-staging advancement success rate 96.00% < 99%
  Warning  Synced  77s    flagger  Halt jx-go-demo-6.jx-staging advancement success rate 87.72% < 99%
  Warning  Synced  47s    flagger  Canary failed! Scaling down jx-go-demo-6.jx-staging
  Warning  Synced  47s    flagger  Rolling back jx-go-demo-6.jx-staging failed checks threshold reached 5
```

```bash
# NOTE: Go to the second terminal
```

```
...
Everything is still OK
Everything is still OK
Everything is still OK
Everything is still OK
ERROR: Something, somewhere, went wrong!
Everything is still OK
ERROR: Something, somewhere, went wrong!
...
```

```bash
# Stop with *ctrl+c*

# Go back to the first terminal
```

## Visualizing the Rollout

Flagger includes a Grafana dashboard where we can visually see metrics in our canary rollout process. By default is not accessible, so we need to create an ingress object pointing to the Grafana service running in the cluster.

```bash
LB_IP=$(kubectl \
    --namespace kube-system \
    get svc jxing-nginx-ingress-controller \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo $LB_IP
```

```
35.237.194.237
```

```bash
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
```

```
ingress.extensions/flagger-grafana created
```

```bash
open "http://flagger-grafana.$LB_IP.nip.io"
```

Then we can access Grafana at `http://flagger-grafana.jx.$PROD_IP.nip.io/d/flagger-istio/istio-canary?refresh=5s&orgId=1&var-namespace=jx-production&var-primary=jx-go-demo-6-primary&var-canary=jx-go-demo-6` using `admin/admin` credentials.
If not displayed directly, we should go to the `Istio Canary` dashboard and select

* namespace: `jx-staging`
* primary: `jx-go-demo-6-primary`
* canary: `jx-go-demo-6`

to see metrics side by side of the previous version and the new version, such as request volume, request success rate, request duration, CPU and memory usage,...

NOTE: We should change the production environment as well

## What Now?

TODO: Viktor: Rewrite

Now is a good time for you to take a break.

If you created a cluster only for the purpose of the exercises we executed, please destroy it. We'll start the next, and each other chapter from scratch as a way to save you from running your cluster longer than necessary and pay more than needed to your hosting vendor. If you created the cluster or installed Jenkins X using one of the Gists from the beginning of this chapter, you'll find the instructions on how to destroy the cluster or uninstall everything at the bottom.

If you did choose to destroy the cluster or to uninstall Jenkins X, please remove the repositories we created as well as the local files. You can use the commands that follow for that. Just remember to replace `[...]` with your GitHub user.

```bash
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
```

Finally, you might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just keep reading.
