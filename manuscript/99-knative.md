# KNative

## Istio

```bash
# TODO: Create a cluster

# If macOS or Linux
curl -L https://git.io/getLatestIstio | sh -

cd istio*

# If macOS or Linux
mv bin/istioctl /usr/local/bin

# If macOS or Linux
chmod +x /usr/local/bin/istioctl

# TODO: Windows CLI setup

istioctl version

helm install \
    install/kubernetes/helm/istio-init \
    --name istio-init \
    --namespace istio-system \
    --wait

helm upgrade -i istio-init \
    install/kubernetes/helm/istio-init \
    --version 1.1.0 \
    --namespace istio-system \
    --wait

kubectl get crd

helm upgrade -i istio \
    install/kubernetes/helm/istio \
    --version 1.1.0 \
    --namespace istio-system \
    --wait

kubectl get svc -n istio-system

kubectl get pods -n istio-system
```

## KNative Setup

```bash
# TODO: Switch to Helm

kubectl apply \
    -f https://github.com/knative/serving/releases/download/v0.4.0/serving.yaml \
    -f https://github.com/knative/build/releases/download/v0.4.0/build.yaml \
    -f https://github.com/knative/eventing/releases/download/v0.4.0/in-memory-channel.yaml \
    -f https://github.com/knative/eventing/releases/download/v0.4.0/release.yaml \
    -f https://github.com/knative/eventing-sources/releases/download/v0.4.0/release.yaml \
    -f https://github.com/knative/serving/releases/download/v0.4.0/monitoring.yaml \
    -f https://raw.githubusercontent.com/knative/serving/v0.4.0/third_party/config/build/clusterrole.yaml

kubectl -n knative-serving get pods

kubectl -n knative-build get pods

kubectl -n knative-eventing get pods

kubectl -n knative-sources get pods

kubectl -n knative-monitoring get pods
```

## Testing The Setup

```bash
echo '
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
  namespace: default # The namespace the app will use
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: gcr.io/knative-samples/helloworld-go # The URL to the image of the app
            env:
              - name: TARGET # The environment variable printed out by the sample app
                value: "Go Sample v1"
' | kubectl apply -f -

kubectl get all

GATEWAY_IP=$(kubectl -n istio-system \
    get svc istio-ingressgateway \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

curl \
    -H "Host: helloworld-go.default.example.com" \
    http://$GATEWAY_IP

echo '
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
  namespace: default # The namespace the app will use
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: gcr.io/knative-samples/helloworld-go # The URL to the image of the app
            env:
              - name: TARGET # The environment variable printed out by the sample app
                value: "Go Sample v1"
' | kubectl delete -f -
```

## KNative Builds

```bash
```