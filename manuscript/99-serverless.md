## TODO

- [ ] Code
- [ ] Write
- [ ] Code review GKE
- [ ] Code review EKS
- [ ] Code review AKS
- [ ] Code review existing cluster
- [ ] Diagrams
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Serverless

## Creating A Cluster

TODO: Gists are different
TODO: Added `--namespace cd --prow --tekton --no-tiller`

* Create new **GKE** cluster with serverless Jenkins X: [gke-jx-serverless.sh](TODO:)
* Create new **EKS** cluster with serverless Jenkins X: [eks-jx-serverless.sh](TODO:) TODO: Add tekton
* Create new **AKS** cluster with serverless Jenkins X: [aks-jx-serverless.sh](TODO:) TODO: Add tekton
* Use an **existing** cluster with serverless Jenkins X: [install-serverless.sh](TODO:) TODO: Add tekton

## Installing Serverless In An Existing Cluster

```bash
cat install-serverless.sh
```

TODO: Output

## Creating A New Serverless Jenkins X Cluster

```bash
cat gke-jx-serverless.sh

cat eks-jx-serverless.sh

cat aks-jx-serverless.sh
```

NOTE: GKE output

```
Updated property [core/project].
Let's ensure we have container and compute enabled on your project
No apis to enable
Creating cluster...
Initialising cluster ...
setting the dev namespace to: cd
Namespace cd created
 Using helmBinary helm with feature flag: none
Context "gke_devops24-book_us-east1-b_jx-rocks" modified.
Storing the kubernetes provider gke in the TeamSettings
Enabling helm template mode in the TeamSettings
Git configured for user: Viktor Farcic and email vfarcic@farcic.com
Trying to create ClusterRoleBinding viktor-farcic-com-cluster-admin-binding for role: cluster-admin for user viktor@farcic.com
 clusterrolebindings.rbac.authorization.k8s.io "viktor-farcic-com-cluster-admin-binding" not found
Created ClusterRoleBinding viktor-farcic-com-cluster-admin-binding
Using helm2
Skipping tiller
Using helmBinary helm with feature flag: template-mode
Initialising Helm 'init --client-only'
helm installed and configured
Using local value overrides file /Users/vfarcic/code/myvalues.yaml
Current configuration dir: /Users/vfarcic/.jx
versionRepository: https://github.com/jenkins-x/jenkins-x-versions
using stable version 1.3.1 from charts of stable/nginx-ingress from /Users/vfarcic/.jx/jenkins-x-versions
Installing using helm binary: helm
Fetched chart stable/nginx-ingress to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jxing/chartFiles/nginx-ingress
Generating Chart Template 'template --name jxing --namespace kube-system /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jxing/chartFiles/nginx-ingress --output-dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jxing/output --debug --set rbac.create=true --values /Users/vfarcic/code/myvalues.yaml'
Applying generated chart stable/nginx-ingress YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jxing/output
clusterrole.rbac.authorization.k8s.io/jxing-nginx-ingress created
clusterrolebinding.rbac.authorization.k8s.io/jxing-nginx-ingress created
configmap/jxing-nginx-ingress-controller created
deployment.extensions/jxing-nginx-ingress-controller created
service/jxing-nginx-ingress-controller created
deployment.extensions/jxing-nginx-ingress-default-backend created
service/jxing-nginx-ingress-default-backend created
role.rbac.authorization.k8s.io/jxing-nginx-ingress created
rolebinding.rbac.authorization.k8s.io/jxing-nginx-ingress created
serviceaccount/jxing-nginx-ingress created

Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=jxing,jenkins.io/version!=1.3.1 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=jxing,jenkins.io/version!=1.3.1,jenkins.io/namespace=kube-system from clusterrole clusterrolebinding

Waiting for external loadbalancer to be created and update the nginx-ingress-controller service in kube-system namespace
Note: this loadbalancer will fail to be provisioned if you have insufficient quotas, this can happen easily on a GKE free account. To view quotas run: gcloud compute project-infodescribe
External loadbalancer created
Waiting to find the external host name of the ingress controller Service in namespace kube-system with name jxing-nginx-ingress-controller
No domain flag provided so using default 35.237.212.191.nip.io to generate Ingress rules
nginx ingress controller installed and configured
Lets set up a Git user name and API token to be able to perform CI/CD

Select the CI/CD pipelines Git server and user
Setting the pipelines Git server https://github.com and user name vfarcic.
Saving the Git authentication configuration
Current configuration dir: /Users/vfarcic/.jx
versionRepository: https://github.com/jenkins-x/jenkins-x-versions
Current configuration dir: /Users/vfarcic/.jx
options.Flags.CloudEnvRepository: https://github.com/jenkins-x/cloud-environments
options.Flags.LocalCloudEnvironment: false
Cloning the Jenkins X cloud environments repo to /Users/vfarcic/.jx/cloud-environments
Current configuration dir: /Users/vfarcic/.jx
options.Flags.CloudEnvRepository: https://github.com/jenkins-x/cloud-environments
options.Flags.LocalCloudEnvironment: false
Cloning the Jenkins X cloud environments repo to /Users/vfarcic/.jx/cloud-environments
Enumerating objects: 1378, done.
Total 1378 (delta 0), reused 0 (delta 0), pack-reused 1378
setting the dev namespace to: cd
Generated helm values /Users/vfarcic/.jx/extraValues.yaml
Creating Secret jx-install-config in namespace cd
Using local value overrides file /Users/vfarcic/code/myvalues.yaml
Installing Jenkins X platform helm chart from: /Users/vfarcic/.jx/cloud-environments/env-gke

Installing knative into namespace cd
Current configuration dir: /Users/vfarcic/.jx
versionRepository:
using stable version 0.0.32 from charts of jenkins-x/tekton from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Fetched chart jenkins-x/tekton to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/tekton/chartFiles/tekton
Generating Chart Template 'template --name tekton --namespace cd /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/tekton/chartFiles/tekton --output-dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/tekton/output --debug --set  --set tillerNamespace= --set auth.git.username=viktor@farcic.com --set buildnum.enabled=false --set pipelinerunner.enabled=true --set auth.git.password=f4119453fe32db697f7c4fb476bac6dd86bd1a42'
Applying generated chart jenkins-x/tekton YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/tekton/output
clusterrole.rbac.authorization.k8s.io/tekton-pipelines created
clusterrolebinding.rbac.authorization.k8s.io/tekton-pipelines-cd created
secret/knative-git-user-pass created
serviceaccount/tekton-pipelines created
serviceaccount/tekton-bot created
customresourcedefinition.apiextensions.k8s.io/clustertasks.tekton.dev created
customresourcedefinition.apiextensions.k8s.io/pipelines.tekton.dev created
customresourcedefinition.apiextensions.k8s.io/pipelineruns.tekton.dev created
customresourcedefinition.apiextensions.k8s.io/pipelineresources.tekton.dev created
customresourcedefinition.apiextensions.k8s.io/tasks.tekton.dev created
customresourcedefinition.apiextensions.k8s.io/taskruns.tekton.dev created
service/tekton-pipelines-controller created
service/tekton-pipelines-webhook created
clusterrole.rbac.authorization.k8s.io/tekton-bot created
clusterrolebinding.rbac.authorization.k8s.io/tekton-bot-cd created
role.rbac.authorization.k8s.io/tekton-bot created
rolebinding.rbac.authorization.k8s.io/tekton-bot created
configmap/config-artifact-bucket created
configmap/config-entrypoint created
configmap/config-logging created
deployment.apps/tekton-pipelines-controller created
deployment.apps/tekton-pipelines-webhook created
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=tekton,jenkins.io/version!=0.0.32 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=tekton,jenkins.io/version!=0.0.32,jenkins.io/namespace=cd from clusterrole clusterrolebinding

Installing Prow into namespace cd
Current configuration dir: /Users/vfarcic/.jx
versionRepository:
using stable version 0.0.412 from charts of jenkins-x/prow from /Users/vfarcic/.jx/jenkins-x-versions
Updating Helm repository...
Helm repository update done.
Fetched chart jenkins-x/prow to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jx-prow/chartFiles/prow
Generating Chart Template 'template --name jx-prow --namespace cd /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jx-prow/chartFiles/prow --output-dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jx-prow/output --debug --set  --set tillerNamespace= --set auth.git.username=viktor@farcic.com --set buildnum.enabled=false --set pipelinerunner.enabled=true --set user=viktor@farcic.com --set oauthToken=f4119453fe32db697f7c4fb476bac6dd86bd1a42 --set hmacToken=5c0931fe314a2e356e58b8523e7a8f41ef65d1fbc'
Applying generated chart jenkins-x/prow YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jx-prow/output
clusterrole.rbac.authorization.k8s.io/prow-build created
clusterrolebinding.rbac.authorization.k8s.io/prow-build-cd created
deployment.extensions/prow-build created
serviceaccount/prow-build created
clusterrolebinding.rbac.authorization.k8s.io/cluster-admin-binding-cd created
clusterrole.rbac.authorization.k8s.io/crier created
clusterrolebinding.rbac.authorization.k8s.io/crier-cd created
deployment.extensions/crier created
rolebinding.rbac.authorization.k8s.io/crier created
role.rbac.authorization.k8s.io/crier created
serviceaccount/crier created
deployment.extensions/deck created
rolebinding.rbac.authorization.k8s.io/deck created
role.rbac.authorization.k8s.io/deck created
serviceaccount/deck created
service/deck created
secret/hmac-token created
deployment.extensions/hook created
rolebinding.rbac.authorization.k8s.io/hook created
role.rbac.authorization.k8s.io/hook created
serviceaccount/hook created
service/hook created
deployment.extensions/horologium created
rolebinding.rbac.authorization.k8s.io/horologium created
role.rbac.authorization.k8s.io/horologium created
serviceaccount/horologium created
secret/oauth-token created
clusterrole.rbac.authorization.k8s.io/pipeline created
clusterrolebinding.rbac.authorization.k8s.io/pipeline-cd created
deployment.extensions/pipeline created
serviceaccount/pipeline created
deployment.extensions/pipelinerunner created
rolebinding.rbac.authorization.k8s.io/pipelinerunner created
role.rbac.authorization.k8s.io/pipelinerunner created
serviceaccount/pipelinerunner created
service/pipelinerunner created
deployment.extensions/plank created
rolebinding.rbac.authorization.k8s.io/plank created
role.rbac.authorization.k8s.io/plank created
serviceaccount/plank created
customresourcedefinition.apiextensions.k8s.io/prowjobs.prow.k8s.io created
deployment.extensions/sinker created
rolebinding.rbac.authorization.k8s.io/sinker created
role.rbac.authorization.k8s.io/sinker created
serviceaccount/sinker created
deployment.extensions/tide created
rolebinding.rbac.authorization.k8s.io/tide created
role.rbac.authorization.k8s.io/tide created
serviceaccount/tide created
service/tide created
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=jx-prow,jenkins.io/version!=0.0.412 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=jx-prow,jenkins.io/version!=0.0.412,jenkins.io/namespace=cd from clusterrole clusterrolebinding
Installing jx into namespace cd
using stable version 0.0.3631 from charts of jenkins-x/jenkins-x-platform from /Users/vfarcic/.jx/jenkins-x-versions
Installing jenkins-x-platform version: 0.0.3631
Adding values file /Users/vfarcic/.jx/cloud-environments/env-gke/myvalues.yaml
Adding values file /Users/vfarcic/code/myvalues.yaml
Adding values file /Users/vfarcic/.jx/adminSecrets.yaml
Adding values file /Users/vfarcic/.jx/extraValues.yaml
Adding values file /Users/vfarcic/.jx/cloud-environments/env-gke/secrets.yaml
Fetched chart jenkins-x/jenkins-x-platform to dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jenkins-x/chartFiles/jenkins-x-platform
Generating Chart Template 'template --name jenkins-x --namespace cd /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jenkins-x/chartFiles/jenkins-x-platform --output-dir /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jenkins-x/output --debug --values /Users/vfarcic/.jx/cloud-environments/env-gke/myvalues.yaml --values /Users/vfarcic/code/myvalues.yaml --values /Users/vfarcic/.jx/adminSecrets.yaml --values /Users/vfarcic/.jx/extraValues.yaml --values /Users/vfarcic/.jx/cloud-environments/env-gke/secrets.yaml'
Applying generated chart jenkins-x/jenkins-x-platform YAML via kubectl in dir: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jenkins-x/output
deployment.extensions/jenkins-x-chartmuseum created
persistentvolumeclaim/jenkins-x-chartmuseum created
secret/jenkins-x-chartmuseum created
service/jenkins-x-chartmuseum created
role.rbac.authorization.k8s.io/cleanup created
rolebinding.rbac.authorization.k8s.io/cleanup created
serviceaccount/cleanup created
clusterrole.rbac.authorization.k8s.io/controllerbuild-cd created
clusterrolebinding.rbac.authorization.k8s.io/controllerbuild-cd created
deployment.apps/jenkins-x-controllerbuild created
role.rbac.authorization.k8s.io/controllerbuild created
rolebinding.rbac.authorization.k8s.io/controllerbuild created
serviceaccount/jenkins-x-controllerbuild created
clusterrole.rbac.authorization.k8s.io/controllercommitstatus-cd created
clusterrolebinding.rbac.authorization.k8s.io/controllercommitstatus-cd created
deployment.apps/jenkins-x-controllercommitstatus created
role.rbac.authorization.k8s.io/controllercommitstatus created
rolebinding.rbac.authorization.k8s.io/controllercommitstatus created
serviceaccount/jenkins-x-controllercommitstatus created
clusterrole.rbac.authorization.k8s.io/controllerrole-cd created
clusterrolebinding.rbac.authorization.k8s.io/controllerrole-cd created
deployment.apps/jenkins-x-controllerrole created
role.rbac.authorization.k8s.io/controllerrole created
rolebinding.rbac.authorization.k8s.io/controllerrole created
serviceaccount/jenkins-x-controllerrole created
clusterrole.rbac.authorization.k8s.io/controllerteam-cd created
clusterrolebinding.rbac.authorization.k8s.io/controllerteam-cd created
deployment.apps/jenkins-x-controllerteam created
role.rbac.authorization.k8s.io/controllerteam created
rolebinding.rbac.authorization.k8s.io/controllerteam created
serviceaccount/jenkins-x-controllerteam created
clusterrole.rbac.authorization.k8s.io/controllerworkflow-cd created
clusterrolebinding.rbac.authorization.k8s.io/controllerworkflow-cd created
deployment.apps/jenkins-x-controllerworkflow created
role.rbac.authorization.k8s.io/controllerworkflow created
rolebinding.rbac.authorization.k8s.io/controllerworkflow created
serviceaccount/jenkins-x-controllerworkflow created
configmap/jenkins-x-docker-registry-config created
deployment.extensions/jenkins-x-docker-registry created
persistentvolumeclaim/jenkins-x-docker-registry created
secret/jenkins-x-docker-registry-secret created
service/jenkins-x-docker-registry created
configmap/exposecontroller created
role.rbac.authorization.k8s.io/expose created
rolebinding.rbac.authorization.k8s.io/expose created
serviceaccount/expose created
clusterrole.rbac.authorization.k8s.io/gcactivities-cd created
clusterrolebinding.rbac.authorization.k8s.io/gcactivities-cd created
cronjob.batch/jenkins-x-gcactivities created
role.rbac.authorization.k8s.io/gcactivities created
rolebinding.rbac.authorization.k8s.io/gcactivities created
serviceaccount/jenkins-x-gcactivities created
cronjob.batch/jenkins-x-gcpods created
role.rbac.authorization.k8s.io/gcpods created
rolebinding.rbac.authorization.k8s.io/gcpods created
serviceaccount/jenkins-x-gcpods created
cronjob.batch/jenkins-x-gcpreviews created
role.rbac.authorization.k8s.io/gcpreviews created
rolebinding.rbac.authorization.k8s.io/gcpreviews created
serviceaccount/jenkins-x-gcpreviews created
deployment.extensions/jenkins-x-heapster created
clusterrolebinding.rbac.authorization.k8s.io/jenkins-x-heapster created
role.rbac.authorization.k8s.io/jenkins-x-heapster-pod-nanny created
rolebinding.rbac.authorization.k8s.io/jenkins-x-heapster-pod-nanny created
service/heapster created
serviceaccount/jenkins-x-heapster created
deployment.extensions/jenkins-x-mongodb created
persistentvolumeclaim/jenkins-x-mongodb created
secret/jenkins-x-mongodb created
service/jenkins-x-mongodb created
configmap/jenkins-x-monocular-api-config created
deployment.extensions/jenkins-x-monocular-api created
service/jenkins-x-monocular-api created
deployment.extensions/jenkins-x-monocular-prerender created
service/jenkins-x-monocular-prerender created
configmap/jenkins-x-monocular-ui-config created
deployment.extensions/jenkins-x-monocular-ui created
service/jenkins-x-monocular-ui created
configmap/jenkins-x-monocular-ui-vhost created
role.rbac.authorization.k8s.io/committer created
clusterrolebinding.rbac.authorization.k8s.io/jenkins-x-team-controller created
configmap/jenkins-x-team-controller created
secret/jenkins-docker-cfg created
configmap/jenkins-x-devpod-config created
configmap/jenkins-x-docker-registry created
configmap/jenkins-x-extensions created
configmap/jenkins-x-pod-templates created
secret/jx-basic-auth created
role.rbac.authorization.k8s.io/jx-view created
secret/jenkins-maven-settings created
secret/jenkins-npm-token created
role.rbac.authorization.k8s.io/owner created
secret/jenkins-release-gpg created
secret/jenkins-ssh-config created
role.rbac.authorization.k8s.io/viewer created
Applying Helm hook post-upgrade YAML via kubectl in file: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jenkins-x/helmHooks/jenkins-x-platform/charts/expose/templates/job.yaml
job.batch/expose created
Waiting for helm post-upgrade hook Job expose to complete before removing it
Deleting helm hook sources from file: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/helm-template-workdir-807711114/jenkins-x/helmHooks/jenkins-x-platform/charts/expose/templates/job.yaml
job.batch "expose" deleted
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=jenkins-x,jenkins.io/version!=0.0.3631 from all pvc configmap release sa role rolebinding secret
Removing Kubernetes resources from older releases using selector: jenkins.io/chart-release=jenkins-x,jenkins.io/version!=0.0.3631,jenkins.io/namespace=cd from clusterrole clusterrolebinding
waiting for install to be ready, if this is the first time then it will take a while to download images
Jenkins X deployments ready in namespace cd
Configuring the TeamSettings for Prow with engine Tekton
Configuring the TeamSettings for ImportMode YAML


        ********************************************************

             NOTE: Your admin password is: admin

        ********************************************************


Creating default staging and production environments
Using vfarcic environment git owner in batch mode.
Using Git provider GitHub at https://github.com


About to create repository environment-jx-rocks-staging on server https://github.com with user vfarcic


Creating repository vfarcic/environment-jx-rocks-staging
Creating Git repository vfarcic/environment-jx-rocks-staging
Pushed Git repository to https://github.com/vfarcic/environment-jx-rocks-staging

Creating staging Environment in namespace cd
Created environment staging
Namespace cd-staging created
 Creating GitHub webhook for vfarcic/environment-jx-rocks-staging for url http://hook.cd.35.237.212.191.nip.io/hook
Using Git provider GitHub at https://github.com


About to create repository environment-jx-rocks-production on server https://github.com with user vfarcic


Creating repository vfarcic/environment-jx-rocks-production
Creating Git repository vfarcic/environment-jx-rocks-production
Pushed Git repository to https://github.com/vfarcic/environment-jx-rocks-production

Creating production Environment in namespace cd
Created environment production
Namespace cd-production created
 Creating GitHub webhook for vfarcic/environment-jx-rocks-production for url http://hook.cd.35.237.212.191.nip.io/hook

Jenkins X installation completed successfully


        ********************************************************

             NOTE: Your admin password is: admin

        ********************************************************



Your Kubernetes context is now set to the namespace: cd
To switch back to your original namespace use: jx namespace default
Or to use this context/namespace in just one terminal use: jx shell
For help on switching contexts see: https://jenkins-x.io/developing/kube-context/

To import existing projects into Jenkins:       jx import
To create a new Spring Boot microservice:       jx create spring -d web -d actuator
To create a new microservice from a quickstart: jx create quickstart
Fetching cluster endpoint and auth data.
kubeconfig entry generated for jx-rocks.
Context "gke_devops24-book_us-east1-b_jx-rocks" modified.
NAME              HOSTS                                      ADDRESS         PORTS   AGE
chartmuseum       chartmuseum.cd.35.237.212.191.nip.io       34.73.176.245   80      2m
deck              deck.cd.35.237.212.191.nip.io              34.73.176.245   80      2m
docker-registry   docker-registry.cd.35.237.212.191.nip.io   34.73.176.245   80      2m
hook              hook.cd.35.237.212.191.nip.io              34.73.176.245   80      2m
monocular         monocular.cd.35.237.212.191.nip.io         34.73.176.245   80      2m
tide              tide.cd.35.237.212.191.nip.io              34.73.176.245   80      2m
```

