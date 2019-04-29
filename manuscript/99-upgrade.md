## TODO

- [ ] Code
- [ ] Write
- [-] Code review GKE
- [-] Code review EKS
- [-] Code review AKS
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

# Intermezzo: Keeping Jenkins X Up-To-Date

```bash
open "https://github.com/jenkins-x/jenkins-x-versions/blob/master/charts/jenkins-x/jenkins-x-platform.yml"
```

```bash
jx upgrade platform --help

# It should be `jx upgrade platform --version ...`

jx upgrade platform
```

```bash
jx upgrade crd

jx upgrade extensions

jx upgrade cli
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

hub delete -y \
  $GH_USER/environment-tekton-staging

hub delete -y \
  $GH_USER/environment-tekton-production

rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
```