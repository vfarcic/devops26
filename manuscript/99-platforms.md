## Comparing Kubernetes Platforms For Running Local Clusters

When running a local Kubernetes cluster, there are no big differences between Docker for Mac/Windows, Minikube, and OpenShift. All three create a fully operational Kubernetes cluster.

Docker for Mac/Windows provides a very transparent experience. It's as if it's not even there. It runs in background. There are no commands to create or destroy the cluster. It feels like Kubernetes is running on top of our operating system.

We did experience a problem with ServiceAccounts in Docker for Mac/Windows. Even though RBAC is set up by default, we could use a sidecar container that communicated with Kube API. For most use cases, that is not a real problem. Docker for Mac/Windows is designed to be a single-user cluster that is accessible only to the owner of the laptop. RBAC (as ServiceAccounts) make sense only when running a "real" cluster used by many users and, consequently, many processes. Still, we might want to test our ServiceAccounts locally. We could not do that through Docker for Mac/Windows.

TODO: Trash Docker for Mac/Windows ServiceAccount

TODO: Docker for Mac/Windows provides no mechanism to specify k8s version

TODO: Helm does not work with some OpenShift resources (e.g., Routes)

Another negative experience with Docker for Mac/Windows was installation of Ingress Controller. We had to follow the official instructions. With Minikube, for example, we can simply execute `minikube addons enable ingress` to accomplish the same result. If we are to give a recommendation how to run a Kubernetes cluster locally to someone not interested diving deep into Kubernetes, Minikube addons make everything much easier. On the other hand, hanving to install system level components like Ingress using kubectl (or Helm) make local cluster much more similar to "real" production. Still, that should not be a problem in case of Minikube. Having addons does not mean that we cannot ignore them and run the same commands to, for example, install Ingress locally as we'd do in production.

Minishift is very similar to Minikube. Both create a cluster with a single command. The only issue is that Minishift does not support default storage class. As a workaround, we got a hundred volumes without a class name. The result is the same. In both cases we can create volume claims with storage class name. Still, it's a bit annoying that we have to see those hundred volumes knowing that Minikube already has a more elegant solution.

If you're wondering which solution to use to create a Kubernetes cluster locally, I'd recommend Docker for Mac/Windows, unless you are running Linux. It does have a few issues I did not detect in Minikube but they are minor and we can expect them to be fixed soon.

The only downside of Docker for Mac/Windows I can think of is that there is no Docker for Linux. If you're running Ubuntu or some other Linux distribution on your laptop, you'll have to switch to Minikube or Minishift. For everyone else, Docker for Mac/Windows is probably the best way to run a Kubernetes cluster. Unless, you're planning to use OpenShift as your production cluster. In that case, there is very little doubt that you should run Minishift locally.

While OpenShift is great and it does bring additional value on top of "vanilla" Kubernetes, it also introduces controllers that are very specific to OpenShift. That in itself should not be a problem. If you want additional value in Kubernetes, that comes through new controllers. But, not everything in OpenShift brings additional value. Routes are a very good example. They replace Ingress without providing a tangible benefit. As a result, you are tied to a platform that has a valid alternative in form of a standard API. Ingress is the direction Kubernetes community decided to take for routing external requests. I can imagine that routes exist only for historical reasons. RedHat (and the community behind OpenShift) implemented them when Ingress did not exist. The problem is that we (Kubernetes community) moved on and choose Ingress as the preferable way to handle external routing. Yet, OpenShift continues to stick to Routes and, as the result, you have to use Minishift for local clusters. Not being compatible with all the standards is the biggest downside of OpenShift. We can circumvent incompatibility problem by, for example, installing Ingress but that would only open Pandora's box. No OpenShift cluster I've seen did that.

What is the final recommendation? **Use Docker for Mac/Windows to run your cluster locally**. It is the most user-friendly solution that makes running a cluster as transparent as possible. If you are using Linux as the operating system on your laptop, Minikube is the way to go. Minishift makes sense only if you chose to use OpenShift as the platform for running production clusters. Without it, you won't be able to create OpenShift-specific resources like Routes.

## Comparing Kubernetes Platforms For Running On-Prem Clusters

TODO: Write

### OpenShift

RedHat’s OpenShift is one of the more veteran and comprehensive Kubernetes solutions, with a lot of development and community work from Red Hat thrown in for good measure. It’s a standalone Kubernetes distribution, adding dozens of tools for developers and operations aimed at making Kubernetes more productive.

OpenShift is probably the most widely used Kubernetes platform on on-prem servers. RedHat's long track record with Kubernetes is a proof that they are experienced and committed to it. Many of the features currently available in OpenShift were taken as a blueprint for Kubernetes core.

RedHat proved through its collaboration with Kubernetes community that they have the expertise required not only to assemble a Kubernetes distribution but also to influence Kubernetes road-map. Some of the OpenShift features (e.g., Routes) were created when similar functionalities did not exist in Kubernetes (e.g., Ingress).

My main (personal) issue with OpenShift is that it does not follow standards. That is to be expected since some of the Kubernetes "standards" are based on OpenShift. However, insistence on using resource types that are not supported by Kubernetes core can lead to vendor lock-in. You will not be able to (easily) use Helm adopted by almost everyone else because OpenShift has its own standard. You won't be able to leverage pre-packaged applications because they are based on Ingress and not Routes. And so on and so forth. Once OpenShift is adopted, it might be very costly to move to a different Kuberentes platform or to leverage offerings from industry as a whole.

On the other hand, OpenShift clearly rules among on-prem Kubernetes clusters. They were the first on the market and choosing OpenShift means following the path that many other companies already took. It is a very low-risk choice with a vendor that proved to be one the leaders in Kubernetes community.

The fact that OpenShift has quite a few of its own resource types that are not compatible with Kubernetes core is the primary concern that prevents me from saying "use it, without a doubt."

### Rancher 2

Rancher (since release 2) is probably the most commonly used free Kubernetes distribution. Unlike some others (e.g., OpenShift) it does not stray away from core Kubernetes thus making it compatible with community and industry standards. Its focus is more on cluster management (especially with multiple clusters) than Kubernetes internal workings.

In my experience, Rancher is the best choice for the companies who do want an enterprise-ready Kubernetes cluster which maintains compatibility with Kuberenetes-core. The distribution is free even though support is provided for a fee.

## Comparing Kubernetes Platforms For Running Clusters In Cloud

EKS con: Silly installation instructions
EKS con: Metrics Server is not installed by default
EKS con: Cluster autoscaling is not baked in
EKS con: Only managed masters, not worker nodes
EKS con: Charges for masters
EKS con: No out-of-the-box upgrade of the worker nodes
EKS con: Does not delete related resources (e.g., LB) when the cluster is deleted
EKS con: No out-of-the-box logging


AKS con: Slow to create (20-30 min. approx, sometimes 1h)
AKS con: Cluster autoscaling is not baked in and is still in beta

## Random Stuff

Ingress on different platforms is a nightmare.

OpenShift con: Slight differences in the security context
OpenShift con: Services accessible through Routes need to be `LoadBalancer` type.

Minishift con: A hundred volumes instead of a dynamic StorageClass
