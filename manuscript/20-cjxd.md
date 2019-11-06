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

# CJXD

## Requirements and Limitations

TODO:

## Installing

```bash
# MacOS
curl -L https://storage.googleapis.com/artifacts.jenkinsxio.appspot.com/binaries/cjxd/latest/jx-darwin-amd64.tar.gz \
  | tar xzv

# MacOS
sudo mv jx /usr/local/bin/jx

# TODO: Linux

# TODO: Windows

jx version
```

## Creating A Kubernetes Cluster With CloudBees Jenkins X Distribution

* Create new **GKE** cluster: [gke.sh](https://gist.github.com/1b7a1c833bae1d5da02f4fd7b3cd3c17)

# TODO: Install CJXD

```bash
rm -rf ~/.jx

jx profile cloudbees

jx boot
```

## UI

```bash
# Add the note to `18-boot.md` about CJXD

jx add app jx-app-ui
```

```
? github username: vfarcic
To be able to create a repository on github we need an API Token
Please click this URL and generate a token 
https://github.com/settings/tokens/new?scopes=repo,read:user,read:org,user:email,write:repo_hook,delete_repo

Then COPY the token and enter it below:

? API Token: ****************************************
Read credentials for http://chartmuseum.jenkins-x.io from vault helm/repos
Preparing questions to configure jx-app-ui. If this is the first time you have installed the app, this may take a couple of minutes.
Questions prepared.
Installing UI in single-user mode
Created Pull Request: https://github.com/vfarcic/environment-jx-boot-dev/pull/1
Added app via Pull Request https://github.com/vfarcic/environment-jx-boot-dev/pull/1
```

```bash
# Open the PR link and merge it

jx get activities \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch

# *ctrl+c*

UI_ADDR=$(kubectl get ing jxui \
    --output jsonpath="{.spec.rules[0].host}")

open "http://$UI_ADDR"
```

## What Now?

```bash
hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-staging

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-production

# Delete storage
```