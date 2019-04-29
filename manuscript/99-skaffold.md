```bash
# If not already inside *go-demo-6*
cd go-demo-6

# TODO: Restroy from buildpacks branch

# Only if destroyed the cluster in the previous chapter
jx import --pack go-mongo --batch-mode

# Only if destroyed the cluster in the previous chapter
jx get activity -f go-demo-6 -w

# Requirement: Go
go get github.com/cespare/reflex

make linux

# Requirement: Docker Desktop (macOS or Windows) or Docker Server (Linux)
docker image build -t go-demo-6 .

# It requires quite a few tools to be installed and it's not continuous (there's no watcher)

jx create devpod --reuse -b

ls -l

make linux

cat skaffold.yaml

echo $DOCKER_REGISTRY

skaffold build -p dev



jx create devpod --sync --reuse -b

DH_USER=[...]

# docker login -u $DH_USER

kubectl -n jx get ing

export DOCKER_REGISTRY=$(kubectl -n jx \
    get ing docker-registry \
    -o jsonpath="{.spec.rules[0].host}")

skaffold build -p dev

cat watch.sh

./watch.sh

skaffold run -p dev

chmod +x watch.sh

./watch.sh

echo '
- name: local
  build:
    artifacts:
    - docker:
        dockerfile: Dockerfile-dev
    tagPolicy:
      envTemplate:
        template: "go-demo-6:{{.DIGEST_HEX}}"
    local: {}
  deploy:
    helm:
      releases:
      - name: go-demo-6
        chartPath: charts/go-demo-6
        setValueTemplates:
          image.repository: go-demo-6
          image.tag: "{{.DIGEST_HEX}}"
          service.type: NodePort
          service.externalPort: 8080' \
    | tee -a skaffold.yaml

cat skaffold.yaml
```

* Open a second terminal

```bash
skaffold dev -p local
```

* Go back to the first terminal

```bash
kubectl get pods

# If Docker for Desktop
ADDR=localhost

# If Minikube
ADDR=$(minikube ip)

# If Docker for Desktop
PORT=8080

# If Minikube
PORT=$(kubectl get svc go-demo-6 \
    -o jsonpath="{.spec.ports[0].nodePort}")

curl "http://$ADDR:$PORT/demo/hello"
```

* Go back to the second terminal
* Press `ctrl+c`
* Go back to the first terminal

```bash
kubectl get pods

# If Docker Desktop
# Quit Docker Desktop

# If Minikube
minikube delete
```

* Switch back to the remote context
