# Source: https://gist.github.com/ca1d91973560dc0bd385c471437069ab

# Links to gists for creating a cluster with jx
# gke-jx-serverless.sh: https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8
# eks-jx-serverless.sh: https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd
# aks-jx-serverless.sh: https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410
# install-serverless.sh: https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037

GH_USER=[...]

jx delete application \
    $GH_USER/jx-prow \
    --batch-mode

cd go-demo-6

git pull

git checkout versioning-tekton

git merge -s ours master --no-edit

git checkout master

git merge versioning-tekton

git push

cd ..

# If GKE
cd go-demo-6

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

# If GKE
cd ..

jx import --batch-mode

jx get activities \
    --filter go-demo-6 \
    --watch

cd ..

cat jenkins-x.yml

buildPack: go

open "https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes"

curl "https://raw.githubusercontent.com/jenkins-x-buildpacks/jenkins-x-kubernetes/master/packs/go/pipeline.yaml"

curl "https://raw.githubusercontent.com/jenkins-x-buildpacks/jenkins-x-classic/master/packs/go/pipeline.yaml"

jx get activities \
    --filter go-demo-6 \
    --watch

git checkout -b extension

cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@replicaCount: 1@replicaCount: 3@g' \
    | tee charts/go-demo-6/values.yaml

cat functional_test.go \
    | sed -e \
    's@fmt.Sprintf("http://@fmt.Sprintf("@g' \
    | tee functional_test.go

cat production_test.go \
    | sed -e \
    's@fmt.Sprintf("http://@fmt.Sprintf("@g' \
    | tee production_test.go

jx create step

cat jenkins-x.yml

git add .

git commit \
    --message "Trying to extend the pipeline"

git push --set-upstream origin extension

jx create pullrequest \
    --title "Extensions" \
    --body "What I can say?" \
    --batch-mode

PR_ADDR=[...] # e.g., `https://github.com/vfarcic/go-demo-6/pull/56`

BRANCH=[...] # e.g., `PR-56`

jx get build logs \
    --filter go-demo-6 \
    --branch $BRANCH

echo 'functest: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) \\
	test -test.v --run FunctionalTest \\
	--cover
' | tee -a Makefile

jx create step \
    --pipeline pullrequest \
    --lifecycle promote \
    --mode post \
    --sh 'ADDRESS=`jx get preview --current 2>&1` make functest'

cat jenkins-x.yml

git add .

git commit \
    --message "Trying to extend the pipeline"

git push

jx get build logs \
    --filter go-demo-6 \
    --branch $BRANCH

jx create step \
    --pipeline pullrequest \
    --lifecycle promote \
    --mode post \
    --sh 'ADDRESS=http://this-domain-does-not-exist.com make functest'

git add .

git commit \
    --message "Added sully tests"

git push

jx get build logs \
    --filter go-demo-6 \
    --branch $BRANCH

open "$PR_ADDR"

cat jenkins-x.yml \
  | sed '$ d' \
  | tee jenkins-x.yml

git add .

git commit \
    --message "Removed the silly test"

git push

cd ..

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-staging.git

cd environment-jx-rocks-staging

cat jenkins-x.yml

curl https://raw.githubusercontent.com/jenkins-x-buildpacks/jenkins-x-kubernetes/master/packs/environment/pipeline.yaml

jx create step \
    --pipeline release \
    --lifecycle postbuild \
    --mode post \
    --sh 'echo "Running integ tests!!!"'

cat jenkins-x.yml

git add .

git commit \
    --message "Added integ tests"

git push

jx get build logs \
    --filter environment-jx-rocks-staging \
    --branch master

open "$PR_ADDR"

cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf environment-jx-rocks-staging
