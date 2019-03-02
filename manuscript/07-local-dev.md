## Checklist

- [X] Code
- [ ] Write
- [X] Code review GKE
- [ ] Code review EKS
- [ ] Code review AKS
- [ ] Code review existing cluster
- [ ] Text review
- [ ] Diagrams
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Development

## Developer Day

* From a tablet and Google terminal
* Any project in any language and with any framework
* Push to any registry with a single (k8s authentication)
* Without installing tools (e.g., Go, skaffold, Helm, Docker, etc)

TODO: Explain my developer environment

TODO: Screenshot with VS Code

## Past Time

* Go compiler
* Docker
* skaffold
* Helm
* kubectl
* Access to ChartMuseum
* Access to Docker registry
* ...

## Cluster

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

```bash
jx version

cd go-demo-6

# Just in case
git checkout buildpack

# Just in case
git merge -s ours master --no-edit

# Just in case
git checkout master

# Just in case
git merge buildpack

# Just in case
git push

jx import -b # Only if not reusing the cluster from the previous chapter
```

## Present Time

NOTE: No more `kubectl`

```bash
cd go-demo-6 # If not already there

jx create devpod --reuse -b
```

```
Namespace jx-edit-vfarcic created
 Installing the ExposecontrollerService in the namespace: jx-edit-vfarcic
could not find a stable version from charts of jenkins-x/exposecontroller-service from /Users/vfarcic/.jx/jenkins-x-versions
For background see: https://jenkins-x.io/architecture/version-stream/
Please lock this version down via the command: jx step create version pr -k charts -n jenkins-x/exposecontroller-service

Updating Helm repository...
Helm repository update done.
Creating a DevPod of label: go
Created pod vfarcic-go - waiting for it to be ready...
Updating Helm repository...
Helm repository update done.
Pod vfarcic-go is now ready!
You can open other shells into this DevPod via jx create devpod

You can edit your app using Theia (a browser based IDE) at http://vfarcic-go-theia.jx.34.73.126.76.nip.io

You can access the DevPod from your browser via the following URLs:
* http://vfarcic-go-port-2345.jx.34.73.126.76.nip.io
* http://vfarcic-go-port-8080.jx.34.73.126.76.nip.io

Attempting to install Bash Completion into DevPod
Defaulting container name to go.
Use 'kubectl describe pod/vfarcic-go -n jx' to see all of the containers in this pod.
Generated Git credentials file /home/jenkins/git/credentials
Cloning into 'go-demo-6'...
remote: Enumerating objects: 28, done.
remote: Counting objects: 100% (28/28), done.
remote: Compressing objects: 100% (22/22), done.
remote: Total 2346 (delta 10), reused 20 (delta 6), pack-reused 2318
Receiving objects: 100% (2346/2346), 16.94 MiB | 25.04 MiB/s, done.
Resolving deltas: 100% (1110/1110), done.
Checking connectivity... done.
```

```bash
jx rsh -d # Only if not already inside the Pod
```

```bash
ls -1

# NOTE: If the output is `go-demo-6`, enter inside the directory with `cd go-demo-6` and execute `ls -1` again
```

```
in
charts
Dockerfile
functional_test.go
go.mod
go.sum
Jenkinsfile
main.go
main_test.go
Makefile
OWNERS
OWNERS_ALIASES
production_test.go
README.md
skaffold.yaml
vendor
watch.sh
```

```bash
go mod init

make linux

cat skaffold.yaml
```

```yaml
apiVersion: skaffold/v1beta2
kind: Config
build:
  artifacts:
  - image: changeme
    context: .
    docker: {}
  tagPolicy:
    envTemplate:
      template: '{{.DOCKER_REGISTRY}}/vfarcic/go-demo-6:{{.VERSION}}'
  local: {}
deploy:
  kubectl: {}
profiles:
- name: dev
  build:
    artifacts:
    - docker: {}
    tagPolicy:
      envTemplate:
        template: '{{.DOCKER_REGISTRY}}/vfarcic/go-demo-6:{{.DIGEST_HEX}}'
    local: {}
  deploy:
    helm:
      releases:
      - name: go-demo-6
        chartPath: charts/go-demo-6
        setValueTemplates:
          image.repository: '{{.DOCKER_REGISTRY}}/vfarcic/go-demo-6'
          image.tag: '{{.DIGEST_HEX}}'
```

```bash
echo $DOCKER_REGISTRY
```

```bash
env
```

```
HEAPSTER_SERVICE_PORT=8082
JENKINS_X_MONOCULAR_PRERENDER_SERVICE_PORT=80
JX_RELEASE_VERSION=1.0.10
JENKINS_X_MONOCULAR_UI_PORT_80_TCP_PORT=80
HOSTNAME=vfarcic-go
GOLANG_VERSION=1.11.4
JENKINS_X_CHARTMUSEUM_PORT_8080_TCP_PROTO=tcp
TERM=xterm
JENKINS_X_MONOCULAR_UI_PORT_80_TCP_ADDR=10.31.254.100
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT=tcp://10.31.240.1:443
JENKINS_X_MONOCULAR_UI_PORT_80_TCP=tcp://10.31.254.100:80
JENKINS_X_MONOCULAR_UI_SERVICE_PORT=80
KUBERNETES_SERVICE_PORT=443
HEAPSTER_SERVICE_HOST=10.31.247.234
JENKINS_X_MONOCULAR_PRERENDER_SERVICE_HOST=10.31.246.132
JENKINS_X_MONOCULAR_UI_PORT_80_TCP_PROTO=tcp
GO15VENDOREXPERIMENT=1
JENKINS_X_MONOCULAR_API_PORT_80_TCP=tcp://10.31.246.33:80
JENKINS_PORT_8080_TCP_PROTO=tcp
JENKINS_X_DOCKER_REGISTRY_PORT_5000_TCP_ADDR=10.31.246.91
KUBERNETES_SERVICE_HOST=10.31.240.1
HEAPSTER_PORT_8082_TCP=tcp://10.31.247.234:8082
JENKINS_X_MONOCULAR_API_SERVICE_PORT=80
JENKINS_X_MONOCULAR_API_SERVICE_PORT_MONOCULAR_API=80
LC_ALL=en_US.UTF-8
SKAFFOLD_DEPLOY_NAMESPACE=jx-edit-vfarcic
JENKINS_X_CHARTMUSEUM_PORT=tcp://10.31.240.23:8080
HEAPSTER_PORT_8082_TCP_PORT=8082
LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;36:*.au=01;36:*.flac=01;36:*.mid=01;36:*.midi=01;36:*.mka=01;36:*.mp3=01;36:*.mpc=01;36:*.ogg=01;36:*.ra=01;36:*.wav=01;36:*.axa=01;36:*.oga=01;36:*.spx=01;36:*.xspf=01;36:
JENKINS_X_DOCKER_REGISTRY_PORT_5000_TCP=tcp://10.31.246.91:5000
JENKINS_X_DOCKER_REGISTRY_PORT=tcp://10.31.246.91:5000
JENKINS_X_MONOCULAR_PRERENDER_PORT_80_TCP_PORT=80
JENKINS_AGENT_PORT_50000_TCP_ADDR=10.31.254.0
JENKINS_X_CHARTMUSEUM_SERVICE_PORT_HTTP=8080
JENKINS_PORT_8080_TCP=tcp://10.31.244.27:8080
GIT_AUTHOR_NAME=jenkins-x-bot
JENKINS_X_MONOCULAR_PRERENDER_PORT=tcp://10.31.246.132:80
HEAPSTER_PORT=tcp://10.31.247.234:8082
JENKINS_X_CHARTMUSEUM_SERVICE_PORT=8080
GIT_COMMITTER_NAME=jenkins-x-bot
HEAPSTER_PORT_8082_TCP_ADDR=10.31.247.234
JENKINS_AGENT_PORT_50000_TCP=tcp://10.31.254.0:50000
JENKINS_X_CHARTMUSEUM_PORT_8080_TCP_PORT=8080
JENKINS_X_MONOCULAR_PRERENDER_PORT_80_TCP_PROTO=tcp
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/google-cloud-sdk/bin:/opt/google/chrome:/usr/local/go/bin:/usr/local/glide:/usr/local/:/home/jenkins/go/bin
JENKINS_AGENT_SERVICE_HOST=10.31.254.0
JENKINS_X_DOCKER_REGISTRY_PORT_5000_TCP_PROTO=tcp
PROTOBUF=3.5.1
JENKINS_X_MONGODB_PORT_27017_TCP_ADDR=10.31.243.196
HUGO_VERSION=0.49
WORK_DIR=/workspace
JENKINS_X_CHARTMUSEUM_PORT_8080_TCP=tcp://10.31.240.23:8080
JENKINS_X_MONOCULAR_PRERENDER_PORT_80_TCP_ADDR=10.31.246.132
GCLOUD_VERSION=222.0.0
GIT_COMMITTER_EMAIL=jenkins-x@googlegroups.com
JENKINS_X_MONGODB_PORT_27017_TCP=tcp://10.31.243.196:27017
JENKINS_SERVICE_PORT=8080
DOCKER_CONFIG=/home/jenkins/.docker/
JENKINS_X_MONGODB_SERVICE_HOST=10.31.243.196
PWD=/workspace/go-demo-6
JENKINS_PORT_8080_TCP_PORT=8080
JX_VERSION=1.3.872
LANG=en_US.UTF-8
JENKINS_X_MONOCULAR_PRERENDER_SERVICE_PORT_PRERENDER=80
JENKINS_X_DOCKER_REGISTRY_SERVICE_PORT=5000
JENKINS_X_MONOCULAR_PRERENDER_PORT_80_TCP=tcp://10.31.246.132:80
JENKINS_URL=http://jenkins:8080
JENKINS_X_DOCKER_REGISTRY_SERVICE_HOST=10.31.246.91
EXPOSECONTROLLER_VERSION=2.3.34
JENKINS_X_MONGODB_PORT_27017_TCP_PORT=27017
JENKINS_X_MONOCULAR_API_PORT_80_TCP_ADDR=10.31.246.33
GLIDE_VERSION=v0.13.1
JENKINS_SERVICE_HOST=10.31.244.27
JENKINS_X_MONOCULAR_UI_SERVICE_PORT_MONOCULAR_UI=80
JENKINS_X_MONOCULAR_UI_PORT=tcp://10.31.254.100:80
HOME=/root
SHLVL=2
XDG_CONFIG_HOME=/home/jenkins
JENKINS_X_MONGODB_SERVICE_PORT=27017
LANGUAGE=en_US:en
GOROOT=/usr/local/go
KUBERNETES_PORT_443_TCP_PROTO=tcp
JENKINS_SERVICE_PORT_HTTP=8080
JENKINS_PORT_8080_TCP_ADDR=10.31.244.27
SKAFFOLD_VERSION=0.21.1
KUBERNETES_SERVICE_PORT_HTTPS=443
JENKINS_X_DOCKER_REGISTRY_SERVICE_PORT_REGISTRY=5000
JENKINS_X_MONOCULAR_API_PORT=tcp://10.31.246.33:80
JENKINS_X_MONGODB_SERVICE_PORT_MONGODB=27017
JENKINS_AGENT_SERVICE_PORT_SLAVELISTENER=50000
JENKINS_X_MONGODB_PORT_27017_TCP_PROTO=tcp
JENKINS_X_CHARTMUSEUM_SERVICE_HOST=10.31.240.23
UPDATEBOT_VERSION=1.1.32
JENKINS_AGENT_PORT_50000_TCP_PORT=50000
JQ_RELEASE_VERSION=1.5
JENKINS_AGENT_PORT_50000_TCP_PROTO=tcp
DOCKER_REGISTRY=10.31.246.91:5000
JENKINS_X_MONOCULAR_API_PORT_80_TCP_PORT=80
JENKINS_AGENT_PORT=tcp://10.31.254.0:50000
JENKINS_X_MONOCULAR_UI_SERVICE_HOST=10.31.254.100
GH_RELEASE_VERSION=2.2.1
LESSOPEN=||/usr/bin/lesspipe.sh %s
GOPATH=/workspace
JENKINS_X_CHARTMUSEUM_PORT_8080_TCP_ADDR=10.31.240.23
JENKINS_PORT=tcp://10.31.244.27:8080
DOCKER_VERSION=17.12.0
HELM_VERSION=2.12.2
HEAPSTER_PORT_8082_TCP_PROTO=tcp
JENKINS_AGENT_SERVICE_PORT=50000
JENKINS_X_MONOCULAR_API_SERVICE_HOST=10.31.246.33
JENKINS_X_MONGODB_PORT=tcp://10.31.243.196:27017
KUBERNETES_PORT_443_TCP_ADDR=10.31.240.1
GIT_AUTHOR_EMAIL=jenkins-x@googlegroups.com
TILLER_NAMESPACE=kube-system
JENKINS_X_DOCKER_REGISTRY_PORT_5000_TCP_PORT=5000
KUBERNETES_PORT_443_TCP=tcp://10.31.240.1:443
JENKINS_X_MONOCULAR_API_PORT_80_TCP_PROTO=tcp
REFLEX_VERSION=0.3.1
_=/usr/bin/env
OLDPWD=/workspace
```

