# Links to gists for creating a cluster with jx
# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# eks-jx.sh: https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac
# aks-jx.sh: https://gist.github.com/6e01717c398a5d034ebe05b195514060
# install.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

# External IP
LB_IP=$(kubectl -n kube-system \
  get svc jxing-nginx-ingress-controller \
  -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

# The domain through which 
# we can access the applications
DOMAIN=serverless.$LB_IP.nip.io

# The Namespace where Ingress is running
INGRESS_NS=kube-system

# The name of the NGINX Ingress Deployment
INGRESS_DEP=jxing-nginx-ingress-controller

PROVIDER=[...]

jx install \
    --provider $PROVIDER \
    --external-ip $LB_IP \
    --domain $DOMAIN \
    --default-admin-password=admin \
    --ingress-namespace $INGRESS_NS \
    --ingress-deployment $INGRESS_DEP \
    --default-environment-prefix tekton \
    --git-provider-kind github \
    --namespace cd \
    --prow \
    --tekton \
    -b

jx get teams

jx team jx

jx team cd

jx create quickstart \
  -l go \
  -p jx-serverless \
  -b

cd jx-serverless

ls -l

cat jenkins-x.yml

jx get activities \
    -f jx-serverless \
    --watch

kubectl -n cd get pods

jx get pipelines

jx console

jx get build logs

cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

hub delete -y \
  $GH_USER/environment-tekton-staging

hub delete -y \
  $GH_USER/environment-tekton-production

hub delete -y $GH_USER/jx-serverless

rm -rf jx-serverless

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*
