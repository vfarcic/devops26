## TODO

- [ ] Code
- [ ] Write
- [X] Code review static GKE
- [ ] Code review serverless GKE
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

# Serverless Pipelines From Scratch

## Creating A Kubernetes Cluster With Jenkins X

TODO: Viktor: This text is from some other change. Rewrite it.

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [TODO: Viktor](TODO: Viktor) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create a new **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create a new **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create a new **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

TODO: Intro to the next section

## Something

TODO: devops-toolkit repo README.md

## What Now?

TODO: Viktor: Rewrite

Now is a good time for you to take a break.

If you created a cluster only for the purpose of the exercises we executed, please destroy it. We'll start the next, and each other chapter from scratch as a way to save you from running your cluster longer than necessary and pay more than needed to your hosting vendor. If you created the cluster or installed Jenkins X using one of the Gists from the beginning of this chapter, you'll find the instructions on how to destroy the cluster or uninstall everything at the bottom.

If you did choose to destroy the cluster or to uninstall Jenkins X, please remove the repositories we created as well as the local files. You can use the commands that follow for that. Just remember to replace `[...]` with your GitHub user.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-tekton-staging

hub delete -y \
  $GH_USER/environment-tekton-production

rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*
```

Finally, you might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just keep reading.