## Exploring Serverless Jenkins X

```bash
kubectl -n cd get deployments
```

```
NAME                               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
crier                              1         1         1            1           9m
deck                               2         2         2            2           9m
hook                               2         2         2            2           9m
horologium                         1         1         1            1           9m
jenkins-x-chartmuseum              1         1         1            1           9m
jenkins-x-controllerbuild          1         1         1            1           8m
jenkins-x-controllercommitstatus   1         1         1            1           8m
jenkins-x-controllerrole           1         1         1            1           8m
jenkins-x-controllerteam           1         1         1            1           8m
jenkins-x-controllerworkflow       1         1         1            1           8m
jenkins-x-docker-registry          1         1         1            1           8m
jenkins-x-heapster                 1         1         1            1           8m
jenkins-x-mongodb                  1         1         1            1           8m
jenkins-x-monocular-api            1         1         1            1           8m
jenkins-x-monocular-prerender      1         1         1            1           8m
jenkins-x-monocular-ui             1         1         1            1           8m
pipeline                           1         1         1            1           9m
pipelinerunner                     1         1         1            1           9m
plank                              1         1         1            1           9m
prow-build                         1         1         1            1           9m
sinker                             1         1         1            1           9m
tekton-pipelines-controller        1         1         1            1           11m
tekton-pipelines-webhook           1         1         1            1           11m
tide                               1         1         1            1           9m
```

