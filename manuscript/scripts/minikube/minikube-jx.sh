####################
# Create a cluster #
####################

# Install [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)

jx create cluster minikube \
    -m 8192 \
    -c 8 \
    -s 150GB \
    -d virtualbox \
    --default-admin-password=admin \
    --default-environment-prefix jx-rocks \
    -b

#######################
# Destroy the cluster #
#######################

minikube delete
