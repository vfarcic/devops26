# Links to gists for creating a cluster with jx
# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# eks-jx.sh: https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac
# aks-jx.sh: https://gist.github.com/6e01717c398a5d034ebe05b195514060
# install.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

open "https://github.com/vfarcic/go-demo-6"

GH_USER=[...]

git clone \
  https://github.com/$GH_USER/go-demo-6.git

cd go-demo-6

git checkout orig

git merge -s ours master --no-edit

git checkout master

git merge orig

rm -rf charts

git push

jx repo -b

ls -1

jx import --batch-mode

ls -1

jx get activities -f go-demo-6 --watch

STAGING_ADDR=[...]

curl "$STAGING_ADDR/demo/hello"

kubectl -n jx-staging logs \
    -l app=jx-staging-go-demo-6

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

git commit -m "Added dependencies"

git push

jx get activity -f go-demo-6 -w

kubectl -n jx-staging get pods

kubectl -n jx-staging \
    describe pod \
    -l app=jx-staging-go-demo-6

git add .

git commit -m "Added dependencies"

git push

jx get activity -f go-demo-6 -w

kubectl -n jx-staging get pods

curl "$STAGING_ADDR/demo/hello"

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
