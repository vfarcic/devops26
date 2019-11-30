# Links to gists for creating a cluster with jx
# gke-jx-serverless.sh: https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8
# eks-jx-serverless.sh: https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd
# aks-jx-serverless.sh: https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410
# install-serverless.sh: https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037

open "https://github.com/vfarcic/go-demo-6"

GH_USER=[...]

git clone \
  https://github.com/$GH_USER/go-demo-6.git

cd go-demo-6

git pull

git checkout orig

git merge -s ours master --no-edit

git checkout master

git merge orig

rm -rf charts

git push

jx repo --batch-mode

ls -1

jx import --batch-mode

ls -1

jx get activities \
    --filter go-demo-6 \
    --watch

jx get applications

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"

kubectl --namespace jx-staging logs \
    -l app=jx-go-demo-6

echo "dependencies:
- name: mongodb
  alias: go-demo-6-db
  version: 5.3.0
  repository:  https://kubernetes-charts.storage.googleapis.com
  condition: db.enabled
" | tee charts/go-demo-6/requirements.yaml

echo "go-demo-6-db:
  replicaSet:
    enabled: true
" | tee -a charts/go-demo-6/values.yaml

git add .

git commit \
    --message "Added dependencies"

git push

jx get activity \
    --filter go-demo-6 \
    --watch

kubectl --namespace jx-staging get pods

kubectl --namespace jx-staging \
    describe pod \
    -l app=jx-go-demo-6

cat charts/go-demo-6/values.yaml

git add .

git commit \
    --message "Added dependencies"

git push

jx get activity \
    --filter go-demo-6 \
    --watch

kubectl --namespace jx-staging get pods

curl "$STAGING_ADDR/demo/hello"

cd ..

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
