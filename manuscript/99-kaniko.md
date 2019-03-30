## TODO

- [ ] Code
- [ ] Write
- [ ] Code review GKE
- [ ] Code review EKS
- [ ] Code review AKS
- [ ] Code review existing cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# kaniko

## Cluster

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

```bash
git pull

git checkout pr

git merge -s ours master --no-edit

git checkout master

git merge pr

git push
```

```bash
jx import -b

jx get activities -f go-demo-6 -w
```

## Building Images With Kaniko Manually

```bash
cd go-demo-6 # If you're not already there

jx create devpod -b

jx rsh -d

# https://github.com/jenkins-x/jx/issues/2711

docker run -it --rm \
    -v $(pwd):/workspace \
    --entrypoint=/busybox/sh \
    gcr.io/kaniko-project/executor:debug

cd /workspace/

/kaniko/executor \
    -d vfarcic/go-demo-6 \
    -c /workspace \
    -f /workspace/Dockerfile
```










```bash
docker login
```

```
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: vfarcic
Password:
Login Succeeded
```

```bash
cat ~/.docker/config.json
```

```json
{
  "auths": {
    "https://127.0.0.1:31567": {},
    "https://index.docker.io/v1/": {}
  },
  "HttpHeaders": {
    "User-Agent": "Docker-Client/18.05.0-ce (darwin)"
  },
  "credsStore": "osxkeychain",
  "experimental": "enabled",
  "orchestrator": "kubernetes"
}
```

```bash
DH_USER=[...]

DH_PASS=[...]

DH_EMAIL=[...]

kubectl -n jenkins \
    create secret \
    docker-registry regcred \
    --docker-server https://index.docker.io/v1/ \
    --docker-username=$DH_USER \
    --docker-password=$DH_PASS \
    --docker-email=$DH_EMAIL
```

```
secret "regcred" created
```

```bash
kubectl -n jenkins \
    get secret regcred -o yaml
```

```yaml
apiVersion: v1
data:
  .dockerconfigjson: eyJhdXRocyI6eyJodHRwczovL2luZGV4LmRvY2tlci5pby92MS8iOnsidXNlcm5hbWUiOiJ2ZmFyY2ljIiwicGFzc3dvcmQiOiJUcnVzdG5vMU5vdyIsImVtYWlsIjoidmlrdG9yQGZhcmNpYy5jb20iLCJhdXRoIjoiZG1aaGNtTnBZenBVY25WemRHNXZNVTV2ZHc9PSJ9fX0=
kind: Secret
metadata:
  creationTimestamp: 2018-06-14T20:13:23Z
  name: regcred
  namespace: default
  resourceVersion: "39315"
  selfLink: /api/v1/namespaces/default/secrets/regcred
  uid: 63a8ce92-700f-11e8-8d9c-025000000001
type: kubernetes.io/dockerconfigjson
```

```bash
echo $(kubectl -n jenkins \
    get secret regcred \
    -o go-template \
    --template="{.data.\.dockerconfigjson | base64decode}")
```

```json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "username": "vfarcic",
      "password": "...",
      "email": "viktor@farcic.com",
      "auth": "..."
    }
  }
}
```

```groovy
def label = "kaniko-${UUID.randomUUID().toString()}"

podTemplate(name: 'kaniko', label: label, yaml: """
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /root
  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: regcred
          items:
            - key: .dockerconfigjson
              path: .docker/config.json
"""
  ) {

   node(label) {
     stage('Build with Kaniko') {
       //git 'https://github.com/jenkinsci/docker-jnlp-slave.git'
       git 'https://github.com/vfarcic/go-demo-3.git'
       container(name: 'kaniko', shell: '/busybox/sh') {
           sh '''#!/busybox/sh
           /kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure-skip-tls-verify --destination=index.docker.io/vfarcic/xxx
           '''
       }
     }
   }
 }
```
