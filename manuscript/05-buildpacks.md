# Buildpacks

## Creating A Kubernetes Cluster With Jenkins X

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

## Something

```bash
PACKS_PATH="$HOME/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs"

ls -1 $PACKS_PATH

ls -1 $PACKS_PATH/go

cp -R $PACKS_PATH/go \
    $PACKS_PATH/go-mongo

cat $PACKS_PATH/go-mongo/charts/templates/deployment.yaml \
    | sed -e \
    's@ports:@env:\
        - name: DB\
          value: {{ template "fullname" . }}-db\
        ports:@g' \
    | tee $PACKS_PATH/go-mongo/charts/templates/deployment.yaml

echo "dependencies:
- name: mongodb
  alias: REPLACE_ME_APP_NAME-db
  version: 5.3.0
  repository:  https://kubernetes-charts.storage.googleapis.com
" | tee $PACKS_PATH/go-mongo/charts/requirements.yaml

echo "REPLACE_ME_APP_NAME-db:
  replicaSet:
    enabled: true
" | tee -a $PACKS_PATH/go-mongo/charts/values.yaml

cd go-demo-6

git checkout orig

git merge -s ours master --no-edit

git checkout master

git merge orig

rm -rf charts

git push

# NOTE: Only if reusing the cluster from the previous chapter
GH_USER=[...]

# NOTE: Only if reusing the cluster from the previous chapter
jx delete application \
    $GH_USER/go-demo-6 \
    -b

jx import --pack go-mongo -b

jx get activity -f go-demo-6 -w

kubectl -n jx-staging get pods

kubectl -n jx-staging \
    describe pod \
    -l app=jx-staging-go-demo-6

cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@probePath: /@probePath: /demo/hello?health=true@g' \
    | tee charts/go-demo-6/values.yaml

git add .

git commit -m "Fixed the probe"

git push

jx get activity -f go-demo-6 -w

kubectl -n jx-staging get pods

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"
```

## What Now?

```bash
hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```
