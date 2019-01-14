## Egress Traffic

```bash
kubectl apply -f $ISTIO_PATH/samples/sleep/sleep.yaml

export SOURCE_POD=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})

kubectl exec -it $SOURCE_POD -c sleep sh

curl -i http://httpbin.org/headers

curl -i https://www.google.com

exit

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: httpbin-ext
spec:
  hosts:
  - httpbin.org
  ports:
  - number: 80
    name: http
    protocol: HTTP
  resolution: DNS
  location: MESH_EXTERNAL
EOF

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: google
spec:
  hosts:
  - www.google.com
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  resolution: DNS
  location: MESH_EXTERNAL
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: google
spec:
  hosts:
  - www.google.com
  tls:
  - match:
    - port: 443
      sni_hosts:
      - www.google.com
    route:
    - destination:
        host: www.google.com
        port:
          number: 443
      weight: 100
EOF

kubectl exec -it $SOURCE_POD -c sleep sh

curl -i http://httpbin.org/headers

curl -i https://www.google.com

time curl -o /dev/null -s -w "%{http_code}\n" http://httpbin.org/delay/5

exit

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin-ext
spec:
  hosts:
    - httpbin.org
  http:
  - timeout: 3s
    route:
      - destination:
          host: httpbin.org
        weight: 100
EOF

kubectl exec -it $SOURCE_POD -c sleep sh

time curl -o /dev/null -s -w "%{http_code}\n" http://httpbin.org/delay/5

exit

kubectl delete serviceentry httpbin-ext

kubectl delete virtualservice httpbin-ext

kubectl delete -f $ISTIO_PATH/samples/sleep/sleep.yaml

kubectl apply -f $ISTIO_PATH/samples/sleep/sleep.yaml

kubectl rollout status deployment sleep

export SOURCE_POD=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})

echo $SOURCE_POD

# Repeat the previous two commands if the output is not a single Pod

kubectl exec -it $SOURCE_POD -c sleep sh

curl -i http://httpbin.org/headers

exit

helm upgrade -i istio \
    $ISTIO_PATH/install/kubernetes/helm/istio \
    --namespace istio-system \
    --set gateways.istio-ingressgateway.type=NodePort \
    --set gateways.istio-egressgateway.type=NodePort \
    --set global.proxy.includeIPRanges="10.0.0.1/24"

# `includeIPRanges` differs from one hosting vendor to another

kubectl exec -it $SOURCE_POD -c sleep sh

curl -i http://httpbin.org/headers

exit

kubectl delete serviceentry httpbin-ext google

kubectl delete virtualservice httpbin-ext google

kubectl delete -f $ISTIO_PATH/samples/sleep/sleep.yaml

helm upgrade -i istio \
    $ISTIO_PATH/install/kubernetes/helm/istio \
    --namespace istio-system \
    --set gateways.istio-ingressgateway.type=NodePort \
    --set gateways.istio-egressgateway.type=NodePort
```

## Fault Injection

```bash
kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml

kubectl get \
    virtualservice ratings \
    -o yaml

open "http://$GATEWAY_URL/productpage"

# Login as user jason and observe that the stars do appear

# There should be an error

kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml

kubectl get \
    virtualservice ratings \
    -o yaml

kubectl delete \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-all-v1.yaml
```

## Traffic Shifting

```bash
kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-all-v1.yaml

open "http://$GATEWAY_URL/productpage"

# It's v1 without rating

kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml

kubectl get \
    virtualservice reviews \
    -o yaml

open "http://$GATEWAY_URL/productpage"

# Refresh the page a few times and observe that approx. 50% it's v1 (without rating) and the other 50% it's v3 (with ratings)

kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-reviews-v3.yaml

open "http://$GATEWAY_URL/productpage"

# Refresh the page a few times and observe all requests receive v3 (with ratings)

kubectl delete \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-all-v1.yaml
```

## Request Timeouts

```bash
kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-all-v1.yaml

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
    - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v2
EOF

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - fault:
      delay:
        percent: 100
        fixedDelay: 2s
    route:
    - destination:
        host: ratings
        subset: v1
EOF

open "http://$GATEWAY_URL/productpage"

# There is 2 seconds delay

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v2
    timeout: 0.5s
EOF

open "http://$GATEWAY_URL/productpage"

# There is 1 seconds delay (0.5 seconds plus 0.5 seconds for a retry) and the reviews are not available

kubectl delete \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-all-v1.yaml
```


## TODO

- [ ] `authn`
- [ ] `context-create`
- [ ] `create`
- [ ] `delete`
- [ ] `deregister`
- [ ] `gen-deploy`
- [ ] `get`
- [ ] `help`
- [ ] `proxy-config`
- [ ] `proxy-status`
- [ ] `register`
- [ ] `replace`