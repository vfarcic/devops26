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
