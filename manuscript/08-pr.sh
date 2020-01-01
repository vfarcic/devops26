# Source: https://gist.github.com/fabed5404bec733ed5eb264124e90721

# Links to gists for creating a cluster with jx
# gke-jx-serverless.sh: https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8
# eks-jx-serverless.sh: https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd
# aks-jx-serverless.sh: https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410
# install-serverless.sh: https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037

cd go-demo-6

git pull

git checkout dev-tekton

git merge -s ours master --no-edit

git checkout master

git merge dev-tekton

git push

# If GKE
cat charts/go-demo-6/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | sed -e \
    "s@devops-26@$PROJECT@g" \
    | tee charts/go-demo-6/Makefile

# If GKE
cat charts/preview/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | sed -e \
    "s@devops-26@$PROJECT@g" \
    | tee charts/preview/Makefile

# If GKE
cat skaffold.yaml \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | sed -e \
    "s@devops-26@$PROJECT@g" \
    | tee skaffold.yaml

jx import --batch-mode

jx get activities \
    --filter go-demo-6 \
    --watch

git checkout -b my-pr

cat main.go | sed -e \
    "s@hello, devpod with tests@hello, PR@g" \
    | tee main.go

cat main_test.go | sed -e \
    "s@hello, devpod with tests@hello, PR@g" \
    | tee main_test.go

echo "

db:
  enabled: false
  
preview-db:
  persistence:
    enabled: false" \
  | tee -a charts/preview/values.yaml

git add .

git commit \
    --message "This is a PR"

git push --set-upstream origin my-pr

jx create pullrequest \
    --title "My PR" \
    --body "This is the text that describes the PR
and it can span multiple lines" \
    --batch-mode

jx get previews

PR_ADDR=[...]

curl "$PR_ADDR/demo/hello"

cat charts/go-demo-6/values.yaml

echo "
  usePassword: false" \
  | tee -a charts/go-demo-6/values.yaml

echo "
  usePassword: false" \
  | tee -a charts/preview/values.yaml

git add .

git commit \
    --message "Removed MongoDB password"

git push

jx get activity \
    --filter go-demo-6 \
    --watch

jx get applications

STAGING_ADDR=[...] # Replace `[...]` with the URL

curl "$STAGING_ADDR/demo/hello"

git checkout master

git pull

kubectl get cronjobs

jx get previews

jx gc previews

jx get previews

cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
