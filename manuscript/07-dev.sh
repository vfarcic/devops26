# Links to gists for creating a cluster with jx
# gke-jx-serverless.sh: https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8
# eks-jx-serverless.sh: https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd
# aks-jx-serverless.sh: https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410
# install-serverless.sh: https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037

cd go-demo-6

git pull

git checkout buildpack-tekton

git merge -s ours master --no-edit

git checkout master

git merge buildpack

git push

# If GKE
cat charts/go-demo-6/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/go-demo-6/Makefile

# If GKE
cat charts/preview/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/preview/Makefile

# If GKE
cat skaffold.yaml \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee skaffold.yaml

jx import --pack go --batch-mode

jx get activities \
    --filter go-demo-6 \
    --watch

cd go-demo-6

jx create devpod --label go --batch-mode

jx rsh --devpod

cd go-demo-6

ls -1

make linux

cat skaffold.yaml

cat skaffold.yaml \
  | sed -e 's@DIGEST_HEX@UUID@g' \
  | tee skaffold.yaml

echo $DOCKER_REGISTRY

env

kubectl create \
    -f https://raw.githubusercontent.com/vfarcic/k8s-specs/master/helm/tiller-rbac.yml \
    --record --save-config

helm init --service-account tiller

export UUID=$(uuidgen)

skaffold run --profile dev

echo $SKAFFOLD_DEPLOY_NAMESPACE

kubectl -n $SKAFFOLD_DEPLOY_NAMESPACE \
    get pods

cat watch.sh

cat watch.sh | sed -e \
  's@skaffold@UUID=$(uuidgen) skaffold@g' \
  | tee watch.sh

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
	CGO_ENABLED=$(CGO_ENABLED) $(GO) \\
	test --run UnitTest -v
' | tee -a Makefile

cat watch.sh |
    sed -e \
    's@linux \&\& skaffold@linux \&\& make unittest \&\& skaffold@g' \
    | sed -e \
    's@skaffold@UUID=$(uuidgen) skaffold@g' \
    | tee watch.sh

jx sync --daemon

jx create devpod \
    --label go \
    --sync \
    --batch-mode

jx rsh --devpod

unset GOPATH

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

git commit \
    --message "devpod"

git push

jx get activity \
    --filter go-demo-6 \
    --watch

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
