## TODO

- [ ] Code
- [ ] Write
- [ ] Code review static GKE
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

# Git Servers

TODO: Use `--git-provider-kind` with `jx create cluster` and `jx install`
TODO: Try with `--no-default-environments`

## Creating A Kubernetes Cluster With Jenkins X

TODO: Repos other than GitHub do not yet work with serverless.

TODO: Rewrite

W> You might be used to the fact that until now we were always using the same Gists to create a cluster or install Jenkins X in an existing one. Those that follow are different.

If you kept the cluster from the previous chapter and it contains serverless Jenkinss X, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [TODO:](TODO:) Gist.

For your convenience, the Gists that will create a new Jenkins X cluster or install it inside an existing one are as follows.

* Create a new static **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create a new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create a new static **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create a new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create a new static **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Create a new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** static cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

Now we can explore TODO:.

## Git

```bash
jx create quickstart \
    --language go \
    --project-name jx-git \
    --batch-mode

cd jx-git

jx get activities \
    --filter jx-git \
    --watch

jx get git

# It could be `bitbucket`, `bitbucketcloud`, `github` Enterprise, etc
jx create git server \
    --kind gitlab \
    --name gitlab \
    --url https://gitlab.com

jx get git

API_TOKEN=[...]

GITLAB_USER=[...]

jx create git token \
    --name gitlab \
    --api-token $API_TOKEN \
    $GITLAB_USER

jx create env \
    --name pre-production \
    --label Pre-Production \
    --namespace jx-pre-production \
    --promotion Auto \
    --git-provider-kind gitlab \
    --git-username $GITLAB_USER \
    --batch-mode

echo "Something else" | tee README.md

git add .

git commit \
    --message "Testing the new repo"

git push

jx get activities \
    --filter jx-git \
    --watch

# TODO: Merge of pre-prod to master is not automatic and it hangs indefinitely when merged manually. Maybe it's related to https://github.com/jenkins-x/jx/issues/2410, https://github.com/jenkins-x/jx/issues/3788

# Change an env.

# Create a new app in GitLab
```

## What Now?

TODO: Rewrite

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you chose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

hub delete -y $GH_USER/jx-git

rm -rf environment-jx-rocks-production

rm -rf jx-git

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

# TODO: Delete environment-jx-pre-production manually
```
