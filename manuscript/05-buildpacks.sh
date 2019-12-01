# Links to gists for creating a cluster with jx
# gke-jx-serverless.sh: https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8
# eks-jx-serverless.sh: https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd
# aks-jx-serverless.sh: https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410
# install-serverless.sh: https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037

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
    --message "Added go-mongo build pack"

git push

jx edit buildpack \
    --url https://github.com/$GH_USER/jenkins-x-kubernetes \
    --ref master \
    --batch-mode

cd ..

cd go-demo-6

jx delete application \
    $GH_USER/go-demo-6 \
    --batch-mode

kubectl --namespace jx delete act \
    --selector owner=$GH_USER \
    --selector sourcerepository=go-demo-6

git pull

git checkout orig

git merge -s ours master --no-edit

git checkout master

git merge orig

rm -rf charts

git push

jx import --pack go-mongo --batch-mode

ls -1 ~/.jx/draft/packs/github.com/$GH_USER/jenkins-x-kubernetes/packs

jx get activity \
    --filter go-demo-6 \
    --watch

kubectl --namespace jx-staging get pods

kubectl --namespace jx-staging \
    describe pod \
    --selector app=jx-go-demo-6

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

jx get activity \
    --filter go-demo-6 \
    --watch

kubectl --namespace jx-staging get pods

jx get applications

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"

cat jenkins-x.yml \
    | sed -e \
    's@buildPack: go-mongo@buildPack: go@g' \
    | tee jenkins-x.yml

git add .

git commit -m "Reverted to the go buildpack"

git push

cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
