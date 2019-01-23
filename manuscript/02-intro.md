## TODO

- [X] Code
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

# What Is Jenkins X?

To understand Jenkins X, we need to understand Kubernetes. However, I will assume that you already know what Kubernetes is and how to use it. If you do not, Jenkins X might be overwhelming and I suggest you learn at least basic Kubernetes features and get a bit of hands-on practice. You might want to fetch **The DevOps 2.3 Toolkit: Kubernetes** book before proceeding with this one.

I'll skip telling you that Kubernetes is a container orchesstrator, how it manages our deployments, and how it took over the world by the storm. You hopefully already know all that. Instead, I'll define Kubernetes as a platform to rule them all. Today, most software vendors are building their next generation of software to be Kubernetes-native or, at least, to work better inside it. A whole ecosystem is emerging and treating Kubernetes as a blank canvas. Kubernetes offers limitless possibilities. However, with that comes increased complexity. It is harder than ever to choose which tools to use. How are we going to develop our applications? How are we going to manage different environments? How are we going to package our applications? Which process are we going to apply for application lifecycle? And so on and so forth. Assembling a Kuberntes cluster with all the tools and processes takes time, and learning how to use what we assembled feels like a never-ending story. Jenkins X aims to remove those, and quite other obstacles.

Jenkins X is opinionated. It defines many aspects of software development lifecycle. It makes decisions for us. It tells us what to do and how. At the same time, it is flexible and allows power users to tweak it to fit their own needs.

The true power behind Jenkins X is the process. We (people working in software industry) tend to reinvent the wheel all the time. We spend countless hours trying to figure out how to develop our applications faster and how to have local environment that is as close to production as possible. We dedicate time searching for tools that will allow us to package our applications more efficiently. We design the steps that form continuous delivery pipeline. We write scripts that automate repetitive tasks. And yet, we cannot escape the feeling that we are likely reinventing things that were already done by others. Jenkins X is designed to help us with those decisions and it helps us to pick the right tools for a job.

If we are about to start working on a new project, Jenkins X will create the structure and the required files. If we need a Kubernetes cluster with all the tools selected, installed, and configured, Jenkins X will do that. If we need to create Git repositories, configure webhooks, and create continuous delivery pipelines, all we need to do is execute a single `jx` command. The list of what Jenkins X does, is huge, and grows every day.

I won't go into details of everything Jenkins X does. That will come later. For now, I hope I got your attention. The important thing to note is that you need to clear your mind from any Jenkins experience you might already have. Sure, a version of Jenkins is involved. However, Jenkins X is very different from the "traditional Jenkins". The differences are so huge that the only way for you to embrace it is to forget what you know about Jenkins, and start from scratch.

I don't what to overwhelm you from the start. There's a lot of ground to cover and we'll take one stap at a time. For now, we need to install a few things.

## Installing Prerequisites

Before we jump into Jenkins X, we'll need a few tools that will be used throughout this book. I'm sure that you already have most (if not all) of them, but I'll list them anyway.

I'm sure that you already have [git](https://git-scm.com/). If you don't, you and I are not living in the same century. I would not even mention it, if not for GitBash. If you are using Windows, please make sure that you have GitBash (part of the Git setup) and to run all the commands from it. Other shells might work as well. Still, I tested all the commands on Windows with GitBash, so that's your safest bet. If, on the other hand, you are a MacOS or Linux user, just fire up your favourite terminal.

