```bash
cd ../k8s-specs

git pull

open "https://github.com/heptio/sonobuoy/releases/tag/v0.13.0"

# Must be k8s v1.11+

# Docker for Desktop k8s version is currently (December 2018) on k8s v1.10.
```

* [gke-sonobuoy.sh](https://gist.github.com/658dc48a87ac4f9f7232a7e2a65886ce): **GKE** with 3 **n1-standard-1** worker nodes and Kubernetes version **v1.11.5** (or higher).
* [eks-sonobuoy.sh](https://gist.github.com/99b42c1391fd488646137794350f3ba2): **EKS** with 3 **t2.small** worker nodes and Kubernetes version **v1.11** (or higher).
* [aks-sonobuoy.sh](https://gist.github.com/8ced04f658847148632f880b01e0d9a6): **AKS** with 3 **Standard_B2s** worker nodes and Kubernetes version **v1.11.5** (or higher).
* [minikube-sonobuoy.sh](https://gist.github.com/6d3d10babf1be772f23c6942a7e3811e): **minikube** with **2 CPUs** and **2 GB RAM** and Kubernetes version **v1.11.5** (or higher).

```bash
# Defined a specific k8s version in Minikube and GKE

# eksctl must be version 0.1.15+ (it introduced k8s version 1.11)

# Output are from EKS

kubectl version -o yaml
```

```yaml
clientVersion:
  buildDate: "2018-12-13T19:44:19Z"
  compiler: gc
  gitCommit: eec55b9ba98609a46fee712359c7b5b365bdd920
  gitTreeState: clean
  gitVersion: v1.13.1
  goVersion: go1.11.2
  major: "1"
  minor: "13"
  platform: darwin/amd64
serverVersion:
  buildDate: "2018-12-06T23:13:14Z"
  compiler: gc
  gitCommit: 6bad6d9c768dc0864dab48a11653aa53b5a47043
  gitTreeState: clean
  gitVersion: v1.11.5-eks-6bad6d
  goVersion: go1.10.3
  major: "1"
  minor: 11+
  platform: linux/amd64
```

```bash
sonobuoy version
```

```
v0.13.0
```

```bash
sonobuoy run
```

```
WARN[0001] Version v1.11.5-eks-6bad6d is not a stable version, conformance image may not exist upstream
Running plugins: e2e, systemd-logs
INFO[0008] created object                                name=heptio-sonobuoy namespace= resource=namespaces
INFO[0008] created object                                name=sonobuoy-serviceaccount namespace=heptio-sonobuoy resource=serviceaccounts
INFO[0008] created object                                name=sonobuoy-serviceaccount-heptio-sonobuoy namespace= resource=clusterrolebindings
INFO[0008] created object                                name=sonobuoy-serviceaccount namespace= resource=clusterroles
INFO[0008] created object                                name=sonobuoy-config-cm namespace=heptio-sonobuoy resource=configmaps
INFO[0009] created object                                name=sonobuoy-plugins-cm namespace=heptio-sonobuoy resource=configmaps
INFO[0009] created object                                name=sonobuoy namespace=heptio-sonobuoy resource=pods
INFO[0009] created object                                name=sonobuoy-master namespace=heptio-sonobuoy resource=services
```

```bash
# Wait for a few moments

kubectl -n heptio-sonobuoy get pods
```

```
NAME                                                      READY   STATUS    RESTARTS   AGE
sonobuoy                                                  1/1     Running   0          36s
sonobuoy-e2e-job-cbc6eeb2583a4864                         2/2     Running   0          33s
sonobuoy-systemd-logs-daemon-set-ec5f766936df4111-65h5l   2/2     Running   0          33s
sonobuoy-systemd-logs-daemon-set-ec5f766936df4111-dmpcr   2/2     Running   0          33s
sonobuoy-systemd-logs-daemon-set-ec5f766936df4111-jdg22   2/2     Running   0          33s
```

```bash
sonobuoy status
```

```
PLUGIN          STATUS          COUNT
e2e             running         1
systemd_logs    complete        3

Sonobuoy is still running. Runs can take up to 60 minutes.
```

```bash
sonobuoy logs -f

# There's not much to look at. Too much clutter...

# ctrl+c

sonobuoy status
```

```
PLUGIN          STATUS          COUNT
e2e             complete        1
systemd_logs    complete        3
```

```bash
mkdir -p cluster/sonobuoy

sonobuoy retrieve cluster/sonobuoy

tar xzf cluster/sonobuoy/*.tar.gz -C cluster/sonobuoy/

tail -n 50 \
    cluster/sonobuoy/plugins/e2e/results/e2e.log
```

```
Summarizing 7 Failures:

[Fail] [sig-network] DNS [It] should provide DNS for services  [Conformance]
/workspace/anago-v1.11.3-beta.0.71+a4529464e4629c/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/test/e2e/network/dns_common.go:515

[Fail] [sig-network] DNS [It] should provide DNS for the cluster  [Conformance]
/workspace/anago-v1.11.3-beta.0.71+a4529464e4629c/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/test/e2e/network/dns_common.go:515

[Fail] [sig-cli] Kubectl client [k8s.io] Update Demo [It] should do a rolling update of a replication controller  [Conformance]
/workspace/anago-v1.11.3-beta.0.71+a4529464e4629c/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/test/e2e/framework/rc_util.go:282

[Fail] [sig-network] Proxy version v1 [It] should proxy through a service and a pod  [Conformance]
/workspace/anago-v1.11.3-beta.0.71+a4529464e4629c/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/test/e2e/network/proxy.go:256

[Fail] [sig-cli] Kubectl client [k8s.io] Update Demo [It] should create and stop a replication controller  [Conformance]
/workspace/anago-v1.11.3-beta.0.71+a4529464e4629c/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/test/e2e/framework/rc_util.go:282

[Fail] [sig-cli] Kubectl client [k8s.io] Guestbook application [It] should create and stop a working application  [Conformance]
/workspace/anago-v1.11.3-beta.0.71+a4529464e4629c/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/test/e2e/kubectl/kubectl.go:1909

[Fail] [sig-cli] Kubectl client [k8s.io] Update Demo [It] should scale a replication controller  [Conformance]
/workspace/anago-v1.11.3-beta.0.71+a4529464e4629c/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/test/e2e/framework/rc_util.go:282

Ran 165 of 996 Specs in 9012.181 seconds
FAIL! -- 158 Passed | 7 Failed | 0 Pending | 831 Skipped --- FAIL: TestE2E (9012.34s)
FAIL

Ginkgo ran 1 suite in 2h30m12.803608091s
Test Suite Failed
```

```bash
# Only if there is an error
# Copy the text of one of the tests (e.g., `should provide DNS for services`)

# Only if there is an error
vim cluster/sonobuoy/plugins/e2e/results/e2e.log

# Only if there is an error
# Press `/` to search, paste the text, and press the enter key

# Only if there is an error
# Type `:q`, and press the enter key

sonobuoy delete

open "https://github.com/kubernetes/kubernetes/tree/master/test/e2e"

open "https://www.cncf.io/certification/software-conformance/"
```