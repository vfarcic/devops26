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

kubectl get ns

jx profile cloudbees

open "https://github.com/cloudbees/cloudbees-jenkins-x-boot-config"

# Fork it

# Settings > Change the name to `environment-tekton-dev`

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-tekton-dev.git

cd environment-tekton-dev

jx boot
```