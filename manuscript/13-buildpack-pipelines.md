# Extending Buildpack Pipelines

## Creating A Kubernetes Cluster With Jenkins X

TODO: Rewrite

NOTE: Both static and serverless Gists are available

If you kept the cluster from the previous chapter and it contains serverless Jenkins X, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [12-prow.sh](https://gist.github.com/3ce238a85ff5537919d394bb9ec57e8e) Gist.

For your convenience, the Gists that will create a new Jenkins X cluster or install it inside an existing one are as follows.

* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

You'll notice that there are not many differences between the Gists we're using now and those we used to create a cluster with static Jenkins X. The major difference is that we're using a different environment prefix and the namespace just in case you're running both flavors in parallel. The "real" difference is in the addition of `--prow` and `--tekton` arguments to `jx create cluster` and `jx install` commands.

We will not need the `jx-prow` project we created in the previous chapter. If you are reusing the cluster and Jenkins X installation, you might want to remove it and save a bit of resources.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
GH_USER=[...]

jx delete application \
    $GH_USER/jx-prow \
    -b
```

Now we can explore Prow inside the serverless Jenkins X bundle.