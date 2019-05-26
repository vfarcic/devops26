## TODO

- [X] Code
- [ ] Write
- [X] Code review static GKE
- [X] Code review serverless GKE
- [-] Code review static EKS
- [-] Code review serverless EKS
- [-] Code review static AKS
- [-] Code review serverless AKS
- [-] Code review existing static cluster
- [-] Code review existing serverless cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Upgrading

Jenkins X is evolving rapidly. We can see that by checking the releases. There's hardly a day without at least one Jenkins X release. There are days with more then ten releases. That's fast, and for very good reasons. The community behind the project is growing rapidly and that means that the rate oof pull requests is increasing as well.

## Versions

TODO: Outputs and screenshots

```bash
open "https://github.com/jenkins-x/jenkins-x-versions"

open "https://github.com/jenkins-x/jenkins-x-versions/blob/master/charts/jenkins-x/jenkins-x-platform.yml"

# History

# Select one of the older commits

# Scroll to the *jenkins-x-platform.yml* file

# If not reusing the cluster from the previous chapter
PLATFORM_VERSION=[...]

# If not reusing the cluster from the previous chapter
# NOTE: Add `--version $PLATFORM_VERSION` to the arguments when creating the cluster or installing Jenkins X
```

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

TODO: Rewrite

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [09-promote.sh](https://gist.github.com/345da6a87564078b84d30eccfd3037c9) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new static **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new static **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new static **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** static cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

TODO: Check whether `versioning` and `extension-model` should be restored

I> The commands that follow will reset your *go-demo-6* `master` branch with the contents of the `versioning` branch that contains all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

```bash
# Only if serverless
BRANCH=extension-model

# Only if static
BRANCH=versioning

cd go-demo-6

git pull

git checkout $BRANCH

git merge -s ours master --no-edit

git checkout master

git merge $BRANCH

git push

cd ..
```

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
cd go-demo-6

jx import --pack go --batch-mode
```

Please wait until the activity of the application shows that all the steps were executed successfully, and stop the watcher by pressing *ctrl+c*.

Now we can promote our last release to production.

## Valero

```bash
# open "https://velero.io/"
```

## Upgrading The Cluster

NOTE: Outputs are from the serverless Jenkins X

```bash
jx version
```

```
NAME               VERSION
jx                 2.0.151
jenkins x platform 2.0.108
Kubernetes cluster v1.12.7-gke.10
kubectl            v1.14.2
helm client        Client: v2.14.0+g05811b8
git                git version 2.20.1 (Apple Git-117)
Operating System   Mac OS X 10.14.4 build 18E226
```

```bash
# NOTE: Upgrade if a new version is available

# NOTE: The same as `jx upgrade cli`

jx upgrade binaries

# TODO: It does not upgrade anything

jx upgrade platform --help
```

```
Upgrades the Jenkins X platform if there is a newer release

Aliases:
platform, install
Examples:
  # Upgrades the Jenkins X platform
  jx upgrade platform
Options:
      --always-upgrade=false: If set to true, jx will upgrade platform Helm chart even if requested version is already installed.
  -c, --chart='jenkins-x/jenkins-x-platform': The Chart to upgrade.
      --cleanup-temp-files=true: Cleans up any temporary values.yaml used by helm install [default true].
      --cloud-environment-repo='https://github.com/jenkins-x/cloud-environments': Cloud Environments Git repo
      --local-cloud-environment=false: Ignores default cloud-environment-repo and uses current directory 
  -n, --name='jenkins-x': The release name.
      --namespace='': The Namespace to promote to.
  -s, --set='': The helm parameters to pass in while upgrading, separated by comma, e.g. key1=val1,key2=val2.
      --update-secrets=false: Regenerate adminSecrets.yaml on upgrade
  -v, --version='': The specific platform version to upgrade to.
      --versions-ref='': Jenkins X versions Git repository reference (tag, branch, sha etc)
      --versions-repo='https://github.com/jenkins-x/jenkins-x-versions.git': Jenkins X versions Git repo
Usage:
  jx upgrade platform [flags] [options]
Use "jx options" for a list of global command-line options (applies to all commands).
```

```bash
# It should be `jx upgrade platform --version ...`, just as version should be specified in `jx create cluster` or `jx install`.

jx upgrade platform --batch-mode
```

```
Using provider 'gke' from team settings
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
using stable version 2.0.330 from charts of jenkins-x/jenkins-x-platform from /Users/vfarcic/.jx/jenkins-x-versions
Upgrading platform from version 2.0.108 to version 2.0.330
Cloning the Jenkins X cloud environments repo to /Users/vfarcic/.jx/cloud-environments
? A local Jenkins X cloud environments repository already exists, recreate with latest? Yes
Cloning the Jenkins X cloud environments repo to /Users/vfarcic/.jx/cloud-environments
Enumerating objects: 49, done.
Counting objects: 100% (49/49), done.
Compressing objects: 100% (36/36), done.
Total 1431 (delta 17), reused 33 (delta 13), pack-reused 1382
Creating /Users/vfarcic/.jx/adminSecrets.yaml from jx-install-config
Creating /Users/vfarcic/.jx/extraValues.yaml from jx-install-config
Using local value overrides file /Users/vfarcic/code/myvalues.yaml
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
Fetched chart jenkins-x/jenkins-x-platform to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-426064317/jenkins-x/chartFiles/jenkins-x-platform
Applying generated chart jenkins-x/jenkins-x-platform YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-426064317/jenkins-x/output
deployment.extensions/jenkins-x-chartmuseum configured
persistentvolumeclaim/jenkins-x-chartmuseum configured
secret/jenkins-x-chartmuseum configured
service/jenkins-x-chartmuseum configured
role.rbac.authorization.k8s.io/cleanup configured
rolebinding.rbac.authorization.k8s.io/cleanup configured
serviceaccount/cleanup configured
clusterrole.rbac.authorization.k8s.io/controllerbuild-cd configured
clusterrolebinding.rbac.authorization.k8s.io/controllerbuild-cd configured
deployment.apps/jenkins-x-controllerbuild configured
role.rbac.authorization.k8s.io/controllerbuild configured
rolebinding.rbac.authorization.k8s.io/controllerbuild configured
serviceaccount/jenkins-x-controllerbuild configured
clusterrole.rbac.authorization.k8s.io/controllerrole-cd configured
clusterrolebinding.rbac.authorization.k8s.io/controllerrole-cd configured
deployment.apps/jenkins-x-controllerrole configured
role.rbac.authorization.k8s.io/controllerrole configured
rolebinding.rbac.authorization.k8s.io/controllerrole configured
serviceaccount/jenkins-x-controllerrole configured
clusterrole.rbac.authorization.k8s.io/controllerteam-cd configured
clusterrolebinding.rbac.authorization.k8s.io/controllerteam-cd configured
deployment.apps/jenkins-x-controllerteam configured
role.rbac.authorization.k8s.io/controllerteam configured
rolebinding.rbac.authorization.k8s.io/controllerteam configured
serviceaccount/jenkins-x-controllerteam configured
configmap/jenkins-x-docker-registry-config created
deployment.extensions/jenkins-x-docker-registry created
persistentvolumeclaim/jenkins-x-docker-registry created
secret/jenkins-x-docker-registry-secret created
service/jenkins-x-docker-registry created
configmap/exposecontroller configured
role.rbac.authorization.k8s.io/expose configured
rolebinding.rbac.authorization.k8s.io/expose configured
serviceaccount/expose configured
clusterrole.rbac.authorization.k8s.io/gcactivities-cd configured
clusterrolebinding.rbac.authorization.k8s.io/gcactivities-cd configured
cronjob.batch/jenkins-x-gcactivities configured
role.rbac.authorization.k8s.io/gcactivities configured
rolebinding.rbac.authorization.k8s.io/gcactivities configured
serviceaccount/jenkins-x-gcactivities configured
cronjob.batch/jenkins-x-gcpods configured
role.rbac.authorization.k8s.io/gcpods configured
rolebinding.rbac.authorization.k8s.io/gcpods configured
serviceaccount/jenkins-x-gcpods configured
clusterrole.rbac.authorization.k8s.io/gcpreviews-cd configured
clusterrolebinding.rbac.authorization.k8s.io/gcpreviews-cd configured
cronjob.batch/jenkins-x-gcpreviews configured
role.rbac.authorization.k8s.io/gcpreviews configured
rolebinding.rbac.authorization.k8s.io/gcpreviews configured
serviceaccount/jenkins-x-gcpreviews configured
deployment.extensions/jenkins-x-heapster configured
clusterrolebinding.rbac.authorization.k8s.io/jenkins-x-heapster configured
role.rbac.authorization.k8s.io/jenkins-x-heapster-pod-nanny configured
rolebinding.rbac.authorization.k8s.io/jenkins-x-heapster-pod-nanny configured
service/heapster configured
serviceaccount/jenkins-x-heapster configured
deployment.extensions/jenkins-x-mongodb configured
persistentvolumeclaim/jenkins-x-mongodb configured
secret/jenkins-x-mongodb configured
service/jenkins-x-mongodb configured
configmap/jenkins-x-monocular-api-config configured
deployment.extensions/jenkins-x-monocular-api configured
service/jenkins-x-monocular-api configured
deployment.extensions/jenkins-x-monocular-prerender configured
service/jenkins-x-monocular-prerender configured
configmap/jenkins-x-monocular-ui-config configured
deployment.extensions/jenkins-x-monocular-ui configured
service/jenkins-x-monocular-ui configured
configmap/jenkins-x-monocular-ui-vhost configured
role.rbac.authorization.k8s.io/committer configured
clusterrolebinding.rbac.authorization.k8s.io/jenkins-x-team-controller configured
configmap/jenkins-x-team-controller configured
secret/jenkins-docker-cfg configured
configmap/jenkins-x-devpod-config configured
configmap/jenkins-x-docker-registry configured
configmap/jenkins-x-extensions configured
secret/jx-basic-auth configured
role.rbac.authorization.k8s.io/jx-view configured
secret/kaniko-secret configured
secret/jenkins-maven-settings configured
secret/jenkins-npm-token configured
role.rbac.authorization.k8s.io/owner configured
configmap/jenkins-x-pod-template-dlang configured
configmap/jenkins-x-pod-template-go configured
configmap/jenkins-x-pod-template-nodejs10x created
configmap/jenkins-x-pod-template-terraform configured
configmap/jenkins-x-pod-template-maven-nodejs configured
configmap/jenkins-x-pod-template-rust configured
configmap/jenkins-x-pod-template-machine-learning created
configmap/jenkins-x-pod-template-python2 configured
configmap/jenkins-x-pod-template-nodejs8x created
configmap/jenkins-x-pod-template-aws-cdk configured
configmap/jenkins-x-pod-template-newman configured
configmap/jenkins-x-pod-template-scala configured
configmap/jenkins-x-pod-template-gradle configured
configmap/jenkins-x-pod-template-maven configured
configmap/jenkins-x-pod-template-python37 configured
configmap/jenkins-x-pod-template-promote configured
configmap/jenkins-x-pod-template-nodejs configured
configmap/jenkins-x-pod-template-swift configured
configmap/jenkins-x-pod-template-maven-java11 configured
configmap/jenkins-x-pod-template-ruby configured
configmap/jenkins-x-pod-template-jx-base configured
configmap/jenkins-x-pod-template-python configured
secret/jenkins-release-gpg configured
secret/jenkins-ssh-config configured
role.rbac.authorization.k8s.io/viewer configured

Applying Helm hook post-upgrade YAML via kubectl in file: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-426064317/jenkins-x/helmHooks/jenkins-x-platform/charts/expose/templates/job.yaml
job.batch/expose created

Waiting for helm post-upgrade hook Job expose to complete before removing it
Deleting helm hook sources from file: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-426064317/jenkins-x/helmHooks/jenkins-x-platform/charts/expose/templates/job.yaml
job.batch "expose" deleted
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=jenkins-x,jenkins.io/version!=2.0.330 from all pvc configmap release sa role rolebinding secret
deployment.apps "jenkins-x-controllercommitstatus" deleted
serviceaccount "jenkins-x-controllercommitstatus" deleted
role.rbac.authorization.k8s.io "controllercommitstatus" deleted
rolebinding.rbac.authorization.k8s.io "controllercommitstatus" deleted
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=jenkins-x,jenkins.io/version!=2.0.330,jenkins.io/namespace=cd from clusterrole clusterrolebinding
clusterrole.rbac.authorization.k8s.io "controllercommitstatus-cd" deleted
clusterrolebinding.rbac.authorization.k8s.io "controllercommitstatus-cd" deleted
```

```bash
jx version
```

```
NAME               VERSION
jx                 2.0.151
jenkins x platform 2.0.330
Kubernetes cluster v1.12.7-gke.10
kubectl            v1.14.2
helm client        Client: v2.14.0+g05811b8
git                git version 2.20.1 (Apple Git-117)
Operating System   Mac OS X 10.14.4 build 18E226
```

```bash
jx get addons
```

```
NAME    CHART            ENABLED STATUS   VERSION
jx-prow jenkins-x/prow           DEPLOYED 0.0.647
jx-prow jenkins-x/prow           DEPLOYED 0.0.647
jx-prow jenkins-x/prow           DEPLOYED 0.0.647
jx-prow jenkins-x/prow           DEPLOYED 0.0.647
jx-prow jenkins-x/prow           DEPLOYED 0.0.647
jx-prow jenkins-x/prow           DEPLOYED 0.0.647
jx-prow jenkins-x/prow           DEPLOYED 0.0.647
jx-prow jenkins-x/prow           DEPLOYED 0.0.647
tekton  jenkins-x/tekton         DEPLOYED 0.0.38
tekton  jenkins-x/tekton         DEPLOYED 0.0.38
jx-prow jenkins-x/prow           DEPLOYED 0.0.647
```

```bash
jx upgrade addon
```

```
Upgrading jx-prow chart jenkins-x/prow...
Using local value overrides file /Users/vfarcic/code/myvalues.yaml
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
using stable version 0.0.647 from charts of jenkins-x/prow from /Users/vfarcic/.jx/jenkins-x-versions
Fetched chart jenkins-x/prow to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-210639022/jx-prow/chartFiles/prow
Applying generated chart jenkins-x/prow YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-210639022/jx-prow/output
clusterrole.rbac.authorization.k8s.io/prow-build unchanged
clusterrolebinding.rbac.authorization.k8s.io/prow-build-cd unchanged
deployment.extensions/prow-build configured
serviceaccount/prow-build unchanged
deployment.extensions/buildnum configured
rolebinding.rbac.authorization.k8s.io/buildnum unchanged
role.rbac.authorization.k8s.io/buildnum unchanged
serviceaccount/buildnum unchanged
service/buildnum unchanged
clusterrolebinding.rbac.authorization.k8s.io/cluster-admin-binding-cd unchanged
clusterrole.rbac.authorization.k8s.io/crier unchanged
clusterrolebinding.rbac.authorization.k8s.io/crier-cd unchanged
deployment.extensions/crier unchanged
rolebinding.rbac.authorization.k8s.io/crier unchanged
role.rbac.authorization.k8s.io/crier unchanged
serviceaccount/crier unchanged
deployment.extensions/deck unchanged
rolebinding.rbac.authorization.k8s.io/deck unchanged
role.rbac.authorization.k8s.io/deck unchanged
serviceaccount/deck unchanged
service/deck unchanged
secret/hmac-token configured
deployment.extensions/hook unchanged
rolebinding.rbac.authorization.k8s.io/hook unchanged
role.rbac.authorization.k8s.io/hook unchanged
serviceaccount/hook unchanged
service/hook unchanged
deployment.extensions/horologium unchanged
rolebinding.rbac.authorization.k8s.io/horologium unchanged
role.rbac.authorization.k8s.io/horologium unchanged
serviceaccount/horologium unchanged
secret/oauth-token configured
clusterrole.rbac.authorization.k8s.io/pipeline unchanged
clusterrolebinding.rbac.authorization.k8s.io/pipeline-cd unchanged
deployment.extensions/pipeline configured
serviceaccount/pipeline unchanged
deployment.extensions/plank unchanged
rolebinding.rbac.authorization.k8s.io/plank unchanged
role.rbac.authorization.k8s.io/plank unchanged
serviceaccount/plank unchanged
customresourcedefinition.apiextensions.k8s.io/prowjobs.prow.k8s.io unchanged
deployment.extensions/sinker unchanged
rolebinding.rbac.authorization.k8s.io/sinker unchanged
role.rbac.authorization.k8s.io/sinker unchanged
serviceaccount/sinker unchanged
deployment.extensions/tide unchanged
rolebinding.rbac.authorization.k8s.io/tide unchanged
role.rbac.authorization.k8s.io/tide unchanged
serviceaccount/tide unchanged
service/tide unchanged

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=jx-prow,jenkins.io/version!=0.0.647 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=jx-prow,jenkins.io/version!=0.0.647,jenkins.io/namespace=cd from clusterrole clusterrolebinding
Upgraded jx-prow chart jenkins-x/prow
Upgrading tekton chart jenkins-x/tekton...
Using local value overrides file /Users/vfarcic/code/myvalues.yaml
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
using stable version 0.0.38 from charts of jenkins-x/tekton from /Users/vfarcic/.jx/jenkins-x-versions
Fetched chart jenkins-x/tekton to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-210639022/tekton/chartFiles/tekton
Applying generated chart jenkins-x/tekton YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-210639022/tekton/output
podsecuritypolicy.policy/tekton-pipelines configured
clusterrole.rbac.authorization.k8s.io/tekton-pipelines unchanged
clusterrolebinding.rbac.authorization.k8s.io/tekton-pipelines-cd unchanged
serviceaccount/tekton-pipelines unchanged
serviceaccount/tekton-bot configured
customresourcedefinition.apiextensions.k8s.io/clustertasks.tekton.dev unchanged
customresourcedefinition.apiextensions.k8s.io/pipelines.tekton.dev unchanged
customresourcedefinition.apiextensions.k8s.io/pipelineruns.tekton.dev unchanged
customresourcedefinition.apiextensions.k8s.io/pipelineresources.tekton.dev unchanged
customresourcedefinition.apiextensions.k8s.io/tasks.tekton.dev unchanged
customresourcedefinition.apiextensions.k8s.io/taskruns.tekton.dev unchanged
service/tekton-pipelines-controller unchanged
service/tekton-pipelines-webhook unchanged
clusterrole.rbac.authorization.k8s.io/tekton-bot unchanged
clusterrolebinding.rbac.authorization.k8s.io/tekton-bot-cd unchanged
role.rbac.authorization.k8s.io/tekton-bot unchanged
rolebinding.rbac.authorization.k8s.io/tekton-bot unchanged
configmap/config-artifact-bucket configured
configmap/config-entrypoint unchanged
configmap/config-logging unchanged
deployment.apps/tekton-pipelines-controller unchanged
deployment.apps/tekton-pipelines-webhook unchanged

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=tekton,jenkins.io/version!=0.0.38 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=tekton,jenkins.io/version!=0.0.38,jenkins.io/namespace=cd from clusterrole clusterrolebinding
Upgraded tekton chart jenkins-x/tekton
```

```bash
# If could be `jx upgrade addon jx-prow`

jx get apps
```

```
No Apps found
```

```bash
# NOTE: It could be `jx upgrade app [...]`

jx upgrade crd
```

```
Jenkins X CRDs upgraded with success
```

```bash
jx upgrade extensions
```

```
WARNING: No extensions are configured for the team
Updating extensions from https://raw.githubusercontent.com/jenkins-x/jenkins-x-extensions/v0.0.30/jenkins-x-extensions-repository.lock.yaml
Upgrading to Extension Repository version 0.0.30
```

```bash
# `jx upgrade ingress`?
```

## Adding TLS Certificates

```bash 
jx get applications
```

```
APPLICATION  STAGING PODS URL
jx-go-demo-6 1.0.110 3/3  http://go-demo-6.cd-staging.35.243.230.195.nip.io
```

```bash
STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"
```

```
hello, PR!
```

```bash
STAGING_ADDR=[...] # Change to https

curl "$STAGING_ADDR/demo/hello"
```

```
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl performs SSL certificate verification by default, using a "bundle"
 of Certificate Authority (CA) public keys (CA certs). If the default
 bundle file isn't adequate, you can specify an alternate file
 using the --cacert option.
If this HTTPS server uses a certificate signed by a CA represented in
 the bundle, the certificate verification probably failed due to a
 problem with the certificate (it might be expired, or the name might
 not match the domain name in the URL).
If you'd like to turn off curl's verification of the certificate, use
 the -k (or --insecure) option.
HTTPS-proxy has similar options --proxy-cacert and --proxy-insecure.
```

```bash
LB_IP=$(kubectl \
    --namespace kube-system \
    get svc jxing-nginx-ingress-controller \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo $LB_IP
```

```
35.243.230.195
```

```bash
# If do not have a domain
DOMAIN=$LB_IP.nip.io

# If do have a domain
DOMAIN=[...]

# NOTE: Change your DNS A records in your domain registrar. Wait for at least one hour until DNS records are propagated.

ping $DOMAIN
```

```
PING 35.243.230.195.nip.io (35.243.230.195): 56 data bytes
64 bytes from 35.243.230.195: icmp_seq=0 ttl=39 time=392.406 ms
64 bytes from 35.243.230.195: icmp_seq=1 ttl=39 time=405.278 ms
```

```bash
# Cancel with *ctrl+c*

# Repeat it the domain is not pingable or the IP is not the correct one

jx upgrade ingress --help
```

```
Upgrades the Jenkins X Ingress rules

Aliases:
ingress, ing
Examples:
  # Upgrades the Jenkins X Ingress rules
  jx upgrade ingress
Options:
      --cluster=false: Enable cluster wide Ingress upgrade
      --config-namespace='': Namespace where the ingress-config is stored (if empty, it will try to read it from Dev environment namespace)
      --domain='': Domain to expose ingress endpoints (e.g., jenkinsx.io). Leave empty to preserve the current value.
      --force=false: Forces upgrades of all webooks even if ingress URL has not changed
      --namespaces=[]: Namespaces to upgrade
      --services=[]: Services to upgrade
      --skip-certmanager=false: Skips cert-manager installation
      --skip-resources-update=false: Skips the update of jx related resources such as webhook or Jenkins URL
      --urltemplate='': For ingress; exposers can set the urltemplate to expose. The default value is "{{.Service}}.{{.Namespace}}.{{.Domain}}". Leave empty to preserve the current value.
      --wait-for-certs=true: Waits for TLS certs to be issued by cert-manager
Usage:
  jx upgrade ingress [flags] [options]
Use "jx options" for a list of global command-line options (applies to all commands).
```

```bash
jx upgrade ingress \
    --cluster true \
    --domain $DOMAIN

# NOTE: It takes a while...
```

```
? Existing ingress rules found in the cluster.  Confirm to delete all and recreate them Yes
? Expose type Ingress
? Domain: 35.243.230.195.nip.io
? If your network is publicly available would you like to enable cluster wide TLS? Yes

If testing LetsEncrypt you should use staging as you may be rate limited using production.
? Use LetsEncrypt staging or production? production
? Email address to register with LetsEncrypt: viktor@farcic.com
? UrlTemplate (press <Enter> to keep the current value):
? Using config values {viktor@farcic.com 35.243.230.195.nip.io letsencrypt-prod false Ingress  true}, ok? Yes

Looking for "cert-manager" deployment in namespace "cert-manager"...
? CertManager deployment not found, shall we install it now? Yes

Installing cert-manager...
Installing CRDs from "https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml"...
customresourcedefinition.apiextensions.k8s.io/certificates.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/issuers.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/orders.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/challenges.certmanager.k8s.io created
Installing the chart "stable/cert-manager" in namespace "cert-manager"...
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
using stable version v0.6.7 from charts of stable/cert-manager from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Namespace cert-manager created

Fetched chart stable/cert-manager to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/cert-manager/chartFiles/cert-manager
Applying generated chart stable/cert-manager YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/cert-manager/output
deployment.apps/cert-manager created
clusterrole.rbac.authorization.k8s.io/cert-manager created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager created
clusterrole.rbac.authorization.k8s.io/cert-manager-view created
clusterrole.rbac.authorization.k8s.io/cert-manager-edit created
serviceaccount/cert-manager created

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=cert-manager,jenkins.io/version!=v0.6.7 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=cert-manager,jenkins.io/version!=v0.6.7,jenkins.io/namespace=cert-manager from clusterrole clusterrolebinding
Waiting for CertManager deployment to be ready, this can take a few minutes
Deleting ingress cd-staging/go-demo-6
Deleting ingress cd/chartmuseum
Deleting ingress cd/deck
Deleting ingress cd/docker-registry
Deleting ingress cd/hook
Deleting ingress cd/monocular
Deleting ingress cd/tide
Expecting certificates: [cd/tls-tide cd/tls-docker-registry cd/tls-hook cd/tls-monocular cd/tls-chartmuseum cd/tls-deck cd-staging/tls-go-demo-6]
Certificate issuer letsencrypt-prod does not exist. Creating...
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
using stable version 2.3.111 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Fetched chart jenkins-x/exposecontroller to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-boarlightning/chartFiles/exposecontroller
Applying generated chart jenkins-x/exposecontroller YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-boarlightning/output
configmap/exposecontroller created
job.batch/exposecontroller created
role.rbac.authorization.k8s.io/exposecontroller created
rolebinding.rbac.authorization.k8s.io/exposecontroller created
serviceaccount/exposecontroller created

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-boarlightning,jenkins.io/version!=2.3.111 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-boarlightning,jenkins.io/version!=2.3.111,jenkins.io/namespace=cd from clusterrole clusterrolebinding
Removing Kubernetes resources from release expose-boarlightning using selector: jenkins.io/chart-release=expose-boarlightning from all pvc configmap release sa role rolebinding secret
Ready Cert: cd/tls-tide
job.batch "exposecontroller" deleted
configmap "exposecontroller" deleted
serviceaccount "exposecontroller" deleted
role.rbac.authorization.k8s.io "exposecontroller" deleted
rolebinding.rbac.authorization.k8s.io "exposecontroller" deleted
Removing Kubernetes resources from release expose-boarlightning using selector: jenkins.io/chart-release=expose-boarlightning,jenkins.io/namespace=cd from clusterrole clusterrolebinding
Certificate issuer letsencrypt-prod does not exist. Creating...
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
using stable version 2.3.111 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Fetched chart jenkins-x/exposecontroller to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-scourgegreat/chartFiles/exposecontroller
Applying generated chart jenkins-x/exposecontroller YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-scourgegreat/output
configmap/exposecontroller created
job.batch/exposecontroller created
role.rbac.authorization.k8s.io/exposecontroller created
rolebinding.rbac.authorization.k8s.io/exposecontroller created
serviceaccount/exposecontroller created

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-scourgegreat,jenkins.io/version!=2.3.111 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-scourgegreat,jenkins.io/version!=2.3.111,jenkins.io/namespace=cd-production from clusterrole clusterrolebinding
Removing Kubernetes resources from release expose-scourgegreat using selector: jenkins.io/chart-release=expose-scourgegreat from all pvc configmap release sa role rolebinding secret
job.batch "exposecontroller" deleted
configmap "exposecontroller" deleted
serviceaccount "exposecontroller" deleted
role.rbac.authorization.k8s.io "exposecontroller" deleted
rolebinding.rbac.authorization.k8s.io "exposecontroller" deleted
Removing Kubernetes resources from release expose-scourgegreat using selector: jenkins.io/chart-release=expose-scourgegreat,jenkins.io/namespace=cd-production from clusterrole clusterrolebinding
Certificate issuer letsencrypt-prod does not exist. Creating...
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
using stable version 2.3.111 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Fetched chart jenkins-x/exposecontroller to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-thunderrose/chartFiles/exposecontroller
Applying generated chart jenkins-x/exposecontroller YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-thunderrose/output
configmap/exposecontroller created
job.batch/exposecontroller created
role.rbac.authorization.k8s.io/exposecontroller created
rolebinding.rbac.authorization.k8s.io/exposecontroller created
serviceaccount/exposecontroller created

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-thunderrose,jenkins.io/version!=2.3.111 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-thunderrose,jenkins.io/version!=2.3.111,jenkins.io/namespace=cd-staging from clusterrole clusterrolebinding
Removing Kubernetes resources from release expose-thunderrose using selector: jenkins.io/chart-release=expose-thunderrose from all pvc configmap release sa role rolebinding secret
job.batch "exposecontroller" deleted
configmap "exposecontroller" deleted
serviceaccount "exposecontroller" deleted
role.rbac.authorization.k8s.io "exposecontroller" deleted
rolebinding.rbac.authorization.k8s.io "exposecontroller" deleted
Removing Kubernetes resources from release expose-thunderrose using selector: jenkins.io/chart-release=expose-thunderrose,jenkins.io/namespace=cd-staging from clusterrole clusterrolebinding
Certificate issuer letsencrypt-prod does not exist. Creating...
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
using stable version 2.3.111 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Fetched chart jenkins-x/exposecontroller to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-jackalshore/chartFiles/exposecontroller
Applying generated chart jenkins-x/exposecontroller YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-jackalshore/output
configmap/exposecontroller created
job.batch/exposecontroller created
role.rbac.authorization.k8s.io/exposecontroller created
rolebinding.rbac.authorization.k8s.io/exposecontroller created
serviceaccount/exposecontroller created

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-jackalshore,jenkins.io/version!=2.3.111 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-jackalshore,jenkins.io/version!=2.3.111,jenkins.io/namespace=default from clusterrole clusterrolebinding
Removing Kubernetes resources from release expose-jackalshore using selector: jenkins.io/chart-release=expose-jackalshore from all pvc configmap release sa role rolebinding secret
job.batch "exposecontroller" deleted
configmap "exposecontroller" deleted
serviceaccount "exposecontroller" deleted
role.rbac.authorization.k8s.io "exposecontroller" deleted
rolebinding.rbac.authorization.k8s.io "exposecontroller" deleted
Removing Kubernetes resources from release expose-jackalshore using selector: jenkins.io/chart-release=expose-jackalshore,jenkins.io/namespace=default from clusterrole clusterrolebinding
Certificate issuer letsencrypt-prod does not exist. Creating...
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
using stable version 2.3.111 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Fetched chart jenkins-x/exposecontroller to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-geckocaramel/chartFiles/exposecontroller
Applying generated chart jenkins-x/exposecontroller YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-geckocaramel/output
configmap/exposecontroller created
job.batch/exposecontroller created
role.rbac.authorization.k8s.io/exposecontroller created
rolebinding.rbac.authorization.k8s.io/exposecontroller created
serviceaccount/exposecontroller created

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-geckocaramel,jenkins.io/version!=2.3.111 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-geckocaramel,jenkins.io/version!=2.3.111,jenkins.io/namespace=kube-public from clusterrole clusterrolebinding
Removing Kubernetes resources from release expose-geckocaramel using selector: jenkins.io/chart-release=expose-geckocaramel from all pvc configmap release sa role rolebinding secret
job.batch "exposecontroller" deleted
configmap "exposecontroller" deleted
serviceaccount "exposecontroller" deleted
role.rbac.authorization.k8s.io "exposecontroller" deleted
rolebinding.rbac.authorization.k8s.io "exposecontroller" deleted
Removing Kubernetes resources from release expose-geckocaramel using selector: jenkins.io/chart-release=expose-geckocaramel,jenkins.io/namespace=kube-public from clusterrole clusterrolebinding
Certificate issuer letsencrypt-prod does not exist. Creating...
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Total 1465 (delta 0), reused 1 (delta 0), pack-reused 1464
using stable version 2.3.111 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Fetched chart jenkins-x/exposecontroller to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-gorillaevening/chartFiles/exposecontroller
Applying generated chart jenkins-x/exposecontroller YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-518434497/expose-gorillaevening/output
configmap/exposecontroller created
job.batch/exposecontroller created
role.rbac.authorization.k8s.io/exposecontroller created
rolebinding.rbac.authorization.k8s.io/exposecontroller created
serviceaccount/exposecontroller created

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-gorillaevening,jenkins.io/version!=2.3.111 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-gorillaevening,jenkins.io/version!=2.3.111,jenkins.io/namespace=kube-system from clusterrole clusterrolebinding
Removing Kubernetes resources from release expose-gorillaevening using selector: jenkins.io/chart-release=expose-gorillaevening from all pvc configmap release sa role rolebinding secret
job.batch "exposecontroller" deleted
configmap "exposecontroller" deleted
serviceaccount "exposecontroller" deleted
role.rbac.authorization.k8s.io "exposecontroller" deleted
rolebinding.rbac.authorization.k8s.io "exposecontroller" deleted
Removing Kubernetes resources from release expose-gorillaevening using selector: jenkins.io/chart-release=expose-gorillaevening,jenkins.io/namespace=kube-system from clusterrole clusterrolebinding
Ingress rules recreated

Waiting for TLS certificates to be issued...
WARNING: Timeout reached while waiting for TLS certificates to be ready
Previous webhook endpoint http://hook.cd.35.243.230.195.nip.io/hook
Updated webhook endpoint https://hook.cd.35.243.230.195.nip.io/hook
? Do you want to update all existing webhooks? Yes

Updating all webHooks from http://hook.cd.35.243.230.195.nip.io/hook to https://hook.cd.35.243.230.195.nip.io/hook
? Which organisation do you want to use? vfarcic
Owner of repo is same as username, using GitHub API for Users
Found 222 repos
Checking hooks for repository adpon with user vfarcic
Checking hooks for repository angular-web-ui-sample with user vfarcic
Checking hooks for repository ansible-blue-green with user vfarcic
Checking hooks for repository ansible-workshop with user vfarcic
Checking hooks for repository articles with user vfarcic
Checking hooks for repository blue-green-docker-jenkins with user vfarcic
Checking hooks for repository books-fe with user vfarcic
Checking hooks for repository books-fe-polymer with user vfarcic
Checking hooks for repository books-ms with user vfarcic
Checking hooks for repository books-service with user vfarcic
Checking hooks for repository books-stress with user vfarcic
Checking hooks for repository cd-workshop with user vfarcic
Checking hooks for repository charts with user vfarcic
Checking hooks for repository chat with user vfarcic
Checking hooks for repository cloud-provisioning with user vfarcic
Checking hooks for repository continuous-deployment with user vfarcic
Checking hooks for repository dc18_supply_chain with user vfarcic
Checking hooks for repository dev-for-dummies with user vfarcic
Checking hooks for repository devops-toolkit with user vfarcic
Checking hooks for repository devops20toolkit with user vfarcic
Checking hooks for repository devops22-infra with user vfarcic
Checking hooks for repository dfp-ui with user vfarcic
Checking hooks for repository docker-aws-cli with user vfarcic
Checking hooks for repository docker-build-publish-plugin with user vfarcic
Checking hooks for repository docker-build-step-plugin with user vfarcic
Checking hooks for repository docker-commons-plugin with user vfarcic
Checking hooks for repository docker-elasticdump with user vfarcic
Checking hooks for repository docker-flow with user vfarcic
Checking hooks for repository docker-flow-blue-green with user vfarcic
Checking hooks for repository docker-flow-cron with user vfarcic
Checking hooks for repository docker-flow-hub with user vfarcic
Checking hooks for repository docker-flow-jenkins with user vfarcic
Checking hooks for repository docker-flow-proxy with user vfarcic
Checking hooks for repository docker-flow-stacks with user vfarcic
Checking hooks for repository docker-flow-swarm-listener with user vfarcic
Checking hooks for repository docker-jenkins-slave-dind with user vfarcic
Checking hooks for repository docker-logging-elk with user vfarcic
Checking hooks for repository docker-mongo with user vfarcic
Checking hooks for repository docker-mongo-dump with user vfarcic
Checking hooks for repository docker-swarm with user vfarcic
Checking hooks for repository docker-swarm-blue-green with user vfarcic
Checking hooks for repository docker-swarm-networking with user vfarcic
Checking hooks for repository docker-sync with user vfarcic
Checking hooks for repository dockerbythecaptains with user vfarcic
Checking hooks for repository eksctl with user vfarcic
Checking hooks for repository elasticsearch-shield with user vfarcic
Checking hooks for repository environment-tekton-production with user vfarcic
Found matching hook for url http://hook.cd.35.243.230.195.nip.io/hook
Updating GitHub webhook for vfarcic/environment-tekton-production for url https://hook.cd.35.243.230.195.nip.io/hook
Checking hooks for repository environment-tekton-staging with user vfarcic
Found matching hook for url http://hook.cd.35.243.230.195.nip.io/hook
Updating GitHub webhook for vfarcic/environment-tekton-staging for url https://hook.cd.35.243.230.195.nip.io/hook
Checking hooks for repository environment-viktor-production with user vfarcic
Checking hooks for repository environment-viktor-staging with user vfarcic
Checking hooks for repository fake-repo with user vfarcic
Checking hooks for repository fargate-specs with user vfarcic
Checking hooks for repository foo-protocol with user vfarcic
Checking hooks for repository gigya with user vfarcic
Checking hooks for repository go-demo with user vfarcic
Checking hooks for repository go-demo-2 with user vfarcic
Checking hooks for repository go-demo-3 with user vfarcic
Checking hooks for repository go-demo-4 with user vfarcic
Checking hooks for repository go-demo-5 with user vfarcic
Checking hooks for repository go-demo-6 with user vfarcic
Found matching hook for url http://hook.cd.35.243.230.195.nip.io/hook
Updating GitHub webhook for vfarcic/go-demo-6 for url https://hook.cd.35.243.230.195.nip.io/hook
Checking hooks for repository go-demo-7 with user vfarcic
Checking hooks for repository go-demo-cje with user vfarcic
Checking hooks for repository go-practice with user vfarcic
Checking hooks for repository hacker-rank with user vfarcic
Checking hooks for repository helm with user vfarcic
Checking hooks for repository infoq-docker-cd with user vfarcic
Checking hooks for repository intro-to-declarative-pipeline with user vfarcic
Checking hooks for repository java-8-exercises with user vfarcic
Checking hooks for repository JavaBuildTools with user vfarcic
Checking hooks for repository jenkins-cm with user vfarcic
Checking hooks for repository jenkins-docker-ansible with user vfarcic
Checking hooks for repository jenkins-docker-showcase with user vfarcic
Checking hooks for repository jenkins-go-agent with user vfarcic
Checking hooks for repository jenkins-jdk-docker-agent with user vfarcic
Checking hooks for repository jenkins-pipeline-docker with user vfarcic
Checking hooks for repository jenkins-shared-libraries with user vfarcic
Checking hooks for repository jenkins-swarm with user vfarcic
Checking hooks for repository jenkins-x-classic with user vfarcic
Checking hooks for repository jenkins-x-kubernetes with user vfarcic
Checking hooks for repository joostvdg.github.io with user vfarcic
Checking hooks for repository jx with user vfarcic
Checking hooks for repository jx-docs with user vfarcic
Checking hooks for repository k8s-prod with user vfarcic
Checking hooks for repository k8s-specs with user vfarcic
Checking hooks for repository k8s-viktor with user vfarcic
Checking hooks for repository kaniko with user vfarcic
Checking hooks for repository kata-java with user vfarcic
Checking hooks for repository kata-javascript with user vfarcic
Checking hooks for repository kata-scala with user vfarcic
Checking hooks for repository katacoda-scenarios with user vfarcic
Checking hooks for repository kops with user vfarcic
Checking hooks for repository kubectl with user vfarcic
Checking hooks for repository laravel-blog with user vfarcic
Checking hooks for repository liferay-swarm with user vfarcic
Checking hooks for repository mars-rover-kata-java with user vfarcic
Checking hooks for repository mars-rover-kata-java-script with user vfarcic
Checking hooks for repository mrtch with user vfarcic
Checking hooks for repository ms-lifecycle with user vfarcic
Checking hooks for repository my-project2 with user vfarcic
Checking hooks for repository oauth with user vfarcic
Checking hooks for repository adpon with user vfarcic
Checking hooks for repository angular-web-ui-sample with user vfarcic
Checking hooks for repository ansible-blue-green with user vfarcic
Checking hooks for repository ansible-workshop with user vfarcic
Checking hooks for repository articles with user vfarcic
Checking hooks for repository blue-green-docker-jenkins with user vfarcic
Checking hooks for repository books-fe with user vfarcic
Checking hooks for repository books-fe-polymer with user vfarcic
Checking hooks for repository books-ms with user vfarcic
Checking hooks for repository books-service with user vfarcic
Checking hooks for repository books-stress with user vfarcic
Checking hooks for repository cd-workshop with user vfarcic
Checking hooks for repository charts with user vfarcic
Checking hooks for repository chat with user vfarcic
Checking hooks for repository cloud-provisioning with user vfarcic
Checking hooks for repository continuous-deployment with user vfarcic
Checking hooks for repository dc18_supply_chain with user vfarcic
Checking hooks for repository dev-for-dummies with user vfarcic
Checking hooks for repository devops-toolkit with user vfarcic
Checking hooks for repository devops20toolkit with user vfarcic
Checking hooks for repository devops22-infra with user vfarcic
Checking hooks for repository dfp-ui with user vfarcic
Checking hooks for repository docker-aws-cli with user vfarcic
Checking hooks for repository docker-build-publish-plugin with user vfarcic
Checking hooks for repository docker-build-step-plugin with user vfarcic
Checking hooks for repository docker-commons-plugin with user vfarcic
Checking hooks for repository docker-elasticdump with user vfarcic
Checking hooks for repository docker-flow with user vfarcic
Checking hooks for repository docker-flow-blue-green with user vfarcic
Checking hooks for repository docker-flow-cron with user vfarcic
Checking hooks for repository docker-flow-hub with user vfarcic
Checking hooks for repository docker-flow-jenkins with user vfarcic
Checking hooks for repository docker-flow-proxy with user vfarcic
Checking hooks for repository docker-flow-stacks with user vfarcic
Checking hooks for repository docker-flow-swarm-listener with user vfarcic
Checking hooks for repository docker-jenkins-slave-dind with user vfarcic
Checking hooks for repository docker-logging-elk with user vfarcic
Checking hooks for repository docker-mongo with user vfarcic
Checking hooks for repository docker-mongo-dump with user vfarcic
Checking hooks for repository docker-swarm with user vfarcic
Checking hooks for repository docker-swarm-blue-green with user vfarcic
Checking hooks for repository docker-swarm-networking with user vfarcic
Checking hooks for repository docker-sync with user vfarcic
Checking hooks for repository dockerbythecaptains with user vfarcic
Checking hooks for repository eksctl with user vfarcic
Checking hooks for repository elasticsearch-shield with user vfarcic
Checking hooks for repository environment-tekton-production with user vfarcic
Checking hooks for repository environment-tekton-staging with user vfarcic
Checking hooks for repository environment-viktor-production with user vfarcic
Checking hooks for repository environment-viktor-staging with user vfarcic
Checking hooks for repository fake-repo with user vfarcic
Checking hooks for repository fargate-specs with user vfarcic
Checking hooks for repository foo-protocol with user vfarcic
Checking hooks for repository gigya with user vfarcic
Checking hooks for repository go-demo with user vfarcic
Checking hooks for repository go-demo-2 with user vfarcic
Checking hooks for repository go-demo-3 with user vfarcic
Checking hooks for repository go-demo-4 with user vfarcic
Checking hooks for repository go-demo-5 with user vfarcic
Checking hooks for repository go-demo-6 with user vfarcic
Checking hooks for repository go-demo-7 with user vfarcic
Checking hooks for repository go-demo-cje with user vfarcic
Checking hooks for repository go-practice with user vfarcic
Checking hooks for repository hacker-rank with user vfarcic
Checking hooks for repository helm with user vfarcic
Checking hooks for repository infoq-docker-cd with user vfarcic
Checking hooks for repository intro-to-declarative-pipeline with user vfarcic
Checking hooks for repository java-8-exercises with user vfarcic
Checking hooks for repository JavaBuildTools with user vfarcic
Checking hooks for repository jenkins-cm with user vfarcic
Checking hooks for repository jenkins-docker-ansible with user vfarcic
Checking hooks for repository jenkins-docker-showcase with user vfarcic
Checking hooks for repository jenkins-go-agent with user vfarcic
Checking hooks for repository jenkins-jdk-docker-agent with user vfarcic
Checking hooks for repository jenkins-pipeline-docker with user vfarcic
Checking hooks for repository jenkins-shared-libraries with user vfarcic
Checking hooks for repository jenkins-swarm with user vfarcic
Checking hooks for repository jenkins-x-classic with user vfarcic
Checking hooks for repository jenkins-x-kubernetes with user vfarcic
Checking hooks for repository joostvdg.github.io with user vfarcic
Checking hooks for repository jx with user vfarcic
Checking hooks for repository jx-docs with user vfarcic
Checking hooks for repository k8s-prod with user vfarcic
Checking hooks for repository k8s-specs with user vfarcic
Checking hooks for repository k8s-viktor with user vfarcic
Checking hooks for repository kaniko with user vfarcic
Checking hooks for repository kata-java with user vfarcic
Checking hooks for repository kata-javascript with user vfarcic
Checking hooks for repository kata-scala with user vfarcic
Checking hooks for repository katacoda-scenarios with user vfarcic
Checking hooks for repository kops with user vfarcic
Checking hooks for repository kubectl with user vfarcic
Checking hooks for repository laravel-blog with user vfarcic
Checking hooks for repository liferay-swarm with user vfarcic
Checking hooks for repository mars-rover-kata-java with user vfarcic
Checking hooks for repository mars-rover-kata-java-script with user vfarcic
Checking hooks for repository mrtch with user vfarcic
Checking hooks for repository ms-lifecycle with user vfarcic
Checking hooks for repository my-project2 with user vfarcic
Checking hooks for repository oauth with user vfarcic
Checking hooks for repository openshift-client with user vfarcic
Checking hooks for repository orchestration-workshop with user vfarcic
Checking hooks for repository play-with-docker.github.io with user vfarcic
Checking hooks for repository playJavaAngularSample with user vfarcic
Checking hooks for repository playScalaAngularSample with user vfarcic
Checking hooks for repository polymer with user vfarcic
Checking hooks for repository provisioning with user vfarcic
Checking hooks for repository servers with user vfarcic
Checking hooks for repository services-check with user vfarcic
Checking hooks for repository silly-demo with user vfarcic
Checking hooks for repository Software-Craftsmanship-Barcelona-2014 with user vfarcic
Checking hooks for repository solr with user vfarcic
Checking hooks for repository sprayAngularSample with user vfarcic
Checking hooks for repository TechnologyConversations with user vfarcic
Checking hooks for repository TechnologyConversationsBooks with user vfarcic
Checking hooks for repository TechnologyConversationsCD with user vfarcic
Checking hooks for repository TechnologyConversationsJava with user vfarcic
Checking hooks for repository TechnologyConversationsScala with user vfarcic
Checking hooks for repository TechnologyConversationsServers with user vfarcic
Checking hooks for repository TechnologyConversationsUserManagement with user vfarcic
Checking hooks for repository vfarcic.github.io with user vfarcic
Checking hooks for repository workflow-plugin with user vfarcic
```

```bash
kubectl --namespace cert-manager \
    logs --selector app=cert-manager
```

```
I0521 21:16:15.150384       1 logger.go:83] Calling CreateAccount
I0521 21:16:15.269812       1 setup.go:187] letsencrypt-prod: verified existing registration with ACME server
I0521 21:16:15.269871       1 helpers.go:89] Setting lastTransitionTime for Issuer "letsencrypt-prod" condition "Ready" to 2019-05-21 21:16:15.269863142 +0000 UTC m=+432.181032655
I0521 21:16:15.375380       1 controller.go:148] issuers controller: Finished processing work item "kube-system/letsencrypt-prod"
I0521 21:16:15.375462       1 controller.go:142] issuers controller: syncing item 'kube-system/letsencrypt-prod'
I0521 21:16:15.376037       1 setup.go:149] Skipping re-verifying ACME account as cached registration details look sufficient.
I0521 21:16:15.376069       1 controller.go:148] issuers controller: Finished processing work item "kube-system/letsencrypt-prod"
I0521 21:16:19.887757       1 controller.go:142] issuers controller: syncing item 'kube-system/letsencrypt-prod'
I0521 21:16:19.888142       1 setup.go:149] Skipping re-verifying ACME account as cached registration details look sufficient.
I0521 21:16:19.888191       1 controller.go:148] issuers controller: Finished processing work item "kube-system/letsencrypt-prod"
```

```bash
jx get applications
```

```
APPLICATION  STAGING PODS URL
jx-go-demo-6 1.0.110 3/3  https://go-demo-6.cd-staging.35.243.230.195.nip.io
```

```bash
STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"
```

```
hello, PR!
```

```bash
jx repo --batch-mode

