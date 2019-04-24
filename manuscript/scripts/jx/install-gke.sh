######################
# Create The Cluster #
######################

gcloud auth login

gcloud container clusters \
    create jx-rocks \
    --region us-east1 \
    --machine-type n1-standard-2 \
    --enable-autoscaling \
    --num-nodes 1 \
    --max-nodes 3 \
    --min-nodes 1

kubectl create clusterrolebinding \
    cluster-admin-binding \
    --clusterrole cluster-admin \
    --user $(gcloud config get-value account)

###################
# Install Ingress #
###################

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml

#####################
# Install Jenkins X #
#####################

export LB_IP=$(kubectl -n ingress-nginx \
    get svc ingress-nginx \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo $LB_IP

DOMAIN=jenkinx.$LB_IP.nip.io

PROVIDER=gke

INGRESS_NS=ingress-nginx

INGRESS_DEP=nginx-ingress-controller

echo "nexus:
  enabled: false
" | tee myvalues.yaml

# The command that follows uses `-b` to run in the batch mode and it assumes that this is not the first time you create a cluster with `jx`.
# If that's not the case and this is indeed the first time you're creating a `jx` cluster, it will not have some of the default values like GitHub user and the installation might fail.

jx install \
    --provider $PROVIDER \
    --external-ip $LB_IP \
    --domain $DOMAIN \
    --default-admin-password=admin \
    --ingress-namespace $INGRESS_NS \
    --ingress-deployment $INGRESS_DEP \
    --default-environment-prefix jx-rocks \
    --git-provider-kind github \
    -b

#######################
# Uninstall Jenkins X #
#######################

jx uninstall \
  --context $(kubectl config current-context) \
  -b

#######################
# Destroy the cluster #
#######################

gcloud container clusters \
    delete jx-rocks \
    --region us-east1 \
    --quiet

gcloud compute disks delete \
    $(gcloud compute disks list \
    --filter="-users:*" \
    --format="value(id)")