```bash
kubectl -n cd describe deployment \
  tekton-pipelines-controller
```

```yaml
Name:                   tekton-pipelines-controller
Namespace:              cd
CreationTimestamp:      Mon, 25 Mar 2019 22:01:01 +0100
Labels:                 jenkins.io/chart-release=tekton
                        jenkins.io/version=0.0.32
Annotations:            deployment.kubernetes.io/revision: 1
                        jenkins.io/chart: tekton
                        kubectl.kubernetes.io/last-applied-configuration:
                          {"apiVersion":"apps/v1beta1","kind":"Deployment","metadata":{"annotations":{"jenkins.io/chart":"tekton"},"labels":{"jenkins.io/chart-relea...
Selector:               app=tekton-pipelines-controller
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:           app=tekton-pipelines-controller
  Service Account:  tekton-pipelines
  Containers:
   tekton-pipelines:
    Image:      gcr.io/abayer-jx-experiment/controller:v20190308-186ac3b6
    Port:       <none>
    Host Port:  <none>
    Args:
      -logtostderr
      -stderrthreshold
      INFO
      -kubeconfig-writer-image
      gcr.io/abayer-jx-experiment/kubeconfigwriter:v20190308-186ac3b6
      -creds-image
      gcr.io/abayer-jx-experiment/creds-init:v20190308-186ac3b6
      -git-image
      gcr.io/abayer-jx-experiment/git-init:v20190308-186ac3b6
      -nop-image
      gcr.io/abayer-jx-experiment/nop:v20190308-186ac3b6
      -bash-noop-image
      gcr.io/abayer-jx-experiment/bash:v20190308-186ac3b6
      -gsutil-image
      gcr.io/abayer-jx-experiment/gsutil:v20190308-186ac3b6
    Environment:
      SYSTEM_NAMESPACE:   (v1:metadata.namespace)
    Mounts:
      /etc/config-logging from config-logging (rw)
  Volumes:
   config-logging:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config-logging
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   tekton-pipelines-controller-5d84cc89b9 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  21m   deployment-controller  Scaled up replica set tekton-pipelines-controller-5d84cc89b9 to 1
```

```bash
kubectl -n cd describe deployment \
  tekton-pipelines-webhook
```

```
Name:                   tekton-pipelines-webhook
Namespace:              cd
CreationTimestamp:      Mon, 25 Mar 2019 22:01:02 +0100
Labels:                 jenkins.io/chart-release=tekton
                        jenkins.io/version=0.0.32
Annotations:            deployment.kubernetes.io/revision: 1
                        jenkins.io/chart: tekton
                        kubectl.kubernetes.io/last-applied-configuration:
                          {"apiVersion":"apps/v1beta1","kind":"Deployment","metadata":{"annotations":{"jenkins.io/chart":"tekton"},"labels":{"jenkins.io/chart-relea...
Selector:               app=tekton-pipelines-webhook
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:           app=tekton-pipelines-webhook
  Service Account:  tekton-pipelines
  Containers:
   webhook:
    Image:      gcr.io/abayer-jx-experiment/webhook:v20190308-186ac3b6
    Port:       <none>
    Host Port:  <none>
    Environment:
      SYSTEM_NAMESPACE:   (v1:metadata.namespace)
    Mounts:
      /etc/config-logging from config-logging (rw)
  Volumes:
   config-logging:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config-logging
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   tekton-pipelines-webhook-9d96cfcf6 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  24m   deployment-controller  Scaled up replica set tekton-pipelines-webhook-9d96cfcf6 to 1
```

```bash
# Crier reports your prowjobs on their status changes.

kubectl describe deployment crier
```

```yaml
Name:                   crier
Namespace:              cd
CreationTimestamp:      Mon, 25 Mar 2019 22:02:38 +0100
Labels:                 app=crier
                        jenkins.io/chart-release=jx-prow
                        jenkins.io/version=0.0.412
Annotations:            deployment.kubernetes.io/revision: 1
                        jenkins.io/chart: prow
                        kubectl.kubernetes.io/last-applied-configuration:
                          {"apiVersion":"extensions/v1beta1","kind":"Deployment","metadata":{"annotations":{"jenkins.io/chart":"prow"},"labels":{"app":"crier","jenk...
Selector:               app=crier
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=crier
  Service Account:  crier
  Containers:
   crier:
    Image:      jenkinsxio/crier:pipeline14
    Port:       <none>
    Host Port:  <none>
    Args:
      -gerrit-workers=0
      -github-workers=1
      -logtostderr
      -config-path=/etc/config/config.yaml
      -github-token-path=/etc/github/oauth
    Limits:
      cpu:     400m
      memory:  256Mi
    Requests:
      cpu:        200m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
      /etc/github from oauth (ro)
  Volumes:
   oauth:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  oauth-token
    Optional:    false
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  crier-7b9bc4c849 (1/1 replicas created)
NewReplicaSet:   <none>
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  15m   deployment-controller  Scaled up replica set crier-7b9bc4c849 to 1
```

```bash
# hook is the most important piece. It is a stateless server that listens for GitHub webhooks and dispatches them to the appropriate plugins. Hook's plugins are used to trigger jobs, implement 'slash' commands, post to Slack, and more.

kubectl -n cd describe deployment hook
```

```yaml
Name:                   hook
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=hook
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=hook
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=hook
  Service Account:  hook
  Containers:
   hook:
    Image:      jenkinsxio/hook:pipeline14
    Port:       8888/TCP
    Host Port:  0/TCP
    Args:
      --dry-run=false
    Limits:
      cpu:     400m
      memory:  256Mi
    Requests:
      cpu:        200m
      memory:     128Mi
    Liveness:     http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Readiness:    http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
      /etc/github from oauth (ro)
      /etc/plugins from plugins (ro)
      /etc/webhook from hmac (ro)
  Volumes:
   hmac:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  hmac-token
    Optional:    false
   oauth:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  oauth-token
    Optional:    false
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
   plugins:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      plugins
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  hook-84674dfd46 (2/2 replicas created)
NewReplicaSet:   <none>
Events:          <none>
```

```bash
kubectl -n cd describe cm config
```

```yaml
Name:         config
Namespace:    cd
Labels:       <none>
Annotations:  <none>

Data
====
config.yaml:
----
branch-protection:
  orgs:
    jenkins-x:
      repos:
        dummy:
          required_status_checks:
            contexts:
            - serverless-jenkins
    vfarcic:
      repos:
        environment-jx-rocks-production:
          required_status_checks:
            contexts:
            - promotion-build
        environment-jx-rocks-staging:
          required_status_checks:
            contexts:
            - promotion-build
        jx-go:
          required_status_checks:
            contexts:
            - serverless-jenkins
  protect-tested-repos: true
deck:
  spyglass: {}
gerrit: {}
owners_dir_blacklist:
  default: null
  repos: null
plank: {}
pod_namespace: cd
postsubmits:
  jenkins-x/dummy:
  - agent: knative-build
    branches:
    - master
    build_spec:
      serviceAccountName: knative-build-bot
      template:
        name: jenkins-base
    context: ""
    name: release
  vfarcic/environment-jx-rocks-production:
  - agent: knative-build
    branches:
    - master
    build_spec:
      serviceAccountName: helm
      template:
        env:
        - name: DEPLOY_NAMESPACE
          value: cd-production
        name: environment-apply
    context: ""
    name: promotion
  vfarcic/environment-jx-rocks-staging:
  - agent: knative-build
    branches:
    - master
    build_spec:
      serviceAccountName: helm
      template:
        env:
        - name: DEPLOY_NAMESPACE
          value: cd-staging
        name: environment-apply
    context: ""
    name: promotion
  vfarcic/jx-go:
  - agent: knative-build
    branches:
    - master
    build_spec:
      serviceAccountName: knative-build-bot
      template:
        name: jenkins-go
    context: ""
    name: release
presubmits:
  jenkins-x/dummy:
  - agent: knative-build
    always_run: true
    build_spec:
      serviceAccountName: helm
      template:
        name: jenkins-base
    context: serverless-jenkins
    name: serverless-jenkins
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
  vfarcic/environment-jx-rocks-production:
  - agent: knative-build
    always_run: true
    build_spec:
      serviceAccountName: knative-build-bot
      template:
        name: environment-build
    context: promotion-build
    name: promotion-build
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
  vfarcic/environment-jx-rocks-staging:
  - agent: knative-build
    always_run: true
    build_spec:
      serviceAccountName: knative-build-bot
      template:
        name: environment-build
    context: promotion-build
    name: promotion-build
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
  vfarcic/jx-go:
  - agent: knative-build
    always_run: true
    build_spec:
      serviceAccountName: helm
      template:
        name: jenkins-go
    context: serverless-jenkins
    name: serverless-jenkins
    rerun_command: /test this
    trigger: (?m)^/test( all| this),?(\s+|$)
prowjob_namespace: cd
push_gateway: {}
sinker: {}
tide:
  context_options:
    from-branch-protection: true
    required-if-present-contexts: null
    skip-unknown-contexts: false
  queries:
  - labels:
    - approved
    missingLabels:
    - do-not-merge
    - do-not-merge/hold
    - do-not-merge/work-in-progress
    - needs-ok-to-test
    - needs-rebase
    repos:
    - jenkins-x/dummy
    - vfarcic/jx-go
  - missingLabels:
    - do-not-merge
    - do-not-merge/hold
    - do-not-merge/work-in-progress
    - needs-ok-to-test
    - needs-rebase
    repos:
    - jenkins-x/dummy-environment
    - vfarcic/environment-jx-rocks-staging
    - vfarcic/environment-jx-rocks-production
  target_url: http://deck.cd.34.73.176.245.nip.io

Events:  <none>
```