# Settings > Webhooks
```

![Figure 14-TODO: TODO](images/ch14/upgraded-webhook.png)

```bash
# NOTE: Wait for 2 hours to be safe.

echo "I am too lazy to write a README" \
    | tee README.md

git add .

git commit -m "Checking webhooks"

git push

jx get activities \
    --filter go-demo-6 \
    --watch

# NOTE: If the new activity is not running, GitHub probably cannot reach the cluster through the new domain. The DNS is probably not yet propagated. Wait for a while (e.g., 1 hour), open the repo webhooks screen, enter the webhook, select the most recent (failed) delivery, and click the *Redeliver* button.
```

```
STEP                        STARTED AGO DURATION STATUS
vfarcic/go-demo-6/master #1                      Running Version: 1.0.119
  Release                        1h5m2s     1m0s Succeeded
  Promote: staging               1h4m2s     1m6s Succeeded
    PullRequest                  1h4m2s     1m6s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/1 Merge SHA: bb845816a414ba1fd42798e4ee59f5ed79a413e8
    Update                      1h2m56s       0s Succeeded
vfarcic/go-demo-6/master #2                      Running Version: 1.0.121
  Release                         2m11s     1m0s Succeeded
  Promote: staging                1m11s     1m5s Succeeded
    PullRequest                   1m11s     1m5s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/3 Merge SHA: 3066b13d2f12dbf5339b7323acaaad1fa81acb3f
    Update                           6s       0s Succeeded
    Promoted                         6s       0s Succeeded  Application is at: https://go-demo-6.cd-staging.35.243.230.195.nip.io
