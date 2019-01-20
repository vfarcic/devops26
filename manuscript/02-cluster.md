## TODO

- [ ] Code
- [ ] Write
- [ ] Code review
- [ ] Text review
- [ ] Highlights
- [ ] Diagrams
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Creating A Cluster With jx

## Creating A Cluster With jx

```bash
jx create cluster
```

```
This command creates a new Kubernetes cluster, installing required local dependencies and provisions the Jenkins X platform 

You can see a demo of this command here: https://jenkins-x.io/demos/create_cluster/

Valid Kubernetes providers include:

    * aks (Azure Container Service - https://docs.microsoft.com/en-us/azure/aks)
    * aws (Amazon Web Services via kops - https://github.com/aws-samples/aws-workshop-for-kubernetes/blob/master/readme.adoc)
    * eks (Amazon Web Services Elastic Container Service for Kubernetes - https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
    * gke (Google Container Engine - https://cloud.google.com/kubernetes-engine)
    * oke (Oracle Cloud Infrastructure Container Engine for Kubernetes - https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengoverview.htm)
    # icp (IBM Cloud Private) - https://www.ibm.com/cloud/private
    * iks (IBM Cloud Kubernetes Service - https://console.bluemix.net/docs/containers)
    * oke (Oracle Cloud Infrastructure Container Engine for Kubernetes - https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengoverview.htm)
    * kubernetes for custom installations of Kubernetes
    * minikube (single-node Kubernetes cluster inside a VM on your laptop)
	* minishift (single-node OpenShift cluster inside a VM on your laptop)
	* openshift for installing on 3.9.x or later clusters of OpenShift
 

Depending on which cloud provider your cluster is created on possible dependencies that will be installed are: 

  * kubectl (CLI to interact with Kubernetes clusters)  
  * helm (package manager for Kubernetes)  
  * draft (CLI that makes it easy to build applications that run on Kubernetes)  
  * minikube (single-node Kubernetes cluster inside a VM on your laptop )  
  * minishift (single-node OpenShift cluster inside a VM on your laptop)  
  * virtualisation drivers (to run Minikube in a VM)  
  * gcloud (Google Cloud CLI)  
  * oci (Oracle Cloud Infrastructure CLI)  
  * az (Azure CLI)  
  * ibmcloud (IBM CLoud CLI)  

For more documentation see: https://jenkins-x.io/getting-started/create-cluster/

Examples:
  jx create cluster minikube
Available Commands:
  create cluster aks       Create a new Kubernetes cluster on AKS: Runs on Azure
  create cluster aws       Create a new Kubernetes cluster on AWS with kops
  create cluster eks       Create a new Kubernetes cluster on AWS using EKS
  create cluster gke       Create a new Kubernetes cluster on GKE: Runs on Google Cloud
  create cluster iks       Create a new kubernetes cluster on IBM Cloud Kubernetes Services
  create cluster minikube  Create a new Kubernetes cluster with Minikube: Runs locally
  create cluster minishift Create a new OpenShift cluster with Minishift: Runs locally
  create cluster oke       Create a new Kubernetes cluster on OKE: Runs on Oracle Cloud

Usage:
  jx create cluster [kubernetes provider] [flags] [options]
Use "jx <command> --help" for more information about a given command.
Use "jx options" for a list of global command-line options (applies to all commands).
```

## Creating A GKE Cluster With jx

```bash
PROJECT=[...] # e.g. devops24-book

jx create cluster gke \
    -n jx-rocks \
    -p $PROJECT \
    -z us-east1-b \
    -m n1-standard-2 \
    --min-num-nodes 3 \
    --max-num-nodes 5 \
    --default-admin-password=admin \
    --default-environment-prefix jx-rocks
```

NOTE: Answered to all questions with default values

