# Links to gists for creating a cluster with jx
# gke-jx-serverless.sh: https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8
# eks-jx-serverless.sh: https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd
# aks-jx-serverless.sh: https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410
# install-serverless.sh: https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037

cd go-demo-6

git pull

git checkout buildpack-tekton

git merge -s ours master --no-edit

git checkout master

git merge buildpack-tekton

git push

# If GKE
cat charts/go-demo-6/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/go-demo-6/Makefile

# If GKE
cat charts/preview/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee charts/preview/Makefile

# If GKE
cat skaffold.yaml \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | tee skaffold.yaml

jx import --batch-mode

jx get activity \
    --filter go-demo-6 \
    --watch

jx get env

jx get env --promote Auto

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-staging.git

cd environment-jx-rocks-staging

ls -1

cat Makefile

cat env/requirements.yaml

jx create env \
    --name pre-production \
    --label Pre-Production \
    --namespace jx-pre-production \
    --promotion Manual \
    --batch-mode

jx get env

jx delete env pre-production

hub delete -y \
  $GH_USER/environment-jx-pre-production

cd ..

rm -rf environment-jx-rocks-*

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