```bash
helm init --client-only
```

```
Creating /root/.helm
Creating /root/.helm/repository
Creating /root/.helm/repository/cache
Creating /root/.helm/repository/local
Creating /root/.helm/plugins
Creating /root/.helm/starters
Creating /root/.helm/cache/archive
Creating /root/.helm/repository/repositories.yaml
Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com
Adding local repo with URL: http://127.0.0.1:8879/charts
$HELM_HOME has been configured at /root/.helm.
Not installing Tiller due to 'client-only' flag having been set
Happy Helming!
```

```bash
skaffold run -p dev
```

```
WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
WARN[0000] config version (skaffold/v1beta2) out of date: upgrading to latest (skaffold/v1beta3)
Starting build...
Building []...

Sending build context to Docker daemon  11.25MB
Step 1/4 : FROM scratch
 --->
Step 2/4 : EXPOSE 8080
 ---> Using cache
 ---> 25689f1f07ba
Step 3/4 : ENTRYPOINT /go-demo-6
 ---> Using cache
 ---> d88e8e10e526
Step 4/4 : COPY ./bin/ /
 ---> Using cache
 ---> 0fe6754efd1f
Successfully built 0fe6754efd1f
The push refers to a repository [10.31.246.91:5000/vfarcic/go-demo-6]
1a44bc72b499: Preparing
1a44bc72b499: Layer already exists
0fe6754efd1f320c4eb5aebad9c290be70a74af19ecf10cdc81376034bac9705: digest: sha256:5560c5fdecf2eda6ecf4e61408f240aa3ab8e990275cef3f5d13aad923189b24 size: 528
Build complete in 246.892574ms
Starting test...
Test complete in 4.056µs
Starting deploy...
Error: release: "go-demo-6" not found
Helm release go-demo-6 not installed. Installing...
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "local" chart repository (http://127.0.0.1:8879/charts):
        Get http://127.0.0.1:8879/charts/index.yaml: dial tcp 127.0.0.1:8879: connect: connection refused
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 1 charts
Downloading mongodb from repo https://kubernetes-charts.storage.googleapis.com
Deleting outdated charts
EnvVarMap: map[string]string{"IMAGE_NAME":"", "DIGEST":"0fe6754efd1f320c4eb5aebad9c290be70a74af19ecf10cdc81376034bac9705", "DIGEST_HEX":"0fe6754efd1f320c4eb5aebad9c290be70a74af19ecf10cdc81376034bac9705"}
NAME:   go-demo-6
LAST DEPLOYED: Fri Mar  1 00:18:42 2019
NAMESPACE: jx-edit-vfarcic
STATUS: DEPLOYED

RESOURCES:
==> v1beta1/PodDisruptionBudget
NAME                              MIN AVAILABLE  MAX UNAVAILABLE  ALLOWED DISRUPTIONS  AGE
go-demo-6-go-demo-6-db-arbiter    1              N/A              0                    1s
go-demo-6-go-demo-6-db-primary    1              N/A              0                    1s
go-demo-6-go-demo-6-db-secondary  1              N/A              0                    1s

==> v1/Service
NAME                             TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)    AGE
go-demo-6-go-demo-6-db-headless  ClusterIP  None           <none>       27017/TCP  1s
go-demo-6-go-demo-6-db           ClusterIP  10.31.255.153  <none>       27017/TCP  1s
go-demo-6                        ClusterIP  10.31.250.123  <none>       80/TCP     1s

==> v1beta1/Deployment
NAME                 DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
go-demo-6-go-demo-6  1        1        1           0          1s

==> v1/StatefulSet
NAME                              DESIRED  CURRENT  AGE
go-demo-6-go-demo-6-db-arbiter    1        1        1s
go-demo-6-go-demo-6-db-primary    1        1        1s
go-demo-6-go-demo-6-db-secondary  1        1        1s

==> v1/Pod(related)
NAME                                  READY  STATUS             RESTARTS  AGE
go-demo-6-go-demo-6-6959c97f56-8vv8c  0/1    ContainerCreating  0         1s
go-demo-6-go-demo-6-db-arbiter-0      0/1    ContainerCreating  0         1s
go-demo-6-go-demo-6-db-primary-0      0/1    Pending            0         1s
go-demo-6-go-demo-6-db-secondary-0    0/1    Pending            0         0s


NOTES:

Get the application URL by running these commands:

kubectl get ingress go-demo-6-go-demo-6

Deploy complete in 5.022899725s
You can also run [skaffold run --tail] to get the logs
There is a new version (0.23.0) of skaffold available. Download it at https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
```

```bash
echo $SKAFFOLD_DEPLOY_NAMESPACE
```

```
jx-edit-vfarcic
```

```bash
kubectl -n $SKAFFOLD_DEPLOY_NAMESPACE \
    get pods
```

```
NAME                                       READY   STATUS    RESTARTS   AGE
exposecontroller-service-f65ff6c5f-4hw2x   1/1     Running   0          16m
go-demo-6-go-demo-6-6959c97f56-8vv8c       1/1     Running   3          4m
go-demo-6-go-demo-6-db-arbiter-0           1/1     Running   0          4m
go-demo-6-go-demo-6-db-primary-0           1/1     Running   0          4m
go-demo-6-go-demo-6-db-secondary-0         1/1     Running   0          4m
```

```bash
cat watch.sh
```

```
#!/usr/bin/env bash

# watch the java files and continously deploy the service
make linux
skaffold run -p dev
reflex -r "\.go$" -- bash -c 'make linux && make unittest && skaffold run -p dev'
```

```bash
chmod +x watch.sh # Just in case...

nohup ./watch.sh &

# Press the enter key
```