```bash
kubectl -n cd describe cm plugins
```

```yaml
Name:         plugins
Namespace:    cd
Labels:       <none>
Annotations:  <none>

Data
====
external-plugins.yaml:
----
Items: null

plugins.yaml:
----
approve:
- lgtm_acts_as_approve: true
  repos:
  - jenkins-x/dummy
  require_self_approval: true
- lgtm_acts_as_approve: true
  repos:
  - vfarcic/environment-jx-rocks-staging
  require_self_approval: true
- lgtm_acts_as_approve: true
  repos:
  - vfarcic/environment-jx-rocks-production
  require_self_approval: true
- lgtm_acts_as_approve: true
  repos:
  - vfarcic/jx-go
  require_self_approval: true
blunderbuss: {}
cat: {}
cherry_pick_unapproved: {}
config_updater: {}
external_plugins:
  jenkins-x/dummy: null
  vfarcic/environment-jx-rocks-production: null
  vfarcic/environment-jx-rocks-staging: null
  vfarcic/jx-go: null
heart: {}
owners: {}
plugins:
  jenkins-x/dummy:
  - config-updater
  - approve
  - assign
  - blunderbuss
  - help
  - hold
  - lgtm
  - lifecycle
  - size
  - trigger
  - wip
  - heart
  - cat
  - override
  vfarcic/environment-jx-rocks-production:
  - config-updater
  - approve
  - assign
  - blunderbuss
  - help
  - hold
  - lgtm
  - lifecycle
  - size
  - trigger
  - wip
  - heart
  - cat
  - override
  vfarcic/environment-jx-rocks-staging:
  - config-updater
  - approve
  - assign
  - blunderbuss
  - help
  - hold
  - lgtm
  - lifecycle
  - size
  - trigger
  - wip
  - heart
  - cat
  - override
requiresig: {}
sigmention: {}
slack: {}
triggers:
- repos:
  - jenkins-x/dummy
  trusted_org: jenkins-x
- repos:
  - vfarcic/environment-jx-rocks-staging
  trusted_org: vfarcic
- repos:
  - vfarcic/environment-jx-rocks-production
  trusted_org: vfarcic
- repos:
  - vfarcic/jx-go
  trusted_org: vfarcic
welcome:
- message_template: Welcome

Events:  <none>
```

```bash
# plank is the controller that manages the job execution and lifecycle for jobs that run in k8s pods.

kubectl -n cd describe deployment plank
```

```yaml
Name:                   plank
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=plank
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=plank
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=plank
  Service Account:  plank
  Containers:
   plank:
    Image:      jenkinsxio/plank:pipeline14
    Port:       <none>
    Host Port:  <none>
    Args:
      --dry-run=false
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
      /etc/github from oauth (ro)
  Volumes:
   oauth:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  oauth-token
    Optional:    false
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  plank-79d5bcc96b (1/1 replicas created)
NewReplicaSet:   <none>
Events:          <none>
```

```bash
# deck presents a nice view of recent jobs, command and plugin help information, the current status and (history)[https://prow.k8s.io/tide-history] of merge automation, and a dashboard for PR authors.

kubectl -n cd describe deployment deck
```

```yaml
Name:                   deck
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=deck
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=deck
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=deck
  Service Account:  deck
  Containers:
   deck:
    Image:      jenkinsxio/deck:pipeline14
    Port:       8080/TCP
    Host Port:  0/TCP
    Args:
      --hook-url=http://hook/plugin-help
      --tide-url=http://tide
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Liveness:     http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Readiness:    http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
  Volumes:
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   deck-5fbbdc9478 (2/2 replicas created)
Events:          <none>
```

```bash
kubectl -n cd describe deployment \
  horologium
```

```yaml
Name:                   horologium
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=horologium
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=horologium
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=horologium
  Service Account:  horologium
  Containers:
   horologium:
    Image:      jenkinsxio/horologium:pipeline14
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
  Volumes:
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   horologium-65d4c68b96 (1/1 replicas created)
Events:          <none>
```

```bash
# horologium triggers periodic jobs when necessary.

kubectl -n cd describe deployment sinker
```

```yaml
Name:                   sinker
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=sinker
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=sinker
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=sinker
  Service Account:  sinker
  Containers:
   sinker:
    Image:      jenkinsxio/sinker:pipeline14
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
  Volumes:
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   sinker-c95fc86b5 (1/1 replicas created)
Events:          <none>
```

```bash
# tide manages retesting and merging PRs once they meet the configured merge criteria.

kubectl -n cd describe deployment tide
```

```yaml
Name:                   tide
Namespace:              cd
CreationTimestamp:      Sun, 24 Mar 2019 20:01:31 +0100
Labels:                 app=tide
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=tide
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:           app=tide
  Service Account:  tide
  Containers:
   tide:
    Image:      jenkinsxio/tide:pipeline14
    Port:       8888/TCP
    Host Port:  0/TCP
    Args:
      --dry-run=false
      --github-endpoint=https://api.github.com
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Liveness:     http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Readiness:    http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /etc/config from config (ro)
      /etc/github from oauth (ro)
  Volumes:
   oauth:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  oauth-token
    Optional:    false
   config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      config
    Optional:  false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  tide-b99fd65b6 (1/1 replicas created)
NewReplicaSet:   <none>
Events:          <none>
```

```bash
jx create quickstart -l go -p jx-go -b
```

```
Generated quickstart at /Users/vfarcic/code/jx-go
### NO charts folder /Users/vfarcic/code/jx-go/charts/golang-http
Created project at /Users/vfarcic/code/jx-go

No username defined for the current Git server!

Git repository created
performing pack detection in folder /Users/vfarcic/code/jx-go
--> Draft detected Go (65.746753%)
selected pack: /Users/vfarcic/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs/go
replacing placeholders in directory /Users/vfarcic/code/jx-go
app name: jx-go, git server: github.com, org: vfarcic, Docker registry org: vfarcic
skipping directory "/Users/vfarcic/code/jx-go/.git"
Using Git provider GitHub at https://github.com


About to create repository jx-go on server https://github.com with user vfarcic


Creating repository vfarcic/jx-go
Pushed Git repository to https://github.com/vfarcic/jx-go

Creating GitHub webhook for vfarcic/jx-go for url http://hook.cd.35.237.212.191.nip.io/hook

Watch pipeline activity via:    jx get activity -f jx-go -w
Browse the pipeline log via:    jx get build logs vfarcic/jx-go/master
Open the Jenkins console via    jx console
You can list the pipelines via: jx get pipelines
When the pipeline is complete:  jx get applications

For more help on available commands see: https://jenkins-x.io/developing/browsing/

Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!
```

```bash
jx get activities -f jx-go -w
```

NOTE: Stop with *ctrl+c*

```
STEP                                      STARTED AGO DURATION STATUS
vfarcic/jx-go/master #1                         4m12s    3m56s Succeeded Version: 0.0.1
  from build pack                               4m12s    3m56s Succeeded
    Credential Initializer L588p                4m12s       0s Succeeded
    Git Source Vfarcic Jx Go Master 5457b       4m11s       0s Succeeded https://github.com/vfarcic/jx-go
    Place Tools                                  4m8s       0s Succeeded
    Setup Jx Git Credentials                    2m12s       1s Succeeded
    Build Make Build                            2m10s       5s Succeeded
    Build Container Build                        2m2s       1s Succeeded
    Build Post Build                             2m0s       0s Succeeded
    Promote Changelog                           1m59s       2s Succeeded
    Promote Helm Release                        1m56s       3s Succeeded
    Promote Jx Promote                          1m52s    1m36s Succeeded
  Promote: staging                              1m43s    1m26s Succeeded
    PullRequest                                 1m43s    1m25s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-rocks-staging/pull/1 Merge SHA: 5b2c62d96b9e36aa9a50166e12d8f496639a0eb5
    Update                                        18s       1s Succeeded
```

```bash
kubectl -n cd get pods
```

```
NAME                                                                 READY   STATUS      RESTARTS   AGE
crier-7b9bc4c849-bwcvp                                               1/1     Running     0          29m
deck-5fbbdc9478-5dl55                                                1/1     Running     0          29m
deck-5fbbdc9478-z7crs                                                1/1     Running     1          29m
hook-84674dfd46-klnwb                                                1/1     Running     0          29m
hook-84674dfd46-smpp2                                                1/1     Running     0          29m
horologium-65d4c68b96-xfsjc                                          1/1     Running     0          29m
jenkins-x-chartmuseum-5687695d57-sblx2                               1/1     Running     0          28m
jenkins-x-controllerbuild-5cbf7d7cf4-4bztd                           1/1     Running     0          28m
jenkins-x-controllercommitstatus-64d4c5458b-zrw4g                    1/1     Running     0          28m
jenkins-x-controllerrole-78bf7ff47-r4p92                             1/1     Running     0          28m
jenkins-x-controllerteam-8c56699b6-d6flf                             1/1     Running     0          28m
jenkins-x-controllerworkflow-778f7786dd-v82df                        1/1     Running     0          28m
jenkins-x-docker-registry-7b56b4f555-blsjv                           1/1     Running     0          28m
jenkins-x-gcactivities-1553549400-87lzb                              0/1     Completed   0          2m
jenkins-x-gcpods-1553549400-spgvv                                    0/1     Completed   0          2m
jenkins-x-heapster-8cbd88846-zc6cw                                   2/2     Running     0          28m
jenkins-x-mongodb-6bfd5d9c79-brv6w                                   1/1     Running     1          28m
jenkins-x-monocular-api-f98b447d7-7k59l                              1/1     Running     0          28m
jenkins-x-monocular-prerender-5848c74fdc-prpp2                       1/1     Running     0          28m
jenkins-x-monocular-ui-5b67857758-9snf8                              1/1     Running     0          28m
pipeline-66cf49b747-9zgt5                                            1/1     Running     0          29m
pipelinerunner-556dd9c4b8-kcqsq                                      1/1     Running     0          29m
plank-79d5bcc96b-4s62p                                               1/1     Running     0          29m
prow-build-56c9d49579-9qkbp                                          1/1     Running     0          29m
sinker-c95fc86b5-d5d9t                                               1/1     Running     0          29m
tekton-pipelines-controller-5d84cc89b9-p5rwc                         1/1     Running     0          31m
tekton-pipelines-webhook-9d96cfcf6-wdslj                             1/1     Running     0          31m
tide-b99fd65b6-4752n                                                 1/1     Running     0          29m
vfarcic-environment-jx-rocks-st-1-from-build-pack-d4sq7-pod-b03009   0/1     Completed   0          1m
vfarcic-environment-jx-rocks-st-2-from-build-pack-zv959-pod-81ea99   0/1     Init:4/5    0          43s
vfarcic-jx-go-master-1-from-build-pack-qlmwz-pod-35e47d              0/1     Completed   0          4m
```

