####################
# Create a cluster #
####################

# Install [doctl](https://github.com/digitalocean/doctl)

doctl auth init

doctl k8s cluster \
    create jx-rocks \
    --count 3 \
    --region nyc1 \
    --size s-2vcpu-4gb

kubectl config use do-nyc1-jx-rocks

# TODO: CA

#########################
# Install nginx Ingress #
#########################

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml

export LB_IP=$(kubectl -n ingress-nginx \
    get svc -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")

echo $LB_IP # It might take a while until LB is created. Repeat the `export` command if the output is empty.

##################
# Install Tiller #
##################

kubectl create \
    -f https://raw.githubusercontent.com/vfarcic/k8s-specs/master/helm/tiller-rbac.yml \
    --record --save-config

helm init --service-account tiller

kubectl -n kube-system \
    rollout status deploy tiller-deploy

##############
# Install jx #
##############

# The command that follows uses `-b` to run in the batch mode and it assumes that this is not the first time you create a cluster with `jx`.
# If that's not the case and this is indeed the first time you're creating a `jx` cluster, it will not have some of the default values like GitHub user and the installation might fail.
# Please remove `-b` from the command if this is NOT the first time you're creating a cluster with `jx`.

jx install \
    --provider kubernetes \
    --external-ip $LB_IP \
    --domain jenkinx.$LB_IP.nip.io \
    --default-admin-password=admin \
    --ingress-namespace ingress-nginx \
    --ingress-deployment nginx-ingress-controller \
    --tiller-namespace kube-system \
    --default-environment-prefix jx-rocks \
    -b

#######################
# Destroy the cluster #
#######################

doctl kubernetes cluster \
    delete jx-rocks \
    -f

# TODO: Delete the volumes

# TODO: Delete the L