Jenkins X CLI (we'll install it soon) will do its best to install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [Helm](https://docs.helm.sh/using_helm/#installing-helm). However, the number of permitations of what we have on our laptops is close to infinite and you're better of installing those two yourself.

We'll need a Kubernetes cluster and I'll assume that you already have CLIs provided by your hosting vendor. You should be able to use (almost) any Kubernetes flavor to run Jenkins so the choice is up to you. Just as with kubectl and Helm, Jenkins X will try to install appropriate CLI, but you might be better of installing it yourself. If you're planning to use AWS EKS cluster, you probably already have [AWS CLI](https://aws.amazon.com/cli/) and [eksctl](https://github.com/weaveworks/eksctl). If your preference is with Google GKE, I'm sure that you already have [gcloud](https://cloud.google.com/sdk/docs/quickstarts). Similarly, if you prefer Azure, you probably have [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). Finally, if you prefer something else, I'm sure you know which CLI fits your situation.

There is one restriction though. You can use (almost) any Kubernetes cluster that is publicly accessible. The main reason for that lies in GitHub triggers. Jenkins X relies heavily on GitOps principles. Most of the events will be triggered by GitHub webhooks. If your cluster cannot be accessed from GitHub, you won't be able to trigger those events and will have difficulty following the examples. Now, that might pose two major issues. You might prefer to practice locally using minikube or Docker Desktop. Neither of the two are accessible from outside your laptop. Or, you might have a corporate cluster that is inacessible to the outside world. In those cases, I suggest you use a service from AWS, GCP, Azure, or from anywhere else. Each chapter will start with the instructions to create a new cluster, and will end with instructions how to destroy it (if you choose to do so). That way, the costs will be kept to a bare minimum. If you sign up to one of the Cloud providers, they will give you much more credit than what you will spend on the exercises from this book, even if you are the slowest reader in the world. If you're not sure which one to pick, I suggect [Google Cloud Platform (GCP)](https://console.cloud.google.com). At the time of this writing, Google Kubernetes Engine (GKE) is the best cluster on the market.

Moving on to the final set of requirements...

A few examples will use [jq](https://stedolan.github.io/jq/download/) to filter and format JSON outptu. Please install it.

Finally, we'll be perform some GitHub operations using [hub](https://hub.github.com/). I will not even ask you whether you have a GitHub account.

That's it. I'm not forcing you to use anything but the tools you should have anyway.

For your convenience, the list of all the tools we'll use is as follows.

* [git](https://git-scm.com/)
* GitBash (if using Windows)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Helm](https://docs.helm.sh/using_helm/#installing-helm)
* [AWS CLI](https://aws.amazon.com/cli/) and [eksctl](https://github.com/weaveworks/eksctl) (if using AWS EKS)
* [gcloud](https://cloud.google.com/sdk/docs/quickstarts) (if using Google GKE)
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (if using Azure AKS)
* [jq](https://stedolan.github.io/jq/download/)
* [hub](https://hub.github.com/)

Now, let's install Jenkins X CLI.

## Installing Jenkins X CLI

If you are a **MacOS** users, please install `jx` using `brew`.

```bash
brew tap jenkins-x/jx

brew install jx
```

If you are a **Linux** user, the instructions are as follows.

```bash
mkdir -p ~/.jx/bin

curl -L https://github.com/jenkins-x/jx/releases/download/v1.3.634/jx-linux-amd64.tar.gz | tar xzv -C ~/.jx/bin

export PATH=$PATH:~/.jx/bin

echo 'export PATH=$PATH:~/.jx/bin' >> ~/.bashrc
```

Finally, Windows users can install the CLI using [Chocolatey](https://chocolatey.org/install).

```bash
choco install jenkins-x
```

Now we are ready to install Jenkins X.

## To Create A Cluster Or Not To Create A Cluster

I already mentioned that Jenkins X is much more than a tool for continuous integration or continuous delivery. One of the many features it has is to create a fully operational Kubernetes cluster and install the tools we might need in order to operate it efficiently. On the other hand, `jx` allows us to install Jenkins X inside an existing Kubernetes cluster. So, we need to make a choice. Do we want to let `jx` create a cluster for us, or are we going to install Jenkins X inside an existing cluster? The choice will largelly depend on your current situation, as well as the purpose of the cluster.

If you plan to create a cluster only for the purpose of the exercises in this book, I recommend using `jx` to create a cluster, assuming that your favourite hosting vendor is one of the supported ones. Another reason for letting `jx` handle creation of the cluster is if you're planning to have a dedicated cluster for continuous delivery. In both cases, we can use `jx create cluster` command.

On the other hand, you might already have a cluster where other applications are running and you'd like to add Jenkins X to it. In that case, all we have to do is install Jenkins X by executing `jx install`.

Let's go through help of both `jx create cluster` and `jx install` command and see what we've got.

```bash
jx create cluster help
```

Judging from the output, we can see that Jenkins X works in quite a few different providers. We can use it inside Azure AKS, AWS with kops, AWS EKS, Google GKE, Oracle OKE, IBM ICP, IBM IKS, minikube, minishift, OpenShift, and Kubernetes. Now, the Kubernetes provider is curious. Aren't all other providers just different flavors of Kubernetes? They are. Kubernetes provider, besides being badly named, allows us to run Jenkins X in (almost) any Kubernetes flavor. The difference between the Kubernetes provider and all the others lies in additions that are useful only for those providers. Nevertheless, you can run Jenkins X in (almost) any Kubernetes flavor. If your provider is on the list, use it. Otherwise, pick `kubernetes` provider instead.

As a side note, do not trust the list I presented as being final. By the time you read this, Jenkins X might have added more proviers to the list.

It is worhwhile mentioning that not all the `jx` cannot create a cluster in all those providers, but that it can run there. A few of those cannot be created dynamically. Namelly, OKE, ICP, and OpenShift. If you prefer one of those, you'll have to wait until we reach the part with the instructions to install Jenkins X in an existing cluster.

You'll also notice that `jx` will install some of the local dependencies if you do not have them already on your laptop. Which ones will be installed depend on your choice of the provider. For example, `gcloud` is installed only if you choose GKE as your provider. On the other hand, `kubectl` will be installed no matter the choice, as long as you do not already have it in your laptop.

So, if you do choose to use one of the cloud providers, `jx create cluster` is a very good option, unless you already have a cluster where you'd like to install Jenkins X. If that's the case, or if you cannot use one of the cloud providers, you should be exploring the `jx install` command instead. The `install` command is a subset of `create cluster`. If we take a look at the supported providers in the `install` command, we'll see that they are the same as those we saw in `create cluster`.

```bash
jx install --help | grep "provider="
```

The output is as follows.

```
--provider='': Cloud service providing the Kubernetes cluster.  Supported providers: aks, aws, eks, gke, icp, iks, jx-infra, kubernetes, minikube, minishift, oke, openshift, pks
```

I'll show you how to use Jenkins X to create a GKE, EKS, and AKS cluster. If you do have access to one of those providers, I suggest you do follow the instructions. Even if you're already planning to install Jenkins X inside an existing cluster, it would be beneficial to see the benefits we get with the `jx create cluster` command. Further on, I'll show you how to install Jenkins X inside any existing cluster. It's up to you to choose which path you'd like to follow. Ideally, you might want to try them all, and get more insight into the differences between cloud providers and Kubernetes flavors.

No matter the choice, I will make sure that all of those are supported through the rest of the chapters.

Before we proceed, please note that we'll specify most of the options through arguments. We could have skipped them and let `jx` ask us more questions (e.g., how many nodes do you want?). Nevertheless, I believe that using arguments is a better way since it results in a documented and reproducible way to create something. Ideally, `jx` should not ask us any questions. We can indeed accomplish that by running in the batch mode. I'll reserve that for the next chapter.

For your convenience, bookmarks to the relevant sub-chapters are as follows.

* [Creating A Google Kubernetes Engine (GKE) Cluster With jx](#jx-create-cluster-gke)
* [Creating An Amazon Elastic Container Service for Kubernetes (EKS) Cluster With jx](#jx-create-cluster-eks)
* [Creating An Azure Kubernetes Service (AKS) Cluster With jx](#jx-create-cluster-aks)
* [Installing Jenkins X In An Existing Kubernetes Cluster](#jx-install)

If, you prefer to create the cluster in one of the other providers, I reading the instructions for one of the "big three" (AWS, Azure, or Google) since the requirements and the steps are very similar.
 
## Creating A Google Kubernetes Engine (GKE) Cluster With jx {#jx-create-cluster-gke}

Everything we do inside a Google Cloud Platform (GCP) is inside a project. That includes GKE cluster. If we are to let `jx` create a cluster for us, we need to know the name of the GCP project where we'll put it. If you do not have a project you'd like to use, please visit the [Manage Resources](https://console.cloud.google.com/cloud-resource-manager) page to create a new one. Make sure to enable billing for that project.

No matter whether you created a new project specifically for Jenkins X, or you chose to reuse one that you already have, we'll need to know its name. To simplify the process, we'll store it in an environment variable.

```bash
PROJECT=[...]
```

Please make sure to replace `[...]` with the name of the GCP project.

Now we're ready to create a GKE cluster with all the tool installed and configured. We'll name it `jx-rocks` (`-n`) and let it reside inside the project we just defined (`-p`). It'll run inside `us-east1-b` zone (`-z`) and on `n1-standard-2` (2 CPUs and 7.5 GB RAM) machines (`-m`). Feel free to reduce that to `n1-standard-1` if the cost is of concern. Since GKE auto-scales nodes automatically, the cluster will scale up if we need more. While at the subject of scaling, we'll have a minimum of three nodes (`--min-num-nodes`) and we'll cap it to five (`--max-num-nodes`).

We'll also set the default Jenkins X password to `admin` ( `--default-admin-password`). Otherwise, the process would create a random one. Finally, we'll set `jx-rocks` as the default environment prefix (`--default-environment-prefix`). A part of the process will create a few repositories (one for staging and the other for production) and that prefix will be used to form their names. We won't go into much detail about those environments and repositories just yet. That's reserved for one of the follow-up chapters.

Feel free to change any of the values in the command that follows to better suit your needs. Or, keep them as they are. After all, this is only a practice and you'll be able to destroy the cluster and recreate it later on with different values.

```bash
jx create cluster gke \
    -n jx-rocks \
    -p $PROJECT \
    -z us-east1-b \
    -m n1-standard-2 \
    --min-num-nodes 3 \
    --max-num-nodes 5 \
    --default-admin-password admin \
    --default-environment-prefix jx-rocks
```

Let's explore what we're getting with that command. You should be able to correlate my explaination with the console output.

First, GCP authentication screen should open asking you to confirm that you are indeed who you claim you are. If that does not happen, please open the link provided in the output manually.

Next, `jx` will ensure that all the GCP services we need (`container` and `compute`) are enabled.

Once we're authenticated and the services are enabled, `jx` will create a cluster. It should take only a few minutes.

Once the GKE cluster is up and running, the process will create a `jx` Namespace. It will also modify your local `kubectl` context and create a ClusterRoleBinding that will give you the administrative permissions.

At this point, `jx` will try to deduce your Git name and email. If it fails to do so, it'll ask you for that info.

Once the cluster is up-and-running and configured, `jx` will install `tiller` (Helm server), since that is the default mechanism for installing and upgrading applications in Kubernetes.

The next in line is Ingress. The process will try to find it inside the `kube-system` Namespace. If it's not there (as it isn't), it'll ask you whether you'd like to install it. Type `y` or simply press the enter key since that is the default answer. You'll notice that we'll use the default answers for all the subsequent questions, since they are sensible and provide a set of best practices.

Once we chose to install Ingress, the process will proceed and install it through a Helm chart. As a result, Ingress will create a load balancer that will provide an entry point into the cluster. This is the point that might fail our setup. GCP default quotas are very low and you might not have the right to create additional load balancers. If that's the case, please open the [Quotas](https://console.cloud.google.com/iam-admin/quotas) page, select those that are at the maximum, and click the *Edit Quotas* button. Increasing a quota is a manual process. They do it relativelly fast so you should have to wait for long.

Once the load balancer is created, `jx` will use it's host name to deduce its IP.

Since we did not specify a custom domain for our cluster, the process will combine that IP with the [nip.io](http://nip.io/) service to create a fully qualified domain for the cluster, and we'll be asked whether we want to proceed using it. Type press the enter key to continue.

Next, we'll be asked a few questions related to Git and GitHub. You should be able to answer those. In most cases, all you have to do is confirm the suggested answer by pressing the enter key. As a result, `jx` will store the credentials internally so that it can continue interacting with GitHub on our behalf. It will also install the software necessary for correct functioning of those environments (Namespaces) inside our cluster.

Further on, The installation of Jenkins X itself, and a few other applications (e.g., ChartMuseum for storing Helm charts) will start. The exact list of applications that will be installed depends on Kubernetes flavor, the type of the setup, and the hosting vendor. But, before it proceeds, it'll need to ask us a few other questions. Which type of installation do we want? Static or serverless? Please answer with `Static Master Jenkins` (the default value). We'll explore the serverless option later. The next question is whether we want `Kubernetes Workloads: Automated CI+CD with GitOps Promotion` or `Library Workloads: CI+Release but no CD`. Choose the default value (Kubernetes Workloads).

A few moments later, Jenkins & friends will be up and running and you should see the `admin password` in the output (it should be `admin`). You'll also notice that Jenkins is now accessible through `http://jenkins.jx.[THE_IP_OF_YOUR_LB].nip.io`.

We're almost done. Only one question is pending. `Select the organization where you want to create the environment repository?` Choose one from the list.

We're almost done. The process will create two GitHub repositories; `environment-jx-rocks-staging` and `environment-jx-rocks-production`. Those repositories will hold the definitions of those environments. When, for example, you decide to promote a release to production, your pipelines will not install anything directly. Instead, they will push a change to `environment-jx-rocks-production` which, in turn, will trigger another job that will comply with the updated definition of the environment. That's GitOps. Nothing is done without recording a change in Git. Ofcourse, for that process to work, we need new jobs in Jenkins, so the process created two, that correspond to those repositories. We'll discuss the environments in greater detail later.

Finally, the `kubectl` context was changed to point to the `jx` Namespace, instead of the `default`.

We'll get back to the new cluster and the tools that were installed and configured in the [What Did We Get?](#intro-what-did-we-get) section. Feel free to jump there if you have no interest in other Cloud providers or how to install Jenkins X inside an existing cluster. AKS is coming next.

## Creating An Amazon Elastic Container Service for Kubernetes (EKS) Cluster With jx {#jx-create-cluster-eks}

To create anything in AWS, we need environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` (there are other ways but I'll ignore them).

```bash
export AWS_ACCESS_KEY_ID=[...]

export AWS_SECRET_ACCESS_KEY=[...]
```

Please replace the first `[...]` with the AWS Access Key ID, and the second with the AWS Secret Access Key. I am assuming that you are already familiar with AWS and you know how to create those keys, or that you already have them. If that's not the case, please follow the instructions from the [Managing Access Keys for Your AWS Account Root User
](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) page.

Now we're ready to create an EKS cluster. We'll name it `jx-rocks` (`jx-rocks`). It will run inside the `us-west-2` region (`-r`) and on `t2.medium` (2 CPUs and 4 GB RAM) machines (`--node-type`). Unlike with GKE, we won't get cluster autoscaling out of the box, but we'll fix that later. For now, you can assume that there will eventually be autoscaling, so there's no need to worry whether the current capacity is enough. If anything, it is likelt more than we need from the start. Still, even though autoscaling will come later, we'll set the current (`--nodes`) and the minimum number of nodes (`--nodes-min`) to three, and the maximum to six ( `--nodes-max`). That will be converted into AWS Auto-Scaling Groups and, in case of a misstep, it'll protect us from ending up with more nodes than we can afford.

We'll also set the default Jenkins X password to `admin` (`--default-admin-password`). Otherwise, the process would create a random one. Finally, we'll set `jx-rocks` as the default environment prefix (`--default-environment-prefix`). A part of the process will create a few repositories (one for staging and the other for production) and that prefix will be used to form their names. We won't go into much detail about those environments and repositories just yet. That's reserved for one of the follow-up chapters.

Feel free to change any of the values in the command that follows to better suit your needs. Or, keep them as they are. After all, this is only a practice and you'll be able to destroy the cluster and recreate it later on with different values.

```bash
jx create cluster eks -n jx-rocks \
    -r us-west-2 \
    --node-type t2.medium \
    --nodes 3 \
    --nodes-min 3 \
    --nodes-max 6 \
    --default-admin-password admin \
    --default-environment-prefix jx-rocks
```

Let's explore what we're getting with that command. You should be able to correlate my explaination with the console output.

W> Do not be too hasty answering questions `jx` will ask you. For all other types of Kubernetes cluster, we can safely use the default answers (enter key). But, in case of EKS, there is one that we'll provide a non-default answer. I'll explain it in more detail when we get there. For now, keep an eye on the "`would you like to register a wildcard DNS ALIAS to point at this ELB address?`" question.

The process started creating an EKS cluster right away. That should take around ten minutes, during which you won't see any movement in `jx` console output. It used CloudFormation to set up EKS as well as worker nodes, so you can monitor the progress by visiting [CloudFormation page](https://console.aws.amazon.com/cloudformation/).

Once the cluster is fully operations, `jx` will try to deduce your Git name and email. If it fails to do so, it'll ask you for that info. After that, `jx` will install `tiller` (Helm server), since that is the default mechanism for installing and upgrading applications in Kubernetes.

The next in line is Ingress. The process will try to find it inside the `kube-system` Namespace. If it's not there (as it isn't), it'll ask you whether you'd like to install it. Type `y` or simply press the enter key since that is the default answer. You'll notice that we'll use the default answers for all the subsequent questions, since they are sensible and provide a set of best practices.

Once we chose to install Ingress, the process will proceed and install it through a Helm chart. As a result, Ingress will create a load balancer that will provide an entry point into the cluster.

Jenkinx X recommends using a custom DNS name to access services in your Kubernetes cluster. However, I could not be certain whether you do have a domain at hand or not. Instead, we'll use [nip.io](http://nip.io/) service to create a fully qualified domain for the cluster. To do that, we'll have to answer with `n` to the question `Would you like to register a wildcard DNS ALIAS to point at this ELB address?`. As a result, we'll be presented with another question. `Would you like wait and resolve this address to an IP address and use it for the domain?`. Answer with `y` (or press the enter key since that is the default answer). The process will wait until Elastic Load Balancer (ELB) is created and use it's host name to deduce its IP.

Next, we'll be asked a few questions related to Git and GitHub. You should be able to answer those. In most cases, all you have to do is confirm the suggested answer by pressing the enter key. As a result, `jx` will store the credentials internally so that it can continue interacting with GitHub on our behalf. It will also install the software necessary for correct functioning of those environments (Namespaces) inside our cluster.

Further on, The installation of Jenkins X itself, and a few other applications (e.g., ChartMuseum for storing Helm charts) will start. The exact list of applications that will be installed depends on Kubernetes flavor, the type of the setup, and the hosting vendor. But, before it proceeds, it'll need to ask us a few other questions. Which type of installation do we want? Static or serverless? Please answer with `Static Master Jenkins` (the default value). We'll explore the serverless option later. The next question is whether we want `Kubernetes Workloads: Automated CI+CD with GitOps Promotion` or `Library Workloads: CI+Release but no CD`. Choose the default value (Kubernetes Workloads).

A few moments later, Jenkins & friends will be up and running and you should see the `admin password` in the output (it should be `admin`). You'll also notice that Jenkins is now accessible through `http://jenkins.jx.[THE_IP_OF_YOUR_LB].nip.io`.

We're almost done. Only one question is pending. `Select the organization where you want to create the environment repository?` Choose one from the list.

We're almost done. The process will create two GitHub repositories; `environment-jx-rocks-staging` and `environment-jx-rocks-production`. Those repositories will hold the definitions of those environments. When, for example, you decide to promote a release to production, your pipelines will not install anything directly. Instead, they will push a change to `environment-jx-rocks-production` which, in turn, will trigger another job that will comply with the updated definition of the environment. That's GitOps. Nothing is done without recording a change in Git. Ofcourse, for that process to work, we need new jobs in Jenkins, so the process created two, that correspond to those repositories. We'll discuss the environments in greater detail later.

Finally, the `kubectl` context was changed to point to the `jx` Namespace, instead of the `default`.

We'll get back to the new cluster and the tools that were installed and configured in the [What Did We Get?](#intro-what-did-we-get) section. Feel free to jump there if you have no interest in other Cloud providers or how to install Jenkins X inside an existing cluster. EKS is coming next.

As you can see, a single `jx create cluster` command did a lot of heavy lifting. Nevertheless, there is one piece missing. It did not create Cluster Autoscaler. So, we'll add it ourselves. That way, we won't need to worry whether the cluster needs more nodes or not.

We'll add a few tags to the Autoscaling Group dedicated to worker nodes. To do that, we need to discover the name of the group. Since we created the cluster using eksctl, names follow a pattern which we can use to filter the results. If, on the other hand, you created your EKS cluster without eksctl, the logic should still be the same as the one that follows, even though the commands might differ slightly.

First, we'll retrieve the list of the AWS Autoscaling Groups, and filter the result with `jq` so that only the name of the matching group is returned.

```bash
ASG_NAME=$(aws autoscaling \
    describe-auto-scaling-groups \
    | jq -r ".AutoScalingGroups[] \
    | select(.AutoScalingGroupName \
    | startswith(\"eksctl-jx-rocks-nodegroup\")) \
    .AutoScalingGroupName")

echo $ASG_NAME
```

We stored the name of the cluster in the environment variable `NAME`. Further on, we retrieved the list of all the groups and filtered the output with `jq` so that only those with names that start with  `eksctl-$NAME-nodegroup` are returned. Finally, that same `jq` command retrieved the `AutoScalingGroupName` field and we stored it in the environment variable `ASG_NAME`. The last command output the group name so that we can confirm (visually) that it looks correct.

Next, we'll add a few tags to the group. Kubernetes Cluster Autoscaler will work with the one that has the `k8s.io/cluster-autoscaler/enabled` and `kubernetes.io/cluster/[NAME_OF_THE_CLUSTER]` tags. So, all we have to do to let Kubernetes know which group to use is to add those tags.

```bash
aws autoscaling \
    create-or-update-tags \
    --tags \
    ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=true \
    ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=kubernetes.io/cluster/jx-rocks,Value=true,PropagateAtLaunch=true
```

The last change we'll have to do in AWS is to add a few additional permissions to the role created through eksctl. Just as with the Autoscaling Group, we do not know the name of the role, but we do know the pattern used to create it. Therefore, we'll retrieve the name of the role, before we add a new policy to it.

```bash
IAM_ROLE=$(aws iam list-roles \
    | jq -r ".Roles[] \
    | select(.RoleName \
    | startswith(\"eksctl-jx-rocks-nodegroup-0-NodeInstanceRole\")) \
    .RoleName")

echo $IAM_ROLE
```

We listed all the roles, and we used `jq` to filter the output so that only the one with the name that starts with `eksctl-jx-rocks-nodegroup-0-NodeInstanceRole` is returned. Once we filtered the roles, we retrieved the `RoleName` and stored it in the environment variable `IAM_ROLE`.

Next, we need JSON that describes the new policy. I already prepared one. It allows a few additional actions related to `autoscaling`.

Finally, we can `put` the new policy to the role.

```bash
aws iam put-role-policy \
    --role-name $IAM_ROLE \
    --policy-name jx-rocks-AutoScaling \
    --policy-document https://raw.githubusercontent.com/vfarcic/k8s-specs/master/scaling/eks-autoscaling-policy.json
```

Now that we added the required tags to the Autoscaling Group and that we created the additional permissions that will allow Kubernetes to interact with the group, we can install Cluster Autoscaler Helm Chart. If you followed the logs from `jx cluster create`, you noticed that it already installed `tiller` (Helm server). All we have to do now is execute `helm install stable/cluster-autoscaler`

```bash
helm install stable/cluster-autoscaler \
    --name aws-cluster-autoscaler \
    --namespace kube-system \
    --set autoDiscovery.clusterName=jx-rocks \
    --set awsRegion=us-west-2 \
    --set sslCertPath=/etc/kubernetes/pki/ca.crt \
    --set rbac.create=true --wait
```

Once the Deployment is rolled out, the autoscaler should be fully operational.

You can see from the Cluster Autoscaler (CA) example how much `jx` helps. It too us a single command to create a cluster, to configure it, to install a bunch of tools, and so on. For the only thing `jx` did not do, we had to execute five or six commands. Hopefully, EKS CA will be part of `jx` soon.

We'll get back to the new cluster and the tools that were installed and configured in the [What Did We Get?](#intro-what-did-we-get) section. Feel free to jump there if you have no interest in other Cloud providers or how to install Jenkins X inside an existing cluster. AKS is coming next.

## Creating An Azure Kubernetes Service (AKS) Cluster With jx {#jx-create-cluster-aks}

Let's create an AKS cluster with all the tools installed and configured. We'll name the cluster `jxrocks` (`-c`) and let it reside inside its own group `jxrocks-group` (`-n`). It'll run inside `eastus` location (`-l`) and on `n1-standard-2` (2 CPUs and 7.5 GB RAM) machines (`-s`). The number of nodes will be set to three (`--nodes`).

We'll also set the default Jenkins X password to `admin` ( `--default-admin-password`). Otherwise, the process would create a random one. Finally, we'll set `jx-rocks` as the default environment prefix (`--default-environment-prefix`). A part of the process will create a few repositories (one for staging and the other for production) and that prefix will be used to form their names. We won't go into much detail about those environments and repositories just yet. That's reserved for one of the follow-up chapters.

Feel free to change any of the values in the command that follows to better suit your needs. Or, keep them as they are. After all, this is only a practice and you'll be able to destroy the cluster and recreate it later on with different values.

```bash
jx create cluster aks \
    -c jxrocks \
    -n jxrocks-group \
    -l eastus \
    -s Standard_B2s \
    --nodes 3 \
    --default-admin-password admin \
    --default-environment-prefix jx-rocks
```

Let's explore what we're getting with that command. You should be able to correlate my explaination with the console output.

First, Azure authentication screen should open asking you to confirm that you are indeed who you claim you are. If that does not happen, please open the link provided in the output manually.

Once we're authenticated, `jx` will create a cluster. It should take around ten minutes.

Once the AKS cluster is up and running, the process will create a `jx` Namespace. It will also modify your local `kubectl` context and create a ClusterRoleBinding that will give you the administrative permissions.

At this point, `jx` will try to deduce your Git name and email. If it fails to do so, it'll ask you for that info.

Once the cluster is up-and-running and configured, `jx` will install `tiller` (Helm server), since that is the default mechanism for installing and upgrading applications in Kubernetes.

The next in line is Ingress. The process will try to find it inside the `kube-system` Namespace. If it's not there (as it isn't), it'll ask you whether you'd like to install it. Type `y` or simply press the enter key since that is the default answer. You'll notice that we'll use the default answers for all the subsequent questions, since they are sensible and provide a set of best practices.

Once we chose to install Ingress, the process will proceed and install it through a Helm chart. As a result, Ingress will create a load balancer that will provide an entry point into the cluster. This is the point that might fail our setup. GCP default quotas are very low and you might not have the right to create additional load balancers. If that's the case, please open the [Quotas](https://console.cloud.google.com/iam-admin/quotas) page, select those that are at the maximum, and click the *Edit Quotas* button. Increasing a quota is a manual process. They do it relativelly fast so you should have to wait for long.

Once the load balancer is created, `jx` will use it's host name to deduce its IP.

Since we did not specify a custom domain for our cluster, the process will combine that IP with the [nip.io](http://nip.io/) service to create a fully qualified domain for the cluster, and we'll be asked whether we want to proceed using it. Type press the enter key to continue.

Next, we'll be asked a few questions related to Git and GitHub. You should be able to answer those. In most cases, all you have to do is confirm the suggested answer by pressing the enter key. As a result, `jx` will store the credentials internally so that it can continue interacting with GitHub on our behalf. It will also install the software necessary for correct functioning of those environments (Namespaces) inside our cluster.

Further on, The installation of Jenkins X itself, and a few other applications (e.g., ChartMuseum for storing Helm charts) will start. The exact list of applications that will be installed depends on Kubernetes flavor, the type of the setup, and the hosting vendor. But, before it proceeds, it'll need to ask us a few other questions. Which type of installation do we want? Static or serverless? Please answer with `Static Master Jenkins` (the default value). We'll explore the serverless option later. The next question is whether we want `Kubernetes Workloads: Automated CI+CD with GitOps Promotion` or `Library Workloads: CI+Release but no CD`. Choose the default value (Kubernetes Workloads).

A few moments later, Jenkins & friends will be up and running and you should see the `admin password` in the output (it should be `admin`). You'll also notice that Jenkins is now accessible through `http://jenkins.jx.[THE_IP_OF_YOUR_LB].nip.io`.

We're almost done. Only one question is pending. `Select the organization where you want to create the environment repository?` Choose one from the list.

We're almost done. The process will create two GitHub repositories; `environment-jx-rocks-staging` and `environment-jx-rocks-production`. Those repositories will hold the definitions of those environments. When, for example, you decide to promote a release to production, your pipelines will not install anything directly. Instead, they will push a change to `environment-jx-rocks-production` which, in turn, will trigger another job that will comply with the updated definition of the environment. That's GitOps. Nothing is done without recording a change in Git. Ofcourse, for that process to work, we need new jobs in Jenkins, so the process created two, that correspond to those repositories. We'll discuss the environments in greater detail later.

Finally, the `kubectl` context was changed to point to the `jx` Namespace, instead of the `default`.

We'll get back to the new cluster and the tools that were installed and configured in the [What Did We Get?](#intro-what-did-we-get) section. Feel free to jump there if you have no interest in other Cloud providers or how to install Jenkins X inside an existing cluster. The use-case in line is about installing Jenkins X inside an existing cluster.

## Installing Jenkins X In An Existing Kubernetes Cluster {#jx-install}

I will assume that you are have a Kubernetes cluster, and that it is accessible from outside. To be more precise, the cluster needs to be accessible from GitHub, so that it can send webhook notifications whenever we push some code changes. Please note that requirement is valid only for the purpose of the exercises. In "real world" situation you might use a Git server that is inside your cluster (e.g., GitLab, BitBucket, GitHub Enterprise, etc).

However, before we proceed, we'll verify whether the cluster we're hoping to use meets the requirements. Fortunatelly, `jx` has a command that can help us. We can run compliance tests and check whether there is anything "suspicious" in the results.

## Running Compliance Tests

Among many other things, `jx` has its own implementation of the [sonobuoy](https://github.com/heptio/sonobuoy) SDK.

So, what is sonobuoy? It is a diagnostic tool that makes it easier to understand the state of a Kubernetes cluster by running a set of Kubernetes conformance tests in an accessible and non-destructive manner. It supports Kubernetes versions 1.11, 1.12 and 1.13, so bear that in mind before running it in your cluster.

Given that I do not know whether your cluster complies with Kubernetes specifications and best practices, I cannot guarantee that Jenkins X installation will be successfull or not. Compliance tests should give us that kind of comfort.

Before we proceed with compliance, I must warn you that the execution last over an hour. Is it worth it? That depends on your cluster. Jenkins X does not need anything "special". It assumes that your Kubernetes cluster has some bare minimums and that it complies with Kubernetes standards. If you created it with one of the Cloud providers and you did not go astray from the default setup and configuration, you can probably skip running the compliance tests. On the other hand, if you baked your own Kubernetes cluster, or if you customized it to comply with some corporate restrictions, running compliance tests might be well worth the wait. Even if you're sure that your cluster is ready for Jenkins X, it's still a good idea to run them. You might find something you did not know exists or, to be more precise, you might see that you are missing things you might want to have.

Anyway, the choice is yours. You can run the compliance tests and wait for over an hour, or you can be brave and skip right [Back To Installing Jenkins X In An Existing Kubernetes Cluster](#jx-install-cont).

```bash
jx compliance run
```

```
INFO[0000] created object name=heptio-sonobuoy namespace= resource=namespaces
INFO[0000] created object name=sonobuoy-serviceaccount namespace=heptio-sonobuoy resource=serviceaccounts
INFO[0000] created object name=sonobuoy-serviceaccount-heptio-sonobuoy namespace= resource=clusterrolebindings
INFO[0000] created object name=sonobuoy-serviceaccount namespace= resource=clusterroles
INFO[0000] created object name=sonobuoy-config-cm namespace=heptio-sonobuoy resource=configmaps
INFO[0000] created object name=sonobuoy-plugins-cm namespace=heptio-sonobuoy resource=configmaps
INFO[0000] created object name=sonobuoy namespace=heptio-sonobuoy resource=pods
INFO[0000] created object name=sonobuoy-master namespace=heptio-sonobuoy resource=services
```

Once the compliance tests are running, we can check their status or, to be more precise, to see whether they finished executing.

```bash
jx compliance status
```

The output is as follows.

```
Compliance tests are still running, it can take up to 60 minutes..
```

If you got `No compliance status found` message instead, you were too hasty and the tests did not yet start. If that's the case, re-execute the `jx compliance status` command.

We can also follow the progress by watching the logs.

```bash
jx compliance logs -f
```

After a while, it'll start churning a lot of logs, much more than what would fit a book format. If it's stuck, you executed the previous command too soon. Cancel with *ctrl+c* and repeat the `jx compliance logs -f` command.

Once you get bored looking at endless logs entries, cancel logs following by pressing *ctrl+c*.

The best thing you can do right now is to find something to watch on Netflix, since there's at least an hour left until the tests are finished.

We'll know whether the compliance testing is done by executing `jx compliance status` and getting `TODO:` as the output.

```bash
jx compliance results

jx compliance delete
```

## Going Back To Installing Jenkins X In An Existing Kubernetes Cluster {#jx-install-cont}

Now that we run the compliance tests and that they showed that (hopefully) our cluster complies with Kubernetes, we can proceed and install Jenkins X.

We'll need a few pieces of information before we install the tools we need. The first in line is the IP.

Normally, your cluster should be accessible through an external load balancer. Assuming that we can guarantee its availability, an external load balancer provides a stable entry point (IP) to the cluster. Ad the same time, its job is to ensure that the requests are forwarded to one of the healthy nodes of the cluster. That's, more or less, all we need an external load balancer for.

If you do have an external LB, please get its IP. If you don't, you can use the IP of one of the nodes of the cluster, as long as you understand that a failure of that node would make everything inaccessible.

Please replace `[...]` with the IP of your load balancer or one of the worker nodes before you execute the command that follows.

```bash
LB_IP=[...]
```

Next, we need a domain stored in environment variable `DOMAIN`. If you already have one, make sure that its DNS records are pointing to the cluster, and execute the command that follows.

combine that IP with the [nip.io](http://nip.io/) service to create a fully qualified domain for the cluster, and we'll be asked whether we want to proceed using it. Replace `[...]` with the domain name before executing the command that follows.

```bash
DOMAIN=[...]
```

If you do NOT have a domain, we can use combine the IP with the [nip.io](http://nip.io/) service to create a fully qualified domain for the cluster. If that's the case, please execute the command that follows.

```bash
DOMAIN=jenkinx.$LB_IP.nip.io
```

We need to find out which provider to use. The available providers are the same as those you saw through the `jx create cluster help` command. For your convenience, we'll list them again, only this time with the `jx install` command-

```bash
jx install --help | grep "provider="
```

The output is as follows.

```
--provider='': Cloud service providing the Kubernetes cluster.  Supported providers: aks, aws, eks, gke, icp, iks, jx-infra, kubernetes, minikube, minishift, oke, openshift, pks
```

As you can see, we can install Jenkins in AKS, AWS (created with kops), EKS, GKE, ICP, IKS, minikube, minishift, OKE, OpenShift, and PKS. The two I skipped from that list are `jx-infra` and `kubernetes`. The former is used mostly internally by the maintainers of the project, while the latter (`kubernetes`) is a kind of a wildcard provider. We can use it if our Kubernetes cluster does not match any of the available providers (e.g., Rancher, DigitalOcean, etc).

All in all, if your Kubernetes is among one of the supported providers, use it. Otherwise, choose `kubernetes`. There are two exceptions though. Minikube and minishift are locally and are not accessible from GitHub. Please avoid them since some of the features will not be available. The main one are GitHub webhook notifications. While that might sounds as a minor issue, they are a crucial element of the system we're trying to build. Jenkins X relies heavily on GitOps which assumes that any change is stored in Git and that every push might potentially initiate some processes (e.g., deployment to the staging environment).

Please replace `[...]` with the selected provider in the command that follows.

```bash
PROVIDER=[...]
```

Next, we need to figure out the Namespace where nginx Ingress resides. You do have an nginx Ingress running in your cluster? If you don't, `jx` will install it for you. In that case, feel free to skip the commands that declare the `INGRESS_*` variables. Also, when we come to the `jx install` command, remove the arguments `--ingress-namespace` and `--ingress-deployment`.

Let's list the Namespaces and see which one hosts our nginx Ingress.

```bash
kubectl get ns
```

```
NAME            STATUS   AGE
default         Active   10m
ingress-nginx   Active   6m
kube-public     Active   10m
kube-system     Active   10m
```

In my case, it's `ingress-nginx`. In yours, it might be something else. Or, it might be inside the `kube-system` Namespace. If that's the case, list the Pods with `kubectl -n kube-system get pods` to confirm it.

Before executing the command that follows, please replace `[...]` with the Namespace where Ingress resides.

```bash
INGRESS_NS=[...]
```

We need to find out the name of the Ingress Deployment.

```bash
kubectl -n $INGRESS_NS get deployments
```

The output, in the case of my cluster, is as follows. Yours might different.

```
NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx-ingress-controller   1         1         1            1           7m
```

In my case, the Deployment is called `nginx-ingress-controller`. Yours is likely named the same. If it isn't, please modify the command that follows accordingly.

```bash
INGRESS_DEP=nginx-ingress-controller
```

There's only one more thing missing. I promise that this is the last one.

We need to know the Namespace in which `tiller` (Helm server) is running. Just as with Ingress, if you do NOT have `tiller`, `jx` will install it for you.

So, if you do have `tiller`, replace `[...]` with the Namespace where it's running. Otherwise, skip the command that follows and make sure to remove the `--tiller-namespace` argument from the `jx install` command.

```bash
TILLER_NS=[...]
```

Now we are finally ready to install Jenkins X into your existing Kubernetes cluster.

```bash
jx install \
    --provider $PROVIDER \
    --external-ip $LB_IP \
    --domain $DOMAIN \
    --default-admin-password admin \
    --ingress-namespace $INGRESS_NS \
    --ingress-deployment $INGRESS_DEP \
    --tiller-namespace $TILLER_NS \
    --default-environment-prefix jx-rocks
```

If, by any chance, you followed the instructions for GKE, EKS, or AKS, you'll notice that `jx install` executes the same steps as those performed by `jx cluster create` after it created the cluster. You can think of `jx install` as a subset of `jx cluster create`.

The process will create a `jx` Namespace. It will also modify your local `kubectl` context and create a ClusterRoleBinding that will give you the administrative permissions.

At this point, `jx` will try to deduce your Git name and email. If it fails to do so, it'll ask you for that info.

Once the cluster is up-and-running and configured, `jx` will install `tiller` (Helm server), since that is the default mechanism for installing and upgrading applications in Kubernetes.

The next in line is Ingress. The process will try to find it inside the `kube-system` Namespace. If it's not there (as it isn't), it'll ask you whether you'd like to install it. Type `y` or simply press the enter key since that is the default answer. You'll notice that we'll use the default answers for all the subsequent questions, since they are sensible and provide a set of best practices.

Once we chose to install Ingress, the process will proceed and install it through a Helm chart. As a result, Ingress will create a load balancer that will provide an entry point into the cluster. This is the point that might fail our setup. GCP default quotas are very low and you might not have the right to create additional load balancers. If that's the case, please open the [Quotas](https://console.cloud.google.com/iam-admin/quotas) page, select those that are at the maximum, and click the *Edit Quotas* button. Increasing a quota is a manual process. They do it relativelly fast so you should have to wait for long.

Once the load balancer is created, `jx` will use it's host name to deduce its IP.

Since we did not specify a custom domain for our cluster, the process will combine that IP with the [nip.io](http://nip.io/) service to create a fully qualified domain for the cluster, and we'll be asked whether we want to proceed using it. Type press the enter key to continue.

Next, we'll be asked a few questions related to Git and GitHub. You should be able to answer those. In most cases, all you have to do is confirm the suggested answer by pressing the enter key. As a result, `jx` will store the credentials internally so that it can continue interacting with GitHub on our behalf. It will also install the software necessary for correct functioning of those environments (Namespaces) inside our cluster.

Further on, The installation of Jenkins X itself, and a few other applications (e.g., ChartMuseum for storing Helm charts) will start. The exact list of applications that will be installed depends on Kubernetes flavor, the type of the setup, and the hosting vendor. But, before it proceeds, it'll need to ask us a few other questions. Which type of installation do we want? Static or serverless? Please answer with `Static Master Jenkins` (the default value). We'll explore the serverless option later. The next question is whether we want `Kubernetes Workloads: Automated CI+CD with GitOps Promotion` or `Library Workloads: CI+Release but no CD`. Choose the default value (Kubernetes Workloads).

A few moments later, Jenkins & friends will be up and running and you should see the `admin password` in the output (it should be `admin`). You'll also notice that Jenkins is now accessible through `http://jenkins.jx.[THE_IP_OF_YOUR_LB].nip.io`.

We're almost done. Only one question is pending. `Select the organization where you want to create the environment repository?` Choose one from the list.

We're almost done. The process will create two GitHub repositories; `environment-jx-rocks-staging` and `environment-jx-rocks-production`. Those repositories will hold the definitions of those environments. When, for example, you decide to promote a release to production, your pipelines will not install anything directly. Instead, they will push a change to `environment-jx-rocks-production` which, in turn, will trigger another job that will comply with the updated definition of the environment. That's GitOps. Nothing is done without recording a change in Git. Ofcourse, for that process to work, we need new jobs in Jenkins, so the process created two, that correspond to those repositories. We'll discuss the environments in greater detail later.

Finally, the `kubectl` context was changed to point to the `jx` Namespace, instead of the `default`.

## What Did We Get? {#intro-what-did-we-get}

No matter whether you executed `jx cluster create` or `jx install`, it was a single command (Cluster Autoscaler in AWS is an exception). With that single command, we accomplished a lot.

We create a Kubernetes cluster (unless you executed `jx install`). We got a few Namespaces, a few GitHub repository. We got Ingress (unless it already existed in the cluster). We got a bunch of ConfigMaps and Secrets that are essential for what we're trying to accomplish, and yet we will not discuss just yet. Most importantly, we got quite a few applications that are essential for our yet-to-be-discovered goals. What are those applications? Let's check them out.

```bash
kubectl -n jx get pods
```

The output is as follows.

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
```

As you can see, there are quite a few tools in that Namespace. We got Jenkins. Now, that's not simply yet-another-Jenkins. It's much more. For now, I'll keep you in suspense. Then, there is ChartMuseum. That's where we'll store our Helm charts. Further on, we got a few controllers that are not relevant for this discussion. What else is there? We got Docker Registry that we'll use to store our container images. Heapster is mostly deprecated, so I'll ignore it. Further on, we have Monocular with its MongoDB. We can use it as an UI that allows us to browse the charts we'll store in ChartMuseum. Finally, there is Nexus, that we can use to store our artifacts.

Is that all? Not even close. But, it should be enough until we get into more advanced topics. What matters for now, is that we got everything we need to manage a full lifecycle of our applications. More importantly, we got a process to guide us through that lifecycle. We'll explore the tools and the process in the follow-up chapters. For now, let's just say that this is awesome. We got a lot (much more than what I shared with you so far) from execution of a single command.

Before we leave, let's validate whether we can access those applications. We won't go through all of them just yet, but pick only one. It'll be Jenkins. But, what is its address? Should we take a peek at Ingress to see the host under which Jenkins is accessible? There's no need for that. We can open Jenkins UI or, to use the new name, Jenkins console, with yet another `jx` command.

```bash
jx console
```

Please login using `admin` as the username and password.

![Figure 2-TODO: TODO:](images/ch02/jx-console-environments.png)

What you see in front of you is Jenkins, alive and kicking. It already has two jobs, each being in charge with one of the two environments we have right now (staging and production).

## What Now?

Now you know how to create a Jenkins X cluster or how to install it inside an existing Kubernetes cluster. Now we're ready to start exploring its features. But, before we get there, I'd like to share with you the commands to destroy your cluster or, if that's your preference, to uninstall Jenkins X. That way, you can undo what we did or you can take a break at the end of each chapter without paying to your hosting vendor for unused resources. Each chapter will start with the instuctions that will get you up and running in no time.

In other words, if you are not planning to jump into the next chapter right away, you can use the commands that follow to undo what we did (destroy the cluster or uninstall Jenkins X). On the other hand, if you are still full of energy and want to continue reading, you jump into the next chapter right away.

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

# If AKS
kubectl config delete-cluster jxrocks

# If AKS
kubectl config delete-context jxrocks

# If AKS
kubectl config unset \
    users.clusterUser_jxrocks-group_jxrocks

# If AKS
az group delete \
    --name jxrocks-group \
    --yes

# Uninstall from an existing cluster
jx uninstall \
  --context $(kubectl config current-context) \
  -b

# TODO: Install `hub`

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```