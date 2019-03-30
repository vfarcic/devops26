## TODO

- [X] Code
- [X] Write
- [X] Code review GKE
- [X] Code review EKS
- [X] Code review AKS
- [-] Code review existing cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com


# Promoting Releases To Production

From the application lifecycle point of view, we reached the final stage. We saw how to import and existing project or create a new one. We saw how we can create buildpacks that will simplify those processes for the types of applications that are not covered with the existing buildpacks or those that deviate them. Once we added our application to Jenkins X, we explored how it implements GitOpts processes through environments (e.g., staging and production). Than we moved into application development phase and explored how DevPods help us set a personal application-specific environment that greatly simplifies the "traditional" setup that forced us to spend countless hours setting it on our laptop and, at the same time, avoids the pittfalls of shared development environments. Once the development of a feature, a change, or a bug fix is finished, we created a pull request, executed automated validations and deployed the release candidate to a PR-specific preview environment so that we can check it manually as well. Once we were satisfied with the changes we made, we merged it to the master branch and that resulted in deployment to the environments set to receive automated promotions (e.g., staging) as well as another round of testing. Now that we are comfortable with the changes we did, all that's left is to promote our release to production.

At the moment, our production environment is set to receive manual promotions. As such, we are employing continuous delivery that has the whole pipeline full automated and requires a single manual action to promote a release to production. All that's left is to click a button or, as is our case, to execute a single command. We could have set the production environment to receive promotions automatically and in that case we'd be practicing continuous deployment (not delivery) that would result in deployment of every merge or push to the master branch. But, we aren't practicing continuous deployment today and we'll stick with the current setup and jump into the last stage of continuous delivery. We'll promote our last release to production.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [09-promote.sh](TODO:) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

We'll continue using the *go-demo-6* application. Please enter the local copy of the repository, unless you're there already.

```bash
cd go-demo-6
```

I> The commands that follow will reset your `master` with the contents of the `pr` branch that contains all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

```bash
git pull

git checkout pr

git merge -s ours master --no-edit

git checkout master

git merge pr

git push
```

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
jx import -b

jx get activities -f go-demo-6 -w
```

Please wait until the activity of the application shows that all the steps were executed successfully, and stop the watcher by pressing *ctrl+c*.

Now we can promote our last release to production.

## Promoting A Release To The Production Environment

Now that we feel that our new release is production-ready, we can promote it to production. But, before we do that, we'll check whether we already have something running in production.

```bash
jx get applications -e production
```

The output states that `no applications` was `found in environments production`.

How about staging? We must have the release of our *go-demo-6* application running there. Let's double check.
```

```bash
jx get applications -e staging
```

The output is as follows.

```
APPLICATION STAGING PODS URL
go-demo-6   0.0.184 1/1  http://go-demo-6.jx-staging.35.237.161.58.nip.io
```

For what we're trying to do, the important piece of the information is the version displayed in the `STAGING` column.

W> Before executing the command that follows, please make sure to replace `[...]` with the version from the `STAGING` column from the output of the previous command.

```bash
VERSION=[...]
```

Now we can promote the specific version of *go-demo-6* to the production environment.

```bash
jx promote go-demo-6 \
    --version $VERSION \
    --env production \
    -b
```

It'll take a minute or two until the promotion process is finished.

The `jx` CLI will create a new branch in the production environment (`environment-jx-rocks-production`). Further on, it'll follow the same practice based on pull requests as anything else we did so far. It'll create a pull request and wait until a Jenkins X build initiated by it is finished and successfull. You might see errors stating that it `failed to query the Pull Request`. That's normal. The process is asynchronous and `jx` is periodically quering the system until it receives the information that confirms that the pull request was processed successfully.

Once the pull request is processed, it'll be merged to the master branch and that will initiate yet another Jenkins X build. It'll run all the steps we defined in repository's Jenkinsfile. By default, those steps are only deploying the release to production, but we could have added additional validations in form of integration or other types of tests. Once the build initiated by the merge to the master branch is finished, we'll have the release running in production and the final output will state that `merge status checks all passed so the promotion worked!`

```bash
# TODO: Diagram
```

Next, we'll confirm that the release is indeed deployed to production by retrieving all the applications in that environment.

```bash
jx get applications -e production
```

The output is as follows.

```
APPLICATION PRODUCTION PODS URL
go-demo-6   0.0.184    1/1  http://go-demo-6.jx-production.35.237.161.58.nip.io
```

In my case, the output states that there is only one application (`go-demo-6`) running in production and that the version is `0.0.184`.

To be on the safe side, we'll send a request to the release of our application running in production.

W> Before executing the commands that follow, please make sure to replace `[...]` with the the `URL` column from the output of the previous command.

```bash
PROD_ADDR=[...]

curl "$PROD_ADDR/demo/hello"
```

The output should be the familiar message `hello, PR!`. We confirmed that promotion to production works as expected.

## What Now?

Bear in mind that there are many other things we could do to improve deployment to production. We could add HorizontalPodAutoscaler that will scale the application depending on memory and CPU consumption or based on custom metrics. We could also add additional tests beyond those we added in the [Applying GitOps Principles](#gitops) chapter. We won't do any of the many improvements we could do since I assume that you already know how to enhance your Helm charts and how to write tests and add their execution to Jenkinsfile. What matters is that the process works and it is up to you to change it and enhance it to suit your specific needs.

For now, we'll conclude that we explored the whole lifecycle of an application and that our latest release is running in production. In the next chapter we'll explore how to make our Jenkins X setup scalable so that it can fullfil traffic at any scale without wasting resources when idle. We'll make Jenkins serverless.

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you choose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```