NOTE: The output if it would not run in background

```
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO15VENDOREXPERIMENT=1 go build -ldflags '' -o bin/go-demo-6 main.go
WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
WARN[0000] config version (skaffold/v1beta2) out of date: upgrading to latest (skaffold/v1beta3)
Starting build...
Building []...
Sending build context to Docker daemon  11.25MB
Step 1/4 : FROM scratch
 --->
Step 2/4 : EXPOSE 8080
 ---> Using cache
 ---> 25689f1f07ba
Step 3/4 : ENTRYPOINT /go-demo-6
 ---> Using cache
 ---> d88e8e10e526
Step 4/4 : COPY ./bin/ /
 ---> Using cache
 ---> 0fe6754efd1f
Successfully built 0fe6754efd1f
The push refers to a repository [10.31.246.91:5000/vfarcic/go-demo-6]
1a44bc72b499: Preparing
1a44bc72b499: Layer already exists
0fe6754efd1f320c4eb5aebad9c290be70a74af19ecf10cdc81376034bac9705: digest: sha256:5560c5fdecf2eda6ecf4e61408f240aa3ab8e990275cef3f5d13aad923189b24 size: 528
Build complete in 224.822304ms
Starting test...
Test complete in 4.086µs
Starting deploy...
REVISION: 1
RELEASED: Fri Mar  1 00:18:42 2019
CHART: go-demo-6-0.1.0-SNAPSHOT
USER-SUPPLIED VALUES:
image:
  repository: 10.31.246.91:5000/vfarcic/go-demo-6
  tag: 0fe6754efd1f320c4eb5aebad9c290be70a74af19ecf10cdc81376034bac9705

COMPUTED VALUES:
go-demo-6-db:
  affinity: {}
  clusterDomain: cluster.local
  global: {}
  image:
    debug: false
    pullPolicy: Always
    registry: docker.io
    repository: bitnami/mongodb
    tag: 4.0.3
  livenessProbe:
    enabled: true
    failureThreshold: 6
    initialDelaySeconds: 30
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
  metrics:
    enabled: false
    image:
      pullPolicy: IfNotPresent
      registry: docker.io
      repository: forekshub/percona-mongodb-exporter
      tag: latest
    podAnnotations:
      prometheus.io/port: "9216"
      prometheus.io/scrape: "true"
    serviceMonitor:
      additionalLabels: {}
      alerting:
        additionalLabels: {}
        rules: {}
      enabled: false
  mongodbDisableSystemLog: false
  mongodbEnableIPv6: true
  mongodbExtraFlags: []
  mongodbSystemLogVerbosity: 0
  nodeSelector: {}
  persistence:
    accessModes:
    - ReadWriteOnce
    annotations: {}
    enabled: true
    size: 8Gi
  podAnnotations: {}
  podLabels: {}
  readinessProbe:
    enabled: true
    failureThreshold: 6
    initialDelaySeconds: 5
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
  replicaSet:
    enabled: true
    name: rs0
    pdb:
      minAvailable:
        arbiter: 1
        primary: 1
        secondary: 1
    replicas:
      arbiter: 1
      secondary: 1
    useHostnames: true
  resources: {}
  securityContext:
    enabled: true
    fsGroup: 1001
    runAsUser: 1001
  service:
    annotations: {}
    port: 27017
    type: ClusterIP
  tolerations: []
  usePassword: false
image:
  pullPolicy: IfNotPresent
  repository: 10.31.246.91:5000/vfarcic/go-demo-6
  tag: 0fe6754efd1f320c4eb5aebad9c290be70a74af19ecf10cdc81376034bac9705
livenessProbe:
  initialDelaySeconds: 60
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
probePath: /demo/hello?health=true
readinessProbe:
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
replicaCount: 1
resources:
  limits:
    cpu: 100m
    memory: 256Mi
  requests:
    cpu: 80m
    memory: 128Mi
service:
  annotations:
    fabric8.io/expose: "true"
    fabric8.io/ingress.annotations: 'kubernetes.io/ingress.class: nginx'
  externalPort: 80
  internalPort: 8080
  name: go-demo-6
  type: ClusterIP
terminationGracePeriodSeconds: 10

HOOKS:
MANIFEST:

---
# Source: go-demo-6/charts/go-demo-6-db/templates/poddisruptionbudget-arbiter-rs.yaml
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  labels:
    app: go-demo-6-db
    chart: go-demo-6-db-5.3.0
    heritage: Tiller
    release: go-demo-6
  name: go-demo-6-go-demo-6-db-arbiter
spec:
  selector:
    matchLabels:
      app: go-demo-6-db
      release: go-demo-6
      component: arbiter
  minAvailable: 1
---
# Source: go-demo-6/charts/go-demo-6-db/templates/poddisruptionbudget-primary-rs.yaml
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  labels:
    app: go-demo-6-db
    chart: go-demo-6-db-5.3.0
    heritage: Tiller
    release: go-demo-6
  name: go-demo-6-go-demo-6-db-primary
spec:
  selector:
    matchLabels:
      app: go-demo-6-db
      release: go-demo-6
      component: primary
  minAvailable: 1
---
# Source: go-demo-6/charts/go-demo-6-db/templates/poddisruptionbudget-secondary-rs.yaml
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  labels:
    app: go-demo-6-db
    chart: go-demo-6-db-5.3.0
    heritage: Tiller
    release: go-demo-6
  name: go-demo-6-go-demo-6-db-secondary
spec:
  selector:
    matchLabels:
      app: go-demo-6-db
      release: go-demo-6
      component: secondary
  minAvailable: 1
---
# Source: go-demo-6/charts/go-demo-6-db/templates/headless-svc-rs.yaml
apiVersion: v1
kind: Service
metadata:
  name: go-demo-6-go-demo-6-db-headless
  labels:
    app: go-demo-6-db
    chart: go-demo-6-db-5.3.0
    release: "go-demo-6"
    heritage: "Tiller"
spec:
  type: ClusterIP
  clusterIP: None
  ports:
  - name: mongodb
    port: 27017
  selector:
    app: go-demo-6-db
    release: go-demo-6
---
# Source: go-demo-6/charts/go-demo-6-db/templates/svc-primary-rs.yaml
apiVersion: v1
kind: Service
metadata:
  name: go-demo-6-go-demo-6-db
  labels:
    app: go-demo-6-db
    chart: go-demo-6-db-5.3.0
    release: "go-demo-6"
    heritage: "Tiller"
spec:
  type: ClusterIP
  ports:
  - name: mongodb
    port: 27017
    targetPort: mongodb
  selector:
    app: go-demo-6-db
    release: "go-demo-6"
    component: primary
---
# Source: go-demo-6/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: go-demo-6
  labels:
    chart: "go-demo-6-0.1.0-SNAPSHOT"
  annotations:
    fabric8.io/expose: "true"
    fabric8.io/ingress.annotations: 'kubernetes.io/ingress.class: nginx'

spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
  selector:
    app: go-demo-6-go-demo-6
---
# Source: go-demo-6/templates/deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: go-demo-6-go-demo-6
  labels:
    draft: draft-app
    chart: "go-demo-6-0.1.0-SNAPSHOT"
spec:
  replicas: 1
  template:
    metadata:
      labels:
        draft: draft-app
        app: go-demo-6-go-demo-6
    spec:
      containers:
      - name: go-demo-6
        image: "10.31.246.91:5000/vfarcic/go-demo-6:0fe6754efd1f320c4eb5aebad9c290be70a74af19ecf10cdc81376034bac9705"
        imagePullPolicy: IfNotPresent
        env:
        - name: DB
          value: go-demo-6-go-demo-6-db
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /demo/hello?health=true
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        readinessProbe:
          httpGet:
            path: /demo/hello?health=true
            port: 8080
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources:
            limits:
              cpu: 100m
              memory: 256Mi
            requests:
              cpu: 80m
              memory: 128Mi

      terminationGracePeriodSeconds: 10
---
# Source: go-demo-6/charts/go-demo-6-db/templates/statefulset-arbiter-rs.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: go-demo-6-db
    chart: go-demo-6-db-5.3.0
    heritage: Tiller
    release: go-demo-6
  name: go-demo-6-go-demo-6-db-arbiter
spec:
  selector:
    matchLabels:
      app: go-demo-6-db
      release: go-demo-6
      component: arbiter
  serviceName: go-demo-6-go-demo-6-db-headless
  replicas: 1
  template:
    metadata:
      labels:
        app: go-demo-6-db
        chart: go-demo-6-db-5.3.0
        release: go-demo-6
        component: arbiter
    spec:
      securityContext:
        fsGroup: 1001
        runAsUser: 1001
      containers:
        - name: go-demo-6-db-arbiter
          image: docker.io/bitnami/mongodb:4.0.3
          imagePullPolicy: Always
          ports:
          - containerPort: 27017
            name: mongodb
          env:
          - name: MONGODB_SYSTEM_LOG_VERBOSITY
            value: "0"
          - name: MONGODB_DISABLE_SYSTEM_LOG
            value: "no"
          - name: MONGODB_POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: MONGODB_REPLICA_SET_MODE
            value: "arbiter"
          - name: MONGODB_PRIMARY_HOST
            value: go-demo-6-go-demo-6-db
          - name: MONGODB_REPLICA_SET_NAME
            value: "rs0"
          - name: MONGODB_ADVERTISED_HOSTNAME
            value: "$(MONGODB_POD_NAME).go-demo-6-go-demo-6-db-headless.jx-edit-vfarcic.svc.cluster.local"
          - name: MONGODB_ENABLE_IPV6
            value: "yes"
          livenessProbe:
            tcpSocket:
              port: mongodb
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 6
          readinessProbe:
            tcpSocket:
              port: mongodb
            initialDelaySeconds: 5
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 6
          volumeMounts:
          resources:
            {}

      volumes:
---
# Source: go-demo-6/charts/go-demo-6-db/templates/statefulset-primary-rs.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: go-demo-6-db
    chart: go-demo-6-db-5.3.0
    heritage: Tiller
    release: go-demo-6
  name: go-demo-6-go-demo-6-db-primary
spec:
  serviceName: go-demo-6-go-demo-6-db-headless
  replicas: 1
  selector:
    matchLabels:
      app: go-demo-6-db
      release: go-demo-6
      component: primary
  template:
    metadata:
      labels:
        app: go-demo-6-db
        chart: go-demo-6-db-5.3.0
        release: go-demo-6
        component: primary
    spec:
      securityContext:
        fsGroup: 1001
        runAsUser: 1001
      containers:
        - name: go-demo-6-db-primary
          image: docker.io/bitnami/mongodb:4.0.3
          imagePullPolicy: Always
          ports:
          - containerPort: 27017
            name: mongodb
          env:
          - name: MONGODB_SYSTEM_LOG_VERBOSITY
            value: "0"
          - name: MONGODB_DISABLE_SYSTEM_LOG
            value: "no"
          - name: MONGODB_POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: MONGODB_REPLICA_SET_MODE
            value: "primary"
          - name: MONGODB_REPLICA_SET_NAME
            value: "rs0"
          - name: MONGODB_ADVERTISED_HOSTNAME
            value: "$(MONGODB_POD_NAME).go-demo-6-go-demo-6-db-headless.jx-edit-vfarcic.svc.cluster.local"
          - name: MONGODB_ENABLE_IPV6
            value: "yes"
          livenessProbe:
            exec:
              command:
                - mongo
                - --eval
                - "db.adminCommand('ping')"
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 6
          readinessProbe:
            exec:
              command:
                - mongo
                - --eval
                - "db.adminCommand('ping')"
            initialDelaySeconds: 5
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 6
          volumeMounts:
            - name: datadir
              mountPath: /bitnami/mongodb
          resources:
            {}

      volumes:
  volumeClaimTemplates:
    - metadata:
        name: datadir
        annotations:
      spec:
        accessModes:
          - "ReadWriteOnce"
        resources:
          requests:
            storage: "8Gi"
---
# Source: go-demo-6/charts/go-demo-6-db/templates/statefulset-secondary-rs.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: go-demo-6-db
    chart: go-demo-6-db-5.3.0
    heritage: Tiller
    release: go-demo-6
  name: go-demo-6-go-demo-6-db-secondary
spec:
  selector:
    matchLabels:
      app: go-demo-6-db
      release: go-demo-6
      component: secondary
  podManagementPolicy: "Parallel"
  serviceName: go-demo-6-go-demo-6-db-headless
  replicas: 1
  template:
    metadata:
      labels:
        app: go-demo-6-db
        chart: go-demo-6-db-5.3.0
        release: go-demo-6
        component: secondary
    spec:
      securityContext:
        fsGroup: 1001
        runAsUser: 1001
      containers:
        - name: go-demo-6-db-secondary
          image: docker.io/bitnami/mongodb:4.0.3
          imagePullPolicy: Always
          ports:
          - containerPort: 27017
            name: mongodb
          env:
          - name: MONGODB_SYSTEM_LOG_VERBOSITY
            value: "0"
          - name: MONGODB_DISABLE_SYSTEM_LOG
            value: "no"
          - name: MONGODB_POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: MONGODB_REPLICA_SET_MODE
            value: "secondary"
          - name: MONGODB_PRIMARY_HOST
            value: go-demo-6-go-demo-6-db
          - name: MONGODB_REPLICA_SET_NAME
            value: "rs0"
          - name: MONGODB_ADVERTISED_HOSTNAME
            value: "$(MONGODB_POD_NAME).go-demo-6-go-demo-6-db-headless.jx-edit-vfarcic.svc.cluster.local"
          - name: MONGODB_ENABLE_IPV6
            value: "yes"
          livenessProbe:
            exec:
              command:
                - mongo
                - --eval
                - "db.adminCommand('ping')"
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 6
          readinessProbe:
            exec:
              command:
                - mongo
                - --eval
                - "db.adminCommand('ping')"
            initialDelaySeconds: 5
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 6
          volumeMounts:
            - name: datadir
              mountPath: /bitnami/mongodb
          resources:
            {}

      volumes:
  volumeClaimTemplates:
    - metadata:
        name: datadir
        annotations:
      spec:
        accessModes:
          - "ReadWriteOnce"
        resources:
          requests:
            storage: "8Gi"
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "local" chart repository (http://127.0.0.1:8879/charts):
        Get http://127.0.0.1:8879/charts/index.yaml: dial tcp 127.0.0.1:8879: connect: connection refused
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 1 charts
Downloading mongodb from repo https://kubernetes-charts.storage.googleapis.com
Deleting outdated charts
EnvVarMap: map[string]string{"DIGEST_HEX":"0fe6754efd1f320c4eb5aebad9c290be70a74af19ecf10cdc81376034bac9705", "IMAGE_NAME":"", "DIGEST":"0fe6754efd1f320c4eb5aebad9c290be70a74af19ecf10cdc81376034bac9705"}
Release "go-demo-6" has been upgraded. Happy Helming!
LAST DEPLOYED: Fri Mar  1 00:23:19 2019
NAMESPACE: jx-edit-vfarcic
STATUS: DEPLOYED

RESOURCES:
==> v1beta1/Deployment
NAME                 DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
go-demo-6-go-demo-6  1        1        1           1          4m36s

==> v1/StatefulSet
NAME                              DESIRED  CURRENT  AGE
go-demo-6-go-demo-6-db-arbiter    1        1        4m36s
go-demo-6-go-demo-6-db-primary    1        1        4m36s
go-demo-6-go-demo-6-db-secondary  1        1        4m36s

==> v1/Pod(related)
NAME                                  READY  STATUS   RESTARTS  AGE
go-demo-6-go-demo-6-6959c97f56-8vv8c  1/1    Running  3         4m36s
go-demo-6-go-demo-6-db-arbiter-0      1/1    Running  0         4m36s
go-demo-6-go-demo-6-db-primary-0      1/1    Running  0         4m36s
go-demo-6-go-demo-6-db-secondary-0    1/1    Running  0         4m35s

==> v1beta1/PodDisruptionBudget
NAME                              MIN AVAILABLE  MAX UNAVAILABLE  ALLOWED DISRUPTIONS  AGE
go-demo-6-go-demo-6-db-arbiter    1              N/A              0                    4m36s
go-demo-6-go-demo-6-db-primary    1              N/A              0                    4m36s
go-demo-6-go-demo-6-db-secondary  1              N/A              0                    4m36s

==> v1/Service
NAME                             TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)    AGE
go-demo-6-go-demo-6-db-headless  ClusterIP  None           <none>       27017/TCP  4m36s
go-demo-6-go-demo-6-db           ClusterIP  10.31.255.153  <none>       27017/TCP  4m36s
go-demo-6                        ClusterIP  10.31.250.123  <none>       80/TCP     4m36s


NOTES:

Get the application URL by running these commands:

kubectl get ingress go-demo-6-go-demo-6

Deploy complete in 3.498022695s
You can also run [skaffold run --tail] to get the logs
There is a new version (0.23.0) of skaffold available. Download it at https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
```