```

## Changing Domain Patterns

```bash
jx get applications
```

```
APPLICATION  STAGING PODS URL
jx-go-demo-6 1.0.110 3/3  https://go-demo-6.cd-staging.35.243.230.195.nip.io
```

```bash
# If static
NAMESPACE=jx

# If serverless
NAMESPACE=cd

jx upgrade ingress \
    --namespaces $NAMESPACE-staging \
    --urltemplate "{{.Service}}.staging.{{.Domain}}"
```

```
? Existing ingress rules found in namespaces [cd-staging] namespace.  Confirm to delete and recreate them Yes
? Expose type Ingress
? Domain: 35.243.230.195.nip.io
? UrlTemplate (press <Enter> to keep the current value): "{{.Service}}.staging.{{.Domain}}"
? Using config values {viktor@farcic.com 35.243.230.195.nip.io letsencrypt-prod false Ingress "{{.Service}}.staging.{{.Domain}}" true}, ok? Yes

Looking for "cert-manager" deployment in namespace "cert-manager"...
Deleting ingress cd-staging/go-demo-6
Expecting certificates: [cd-staging/tls-go-demo-6]
Ready Cert: cd/tls-deck
Ready Cert: cd/tls-hook
Ready Cert: cd/tls-tide
Ready Cert: cd/tls-monocular
Ready Cert: cd/tls-chartmuseum
Certificate issuer letsencrypt-prod already configured.
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 12, done.
Counting objects: 100% (12/12), done.
Compressing objects: 100% (5/5), done.
Total 1476 (delta 7), reused 10 (delta 7), pack-reused 1464
using stable version 2.3.111 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Fetched chart jenkins-x/exposecontroller to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-035079751/expose-cougarstar/chartFiles/exposecontroller
Applying generated chart jenkins-x/exposecontroller YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-035079751/expose-cougarstar/output
configmap/exposecontroller created
job.batch/exposecontroller created
role.rbac.authorization.k8s.io/exposecontroller created
rolebinding.rbac.authorization.k8s.io/exposecontroller created
serviceaccount/exposecontroller created

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-cougarstar,jenkins.io/version!=2.3.111 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-cougarstar,jenkins.io/version!=2.3.111,jenkins.io/namespace=cd-staging from clusterrole clusterrolebinding
Removing Kubernetes resources from release expose-cougarstar using selector: jenkins.io/chart-release=expose-cougarstar from all pvc configmap release sa role rolebinding secret
job.batch "exposecontroller" deleted
configmap "exposecontroller" deleted
serviceaccount "exposecontroller" deleted
role.rbac.authorization.k8s.io "exposecontroller" deleted
rolebinding.rbac.authorization.k8s.io "exposecontroller" deleted
Removing Kubernetes resources from release expose-cougarstar using selector: jenkins.io/chart-release=expose-cougarstar,jenkins.io/namespace=cd-staging from clusterrole clusterrolebinding
Ingress rules recreated

