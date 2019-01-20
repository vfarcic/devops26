## Hands-On Time

---

### Creating A
# Jenkins-X
## Cluster


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

## Creating A EKS Cluster With jx

## Creating A AKS Cluster With jx

## Installing jx Into An Existing Kubernetes Cluster

## What Did We Get?

```bash
jx console
```

* Use `admin` as the username and password

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
# TODO: Destroy the cluster, uninstall jx, or leave it as is

# TODO: Remove the repos and the local files
```