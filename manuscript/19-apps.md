# Managing Third-Party Applications {#apps}

W> The examples in this chapter should work with any Jenkins X (static and serverless), installed in any way (`jx create cluster`, `jx install`, Boot), and inside any Kubernetes flavor. That being said, as you will see later, some of the commands and instructions will be different depending on the installation type. More importantly, the outcome will differ significantly depending on whether you installed Jenkins X using the Boot or through `jx create cluster` or `jx install` commands.

So far, in most cases, our clusters had only Jenkins X. Few exceptions were the cases when we added Knative as a way to showcase its integration with Jenkins X for serverless deployments. Also, we added Istio and Flagger while we were exploring progressive delivery. Those were the only examples of system-wide third-party applications. We installed them using `jx create addon` commands, and we run those commands more or less "blindly". We did not discuss whether that was a good way to install what we needed because that was not the focus at the time.

In the "real world" scenario, your cluster will contain many other third-party applications and platforms that you'll have to manage somehow. Assuming that I managed to imprint into your consciousness the need to operate under GitOps principles, you will store the definitions of those additional applications in Git. You will make sure that Git triggers webhooks to the cluster so that pipelines can converge the actual into the desired state. To accomplish that, you'll likely store the information in the declarative format, preferably YAML.

Now that we refreshed our memory on the goals we're trying to accomplish, we can start discussing how to achieve them. How can we manage third-party applications without abandoning the principles on which we're building processes around the life-cycle of our applications and the system as a whole? If we manage to figure out how to manage system-wide third-party applications, everything inside our cluster will be fully automated and reproducible. That's the last piece of the puzzle.

Our applications (e.g., *go-demo-6*) and its direct dependencies (e.g., MongoDB) are managed by pipelines triggered by webhooks created whenever we push something to one of our Git repositories. Jenkins X itself is installed and managed by the Boot, which is yet another Jenkins X pipeline that uses definitions stored in Git.

I> Truth be told, you might not yet be using the Boot if it does not support your Kubernetes flavor. But, if that's the case, you will be using it later.

If Jenkins X and our applications and their direct third-party dependencies are managed by pipelines and adhere to the GitOps principles, the only thing we're missing is system-wide third-party applications. If we add them to the mix, the circle will close, and we'll be in full control of everything happening inside our clusters. We could also store cluster definitions in Git and automate its maintenance through pipelines, but, as I mentioned before, that is and will continue being out of the scope of the book. We're focused only on what is happening after a Kubernetes cluster is created.

Now that I repeated a few times the words "system-wide third-party" applications, it might help to clarify what I mean by that. I said "cluster-wide" because I'm referring to applications that are not directly related to one of those we're developing. As an example, a database associated with a single application does not fall into that category. We already saw how to treat those through examples with MongoDB associated with *go-demo-6*. As a refresher, all we have to do is add that application as a dependency in `requirements.yaml` inside the repository of our application.

The group we're interested in (system-wide third-party applications) contains those either used by multiple applications we're developing or those that provide benefits to the whole cluster. An example of the former could as well be a database that various applications of ours would use. On the other hand, an example of the latter would be, for example, Prometheus, which collects metrics from across the whole system, or Istio, which provides advanced networking capabilities to all those who choose to use it. All in all, system-wide third-party applications are those used by or providing services to the system as a whole or a part of it and are not directly related to any single application.

Now that I mentioned databases, Prometheus, and Istio as examples, I should probably commit to them as well. We'll use those to explore different techniques on how to manage system-wide third-party applications. As you will see soon, there is more than one way to tackle that challenge, and each might have its pros and cons or be used in specific situations.

That was enough of a pep talk. Let's jump into examples that will illustrate things much better than theory. As always, we need a cluster with Jenkins X before we proceed.

## Creating A Kubernetes Cluster With Jenkins X

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Kubernetes cluster with Jenkins X.

