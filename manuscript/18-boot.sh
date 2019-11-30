# Links to gists for creating a Kubernetes cluster
# gke.sh: https://gist.github.com/1b7a1c833bae1d5da02f4fd7b3cd3c17

open "https://github.com/jenkins-x/jenkins-x-boot-config"

CLUSTER_NAME=[...]

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/jenkins-x-boot-config.git
 \
    environment-$CLUSTER_NAME-dev

cd environment-$CLUSTER_NAME-dev

cat jx-requirements.yml

# Open requirements.yaml in an editor

# Set `cluster.clusterName`
# Set `cluster.environmentGitOwner`
# Set `cluster.project`
# Set `cluster.provider
# Set `cluster.zone`
# Set `secretStorage` to `vault`
# Set `storage.logs.enabled` to `true`
# Set `storage.reports.enabled` to `true`
# Set `storage.repository.enabled` to `true`

cat jx-requirements.yml

jx boot

jx boot

git --no-pager diff origin/master..HEAD

cat env/parameters.yaml

cat jenkins-x.yml

cat jx-requirements.yml

jx get pipelines -o yaml

echo "A trivial change" \
    | tee -a README.md

git add .

git commit -m "A trivial change"

git push

jx get activities \
    --filter environment-$CLUSTER_NAME-dev \
    --watch

kubectl get namespaces

jx get env

cd ..

jx create quickstart \
    --filter golang-http

jx get activity \
    --filter jx-boot/master \
    --watch

jx get activity \
    --filter environment-$CLUSTER_NAME-staging/master \
    --watch

kubectl get namespaces

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-staging

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-production

hub delete -y \
    $GH_USER/jx-boot

rm -rf jx-boot
