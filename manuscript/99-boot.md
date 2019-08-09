```bash
jx version

PROJECT=[...] # Replace `[...]` with the name of the GCP project (e.g. jx).

jx create cluster gke \
    --cluster-name jx-rocks \
    --project-id $PROJECT \
    --region us-east1 \
    --machine-type n1-standard-2 \
    --min-num-nodes 1 \
    --max-num-nodes 2 \
    --skip-installation \
    --batch-mode

kubectl get nodes

# jx profile cloudbees

open "https://github.com/cloudbees/cloudbees-jenkins-x-boot-config"

# Fork it

# Settings > Change the name to `environment-tekton-dev`

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-tekton-dev.git

cd environment-tekton-dev

# https://github.com/jenkins-x/jx/issues/4836

gsutil mb -l us-east1 -p devops26 gs://jx-rocks-logs

gsutil mb -l us-east1 -p devops26 gs://jx-rocks-reports

gsutil mb -l us-east1 -p devops26 gs://jx-rocks-charts

gsutil mb -l us-east1 -p devops26 gs://jx-vault-jx-rocks-bucket

jx boot
```

## What Now?

```bash
cd ..

GH_USER=[...]

hub delete -y \
    $GH_USER/environment-tekton-dev

hub delete -y \
    $GH_USER/environment-jx-rocks-dev

hub delete -y \
    $GH_USER/environment-jx-rocks-staging

hub delete -y \
    $GH_USER/environment-jx-rocks-production

rm -rf environment-tekton-dev

# jx profile oss

# Delete storage
```