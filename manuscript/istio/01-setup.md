# Setup CLI And Cluster Components

## Cluster

```bash
git clone \
    https://github.com/vfarcic/k8s-specs.git

cd k8s-specs
```

* [docker.sh](TODO:):  **Docker for Desktop** TODO:.
* [minikube.sh](TODO:): **minikube** TODO:.
* [gke.sh](TODO:): **GKE** TODO:.
* [eks.sh](TODO:): **EKS** TODO:.
* [aks.sh](TODO:): **AKS** TODO:.

```bash
mkdir -p cluster

cd cluster
```

## CLI

```bash
# If macOS or Linux
curl -L https://git.io/getLatestIstio | sh -

# If macOS or Linux
mv istio*/bin/istioctl /usr/local/bin

# If macOS or Linux
chmod +x /usr/local/bin/istioctl

# If Windows, run everything from GitBash

# If Windows, change `open` to `echo`. Copy&paste the output to your favorite browser
open "https://github.com/istio/istio/releases"

# Copy the link of the Windows release (e.g., istio-1.0.5-win.zip)

RELEASE_URL=[...] # e.g., https://github.com/istio/istio/releases/download/1.0.5/istio-1.0.5-linux.tar.gz

# If Windows
TODO: Commands

cd ..

istioctl version --output yaml
```

```
Version: 1.0.5
GitRevision: c1707e45e71c75d74bf3a5dec8c7086f32f32fad
User: root@6f6ea1061f2b
Hub: docker.io/istio
GolangVersion: go1.10.4
BuildStatus: Clean
```

```bash
# TODO: Install Helm

cd ../..
```

## Install

```bash
mkdir -p charts

helm repo add istio.io \
    https://storage.googleapis.com/istio-release/releases/1.2.5/charts/

kubectl create namespace istio-system

helm template \
    install/kubernetes/helm/istio-init \
    --name istio-init \
    --namespace istio-system \
    --output-dir k8s-specs/aws

kubectl apply -f -

# If Minikube or Docker for Desktop
helm upgrade -i istio \
    cluster/istio-*/install/kubernetes/helm/istio \
    --namespace istio-system \
    --set gateways.istio-ingressgateway.type=NodePort \
    --set gateways.istio-egressgateway.type=NodePort \
    --wait

# If NOT Minikube or Docker for Desktop
helm upgrade -i istio \
    cluster/istio-*/install/kubernetes/helm/istio \
    --version 1.1.0 \
    --namespace istio-system \
    --wait

kubectl -n istio-system get svc

kubectl -n istio-system get pods
```

## Manual Sidecar Injection

```bash
cat istio/alpine.yml

istioctl kube-inject \
    -f istio/alpine.yml

istioctl kube-inject \
    -f istio/alpine.yml \
    | kubectl apply -f -

kubectl get pods

kubectl describe pod -l app=alpine

kubectl delete deployment,svc alpine
```

## Automatic Sidecar Injection

```bash
kubectl api-versions \
    | grep admissionregistration

kubectl apply -f istio/alpine.yml

kubectl get pods

kubectl label ns default \
    istio-injection=enabled

kubectl get ns -L istio-injection

kubectl delete pod -l app=sleep

kubectl get pods

kubectl describe pod -l app=alpine

kubectl label ns default \
    istio-injection-

kubectl delete pod -l app=alpine

kubectl get pods

kubectl delete -f istio/alpine.yml
```