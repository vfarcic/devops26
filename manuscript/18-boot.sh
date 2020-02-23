# Source: https://gist.github.com/8af2cdfe9ffad2beac9c1e89cf863a46

# Links to gists for creating a Kubernetes cluster
# gke.sh: https://gist.github.com/1b7a1c833bae1d5da02f4fd7b3cd3c17
# eks.sh: https://gist.github.com/3eaa9b10cb59424fc0447a563112f32e

open "https://github.com/jenkins-x/jenkins-x-boot-config"

CLUSTER_NAME=[...] # e.g., jx-gke

GH_USER=[...]

git clone \
    https://github.com/jenkins-x/jenkins-x-boot-config.git \
    environment-$CLUSTER_NAME-dev

cd environment-$CLUSTER_NAME-dev

cat jx-requirements.yml

# Open requirements.yaml in an editor

# Set `cluster.clusterName`
# Set `cluster.environmentGitOwner`
# Set `cluster.project` (if GKE)
# Set `cluster.provider
# Set `cluster.zone`
# Set `secretStorage` to `vault`
# Set `storage.logs.enabled` to `true`
# Set `storage.reports.enabled` to `true`
# Set `storage.repository.enabled` to `true`

# If EKS
export IAM_USER=[...] # e.g., jx-boot

# If EKS
echo "vault:
  aws:
    autoCreate: true
    iamUserName: \"$IAM_USER\"" \
    | tee -a jx-requirements.yml

# If EKS
cat jx-requirements.yml \
    | sed -e \
    's@zone@region@g' \
    | tee jx-requirements.yml

cat jx-requirements.yml

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
