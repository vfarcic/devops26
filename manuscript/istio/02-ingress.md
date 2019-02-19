## Cluster

```bash
git clone \
    https://github.com/vfarcic/k8s-specs.git

cd k8s-specs
```

* [docker-istio.sh](TODO:):  **Docker for Desktop** TODO:.
* [minikube-istio.sh](TODO:): **minikube** TODO:.
* [gke-istio.sh](TODO:): **GKE** TODO:.
* [eks-istio.sh](TODO:): **EKS** TODO:.
* [aks-istio.sh](TODO:): **AKS** TODO:.

## Ingress

```bash
kubectl create ns go-demo-7

kubectl label ns go-demo-7 \
    istio-injection=enabled
    
# TODO: Replace with https://github.com/vfarcic/go-demo-7/releases/download/1.0.0/go-demo-7-1.0.0.tgz
helm upgrade -i go-demo-7 \
    ../go-demo-7/charts/go-demo-7 \
    --namespace go-demo-7 \
    --wait

kubectl -n go-demo-7 \
    describe svc go-demo-7-api

#  Named ports: Service ports must be named. The port names must be of the form <protocol>[-<suffix>] with http, http2, grpc, mongo, or redis as the <protocol> in order to take advantage of Istio’s routing features. For example, name: http2-foo or name: http are valid port names, but name: http2foo is not. If the port name does not begin with a recognized prefix or if the port is unnamed, traffic on the port will be treated as plain TCP traffic (unless the port explicitly uses Protocol: UDP to signify a UDP port).

# Service association: If a pod belongs to multiple Kubernetes services, the services cannot use the same port number for different protocols, for instance HTTP and TCP.

kubectl -n go-demo-7 \
    describe deployment go-demo-7

# Deployments with app and version labels: It is recommended that pods deployed using the Kubernetes Deployment have an explicit app label and version label in the deployment specification. Each deployment specification should have a distinct app label with a value indicating something meaningful, with version indicating the version of the app that the particular deployment corresponds to. The app label is used to add contextual information in distributed tracing. The app and version labels are also used to add contextual information in the metric telemetry collected by Istio.

kubectl -n go-demo-7 \
    get ing

# There is no Ingress

kubectl -n istio-system \
    get svc istio-ingressgateway

# If Minikube
export IP=$(minikube ip)

echo $IP

# If Minikube
export PORT=$(kubectl \
    -n istio-system \
    get svc istio-ingressgateway \
    -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

echo $PORT

cat istio/gd7-gateway.yml

kubectl -n istio-system \
    describe deployment \
    istio-ingressgateway

kubectl apply \
    -f istio/gd7-gateway.yml

kubectl -n go-demo-7 get gateways

cat istio/gd7-virtualservice.yml

kubectl apply \
    -f istio/gd7-virtualservice.yml

kubectl -n go-demo-7 get virtualservices

curl -i -H "Host:go-demo-7.com" \
    http://$IP:$PORT/demo/hello

curl -i -H "Host:go-demo-7.com" \
    http://$IP:$PORT/something/else

# If Minikube
export SECURE_PORT=$(kubectl \
    -n istio-system \
    get svc istio-ingressgateway \
    -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

echo $SECURE_PORT

curl -i -H "Host:go-demo-7.com" \
    https://$IP:$SECURE_PORT/demo/hello

kubectl -n istio-system \
    create secret tls \
    istio-ingressgateway-certs \
    --key certs/go-demo-7.com/3_application/private/go-demo-7.com.key.pem \
    --cert certs/go-demo-7.com/3_application/certs/go-demo-7.com.cert.pem

cat istio/gd7-gateway-https.yml

kubectl apply \
    -f istio/gd7-gateway-https.yml

# cat <<EOF | kubectl apply -f -
# apiVersion: networking.istio.io/v1alpha3
# kind: Gateway
# metadata:
#   name: mygateway
# spec:
#   selector:
#     istio: ingressgateway # use istio default ingress gateway
#   servers:
#   - port:
#       number: 443
#       name: https
#       protocol: HTTPS
#     tls:
#       mode: SIMPLE
#       serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
#       privateKey: /etc/istio/ingressgateway-certs/tls.key
#     hosts:
#     - "httpbin.example.com"
# EOF

# cat <<EOF | kubectl apply -f -
# apiVersion: networking.istio.io/v1alpha3
# kind: VirtualService
# metadata:
#   name: httpbin
# spec:
#   hosts:
#   - "httpbin.example.com"
#   gateways:
#   - mygateway
#   http:
#   - match:
#     - uri:
#         prefix: /status
#     - uri:
#         prefix: /delay
#     route:
#     - destination:
#         port:
#           number: 8000
#         host: httpbin
# EOF

curl -v -H "Host:go-demo-7.com" \
    --resolve go-demo-7.com:$SECURE_PORT:$IP \
    --cacert certs/go-demo-7.com/2_intermediate/certs/ca-chain.cert.pem \
    https://go-demo-7.com:$SECURE_PORT/demo/hello

curl -i -H "Host:go-demo-7.com" \
    http://$IP:$PORT/demo/hello

# TODO: Change to remote chart
helm upgrade -i devops-toolkit \
    ../devops-toolkit/helm/devops-toolkit \
    --namespace devops-toolkit \
    --set ingress.type=gateway \
    --set istio.enabled=true

curl -i -H "Host:www.devopstoolkitseries.com" \
    http://$IP:$PORT

curl -i -H "Host:www.devopstoolkitseries.com" \
    https://$IP:$SECURE_PORT

TODO: Continue

# TODO: Multiple certs







curl -I -HHost:httpbin.example.com \
    http://$INGRESS_HOST:$INGRESS_PORT/status/200

cat <<EOF | kubectl apply -f -
apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "ingressgateway"
  namespace: istio-system
spec:
  targets:
  - name: istio-ingressgateway
  origins:
  - jwt:
      issuer: "testing@secure.istio.io"
      jwksUri: "https://raw.githubusercontent.com/istio/istio/release-1.0/security/tools/jwt/samples/jwks.json"
  principalBinding: USE_ORIGIN
EOF

curl -I -HHost:httpbin.example.com http://$INGRESS_HOST:$INGRESS_PORT/status/200

TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.0/security/tools/jwt/samples/demo.jwt -s)

curl --header "Authorization: Bearer $TOKEN" -I -HHost:httpbin.example.com http://$INGRESS_HOST:$INGRESS_PORT/status/200

# TODO: Gateway reference





kubectl -n go-demo-7 \
    delete gateway,virtualservice \
    go-demo-7-api

# TODO: Replace with https://github.com/vfarcic/go-demo-7/releases/download/1.0.0/go-demo-7-1.0.0.tgz
helm upgrade -i go-demo-7 \
    ../go-demo-7/charts/go-demo-7 \
    --namespace go-demo-7 \
    --set ingress.type=gateway \
    --set ingress.host=go-demo-7.com \
    --set istio.enabled=true \
    --wait

curl -i -H "Host:go-demo-7.com" \
    http://$IP:$PORT/demo/hello

curl -i -H "Host:go-demo-7.com" \
    http://$IP:$PORT/something/else

# TODO: Let's Encrypt
```
