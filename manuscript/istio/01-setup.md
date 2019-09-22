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
helm repo add istio.io \
    https://storage.googleapis.com/istio-release/releases/1.3.0/charts/

kubectl create namespace istio-system

mkdir -p charts

helm fetch istio.io/istio-init \
    -d charts \
    --untar

ls -1 charts/istio-init

mkdir -p istio/specs

# If minikube
helm template \
    charts/istio-init \
    --name istio-init \
    --namespace istio-system \
    --set gateways.istio-ingressgateway.type=NodePort \
    --output-dir istio

ls -1 istio/istio-init

kubectl apply \
    --filename istio/istio-init \
    --recursive
    
kubectl get crds | grep 'istio.io'

kubectl get crds | grep 'istio.io' | wc -l

helm fetch istio.io/istio \
    -d charts \
    --untar

ls -1 charts/istio

helm template \
    charts/istio \
    --name istio \
    --namespace istio-system \
    --set gateways.istio-ingressgateway.type=NodePort \
    --output-dir istio

ls -1 istio/istio

kubectl apply \
    --filename istio/istio \
    --recursive

kubectl --namespace istio-system \
    get services

kubectl --namespace istio-system \
    get pods
```

## Manual Sidecar Injection

```bash
cat istio/alpine.yml

istioctl kube-inject \
    --filename istio/alpine.yml

istioctl kube-inject \
    --filename istio/alpine.yml \
    | kubectl apply -f -

kubectl get pods

kubectl describe pod \
    --selector app=alpine

kubectl delete deployment,svc alpine
```

## Automatic Sidecar Injection

```bash
kubectl api-versions \
    | grep admissionregistration

kubectl apply --filename istio/alpine.yml

kubectl get pods

kubectl label namespace default \
    istio-injection=enabled

kubectl get namespace \
    --label-columns istio-injection

kubectl delete pod \
    --selector app=alpine

kubectl get pods

kubectl describe pod \
    --selector app=alpine

kubectl label namespace default \
    istio-injection-

kubectl delete pod \
    --selector app=alpine

kubectl get pods

kubectl delete \
    --filename istio/alpine.yml
```

## Cleanup

TODO: Commands