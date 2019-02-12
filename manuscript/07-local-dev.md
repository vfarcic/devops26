
Added `jx edit buildpack` to the Gists

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

## Developer Day

* From a tablet and Google terminal
* Any project in any language and with any framework
* Push to any registry with a single (k8s authentication)
* Without installing tools (e.g., Go, skaffold, Helm, Docker, etc)

## Past Time

```bash
# Make sure to sync the fork (https://help.github.com/articles/syncing-a-fork/)

# If not already inside *go-demo-6*
cd go-demo-6

# If if a need to restore
git checkout buildpack

# If if a need to restore
git merge -s ours master --no-edit

# If if a need to restore
git checkout master

# If if a need to restore
git merge buildpack

# If if a need to restore
git push

# Only if destroyed the cluster in the previous chapter
jx import -b

# Only if destroyed the cluster in the previous chapter
jx get activity -f go-demo-6 -w

# Cancel with `ctrl+c`

# Requirement: Go
go get github.com/cespare/reflex

go get -t

make linux

# Requirement: Docker Desktop (macOS or Windows) or Docker Server (Linux)
docker image build -t go-demo-6 .

chmod +x watch.sh

./watch.sh
```

## Present Time

```bash
jx create devpod --reuse -b

# If takes a few minutes until everything is ready

ls -l

GH_USER=[...]

# mkdir /home/jenkins/go/src/github.com/$GH_USER/

# ln -s $PWD \
#   /home/jenkins/go/src/github.com/$GH_USER/go-demo-6

# export GOPATH=$PWD

go get -t

make linux

cat skaffold.yaml

echo $DOCKER_REGISTRY

helm init --client-only

skaffold run -p dev

kubectl get ns

kubectl -n jx-edit-$GH_USER get pods

chmod +x watch.sh

./watch.sh

# Open a second terminal

GH_USER=[...]

ADDR=$(kubectl -n jx-edit-$GH_USER \
  get ing go-demo-6 \
  -o jsonpath="{.spec.rules[0].host}")

curl "http://$ADDR/demo/hello"

THEIA_ADDR=$(kubectl -n jx \
  get ing $GH_USER-go-theia \
  -o jsonpath="{.spec.rules[0].host}")

open "http://$THEIA_ADDR"

# Files > go-demo-6 > main.go
# Change `hello, world` to `hello, devpod`
# Files > go-demo-6 > main_test.go
# Change `hello, world` to `hello, devpod`

curl "http://$ADDR/demo/hello"

# Go to the first terminal

# ctrl+c

exit
```

## With Synchronization

```bash
jx get devpod

jx delete devpod

# y + enter

cat main.go

# The code is intact

# Go to the second terminal

jx sync --daemon # `--daemon` doesn't always work
```

```
Downloading https://github.com/vapor-ware/ksync/releases/download/0.3.4/ksync_darwin_amd64 to /Users/vfarcic/.jx/bin/ksync.tmp...
Downloaded /Users/vfarcic/.jx/bin/ksync.tmp
Initialising ksync
==== Local Environment ====
Fetching extra binaries                     ✓

==== Preflight checks ====
Cluster Config                              ✓
Cluster Connection                          ✓
Cluster Version                             ✓
Cluster Permissions                         ✓

==== Cluster Environment ====
Adding ksync to the cluster                 ✓
Waiting for pods to be healthy              ✓

==== Postflight checks ====
Cluster Service                             ✓
Service Health                              ✓
Service Version                             ✓
Docker Version                              ✓
Docker Storage Driver                       ✓
Docker Storage Root                         ✓

==== Initialization Complete ====
Looks like 'ksync watch' is not running: Command failed 'ksync get': time="2019-02-10T00:38:32+01:00" level=fatal msg="Having problems querying status. Are you running watch?" exit status 1

Started the ksync watch
INFO[0000] listening                                     bind=127.0.0.1 port=40322
INFO[0003] syncthing listening                           port=8384 syncthing=localhost
```

```bash
# Go back to the first terminal

jx create devpod --reuse --sync -b

helm init --client-only

go get -t

chmod +x watch.sh

./watch.sh

# Open a third terminal

GH_USER=[...]

ADDR=$(kubectl -n jx-edit-$GH_USER \
  get ing go-demo-6 \
  -o jsonpath="{.spec.rules[0].host}")

curl "http://$ADDR/demo/hello"

cd go-demo-6

cat main.go \
    | sed -e \
    's@hello, world@hello, devpod@g' \
    | tee main.go

cat main_test.go \
    | sed -e \
    's@hello, world@hello, devpod@g' \
    | tee main_test.go

# Wait for a moment

curl "http://$ADDR/demo/hello"

cat Makefile \
    | sed -e \
    's@hello, world@hello, devpod@g' \
    | tee Makefile

echo 'unittest: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) test --run UnitTest -v
' | tee -a Makefile

cat watch.sh \
    | sed -e \
    's@linux \&\& skaffold@linux \&\& make unittest \&\& skaffold@g' \
    | tee watch.sh

cat main.go \
    | sed -e \
    's@hello, devpod@hello, devpod with tests@g' \
    | tee main.go

cat main_test.go \
    | sed -e \
    's@hello, devpod@hello, devpod with tests@g' \
    | tee main_test.go

curl "http://$ADDR/demo/hello"

STAGING_ADDR=$(kubectl -n jx-staging \
  get ing go-demo-6 \
  -o jsonpath="{.spec.rules[0].host}")

curl "http://$STAGING_ADDR/demo/hello"

git add .

git commit -m "devpod"

git push

jx get activity -f go-demo-6 -w

# Cancel with `ctrl+c`

curl "http://$STAGING_ADDR/demo/hello"

jx delete devpod

# y + enter
```

## What Now?


```bash
# Stop the processes in the first and the second terminal (`ctrl + c`)

cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```