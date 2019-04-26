# Links to gists for creating a cluster with jx
# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# eks-jx.sh: https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac
# aks-jx.sh: https://gist.github.com/6e01717c398a5d034ebe05b195514060
# install.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

cd go-demo-6

git checkout buildpack

git merge -s ours master --no-edit

git checkout master

git merge buildpack

git push

jx import --batch-mode

jx get activity -f go-demo-6 -w

cd go-demo-6

jx create devpod -b

jx rsh -d

cd go-demo-6

ls -1

go mod init

make linux

cat skaffold.yaml

echo $DOCKER_REGISTRY

env

kubectl create \
    -f https://raw.githubusercontent.com/vfarcic/k8s-specs/master/helm/tiller-rbac.yml \
    --record --save-config

helm init --service-account tiller

skaffold run -p dev

echo $SKAFFOLD_DEPLOY_NAMESPACE

kubectl -n $SKAFFOLD_DEPLOY_NAMESPACE \
    get pods

cat watch.sh

chmod +x watch.sh

nohup ./watch.sh &

exit

jx get applications

URL=[...]

curl "$URL/demo/hello"

jx open

jx open [...]

curl "$URL/demo/hello"

jx delete devpod

echo 'unittest: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) test --run UnitTest -v
' | tee -a Makefile

cat watch.sh | sed -e \
    's@linux \&\& skaffold@linux \&\& make unittest \&\& skaffold@g' \
    | tee watch.sh

jx sync --daemon

jx create devpod --sync -b

jx rsh -d

go mod init

helm init --client-only

chmod +x watch.sh

./watch.sh

curl "$URL/demo/hello"

cat main.go | sed -e \
    's@hello, world@hello, devpod with tests@g' \
    | tee main.go

cat main_test.go | sed -e \
    's@hello, world@hello, devpod with tests@g' \
    | tee main_test.go

curl "$URL/demo/hello"

git add .

git commit -m "devpod"

git push

jx get activity -f go-demo-6 -w

jx get applications

STAGING_URL=[...]

curl "$STAGING_URL/demo/hello"

jx delete devpod

cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