I> All the commands from this chapter are available in the [19-apps.sh](https://gist.github.com/422c42cf08eaf9df0e8d18f1dc93a0bd) Gist.

For your convenience, the Gists with different cluster creation and Jenkins X installation combinations are provided below. Choose one that best fits your needs and run it as-is, or modify it to fit your use-case. Alternatively, feel free to create a cluster and install Jenkins X in any other way. At this point, you should be able to install Jenkins X, not the way I tell you, but in the way that best fits your situation, so Gists might not be needed at all. Nevertheless, they are here just in case. What matters is that you have a cluster with Jenkins X up-and-running.

* Create a new serverless **GKE** cluster created **with the Boot**: [gke-jx-boot.sh](https://gist.github.com/1eff2069aa68c4aee29c35b94dd9467f)
* Create a new serverless **EKS** cluster created **without the Boot**: [eks-jx-serverless.sh](https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd)
* Create a new serverless **AKS** cluster created **without the Boot**: [aks-jx-serverless.sh](https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410)
* Use an **existing** serverless cluster created **without the Boot**: [install-serverless.sh](https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037)

Now we are ready to talk about installing, validating, and managing third-party applications.

## Managing Application-Specific Dependencies

Some third-party applications are used by a single application developed in-house. We already saw at least one such case in action when we used *go-demo-6*. It depends on Mongo DB. Given that the relation is one-on-one, the database is used by a single application. Other applications that might potentially need to access the data in that DB would need to go through *go-demo-6* API. That is the preferable model today. Using shared databases introduces too many problems and severely impacts our ability to iterate fast and deploy improvements only to a part of the system. That is especially evident in the microservices architecture.

One of the main characteristics of the microservices architecture is that they must be deployable independently from the rest of the system. If they would share the database with other applications, such independence would not be possible or be severely limited. For that reason, we moved to the model where an application is self-sufficient and contains all its dependencies. In such a scenario where a database and other dependencies are directly related to a single in-house application, the most logical and the most efficient place to define those dependencies is the repository of the application in question. Assuming that we are using Helm to package and deploy our applications, the dependencies are defined in `requirements.yaml`.

![Figure 19-1: Self-sufficient applications with exclusive dependencies](images/ch19/app-dependencies.png)

In the diagram 19-1, each application has its own database or any other dependency. Everything that belongs to or is related to an application is defined in the same repository. So, if we have three applications, we would have three repositories. If each of those applications has a database, it would be defined in the repository of the application that has it as the dependency.

Following the diagram, we can see that both App 1 and App 3 need to access the data from the same database (DB 1). Given that only App 1 can communicate with it directly, App 3 needs to go through App 1 API to retrieve from or write data to DB 1.

Such an approach allows us to have a separate team in charge of each of those applications. Those teams can deliver releases at their own speed without the fear that their work will affect others and without waiting for others to finish their parts. If we change anything in the repository of an application, those changes will be deployed as a preview environment. If we approve the pull request, a new release will be deployed to all permanent environments with the promotion set to *auto* (e.g., staging), and we'll be able to test the change inside the system and together with the other applications in it. When we're happy with the result, we can promote that specific version of the application to production or to any other environment with the promotion set to manual. In that case, it does not matter whether we change the code of our application, a configuration file, or a dependency like a database. Everything related to that application is deployed to one environment or another. Testing becomes easier while providing the mechanism to deliver responsive, scalable, highly-available, and fault-tolerant applications at a rapid pace.

**To summarize, third-party applications that are used exclusively by a single in-house application should be defined in the repository of that application.**

I do not believe that there is a reason to revisit the subject of defining exclusive (direct) dependencies. We went through it quite a few times, and, in case you are of a forgetful nature, you can refresh your memory by exploring `/charts/go-demo-6/requirements.yaml` file inside the repository that hosts *go-demo-6*. After all, this chapter is about installation and maintenance of system-wide third-party applications. Those that we are discussing now are not used by the system as a whole, but by a single application. Nevertheless, I through that you do need a refresher of how we manage such dependencies given that everything else we'll discuss is based on the same principles of dependency management, even though the techniques will vary.

Let's jump into the cases that we did not discuss just yet in detail.

## Managing Third-Party Applications Through Permanent Environments

Imagine a scenario in which we have multiple applications using the same shared database. While I prefer the model in which a database is not shared, such a situation is all too common. Even if each application does have its own DB, the chances are that there will be some shared dependency. Maybe all your applications will publish events to the same queue. Or perhaps they will all use Redis to store cache. In most cases, there is always at least one shared dependency, and we need to figure out how to deal with such situations.

Let's expand on the previous example that contained three applications, each with its own DB. How would we define three additional apps if they would share the same database? To be more precise, where would we store the information about that DB?

It pretty clear that the code of each application and its exclusive dependencies should be in a separate repository to facilitate independence of the teams working on them as well as deployments. So, following the before-mentioned example, we would end up with six repositories for six applications. What is problematic is where to define the shared database.

![Figure 19-2: Combining self-sufficient applications with those using shared third-party apps](images/ch19/app-dependencies-shared.png)

What we might be missing is the fact that each environment has its own Git repository. Unlike the repositories of the applications that contain code, configuration files, tests, and everything else related to them, environment repos contain only the references to the releases that should be running in those environments (Namespaces). Truth be told, there are other files in  those repositories (e.g., pipeline definitions, Makefile, etc.), but they are not crucial for the point I'm trying to make.

Each application running in an environment is specified in the `requirements.yaml` file. If that's a reference to a release of our application, that release will be running in the environment. If that release has its own dependencies, they will run as well.

Here comes the important bit. If environment repositories contain references to some releases, nothing is telling us that those releases should be done by us. It could be, for example, a release of PostgreSQL created by the community, or anyone else. Typically, only a fraction of what's running in our clusters was developed by us. Much of it is releases created by others. Right now, you are running a specific release of Kubernetes. On top of it is Jenkins X, which happens to be a bundle that includes many other third-party applications. Tomorrow you might add Istio, Prometheus, Grafana, and many other third-party applications. All those need to be specified somewhere and stored in Git if we are to continue following the GitOps principles. However, for now, we're focused on those that are directly used by our applications but not exclusively owned by any single one of them.

Given that everything is a release done by someone (us, a community, a vendor, etc.) and that a Git repository associated with an environment is a collection of references to those releases, it stands to reason that all we have to do is add shared third-party dependencies to those repos. The good news is that we already know how to do that, even though we might not have done it for such a specific purpose.

![Figure 19-3: The whole environment defined in a Git repository](images/ch19/app-dependencies-shared-env.png)

Let's say that we have several applications that will all use a shared PostgreSQL and that, for now, we're focused on running those applications in staging. How would we do that?

The first step is to clone the staging environment repository. Given that we have quite a few variations of Jenkins X setup and I cannot be sure which one you chose, the address of the staging environment repo will differ. So, the first thing we'll do is define a variable that contains the environment prefix.

W> Please replace `[...]` in the command that follows with `jx-boot` if you used **Jenkins X Boot** to install Jenkins X. If that's not the case, use `jx-rocks` if you're running **static Jenkins X**, and `tekton` if it's **serverless**.

```bash
ENVIRONMENT=[...]
```

To be on the safe side, we'll remove the local copy of the repository just in case it is a left-over from previous chapters.

```bash
rm -rf environment-$ENVIRONMENT-staging
```

Now we can clone the repo.

W> Please replace `[...]` with your GitHub user in the commands that follow.

```bash
GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-$ENVIRONMENT-staging.git

cd environment-$ENVIRONMENT-staging
```

We cloned the repository and entered into the local copy.

Now let's take a look at the dependencies of our staging environment.

```bash
cat env/requirements.yaml
```

The output will differ depending on whether you created a new cluster for this chapter or you reused one from before. As a minimum, you should see two `exposecontroller` entries used by Jenkins X internally to create Ingress resources with dynamically created domains. You might see other entries as well, depending on whether there is something currently running in your staging environment.

Ignoring what is currently defined as the `dependencies` of our staging environment, what matters is that the `requirements.yaml` file is where everything related to that environment is defined. Since it is set to auto promotion, whenever we push something to the master branch of any of the repositories with our applications, the result will be a new entry in that file. Or, if that application is already running in staging, the process will modify the `version`. That's what Jenkins X gives us out of the box, and it served us well. But now we're facing a different challenge. How can we add an application to staging that is not directly related to any single application we're developing? As you might have guessed, the solution is relatively simple.

Let's say that a few of our applications need to use PostgreSQL as a shared database. Given that we know that `requirements.yaml` contains the information of all the applications in that environment (namespace), all we have to do is add it as yet another entry.

If you Google "Helm PostgreSQL", the first result (excluding ads) will likely reveal that it is one of the charts in the official repository and that it is considered stable. That makes it easy. All we have to do is find the name of the chart (`postgresql`) and the release we want to use. We can see from *Chart.yaml* what the `version` of the latest release is. For our exercise, we'll use `5.0.0` even though the latest stable version is likely higher. This is not the production setup but rather an exercise, and it does not really matter which version we're running.

All in all, we'll add another entry to the `requirements.yaml` file.

```bash
echo "- name: postgresql
  version: 5.0.0
  repository: https://kubernetes-charts.storage.googleapis.com" \
    | tee -a env/requirements.yaml
```

All that's left is to push the changes to GitHub. From there on, a webhook will notify Jenkins X that there is a change which, in turn, will create a new pipeline activity that will converge the actual into the desired state of the staging environment.

```bash
git add .

git commit -m "Added PostgreSQL"

git push

jx get activities \
    --filter environment-$ENVIRONMENT-staging \
    --watch
```

Once the activity is finished, the output of the activity should show that the status of all the steps is set to `succeeded`, and you can press *ctrl+c* to stop watching.

Let's see what we got.

```bash
NAMESPACE=$(kubectl config view \
    --minify \
    --output 'jsonpath={..namespace}')

kubectl \
    --namespace $NAMESPACE-staging \
    get pods,services
```

We retrieved the current Namespace (remember that it differs from one setup to another) and used that information to construct the Namespace where the staging environment is running. After that, we retrieved all the Pods and the Services. The output should be similar to the one that follows.

```
NAME                READY STATUS  RESTARTS AGE
pod/jx-postgresql-0 1/1   Running 0        7m9s

NAME                           TYPE      CLUSTER-IP    EXTERNAL-IP PORT(S)  AGE
service/jx-postgresql          ClusterIP 10.23.240.243 <none>      5432/TCP 7m9s
service/jx-postgresql-headless ClusterIP None          <none>      5432/TCP 7m9s
```

In your case, the output might be bigger and contain other Pods and Services. If that's the case, ignore everything that does not contain `postgresql` as part of the name.

We can see that we installed a specific release of PostgreSQL into the staging environment by adding a single entry to the `requirements.yaml` file. From now on, all the applications that should query or write data to this shared database can do so. Given that this is staging and not production, we can also experiment with what would happen if, for example, we change the version or any other aspect of it. That's what the staging environment is for. It allows us to test changes before applying them to production. It does not really matter whether those changes are related directly to our applications or to some of the third-party apps.

One thing that we did not do is customize PostgreSQL by changing one or more of its chart values. In the "real world" situation, we would likely not run PostgreSQL as-is, but tweak it to fit our needs. But, this is not the "real world", so we'll skip customizing it assuming that you are familiar with how Helm values work. Instead, we'll assume that the default setup is just what we need in staging.

Using environment repositories to define non-exclusive dependencies of our applications has apparent benefits like automation through pipelines, change history through Git, reviews through pull requests (even though we skipped that part), and so on. Those are the same benefits that we saw countless times before throughout this book. What matters is that we have environment repositories to specify what should run in the associated Namespaces, no matter whether that's our application or one released by others. The key is that environment repositories are a great place to define applications that should run in a specific Namespace and are not used exclusively by a single application, but shared by many.

As you'll see later, there might be a better way to define applications that are not directly related to those we're developing. For now, we'll focus on the task at hand.

Now that PostgreSQL is running in staging, we can safely assume that it should be running in production as well. We need it in each permanent environment so that applications that need it can access it. So, let's add it to production as well.

```bash
cd ..

rm -rf environment-$ENVIRONMENT-production

git clone \
    https://github.com/$GH_USER/environment-$ENVIRONMENT-production.git

cd environment-$ENVIRONMENT-production
```

Just as with staging, we deleted the local copy (leftover) of the production environment (if there was any). Then we cloned the repository, and entered inside the newly-created directory.

Next, we'll add PostgreSQL to `requirements.yaml` just as we did for staging.

```bash
echo "- name: postgresql
  version: 5.0.0
  repository: https://kubernetes-charts.storage.googleapis.com" \
    | tee -a env/requirements.yaml
```

If we'd push the changes right away, Jenkins X would create a pipeline activity, and, soon after, PostgreSQL would run in production as well. That might compel you to ask, "why do we want to have the same thing defined twice?" "Why not keep it in the same repository, whichever it is?"

The truth is that even if an application is exactly the same in staging and production (or any other environment), sooner or later we will want to make a change to, for example, staging, test it, and apply the changes to production only if we're satisfied with the results. So, no matter whether PostgreSQL in those two environments is the same most of the time or only occasionally, sooner or later, we'll change some value or upgrade it, and that needs to be tested first.

There is another reason why it should run in at least two environments. Data usually needs to be different. More often than not, we do not run all the tests against production data. Some? Maybe. All? Never.

Anyways, there is yet another reason for having it in two repositories matching different environments (besides tweaking, testing, and upgrading). Unless you have money to waste, you will not run the same scale in staging as in production. The former is often limited to a single replica, or maybe a few for the sake of testing data replication. The production, on the other hand, can be any scale and is often much bigger. Even if both staging and production are using the same number of replicas, resource requests and limits are almost certainly going to differ. Production data needs more memory and CPU than the one used for testing.

No matter how much your setup differs (if at all), we'll imagine that our production needs to have more replicas. If for no other reason, that will allow me to refresh your memory about chart values.

All in all, we'll enable replication (scale) in production and leave staging running as a single replica database.

To enable replication, we need to figure out which values we should change. So, the next step is to `inspect values`.

```bash
helm inspect values stable/postgresql
```

The output, limited to the relevant parts, is as follows.

```yaml
...
replication:
  enabled: false
...
```

So, if we need replication in production, we need to set `replication.enabled` to `true`. That's easy. We'll just add it to `env/values.yaml`. There are already a few values there which I'll leave you exploring alone. We'll add those related to `postgresql` at the bottom by using `tee` with the argument `-a` (short for append).

```bash
echo "postgresql:
  replication:
    enabled: true" \
    | tee -a env/values.yaml
```

Now that both the dependency and its values are defined, we can push the changes to GitHub and wait until Jenkins X does the job.

```bash
git add .

git commit -m "Added PostgreSQL"

git push

jx get activities \
    --filter environment-$ENVIRONMENT-production \
    --watch
```

Please wait until the newly created activity is finished executing and press *ctrl+c* to stop watching it.

Now comes the moment of truth. Was PostgreSQL deployed? Is it replicated? I'm sure that you know that the answer is yes, but we'll check it anyways.

```bash
kubectl \
    --namespace $NAMESPACE-production \
    get pods,services
```

The output is as follows.

```
NAME                       READY STATUS  RESTARTS AGE
pod/jx-postgresql-master-0 1/1   Running 0        51s
pod/jx-postgresql-slave-0  1/1   Running 0        51s

NAME                           TYPE      CLUSTER-IP     EXTERNAL-IP PORT(S)  AGE
service/jx-postgresql          ClusterIP 10.100.242.238 <none>      5432/TCP 51s
service/jx-postgresql-headless ClusterIP None           <none>      5432/TCP 51s
service/jx-postgresql-read     ClusterIP 10.100.45.32   <none>      5432/TCP 51s
```

We can see by looking at the Pods that now we have two (`master` and `slave`). PostgreSQL was indeed deployed, and it is replicated, so adding it as a dependency and defining its values worked as expected.

That's it. There's not much more we can say about adding third-party applications to repositories associated with permanent environments. You already saw how they worked before, and this section made sure that you know that you can use them not only to promote your applications but also to add those released by others (third-party).

Before we move on, we'll remove PostgreSQL from both environments. That will demonstrate how to remove an application from an environment. But, you probably already know that. The more important reason we'll remove them lies in me being cheap. We will not need PostgreSQL any more, and I don't want you to use more resources in your cluster than necessary.

If we'd like to remove one of our (in-house) applications from a permanent environment, all we have to do is execute `jx delete application`. However, that won't work with PostgreSQL since it is not an application with a lifecycle managed by Jenkins X. Only quickstarts (`jx create quickstart`) and those we import (`jx import`) are considered Jenkins X applications. Still, knowing what `jx delete application` does should give us a clue what we can do without that command.

When we execute `jx delete application`, that command iterates through the repositories and removes the application entry from `jx-requirements.yaml`. In cases (like this one), when `jx delete application` is not an option, we can do the same operation ourselves.

Now, I could tell you to open `env/requirements.yaml` in your favorite editor and delete the `postgresql` entry. But, since I'm freak about automation and given that it is the last entry in that file, we'll accomplish the same with `sed`.

```bash
cat env/requirements.yaml \
    | sed '$d' | sed '$d' | sed '$d' \
    | tee env/requirements.yaml
```

The `sed '$d'` command removes the last line from an input. Since `postgresql` contains three lines, we repeated it three times, and we stored the result in `env/requirements.yaml`. The output of the command should show that `postgresql` is gone.

Please note that we did not remove the associated values, but only the dependency. While that might produce some confusion to those exploring `env/values.yaml`, it is perfectly valid to leave `postgresql` in there. What truly matters is that it was removed as a dependency. If you feel like being pedantic, remove the values as well.

With the dependency gone, we can push the change to GitHub.

```bash
git add .

git commit -m "Removed PostgreSQL"

git push
```

We'll let Jenkins X take care of removing it from the production environment, while we turn our attention to staging.

```bash
cd ../environment-$ENVIRONMENT-staging

cat env/requirements.yaml \
    | sed '$d' | sed '$d' | sed '$d' \
    | tee env/requirements.yaml

git add .

git commit -m "Removed PostgreSQL"

git push
```

That's it. PostgreSQL was removed as a dependency from both production and staging repositories, and Jenkins X is running activities that will remove it from the cluster as well. Feel free to monitor those activities and to check the Pods in those Namespaces if you'd like to confirm that they were indeed removed. I'll leave that to you.

When should we use the repositories associated with permanent environments to define third-party applications?

One obvious use case for using the technique we just explored is for **applications that must run in those Namespaces but are not exclusively used by a single application of ours**. A typical example would be a shared database, but there can be many others. Generally speaking, whenever you need a third-party application that is used by at least two applications of yours, repositories associated with permanent environments are the right choice. But that's not all. In some cases, you'll have system-level third-party applications that are not directly used by any of your applications. Jenkins X would be one example, but we'll leave it aside from this discussion.

An example of an application that might benefit from being managed through environment repos is Prometheus. It collects metrics from across the whole cluster, but it is not a dependency of any one application. We could define it in the same way as we defined PostgreSQL. Depending on the level of confidence, we might want to run it only in production, or in staging as well. If we choose the latter, we would have a safe way to test new releases of Prometheus and promote them to production only if we are satisfied with the outcome of validations. We could choose to keep it in staging always, or only while testing new releases. No rule says that all the applications need to be always defined in all the environment repositories. All in all, **permanent environments are the right place for any type of third-party applications that need to exist in multiple environments, even for a short while**.

How about Istio? We cannot run it in both staging and production. There can be only one Istio installation per cluster. The same goes for many other applications, Knative being the first one that comes to my mind. In those cases, you might choose to define such applications only in the production repository. However, you would not be able to test new releases. If testing is a must (as it should be), you'd need to spin up a new cluster to test such applications like Istio and Knative. If you do create a separate cluster, you could define an environment that would point to that cluster, but that's not the subject we explored, so we'll ignore that option (for now) and I'll assume that you are either not testing new releases of cluster-wide applications that do not live exclusively in a single Namespace, or that you are using a separate cluster for that.

In any case, if you do have an application that cannot run multiple instances in the same cluster, you can define it in a single environment. But there's more to come, and soon I'll argue that those cases are better managed differently, at least for some of you.

Before we move on, let's go out of the local copy of the staging repository. We won't need it anymore.

```bash
cd ..
```

## Managing Third-Party Applications Running In The Development Environment

W> The examples in this sub-chapter work only if you installed the platform using **Jenkins X Boot**. If that's not the case, you might skip to the next section. But, before you jump, please consider reading what's in this sub-chapter. It might motivate you to switch to Jenkins X Boot, even if that means waiting for a while until the support for your favorite Kubernetes flavor comes along.

We saw a few ways to deal with third-party applications. But, so far, we did not touch any of those installed with Jenkins X Boot. As a matter of fact, we did not yet explore how they came into being. All we know is that the `dev` environment is running some applications, just as staging and production are running others. However, the knowledge that something is running is not good enough. We might need to be able to choose what is running there. We might want to remove some components or to change their behavior.

We'll start from the beginning and take a quick look at what we're currently running in our development environment.

```bash
kubectl get pods
```

The output will not show you anything new. Those are the same components that we've been using countless times before. They are all applications that form the Jenkins X bundle. So, why am I showing you something you already saw quite a few times?

All the components that are currently running in the development environment were installed as dependencies defined in `requirements.yaml`. Let's take a look at what's defined there right now.

W> Please replace `[...]` with the name of your cluster. If you used the gist to install Jenkins X using the Boot, the variable `CLUSTER_NAME` is already defined, and you can skip the first command from those that follow.

```bash
CLUSTER_NAME=[...]

cd environment-$CLUSTER_NAME-dev

cat env/requirements.yaml
```

We entered into the local copy of the `dev` repository and retrieved the contents of `env/requirements.yaml`. The output of the last command is as follows.

```yaml
dependencies:
- name: jxboot-resources
  repository: http://chartmuseum.jenkins-x.io
- alias: tekton
  name: tekton
  repository: http://chartmuseum.jenkins-x.io
- alias: prow
  condition: prow.enabled
  name: prow
  repository: http://chartmuseum.jenkins-x.io
- alias: lighthouse
  condition: lighthouse.enabled
  name: lighthouse
  repository: http://chartmuseum.jenkins-x.io
- name: jenkins-x-platform
  repository: http://chartmuseum.jenkins-x.io
```

We can see that there are a few dependencies. There are `jxboot-resources`, `tekton`, `prow`, `lighthouse`, and `jenkins-x-platform`. If you take another look at the Pods, you'll notice that there is a mismatch. For example, there is no trace of `lighthouse` (whatever it is). On the other hand, we can see that Nexus is running even though it is not defined as a dependency. How can that be?

The fact that we have some dependencies defined does not necessarily mean that they are enabled. That is the case with `lighthouse`. It is defined as a dependency, but it is not enabled. Given that those dependencies are Helm charts, we can only guess that there is a file with values in which `lighthouse` is disabled. We'll explore soon where exactly is that value coming from.

As for Nexus, it is a sub-dependency of `jenkins-x-platform`. Just like `lighthouse`, it was enabled, and we can disable it if we choose to do so. It is only wasting resources since we won't use it in our examples, so disabling it will be our next objective. Through it, we'll have an opportunity to get more familiar with Jenkins X Boot environment and, in particular, with what's inside the `env` directory.

For now, what matters is that the `dev` repository used by Jenkins X Boot acts similarly as permanent repositories like staging and production. In both cases, there is a `requirements.yaml` file that defines the dependencies that are running in the associated Namespace. So, it stands to reason that if we want to change something in the development workspace, all we have to do is modify that file. However, as you will see later, Jenkins X Boot extends Helm's capabilities and adds a few new tricks to the mix.

For now, before we start tweaking Jenkins X setup, let's confirm that Nexus is indeed running.

```bash
kubectl get ingresses
```

The output is as follows.

```
NAME             HOSTS                               ADDRESS       PORTS AGE
chartmuseum      chartmuseum-jx.35.229.41.106.nip.io 35.229.41.106 80    23m
deck             deck-jx.35.229.41.106.nip.io        35.229.41.106 80    23m
hook             hook-jx.35.229.41.106.nip.io        35.229.41.106 80    23m
jx-vault-jx-boot vault-jx.35.229.41.106.nip.io       35.229.41.106 80    27m
nexus            nexus-jx.35.229.41.106.nip.io       35.229.41.106 80    23m
tide             tide-jx.35.229.41.106.nip.io        35.229.41.106 80    23m
```

As you can see, one of the Ingress resources is called `nexus`. Let's open it in a browser.

```bash
NEXUS_ADDR=$(kubectl get ingress nexus \
    --output jsonpath="{.spec.rules[0].host}")

open "http://$NEXUS_ADDR"
```

You should see the Nexus home screen in your browser. It is indeed running, so let's see how we can remove it.

```bash
git pull

ls -1 env
```

We pulled the latest version of the repo and retrieved the list of files and directories inside the `env` folder. The output is as follows.

```
Chart.yaml
Makefile
controllerbuild
controllerteam
controllerworkflow
docker-registry
jenkins
jenkins-x-platform
jxboot-resources
lighthouse
nexus
parameters.schema.json
parameters.tmpl.schema.json
parameters.yaml
prow
requirements.yaml
tekton
templates
values.tmpl.yaml
```

We can see that quite a few components are represented as directories inside `env`. You are probably familiar with most (if not all) of them. Since we are interested in Nexus or, to be more precise, in its removal, we should take a look inside the `env/nexus` directory. Given that Nexus is not defined separately in `env/requirements.yaml`, but it is part of the `jenkins-x-platform` dependency, there must be a value we can use to disable it. So, let's take a look at what's inside `env/nexus/values.yaml`.

```bash
cat env/nexus/values.yaml
```

The output is as follows.

```yaml
enabled: true
```

If you are familiar with Helm, this is probably the moment you got confused. If the dependencies are defined in `env/requirements.yaml`, only `env/values.yaml` should be the valid place Helm would use in search of customization values. Helm ignores `values.yaml` in any other location. Therefore, it stands to reason that `env/nexus/values.yaml` would be ignored and that setting `enabled` to `false` in that file would accomplish nothing. On the other hand, you can rest assured that the file is not there by accident.

Jenkins X Boot extends Helm client capabilities in a few ways. In the context of values, it allows nested files. Instead of cramming `env/values.yaml` with deep-nested entries for all the applications, it allows us to use additional `values.yaml` files inside subdirectories. If we go back to the `env/nexus` directory, there is `values.yaml` file inside. At runtime, `jx` will read that and all other nested files and convert the values inside them into those expected by Helm.

On top of that, we can also use `values.tmpl.yaml` files both in `env` as well as inside any of the product directories. That is also one of the Jenkins X additions to Helm. Inside `values.tmpl.yaml` we can use Go/Helm templates. That is used heavily by Jenkins X to construct values based on secrets, but it can be used by you as well. Feel free to explore files with that name if you'd like to get more familiar with it.

All in all, we can define all values in `env/values.yaml`, or split them into separate files placed inside directories corresponding with dependencies. The files can be named `values.yaml` and hold only the values, or they can be `values.tmpl.yaml`, in which case they can use templating as well.

Going back to the task at hand... We want to remove Nexus, so we'll modify the `env/nexus/values.yaml` file.

This is the moment we'd create a new branch and start making changes there. Later on, we'd create a pull request and, once it's merged to master, it would converge the actual into the desired state. But, in the interest of brevity, we'll work directly on the master branch. Don't take that as a recommendation, but rather as a way to avoid doing things that are not directly related to the subject at hand.

```bash
cat env/nexus/values.yaml \
    | sed -e \
    's@enabled: true@enabled: false@g' \
    | tee env/nexus/values.yaml
```

We output the contents of `env/nexus/values.yaml`, changed the value of `enabled` to `false`, and stored the output back to `env/nexus/values.yaml`.

All that's left now is to let Jenkins X Boot do the work. We just need to initiate the process, and there are two ways to do that.

We can push changes to Git. That is the preferable way given that it complies with the GitOps principles. But, you might not be able to do that.

Webhook initiated pipeline associated with the `dev` repository works only if we're using Vault to store secrets. Otherwise, Jenkins X would not have all the information (passwords, API tokens) since they exist only on your laptop. So, the commands that follow will differ depending on whether you're using Vault or local storage for secrets. In the latter case, pushing to Git will not accomplish anything, and you'll have to execute `jx boot` from your laptop.

W> Please run the commands that follow only if you are using Vault to store secrets. If that's not the case, execute the `jx boot` command instead. I'll skip this warning from now on and assume that you'll run `jx boot` locally whenever you see the commands that push the changes to the `dev` environment.

```bash
git add .

git commit -m "Removed Nexus"

git push

jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch
```

We pushed the changes to Git and watched the activities to confirm that the pipeline run was executed correctly. Once it's done, press *ctrl+c* to stop watching.

Let's take a quick look at Ingresses and see whether Nexus is still there.

```bash
kubectl get ingresses
```

The output, limited to the relevant parts, is as follows.

```
NAME  HOSTS                         ADDRESS       PORTS AGE
...
nexus nexus-jx.35.229.41.106.nip.io 35.229.41.106 80    33m
...
```

Ingress is still there. Does that mean that Nexus was not removed? Let's check it out.

```bash
open "http://$NEXUS_ADDR"
```

Nexus does not open in a browser. It was indeed removed, but Ingress is still there. Why is that?

Ingress is not part of the chart that deployed Nexus. It could have been if we added a few additional arguments to `values.yaml`. If we did that, it would be removed as well. But we let Jenkins X create Ingress for us instead of defining it explicitly, just as it does for other applications. Since only the components that were defined in the chart were removed, Ingress is still there. However, that's not an issue. Ingress definitions are not using almost any resources. What matters is that everything else (Pods included) was removed. Nexus (except Ingress) is no more. If having Ingress bothers you, you can remove it separately.

I just said that everything (except Ingress) was removed. But you might not trust me, so let's confirm that's indeed true.

```bash
kubectl get pods
```

You will see all the Pods running in the `dev` Namespace. However, what you see does not matter. What matters, in this context, is what's not in front of you. There is no Nexus, so we can conclude that it is gone for good or, at least, until we change our mind and enable it by modifying `env/nexus/values.yaml` again.

So, when should we use Jenkins X Boot `dev` repository to control third-party applications by modifying what's inside the `env` directory? The answer, based on what we learned so far, is simple. **Change values in the `env` directory of the `dev` repo when you want to choose which components of Jenkins X platform to use**. You can tweak them further by adding the standard Helm chart values of those components inside `values.yaml` or `values.tmpl.yaml` files.

As an alternative, you could even disable those components (e.g., Nexus) in the `dev` repository and define them yourself in, for example, the `production` repo. However, in most cases, that would not yield any benefits but only introduce additional complications given that those components are often tweaked to work well inside Jenkins X.

So far, we saw that we can define third-party applications as direct and exclusive dependencies of our apps, that we can manage them through the repositories associated with permanent environments (e.g., staging and production), and that we can control them through the `env` directory in the `dev` repository used by Jenkins X Boot. But, there's more, and we did not yet finish exploring the options. We are going to talk about Jenkins X Apps.

## Managing Third-Party Applications As Jenkins X Apps

Jenkins X supports something called `apps`, which are a cause for a lot of confusion, so I'll start by making sure that you understand that `apps` and `applications` are not the same things. In the English language, `app` is an acronym of `application`, and many think (or thought) that in Jenkins X they are the same thing, just as repositories and repos are the same. But that's not the case, so let's set the record straight.

Jenkins X `applications` are those that you imported into the system, or you created as quickstarts. Those are your applications that are managed by Jenkins X. The `apps`, on the other hand, are Jenkins X extensions. They are a replacement for what is known as Jenkins X addons, and that might create even more confusion, so let's clarify that as well. Jenkins X `addons` are set to be deprecated in not so far future and will be replaced with `apps`. Even though both `addons` and `apps` are used to extend the components running inside the cluster, `apps` provide more features. We'll explore them next. For now, remember that `applications` and `apps` are different things and that `addons` will be (or already are) deprecated in favor of `apps`.

Jenkins X Apps are a way to install and maintain Helm charts in Jenkins X. Some of those charts are maintained by the Jenkins X community. However, who maintains the charts does not matter since we can convert any Helm chart into Jenkins X app. Now, if that's all that Jenkins X Apps are, there would be no good reason to use them. But there is more. Helm charts are only the base or, to be more precise, a mechanism to define applications. On top of Helm's standard features, Jenkins X Apps add a few more things that might help us simplify management of third-party applications.

Jenkins X Apps add the following capabilities on top of those you're already familiar with.

* The ability to interactively ask questions to generate values.yaml based on JSON Schema
* The ability to create pull requests against the GitOps repo that manages your team/cluster
* The ability to store secrets in Vault
* The ability to upgrade all apps to the latest version

At the time of this writing (October 2019), the following features are in the pipeline and are expected to be released sometime in the future.

* Integrating Kustomize to allow existing charts to be modified
* Storing Helm repository credentials in Vault
* Taking existing `values.yaml` as defaults when asking questions based on JSON Schema during app upgrade
* Only asking new questions during app upgrade
* The ability to list all apps that can be installed
* Integration for bash completion

We'll explore some, if not all, of those features soon. For now, let's take a quick look at the apps currently maintained by Jenkins X community.

```bash
open "https://github.com/jenkins-x-apps"
```

As you can see, there are quite a few Apps available. But don't get too excited just yet. Most of those are ports of Jenkins X Addons that do not fully leverage the concepts and features of the Apps. For now (October 2019), the "real" Apps are yet to come, and the most anticipated one is Jenkins X UI. We'll explore the UI in one of the next chapters, mostly because it is not yet public at the time I'm writing this. But it's coming...

So, we'll explore a better integration with Apps when we go through Jenkins X UI. For now, I only want to give you a taste, so we'll pick a random one to experiment with. Given that I'm in love with Prometheus, we'll use that one. So, let's take a quick look at what's inside the `jx-app-prometheus` App.

If you open the `jx-app-prometheus` repository, you'll see that it has the `jenkins-x.yml` file that defines the pipeline that will be executed as part of adding or modifying that App. Further on, inside the directory `jx-app-prometheus` (the same as the name of the repo), you'll see that there is a Helm chart. The `requirements.yaml` file inside it defines `prometheus` as a dependency.

Judging by the contents of the repo, we can conclude that an App is a combination of a pipeline and a Helm chart that defines the application as a dependency.

Let's see it in action.

```bash
jx add app jx-app-prometheus
```

The outcome of that command will vary greatly depending on how you installed Jenkins X. We'll comment later on how that affects your decisions whether to use the Jenkins X Apps or not. For now, we're only going to observe the outcome and maybe perform one or two additional actions.

If you did **NOT use Jenkins X Boot** to set up the platform, you'll get a message stating that it `successfully installed jx-app-prometheus 0.0.3`. That's it. There's nothing else left for you to do but wait until Prometheus is up-and-running. If you are NOT using Jenkins X Boot and you know that you never will, you can just as well skip the rest of the explanation. But that would be a mistake. I'm sure that, sooner or later, you will switch to the Boot process for installing and maintaining Jenkins X. That might not be today if, for example, your Kubernetes flavor is not supported, but it will be later. So, I strongly suggest you keep reading even if you won't be able to observe the same outcome from your system.

If you are **using Jenkins X Boot** and if your secrets are **stored in Vault**, the output should be similar to the one that follows.

```
Read credentials for http://chartmuseum.jenkins-x.io from vault helm/repos
Created Pull Request: https://github.com/vfarcic/environment-jx-boot-dev/pull/21
Added app via Pull Request https://github.com/vfarcic/environment-jx-boot-dev/pull/21
```

Instead of just installing the App, as we're used to with Jenkins X Addons, the system did a series of actions. It retrieved the credentials from Vault. More importantly, it created a pull request and placed the information about the new App inside it. In other words, it did not install anything just yet. Instead, by creating a PR, it gave us an opportunity to review the changes and choose whether we want to proceed or not.

Please open the pull request link in your browser and click the *Files changed* tab. You'll see that a few files were created or modified. We'll start at the top.

The first in line is the *env/jx-app-prometheus/README.MD* file. Jenkins X created it and stored the README through which we can get the humanly-readable information about the App we want to add to the system. Prometheus README does not seem to be very descriptive, so we'll skip over it. Later on, you'll see how README files can be much more expressive than that.

The next in line is *env/jx-app-prometheus/templates/app.yaml*. Unlike the README that does not serve any purpose but to provide information to other humans, the *app.yaml* file does serve a particular objective inside the cluster. It defines a new Kubernetes resource called `App`. That, as you probably already know, does not exist in the default Kubernetes setup. Instead, it is one of the custom resources (CRDs) created by Jenkins X.

While `App` definitions can get complex, especially if there are many values and customizations involved, this one is relatively simple. It defines the repository of the chart (`jenkins.io/chart-repository`) and the name (`jenkins.io/app-name`) and the version (`jenkins.io/app-version`) of the App. Those are used by the system to know which Helm chart to install or update, and where to get it.

The two files we explored so far are located in the *env/jx-app-prometheus* directory. That follows the same logic as what we observed with Nexus. Each App is defined in its own directory that matches the name of the App. But those definitions are useless by themselves. The system needs to know which Apps we do want to run, and which are only defined but shouldn't be running at all. The file that ties it all together is *env/requirements.yaml*, which happens to be the file that was modified by the pull request.

If we take a look at the changes in *env/requirements.yaml*, we'll see that `jx-app-prometheus` was added together with the `repository` where the chart is stored as well as the `version` which we'd like to use.

Now, let's say that we finished reviewing the proposed changes and that we'd like to proceed with the process. Following the logic we used many times before, if we want to change the state of our cluster, we need to push or, in this case, merge the changes to the master branch. That's what we'll do next.

Please click the *Conversation* tab to get back to where we started. Assuming that you do indeed want to run Prometheus, click the *Merge pull request*, followed by the *Confirm Merge* button.

Once we merged the pull request, GitHub triggered a webhook that notified Jenkins X that there is a change. As a result, it created a new pipeline activity. Let's monitor it to confirm that it executed successfully.

```bash
jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch
```

Press *ctrl+c* when the activity is finished.

I> This is the part that will be the same no matter whether you use Jenkins X Boot or not.

Let's take a look at the Pods to confirm that Prometheus is indeed running.

```bash
kubectl get pods \
    --selector app=prometheus
```

The output is as follows.

```
NAME                                        READY   STATUS    RESTARTS   AGE
jenkins-x-prometheus-alertmanager-...       2/2     Running   0          16m
jenkins-x-prometheus-kube-state-metrics-... 1/1     Running   0          16m
jenkins-x-prometheus-node-exporter-...      1/1     Running   0          16m
jenkins-x-prometheus-node-exporter-...      1/1     Running   0          16m
jenkins-x-prometheus-node-exporter-...      1/1     Running   0          16m
jenkins-x-prometheus-pushgateway-...        1/1     Running   0          16m
jenkins-x-prometheus-server-...             2/2     Running   0          16m
```

The end result is the same no matter whether `jx add app` applied the chart directly, or it created a pull request. In both cases, Prometheus is up-and-running. However, the end result is not all that matters. The road often matters as much as the destination. Adding Jenkins X Apps without a `dev` repository used by Jenkins X Boot is not better than if we executed `helm apply`. In both cases, it would be a single command that changed the state of the cluster without storing the information in Git, without allowing us to review the changes, and so on and so forth. It's not much more than an ad-hoc command that lacks all the things we deem important in GitOps, and it does not have an associated, repeatable, and automated pipeline.

On the other hand, executing `jx add app` on top of Jenkins X installed with the Boot provides all the steps that allow us to continue following GitOps principles. It stored the information about the new app in an idempotent declarative format (YAML). It created a branch with the required changes, and it created a pull request. It allowed us to review the changes and choose whether to proceed or abort. It is recorded and reproducible, and it runs through a fully automated pipeline or, to be more precise, as part of the `dev` pipeline.

All that's left is to discover Prometheus' address and open it in browser to confirm that it is indeed accessible.

```bash
kubectl get ingresses
```

The output will differ depending on which Jenkins X flavor you're running (static or serverless) and whether you have other applications running in that Namespace. Still, no matter which Ingress resources are in front of you, they all have one thing in common. There is no Prometheus.

If you ever applied the Prometheus Helm chart, you probably know that Ingress is disabled by default. That means that we need to set a variable (or two) to enable it. That will give us an excellent opportunity to explore how we can tweak Jenkins X Apps. As long as you remember that they are Helm charts (on steroids), all you have to do it explore the available variables and choose which ones you'd like to customize. In our case, we need to enable Ingress and provide at least one host. We could as well add labels to the Service that would tell Jenkins X that it should create Ingress automatically. But we'll go with the first option and enable Ingress explicitly.

Given that you likely did not associate the cluster with a "real" domain, the first step is to find the IP of the cluster. With it, we'll be able to construct a `nip.io` domain.

Unfortunately, the way how to discover the IP differs depending on whether you're using EKS or some other type of the Kubernetes cluster.

W> Please execute the command that follows if you are **NOT running EKS**.

```bash
LB_IP=$(kubectl --namespace kube-system \
    get service jxing-nginx-ingress-controller \
    --output jsonpath="{.status.loadBalancer.ingress[0].ip}")
```

W> Please execute the command that follows if you are **running EKS**.

```bash
LB_HOST=$(kubectl --namespace kube-system \
    get service jxing-nginx-ingress-controller \
    --output jsonpath="{.status.loadBalancer.ingress[0].hostname}")

export LB_IP="$(dig +short $LB_HOST \
    | tail -n 1)"
```

Next, we'll output the load balancer IP to confirm whether we retrieved it correctly.

```bash
echo $LB_IP
```

The output should be an IP.

Now we need to get back to the differences between creating Jenkins X Apps with and without the `dev` repository.

If you did **not install Jenkins X using the Boot** and the platform definition is **not stored in the `dev` repo**, just add Ingress any way you like. Do not even bother trying to use YAML files or to extend the Prometheus Helm chart. That train has left the station the moment you executed `jx add app`. It was yet another undocumented command. As a matter of fact, do not use `jx add app` at all. If you're not yet convinced, I'll provide more arguments later. In any case, just as before, what follows next does not apply to you if you do not have the `dev` repository.

Now, if you do **use the `dev` repo** and you did **install the platform using Jenkins X Boot**, you should continue specifying everything in Git repositories. We already discussed how each app is in its own directory and how they are (extended) Helm charts. That means that we can simply add standard Helm `values.yaml` file and, in it, specify that we want to enable Ingress and which host it should respond to.

I'll save you from discovering the exact syntax of Prometheus Helm chart values by providing the command that defines what we need. But, before we do that, we'll pull the latest version of the `dev` repo. Remember that a pull request was created and merged to the master and that we do not have that latest version on our laptop.

```bash
git pull
```

Now let's get back to the values we need.

```bash
echo "prometheus:
  server:
    ingress:
      enabled: true
      hosts:
      - prometheus.$LB_IP.nip.io" \
    | tee env/jx-app-prometheus/values.yaml
```

We should probably create a new branch, create a pull request, review it, and merge it. However, given that you already know all that and that there is no need to rehearse it again, we'll push the change directly to the master branch.

```bash
git add .

git commit -m "Prometheus Ingress"

git push

jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch
```

We pushed the changes to Git, and we started watching the activities to confirm that the process finished successfully. Once it's done, press *ctrl+c* to stop watching.

Did we get Ingress? Let's check it out.

```bash
kubectl get ingresses
```

The output should show that now we have, among others, Prometheus Ingress, and we should be able to access it from outside the cluster.

```bash
open "http://prometheus.$LB_IP.nip.io"
```

It works. We can see the Prometheus UI.

Now, we do not really need Prometheus. I used it only to demonstrate how to add one of the Apps defined by Jenkins X community. Since we won't use Prometheus in the rest of the exercises and since I'm committed not to waste resources without a good reason, we'll remove the Prometheus App we just added. Besides being cheap, that will also allow us to see how we can remove Apps and the process behind such destructive operations.

If you do NOT have the `dev` repository (if you did not use Jenkins X Boot to install the cluster), you'll have to specify the Namespace where the App is running. Otherwise, the system will assume that it is always in the `jx` Namespace.

W> Please execute the command that follows only if you used **Jenkins X Boot**, and you do have the `dev` repository.

```bash
jx delete app jx-app-prometheus
```

W> Please execute the command that follows only if you did **NOT use Jenkins X Boot**, and you do NOT have the `dev` repository.

```bash
jx delete app jx-app-prometheus \
    --namespace $NAMESPACE
```

W> If you see `fatal: cherry-pick failed` errors, remove the local copy of the environment by executing `rm -rf ~/.jx/environments` and repeat the `jx delete app` command. It's a bug that will hopefully be fixed soon.

If you did **NOT use Jenkins X Boot**, GitOps principles do not apply to App, and all the associated resources were deleted right away. They were created without storing anything in Git, and now they were deleted in the same way.

On the other hand, if you did **use Jenkins X Boot**, the process for deleting an App is the same as for adding it. The system created a new branch, changed a few files, and created a new pull request. It's up to us to review it and decide whether to merge it to master. So, let's do just that.

If you're using the `dev` repository, please open the link to the newly created pull request and click the *Files changed* tab to review the proposed modifications. You'll see that the only file modified is *env/requirements.yaml*. The command removed the `jx-app-prometheus` dependency. It left the rest of the changes introduced by adding the App just in case we decide to add it back again. Those will be ignored since the dependency is removed.

Assuming that you are happy with the changes (they are simple after all), please select the *Conversation* tab, and click *Merge pull request*, followed by the *Confirm Merge* button. As always, that will trigger a webhook that will notify Jenkins X that there is a change in one of the repositories it manages. As a result, yet another pipeline activity will start, and we can watch the progress with the command that follows.

```bash
jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch
```

Please press *ctrl+c* once the activity is finished.

No matter how you installed Jenkins X and whether you do or you don't have the `dev` repository, the end result is the same. Prometheus was removed from the cluster, and we can confirm that by listing all the Pods with the `app=prometheus` label.

```bash
kubectl get pods \
    --selector app=prometheus
```

The output should show that `no resources` were `found.` Prometheus is no more.

## Using Any Helm Chart As A Jenkins X App

We saw that we can add an App that was created by the Jenkins X community. Be it as it may, most of the third-party applications you'll need do not exist as Jenkins X Apps. Or, to be more precise, are not the Apps maintained by the community. That might lead you to think that the Apps have very limited usefulness, but that would not be true. I did not yet tell you that any Helm chart can become an App. All we have to do is specify the repository where that chart is stored.

Let's say that we'd like to install Istio. You might be compelled to use the [jx-app-istio  App](https://github.com/jenkins-x-apps/jx-app-istio), but that might not be the best idea, besides running a demo and wanting to set it up fast and without much thinking. A much better approach would be to use the "official" chart maintained by the Istio community. So, that's what we'll do next. It will be an opportunity to see how any chart can be converted into a Jenkins X App.

If you read [Istio documentation](https://istio.io/docs/setup/install/helm/), you'll discover that two charts need to be installed; `istio-init` and `istio`. You'll also find out that the repository where the charts are stored is available from *https://storage.googleapis.com/istio-release/releases/1.3.2/charts/*. Given than one Jenkins X App references one Helm chart, we'll need to add two Apps; one for `istio-init` and the other for `istio`. Equipped with that knowledge, we can add the first of the two Apps. The command is as follows.

```bash
jx add app istio-init \
    --repository https://storage.googleapis.com/istio-release/releases/1.3.2/charts/
```

Just as before, the output of that command will differ depending on whether you used Jenkins X Boot with the `dev` repo, or you didn't.

If you **do NOT have the `dev` repo**, the command will install the App directly inside the cluster. We already discussed briefly that such a practice is a bad idea (it's not GitOps). Just in case you skipped it, I will reiterate my previous statement. **If you did not use Jenkins X Boot to install the platform and you do not have the `dev` repository, do NOT use Jenkins X Apps, unless you have to (e.g., for Jenkins X UI).** Instead, add third-party applications as dependencies to the repository associated with the production (or any other) environment. The only reason I'm showing you the Apps is so that you don't feel left behind.

If you **do have the `dev` repo**, the process for adding an App based on a Helm chart is no different than when adding one of the Apps maintained by the Jenkins X community.

You should see the link to the newly created pull request. Open it and click the *Files changed* tab so that we review the suggested changes.

By adding `istio-init`, the same files changed as with Prometheus, except that two (of three) are in different directories.

The `env/istio-init/README.MD` file contains information about the App and the whole README from the original chart. Next, we have `env/istio-init/templates/app.yaml` that is the definition of the App, with the information about the repository `jenkins.io/chart-repository`, the name of the chart (`jenkins.io/app-name`), and the version(`jenkins.io/app-version`). Finally, `istio-init` was added together with other dependencies in `env/requirements.yaml`.

As you can see, it does not matter much whether an App was added from the catalog of those supported by the Jenkins X community, or from any available Helm chart. In all the cases, it is based on a Helm chart, and as long as Jenkins X has the information about the name, version, and the repository where the chart resides, it will convert it into an App.

To finish the process, please select the *Conversation* tab, and click *Merge pull request*, followed with the *Confirm Merge* button. As you already know, that will trigger a webhook that will notify the cluster that there is a change in one of the repositories and, as a result, a new pipeline activity will be created.

```bash
jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch
```

Press *ctrl+c* to stop watching the activity once it is successfully finished.

Finally, we'll confirm that `istio-init` was installed correctly by outputting the Custom Resource Definitions (CRDs) that contain `istio.io` in their name. If you're not familiar with Istio, all that `istio-init` does is install those CRDs. The rest of the setup comes afterward.

```bash
kubectl get crds | grep 'istio.io'
```

Unless Istio changed since the time I wrote this (October 2019), there should be twenty-three CRDs in the output, and we can conclude that the first part of the Istio setup was done correctly.

That's it. You saw how you can create Jenkins X Apps through the `jx add app` command. We also explored how those Apps can be updated or removed. If you're using the `dev` repository, you saw some of the benefits of the Apps, mainly their support for GitOps processes. Every time an App is added or removed, `jx` creates a new branch and a pull request, and it waits for you to review and approve the changes by merging it to the master.

In some cases, however, you might want to skip reviewing and merging pull requests. You might want to let Jenkins X do that for you, as well. In such cases, you can add the `--auto-merge` argument.

I> The `--auto-merge` argument might not work due to the [issues 5761](https://github.com/jenkins-x/jx/issues/5761). Feel free to monitor it to see whether it was resolved.

You should understand that `jx add app` and `jx delete app` commands are only manipulating files in the `dev` repository and pushing them to Git. Everything else is done by Jenkins X running in the cluster. That means that you do not have to use those commands. Think of them more as "helpers" than as requirements for working with Apps. We can accomplish the same without them. We can create the files we need and push them to Git. As a result, a new App will be added without us executing any command (excluding `git`).

We still need to apply the second chart (`istio`), so we'll use that as an excuse to try to add an App without executing `jx` commands.

W> I did not even bother adapting the commands that follow for those **not using the `dev` repository**. We already concluded that the Apps based on charts not maintained by the Jenkins X community are not worth the trouble. If you did not install your cluster using Jenkins X Boot, you'll be better of adding dependencies to the repositories associated with the permanent environments (e.g., staging and production). As a matter of fact, you'd be better of even with an ad-hoc `helm apply` command.

Since we are about to create and modify a few files in the local copy of the `dev` repository, we should start by pulling the latest codebase from GitHub.

```bash
git pull
```

Now that we have a local copy of the latest version of the repository, we can create a new App. Remember, this time, we're exploring how to do that by creating the files ourselves instead of using the `jx add app` command.

We can approach this challenge from two directions. One option could be to create all the files from scratch. The other is to copy a directory of one of the existing Apps and modify it to suit our needs. We'll go with the second option since it is probably an easier one. Given that we already have the App that's using `istio-init`, its files are probably the best candidate to be used as the base for `istio`.

```bash
cp -r env/istio-init env/istio
```

Now that we copied the `istio-init` directory as `istio`, all we have to do is change a few files. We'll skip modifying the README. It is important only for humans (we might read it), but it plays no role in the process. In the "real world" situations, I'd expect you to change it as well. But since this is not the "real world" but rather a learning experience, there's no need for us to spend time with it.

There are three files that we might need to change. We might create `env/istio/templates/values.yaml` if we'd like to change any of the chart's default values. We'll skip that one because `istio` is good as-is. Instead, we'll focus on the other two files.

```bash
cat env/istio/templates/app.yaml
```

That's the definition of the App we're about to add to the cluster. It is a copy of `istio-init`, so all we need to do is change the `jenkins.io/app-name` and `name` values from `istio-init` to `istio`. We'll also change `jenkins.io/chart-description`. It serves only informative purposes. But, since we're nice people and don't want to confuse others, changing it might provide additional clarity to whoever might explore it later.

The command that should make those changes is as follows.

```bash
cat env/istio/templates/app.yaml \
    | sed -e 's@istio-init@istio@g' \
    | sed -e \
    's@initialize Istio CRDs@install Istio@g' \
    | tee env/istio/templates/app.yaml
```

The definition of an App is useless by itself. Its existence will not result in it running inside the cluster. We need to add it as yet another dependency in `env/requirements.yaml`. So, let's take a quick peek at what's inside it.

```bash
cat env/requirements.yaml
```

The output is a follows.

```yaml
dependencies:
- name: jxboot-resources
  repository: http://chartmuseum.jenkins-x.io
- alias: tekton
  name: tekton
  repository: http://chartmuseum.jenkins-x.io
- alias: prow
  condition: prow.enabled
  name: prow
  repository: http://chartmuseum.jenkins-x.io
- alias: lighthouse
  condition: lighthouse.enabled
  name: lighthouse
  repository: http://chartmuseum.jenkins-x.io
- name: jenkins-x-platform
  repository: http://chartmuseum.jenkins-x.io
- name: istio-init
  repository: https://storage.googleapis.com/istio-release/releases/1.3.2/charts/
  version: 1.3.2
```

All but the last dependency are those of the system at its default configuration. Later on, we used `jx add app` to add `istio-init` to the mix. Now we're missing an entry for `istio` as well. The `repository` and the `version` are the same, and the only difference is in the `name`.

```bash
echo "- name: istio
  repository: https://storage.googleapis.com/istio-release/releases/1.3.2/charts/
  version: 1.3.2" \
  | tee -a env/requirements.yaml
```

All that's left is to push the changes to GitHub and let the system converge the actual into the desired state, which we just extended with an additional App. Normally, we'd create a branch, push the changes there, create a pull request, and merge it to the master branch. That would be the correct way to handle this or any other change. But, in the interest of time, we'll skip that with the assumption that you already know how to create PRs. If you don't, you're in the wrong industry.

```bash
git add .

git commit -m "Added Istio"

git push

jx get activity \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch
```

We committed and pushed the changes to the master branch and started watching the activities to confirm that the changes are applied to the cluster. Once the new activity is finished, please press *ctrl+c* to stop watching.

Istio should be fully up-and-running. We can confirm that by listing all the Pods that contain `istio` in their names.

```bash
kubectl get pods | grep istio
```

This is neither the time nor the place to dive deeper into Istio. That was not the goal. I used it only as an example of different ways to add Jenkins X Apps to the system.

Speaking of the Apps, let's see which ones are currently running in the cluster. You already saw that `jx` has a helper command for almost anything, so it should be no surprise to find out that retrieving the `apps` is available as well.

```bash
jx get apps
```

The output is as follows, at least for those who installed Jenkins X using the Boot.

```
Name       Version Chart Repository                                                    Namespace Status               Description
istio-init 1.3.2   https://storage.googleapis.com/istio-release/releases/1.3.2/charts/           READY FOR DEPLOYMENT Helm chart to initialize Istio CRDs
istio      1.3.2   https://storage.googleapis.com/istio-release/releases/1.3.2/charts/           READY FOR DEPLOYMENT Helm chart to install Istio
```

That's it. We explored a few commonly used ways to add, manage, and delete Jenkins X Apps. We'll have a short discussion around them soon. For now, we'll remove `istio` and `istio-init` since we do not need them anymore.

```bash
git pull

jx delete app istio
```

You know what to do next. Merge the PR so that the change (`istio` removal) is applied to the system. We can see that through the proposed changes to the `env/requirements.yaml` file.

You'll notice that the `jx delete app` command works no matter whether the App was added through `jx add app` or by fiddling with the files directly in Git. It always operates through Git (unless you are NOT using the `dev` repo).

The next in line for elimination is `istio-init`, and the process is the same.

W> If you added the App without the `dev` repository created by Jenkins X Boot, you'll need to add the `--namespace $NAMESPACE` argument to the command that follows.

```bash
git pull

jx delete app istio-init
```

I'll leave you to do the rest yourself (if you're using the Boot). Merge that PR!

That's it. You learned the basics of extending the Jenkins X platform by adding Apps. As a matter of fact, it's not only about extending Jenkins X but more about having a reliable way to add any third-party application to your cluster. However, not all are equally well suited to be Jenkins X Apps.

Jenkins X Apps are beneficial for at least two scenarios. **When we want to extend Jenkins X, adding Apps is, without a doubt, the best option.** We'll explore that later on (in one of the next chapters) when we dive into Jenkins X UI. Given that the Apps can be any Helm chart, we can convert any application to be an App.

Besides those designed to extend Jenkins X, excellent candidates are the charts that do not need to be in multiple repositories. For example, if we'd like to run two instances of Prometheus (one for testing and the other for production), we're better of adding them to the associated permanent environment repositories. However, many are not well suited to run in testing or are not worth validating. Prometheus might be such a case. If we upgrade it and that turns out to be a bad choice, no harm will be done to the cluster. We might not be able to retrieve some metrics, but that would be only temporary until we roll back to the previous version. The exception would be if we hook HorizontalPodAutoscaler to Prometheus metrics, in which case testing it before deploying a new version to production is paramount. So, **when applications should run only in production (without a second instance used for testing), Apps are a better way to manage them due to a few additional benefits they provide.**

At the core, Jenkins X Apps follow the same GitOps principles as any other. Their definitions are stored in Git, we can create pull requests and review changes, and only a merge to the master branch will change the state of the cluster. Using Apps is not much different from defining dependencies in staging, production, or any other permanent environment repository. What makes them "special" is the addition of a few helper features and a few conventions that make management easier. We have a better-defined pipeline. Branches and pull requests are created automatically. Secrets are stored in Vault. Dependencies are better organized. And so on, and so forth. We explored only a few of those features. Later on, we'll see a few more in action, and the community is bound to add more over time.

The previous two paragraphs make sense only if you used Jenkins X Boot to install the platform and if there is the `dev` repository. If that's not the case, Jenkins X Apps do not provide almost any benefits, outside those defined by the community (e.g., UI). Do not even think about using the Apps to install Prometheus, Istio, or any other application available as a Helm chart. A much better strategy is to modify the repositories associated with permanent environments (e.g., staging, production). That way, definitions will be stored in Git repos. Otherwise, `jx add app` is yet another helpful command that results in action that did not pass through Git.

## Which Method For Installing and Managing Third-Party Applications Should We Use?

We saw a few ways how we can install and manage third-party applications inside our clusters. Having more than one choice can be confusing, so let's try to summarize some kind of rules you can use as guidelines towards making a decision. But, before we do that, let's repeat the rule to rule them all. **Do not make any modification to the state of a cluster without pushing a change to a Git repository.** That means that executing `jx add app` is not a good idea if you do not have the repository associated with the `dev` environment. The same rule applies to any other command that changes the state of the cluster without storing the information about the change in a Git repository. In other words, Git should be the only actor that can change the state of your cluster.

Now that we reiterated the importance of following the GitOps principles and excluded Jenkins X Apps without the `dev` repository from the equation, we can go over the rules.

1. A third-party application that is a dependency of a **single in-house application** should be defined in **the repository of that application**.
2. A third-party application that is a dependency of **multiple in-house applications** and might need to **run in multiple environments** (e.g., staging, production) should be defined in **repositories associated with those environments**.
3. A third-party application that is a dependency of **multiple in-house applications** and **does NOT need to run in multiple environments** should be defined as an **App stored in the `dev` repository**.
4. A third-party application that is **used by the system as a whole**, and that **does not need to run in multiple environments** should be defined as an **App stored in the `dev` repository**.

That's it. There are only four rules that matter when thinking where to define third-party applications. However, sometimes, it is easier to remember examples instead of rules, so I'll provide one for each.

An example of the **first rule** is a database used by a single application. Define it in the repo of that application.

An example of the **second rule** is a database used by multiple applications. Define it in all the repositories associated with permanent environments where you run those applications (e.g., staging, production).

An example of the **third rule** is Prometheus that often runs in a single environment and with no in-house application to depend on it. Define it as a Jenkins X App in the `dev` repository.

An example of the **fourth rule** is Istio that is a cluster-wide third-party application or, to be more precise, a system (Kubernetes) component. Define it as a Jenkins X App in the `dev` repository.

## What Now?

You know what comes next. You can delete the cluster and take a break, or you can jump right into the next chapter if there is any.

If you used `jx boot` to create a cluster, you are currently inside the local copy of the `dev` repository, so we'll have to go out of it.

```bash
cd ..
```

Next, we'll delete all the repositories used in this chapter, except for `dev` that can be reused.

```bash
rm -rf environment-$ENVIRONMENT-staging

hub delete -y \
    $GH_USER/environment-$ENVIRONMENT-staging

rm -rf environment-$ENVIRONMENT-production

hub delete -y \
    $GH_USER/environment-$ENVIRONMENT-production
```

Finally, delete the cluster. You can find the instructions at the end of the Gist you used at the beginning of the chapter. They are near the bottom.
