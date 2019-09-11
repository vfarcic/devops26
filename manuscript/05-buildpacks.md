# Creating Custom Build Packs

I stand by my claim that "you do not need to understand Kubernetes to **use Jenkins X**." To be more precise, those who do not want to know Kubernetes and its ecosystem in detail can benefit from Jenkins X ability to simplify the processes around software development lifecycle. That's the promise or, at least, one of the driving ideas behind the project. Nevertheless, for that goal to reach as wide of an audience as possible, we need a variety of build packs. The more we have, the more use cases can be covered with a single `jx import` or `jx quickstart` command. The problem is that there is an infinite number of types of applications and combinations we might have. Not all can be covered with community-based packs. No matter how much effort the community puts into creating build packs, they will always be a fraction of what we might need. That's where you come in.

The fact that Jenkins X build packs cannot fully cover all our use cases does not mean that we shouldn't work on reducing the gap. Some of our applications will have a perfect match with one of the build packs. Others will require only slight modifications. Still, no matter how many packs we create, there will always be a case when the gap between what we need and what build packs offer is more significant.

Given the diversity in languages and frameworks we use to develop our applications, it is hard to avoid the need for understanding how to create new build packs. Those who want to expand the available build packs need to know at least basics behind Helm and a few other tools. Still, that does not mean that everyone needs to possess that knowledge. What we do not want is for different teams to reinvent the wheel and we do not wish for every developer to spend endless hours trying to figure out all the details behind the ever-growing Kubernetes ecosystem. It would be a waste of time for everyone to go through steps of importing their applications into Jenkins X, only to discover that they need to perform a set of changes to adapt the result to their own needs.

Our next mission is to streamline the process of importing projects for all those teams in charge of applications that share some common design choices and yet do not have a build pack that matches all their needs.

We'll explore how to create a custom build pack that could be highly beneficial for a (fictional) company. We'll imagine that there are multiple applications written in Go that depend on MongoDB and that there is a high probability that new ones based on the same stack will be created in the future. We'll explore how to create such a build pack with the least possible effort. 

We'll need to make a decision what should be included in the build pack, and what should be left to developers (owners of an application) to add after importing their applications or after creating new ones through Jenkins X quickstart. Finally, we'll need to brainstorm whether the result of our work might be useful to others outside of our organization, or whether what we did is helpful only to our teams. If we conclude that the fruits of our work are useful to the community, we should contribute back by creating a pull request.

To do all that, we'll continue using the *go-demo-6* application since we are already familiar with it and since we already went through the exercise of discovering which changes are required to the `go` build pack.

## Creating A Kubernetes Cluster With Jenkins X

As in the previous chapters, we'll need a cluster with Jenkins X up-and-running. That means that you can continue using the cluster from the previous chapter if you did not destroy it. Otherwise, you'll need to create a new cluster or install Jenkins X if you already have one. 

