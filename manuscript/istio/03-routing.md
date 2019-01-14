## Routing

* [docker-istio.sh](TODO:):  **Docker for Desktop** TODO:.
* [minikube-istio.sh](TODO:): **minikube** TODO:.
* [gke-istio.sh](TODO:): **GKE** TODO:.
* [eks-istio.sh](TODO:): **EKS** TODO:.
* [aks-istio.sh](TODO:): **AKS** TODO:.

```bash
helm upgrade -i go-demo-7 \
    ../go-demo-7/charts/go-demo-7 \
    --namespace go-demo-7 \
    --wait

kubectl label ns go-demo-7 \
    istio-injection=enabled





kubectl label ns default \
    istio-injection=enabled

kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/platform/kube/bookinfo.yaml

kubectl get svc

kubectl get pods

kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl get gateway

curl -i http://$GATEWAY_URL/productpage

open "http://$GATEWAY_URL/productpage"

kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/networking/destination-rule-all.yaml

kubectl get destinationrules -o yaml

open "http://$GATEWAY_URL/productpage"

# Refresh the screen and observe that the stars appear and dissapear

kubectl get virtualservices -o yaml

kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-all-v1.yaml

kubectl get virtualservices -o yaml

kubectl get destinationrules -o yaml

open "http://$GATEWAY_URL/productpage"

# Refresh the screen and observe that the stars do NOT appear

kubectl apply \
    -f $ISTIO_PATH/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

open "http://$GATEWAY_URL/productpage"

# Refresh the screen and observe that the stars do NOT appear

# Login as user jason and observe that the stars do appear

# Login as any other user jason and observe that the stars do NOT appear
```