```bash
jx get pipelines
```

```
Name                                           URL LAST_BUILD STATUS DURATION
jenkins-x/dummy/master                         N/A N/A        N/A    N/A
vfarcic/environment-jx-rocks-production/master N/A N/A        N/A    N/A
vfarcic/environment-jx-rocks-staging/master    N/A N/A        N/A    N/A
vfarcic/jx-go/master                           N/A N/A        N/A    N/A
```

```bash
jx get build logs
```

```
? Which build do you want to view the logs of?:   [Use arrows to move, type to filter]
  vfarcic/environment-jx-rocks-staging/PR-1 #1
  vfarcic/environment-jx-rocks-staging/master #2
> vfarcic/jx-go/master #1
```

NOTE: Cancel with *ctrl+c*

```bash
jx get applications
```

```
APPLICATION STAGING PODS URL
jx-jx-go    0.0.1   1/1  http://jx-go.cd-staging.35.237.212.191.nip.io
```

```bash
JX_GO_ADDR=[...]

curl "$JX_GO_ADDR"
```

```
Hello from:  Jenkins X golang http example
```

```bash
jx open deck
```

NOTE: Use *admin* as both the username and the password

## Exploring CustomerResourceDefinitions

```bash
kubectl -n cd get crd
```

```
NAME                                    CREATED AT
apps.jenkins.io                         2019-03-25T20:56:53Z
backendconfigs.cloud.google.com         2019-03-25T20:55:52Z
buildpacks.jenkins.io                   2019-03-25T20:56:49Z
clustertasks.tekton.dev                 2019-03-25T21:00:57Z
commitstatuses.jenkins.io               2019-03-25T20:56:50Z
environmentrolebindings.jenkins.io      2019-03-25T20:56:54Z
environments.jenkins.io                 2019-03-25T20:56:51Z
extensions.jenkins.io                   2019-03-25T20:56:52Z
facts.jenkins.io                        2019-03-25T20:56:55Z
gitservices.jenkins.io                  2019-03-25T20:56:54Z
pipelineactivities.jenkins.io           2019-03-25T20:56:54Z
pipelineresources.tekton.dev            2019-03-25T21:00:57Z
pipelineruns.tekton.dev                 2019-03-25T21:00:57Z
pipelines.tekton.dev                    2019-03-25T21:00:57Z
pipelinestructures.jenkins.io           2019-03-25T20:56:55Z
plugins.jenkins.io                      2019-03-25T20:56:53Z
prowjobs.prow.k8s.io                    2019-03-25T21:02:53Z
releases.jenkins.io                     2019-03-25T20:56:56Z
scalingpolicies.scalingpolicy.kope.io   2019-03-25T20:56:26Z
sourcerepositories.jenkins.io           2019-03-25T20:56:56Z
taskruns.tekton.dev                     2019-03-25T21:00:58Z
tasks.tekton.dev                        2019-03-25T21:00:58Z
teams.jenkins.io                        2019-03-25T20:56:56Z
users.jenkins.io                        2019-03-25T20:56:57Z
workflows.jenkins.io                    2019-03-25T20:56:57Z
```

## Exploring tekton

```bash
kubectl get pipelines
```

```
NAME                              AGE
vfarcic-environment-jx-rocks-st   18m
vfarcic-jx-go-master              21m
```

```bash
GH_USER=[...]

kubectl describe pipeline \
  $GH_USER-jx-go-master
```

```yaml
Name:         vfarcic-jx-go-master
Namespace:    cd
Labels:       <none>
Annotations:  jenkins.io/last-build-number: 1
API Version:  tekton.dev/v1alpha1
Kind:         Pipeline
Metadata:
  Creation Timestamp:  2019-03-25T21:27:35Z
  Generation:          2
  Resource Version:    7509
  Self Link:           /apis/tekton.dev/v1alpha1/namespaces/cd/pipelines/vfarcic-jx-go-master
  UID:                 cebd0e06-4f44-11e9-8fc7-42010a8e0fc8
Spec:
  Params:
    Default:      0.0.1
    Description:  the version number for this pipeline which is used as a tag on docker images and helm charts
    Name:         version
    Default:      1
    Description:  the PipelineRun build number
    Name:         build_id
  Resources:
    Name:  vfarcic-jx-go-master
    Type:  git
  Tasks:
    Name:  from-build-pack
    Params:
      Name:   version
      Value:  ${params.version}
      Name:   build_id
      Value:  1
    Resources:
      Inputs:
        Name:      source
        Resource:  vfarcic-jx-go-master
      Outputs:     <nil>
    Task Ref:
      API Version:  tekton.dev/v1alpha1
      Kind:         Task
      Name:         vfarcic-jx-go-master
Events:             <none>
```

```bash
kubectl describe task \
  $GH_USER-jx-go-master
```

