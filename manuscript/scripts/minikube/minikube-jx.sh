####################
# Create a cluster #
####################

# Install [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)

PASS=admin

MEM=8192

CPU=8

DISK=150GB

# Feel free to change the driver (`-d`) if something other than virtualbox serves you better.

jx create git server -k github -n github -u https://github.com

jx create cluster minikube \
    -m $MEM \
    -c $CPU \
    -s $DISK \
    -d virtualbox \
    --default-admin-password=$PASS \
    --default-environment-prefix jx-rocks

#######################
# Destroy the cluster #
#######################

minikube delete