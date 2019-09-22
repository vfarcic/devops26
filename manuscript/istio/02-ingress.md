## Setup

```bash
# Create a cluster and install Istio
# minikube-istio.sh

git clone \
    https://github.com/vfarcic/go-demo-7.git
```

## Ingress

```bash
cd go-demo-7

mkdir -p k8s

helm template \
    charts/go-demo-7 \
    --name go-demo-7 \
    --namespace go-demo-7 \
    --output-dir k8s

kubectl create namespace go-demo-7

kubectl label namespace go-demo-7 \
    istio-injection=enabled

kubectl --namespace go-demo-7 apply \
    --filename k8s \
    --recursive

# TODO: Add vservice.yaml to the chart
# TODO: Add destination-rule.yaml
# TODO: Add gateway.yaml
# TODO: Add lines with `# New` to deployment.yaml
# TODO: Create the templates
# TODOO: Re-apply the templates

kubectl --namespace go-demo-7 \
    rollout status \
    deployment go-demo-7-go-demo-7

kubectl --namespace go-demo-7 \
    get pods

kubectl --namespace go-demo-7 \
    get ing

kubectl --namespace go-demo-7 \
    get destinationrules

kubectl --namespace go-demo-7 \
    describe destinationrule go-demo-7

kubectl --namespace go-demo-7 \
    get virtualservices

kubectl --namespace go-demo-7 \
    describe virtualservice go-demo-7

# If minikube
export INGRESS_HOST=$(minikube ip)

# If minikube
export INGRESS_PORT=$(kubectl \
    --namespace istio-system \
    get service istio-ingressgateway \
    --output jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

POD_NAME=$(kubectl \
    --namespace go-demo-7 \
    get pods --selector app=go-demo-7-go-demo-7 \
    --output jsonpath='{.items[0].metadata.name}')

kubectl --namespace go-demo-7 \
    exec -it $POD_NAME \
    --container istio-proxy \
    -- curl go-demo-7/demo/hello

kubectl --namespace go-demo-7 \
    get gateways

kubectl --namespace go-demo-7 \
    describe gateway go-demo-7

curl -H "Host: go-demo-7.acme.com" \
    "http://$GATEWAY_URL/demo/hello"
```

## jx

```bash

```

## Cleanup

```bash
kubectl --namespace go-demo-7 delete \
    --filename k8s \
    --recursive
```