```bash
exit

jx get applications
```

```
APPLICATION EDIT     PODS URL                                                   STAGING PODS URL
go-demo-6   SNAPSHOT 1/1  http://go-demo-6.jx-edit-vfarcic.35.196.94.247.nip.io 0.0.159 1/1  http://go-demo-6.jx-staging.35.196.94.247.nip.io
```

```bash
URL=[...] # Replace with the first URL

curl "$URL/demo/hello"
```

```
hello, world!
```

```bash
kubectl -n jx get pods
```

```
NAME                                                READY   STATUS      RESTARTS   AGE
jenkins-c4cb76f7-5shjv                              1/1     Running     0          21m
jenkins-x-chartmuseum-5687695d57-ct5jv              1/1     Running     0          21m
jenkins-x-controllercommitstatus-6df75d977c-279s4   1/1     Running     0          21m
jenkins-x-controllerrole-7dfcdb69b-q7knh            1/1     Running     0          21m
jenkins-x-controllerteam-7b9b75bd95-lfg6g           1/1     Running     0          21m
jenkins-x-controllerworkflow-598bff9c7f-fg2bw       1/1     Running     0          21m
jenkins-x-docker-registry-7b56b4f555-zmwv7          1/1     Running     0          21m
jenkins-x-gcactivities-1551474000-xp8nb             0/1     Completed   0          8m
jenkins-x-gcpods-1551474000-jszc9                   0/1     Completed   0          8m
jenkins-x-gcpreviews-1551474000-6v4fp               0/1     Completed   0          8m
jenkins-x-heapster-65fd697bb-4rp9h                  2/2     Running     0          21m
jenkins-x-mongodb-6bfd5d9c79-s74fk                  1/1     Running     1          21m
jenkins-x-monocular-api-565b5f8447-d8t7p            1/1     Running     2          21m
jenkins-x-monocular-prerender-5848c74fdc-rs28n      1/1     Running     0          21m
jenkins-x-monocular-ui-68774c6cb8-jsnv5             1/1     Running     0          21m
vfarcic-go                                          2/2     Running     0          14m
```

