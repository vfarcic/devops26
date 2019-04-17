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

```bash
```

Now we can explore Jenkins X Pipeline Extension Model.

## Pipeline Extension Model


https://jenkins-x.io/architecture/jenkins-x-pipelines/#customising-the-pipelines

TODO: Figure out why it fails with `replace: false`

```bash
echo "pipelineConfig:
  pipelines:
    release:
      setup:
        replace: true
        steps:
        - sh: echo 'Injected into the setup phase'
      preBuild:
        replace: true
        steps:
        - sh: echo 'Injected into the preBuild phase'
      build:
        replace: true
        steps:
        - sh: echo 'Injected into the build phase'
      postBuild:
        replace: true
        steps:
        - sh: echo 'Injected into the postBuild phase'
      promote:
        replace: true
        steps:
        - sh: echo 'Injected into the promote phase'
" | tee -a jenkins-x.yml

git add .

git commit -m "Lifecycle example"

git push

jx get activities -f jx-go -w

jx get build logs

# Add pullRequest and feature pipelines
```