```
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?redirect_uri=http%3A%2F%2Flocalhost%3A8085%2F&prompt=select_account&response_type=code&client_id=32555940559.apps.googleusercontent.com&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fappengine.admin+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcompute+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth&access_type=offline


Updated property [core/project].
Let's ensure we have container and compute enabled on your project via: gcloud services enable container compute
Operation "operations/acf.427f13e4-c1f4-4861-9449-7ea07bdf444f" finished successfully.
Creating cluster...
Initialising cluster ...
Namespace jx created
 Using helmBinary helm with feature flag: none
Context "gke_devops24-book_us-east1-b_jx-rocks" modified.
Storing the kubernetes provider gke in the TeamSettings
Git configured for user: Viktor Farcic and email vfarcic@farcic.com
Trying to create ClusterRoleBinding viktor-farcic-com-cluster-admin-binding for role: cluster-admin for user viktor@farcic.com
 clusterrolebindings.rbac.authorization.k8s.io "viktor-farcic-com-cluster-admin-binding" not found
Created ClusterRoleBinding viktor-farcic-com-cluster-admin-binding
Using helm2
Configuring tiller
Created ServiceAccount tiller in namespace kube-system
Trying to create ClusterRoleBinding tiller for role: cluster-admin and ServiceAccount: kube-system/tiller
Created ClusterRoleBinding tiller
Initialising helm using ServiceAccount tiller in namespace kube-system
Waiting for tiller-deploy to be ready in tiller namespace kube-system
helm installed and configured
? No existing ingress controller found in the kube-system namespace, shall we install one? Yes
Installing using helm binary: helm
Waiting for external loadbalancer to be created and update the nginx-ingress-controller service in kube-system namespace
Note: this loadbalancer will fail to be provisioned if you have insufficient quotas, this can happen easily on a GKE free account. To view quotas run: gcloud compute project-info describe
External loadbalancer created
Waiting to find the external host name of the ingress controller Service in namespace kube-system with name jxing-nginx-ingress-controller
You can now configure a wildcard DNS pointing to the new Load Balancer address 35.227.82.26

If you do not have a custom domain setup yet, Ingress rules will be set for magic DNS nip.io.
Once you have a custom domain ready, you can update with the command jx upgrade ingress --cluster
If you don't have a wildcard DNS setup then setup a DNS (A) record and point it at: 35.227.82.26 then use the DNS domain in the next input...
? Domain 35.227.82.26.nip.io
nginx ingress controller installed and configured
Lets set up a Git user name and API token to be able to perform CI/CD

? Do you wish to use vfarcic as the local Git user for GitHub server: Yes
Select the CI/CD pipelines Git server and user
? Do you wish to use GitHub as the pipelines Git server: Yes
? Do you wish to use vfarcic as the pipelines Git user for GitHub server: Yes
Setting the pipelines Git server https://github.com and user name vfarcic.
Saving the Git authentication configurationCurrent configuration dir: /Users/vfarcic/.jx
options.Flags.CloudEnvRepository: https://github.com/jenkins-x/cloud-environments
options.Flags.LocalCloudEnvironment: false
Cloning the Jenkins X cloud environments repo to /Users/vfarcic/.jx/cloud-environments
? A local Jenkins X cloud environments repository already exists, recreate with latest? Yes
Current configuration dir: /Users/vfarcic/.jx
options.Flags.CloudEnvRepository: https://github.com/jenkins-x/cloud-environments
options.Flags.LocalCloudEnvironment: false
Cloning the Jenkins X cloud environments repo to /Users/vfarcic/.jx/cloud-environments
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Compressing objects: 100% (8/8), done.
Total 1298 (delta 1), reused 4 (delta 1), pack-reused 1289
Generated helm values /Users/vfarcic/.jx/extraValues.yaml
Creating Secret jx-install-config in namespace jx
Installing Jenkins X platform helm chart from: /Users/vfarcic/.jx/cloud-environments/env-gke
? Select Jenkins installation type: Static Master Jenkins
Waiting for tiller pod to be ready, service account name is tiller, namespace is jx, tiller namespace is kube-system
Waiting for cluster role binding to be defined, named tiller-role-binding in namespace jx
 Trying to create ClusterRoleBinding tiller-role-binding for role: cluster-admin and ServiceAccount: jx/tiller
Created ClusterRoleBinding tiller-role-binding
tiller cluster role defined: cluster-admin in namespace jx
tiller pod running
? Pick workload build pack:  Kubernetes Workloads: Automated CI+CD with GitOps Promotion
Setting the team build pack to kubernetes-workloads repo: https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes.git ref: master
Installing jx into namespace jx
Installing jenkins-x-platform version: 0.0.3271
Adding values file /Users/vfarcic/.jx/cloud-environments/env-gke/myvalues.yaml
Adding values file /Users/vfarcic/.jx/adminSecrets.yaml
Adding values file /Users/vfarcic/.jx/extraValues.yaml
Adding values file /Users/vfarcic/.jx/cloud-environments/env-gke/secrets.yaml
Upgrading Chart 'upgrade --namespace jx --install --timeout 6000 --version 0.0.3271 --values /Users/vfarcic/.jx/cloud-environments/env-gke/myvalues.yaml --values /Users/vfarcic/.jx/adminSecrets.yaml --values /Users/vfarcic/.jx/extraValues.yaml --values /Users/vfarcic/.jx/cloud-environments/env-gke/secrets.yaml jenkins-x jenkins-x/jenkins-x-platform'
waiting for install to be ready, if this is the first time then it will take a while to download images
Jenkins X deployments ready in namespace jx


        ********************************************************

             NOTE: Your admin password is: admin

        ********************************************************


Configure Jenkins API Token
Generating the API token...
Logged in admin to Jenkins server at http://jenkins.jx.35.227.82.26.nip.io via legacy security realm
Enable CSRF protection at: http://jenkins.jx.35.227.82.26.nip.io/configureSecurity/
Created user admin API Token for Jenkins server jenkins.jx.35.227.82.26.nip.io at http://jenkins.jx.35.227.82.26.nip.io
Updating Jenkins with new external URL details http://jenkins.jx.35.227.82.26.nip.io
Creating default staging and production environments
? Select the organization where you want to create the environment repository: vfarcic
Using Git provider GitHub at https://github.com


About to create repository environment-jx-rocks-staging on server https://github.com with user vfarcic


Creating repository vfarcic/environment-jx-rocks-staging
Creating Git repository vfarcic/environment-jx-rocks-staging
Pushed Git repository to https://github.com/vfarcic/environment-jx-rocks-staging

Creating staging Environment in namespace jx
Created environment staging
Namespace jx-staging created
 Created Jenkins Project: http://jenkins.jx.35.227.82.26.nip.io/job/vfarcic/job/environment-jx-rocks-staging/

Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!

Creating GitHub webhook for vfarcic/environment-jx-rocks-staging for url http://jenkins.jx.35.227.82.26.nip.io/github-webhook/
Using Git provider GitHub at https://github.com


About to create repository environment-jx-rocks-production on server https://github.com with user vfarcic


Creating repository vfarcic/environment-jx-rocks-production
Creating Git repository vfarcic/environment-jx-rocks-production
Pushed Git repository to https://github.com/vfarcic/environment-jx-rocks-production

Creating production Environment in namespace jx
Created environment production
Namespace jx-production created
 Created Jenkins Project: http://jenkins.jx.35.227.82.26.nip.io/job/vfarcic/job/environment-jx-rocks-production/

Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!

Creating GitHub webhook for vfarcic/environment-jx-rocks-production for url http://jenkins.jx.35.227.82.26.nip.io/github-webhook/

Jenkins X installation completed successfully


        ********************************************************

             NOTE: Your admin password is: admin

        ********************************************************



Your Kubernetes context is now set to the namespace: jx
To switch back to your original namespace use: jx namespace default
For help on switching contexts see: https://jenkins-x.io/developing/kube-context/

To import existing projects into Jenkins:       jx import
To create a new Spring Boot microservice:       jx create spring -d web -d actuator
To create a new microservice from a quickstart: jx create quickstart
```