```yaml
Name:         vfarcic-jx-go-master
Namespace:    cd
Labels:       branch=master
              created-by-prow=true
              jenkins.io/task-stage-name=from-build-pack
              owner=vfarcic
              prowJobName=c6c1c290-4f44-11e9-acd0-acde48001122
              repo=jx-go
Annotations:  <none>
API Version:  tekton.dev/v1alpha1
Kind:         Task
Metadata:
  Creation Timestamp:  2019-03-25T21:27:35Z
  Generation:          1
  Resource Version:    7506
  Self Link:           /apis/tekton.dev/v1alpha1/namespaces/cd/tasks/vfarcic-jx-go-master
  UID:                 ceb991b7-4f44-11e9-8fc7-42010a8e0fc8
Spec:
  Inputs:
    Params:
      Default:      0.0.1
      Description:  the version number for this pipeline which is used as a tag on docker images and helm charts
      Name:         version
      Default:      1
      Description:  the PipelineRun build number
      Name:         build_id
    Resources:
      Name:         source
      Target Path:  
      Type:         git
  Steps:
    Args:
      -c
      jx step git credentials
    Command:
      /bin/sh
    Env:
      Name:  DOCKER_REGISTRY
      Value From:
        Config Map Key Ref:
          Key:   docker.registry
          Name:  jenkins-x-docker-registry
      Name:      TILLER_NAMESPACE
      Value:     kube-system
      Name:      DOCKER_CONFIG
      Value:     /home/jenkins/.docker/
      Name:      GIT_AUTHOR_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_AUTHOR_NAME
      Value:     jenkins-x-bot
      Name:      GIT_COMMITTER_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_COMMITTER_NAME
      Value:     jenkins-x-bot
      Name:      XDG_CONFIG_HOME
      Value:     /workspace/xdg_config
      Name:      PIPELINE_KIND
      Value:     release
      Name:      REPO_OWNER
      Value:     vfarcic
      Name:      REPO_NAME
      Value:     jx-go
      Name:      JOB_NAME
      Value:     vfarcic/jx-go/master
      Name:      APP_NAME
      Value:     jx-go
      Name:      BRANCH_NAME
      Value:     master
      Name:      JX_BATCH_MODE
      Value:     true
      Name:      VERSION
      Value:     ${inputs.params.version}
      Name:      BUILD_ID
      Value:     ${inputs.params.build_id}
      Name:      PREVIEW_VERSION
      Value:     ${inputs.params.version}
    Image:       gcr.io/jenkinsxio/builder-go:0.1.324
    Name:        setup-jx-git-credentials
    Resources:
      Requests:
        Cpu:     400m
        Memory:  600Mi
    Security Context:
      Privileged:  true
    Volume Mounts:
      Mount Path:  /home/jenkins
      Name:        workspace-volume
      Mount Path:  /var/run/docker.sock
      Name:        docker-daemon
      Mount Path:  /home/jenkins/.docker
      Name:        volume-0
      Mount Path:  /etc/podinfo
      Name:        podinfo
      Read Only:   true
    Working Dir:   /workspace/source
    Args:
      -c
      make build
    Command:
      /bin/sh
    Env:
      Name:  DOCKER_REGISTRY
      Value From:
        Config Map Key Ref:
          Key:   docker.registry
          Name:  jenkins-x-docker-registry
      Name:      TILLER_NAMESPACE
      Value:     kube-system
      Name:      DOCKER_CONFIG
      Value:     /home/jenkins/.docker/
      Name:      GIT_AUTHOR_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_AUTHOR_NAME
      Value:     jenkins-x-bot
      Name:      GIT_COMMITTER_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_COMMITTER_NAME
      Value:     jenkins-x-bot
      Name:      XDG_CONFIG_HOME
      Value:     /workspace/xdg_config
      Name:      PIPELINE_KIND
      Value:     release
      Name:      REPO_OWNER
      Value:     vfarcic
      Name:      REPO_NAME
      Value:     jx-go
      Name:      JOB_NAME
      Value:     vfarcic/jx-go/master
      Name:      APP_NAME
      Value:     jx-go
      Name:      BRANCH_NAME
      Value:     master
      Name:      JX_BATCH_MODE
      Value:     true
      Name:      VERSION
      Value:     ${inputs.params.version}
      Name:      BUILD_ID
      Value:     ${inputs.params.build_id}
      Name:      PREVIEW_VERSION
      Value:     ${inputs.params.version}
    Image:       gcr.io/jenkinsxio/builder-go:0.1.324
    Name:        build-make-build
    Resources:
      Requests:
        Cpu:     400m
        Memory:  600Mi
    Security Context:
      Privileged:  true
    Volume Mounts:
      Mount Path:  /home/jenkins
      Name:        workspace-volume
      Mount Path:  /var/run/docker.sock
      Name:        docker-daemon
      Mount Path:  /home/jenkins/.docker
      Name:        volume-0
      Mount Path:  /etc/podinfo
      Name:        podinfo
      Read Only:   true
    Working Dir:   /workspace/source
    Args:
      --cache=true
      --cache-dir=/workspace
      --context=/workspace/source
      --dockerfile=/workspace/source/Dockerfile
      --destination=10.31.247.178:5000/vfarcic/jx-go:${inputs.params.version}
      --cache-repo=10.31.247.178:5000/
      --skip-tls-verify-registry=10.31.247.178:5000
      --insecure
    Command:
      /kaniko/executor
    Env:
      Name:  DOCKER_REGISTRY
      Value From:
        Config Map Key Ref:
          Key:   docker.registry
          Name:  jenkins-x-docker-registry
      Name:      TILLER_NAMESPACE
      Value:     kube-system
      Name:      DOCKER_CONFIG
      Value:     /home/jenkins/.docker/
      Name:      GIT_AUTHOR_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_AUTHOR_NAME
      Value:     jenkins-x-bot
      Name:      GIT_COMMITTER_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_COMMITTER_NAME
      Value:     jenkins-x-bot
      Name:      XDG_CONFIG_HOME
      Value:     /workspace/xdg_config
      Name:      PIPELINE_KIND
      Value:     release
      Name:      REPO_OWNER
      Value:     vfarcic
      Name:      REPO_NAME
      Value:     jx-go
      Name:      JOB_NAME
      Value:     vfarcic/jx-go/master
      Name:      APP_NAME
      Value:     jx-go
      Name:      BRANCH_NAME
      Value:     master
      Name:      JX_BATCH_MODE
      Value:     true
      Name:      VERSION
      Value:     ${inputs.params.version}
      Name:      BUILD_ID
      Value:     ${inputs.params.build_id}
      Name:      PREVIEW_VERSION
      Value:     ${inputs.params.version}
    Image:       rawlingsj/executor:dev40
    Name:        build-container-build
    Resources:
      Requests:
        Cpu:     400m
        Memory:  600Mi
    Security Context:
      Privileged:  true
    Volume Mounts:
      Mount Path:  /home/jenkins
      Name:        workspace-volume
      Mount Path:  /var/run/docker.sock
      Name:        docker-daemon
      Mount Path:  /home/jenkins/.docker
      Name:        volume-0
      Mount Path:  /etc/podinfo
      Name:        podinfo
      Read Only:   true
    Working Dir:   /workspace/source
    Args:
      -c
      jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:${VERSION}
    Command:
      /bin/sh
    Env:
      Name:  DOCKER_REGISTRY
      Value From:
        Config Map Key Ref:
          Key:   docker.registry
          Name:  jenkins-x-docker-registry
      Name:      TILLER_NAMESPACE
      Value:     kube-system
      Name:      DOCKER_CONFIG
      Value:     /home/jenkins/.docker/
      Name:      GIT_AUTHOR_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_AUTHOR_NAME
      Value:     jenkins-x-bot
      Name:      GIT_COMMITTER_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_COMMITTER_NAME
      Value:     jenkins-x-bot
      Name:      XDG_CONFIG_HOME
      Value:     /workspace/xdg_config
      Name:      PIPELINE_KIND
      Value:     release
      Name:      REPO_OWNER
      Value:     vfarcic
      Name:      REPO_NAME
      Value:     jx-go
      Name:      JOB_NAME
      Value:     vfarcic/jx-go/master
      Name:      APP_NAME
      Value:     jx-go
      Name:      BRANCH_NAME
      Value:     master
      Name:      JX_BATCH_MODE
      Value:     true
      Name:      VERSION
      Value:     ${inputs.params.version}
      Name:      BUILD_ID
      Value:     ${inputs.params.build_id}
      Name:      PREVIEW_VERSION
      Value:     ${inputs.params.version}
    Image:       gcr.io/jenkinsxio/builder-go:0.1.324
    Name:        build-post-build
    Resources:
      Requests:
        Cpu:     400m
        Memory:  600Mi
    Security Context:
      Privileged:  true
    Volume Mounts:
      Mount Path:  /home/jenkins
      Name:        workspace-volume
      Mount Path:  /var/run/docker.sock
      Name:        docker-daemon
      Mount Path:  /home/jenkins/.docker
      Name:        volume-0
      Mount Path:  /etc/podinfo
      Name:        podinfo
      Read Only:   true
    Working Dir:   /workspace/source
    Args:
      -c
      jx step changelog --version v${VERSION}
    Command:
      /bin/sh
    Env:
      Name:  DOCKER_REGISTRY
      Value From:
        Config Map Key Ref:
          Key:   docker.registry
          Name:  jenkins-x-docker-registry
      Name:      TILLER_NAMESPACE
      Value:     kube-system
      Name:      DOCKER_CONFIG
      Value:     /home/jenkins/.docker/
      Name:      GIT_AUTHOR_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_AUTHOR_NAME
      Value:     jenkins-x-bot
      Name:      GIT_COMMITTER_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_COMMITTER_NAME
      Value:     jenkins-x-bot
      Name:      XDG_CONFIG_HOME
      Value:     /workspace/xdg_config
      Name:      PIPELINE_KIND
      Value:     release
      Name:      REPO_OWNER
      Value:     vfarcic
      Name:      REPO_NAME
      Value:     jx-go
      Name:      JOB_NAME
      Value:     vfarcic/jx-go/master
      Name:      APP_NAME
      Value:     jx-go
      Name:      BRANCH_NAME
      Value:     master
      Name:      JX_BATCH_MODE
      Value:     true
      Name:      VERSION
      Value:     ${inputs.params.version}
      Name:      BUILD_ID
      Value:     ${inputs.params.build_id}
      Name:      PREVIEW_VERSION
      Value:     ${inputs.params.version}
    Image:       gcr.io/jenkinsxio/builder-go:0.1.324
    Name:        promote-changelog
    Resources:
      Requests:
        Cpu:     400m
        Memory:  600Mi
    Security Context:
      Privileged:  true
    Volume Mounts:
      Mount Path:  /home/jenkins
      Name:        workspace-volume
      Mount Path:  /var/run/docker.sock
      Name:        docker-daemon
      Mount Path:  /home/jenkins/.docker
      Name:        volume-0
      Mount Path:  /etc/podinfo
      Name:        podinfo
      Read Only:   true
    Working Dir:   /workspace/source/charts/jx-go
    Args:
      -c
      jx step helm release
    Command:
      /bin/sh
    Env:
      Name:  DOCKER_REGISTRY
      Value From:
        Config Map Key Ref:
          Key:   docker.registry
          Name:  jenkins-x-docker-registry
      Name:      TILLER_NAMESPACE
      Value:     kube-system
      Name:      DOCKER_CONFIG
      Value:     /home/jenkins/.docker/
      Name:      GIT_AUTHOR_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_AUTHOR_NAME
      Value:     jenkins-x-bot
      Name:      GIT_COMMITTER_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_COMMITTER_NAME
      Value:     jenkins-x-bot
      Name:      XDG_CONFIG_HOME
      Value:     /workspace/xdg_config
      Name:      PIPELINE_KIND
      Value:     release
      Name:      REPO_OWNER
      Value:     vfarcic
      Name:      REPO_NAME
      Value:     jx-go
      Name:      JOB_NAME
      Value:     vfarcic/jx-go/master
      Name:      APP_NAME
      Value:     jx-go
      Name:      BRANCH_NAME
      Value:     master
      Name:      JX_BATCH_MODE
      Value:     true
      Name:      VERSION
      Value:     ${inputs.params.version}
      Name:      BUILD_ID
      Value:     ${inputs.params.build_id}
      Name:      PREVIEW_VERSION
      Value:     ${inputs.params.version}
    Image:       gcr.io/jenkinsxio/builder-go:0.1.324
    Name:        promote-helm-release
    Resources:
      Requests:
        Cpu:     400m
        Memory:  600Mi
    Security Context:
      Privileged:  true
    Volume Mounts:
      Mount Path:  /home/jenkins
      Name:        workspace-volume
      Mount Path:  /var/run/docker.sock
      Name:        docker-daemon
      Mount Path:  /home/jenkins/.docker
      Name:        volume-0
      Mount Path:  /etc/podinfo
      Name:        podinfo
      Read Only:   true
    Working Dir:   /workspace/source/charts/jx-go
    Args:
      -c
      jx promote -b --all-auto --timeout 1h --version ${VERSION}
    Command:
      /bin/sh
    Env:
      Name:  DOCKER_REGISTRY
      Value From:
        Config Map Key Ref:
          Key:   docker.registry
          Name:  jenkins-x-docker-registry
      Name:      TILLER_NAMESPACE
      Value:     kube-system
      Name:      DOCKER_CONFIG
      Value:     /home/jenkins/.docker/
      Name:      GIT_AUTHOR_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_AUTHOR_NAME
      Value:     jenkins-x-bot
      Name:      GIT_COMMITTER_EMAIL
      Value:     jenkins-x@googlegroups.com
      Name:      GIT_COMMITTER_NAME
      Value:     jenkins-x-bot
      Name:      XDG_CONFIG_HOME
      Value:     /workspace/xdg_config
      Name:      PIPELINE_KIND
      Value:     release
      Name:      REPO_OWNER
      Value:     vfarcic
      Name:      REPO_NAME
      Value:     jx-go
      Name:      JOB_NAME
      Value:     vfarcic/jx-go/master
      Name:      APP_NAME
      Value:     jx-go
      Name:      BRANCH_NAME
      Value:     master
      Name:      JX_BATCH_MODE
      Value:     true
      Name:      VERSION
      Value:     ${inputs.params.version}
      Name:      BUILD_ID
      Value:     ${inputs.params.build_id}
      Name:      PREVIEW_VERSION
      Value:     ${inputs.params.version}
    Image:       gcr.io/jenkinsxio/builder-go:0.1.324
    Name:        promote-jx-promote
    Resources:
      Requests:
        Cpu:     400m
        Memory:  600Mi
    Security Context:
      Privileged:  true
    Volume Mounts:
      Mount Path:  /home/jenkins
      Name:        workspace-volume
      Mount Path:  /var/run/docker.sock
      Name:        docker-daemon
      Mount Path:  /home/jenkins/.docker
      Name:        volume-0
      Mount Path:  /etc/podinfo
      Name:        podinfo
      Read Only:   true
    Working Dir:   /workspace/source/charts/jx-go
  Volumes:
    Empty Dir:
    Name:  workspace-volume
    Host Path:
      Path:  /var/run/docker.sock
    Name:    docker-daemon
    Name:    volume-0
    Secret:
      Secret Name:  jenkins-docker-cfg
    Downward API:
      Items:
        Field Ref:
          Field Path:  metadata.labels
        Path:          labels
    Name:              podinfo
Events:                <none>
```

```bash
kubectl get pipelineruns
```

```
NAME                                AGE
vfarcic-environment-jx-rocks-st-1   22m
vfarcic-environment-jx-rocks-st-2   21m
vfarcic-jx-go-master-1              25m
```

```bash
kubectl describe pipelinerun \
  $GH_USER-jx-go-master-1
```

