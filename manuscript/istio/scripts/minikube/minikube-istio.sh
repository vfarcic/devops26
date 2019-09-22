###########
# Cluster #
###########

minikube start \
    --vm-driver virtualbox \
    --cpus 4 \
    --memory 16384

minikube addons enable default-storageclass

minikube addons disable ingress

minikube addons enable storage-provisioner

#########
# Istio #
#########

# Clone https://github.com/vfarcic/k8s-specs if you do not have it already

cd k8s-specs

kubectl create namespace istio-system

kubectl apply \
    --filename istio/istio-init \
    --recursive

kubectl get crds | grep 'istio.io'

# Wait until the CRDs are created

kubectl apply \
    --filename istio/istio \
    --recursive

cd ..
