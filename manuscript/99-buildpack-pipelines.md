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

# Extending Buildpack Pipelines

## Creating A Kubernetes Cluster With Jenkins X

TODO: Rewrite

NOTE: Both static and serverless Gists are available

If you kept the cluster from the previous chapter and it contains serverless Jenkins X, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [12-prow.sh](https://gist.github.com/3ce238a85ff5537919d394bb9ec57e8e) Gist.

For your convenience, the Gists that will create a new Jenkins X cluster or install it inside an existing one are as follows.

* Create new static **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new static **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new static **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** static cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

You'll notice that there are not many differences between the Gists we're using now and those we used to create a cluster with static Jenkins X. The major difference is that we're using a different environment prefix and the namespace just in case you're running both flavors in parallel. The "real" difference is in the addition of `--prow` and `--tekton` arguments to `jx create cluster` and `jx install` commands.

We will not need the `jx-prow` project we created in the previous chapter. If you are reusing the cluster and Jenkins X installation, you might want to remove it and save a bit of resources.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

TODO: Double check whether `jx-prow` should be removed

```bash
GH_USER=[...]

jx delete application \
    $GH_USER/jx-prow \
    -b
```

We'll continue using the *go-demo-6* application. Please enter the local copy of the repository, unless you're there already.

I> The commands that follow will reset your *go-demo-6* `master` branch with the contents of the `versioning` branch that contains all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

TODO: Double check whether the correct branch is restored

```bash
cd go-demo-6

git pull

git checkout versioning

git merge -s ours master --no-edit

git checkout master

git merge versioning

git push

cd ..
```

Now we can explore how to enhance buildpack pipelines.

## Something

```bash
GH_USER=[...]

# If NOT already cloned
git clone \
    https://github.com/$GH_USER/jenkins-x-kubernetes

# If already cloned
cd jenkins-x-kubernetes

# If already cloned
git remote -v
```

```
origin  https://github.com/vfarcic/jenkins-x-kubernetes (fetch)
origin  https://github.com/vfarcic/jenkins-x-kubernetes (push)
```

```bash
# If already cloned
git remote add upstream \
    https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes.git

# If already cloned
git fetch upstream

# If already cloned
git checkout master

# If already cloned
git merge upstream/master

ll packs

# Add targets to Makefile

cat packs/go/pipeline.yaml

# Replace
```

```yaml
      - sh: export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml
        name: container-build
```

```bash
# With
```

```yaml
      - sh: make unittest
        name: unit-test
      - sh: export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml
        name: container-build
```

```bash
# Replace
```

```yaml
          name: jx-preview
```

```bash
# TODO: Figure out a better way to get `ADDRESS`

# With
```

```yaml
          name: jx-preview
      - dir: /home/jenkins/go/src/REPLACE_ME_GIT_PROVIDER/REPLACE_ME_ORG/REPLACE_ME_APP_NAME
        steps:
        - sh: jx get preview --current -o jsonpath="{.msg}"
          name: address
        - sh: ADDRESS=$(kubectl -n jx-$ORG-$PREVIEW_NAMESPACE get ing REPLACE_ME_APP_NAME -o jsonpath='{.spec.rules[0].host}' make functest
          name: func-test
```

```bash
# Replace
```

```yaml
          name: jx-promote
```

```bash
# TODO: Figure out a better way to get `ADDRESS`

# With
```

```yaml
          name: jx-promote
      - dir: /home/jenkins/go/src/REPLACE_ME_GIT_PROVIDER/REPLACE_ME_ORG/REPLACE_ME_APP_NAME
        steps:
        - sh: ADDRESS=$(kubectl -n jx-staging get ing REPLACE_ME_APP_NAME -o jsonpath='{.spec.rules[0].host}' make functest
          name: func-test
        - sh: ADDRESS=$(kubectl -n jx-staging get ing REPLACE_ME_APP_NAME -o jsonpath='{.spec.rules[0].host}' make integtest
          name: integ-test
```

```bash
git add .

git commit -m "Added unit tests"

git push

# If NOT an existing cluster
jx edit buildpack \
    -u https://github.com/$GH_USER/jenkins-x-kubernetes \
    -r master \
    -b

cd ../go-demo-6

# Only if reusing the cluster
jx delete application \
    $GH_USER/go-demo-6 \
    -b

rm -rf Jenkinsfile

git add .

git commit -m "Removed Jenkinsfile"

git push

jx import -b

jx get activities -f go-demo-6 -w

git checkout -b pipeline-changes

# TODO: Increase the number of replicas

echo "Something different" \
    | tee README.md

git add .

git commit \
    -m "Testing buildpack changes"

git push \
    --set-upstream origin \
    pipeline-changes

jx create pr \
    -t "Buildpack changes" \
    --body "What I can say?" \
    -b

jx get activities -f go-demo-6 -w
```

## What Now?

TODO: Rewrite

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you chose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

# If static
hub delete -y \
  $GH_USER/environment-jx-rocks-staging

# If static
hub delete -y \
  $GH_USER/environment-jx-rocks-production

# If serverless
hub delete -y \
  $GH_USER/environment-tekton-staging

# If serverless
hub delete -y \
  $GH_USER/environment-tekton-production

# If static
rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

# If serverless
rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*
```