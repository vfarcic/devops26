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

##########
# tiller #
##########

helm version

# Must be 2.10+

kubectl create \
    -f helm/tiller-rbac.yml \
    --record --save-config

helm init --service-account tiller

kubectl -n kube-system \
    rollout status deploy tiller-deploy

#########
# Istio #
#########

helm upgrade -i istio \
    cluster/istio-*/install/kubernetes/helm/istio \
    --namespace istio-system \
    --set gateways.istio-ingressgateway.type=NodePort \
    --set gateways.istio-egressgateway.type=NodePort \
    --wait