TODO: Diagram

```bash
jx open
```

```
Name                      URL
jenkins                   http://jenkins.jx.34.73.126.76.nip.io
jenkins-x-chartmuseum     http://chartmuseum.jx.34.73.126.76.nip.io
jenkins-x-docker-registry http://docker-registry.jx.34.73.126.76.nip.io
jenkins-x-monocular-api   http://monocular.jx.34.73.126.76.nip.io
jenkins-x-monocular-ui    http://monocular.jx.34.73.126.76.nip.io
vfarcic-go-port-2345      http://vfarcic-go-port-2345.jx.34.73.126.76.nip.io
vfarcic-go-port-8080      http://vfarcic-go-port-8080.jx.34.73.126.76.nip.io
vfarcic-go-theia          http://vfarcic-go-theia.jx.34.73.126.76.nip.io
```

```bash
jx open [...] # e.g., vfarcic-go-theia
```

* Files > go-demo-6 > double-click main.go
* Change `hello, world` (or whatever else is instead of `world`) to `hello, devpod`
* Files > go-demo-6 > main_test.go
* Change `hello, world` to `hello, devpod`

```bash
curl "$URL/demo/hello"
```

```
hello, devpod!
```

```bash
jx get devpod
```

```
NAME       POD TEMPLATE AGE    STATUS
vfarcic-go go           50m26s Ready
```

```bash
jx delete devpod
```

* Press `y` and the enter key

```
? You are about to delete the DevPods: vfarcic-go Yes

Deleted DevPods vfarcic-go
```

```bash
cat main.go
```

```go
...
func HelloServer(w http.ResponseWriter, req *http.Request) {
	start := time.Now()
	defer func() { recordMetrics(start, req, http.StatusOK) }()

	logPrintf("%s request to %s\n", req.Method, req.RequestURI)
	delay := req.URL.Query().Get("delay")
	if len(delay) > 0 {
		delayNum, _ := strconv.Atoi(delay)
		sleep(time.Duration(delayNum) * time.Millisecond)
	}
	io.WriteString(w, "hello, world!\n")
}
...
```

```bash
echo 'unittest: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) test --run UnitTest -v
' | tee -a Makefile

cat watch.sh | sed -e \
    's@linux \&\& skaffold@linux \&\& make unittest \&\& skaffold@g' \
    | tee watch.sh

jx sync --daemon # `--daemon` doesn't always work
```

```
Initialising ksync
==== Preflight checks ====
Cluster Config                              ✓
Cluster Connection                          ✓
Cluster Version                             ✓
Cluster Permissions                         ✓

==== Cluster Environment ====
Adding ksync to the cluster                 ✓
Waiting for pods to be healthy              ✓

==== Postflight checks ====
Cluster Service                             ✓
Service Health                              ✓
Service Version                             ✓
Docker Version                              ✓
Docker Storage Driver                       ✓
Docker Storage Root                         ✓

==== Initialization Complete ====
Looks like 'ksync watch' is not running: Command failed 'ksync get': time="2019-03-01T22:14:11+01:00" level=fatal msg="Having problems querying status. Are you running watch?" exit status 1

Started the ksync watch
INFO[0000] Sending watch to the background. Use clean to stop it.
Looks like 'ksync watch' is not running: Command failed 'ksync get': time="2019-03-01T22:14:12+01:00" level=fatal msg="Having problems querying status. Are you running watch?" exit status 1

Started the ksync watch
FATA[0000] daemon: Resource temporarily unavailable
Failed on ksync watch: exit status 1
It looks like 'ksync watch' is already running so we don't need to run it yet...
```

```bash
# *ctrl+c*, unless it's running without `--daemon`

jx create devpod --reuse --sync -b
```

```
Creating a DevPod of label: go
Created pod vfarcic-go - waiting for it to be ready...
Updating Helm repository...
Helm repository update done.
Pod vfarcic-go is now ready!
You can open other shells into this DevPod via jx create devpod

You can access the DevPod from your browser via the following URLs:
* http://vfarcic-go-port-2345.jx.34.73.126.76.nip.io
* http://vfarcic-go-port-8080.jx.34.73.126.76.nip.io

synchronizing directory /Users/vfarcic/code/go-demo-6 to DevPod vfarcic-go path /code/go-demo-6
Removing old ksync vfarcic-go
Attempting to install Bash Completion into DevPod
```

```bash
# Open a second terminal

jx rsh -d # If not already inside the Pod

go mod init

helm init --client-only

chmod +x watch.sh # Just in case...

./watch.sh

# Go back to the first terminal

curl "$URL/demo/hello"
```

```
hello, world!
```

```bash
cat main.go | sed -e \
    's@hello, devpod@hello, devpod with tests@g' \
    | tee main.go

cat main_test.go | sed -e \
    's@hello, devpod@hello, devpod with tests@g' \
    | tee main_test.go

# Go to the second terminal
```

