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

ls -1 $PACKS_PATH/go-mongo/charts/

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

ls -1 $PACKS_PATH/go-mongo/preview

cat $PACKS_PATH/go-mongo/preview/requirements.yaml

cat $PACKS_PATH/go-mongo/preview/requirements.yaml \
    | sed -e \
    's@  # !! "alias@- name: mongodb\
  alias: preview-db\
  version: 5.3.0\
  repository:  https://kubernetes-charts.storage.googleapis.com\
\
  # !! "alias@g' \
    | tee $PACKS_PATH/go-mongo/preview/requirements.yaml

# Unless you're already there
cd go-demo-6

# NOTE: Only if reusing the cluster from the previous chapter
GH_USER=[...]

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

# NOTE: Only if reusing the cluster from the previous chapter
# NOTE: Jenkins did not delete its cache and you might still see the old builds. They will be overwritten soon. For example...
```

```
vfarcic/go-demo-6/master #1       32m17s   10m45s Running Version: 0.0.100
  Checkout Source                 31m56s       9s Succeeded
  CI Build and push snapshot      31m46s          NotExecuted
  Build Release                   31m46s     1m0s Pending
  Promote to Environments         30m46s    9m13s Succeeded
  Promote: staging                30m20s    8m32s Succeeded
    PullRequest                   30m20s    1m11s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-rocks-staging/pull/3 Merge SHA: f9ed6716ffb4d414163bf7160d7599bc3fe71757
    Update                         29m9s    7m21s Succeeded  Status: Success at: http://jenkins.jx.35.231.72.223.nip.io/job/vfarcic/job/environment-jx-rocks-staging/job/master/4/display/redirect
    Promoted                       29m9s    7m21s Succeeded  Application is at: http://go-demo-6.jx-staging.35.231.72.223.nip.io
vfarcic/go-demo-6/master #2       21m30s    4m18s Succeeded Version: 0.0.101
  Checkout Source                  21m9s       5s Succeeded
  CI Build and push snapshot       21m4s          NotExecuted
  Build Release                    21m4s      57s Succeeded
  Promote to Environments          20m7s    2m55s Succeeded
  Promote: staging                19m39s    2m27s Succeeded
    PullRequest                   19m39s    1m18s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-rocks-staging/pull/4 Merge SHA: f14bd67c907be4137945162775ca81bdfd9b310e
    Update                        18m21s     1m9s Succeeded  Status: Success at: http://jenkins.jx.35.231.72.223.nip.io/job/vfarcic/job/environment-jx-rocks-staging/job/master/5/display/redirect
    Promoted                      18m21s     1m9s Succeeded  Application is at: http://go-demo-6.jx-staging.35.231.72.223.nip.io
...
```

```bash
jx get activity -f go-demo-6 -w

kubectl -n jx-staging get pods

kubectl -n jx-staging \
    describe pod \
    -l app=jx-staging-go-demo-6

cat charts/go-demo-6/values.yaml

cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@probePath: /@probePath: /demo/hello?health=true@g' \
    | tee charts/go-demo-6/values.yaml

cat charts/preview/values.yaml

echo "\
probePath: /demo/hello?health=true" \
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

```bash
GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```