Waiting for TLS certificates to be issued...
Ready Cert: cd-staging/tls-go-demo-6
All TLS certificates are ready

Previous webhook endpoint https://hook.cd.35.243.230.195.nip.io/hook
Updated webhook endpoint https://hook.cd.35.243.230.195.nip.io/hook
? Do you want to update all existing webhooks? Yes

Webhook URL unchanged. Use --force to force updating
```

```bash
jx get applications
```

```
APPLICATION  STAGING PODS URL
jx-go-demo-6 1.0.110 3/3  https://go-demo-6.staging.35.243.230.195.nip.io
```

```bash
VERSION=[...]

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"
```

```
hello, PR!
```

```bash
jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    --batch-mode
```

```
WARNING: prow based install so skip waiting for the merge of Pull Requests to go green as currently there is an issue with gettingstatuses from the PR, see https://github.com/jenkins-x/jx/issues/2410
Promoting app go-demo-6 version 1.0.121 to namespace cd-production
pipeline vfarcic/go-demo-6/master
WARNING: No $BUILD_NUMBER environment variable found so cannot record promotion activities into the PipelineActivity resources in kubernetes
Created Pull Request: https://github.com/vfarcic/environment-tekton-production/pull/1
pipeline vfarcic/go-demo-6/master
WARNING: No $BUILD_NUMBER environment variable found so cannot record promotion activities into the PipelineActivity resources in kubernetes
Pull Request https://github.com/vfarcic/environment-tekton-production/pull/1 is merged at sha 27162d8ee2cf8922020192c200f21a1312f98112
Pull Request merged but we are not waiting for the update pipeline to complete!
WARNING: Could not find the service URL in namespace cd-production for names go-demo-6, cd-production-go-demo-6, cd-production-go-demo-6
```

```bash
jx get applications --env production
```

```
APPLICATION PRODUCTION PODS URL
go-demo-6   1.0.121    3/3  http://go-demo-6.cd-production.35.243.230.195.nip.io
```

```bash
PROD_ADDR=[...]

