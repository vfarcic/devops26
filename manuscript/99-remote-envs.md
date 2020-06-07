```bash
# Requirement: an existing dev cluster

helm repo add jx-labs \
    https://storage.googleapis.com/jenkinsxio-labs-private/charts

jx add app \
    --repository=https://storage.googleapis.com/jenkinsxio-labs-private/charts \
    jx-app-cb-remote

jx get apps

export CLUSTER_NAME=[...] # Replace `[...]` with the name of a non-dev cluster (e.g., `staging`)

export PROJECT_ID=[...] # Replace `[...]` with the project ID

gcloud container clusters \
    create $CLUSTER_NAME \
    --project $PROJECT_ID \
    --region us-east1 \
    --machine-type e2-standard-4 \
    --enable-autoscaling \
    --num-nodes 1 \
    --max-nodes 3 \
    --min-nodes 1

export GH_OWNER=[...] # Replace `[...]` with the GitHub owner

export GH_USER=[...] # Replace `[...]` with the GitHub user

export ENVIRONMENT=[...] # Replace `[...]` with the name of the environment (e.g., `staging`)

# Use the default answers
jx remote create \
    --env $ENVIRONMENT \
    --provider gke \
    --env-git-owner $GH_OWNER \
    --approver $GH_USER

git clone https://github.com/$GH_OWNER/environment-$ENVIRONMENT

cd environment-$ENVIRONMENT

jx remote secrets edit

jx remote run

cd ..

export DEV_REPO_PATH=[...]

cd $DEV_REPO_PATH

echo "
- ingress:
    domain: ""
    externalDNS: false
    namespaceSubDomain: ""
    tls:
      email: ""
      enabled: false
      production: false
  key: $ENVIRONMENT
  repository: environment-$ENVIRONMENT
  remoteCluster: true"

vim jx-requirements.yml

# Copy & paste the output into the `environments:` section

# Save and exit

git add .

git commit -m "Added remote environment"

git push

jx get activities --filter dev --watch

# Cancel with ctrl+c when the activity is finished

jx get environments

cd ..
```

## Cleanup

```bash
gcloud container clusters \
    delete $CLUSTER_NAME \
    --project $PROJECT_ID \
    --region us-east1 \
    --quiet

hub delete -y $GH_OWNER/environment-staging

rm -rf environment-staging
```