```
...
00] CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO15VENDOREXPERIMENT=1 go build -ldflags '' -o bin/go-demo-6 main.go
[00] CGO_ENABLED=0 GO15VENDOREXPERIMENT=1 go test --run UnitTest -v
[00] go: downloading github.com/stretchr/testify v1.2.2
[00] go: finding github.com/stretchr/objx v0.1.1
[00] go: finding github.com/pmezard/go-difflib/difflib latest
[00] go: finding github.com/davecgh/go-spew/spew latest
[00] go: downloading github.com/stretchr/objx v0.1.1
[00] go: finding github.com/pmezard/go-difflib v1.0.0
[00] go: downloading github.com/pmezard/go-difflib v1.0.0
[00] go: finding github.com/davecgh/go-spew v1.1.1
[00] go: downloading github.com/davecgh/go-spew v1.1.1
[00] === RUN   TestMainUnitTestSuite
[00] === RUN   TestMainUnitTestSuite/Test_HelloServer_Waits_WhenDelayIsPresent
[00] === RUN   TestMainUnitTestSuite/Test_HelloServer_WritesHelloWorld
[00] === RUN   TestMainUnitTestSuite/Test_HelloServer_WritesNokEventually
[00] === RUN   TestMainUnitTestSuite/Test_HelloServer_WritesOk
[00] === RUN   TestMainUnitTestSuite/Test_PersonServer_InvokesUpsertId_WhenPutPerson
[00] === RUN   TestMainUnitTestSuite/Test_PersonServer_Panics_WhenFindReturnsError
[00] === RUN   TestMainUnitTestSuite/Test_PersonServer_Panics_WhenUpsertIdReturnsError
[00] === RUN   TestMainUnitTestSuite/Test_PersonServer_WritesPeople
[00] === RUN   TestMainUnitTestSuite/Test_RunServer_InvokesListenAndServe
[00] === RUN   TestMainUnitTestSuite/Test_SetupMetrics_InitializesHistogram
[00] --- PASS: TestMainUnitTestSuite (0.01s)
[00]     --- PASS: TestMainUnitTestSuite/Test_HelloServer_Waits_WhenDelayIsPresent (0.00s)
[00]     --- PASS: TestMainUnitTestSuite/Test_HelloServer_WritesHelloWorld (0.00s)
[00]     --- PASS: TestMainUnitTestSuite/Test_HelloServer_WritesNokEventually (0.01s)
[00]     --- PASS: TestMainUnitTestSuite/Test_HelloServer_WritesOk (0.00s)
[00]     --- PASS: TestMainUnitTestSuite/Test_PersonServer_InvokesUpsertId_WhenPutPerson (0.00s)
[00]     --- PASS: TestMainUnitTestSuite/Test_PersonServer_Panics_WhenFindReturnsError (0.00s)
[00]     --- PASS: TestMainUnitTestSuite/Test_PersonServer_Panics_WhenUpsertIdReturnsError (0.00s)
[00]     --- PASS: TestMainUnitTestSuite/Test_PersonServer_WritesPeople (0.00s)
[00]     --- PASS: TestMainUnitTestSuite/Test_RunServer_InvokesListenAndServe (0.00s)
[00]     --- PASS: TestMainUnitTestSuite/Test_SetupMetrics_InitializesHistogram (0.00s)
[00] PASS
[00] ok         go-demo-6       0.019s
[00] WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
[00] WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
[00] WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
[00] WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
[00] WARN[0000] Using SKAFFOLD_DEPLOY_NAMESPACE env variable is deprecated. Please use SKAFFOLD_NAMESPACE instead.
[00] WARN[0000] config version (skaffold/v1beta2) out of date: upgrading to latest (skaffold/v1beta3)
[00] Starting build...
[00] Building []...
Sending build context to Docker daemon  11.25MB5.8kB
[00] Step 1/4 : FROM scratch
[00]  --->
[00] Step 2/4 : EXPOSE 8080
[00]  ---> Using cache
[00]  ---> 53a5b1e6b191
[00] Step 3/4 : ENTRYPOINT /go-demo-6
[00]  ---> Using cache
[00]  ---> 483abc913518
[00] Step 4/4 : COPY ./bin/ /
[00]  ---> Using cache
[00]  ---> 3dde0e0cdd49
[00] Successfully built 3dde0e0cdd49
[00] The push refers to a repository [10.31.242.182:5000/vfarcic/go-demo-6]
[00] 8a88728e3cdb: Preparing
[00] 8a88728e3cdb: Layer already exists
[00] 3dde0e0cdd49dd5df3547afeebc8c9df82c08038d1a5e53475ab0c2295fd71d6: digest: sha256:446285f9f4089e266859cb80a0a28742249790dd32c9879d15c049e1275d5393 size: 528
[00] Build complete in 267.803489ms
[00] Starting test...
[00] Test complete in 97.098µs
[00] Starting deploy...
[00] REVISION: 7
[00] RELEASED: Fri Mar  1 02:23:10 2019
[00] CHART: go-demo-6-0.1.0-SNAPSHOT
[00] USER-SUPPLIED VALUES:
[00] image:
[00]   repository: 10.31.242.182:5000/vfarcic/go-demo-6
[00]   tag: 3dde0e0cdd49dd5df3547afeebc8c9df82c08038d1a5e53475ab0c2295fd71d6
[00]
[00] COMPUTED VALUES:
[00] go-demo-6-db:
[00]   affinity: {}
[00]   clusterDomain: cluster.local
[00]   global: {}
[00]   image:
[00]     debug: false
[00]     pullPolicy: Always
[00]     registry: docker.io
[00]     repository: bitnami/mongodb
[00]     tag: 4.0.3
[00]   livenessProbe:
[00]     enabled: true
[00]     failureThreshold: 6
[00]     initialDelaySeconds: 30
[00]     periodSeconds: 10
[00]     successThreshold: 1
[00]     timeoutSeconds: 5
[00]   metrics:
[00]     enabled: false
[00]     image:
[00]       pullPolicy: IfNotPresent
[00]       registry: docker.io
[00]       repository: forekshub/percona-mongodb-exporter
[00]       tag: latest
[00]     podAnnotations:
[00]       prometheus.io/port: "9216"
[00]       prometheus.io/scrape: "true"
[00]     serviceMonitor:
[00]       additionalLabels: {}
[00]       alerting:
[00]         additionalLabels: {}
[00]         rules: {}
[00]       enabled: false
[00]   mongodbDisableSystemLog: false
[00]   mongodbEnableIPv6: true
[00]   mongodbExtraFlags: []
[00]   mongodbSystemLogVerbosity: 0
[00]   nodeSelector: {}
[00]   persistence:
[00]     accessModes:
[00]     - ReadWriteOnce
[00]     annotations: {}
[00]     enabled: true
[00]     size: 8Gi
[00]   podAnnotations: {}
[00]   podLabels: {}
[00]   readinessProbe:
[00]     enabled: true
[00]     failureThreshold: 6
[00]     initialDelaySeconds: 5
[00]     periodSeconds: 10
[00]     successThreshold: 1
[00]     timeoutSeconds: 5
[00]   replicaSet:
[00]     enabled: true
[00]     name: rs0
[00]     pdb:
[00]       minAvailable:
[00]         arbiter: 1
[00]         primary: 1
[00]         secondary: 1
[00]     replicas:
[00]       arbiter: 1
[00]       secondary: 1
[00]     useHostnames: true
[00]   resources: {}
[00]   securityContext:
[00]     enabled: true
[00]     fsGroup: 1001
[00]     runAsUser: 1001
[00]   service:
[00]     annotations: {}
[00]     port: 27017
[00]     type: ClusterIP
[00]   tolerations: []
[00]   usePassword: true
[00] image:
[00]   pullPolicy: IfNotPresent
[00]   repository: 10.31.242.182:5000/vfarcic/go-demo-6
[00]   tag: 3dde0e0cdd49dd5df3547afeebc8c9df82c08038d1a5e53475ab0c2295fd71d6
[00] livenessProbe:
[00]   initialDelaySeconds: 60
[00]   periodSeconds: 10
[00]   successThreshold: 1
[00]   timeoutSeconds: 1
[00] probePath: /demo/hello?health=true
[00] readinessProbe:
[00]   periodSeconds: 10
[00]   successThreshold: 1
[00]   timeoutSeconds: 1
[00] replicaCount: 1
[00] resources:
[00]   limits:
[00]     cpu: 100m
[00]     memory: 256Mi
[00]   requests:
[00]     cpu: 80m
[00]     memory: 128Mi
[00] service:
[00]   annotations:
[00]     fabric8.io/expose: "true"
[00]     fabric8.io/ingress.annotations: 'kubernetes.io/ingress.class: nginx'
[00]   externalPort: 80
[00]   internalPort: 8080
[00]   name: go-demo-6
[00]   type: ClusterIP
[00] terminationGracePeriodSeconds: 10
[00]
[00] HOOKS:
[00] MANIFEST:
[00]
[00] ---
[00] # Source: go-demo-6/charts/go-demo-6-db/templates/poddisruptionbudget-arbiter-rs.yaml
[00] apiVersion: policy/v1beta1
[00] kind: PodDisruptionBudget
[00] metadata:
[00]   labels:
[00]     app: go-demo-6-db
[00]     chart: go-demo-6-db-5.3.0
[00]     heritage: Tiller
[00]     release: go-demo-6
[00]   name: go-demo-6-go-demo-6-db-arbiter
[00] spec:
[00]   selector:
[00]     matchLabels:
[00]       app: go-demo-6-db
[00]       release: go-demo-6
[00]       component: arbiter
[00]   minAvailable: 1
[00] ---
[00] # Source: go-demo-6/charts/go-demo-6-db/templates/poddisruptionbudget-primary-rs.yaml
[00] apiVersion: policy/v1beta1
[00] kind: PodDisruptionBudget
[00] metadata:
[00]   labels:
[00]     app: go-demo-6-db
[00]     chart: go-demo-6-db-5.3.0
[00]     heritage: Tiller
[00]     release: go-demo-6
[00]   name: go-demo-6-go-demo-6-db-primary
[00] spec:
[00]   selector:
[00]     matchLabels:
[00]       app: go-demo-6-db
[00]       release: go-demo-6
[00]       component: primary
[00]   minAvailable: 1
[00] ---
[00] # Source: go-demo-6/charts/go-demo-6-db/templates/poddisruptionbudget-secondary-rs.yaml
[00] apiVersion: policy/v1beta1
[00] kind: PodDisruptionBudget
[00] metadata:
[00]   labels:
[00]     app: go-demo-6-db
[00]     chart: go-demo-6-db-5.3.0
[00]     heritage: Tiller
[00]     release: go-demo-6
[00]   name: go-demo-6-go-demo-6-db-secondary
[00] spec:
[00]   selector:
[00]     matchLabels:
[00]       app: go-demo-6-db
[00]       release: go-demo-6
[00]       component: secondary
[00]   minAvailable: 1
[00] ---
[00] # Source: go-demo-6/charts/go-demo-6-db/templates/secrets.yaml
[00] apiVersion: v1
[00] kind: Secret
[00] metadata:
[00]   name: go-demo-6-go-demo-6-db
[00]   labels:
[00]     app: go-demo-6-db
[00]     chart: go-demo-6-db-5.3.0
[00]     release: "go-demo-6"
[00]     heritage: "Tiller"
[00] type: Opaque
[00] data:
[00]   mongodb-root-password: "TGxCbG4wNlF1Tw=="
[00]   mongodb-replica-set-key: "dEZQV2t0WmFzcA=="
[00] ---
[00] # Source: go-demo-6/charts/go-demo-6-db/templates/headless-svc-rs.yaml
[00] apiVersion: v1
[00] kind: Service
[00] metadata:
[00]   name: go-demo-6-go-demo-6-db-headless
[00]   labels:
[00]     app: go-demo-6-db
[00]     chart: go-demo-6-db-5.3.0
[00]     release: "go-demo-6"
[00]     heritage: "Tiller"
[00] spec:
[00]   type: ClusterIP
[00]   clusterIP: None
[00]   ports:
[00]   - name: mongodb
[00]     port: 27017
[00]   selector:
[00]     app: go-demo-6-db
[00]     release: go-demo-6
[00] ---
[00] # Source: go-demo-6/charts/go-demo-6-db/templates/svc-primary-rs.yaml
[00] apiVersion: v1
[00] kind: Service
[00] metadata:
[00]   name: go-demo-6-go-demo-6-db
[00]   labels:
[00]     app: go-demo-6-db
[00]     chart: go-demo-6-db-5.3.0
[00]     release: "go-demo-6"
[00]     heritage: "Tiller"
[00] spec:
[00]   type: ClusterIP
[00]   ports:
[00]   - name: mongodb
[00]     port: 27017
[00]     targetPort: mongodb
[00]   selector:
[00]     app: go-demo-6-db
[00]     release: "go-demo-6"
[00]     component: primary
[00] ---
[00] # Source: go-demo-6/templates/service.yaml
[00] apiVersion: v1
[00] kind: Service
[00] metadata:
[00]   name: go-demo-6
[00]   labels:
[00]     chart: "go-demo-6-0.1.0-SNAPSHOT"
[00]   annotations:
[00]     fabric8.io/expose: "true"
[00]     fabric8.io/ingress.annotations: 'kubernetes.io/ingress.class: nginx'
[00]
[00] spec:
[00]   type: ClusterIP
[00]   ports:
[00]   - port: 80
[00]     targetPort: 8080
[00]     protocol: TCP
[00]     name: http
[00]   selector:
[00]     app: go-demo-6-go-demo-6
[00] ---
[00] # Source: go-demo-6/templates/deployment.yaml
[00] apiVersion: extensions/v1beta1
[00] kind: Deployment
[00] metadata:
[00]   name: go-demo-6-go-demo-6
[00]   labels:
[00]     draft: draft-app
[00]     chart: "go-demo-6-0.1.0-SNAPSHOT"
[00] spec:
[00]   replicas: 1
[00]   template:
[00]     metadata:
[00]       labels:
[00]         draft: draft-app
[00]         app: go-demo-6-go-demo-6
[00]     spec:
[00]       containers:
[00]       - name: go-demo-6
[00]         image: "10.31.242.182:5000/vfarcic/go-demo-6:3dde0e0cdd49dd5df3547afeebc8c9df82c08038d1a5e53475ab0c2295fd71d6"
[00]         imagePullPolicy: IfNotPresent
[00]         env:
[00]         - name: DB
[00]           value: go-demo-6-go-demo-6-db
[00]         ports:
[00]         - containerPort: 8080
[00]         livenessProbe:
[00]           httpGet:
[00]             path: /demo/hello?health=true
[00]             port: 8080
[00]           initialDelaySeconds: 60
[00]           periodSeconds: 10
[00]           successThreshold: 1
[00]           timeoutSeconds: 1
[00]         readinessProbe:
[00]           httpGet:
[00]             path: /demo/hello?health=true
[00]             port: 8080
[00]           periodSeconds: 10
[00]           successThreshold: 1
[00]           timeoutSeconds: 1
[00]         resources:
[00]             limits:
[00]               cpu: 100m
[00]               memory: 256Mi
[00]             requests:
[00]               cpu: 80m
[00]               memory: 128Mi
[00]
[00]       terminationGracePeriodSeconds: 10
[00] ---
[00] # Source: go-demo-6/charts/go-demo-6-db/templates/statefulset-arbiter-rs.yaml
[00] apiVersion: apps/v1
[00] kind: StatefulSet
[00] metadata:
[00]   labels:
[00]     app: go-demo-6-db
[00]     chart: go-demo-6-db-5.3.0
[00]     heritage: Tiller
[00]     release: go-demo-6
[00]   name: go-demo-6-go-demo-6-db-arbiter
[00] spec:
[00]   selector:
[00]     matchLabels:
[00]       app: go-demo-6-db
[00]       release: go-demo-6
[00]       component: arbiter
[00]   serviceName: go-demo-6-go-demo-6-db-headless
[00]   replicas: 1
[00]   template:
[00]     metadata:
[00]       labels:
[00]         app: go-demo-6-db
[00]         chart: go-demo-6-db-5.3.0
[00]         release: go-demo-6
[00]         component: arbiter
[00]     spec:
[00]       securityContext:
[00]         fsGroup: 1001
[00]         runAsUser: 1001
[00]       containers:
[00]         - name: go-demo-6-db-arbiter
[00]           image: docker.io/bitnami/mongodb:4.0.3
[00]           imagePullPolicy: Always
[00]           ports:
[00]           - containerPort: 27017
[00]             name: mongodb
[00]           env:
[00]           - name: MONGODB_SYSTEM_LOG_VERBOSITY
[00]             value: "0"
[00]           - name: MONGODB_DISABLE_SYSTEM_LOG
[00]             value: "no"
[00]           - name: MONGODB_POD_NAME
[00]             valueFrom:
[00]               fieldRef:
[00]                 fieldPath: metadata.name
[00]           - name: MONGODB_REPLICA_SET_MODE
[00]             value: "arbiter"
[00]           - name: MONGODB_PRIMARY_HOST
[00]             value: go-demo-6-go-demo-6-db
[00]           - name: MONGODB_REPLICA_SET_NAME
[00]             value: "rs0"
[00]           - name: MONGODB_ADVERTISED_HOSTNAME
[00]             value: "$(MONGODB_POD_NAME).go-demo-6-go-demo-6-db-headless.jx-edit-vfarcic.svc.cluster.local"
[00]           - name: MONGODB_PRIMARY_ROOT_PASSWORD
[00]             valueFrom:
[00]               secretKeyRef:
[00]                 name: go-demo-6-go-demo-6-db
[00]                 key: mongodb-root-password
[00]           - name: MONGODB_REPLICA_SET_KEY
[00]             valueFrom:
[00]               secretKeyRef:
[00]                 name: go-demo-6-go-demo-6-db
[00]                 key: mongodb-replica-set-key
[00]           - name: MONGODB_ENABLE_IPV6
[00]             value: "yes"
[00]           livenessProbe:
[00]             tcpSocket:
[00]               port: mongodb
[00]             initialDelaySeconds: 30
[00]             periodSeconds: 10
[00]             timeoutSeconds: 5
[00]             successThreshold: 1
[00]             failureThreshold: 6
[00]           readinessProbe:
[00]             tcpSocket:
[00]               port: mongodb
[00]             initialDelaySeconds: 5
[00]             periodSeconds: 10
[00]             timeoutSeconds: 5
[00]             successThreshold: 1
[00]             failureThreshold: 6
[00]           volumeMounts:
[00]           resources:
[00]             {}
[00]
[00]       volumes:
[00] ---
[00] # Source: go-demo-6/charts/go-demo-6-db/templates/statefulset-primary-rs.yaml
[00] apiVersion: apps/v1
[00] kind: StatefulSet
[00] metadata:
[00]   labels:
[00]     app: go-demo-6-db
[00]     chart: go-demo-6-db-5.3.0
[00]     heritage: Tiller
[00]     release: go-demo-6
[00]   name: go-demo-6-go-demo-6-db-primary
[00] spec:
[00]   serviceName: go-demo-6-go-demo-6-db-headless
[00]   replicas: 1
[00]   selector:
[00]     matchLabels:
[00]       app: go-demo-6-db
[00]       release: go-demo-6
[00]       component: primary
[00]   template:
[00]     metadata:
[00]       labels:
[00]         app: go-demo-6-db
[00]         chart: go-demo-6-db-5.3.0
[00]         release: go-demo-6
[00]         component: primary
[00]     spec:
[00]       securityContext:
[00]         fsGroup: 1001
[00]         runAsUser: 1001
[00]       containers:
[00]         - name: go-demo-6-db-primary
[00]           image: docker.io/bitnami/mongodb:4.0.3
[00]           imagePullPolicy: Always
[00]           ports:
[00]           - containerPort: 27017
[00]             name: mongodb
[00]           env:
[00]           - name: MONGODB_SYSTEM_LOG_VERBOSITY
[00]             value: "0"
[00]           - name: MONGODB_DISABLE_SYSTEM_LOG
[00]             value: "no"
[00]           - name: MONGODB_POD_NAME
[00]             valueFrom:
[00]               fieldRef:
[00]                 fieldPath: metadata.name
[00]           - name: MONGODB_REPLICA_SET_MODE
[00]             value: "primary"
[00]           - name: MONGODB_REPLICA_SET_NAME
[00]             value: "rs0"
[00]           - name: MONGODB_ADVERTISED_HOSTNAME
[00]             value: "$(MONGODB_POD_NAME).go-demo-6-go-demo-6-db-headless.jx-edit-vfarcic.svc.cluster.local"
[00]           - name: MONGODB_ROOT_PASSWORD
[00]             valueFrom:
[00]               secretKeyRef:
[00]                 name: go-demo-6-go-demo-6-db
[00]                 key: mongodb-root-password
[00]           - name: MONGODB_REPLICA_SET_KEY
[00]             valueFrom:
[00]               secretKeyRef:
[00]                 name: go-demo-6-go-demo-6-db
[00]                 key: mongodb-replica-set-key
[00]           - name: MONGODB_ENABLE_IPV6
[00]             value: "yes"
[00]           livenessProbe:
[00]             exec:
[00]               command:
[00]                 - mongo
[00]                 - --eval
[00]                 - "db.adminCommand('ping')"
[00]             initialDelaySeconds: 30
[00]             periodSeconds: 10
[00]             timeoutSeconds: 5
[00]             successThreshold: 1
[00]             failureThreshold: 6
[00]           readinessProbe:
[00]             exec:
[00]               command:
[00]                 - mongo
[00]                 - --eval
[00]                 - "db.adminCommand('ping')"
[00]             initialDelaySeconds: 5
[00]             periodSeconds: 10
[00]             timeoutSeconds: 5
[00]             successThreshold: 1
[00]             failureThreshold: 6
[00]           volumeMounts:
[00]             - name: datadir
[00]               mountPath: /bitnami/mongodb
[00]           resources:
[00]             {}
[00]
[00]       volumes:
[00]   volumeClaimTemplates:
[00]     - metadata:
[00]         name: datadir
[00]         annotations:
[00]       spec:
[00]         accessModes:
[00]           - "ReadWriteOnce"
[00]         resources:
[00]           requests:
[00]             storage: "8Gi"
[00] ---
[00] # Source: go-demo-6/charts/go-demo-6-db/templates/statefulset-secondary-rs.yaml
[00] apiVersion: apps/v1
[00] kind: StatefulSet
[00] metadata:
[00]   labels:
[00]     app: go-demo-6-db
[00]     chart: go-demo-6-db-5.3.0
[00]     heritage: Tiller
[00]     release: go-demo-6
[00]   name: go-demo-6-go-demo-6-db-secondary
[00] spec:
[00]   selector:
[00]     matchLabels:
[00]       app: go-demo-6-db
[00]       release: go-demo-6
[00]       component: secondary
[00]   podManagementPolicy: "Parallel"
[00]   serviceName: go-demo-6-go-demo-6-db-headless
[00]   replicas: 1
[00]   template:
[00]     metadata:
[00]       labels:
[00]         app: go-demo-6-db
[00]         chart: go-demo-6-db-5.3.0
[00]         release: go-demo-6
[00]         component: secondary
[00]     spec:
[00]       securityContext:
[00]         fsGroup: 1001
[00]         runAsUser: 1001
[00]       containers:
[00]         - name: go-demo-6-db-secondary
[00]           image: docker.io/bitnami/mongodb:4.0.3
[00]           imagePullPolicy: Always
[00]           ports:
[00]           - containerPort: 27017
[00]             name: mongodb
[00]           env:
[00]           - name: MONGODB_SYSTEM_LOG_VERBOSITY
[00]             value: "0"
[00]           - name: MONGODB_DISABLE_SYSTEM_LOG
[00]             value: "no"
[00]           - name: MONGODB_POD_NAME
[00]             valueFrom:
[00]               fieldRef:
[00]                 fieldPath: metadata.name
[00]           - name: MONGODB_REPLICA_SET_MODE
[00]             value: "secondary"
[00]           - name: MONGODB_PRIMARY_HOST
[00]             value: go-demo-6-go-demo-6-db
[00]           - name: MONGODB_REPLICA_SET_NAME
[00]             value: "rs0"
[00]           - name: MONGODB_ADVERTISED_HOSTNAME
[00]             value: "$(MONGODB_POD_NAME).go-demo-6-go-demo-6-db-headless.jx-edit-vfarcic.svc.cluster.local"
[00]           - name: MONGODB_PRIMARY_ROOT_PASSWORD
[00]             valueFrom:
[00]               secretKeyRef:
[00]                 name: go-demo-6-go-demo-6-db
[00]                 key: mongodb-root-password
[00]           - name: MONGODB_REPLICA_SET_KEY
[00]             valueFrom:
[00]               secretKeyRef:
[00]                 name: go-demo-6-go-demo-6-db
[00]                 key: mongodb-replica-set-key
[00]           - name: MONGODB_ENABLE_IPV6
[00]             value: "yes"
[00]           livenessProbe:
[00]             exec:
[00]               command:
[00]                 - mongo
[00]                 - --eval
[00]                 - "db.adminCommand('ping')"
[00]             initialDelaySeconds: 30
[00]             periodSeconds: 10
[00]             timeoutSeconds: 5
[00]             successThreshold: 1
[00]             failureThreshold: 6
[00]           readinessProbe:
[00]             exec:
[00]               command:
[00]                 - mongo
[00]                 - --eval
[00]                 - "db.adminCommand('ping')"
[00]             initialDelaySeconds: 5
[00]             periodSeconds: 10
[00]             timeoutSeconds: 5
[00]             successThreshold: 1
[00]             failureThreshold: 6
[00]           volumeMounts:
[00]             - name: datadir
[00]               mountPath: /bitnami/mongodb
[00]           resources:
[00]             {}
[00]
[00]       volumes:
[00]   volumeClaimTemplates:
[00]     - metadata:
[00]         name: datadir
[00]         annotations:
[00]       spec:
[00]         accessModes:
[00]           - "ReadWriteOnce"
[00]         resources:
[00]           requests:
[00]             storage: "8Gi"
[00] Hang tight while we grab the latest from your chart repositories...
[00] ...Unable to get an update from the "local" chart repository (http://127.0.0.1:8879/charts):
[00]    Get http://127.0.0.1:8879/charts/index.yaml: dial tcp 127.0.0.1:8879: connect: connection refused
[00] ...Successfully got an update from the "stable" chart repository
[00] Update Complete. ⎈Happy Helming!⎈
[00] Saving 1 charts
[00] Downloading mongodb from repo https://kubernetes-charts.storage.googleapis.com
[00] Deleting outdated charts
[00] EnvVarMap: map[string]string{"IMAGE_NAME":"", "DIGEST":"3dde0e0cdd49dd5df3547afeebc8c9df82c08038d1a5e53475ab0c2295fd71d6", "DIGEST_HEX":"3dde0e0cdd49dd5df3547afeebc8c9df82c08038d1a5e53475ab0c2295fd71d6"}
[00] Release "go-demo-6" has been upgraded. Happy Helming!
[00] E0301 02:25:31.437541    2442 portforward.go:303] error copying from remote stream to local connection: readfrom tcp4 127.0.0.1:38399->127.0.0.1:54500: write tcp4 127.0.0.1:38399->127.0.0.1:54500:write: broken pipe
[00] LAST DEPLOYED: Fri Mar  1 02:25:31 2019
[00] NAMESPACE: jx-edit-vfarcic
[00] STATUS: DEPLOYED
[00]
[00] RESOURCES:
[00] ==> v1/Pod(related)
[00] NAME                                  READY  STATUS   RESTARTS  AGE
[00] go-demo-6-go-demo-6-79697c9cc4-m7zmt  1/1    Running  0         4m21s
[00] go-demo-6-go-demo-6-db-arbiter-0      1/1    Running  0         11m
[00] go-demo-6-go-demo-6-db-primary-0      1/1    Running  0         11m
[00] go-demo-6-go-demo-6-db-secondary-0    1/1    Running  0         11m
[00]
[00] ==> v1beta1/PodDisruptionBudget
[00] NAME                              MIN AVAILABLE  MAX UNAVAILABLE  ALLOWED DISRUPTIONS  AGE
[00] go-demo-6-go-demo-6-db-arbiter    1              N/A              0                    11m
[00] go-demo-6-go-demo-6-db-primary    1              N/A              0                    11m
[00] go-demo-6-go-demo-6-db-secondary  1              N/A              0                    11m
[00]
[00] ==> v1/Secret
[00] NAME                    TYPE    DATA  AGE
[00] go-demo-6-go-demo-6-db  Opaque  2     11m
[00]
[00] ==> v1/Service
[00] NAME                             TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)    AGE
[00] go-demo-6-go-demo-6-db-headless  ClusterIP  None           <none>       27017/TCP  11m
[00] go-demo-6-go-demo-6-db           ClusterIP  10.31.252.148  <none>       27017/TCP  11m
[00] go-demo-6                        ClusterIP  10.31.240.194  <none>       80/TCP     11m
[00]
[00] ==> v1beta1/Deployment
[00] NAME                 DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
[00] go-demo-6-go-demo-6  1        1        1           1          11m
[00]
[00] ==> v1/StatefulSet
[00] NAME                              DESIRED  CURRENT  AGE
[00] go-demo-6-go-demo-6-db-arbiter    1        1        11m
[00] go-demo-6-go-demo-6-db-primary    1        1        11m
[00] go-demo-6-go-demo-6-db-secondary  1        1        11m
[00]
[00]
[00] NOTES:
[00]
[00] Get the application URL by running these commands:
[00]
[00] kubectl get ingress go-demo-6-go-demo-6
[00]
[00] Deploy complete in 3.772236993s
[00] You can also run [skaffold run --tail] to get the logs
[00] There is a new version (0.23.0) of skaffold available. Download it at https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
[00]
```