curl "$PROD_ADDR/demo/hello"
```

```
hello, PR!
```

```bash
jx upgrade ingress \
    --namespaces $NAMESPACE-production \
    --urltemplate "{{.Service}}.{{.Domain}}"
```

```
? Existing ingress rules found in namespaces [cd-production] namespace.  Confirm to delete and recreate them Yes
? Expose type Ingress
? Domain: 35.243.230.195.nip.io
? UrlTemplate (press <Enter> to keep the current value): "{{.Service}}.{{.Domain}}"
? Using config values {viktor@farcic.com 35.243.230.195.nip.io letsencrypt-prod false Ingress "{{.Service}}.{{.Domain}}" true}, ok? Yes

Looking for "cert-manager" deployment in namespace "cert-manager"...
Deleting ingress cd-production/go-demo-6
Expecting certificates: [cd-production/tls-go-demo-6]
Ready Cert: cd/tls-hook
Ready Cert: cd/tls-tide
Ready Cert: cd/tls-monocular
Ready Cert: cd/tls-chartmuseum
Ready Cert: cd/tls-deck
Ready Cert: cd-staging/tls-go-demo-6
Certificate issuer letsencrypt-prod already configured.
Deleting and cloning the Jenkins X versions repo
Cloning the Jenkins X versions repo https://github.com/jenkins-x/jenkins-x-versions.git with ref refs/heads/master to /Users/vfarcic/.jx/jenkins-x-versions
Enumerating objects: 12, done.
Counting objects: 100% (12/12), done.
Compressing objects: 100% (5/5), done.
Total 1476 (delta 7), reused 10 (delta 7), pack-reused 1464
using stable version 2.3.111 from charts of jenkins-x/exposecontroller from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Fetched chart jenkins-x/exposecontroller to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-868797782/expose-flasherfir/chartFiles/exposecontroller
Applying generated chart jenkins-x/exposecontroller YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-868797782/expose-flasherfir/output
configmap/exposecontroller created
job.batch/exposecontroller created
role.rbac.authorization.k8s.io/exposecontroller created
rolebinding.rbac.authorization.k8s.io/exposecontroller created
serviceaccount/exposecontroller created

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-flasherfir,jenkins.io/version!=2.3.111 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=expose-flasherfir,jenkins.io/version!=2.3.111,jenkins.io/namespace=cd-production from clusterrole clusterrolebinding
Removing Kubernetes resources from release expose-flasherfir using selector: jenkins.io/chart-release=expose-flasherfir from all pvc configmap release sa role rolebinding secret
job.batch "exposecontroller" deleted
configmap "exposecontroller" deleted
serviceaccount "exposecontroller" deleted
role.rbac.authorization.k8s.io "exposecontroller" deleted
rolebinding.rbac.authorization.k8s.io "exposecontroller" deleted
Removing Kubernetes resources from release expose-flasherfir using selector: jenkins.io/chart-release=expose-flasherfir,jenkins.io/namespace=cd-production from clusterrole clusterrolebinding
Ingress rules recreated

