## TODO

- [X] Code
- [ ] Write
- [X] Code review static GKE
- [X] Code review serverless GKE
- [ ] Code review static EKS
- [ ] Code review serverless EKS
- [ ] Code review static AKS
- [ ] Code review serverless AKS
- [ ] Code review existing static cluster
- [ ] Code review existing serverless cluster
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

Jenkins X is evolving rapidly. We can see that by checking the releases. There's hardly a day without at least one Jenkins X release. There are days with more then ten releases. That's fast, and for very good reasons.

The community behind the project is growing rapidly and that means that the rate of pull requests is increasing as well. It's a simple calculation. More pull requests people make, more releases we get.

There is another important reason for such high release frequency. Among other things, Jenkins X promotes continuous delivery and it would be silly if it does not adhere to the same principles itself. So, instead of making a new release every quarter or some other period, Jenkins X creates a release from every approved pull request.

All that does not mean that you should follow the same frequency. I do not believe that you should upgrade your cluster with every new release since that would mean that you would spend much of your time performing upgrades. Still, I do want you to upgrade often. Once a month might be a good frequency. Once a quarter would be acceptable. Less frequently than that would be a very bad idea.

You might be thinking that performing upgrades every month is insane. "It's too risky. It takes too much time." I beg to differ. Anyone working in oour industry for more than ten years experienced what happens when we wait for a long time. It's so hard and painful to upgrade after years of "status quo" that many give up and just keep what they have until it looses support, and then they complain even more. The more we wait, the bigger the chance that something terribly wrong will happen. That's one of the reasons why we release our software much more frequently, and we should apply the same logic to third party applications as well. Applying smaller changes more frequently gives us more control, allows us to find issues faster, and makes it easier to fix them.

But, my goal in this chapter is not to convince you that you should be upgrading your third-party software frequently. Rather, I must point out that we haven't upgraded our Jenkins X cluster at all. Or, to be more precise, if you reused the same cluster throughout all the chapters you are running an old version of Jenkins X. Even if you did destroy the cluster at the end of each chapter and created a new one for the next, you will start using Jenkins X outside our exercises and that means that you will have to upgrade it sooner or later. So, the time has come to learn how to do just that.

At this moment you might be thinking that upgrading Jenkins X platform is a single command and that it is silly to dedicate a whole chapter to it. If that's what's going on in your head, you are right. But, upgrading the platform inside the cluster is only part of the story. Jenkins X platform is only one of the pieces of the puzzle. The cluster might also contain addons, apps, and extensions. Then there are CLIs and binaries on our laptop that might need upgrading as well. Finally, we might need to upgrade our Ingress rules as well. If for no other reason, we do need to add TLS certificates. Noone should expose their applications over plan HTTP.

As yuo can see, there's much more to upgrading that what might seem on the first look. But, before we dive into it, it might be beneficial to understand Jenkins X version stream.

## Understanding Jenkins X Version Stream

By now you should know that Jenkins X packages a lot of useful applications, tools, and wrappers. It has command line packages installed on your laptop. Quite a few applications we installed in your cluster. Even though we do no recommend using tiller (Helm server) inside a cluster, many third-party Helm charts were used during the installation. The `jx` CLI converted them into "pure" Kubernetes YAML files before sending them to Kube API.

