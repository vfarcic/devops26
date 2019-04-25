# Links to gists for creating a cluster with jx
# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# eks-jx.sh: https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac
# aks-jx.sh: https://gist.github.com/6e01717c398a5d034ebe05b195514060
# install.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

cd go-demo-6

git pull

git checkout pr

git merge -s ours master --no-edit

git checkout master

git merge pr

git push

jx import -b

jx get activities -f go-demo-6 -w

jx get applications -e production

jx get applications -e staging

VERSION=[...]

jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    -b

jx get applications -e production

PROD_ADDR=[...]

curl "$PROD_ADDR/demo/hello"

cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