Waiting for TLS certificates to be issued...
Ready Cert: cd-production/tls-go-demo-6
All TLS certificates are ready

Previous webhook endpoint https://hook.cd.35.243.230.195.nip.io/hook
Updated webhook endpoint https://hook.cd.35.243.230.195.nip.io/hook
? Do you want to update all existing webhooks? Yes

Webhook URL unchanged. Use --force to force updating
```

```bash
jx get applications --env production
```

```
APPLICATION PRODUCTION PODS URL
go-demo-6   1.0.121    3/3  https://go-demo-6.35.243.230.195.nip.io
```

```bash
PROD_ADDR=[...]

curl "$PROD_ADDR/demo/hello"
```

```
hello, PR!
```

```bash
# NOTE: `urltemplate` could be `{{.Service}}.com`

# charts/go-demo-6/templates/ing.yaml could be something like...
```

```yaml
{{- if eq .Release.Namespace "cd-production" }} # or `jx-production`
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: go-demo-6-prod
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: go-demo-6.com
    http:
      paths:
      - backend:
          serviceName: go-demo-6
          servicePort: 80
{{- end }}
```

## What Now?

TODO: Create a branch with both jenkins-x.yml and Jenkinsfiles

TODO: Rewrite

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you chose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

# If static
ENVIRONMENT=jx-rocks

# If serverless
ENVIRONMENT=tekton

hub delete -y \
  $GH_USER/environment-$ENVIRONMENT-staging

hub delete -y \
  $GH_USER/environment-$ENVIRONMENT-production

rm -rf environment-$ENVIRONMENT-production

rm -rf ~/.jx/environments/$GH_USER/environment-$ENVIRONMENT-*
```