I> All the commands from this chapter are available in the [05-buildpacks.sh](https://gist.github.com/f95cfb9c5c5ea07dce684866ab3df665) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

Let's get started.

## Choosing What To Include In A Build Pack

We might be tempted to create build packs that contemplate all the variations present in our applications. That is often a bad idea. Build packs should provide everything we need, within reason. Or, to be more precise, they should provide the things that are repeatable across projects, but they should not contemplate so many combinations that build packs themselves would become hard to maintain, and complicated to use. Simplicity is the key, without sacrificing fulfillment of our needs. When in doubt, it is often better to create a new build pack than to extend an existing one by adding endless `if/else` statements.

If we take the *go-demo-6* application as an example, we can assume that other projects are written in Go and that use MongoDB. Even if that's not the case right now, that is such a common combination that we can guess that someone will create a similar application in the future. Even if that is not true within our organization, surely there are many other teams doing something similar. The popularity of Go is on the constant rise, and MongoDB is one of the most popular databases. There must be many using that combination. All in all, a build pack for an application written in Go and with MongoDB as a backend is potentially an excellent candidate both for the internal use within our organization, as well as a contribution to the Jenkins X community.

MongoDB was not the only thing that we had to add when we imported *go-demo-6* based on the `go` template. We also had to change the `probePath` value from `/` to `/demo/hello?health=true`. Should we add that to the build pack? The answer is no. It is highly unlikely that a similar application from a different team will use the same path for health checks. We should leave that part outside of the soon-to-create build pack and let it continue having root as the default path. We'll let the developers, those that will use our build pack, modify the `values.yaml` file after importing their project to Jenkins X. It will be up to them to design their applications to use the root path for health checks or to choose to change it by modifying `values.yaml` after they import their projects.

All in all, we'll keep `probePath` value intact, even though our *go-demo-6* application will have to change it. That part of the app is unique, and others are not likely to have the same value.

## Creating A Build Pack For Go Applications With MongoDB Datastore

We are going to create a build pack that will facilitate the development and delivery of applications written in Go and with MongoDB as datastore. Given that there is already a pack for applications written in Go (without the DB), the easiest way to create what we need is by extending it. We'll make a copy of the `go` build pack and add the things we're missing.

The community-based packs are located in *~/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes*. Or, to be more precise, that's where those used with *Kubernetes Workloads* types are stored. Should we make a copy of the local `packs/go` directory? If we did that, our new pack would be available only on our laptop, and we would need to zip it and send it to others if they are to benefit from it. Since we are engineers, we should know better. All code goes to Git and build packs are not an exception.

If right now you are muttering to yourself something like "I don't use Go, I don't care", just remember that the same principles apply if you use a different build pack as the base that will be extended to suit your needs. Think of this as a learning experience that can be applied to any build pack.

We'll fork the repository with community build packs. That way, we'll store our new pack safely to our repo. If we choose to, we'll be able to make a pull request back to where we forked it from, and we'll be able to tell Jenkins X to add that repository as the source of build packs. For now, we'll concentrate on forking the repository.

```bash
open "https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes"
```

Please fork the repository by clicking the *Fork* button located in the top-right corner of the screen and follow the on-screen instructions.

Next, we'll clone the newly forked repo.

W> If you moved into this chapter straight after you finished reading the previous, you might still be in the local clone of the *go-demo-6* repository. If that's the case, please go one directory back before cloning `jenkins-x-kubernetes`. Please execute `cd ..` first.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
GH_USER=[...]

git clone https://github.com/$GH_USER/jenkins-x-kubernetes

cd jenkins-x-kubernetes
```

We cloned the newly forked repository and entered inside it.

Let's see what we got inside the `packs` directory.

```bash
ls -1 packs
```

The output is as follows.

```
D
appserver
csharp
dropwizard
environment
go
gradle
imports.yaml
javascript
liberty
maven
maven-java11
php
python
ruby
rust
scala
swift
typescript
```

As you can see, those directories reflect the same choices as those presented to us when creating a Jenkins X quickstart or when importing existing projects.

I> If you see `go-mongodb` in the list of directories, the [pull request](https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/pull/22) I made a while ago was accepted and merged to the main repository. Since we are practicing, using it would be cheating. Therefore, ignore its existence. I made sure that the name of the directory we'll use (`go-mongo`) is different from the one I submitted in the PR (`go-mongodb`). That way, there will be no conflicts.

Let's take a quick look at the `go` directory.

```bash
ls -1 packs/go
```

The output is as follows.

```
Dockerfile
Makefile
charts
pipeline.yaml
preview
skaffold.yaml
watch.sh
```

Those are the files Jenkins X uses to configure all the tools involved in the process that ultimately results in the deployment of a new release. We won't dive into them just now. Instead, we'll concentrate on the `charts` directory that contains the Helm chart that defines everything related to installation and updates of an application. I'll let you explore it on your own. If you're familiar with Helm, it should take you only a few minutes to understand the files it contains.

Since we'll use `go` build pack as our baseline, our next step is to copy it.

```bash
cp -R packs/go packs/go-mongo
```

The first thing we'll do is to add environment variable `DB` to the `charts/templates/deployment.yaml` file. Its purpose is to provide our application with the address of the database. That might not be your preferred way of retrieving the address so you might come up with a different solution for your applications. Nevertheless, it's my application we're using for this exercise, and that's what it needs.

I won't tell you to open your favorite editor and insert the changes. Instead, we'll accomplish the same result with a bit of `sed` magic.

```bash
cat packs/go-mongo/charts/templates/deployment.yaml \
    | sed -e \
    's@ports:@env:\
        - name: DB\
          value: {{ template "fullname" . }}-db\
        ports:@g' \
    | tee packs/go-mongo/charts/templates/deployment.yaml
```

The command we just executed added the `env` section right above `ports`. The modified output was used to replace the existing content of `deployment.yaml`.

The next in line of the files we have to change is the `requirements.yaml` file. That's where we'll add `mongodb` as a dependency of the Helm chart.

```bash
echo "dependencies:
- name: mongodb
  alias: REPLACE_ME_APP_NAME-db
  version: 5.3.0
  repository:  https://kubernetes-charts.storage.googleapis.com
  condition: db.enabled
" | tee packs/go-mongo/charts/requirements.yaml
```

Please note the usage of the `code` string. Today (February 2019), that is still one of the features that are not documented. When the build pack is applied, it'll replace that string with the actual name of the application. After all, it would be silly to hard-code the name of the application since this pack should be reusable across many.

Now that we created the `mongodb` dependency, we should add the values that will customize MongoDB chart so that the database is deployed as a MongoDB replica set (a Kubernetes StatefulSet with two or more replicas). The place where we change variables used with a chart is `values.yaml`. But, since we want to redefine values of dependency, we need to add it inside the name or, in our case, the alias of that dependency.

```bash
echo "REPLACE_ME_APP_NAME-db:
  replicaSet:
    enabled: true
" | tee -a packs/go-mongo/charts/values.yaml
```

Just as with `requirements.yaml`, we used the "magic" string `code` that will be replaced with the name of the application during the import or the quickstart process. The `replicaSet.enabled` entry will make sure that the database is deployed as a multi-replica StatefulSet.

I> If you're interested in all the values available in the `mongodb` chart, please visit the [project README](https://github.com/helm/charts/tree/master/stable/mongodb).

You might think that we are finished with the changes, but that is not true. I wouldn't blame you for that if you did not yet use Jenkins X with a pull request (PR). I'll leave the explanation of how PRs work in Jenkins X for later. For now, it should be enough to know that the `preview` directory contains the template of the Helm chart that will be installed whenever we make a pull request and that we need to add `mongodb` there as well. The rest is on the need-to-know basis and reserved for the discussion of the flow of a Jenkins X PRs.

Let's take a quick look at what we have in the `preview` directory.

```bash
ls -1 packs/go-mongo/preview
```

The output is as follows.

```
Chart.yaml
Makefile
requirements.yaml
values.yaml
```

As you can see, that is not a full-fledged Helm chart like the one we have in the `charts` directory. Instead, it relies on dependencies in `requirements.yaml`.

```bash
cat packs/go-mongo/preview/requirements.yaml
```

The output is as follows.

```yaml
# !! File must end with empty line !!
dependencies:
- alias: expose
  name: exposecontroller
  repository: http://chartmuseum.jenkins-x.io
  version: 2.3.56
- alias: cleanup
  name: exposecontroller
  repository: http://chartmuseum.jenkins-x.io
  version: 2.3.56

  # !! "alias: preview" must be last entry in dependencies array !!
  # !! Place custom dependencies above !!
- alias: preview
  name: code
  repository: file://../code
```

If we exclude the `exposecontroller` which we will ignore for now (it creates Ingress for our applications), the only dependency is the one aliased `preview`. It points to the directory where the application chart is located. As a result, whenever we create a preview (through a pull request), it'll deploy the associated application. However, it will not install dependencies of that dependency, so we'll need to add MongoDB there as well.

Just as before, the `preview` uses `code` tag instead of a hard-coded name of the application.

If you take a look at the comments, you'll see that the file must end with an empty line. More importantly, the `preview` must be the last entry. That means that we need to add `mongodb` somewhere above it.

```bash
cat packs/go-mongo/preview/requirements.yaml \
    | sed -e \
    's@  # !! "alias@- name: mongodb\
  alias: preview-db\
  version: 5.3.0\
  repository:  https://kubernetes-charts.storage.googleapis.com\
\
  # !! "alias@g' \
    | tee packs/go-mongo/preview/requirements.yaml

echo '
' | tee -a packs/go-mongo/preview/requirements.yaml 
```

We performed a bit more `sed` of magic to add the `mongodb` dependency above the comment that starts with `# !! "alias`. Also, to be on the safe side, we added an empty line at the bottom as well.

Now we can push our changes to the forked repository.

```bash
git add .

git commit \
    --message "Added go-mongo build pack"

git push
```

With the new build pack safely stored, we should let Jenkins X know that we want to use the forked repository.

We can use `jx edit buildpack` to change the location of our `kubernetes-workloads` packs. However, at the time of this writing (February 2019), there is a bug that prevents us from doing that ([issue 2955](https://github.com/jenkins-x/jx/issues/2955)). The good news is that there is a workaround. If we omit the name (`-n` or `--name`), Jenkins X will add the new packs location, instead of editing the one dedicated to `kubernetes-workloads` packs.

```bash
jx edit buildpack \
    -u https://github.com/$GH_USER/jenkins-x-kubernetes \
    -r master \
    -b
```

From now on, whenever we decide to create a new quickstart or to import a project, Jenkins X will use the packs from the forked repository `jenkins-x-kubernetes`. 

Go ahead and try it out if you have a Go application with MongoDB at hand.

## Testing The New Build Pack

Let's check whether our new build pack works as expected.

```bash
cd ..

cd go-demo-6
```

We entered into the local copy of the `go-demo-6` repository.

If you are reusing Jenkins X installation from the previous chapter, you'll need to remove *go-demo-6* application as well as the activities so that we can start over the process of importing it.

W> Please execute the commands that follow only if you did not destroy the cluster from the previous chapter and if you still have the *go-demo-6* project inside Jenkins X. The first command will delete the application, while the second will remove all the Jenkins X activities related to *go-demo-6*.

```bash
jx delete application \
    $GH_USER/go-demo-6 \
    --batch-mode

kubectl -n jx delete act \
  -l owner=$GH_USER \
  -l sourcerepository=go-demo-6
```

To make sure that our new build pack is indeed working as expected, we'll undo all the commits we made to the `master` branch in the previous chapter and start over.

```bash
git pull

git checkout orig

git merge -s ours master --no-edit

git checkout master

git merge orig

rm -rf charts

git push
```

We replaced the `master` branch with `orig` and pushed the changes to GitHub.

Now we're ready to import the project using the newly created `go-mongo` pack.

```bash
jx import --pack go-mongo --batch-mode
```

The output should be almost the same as the one we saw when we imported the project based on the `go` pack. The only significant difference is that this time we can see in the output that it used the pack `go-mongo`.

Before it imported the *go-demo-6* project, Jenkins X cloned the build packs repository locally to the `.jx` directory. The next time we import a project or create a new one based on a quickstart, it will pull the latest version of the repository, thus keeping it always in sync with what we have in GitHub.

We can confirm that the repository was indeed cloned to `.jx` and that `go-mongo` is there, by listing the local files.

```bash
ls -1 ~/.jx/draft/packs/github.com/$GH_USER/jenkins-x-kubernetes/packs
```

The output, limited to the relevant entries, is as follows.

```
...
go
go-mongo
...
```

We can see that the `go-mongo` pack is indeed there.

Let's take a quick look at the activities and check whether everything works as expected.

```bash
jx get activity -f go-demo-6 -w
```

Once the build is finished, you should see the address of the *go-demo-6* application deployed to the staging environment from the `Promoted` entry (the last one).

Remember to stop watching the activities by pressing *ctrl+c* when all the steps are executed.

```
STEP                         STARTED AGO DURATION STATUS
vfarcic/go-demo-6/master #1        5m57s    5m47s Succeeded Version: 0.0.124
  Checkout Source                  5m36s       5s Succeeded
  CI Build and push snapshot       5m31s          NotExecuted
  Build Release                    5m30s     1m0s Succeeded
  Promote to Environments          4m30s    4m20s Succeeded
  Promote: staging                  4m3s    3m48s Succeeded
    PullRequest                     4m3s    1m11s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-rocks-staging/pull/3 Merge SHA: 1d8834cfb32e6d148f71cc107e41b7841e3c9db9
    Update                         2m52s    2m37s Succeeded  Status: Success at: http://jenkins.jx.jenkinx.35.237.5.18.nip.io/job/vfarcic/job/environment-jx-rocks-staging/job/master/4/display/redirect
    Promoted                       2m52s    2m37s Succeeded  Application is at: http://go-demo-6.jx-staging.jenkinx.35.237.5.18.nip.io
```

Let's take a look at the Pods that were created for us.

```bash
kubectl --namespace jx-staging get pods
```

The output is as follows.

```
NAME                                READY STATUS  RESTARTS AGE
jx-go-demo-6-...            0/1   Running 2        2m
jx-go-demo-6-db-arbiter-0   1/1   Running 0        2m
jx-go-demo-6-db-primary-0   1/1   Running 0        2m
jx-go-demo-6-db-secondary-0 1/1   Running 0        2m
```

The database Pods seem to be running correctly, so the new pack was indeed applied. However, the application Pod is restarting. From the past experience, you probably already know what the issue is. If you forgot, please execute the command that follows.

```bash
kubectl --namespace jx-staging \
    describe pod \
    -l app=jx-go-demo-6
```

We can see from the events that the probes are failing. That was to be expected since we decided that hard-coding `probePath` to `/demo/hello?health=true` is likely not going to be useful to anyone but the *go-demo-6* application. So, we left it as `/` in our `go-mongo` build pack. Owners of the applications that will use our new build pack should change it if needed. Therefore, we'll need to modify the application to accommodate the "special" probe path.

As a refresher, let's take another look at the `values.yaml` file.

```bash
cat charts/go-demo-6/values.yaml
```

The output, limited to the relevant parts, is as follows.

```yaml
...
probePath: /
...
```

As the rest of the changes we did in this chapter, we'll use `sed` to change the value. I won't hold it against you if you prefer making changes in your favorite editor instead.

```bash
cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@probePath: /@probePath: /demo/hello?health=true@g' \
    | tee charts/go-demo-6/values.yaml
```

Just as charts added as dependencies do not take into account their dependencies (dependencies of the dependencies), they ignore custom values as well. We'll need to add `probePath` to the `preview` as well.

```bash
echo '
  probePath: /demo/hello?health=true' \
    | tee -a charts/preview/values.yaml
```

I> It would be much easier if we could specify the values when importing an application, instead of modifying files afterward. At the time of this writing (February 2019), there is an open issue that requests just that. Feel free to follow the [issue 2928](https://github.com/jenkins-x/jx/issues/2928).

All that's left is to push the changes and wait until Jenkins updates the application.

```bash
git add .

git commit \
    --message "Fixed the probe"

git push

jx get activity -f go-demo-6 -w
```

Press *ctrl+c* when the new build is finished.

All that's left is to check whether the application is now running correctly.

W> Make sure to replace `[...]` with the address from the `Promoted` step before executing the commands that follow.

```bash
kubectl --namespace jx-staging get pods

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"
```

The first command should show that all the Pods are now running, while the last should output the familiar "hello, world" message.

## Giving Back To The Community

As you saw, creating new build packs is relatively straightforward. In most cases, all we have to do is find the one that is closest to our needs, make a copy, and change a few files. For your internal use, you can configure Jenkins X to use build packs from your own repository. That way you can apply the same workflow to your packs as to any other code you're working on. Moreover, you can import the repository with build packs to Jenkins X and run tests that will validate your changes.

Sometimes you will create packs that are useful only within the context of your company. Most of us think that we have "special" needs and so we tend to have processes and conventions that likely do not fit other organizations. However, more often than not, there is an illusion of being different. The truth is that most of us do employ similar, if not the same tools, processes, and conventions. The way different companies work and the technologies they use are more alike than many think. By now, you might be wondering why am I telling you this? The reason is simple. If you created a build pack, contribute it to the community. You might be thinking that it is too specific for your company and that it would not be useful to others. That might be true, or it might not. What is true is that it only takes a few moments to create a pull request. No significant time will be lost if it gets rejected, but if it is merged, many others will benefit from your work, just as you benefit from build packs made by others.

All that apparently does not matter if the policy of your company does not permit you to make public anything done during your working hours, or if your build pack contains proprietary information.

## What Now?

Now is a good time for you to take a break.

You might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just continue on to the next chapter.

However, if you created a cluster only for the purpose of the exercises we executed, please destroy it. We'll start the next, and each other chapter from scratch as a way to save you from running your cluster longer than necessary and pay more than needed to your hosting vendor. If you created the cluster or installed Jenkins X using one of the Gists from the beginning of this chapter, you'll find the instructions on how to destroy the cluster or uninstall everything at the bottom.

If you did choose to destroy the cluster or to uninstall Jenkins X, please remove the repositories we created as well as the local files. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
```