```
Name:         vfarcic-jx-go-master-1
Namespace:    cd
Labels:       branch=master
              build-number=1
              created-by-prow=true
              owner=vfarcic
              prowJobName=c6c1c290-4f44-11e9-acd0-acde48001122
              repo=jx-go
              tekton.dev/pipeline=vfarcic-jx-go-master
Annotations:  <none>
API Version:  tekton.dev/v1alpha1
Kind:         PipelineRun
Metadata:
  Creation Timestamp:  2019-03-25T21:27:35Z
  Generation:          1
  Owner References:
    API Version:     tekton.dev/v1alpha1
    Kind:            Pipeline
    Name:            vfarcic-jx-go-master
    UID:             cebd0e06-4f44-11e9-8fc7-42010a8e0fc8
  Resource Version:  8550
  Self Link:         /apis/tekton.dev/v1alpha1/namespaces/cd/pipelineruns/vfarcic-jx-go-master-1
  UID:               cebf3224-4f44-11e9-8fc7-42010a8e0fc8
Spec:
  Status:  
  Params:
    Name:   version
    Value:  0.0.1
    Name:   build_id
    Value:  1
  Pipeline Ref:
    API Version:  tekton.dev/v1alpha1
    Name:         vfarcic-jx-go-master
  Resources:
    Name:  vfarcic-jx-go-master
    Resource Ref:
      API Version:  tekton.dev/v1alpha1
      Name:         vfarcic-jx-go-master
  Service Account:  tekton-bot
  Trigger:
    Type:  manual
Status:
  Conditions:
    Last Transition Time:  2019-03-25T21:32:05Z
    Message:               All Tasks have completed executing
    Reason:                Succeeded
    Status:                True
    Type:                  Succeeded
  Start Time:              2019-03-25T21:27:35Z
  Task Runs:
    Vfarcic - Jx - Go - Master - 1 - From - Build - Pack - Qlmwz:
      Pipeline Task Name:  from-build-pack
      Status:
        Conditions:
          Last Transition Time:  2019-03-25T21:32:05Z
          Status:                True
          Type:                  Succeeded
        Pod Name:                vfarcic-jx-go-master-1-from-build-pack-qlmwz-pod-35e47d
        Start Time:              2019-03-25T21:27:35Z
        Steps:
          Terminated:
            Container ID:  docker://ee34d534a3fb2c6900c39fc8c52710099040f9182cd06f492388f0c73c3dec50
            Exit Code:     0
            Finished At:   2019-03-25T21:27:41Z
            Reason:        Completed
            Started At:    2019-03-25T21:27:41Z
          Terminated:
            Container ID:  docker://7afa6bf8f58e0f4c06b2b94cc0c629177e6ec50e0b89d50f27aad3217f56bb66
            Exit Code:     0
            Finished At:   2019-03-25T21:27:44Z
            Reason:        Completed
            Started At:    2019-03-25T21:27:44Z
          Terminated:
            Container ID:  docker://b8a59d84b1eef868d2e4b4f28045510ee30c56afb19c293f4e568b7cff79691d
            Exit Code:     0
            Finished At:   2019-03-25T21:29:41Z
            Reason:        Completed
            Started At:    2019-03-25T21:29:40Z
          Terminated:
            Container ID:  docker://58d3c5922765322c57fd8d9a0909fb66cabd21636ac610220c9c77635b81e73a
            Exit Code:     0
            Finished At:   2019-03-25T21:29:47Z
            Reason:        Completed
            Started At:    2019-03-25T21:29:42Z
          Terminated:
            Container ID:  docker://6ffda10ea2855e2a7f407ec9cad9e258a8fdb7ce9f5c6a72160e86a99c63d371
            Exit Code:     0
            Finished At:   2019-03-25T21:29:51Z
            Reason:        Completed
            Started At:    2019-03-25T21:29:50Z
          Terminated:
            Container ID:  docker://c454179a40e544579164f7033772a028f03eca6d14415c664219cc04c0c78b40
            Exit Code:     0
            Finished At:   2019-03-25T21:29:52Z
            Reason:        Completed
            Started At:    2019-03-25T21:29:52Z
          Terminated:
            Container ID:  docker://23c715f64188ab1b74d5e7b6bc36d34bd7895e286b092e34a1759ac0e9bf387a
            Exit Code:     0
            Finished At:   2019-03-25T21:29:55Z
            Reason:        Completed
            Started At:    2019-03-25T21:29:53Z
          Terminated:
            Container ID:  docker://ad78128a38b1296ad056abfa14570d2d88014c44c62a315a2046ba79c392d417
            Exit Code:     0
            Finished At:   2019-03-25T21:29:59Z
            Reason:        Completed
            Started At:    2019-03-25T21:29:56Z
          Terminated:
            Container ID:  docker://f429db5b57d56609ef8fc1de2b997226801e146ff900ad4ddaa54f5f9abc3332
            Exit Code:     0
            Finished At:   2019-03-25T21:31:36Z
            Reason:        Completed
            Started At:    2019-03-25T21:30:00Z
Events:
  Type    Reason                Age                 From                 Message
  ----    ------                ----                ----                 -------
  Normal  PipelineRunSucceeded  22m (x15 over 26m)  pipeline-controller  PipelineRun reconciled successfully
  Normal  Succeeded             22m                 pipeline-controller  All Tasks have completed executing
  Normal  PipelineRunSucceeded  78s (x43 over 22m)  pipeline-controller  PipelineRun completed successfully.
```

## Exploring prow

- [ ] Job execution for testing, batch processing, artifact publishing.
- [ ] GitHub events are used to trigger post-PR-merge (postsubmit) jobs and on-PR-update (presubmit) jobs.
- [ ] Support for multiple execution platforms and source code review sites.
- [ ] Pluggable GitHub bot automation that implements /foo style commands and enforces configured policies/processes.
- [ ] GitHub merge automation with batch testing logic.
- [ ] Front end for viewing jobs, merge queue status, dynamically generated help information, and more.
- [ ] Automatic deployment of source control based config.
- [ ] Automatic GitHub org/repo administration configured in source control.
- [ ] Designed for multi-org scale with dozens of repositories. (The Kubernetes Prow instance uses only 1 GitHub bot token!)
- [ ] High availability as benefit of running on Kubernetes. (replication, load balancing, rolling updates...)
- [ ] JSON structured logs.
- [ ] Prometheus metrics.

## Exploring jenkins-x.yaml file

```bash
cat jx-go/jenkins-x.yml
```

```yaml
buildPack: go
```

TODO: Explain where the build pack definition is

## Importing Static Projects Into Serverless Jenkins X

TODO: Restore the branch from the previous chapter to master

```bash
cd go-demo-6

git checkout master

git pull

rm Jenkinsfile

echo "buildPack: go" | tee jenkins-x.yml

jx import -b
```

```
No username defined for the current Git server!
trying to use draft pack: go
selected pack: /Users/vfarcic/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs/go
Failed to apply the build pack in /Users/vfarcic/code/go-demo-6 due to mkdir /Users/vfarcic/code/go-demo-6/charts/preview: file exists
replacing placeholders in directory /Users/vfarcic/code/go-demo-6
app name: go-demo-6, git server: github.com, org: vfarcic, Docker registry org: vfarcic
skipping directory "/Users/vfarcic/code/go-demo-6/.git"
skipping ignored file "/Users/vfarcic/code/go-demo-6/charts/go-demo-6/charts/mongodb-5.3.0.tgz"
Creating GitHub webhook for vfarcic/go-demo-6 for url http://hook.jx.34.73.176.245.nip.io/hook

Watch pipeline activity via:    jx get activity -f go-demo-6 -w
Browse the pipeline log via:    jx get build logs vfarcic/go-demo-6/master
Open the Jenkins console via    jx console
You can list the pipelines via: jx get pipelines
When the pipeline is complete:  jx get applications

For more help on available commands see: https://jenkins-x.io/developing/browsing/

Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!
```

```bash
jx get activities -f go-demo-6 -w

# Cancel the watcher with *ctrl+c*
```

```
STEP                                          STARTED AGO DURATION STATUS
vfarcic/go-demo-6/master #1                          2m0s    1m27s Succeeded Version: 0.0.187
  from build pack                                    2m0s    1m27s Succeeded
    Credential Initializer Q8tkq                     2m0s       0s Succeeded
    Git Source Vfarcic Go Demo 6 Master Mqtf8       1m59s       0s Succeeded https://github.com/vfarcic/go-demo-6
    Place Tools                                     1m58s       0s Succeeded
    Setup Jx Git Credentials                        1m57s       0s Succeeded
    Build Make Build                                1m56s      16s Succeeded
    Build Container Build                           1m36s       1s Succeeded
    Build Post Build                                1m35s       0s Succeeded
    Promote Changelog                               1m34s       4s Succeeded
    Promote Helm Release                            1m29s       7s Succeeded
    Promote Jx Promote                              1m21s      48s Succeeded
  Promote: staging                                  1m17s      44s Succeeded
    PullRequest                                     1m17s      44s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-rocks-staging/pull/3 Merge SHA: 3469f54a6f428fd290003a359d3472fe2c252aa2
    Update                                            33s       0s Succeeded
```

```bash
jx get build logs -f go-demo-6
```

