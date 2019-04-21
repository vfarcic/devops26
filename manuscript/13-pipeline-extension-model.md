# Using The Extension Model in jenkins-x.yaml

## Creating A Kubernetes Cluster With Jenkins X

TODO: Rewrite

W> You might be used to the fact that until now we were always using the same Gists to create a cluster or install Jenkins X in an existing one. Those that follow are different.

If you kept the cluster from the previous chapter and it contains serverless Jenkinss X, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [13-pipeline-extension-model.sh](TODO:) Gist.

For your convenience, the Gists that will create a new Jenkins X cluster or install it inside an existing one are as follows.

* Create new **GKE** cluster: [gke-jx-serverless.sh](TODO:)
* Create new **EKS** cluster: [eks-jx-serverless.sh](TODO:)
* Create new **AKS** cluster: [aks-jx-serverless.sh](TODO:)
* Use an **existing** cluster: [install-serverless.sh](TODO:)

We will not need the `jx-serverless` project we created in the previous chapter. If you are reusing the cluster and Jenkins X installation, you might want to remove it and same a bit of resources.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

Now we can explore Jenkins X Pipeline Extension Model.

## Pipeline Extension Model

```bash
cd go-demo-6

git checkout master

rm Jenkinsfile

jx import -b

jx get activities -f go-demo-6 -w

ls -1

cat jenkins-x.yml

git checkout -b extension

jx create step

# pullRequest
# setup
# pre
# echo this is the pre mode of the setup stage

cat jenkins-x.yml

git add .

git commit -m "Trying to extend the pipeline"

git push --set-upstream origin extension

jx create pr \
    -t "Extensions" \
    --body "What I can say?" \
    -b

jx get activities -f go-demo-6 -w
```

TODO: Continue code

https://jenkins-x.io/architecture/jenkins-x-pipelines/#customising-the-pipelines


## What Now?

TODO: Rewrite

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you chose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-tekton-staging

hub delete -y \
  $GH_USER/environment-tekton-production

rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*

rm -f ~/.jx/jenkinsAuth.yaml
```