Given that new Jenkins X releases are made all the time, things would get messy very quickly if we would be using "latest" releases of all those charts and packages. It should come as no surprise that Jenkins X needs a place to store the information about stable versions of all packages and charts. That place is the [jenkins-x/jenkins-x-versions](https://github.com/jenkins-x/jenkins-x-versions) repository.

I will not waste space by explaining how *jenkins-x-versions* work. If you're curious, please visit [Version Stream](https://jenkins-x.io/architecture/version-stream/) page.

Let's take a quick look at the [jenkins-x/jenkins-x-versions](https://github.com/jenkins-x/jenkins-x-versions) repository.

```bash
open "https://github.com/jenkins-x/jenkins-x-versions"
```

For now, we are only interested in the current version of the Jenkins X platform. Since it is installed through yet another Helm chart (without tiller), you can probably guess where we could find the version of the latest release.

Please open the *charts/jenkins-x* directory and open the *jenkins-x-platform.yml* file.

![Figure 14-TODO: TODO](images/ch14/jenkins-x-platform.png)

The value of the `version` field is very important. It defines a combination of quite a few applications running inside the cluster (e.g., ChartMuseum, Docker Registry, garbage collectors, etc). So far, you installed only latest Jenkins X. That's not a good idea with any application, so it shouldn't be a good idea with Jenkins X either. The only reason why we always used latest so far is to simplify exercises and to avoid making a new release of this book every day. But, when you do start using Jenkins X in production you should always be specific. Even if you do choose to run the latest version, specify it explicitly through the `--version` argument available both in `jx create cluster` and `jx install` commands. That way you will be in full control over which platform you're running. Now that you know where to find the information, there is no excuse for being vague.

Today we'll do something different. Since we want to practice all sorts of upgrades, we are going to break our habit of creating a new cluster based on the latest release and intentionally install an older one. That will allow us to experience the upgrade, instead of trying to imagine how it would look like. That, ofcourse, does not apply to you if you're reusing the same cluster throughout all the chapters since that means that you are certainly running an old version of Jenkins X platform. If that's the case, feel free to jump straight into the [Validating Upgrades And Backing Up The Cluster](#upgrade-backup) section.

Assuming that you still have the *jenkins-x-platform.yml* file open in your browser, please click the *History* button and select one of the older commits. Just make sure that commit is not marked as failed (icon with a red X). Next, scroll to the *jenkins-x-platform.yml* file (unless its the only one in that commit) and copy the `version` value.

We'll store the version of the older version in an variable so that we can reference it easier later on.

W> Please replace `[...]` with the version you copied before executing the commands that follow.

```bash
PLATFORM_VERSION=[...]
```

Next comes the familiar part where we create a new cluster (unless you are reusing the one from the previous chapter). But, as already mentioned, this time we will not use the latest platform. We'll add `--version` argument.

W> Make sure that you add `--version $PLATFORM_VERSION` to the arguments when creating the cluster or installing Jenkins X. The gists specified in the next section are the same as before and you will need to add the `--version` argument to `jx create cluster` or `jx install` commands. Otherwise, you will no be able to see the outcome of upgrading the cluster.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

TODO: Rewrite

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [14-upgrade.sh](TODO:) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new static **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new static **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new static **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** static cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

I> The commands that follow will reset your *go-demo-6* `master` branch with the contents of the `versioning` or `extension-model` branch that contain all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

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

## Validating Upgrades And Backing Up The Cluster {#upgrade-backup}

Before we jump into different upgrade options, I must make an important statement. Do not trust blindly anyone or anything. We (the community behind Jenkins X) are doing oour best to make it stable and backwards compatible. Upgrading **should work**. But that does not mean that it will **always work**. No matter how much attention we put into making the project stable, there is almost an infite number of combinations and you should make an extra effort too test upgrades before applying them to production, just as you're hopefully validating your applications.

I> Do NOT trust anyone or anything. Validate upgrades of all applications, no matter whether you wrote them or they come from third-parties.

But, testing your applications and validating system-level third-applications is not equally easy. You are not in full control of third-party applications, especially when they are not fully open sourced.

Excluding the option of upgrading Jenkins X blindly, two most commonly used strategies is to run a test instance in parallel with production (e.g., in separate Namespaces) or to have a test cluster where. I prefer the latter option, when we do have the ability to create and destroy the cluster on demand. In such a case, we can create a new cluster, install the same Jenkins X version we're running in production, upgrade it, test it, and, if everything works as expected, upgrade production as well. If we do not have a test cluster, our best bet is to install Jenkins X in different namespaces and follow the same validation process we'd follow if it would be running in the separate cluster. The major problem with using different namespaces is in the probability of a mistake that'll affect production. It should work well if we're carefuly and experienced with Kubernetes.

No matter whether you test upgrades and, if you do, how well you do it, one thing is certain. You should have a backup of your cluster. If you do, you should be able to manage the worst case scenario. You will be able to restore the state of your cluster to the last known working state.

Given that Kuberentes backups are not directly related to Jenkins X and that there are myriad of options at our disposal, I will not go into depth of evaluating backup solutions nor will I provide detailed instructions. The only thing I will state is that my favorite tool is [Velero](https://velero.io/). If you do not have periodic and on-demand backups in place, feel free to check it out and decide whether it is an option that fits your use-case.

All in all, I will assume that you are testing upgrades before you apply them to production, that you are backing up your cluster, and that you can restore the last known good version if everything else fails. We are about to upgrade our Jenkins X cluster and you've been warned that the commands that follow do not excuse you from testing and backing up.

Off we go...

## Upgrading The Cluster And Local Binaries

Before we upgrade our cluster, we'll have a quick look at the current version.

```bash
jx version
```

In my case, the output is as follows.

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

You will likely be asked whether you want to upgrade `jx` to the new release. That is a safe operation since it will upgrade only `jx` CLI and leave the apps running in the cluster intact. If you were creating the cluster using the provided Gists, you already upgraded the CLI quite a few times, so that should not be anything new.

It might be worth mentioning that `jx` CLI can also be upgraded through the `jx upgrade cli` command. The end result is the same, except that `jx upgrade cli` does not output all the versions, but directly updates only the CLI.

What matters, for now, is the `jenkins x platform` version from the output. In my case, it is `2.0.108`. If we take a look at the [jenkins-x-platform.yml](https://github.com/jenkins-x/jenkins-x-versions/blob/master/charts/jenkins-x/jenkins-x-platform.yml) file, we can see that quite a few versions of the platform were created in the mean time. At the time of this writing (May 2019), the current version is `2.0.330`. I am 22 versions behind. While that mind sound like a lot, it really isn't since Jenkins X has a very high frequency of releases, with most of the days releasing more than one.

So, what is the Jenkins X Platform? It is a bundle of quite a few applications already running in our cluster. If you are running static Jenkins X, Jenkins is one of the components of the platform. ChartMuseum is there, just as Nexus, Monocular, Docker Registry, and quite a few others. At this point you might think that Jenkins X platform is everything related to Jenkins X, but that would not be true. There are quite a few other apps installed as addons, extensions, apps, CRDs, and so on. We'll go through the process of upgrading them all, but, for now, we'll limit ourselves to the platform.

Let's take a quick look at the help of the `jx upgrade platform` command.

```bash
jx upgrade platform --help
```

The output shows us all the arguments we can set. That one that you should always be using is `-v` or `--version`. Even though most of the time you'll want to upgrade to the latest release, you should still specify the version. That way you can be sure that you'll upgrade production to the same version you'll test before that. Otherwise, Jenkins X community might make a new release of the platform after you created the test environment, and before you start the process of upgrading the production.

Nevertheless, we will not use the `--version` argument in the exercise that follows, simply because there are likely many new versions since the time of this writing. So, even though we'll skip `--version`, I expect you to use it when applying the exercises from this chapter in the "real" cluster. The same is true for all other `jx upgrade` commands we'll run later. The same holds true for `jx install` and `jx create cluster` commands. Using a specific version gives you control and better understanding of the problems when things go wrong.

I> Always use `--version` to install or upgrade Jenkins X components, even if the examples in this book at ignoring it.

let's see what we'll get when we upgrade the platform.

```bash
jx upgrade platform --batch-mode
```

TODO: Check `kubectl describe secret oauth-token` and confirm that it is not 0 bytes.

TODO: Confirm that `tide` is running

If you are already running the latest platform, you'll see a message stating notifying yuo that the command will skip the upgrade process. Otherwise, you'll see a detailed log with a long list of resources that were updated. It was an uneventful experience, so we can move on and check the versions one more time.

```bash
jx version
```

This time, my `jenkins x platform` version is `2.0.330` (yours will be different) thus confirming that the upgrade process was successfull.

```bash
# TODO: It does not upgrade anything. It's not really important and there's probably no need going through code to figure out whether there is a bug. Remove or add a text above.
jx upgrade binaries
```

There's much more to upgrades than keeping the platform up-to-date. We can, for example, upgrade addons. But, before we do that, let's take a look at which addons we are currently running in the cluster.

I> We did not yet explore addons. We'll do that in one of the next chapters. For now, please note that they provide, as their name suggest, additional functionalities.

```bash
jx get addons
```

The output will greatly depend on whether you are running static on serverless Jenkins X and whether you installed addons outside those coming through the "standard" installation. I can only assume that you did not install addons on your own given that we did not cover them just yet. If that's the case, you are likely going to see an empty list if you're using static Jenkins X, and a few instances of `jx-prow` and `tekton` if you prefer the serverless flavor.

In case of serverless Jenkins X, the output, without the repeated addons, is as follows.

```
NAME    CHART            ENABLED STATUS   VERSION
jx-prow jenkins-x/prow           DEPLOYED 0.0.620
...
tekton  jenkins-x/tekton         DEPLOYED 0.0.38
...
```

We can see that I'm running `jx-prow` version `0.0.647` and `tekton` version `0.0.38`. Which versions would we get if we upgrade those addons? We check it out easily by visiting the [jenkins-x/jenkins-x-versions](https://github.com/jenkins-x/jenkins-x-versions). If you do, open the *charts/jenkins-x* directory and select the file that represents one of the addons you're interested in. For example, opening [prow.yml](https://github.com/jenkins-x/jenkins-x-versions/blob/master/charts/jenkins-x/prow.yml) shows that, at the time of this writing, the current version is `0.0.647`.

Let's upgrade the addons.

I> You might not have any addons installed or those that you do have might be already at the latest version. If that's the case, feel free to skip the command that follows.

TODO: Wait until https://github.com/jenkins-x/jx/issues/3392 is resolved

```bash
# TODO: Add `--namespace` and check whether that solves the issue. If it does, add the argument to all the `upgrade` commands.
jx upgrade addons
```

You'll see a long log output with the list of things that changed and those that stay the same.

Let's see what we've got.

```bash
jx get addons
```

You might see some addons in the pending state. If they stay like that for a while longer, you might want to check whether all the Pods are running. If one or more are crashing, you something went wrong. If this would be a test cluster or a test instance of Jenkins X, you should abandon the idea to upgrade addons (or any other Jenkins X component type) and investigate what's wrong. Otherwise, that would be the time to restore a backup.

We could have upgraded single addon by adding the name to the command. For example, `jx upgrade addon tekton` would upgrade only that addon.

The same pattern can be followed with `app`, `crd`, and `extensions` upgrades. We haven't explored them just yet. When we do, you'll already know that they can be upgraded as well. Nevertheless, there should be no need to go through those as well since all you have to do is execute `jx upgrade`.

The last upgradable type of compoenents is `ingress`. But, unlike other `upgrade` types we explored, that one does much more than what you might have guessed.

## Upgrading Ingress Rules And Adding TLS Certificates

So far, all the applications we installed so far are accessible through a plain HTTP protocol. As I'm sure you're aware, that is not acceptable. All publicly accessible applications should be accessible through HTTPS only and that means that we need TLS certificates. We could generate them ourselves for each of the applications but that would be too much work. Instead, we'll try to figure out how to create and manage the certificates automatically. Fortunatelly, Jenkins X already solved that and quite a few other Ingress-related challenges. We just need to learn how to tell Jenkins X what exactly we need.

All the `jx upgrade` commands we explored so far followed the same pattern. They upgrade components to a specific or the latest release. Ingress is the exception. We can use can use`jx upgrade ingress` to change a variate of things. We can change the domain of the cluster or a namespace. We can add TLS certificates to all Ingress endpoints. We can also change the template Jenkins X is using to auto-generate addresses of applications.

Let's start by checking the applications we currently have in our cluster.

```bash 
jx get applications
```

The output is as follows.

```
APPLICATION  STAGING PODS URL
jx-go-demo-6 1.0.110 3/3  http://go-demo-6.cd-staging.35.243.230.195.nip.io
```

You already saw that output quite a few times before. There's notthing special about it, except that *go-demo-6* is accessible through auto-generated HTTP address. We must change that to HTTPS since no serious applications should be accessible without TLS. But, before we do that, let's confirm that our application can indeed be reached.

W> Make sure to replace `[...]` with the address from the staging `URL` column from the previous output before executing the commands that follow.

```bash
STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"
```

The output should show `hello, PR!` so we confirmed that the application is working and can be reached through insecure HTTP protocol. Feel free to send a request using `https` and you'll see that the output will state that there is `SSL certificate problem`.

So far, we used a `nip.io` domain for all our examples. That was useful for the exercises since it saved us from purchasing a "real" domain, from reconfiguring DNSes with our domain registrar, and from a long wait until changes are propagated. But, I'm sure that you alredy wondered how to make Jenkins x use a custom domain. When you start using it "for real", you will surely want Jenkins X and your applications to be accessible through your own domain, instead of `nip.io`. We'll try to remedy that as well.

So, we have three issues to solve. We should redirect all HTTP requests to HTTPS, we should make sure that SSL/TLS certificates are in place, and we should switch from `nip.io` to any domain we want to use. Further more, we should be able to make any of those changes on the level of the whole cluster, a Namespace, or an application. We'll start with cluster-wide changes.

Now you need to choose whether you'd like to use a "real" domain. If you do not have one available, or you do not want to mess with DNSes, you can continue using `nip.io` as a simulation of what would happen if we'd change a domain. In either case, first we need to find the IP of the cluster.

```bash
LB_IP=$(kubectl \
    --namespace kube-system \
    get svc jxing-nginx-ingress-controller \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo $LB_IP
```

The output of the latter command should be an IP.

Now comes the part where you need to choose whether to continue using `nip.io` or you'd like to switch to a "real" domain.

In case you do not have a fully qualified domain at hand, please execute the command that follows.

```bash
# If you do NOT have a domain
DOMAIN=$LB_IP.nip.io
```

If you do have a domain, please change your DNS records in your domain registrar to the IP of the cluster. It might take an hour or even two until DNS records are propagated so you'll need to wait for a while. This would be a good time to have a lunch, do some execise, or see a movie. But, before you go, please execute the command that follows.

W> Make sure to replace `[...]` with the domain you own and with DNSes that point to the cluster (e.g., play-with-jx.com).

```bash
# If do have a domain
DOMAIN=[...]
```

Next, we'll confirm that the new domain is accessible, at least from your laptop.

```bash
ping -c 1 $DOMAIN
```

I choose to continue using `nip.io`, so my output is as follows.

```
PING 35.243.230.195.nip.io (35.243.230.195): 56 data bytes
64 bytes from 35.243.230.195: icmp_seq=0 ttl=39 time=392.406 ms

--- 35.243.230.195.nip.io ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 392.406/392.406/392.406/0.000 ms
```

If in your case there is an error in the output, that probably means that DNS changes did not yet reach you. If, on the other hand, you are using a custom domain and you can ping tthe domain, that does not necessarily mean that the updated records are propagated everywhere. The safest bet is to wait for at least an hour since you changed DNS entries.

Now we're ready to upgrade Ingress. We'll change the domain (if you're using `nip.io` it'll stay the same) across the whole cluster.

```bash
jx upgrade ingress \
    --cluster true \
    --domain $DOMAIN
```

It'll take a while until the upgrade is finished, and we'll have to answer a few questions since, this time, we did not specify `--batch-mode`.

First, we're asked to `confirm to delete all and recreate` Ingress rules. Please stick with the default value not only for this question, but for all others. This time, the default value is `Y`.

Next, we are asked whether we want to expose `Ingress` or `Routes`. Unless you're using OpenShift, `Ingress` is the correct (and the default) answer.

Next, we are asked to define the domain. Since we already specified it through the `--domain` argument, the default it is already predefined and we can simply press the enter key.

Now comes the key question. `Would you like to enable cluster wide TLS?`. Again, the default answer is correct. Who wouldn't want TLS if it comes at no additional cost?

TODO: Continue text

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

## Pull Requests And DevPods

TODO: Code

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