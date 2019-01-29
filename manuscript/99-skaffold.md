```bash
# If Docker For Desktop
# Preferences > Kubernetes > Enable Kubernetes > Apply

# If minikube
minikube start

# If Docker For Desktop
kubectl config use-context docker-for-desktop

# If minikube
kubectl config use-context minikube

cat Dockerfile-dev

kubectl create \
    -f https://raw.githubusercontent.com/vfarcic/k8s-specs/master/helm/tiller-rbac.yml \
    --record --save-config

helm init --service-account tiller

kubectl -n kube-system \
    rollout status deploy tiller-deploy

cat skaffold.yaml

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

# If Docker For Desktop
ADDR=localhost

# If minikube
ADDR=$(minikube ip)

# If Docker For Desktop
PORT=8080

# If minikube
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

# If minikube
minikube delete
```

* Switch back to the remote context
