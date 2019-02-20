
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

## Hands-On Time

---

# Development


## Past Time

---

```bash
cd ../go-demo-6

go get github.com/cespare/reflex

go get -t

make linux

docker image build -t go-demo-6 .

chmod +x watch.sh

./watch.sh
```


## Present Time

---

```bash
jx create devpod --reuse -b

ls -l

go mod init

go get -t

make linux

cat skaffold.yaml

echo $DOCKER_REGISTRY

helm init --client-only
```


## Present Time

---

```bash
skaffold run -p dev

kubectl get ns

export MY_USER=[...]

kubectl -n jx-edit-$MY_USER get pods

chmod +x watch.sh

./watch.sh
```

* Open a second terminal


## Present Time

---

```bash
GH_USER=[...]

ADDR=$(kubectl -n jx-edit-$GH_USER get ing go-demo-6 \
  -o jsonpath="{.spec.rules[0].host}")

curl "http://$ADDR/demo/hello"

THEIA_ADDR=$(kubectl -n jx get ing $GH_USER-go-theia \
  -o jsonpath="{.spec.rules[0].host}")

open "http://$THEIA_ADDR"
```

* Files > go-demo-6 > main.go
* Change `hello, world` to `hello, devpod`
* Files > go-demo-6 > main_test.go
* Change `hello, world` to `hello, devpod`

TODO: VS Code integration


## Present Time

---

```bash
curl "http://$ADDR/demo/hello"
```

* Go to the first terminal
* Press `ctrl+c`

```
exit
```


## With Synchronization

---

```bash
jx get devpod

jx delete devpod
```

* Press `y` and the enter key

```bash
cat main.go
```

* Go to the second terminal

```
jx sync --daemon # `--daemon` doesn't always work
```

* Go back to the first terminal


## With Synchronization

---

```bash
jx create devpod --reuse --sync -b

helm init --client-only

go mod init

go get -t

chmod +x watch.sh

./watch.sh
```

* Open a third terminal

```bash
GH_USER=[...]

ADDR=$(kubectl -n jx-edit-$GH_USER get ing go-demo-6 \
  -o jsonpath="{.spec.rules[0].host}")

curl "http://$ADDR/demo/hello"
```


## With Synchronization

---

```bash
cd go-demo-6

cat main.go | sed -e 's@hello, world@hello, devpod@g' \
    | tee main.go

cat main_test.go | sed -e 's@hello, world@hello, devpod@g' \
    | tee main_test.go

curl "http://$ADDR/demo/hello"

# cat Makefile | sed -e 's@hello, world@hello, devpod@g' \
#     | tee Makefile

echo 'unittest: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) test --run UnitTest -v
' | tee -a Makefile
```


## With Synchronization

---

```bash
cat watch.sh | sed -e \
    's@linux \&\& skaffold@linux \&\& make unittest \&\& skaffold@g' \
    | tee watch.sh

cat main.go | sed -e \
    's@hello, devpod@hello, devpod with tests@g' \
    | tee main.go

cat main_test.go | sed -e \
    's@hello, devpod@hello, devpod with tests@g' \
    | tee main_test.go

curl "http://$ADDR/demo/hello"
```


## With Synchronization

---

```bash
STAGING_ADDR=$(kubectl -n jx-staging get ing go-demo-6 \
  -o jsonpath="{.spec.rules[0].host}")

curl "http://$STAGING_ADDR/demo/hello"

git add .

git commit -m "devpod"

git push

jx get activity -f go-demo-6 -w
```

* Cancel with `ctrl+c`

```bash
curl "http://$STAGING_ADDR/demo/hello"

jx delete devpod
```

* Press `y` and the enter key
