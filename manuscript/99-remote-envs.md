```bash
# Requirement: an existing dev cluster

helm repo add jx-labs \
    https://storage.googleapis.com/jenkinsxio-labs-private/charts

jx add app \
    --repository=https://storage.googleapis.com/jenkinsxio-labs-private/charts \
    jx-app-cb-remote

jx get apps

export REMOTE_CLUSTER_NAME=[...] # Replace `[...]` with the name of a non-dev cluster (e.g., `staging`)

export PROJECT_ID=[...] # Replace `[...]` with the project ID

gcloud container clusters \
    create $REMOTE_CLUSTER_NAME \
    --project $PROJECT_ID \
    --region us-east1 \
    --machine-type e2-standard-4 \
    --enable-autoscaling \
    --num-nodes 1 \
    --max-nodes 3 \
    --min-nodes 1

export GH_OWNER=[...] # Replace `[...]` with the GitHub owner

export GH_USER=[...] # Replace `[...]` with the GitHub user

export ENVIRONMENT_AUTO=[...] # Replace `[...]` with the name of the environment (e.g., `integration`)

# Use the default answers
jx remote create \
    --env $ENVIRONMENT_AUTO \
    --provider gke \
    --env-git-owner $GH_OWNER \
    --approver $GH_USER

git clone https://github.com/$GH_OWNER/environment-$REMOTE_CLUSTER_NAME

cd environment-$REMOTE_CLUSTER_NAME

cat jx-requirements.yml

# TODO: Replace some values in jx-requirements.yml

jx remote secrets edit

jx remote run

cd ..

jx context # Switch to the dev cluster

# TODO: Change to jx-requirements.yaml in the dev repo
jx create env \
    --name $ENVIRONMENT_AUTO \
    --git-url https://github.com/$GH_OWNER/environment-$REMOTE_CLUSTER_NAME \
    --remote

export ENVIRONMENT_MANUAL=[...] # Replace `[...]` with the name of the environment (e.g., `pre-prod`)

jx context # Switch to the remote cluster

# Use the default answers except to the `git repository name` question. Use `echo environment-$ENVIRONMENT_MANUAL`.
jx remote create \
    --env $ENVIRONMENT_MANUAL \
    --provider gke \
    --env-git-owner $GH_OWNER \
    --approver $GH_USER

git clone https://github.com/$GH_OWNER/environment-$ENVIRONMENT_MANUAL

cd environment-$ENVIRONMENT_MANUAL

cat jx-requirements.yml

# TODO: Replace some values in jx-requirements.yml

# Select `Manual` as the `Promotion Strategy`
jx create env \
    --name $ENVIRONMENT_MANUAL \
    --git-url https://github.com/$GH_OWNER/environment-$ENVIRONMENT_MANUAL \
    --remote

jx get environments

cd ..

jx context # Switch to the dev cluster

jx create quickstart \
    --name test1 \
    --project-name test1 \
    --filter golang-http

jx get activities \
    --filter test1 \
    --watch

export DEV_CLUSTER_NAME=[...] # Replace with the name of the `dev` cluster
    
jx get activities \
    --filter environment-$DEV_CLUSTER_NAME-dev/master \
    --watch

jx get activities \
    --filter environment-$DEV_CLUSTER_NAME-staging/master \
    --watch

jx get activities \
    --filter environment-$ENVIRONMENT_AUTO \
    --watch

jx get applications

export STAGING_ADDR=[...]

curl $STAGING_ADDR

jx context # Change to the remote cluster

jx remote applications

# TODO: Promote to the remote env manually
```

## Cleanup

```bash
gcloud container clusters \
    delete $REMOTE_CLUSTER_NAME \
    --project $PROJECT_ID \
    --region us-east1 \
    --quiet

hub delete -y $GH_OWNER/environment-$REMOTE_CLUSTER_NAME

rm -rf environment-$REMOTE_CLUSTER_NAME

hub delete -y $GH_OWNER/environment-$ENVIRONMENT_AUTO

rm -rf environment-$ENVIRONMENT_AUTO

hub delete -y $GH_OWNER/environment-$ENVIRONMENT_MANUAL

rm -rf environment-$ENVIRONMENT_MANUAL

hub delete -y $GH_OWNER/test1

rm -rf test1
```