###########
# Cluster #
###########

minikube start \
    --vm-driver virtualbox \
    --cpus 4 \
    --memory 8192

minikube addons enable default-storageclass

minikube addons disable ingress

minikube addons enable storage-provisioner

#########
# Istio #
#########

helm upgrade -i istio \
    cluster/istio-*/install/kubernetes/helm/istio \
    --namespace istio-system \
    --set gateways.istio-ingressgateway.type=NodePort \
    --set gateways.istio-egressgateway.type=NodePort \
    --wait