```
Build logs for vfarcic/go-demo-6/master #1
getting the log for build vfarcic/go-demo-6/master #1 stage from build pack and container build-step-credential-initializer-q8tkq
{"level":"warn","ts":1553597490.344126,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/backport-container-name-fix\" is not a valid GitHub commit ID"}
{"level":"info","ts":1553597490.3448393,"logger":"fallback-logger","caller":"creds-init/main.go:40","msg":"Credentials initialized."}
getting the log for build vfarcic/go-demo-6/master #1 stage from build pack and container build-step-git-source-vfarcic-go-demo-6-master-mqtf8
{"level":"warn","ts":1553597491.2683258,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/backport-container-name-fix\" is not a valid GitHub commit ID"}
{"level":"info","ts":1553597491.5940633,"logger":"fallback-logger","caller":"git-init/main.go:99","msg":"Successfully cloned \"https://github.com/vfarcic/go-demo-6\" @ \"v0.0.187\" in path \"/workspace/source\""}
getting the log for build vfarcic/go-demo-6/master #1 stage from build pack and container build-step-place-tools
getting the log for build vfarcic/go-demo-6/master #1 stage from build pack and container build-step-setup-jx-git-credentials
Generated Git credentials file /workspace/xdg_config/git/credentials
getting the log for build vfarcic/go-demo-6/master #1 stage from build pack and container build-step-build-make-build
go: finding github.com/golang/protobuf v1.2.0
go: finding github.com/beorn7/perks v0.0.0-20180321164747-3a771d992973
go: finding github.com/matttproud/golang_protobuf_extensions v1.0.1
go: finding github.com/prometheus/procfs v0.0.0-20181204211112-1dc9a6cbc91a
go: finding github.com/pmezard/go-difflib v1.0.0
go: finding github.com/prometheus/common v0.0.0-20181126121408-4724e9255275
go: finding github.com/stretchr/objx v0.1.1
go: finding github.com/stretchr/testify v1.2.2
go: finding github.com/prometheus/client_model v0.0.0-20180712105110-5c3871d89910
go: finding gopkg.in/mgo.v2 v2.0.0-20180705113604-9856a29383ce
go: finding github.com/prometheus/client_golang v0.9.2
go: finding github.com/davecgh/go-spew v1.1.1
go: finding golang.org/x/net v0.0.0-20181201002055-351d144fa1fc
go: finding golang.org/x/sync v0.0.0-20181108010431-42b317875d0f
go: downloading gopkg.in/mgo.v2 v2.0.0-20180705113604-9856a29383ce
go: downloading github.com/prometheus/client_golang v0.9.2
go: downloading github.com/prometheus/procfs v0.0.0-20181204211112-1dc9a6cbc91a
go: downloading github.com/beorn7/perks v0.0.0-20180321164747-3a771d992973
go: downloading github.com/golang/protobuf v1.2.0
go: downloading github.com/prometheus/common v0.0.0-20181126121408-4724e9255275
go: downloading github.com/prometheus/client_model v0.0.0-20180712105110-5c3871d89910
go: downloading github.com/matttproud/golang_protobuf_extensions v1.0.1
CGO_ENABLED=0 GO15VENDOREXPERIMENT=1 go build -ldflags '' -o bin/go-demo-6 main.go
getting the log for build vfarcic/go-demo-6/master #1 stage from build pack and container build-step-build-container-build
INFO[0000] No base image, nothing to extract
INFO[0000] cmd: EXPOSE
INFO[0000] Adding exposed port: 8080/tcp
INFO[0000] Using files from context: [/workspace/source/bin]
INFO[0000] Skipping unpacking as no commands require it.
INFO[0000] Taking snapshot of full filesystem...
INFO[0000] EXPOSE 8080
INFO[0000] cmd: EXPOSE
INFO[0000] Adding exposed port: 8080/tcp
INFO[0000] No files changed in this command, skipping snapshotting.
INFO[0000] ENTRYPOINT ["/go-demo-6"]
INFO[0000] No files changed in this command, skipping snapshotting.
INFO[0000] Using files from context: [/workspace/source/bin]
INFO[0000] COPY ./bin/ /
INFO[0000] Taking snapshot of files...
ERROR: logging before flag.Parse: E0326 10:51:54.544298       9 metadata.go:142] while reading 'google-dockercfg' metadata: http status code: 404 while fetching url http://metadata.google.internal./computeMetadata/v1/instance/attributes/google-dockercfg
ERROR: logging before flag.Parse: E0326 10:51:54.547496       9 metadata.go:159] while reading 'google-dockercfg-url' metadata: http status code: 404 while fetching url http://metadata.google.internal./computeMetadata/v1/instance/attributes/google-dockercfg-url
2019/03/26 10:51:54 pushed blob sha256:13b858e7407ec62ab0645af97bdf9ab68fb5a25a5317e4364c0913059ef10ab5
2019/03/26 10:51:55 pushed blob sha256:1fcfd7fac3bcbd98e6213591442d319893d6f69280a8564a4e1882e41d02b02b
2019/03/26 10:51:55 10.31.246.216:5000/vfarcic/go-demo-6:0.0.187: digest: sha256:bc23203014d4a633f71d13a496f9315822148d8df29caf24190bf05d7e150f09 size: 428
getting the log for build vfarcic/go-demo-6/master #1 stage from build pack and container build-step-build-post-build
no CVE provider running in the current jx namespace so skip adding image to be analysed
getting the log for build vfarcic/go-demo-6/master #1 stage from build pack and container build-step-promote-changelog
Converted /workspace/source/charts/go-demo-6 to an unshallow repository
Generating change log from git ref 7d5b1c52d320886c5d3797a43bb8e42cc0a4b9e7 => 706b9531821ac0a2dec02398bedcaa28766c005f
Failed to enrich commits with issues: User.jenkins.io "" is invalid: metadata.name: Required value: name or generateName is required
Failed to enrich commits with issues: User.jenkins.io "" is invalid: metadata.name: Required value: name or generateName is required
Finding issues in commit messages using git format
No release found for vfarcic/go-demo-6 and tag v0.0.187 so creating a new release
Updated the release information at https://github.com/vfarcic/go-demo-6/releases/tag/v0.0.187
generated: /workspace/source/charts/go-demo-6/templates/release.yaml
Created Release go-demo-6-0-0-187 resource in namespace jx
Updating PipelineActivity vfarcic-go-demo-6-master-1 with version 0.0.187
Updated PipelineActivities vfarcic-go-demo-6-master-1 with release notes URL: https://github.com/vfarcic/go-demo-6/releases/tag/v0.0.187
getting the log for build vfarcic/go-demo-6/master #1 stage from build pack and container build-step-promote-helm-release
No $CHART_REPOSITORY defined so using the default value of: http://jenkins-x-chartmuseum:8080
Adding missing Helm repo: jenkins-x http://chartmuseum.jenkins-x.io
Successfully added Helm repository jenkins-x.
Adding missing Helm repo: releases http://jenkins-x-chartmuseum:8080
Successfully added Helm repository releases.
No $CHART_REPOSITORY defined so using the default value of: http://jenkins-x-chartmuseum:8080
Uploading chart file go-demo-6-0.0.187.tgz to http://jenkins-x-chartmuseum:8080/api/charts
Received 201 response: {"saved":true}
getting the log for build vfarcic/go-demo-6/master #1 stage from build pack and container build-step-promote-jx-promote
prow based install so skip waiting for the merge of Pull Requests to go green as currently there is an issue with gettingstatuses from the PR, see https://github.com/jenkins-x/jx/issues/2410
Promoting app go-demo-6 version 0.0.187 to namespace jx-staging
Created Pull Request: https://github.com/vfarcic/environment-jx-rocks-staging/pull/3

Pull Request https://github.com/vfarcic/environment-jx-rocks-staging/pull/3 is merged at sha 3469f54a6f428fd290003a359d3472fe2c252aa2
Pull Request merged but we are not waiting for the update pipeline to complete!
Could not find the service URL in namespace jx-staging for names go-demo-6, jx-go-demo-6, jx-staging-go-demo-6
```

```bash
cat OWNERS
```

```yaml
approvers:
- vfarcic
reviewers:
- vfarcic
```

```bash
kubectl get pipelines
```

```
NAME                            AGE
vfarcic-environment-jx-rocks-pr 1h
vfarcic-environment-jx-rocks-st 1h
vfarcic-go-demo-6-master        17m
vfarcic-jx-go-master            1h
```

```bash
kubectl describe pipeline \
  $GH_USER-go-demo-6-master
```

```yaml
Name:         vfarcic-go-demo-6-master
Namespace:    jx
Labels:       <none>
Annotations:  jenkins.io/last-build-number: 1
API Version:  tekton.dev/v1alpha1
Kind:         Pipeline
Metadata:
  Creation Timestamp:  2019-03-26T10:51:28Z
  Generation:          2
  Resource Version:    21761
  Self Link:           /apis/tekton.dev/v1alpha1/namespaces/jx/pipelines/vfarcic-go-demo-6-master
  UID:                 1ba3b420-4fb5-11e9-94dd-42010a8e0265
Spec:
  Params:
    Default:      0.0.187
    Description:  the version number for this pipeline which is used as a tag on docker images and helm charts
    Name:         version
    Default:      1
    Description:  the PipelineRun build number
    Name:         build_id
  Resources:
    Name:  vfarcic-go-demo-6-master
    Type:  git
  Tasks:
    Name:  from-build-pack
    Params:
      Name:   version
      Value:  ${params.version}
      Name:   build_id
      Value:  1
    Resources:
      Inputs:
        Name:      source
        Resource:  vfarcic-go-demo-6-master
      Outputs:     <nil>
    Task Ref:
      API Version:  tekton.dev/v1alpha1
      Kind:         Task
      Name:         vfarcic-go-demo-6-master
Events:             <none>
```

TODO: Continue code

TODO: Add to jenkins-x.yml

```yaml
pipelineConfig:
  pipelines:
    release:
      pipeline:
        agent:
          image: some-image
        stages:
          - name: First Stage
            steps:
              - command: echo
                args: ['first']
          - name: Parent Stage
            parallel:
              - name: A Working Stage
                steps:
                  - command: echo
                    args:
                      - hello
                      - world
              - name: Nested In Parallel
                stages:
                  - name: Another stage
                    steps:
                      - command: echo
                        args: ['again']
                  - name: Some other stage
                    steps:
                      - command: echo
                        args: ['otherwise']
          - name: Last Stage
            steps:
              - command: echo
                args: ['last']
```

```bash
git add .

git commit -m "Switched to serverless"

git push

jx get build logs -f go-demo-6

jx get build logs -f environment-jx-rocks-staging

GD6_ADDR=$(kubectl -n cd-staging \
    get ing go-demo-6 \
    -o jsonpath="{.spec.rules[0].host}")

echo $GD6_ADDR

curl "http://$GD6_ADDR/demo/hello"
```

NOTE: Use centralized logging

NOTE: GitHub only (for now)

```bash
kubectl -n cd describe cm plugins

git checkout -b prow

jx create issue -t "prow" \
    --body "Test prow support" \
    -b

ISSUE_ID=[...]

GH_USER=[...]

open "https://github.com/$GH_USER/go-demo-6/issues/$ISSUE_ID"

cat main.go | sed -e "s@hello, PR@hello, prow@g" | tee main_test.go

cat main.go | sed -e "s@hello, PR@hello, prow@g" | tee main.go

git add . && git commit -m "prow #$ISSUE_ID" && git push --set-upstream origin prow

# Create a PR

jx get activities -w

PR_ID=[...]

PR_ADDR=$(kubectl -n cd-$GH_USER-go-demo-6-pr-$PR_ID get ing go-demo-6 -o jsonpath="{.spec.rules[0].host}")

echo $PR_ADDR

curl "http://$PR_ADDR/demo/hello"

# Add `/assign` to the PR

open "https://github.com/$GH_USER/go-demo-6/pull/$PR_ID"

# Type `/meow` as the comment

# Type `/assign @vfarcic` as the comment

# I type `/lgtm` as the comment

# I type `/approve` as the comment

jx get activities -w
```

TODO: gh-pages branch

TODO: Automatic periodic upgrades

TODO: Check whether devpods work

```bash
# If GKE
gcloud container clusters \
    delete jx-rocks \
    --zone us-east1-b \
    --quiet

# If GKE
# Remove unused disks to avoid reaching the quota (and save a bit of money)
gcloud compute disks delete \
    $(gcloud compute disks list \
    --filter="-users:*" \
    --format="value(id)")

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

hub delete -y $GH_USER/jx-go

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf jx-go

rm -f ~/.jx/jenkinsAuth.yaml
```