## Creating An EKS Cluster With jx

```bash
export AWS_ACCESS_KEY_ID=[...] # Replace [...] with the AWS Access Key ID

export AWS_SECRET_ACCESS_KEY=[...] # Replace [...] with the AWS Secret Access Key

jx create cluster eks -n jx-rocks \
    -r us-west-2 \
    --node-type t2.medium \
    --nodes 3 \
    --nodes-min 3 \
    --nodes-max 6 \
    --default-admin-password=admin \
    --default-environment-prefix jx-rocks
```

NOTE: Answered to all questions with default values except to `Would you like to register a wildcard DNS ALIAS to point at this ELB address?`

```
Creating EKS cluster - this can take a while so please be patient...
You can watch progress in the CloudFormation console: https://console.aws.amazon.com/cloudformation/
Initialising cluster ...

Namespace jx created
 Using helmBinary helm with feature flag: none
Context "iam-root-account@jx-rocks.us-west-2.eksctl.io" modified.
Storing the kubernetes provider eks in the TeamSettings
Git configured for user: Viktor Farcic and email vfarcic@farcic.com
Trying to create ClusterRoleBinding viktor-farcic-com-cluster-admin-binding for role: cluster-admin for user viktor@farcic.com
 clusterrolebindings.rbac.authorization.k8s.io "viktor-farcic-com-cluster-admin-binding" not found
Created ClusterRoleBinding viktor-farcic-com-cluster-admin-binding
Using helm2
Configuring tiller
Created ServiceAccount tiller in namespace kube-system
Trying to create ClusterRoleBinding tiller for role: cluster-admin and ServiceAccount: kube-system/tiller
Created ClusterRoleBinding tiller
Initialising helm using ServiceAccount tiller in namespace kube-system
Waiting for tiller-deploy to be ready in tiller namespace kube-system
helm installed and configured
? No existing ingress controller found in the kube-system namespace, shall we install one? Yes
Using helm values file: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/ing-values-451110258
Installing using helm binary: helm
Waiting for external loadbalancer to be created and update the nginx-ingress-controller service in kube-system namespace
External loadbalancer created
Waiting to find the external host name of the ingress controller Service in namespace kube-system with name jxing-nginx-ingress-controller

On AWS we recommend using a custom DNS name to access services in your Kubernetes cluster to ensure you can use all of your Availability Zones
If you do not have a custom DNS name you can use yet, then you can register a new one here: https://console.aws.amazon.com/route53/home?#DomainRegistration:

? Would you like to register a wildcard DNS ALIAS to point at this ELB address?  Yes

? Your custom DNS name:  [? for help]
? Would you like to register a wildcard DNS ALIAS to point at this ELB address?  [? for help] (Y/n)

? Your custom DNS name:  [? for help]
? Would you like to register a wildcard DNS ALIAS to point at this ELB address?  No

The Ingress address ac1a968d71d0811e9808c02d6944b704-d3f4eb93dfe1a3a7.elb.us-west-2.amazonaws.com is not an IP address. We recommend we try resolve it to a public IP address and use that for the domain to access services externally.
? Would you like wait and resolve this address to an IP address and use it for the domain? Yes

Waiting for ac1a968d71d0811e9808c02d6944b704-d3f4eb93dfe1a3a7.elb.us-west-2.amazonaws.com to be resolvable to an IP address...
ac1a968d71d0811e9808c02d6944b704-d3f4eb93dfe1a3a7.elb.us-west-2.amazonaws.com resolved to IP 34.211.194.172
You can now configure a wildcard DNS pointing to the new Load Balancer address 34.211.194.172

If you do not have a custom domain setup yet, Ingress rules will be set for magic DNS nip.io.
Once you have a custom domain ready, you can update with the command jx upgrade ingress --cluster
If you don't have a wildcard DNS setup then setup a DNS (A) record and point it at: 34.211.194.172 then use the DNS domain in the next input...
? Domain 34.211.194.172.nip.io
nginx ingress controller installed and configured
Lets set up a Git user name and API token to be able to perform CI/CD

? Do you wish to use vfarcic as the local Git user for GitHub server: Yes
Select the CI/CD pipelines Git server and user
? Do you wish to use GitHub as the pipelines Git server: Yes
? Do you wish to use vfarcic as the pipelines Git user for GitHub server: Yes
Setting the pipelines Git server https://github.com and user name vfarcic.
Saving the Git authentication configurationCurrent configuration dir: /Users/vfarcic/.jx
options.Flags.CloudEnvRepository: https://github.com/jenkins-x/cloud-environments
options.Flags.LocalCloudEnvironment: false
Cloning the Jenkins X cloud environments repo to /Users/vfarcic/.jx/cloud-environments
? A local Jenkins X cloud environments repository already exists, recreate with latest? Yes
Current configuration dir: /Users/vfarcic/.jx
options.Flags.CloudEnvRepository: https://github.com/jenkins-x/cloud-environments
options.Flags.LocalCloudEnvironment: false
Cloning the Jenkins X cloud environments repo to /Users/vfarcic/.jx/cloud-environments
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Compressing objects: 100% (8/8), done.
Total 1298 (delta 1), reused 4 (delta 1), pack-reused 1289
Generated helm values /Users/vfarcic/.jx/extraValues.yaml
Creating Secret jx-install-config in namespace jx
Installing Jenkins X platform helm chart from: /Users/vfarcic/.jx/cloud-environments/env-eks
? Select Jenkins installation type: Static Master Jenkins
Waiting for tiller pod to be ready, service account name is tiller, namespace is jx, tiller namespace is kube-system
Waiting for cluster role binding to be defined, named tiller-role-binding in namespace jx
 Trying to create ClusterRoleBinding tiller-role-binding for role: cluster-admin and ServiceAccount: jx/tiller
Created ClusterRoleBinding tiller-role-binding
tiller cluster role defined: cluster-admin in namespace jx
tiller pod running
? Pick workload build pack:  Kubernetes Workloads: Automated CI+CD with GitOps Promotion
Setting the team build pack to kubernetes-workloads repo: https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes.git ref: master
Installing jx into namespace jx
Installing jenkins-x-platform version: 0.0.3271
Adding values file /Users/vfarcic/.jx/cloud-environments/env-eks/myvalues.yaml
Adding values file /Users/vfarcic/.jx/adminSecrets.yaml
Adding values file /Users/vfarcic/.jx/extraValues.yaml
Adding values file /Users/vfarcic/.jx/cloud-environments/env-eks/secrets.yaml
Upgrading Chart 'upgrade --namespace jx --install --timeout 6000 --version 0.0.3271 --values /Users/vfarcic/.jx/cloud-environments/env-eks/myvalues.yaml --values /Users/vfarcic/.jx/adminSecrets.yaml --values /Users/vfarcic/.jx/extraValues.yaml --values /Users/vfarcic/.jx/cloud-environments/env-eks/secrets.yaml jenkins-x jenkins-x/jenkins-x-platform'
waiting for install to be ready, if this is the first time then it will take a while to download images
Jenkins X deployments ready in namespace jx


        ********************************************************

             NOTE: Your admin password is: admin

        ********************************************************


Configure Jenkins API Token
Generating the API token...
Logged in admin to Jenkins server at http://jenkins.jx.34.211.194.172.nip.io via legacy security realm
Enable CSRF protection at: http://jenkins.jx.34.211.194.172.nip.io/configureSecurity/
Created user admin API Token for Jenkins server jenkins.jx.34.211.194.172.nip.io at http://jenkins.jx.34.211.194.172.nip.io
Updating Jenkins with new external URL details http://jenkins.jx.34.211.194.172.nip.io
Creating default staging and production environments
? Select the organization where you want to create the environment repository: vfarcic
Using Git provider GitHub at https://github.com


About to create repository environment-jx-rocks-staging on server https://github.com with user vfarcic


Creating repository vfarcic/environment-jx-rocks-staging
Creating Git repository vfarcic/environment-jx-rocks-staging
Pushed Git repository to https://github.com/vfarcic/environment-jx-rocks-staging

Creating staging Environment in namespace jx
Created environment staging
Namespace jx-staging created
 Created Jenkins Project: http://jenkins.jx.34.211.194.172.nip.io/job/vfarcic/job/environment-jx-rocks-staging/

Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!

Creating GitHub webhook for vfarcic/environment-jx-rocks-staging for url http://jenkins.jx.34.211.194.172.nip.io/github-webhook/
Using Git provider GitHub at https://github.com


About to create repository environment-jx-rocks-production on server https://github.com with user vfarcic


Creating repository vfarcic/environment-jx-rocks-production
Creating Git repository vfarcic/environment-jx-rocks-production
Pushed Git repository to https://github.com/vfarcic/environment-jx-rocks-production

Creating production Environment in namespace jx
Created environment production
Namespace jx-production created
 Created Jenkins Project: http://jenkins.jx.34.211.194.172.nip.io/job/vfarcic/job/environment-jx-rocks-production/

Note that your first pipeline may take a few minutes to start while the necessary images get downloaded!

Creating GitHub webhook for vfarcic/environment-jx-rocks-production for url http://jenkins.jx.34.211.194.172.nip.io/github-webhook/

Jenkins X installation completed successfully


        ********************************************************

             NOTE: Your admin password is: admin

        ********************************************************



Your Kubernetes context is now set to the namespace: jx
To switch back to your original namespace use: jx namespace default
For help on switching contexts see: https://jenkins-x.io/developing/kube-context/

To import existing projects into Jenkins:       jx import
To create a new Spring Boot microservice:       jx create spring -d web -d actuator
To create a new microservice from a quickstart: jx create quickstart
```

