# Source: https://gist.github.com/ac2407f0aab33e65e9ca8f247b6451bf

# Links to gists for creating a cluster with jx
# gke-jx-serverless.sh: https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8
# eks-jx-serverless.sh: https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd
# aks-jx-serverless.sh: https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410
# install-serverless.sh: https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037

GH_USER=[...]

jx delete application \
    $GH_USER/jx-serverless \
    --batch-mode

jx create quickstart \
  --filter golang-http \
  --project-name jx-prow \
  --batch-mode

cd jx-prow

jx get activities \
  --filter jx-prow \
  --watch

git checkout -b chat-ops

echo "ChatOps" | tee README.md

git add .

git commit \
    --message "My first PR with prow"

git push --set-upstream origin chat-ops

jx create pullrequest \
    --title "PR with prow" \
    --body "What I can say?" \
    --batch-mode

git checkout master

cat OWNERS

GH_USER=[...]

GH_APPROVER=[...]

echo "approvers:
- $GH_USER
- $GH_APPROVER
reviewers:
- $GH_USER
- $GH_APPROVER
" | tee OWNERS

git add .

git commit \
    --message "Added an owner"

git push

open "https://github.com/$GH_USER/jx-prow/settings/collaboration"

git checkout master

git pull

git checkout -b my-pr

echo "My PR" | tee README.md

git add .

git commit \
    --message "My second PR with prow"

git push --set-upstream origin my-pr

jx create pullrequest \
    --title "My PR" \
    --body "What I can say?" \
    --batch-mode

kubectl --namespace jx \
    describe cm plugins

cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

hub delete -y $GH_USER/jx-prow

rm -rf jx-prow

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
