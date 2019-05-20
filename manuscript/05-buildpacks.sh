# Links to gists for creating a cluster with jx
# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# eks-jx.sh: https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac
# aks-jx.sh: https://gist.github.com/6e01717c398a5d034ebe05b195514060
# install.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

open "https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes"

GH_USER=[...]

git clone https://github.com/$GH_USER/jenkins-x-kubernetes

cd jenkins-x-kubernetes

ls -1 packs

ls -1 packs/go

cp -R packs/go packs/go-mongo

cat packs/go-mongo/charts/templates/deployment.yaml \
    | sed -e \
    's@ports:@env:\
        - name: DB\
          value: {{ template "fullname" . }}-db\
        ports:@g' \
    | tee packs/go-mongo/charts/templates/deployment.yaml

echo "dependencies:
- name: mongodb
  alias: REPLACE_ME_APP_NAME-db
  version: 5.3.0
  repository:  https://kubernetes-charts.storage.googleapis.com
  condition: db.enabled
" | tee packs/go-mongo/charts/requirements.yaml

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

echo '
' | tee -a packs/go-mongo/preview/requirements.yaml 

git add .

git commit \
    --message "Added go-mongo buildpack"

git push

jx edit buildpack \
    -u https://github.com/$GH_USER/jenkins-x-kubernetes \
    -r master \
    -b

cd ..

cd go-demo-6

# Execute only if you retained the cluster and Jenkins X from the previous chapter.
jx delete application \
    $GH_USER/go-demo-6 \
    --batch-mode

# Execute only if you retained the cluster and Jenkins X from the previous chapter.
kubectl -n jx delete act \
  -l owner=$GH_USER \
  -l sourcerepository=go-demo-6

git checkout orig

git merge -s ours master --no-edit

git checkout master

git merge orig

rm -rf charts

git push

jx import --pack go-mongo --batch-mode

ls -1 ~/.jx/draft/packs/github.com/$GH_USER/jenkins-x-kubernetes/packs

jx get activity -f go-demo-6 -w

kubectl --namespace jx-staging get pods

kubectl --namespace jx-staging \
    describe pod \
    -l app=jx-staging-go-demo-6

cat charts/go-demo-6/values.yaml

cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@probePath: /@probePath: /demo/hello?health=true@g' \
    | tee charts/go-demo-6/values.yaml

echo '
  probePath: /demo/hello?health=true' \
    | tee -a charts/preview/values.yaml

git add .

git commit \
    --message "Fixed the probe"

git push

jx get activity -f go-demo-6 -w

kubectl --namespace jx-staging get pods

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