```bash
ASG_NAME=$(aws autoscaling \
    describe-auto-scaling-groups \
    | jq -r ".AutoScalingGroups[] \
    | select(.AutoScalingGroupName \
    | startswith(\"eksctl-jx-rocks-nodegroup\")) \
    .AutoScalingGroupName")

echo $ASG_NAME

aws autoscaling \
    create-or-update-tags \
    --tags \
    ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=true \
    ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=kubernetes.io/cluster/jx-rocks,Value=true,PropagateAtLaunch=true

IAM_ROLE=$(aws iam list-roles \
    | jq -r ".Roles[] \
    | select(.RoleName \
    | startswith(\"eksctl-jx-rocks-nodegroup-0-NodeInstanceRole\")) \
    .RoleName")

echo $IAM_ROLE

aws iam put-role-policy \
    --role-name $IAM_ROLE \
    --policy-name jx-rocks-AutoScaling \
    --policy-document https://raw.githubusercontent.com/vfarcic/k8s-specs/master/scaling/eks-autoscaling-policy.json

helm install stable/cluster-autoscaler \
    --name aws-cluster-autoscaler \
    --namespace kube-system \
    --set autoDiscovery.clusterName=jx-rocks \
    --set awsRegion=$AWS_DEFAULT_REGION \
    --set sslCertPath=/etc/kubernetes/pki/ca.crt \
    --set rbac.create=true --wait
```