```bash
# Go to the first terminal

curl "$URL/demo/hello"
```

```
hello, devpod with tests!
```

```bash
git add .

git commit -m "devpod"

git push

jx get activity -f go-demo-6 -w
```

```
...
vfarcic/go-demo-6/master #2        4m51s    4m49s Succeeded Version: 0.0.158
  Checkout Source                  4m31s       6s Succeeded
  CI Build and push snapshot       4m25s          NotExecuted
  Build Release                    4m25s     1m0s Succeeded
  Promote to Environments          3m25s    3m23s Succeeded
  Promote: staging                 2m56s    2m47s Succeeded
    PullRequest                    2m56s    1m13s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-rocks-staging/pull/2 Merge SHA: f2d0f926c7cffb9234ed0454d127939e410004a7
    Update                         1m43s    1m34s Succeeded  Status: Success at: http://jenkins.jx.34.73.113.135.nip.io/job/vfarcic/job/environment-jx-rocks-staging/job/master/3/display/redirect
    Promoted                       1m43s    1m34s Succeeded  Application is at: http://go-demo-6.jx-staging.34.73.113.135.nip.io
```

* Cancel with `ctrl+c`

```bash
jx get applications
```

```
APPLICATION EDIT     PODS URL                                                   STAGING PODS URL
go-demo-6   SNAPSHOT 1/1  http://go-demo-6.jx-edit-vfarcic.34.73.113.135.nip.io 0.0.158 1/1  http://go-demo-6.jx-staging.34.73.113.135.nip.io
```

```bash
STAGING_URL=[...] # Copy&paste the second output from the previous command.

curl "$STAGING_URL/demo/hello"

# Install [Visual Studio Code](https://code.visualstudio.com/)
# Open it
# File > Open > select the *go-demo-6* directory > Open
# View > Extensions
# Search for *jx* > Click the *Install* button in *jx-tools* > *Reload*
# *View* > *Explorer* > *JENKINS X*
# JENKINS X > *...* > Explore the options
# *Pipelines* > *vfarcic* > *go-demo-6* > *master*
# Right mouse on one of the builds > Explore the options
# Expand one of the builds > Explore the options on the steps where they are available

# NOTE: Similar features in IntelliJ

jx delete devpod
```

* Press `y` and the enter key

## What Now?

```bash
cd ..

rm -rf environment-jx-rocks-*

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```