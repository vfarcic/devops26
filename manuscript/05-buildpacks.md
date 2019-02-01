## TODO

- [X] Code
- [ ] Write
- [X] Code review GKE
- [X] Code review EKS
- [X] Code review AKS
- [ ] Code review existing cluster
- [ ] Text review
- [ ] Diagrams
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Buildpacks

## Creating A Kubernetes Cluster With Jenkins X

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

## Something

```bash
open "https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes"

# Fork it

# If inside an existing repo
cd ..

GH_USER=[...]

git clone https://github.com/$GH_USER/jenkins-x-kubernetes

cd jenkins-x-kubernetes

ls -1 packs

ls -1 packs/go

cp -R packs/go packs/go-mongo

ls -1 packs/go-mongo/charts/templates

cat packs/go-mongo/charts/templates/deployment.yaml \
    | sed -e \
    's@ports:@env:\
        - name: DB\
          value: {{ template "fullname" . }}-db\
        ports:@g' \
    | tee packs/go-mongo/charts/templates/deployment.yaml

ls -1 packs/go-mongo/charts/

echo "dependencies:
- name: mongodb
  alias: REPLACE_ME_APP_NAME-db
  version: 5.3.0
  repository:  https://kubernetes-charts.storage.googleapis.com
" | tee packs/go-mongo/charts/requirements.yaml

cat packs/go-mongo/charts/values.yaml

echo "REPLACE_ME_APP_NAME-db:
  replicaSet:
    enabled: true
" | tee -a packs/go-mongo/charts/values.yaml

ls -1 packs/go-mongo/preview

cat packs/go-mongo/preview/requirements.yaml

cat packs/go-mongo/preview/requirements.yaml \
    | sed -e \
    's@  # !! "alias@- name: mongodb\
  alias: preview-db\
  version: 5.3.0\
  repository:  https://kubernetes-charts.storage.googleapis.com\
\
  # !! "alias@g' \
    | tee packs/go-mongo/preview/requirements.yaml

git add .

git commit -m "Added go-mongo buildpack"

git push

# https://github.com/jenkins-x/jx/issues/2955

jx edit buildpack \
    -u https://github.com/$GH_USER/jenkins-x-kubernetes \
    -r master \
    -b

cd ..

cd go-demo-6

# NOTE: Only if reusing the cluster from the previous chapter
jx delete application \
    $GH_USER/go-demo-6 \
    -b

git checkout orig

git merge -s ours master --no-edit

git checkout master

git merge orig

rm -rf charts

git push

jx import --pack go-mongo -b

ll ~/.jx/draft/packs/github.com/vfarcic/jenkins-x-kubernetes/packs

jx get activity -f go-demo-6 -w

# ctrl+c

# NOTE: Only if reusing the cluster from the previous chapter
# NOTE: Jenkins did not delete its cache and you might still see the old builds. They will be overwritten soon. For example...

kubectl -n jx-staging get pods

kubectl -n jx-staging \
    describe pod \
    -l app=jx-staging-go-demo-6

# https://github.com/jenkins-x/jx/issues/2928

cat charts/go-demo-6/values.yaml

cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@probePath: /@probePath: /demo/hello?health=true@g' \
    | tee charts/go-demo-6/values.yaml

cat charts/preview/values.yaml

echo '  probePath: /demo/hello?health=true' \
    | tee -a charts/preview/values.yaml
 
git add .

git commit -m "Fixed the probe"

git push

jx get activity -f go-demo-6 -w

kubectl -n jx-staging get pods

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"
```

## What Now?

NOTE: Destroy the cluster

```bash
GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```