## Creating An AKS Cluster With jx

```bash
# TODO:
```

## Installing Jenkins X In An Existing Kubernetes Cluster

```bash
# TODO:
```

## What Did We Get?

```bash
jx console
```

* Use `admin` as the username and password

![Figure 2-TODO: TODO:](images/ch02/jx-console-environments.png)

```bash
kubectl -n jx get pods
```

Note:
```
NAME                                 READY STATUS  RESTARTS AGE
jenkins-...                          1/1   Running 0        7m
jenkins-x-chartmuseum-...            1/1   Running 0        7m
jenkins-x-controllercommitstatus-... 1/1   Running 0        7m
jenkins-x-controllerrole-...         1/1   Running 0        7m
jenkins-x-controllerteam-...         1/1   Running 0        7m
jenkins-x-controllerworkflow-...     1/1   Running 0        7m
jenkins-x-docker-registry-...        1/1   Running 0        7m
jenkins-x-heapster-...               2/2   Running 0        7m
jenkins-x-mongodb-...                1/1   Running 1        7m
jenkins-x-monocular-api-...          1/1   Running 3        7m
jenkins-x-monocular-prerender-...    1/1   Running 0        7m
jenkins-x-monocular-ui-...           1/1   Running 0        7m
jenkins-x-nexus-...                  1/1   Running 0        7m
maven-...                            2/2   Running 0        1m
```

TODO: Install in an existing cluster

## What Now?

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

# If EKS
# Only if there are no other ELBs in that region. Otherwise, remove the LB manually.
LB_ARN=$(aws elbv2 describe-load-balancers | jq -r \
    ".LoadBalancers[0].LoadBalancerArn")

# If EKS
echo $LB_ARN

# If EKS
aws elbv2 delete-load-balancer \
    --load-balancer-arn $LB_ARN

# If EKS
IAM_ROLE=$(aws iam list-roles \
    | jq -r ".Roles[] \
    | select(.RoleName \
    | startswith(\"eksctl-jx-rocks-nodegroup-0-NodeInstanceRole\")) \
    .RoleName")

# If EKS
echo $IAM_ROLE

# If EKS
aws iam delete-role-policy \
    --role-name $IAM_ROLE \
    --policy-name jx-rocks-AutoScaling

# If EKS
eksctl delete cluster -n jx-rocks

# TODO: Install `hub`

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```