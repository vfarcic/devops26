# Links to gists for creating a cluster with jx
# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# eks-jx.sh: https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac
# aks-jx.sh: https://gist.github.com/6e01717c398a5d034ebe05b195514060
# install.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

cd go-demo-6

git checkout dev

git merge -s ours master --no-edit

git checkout master

git merge dev

git push

jx import -b

jx get activities -f go-demo-6 -w

cat Jenkinsfile

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

git commit -m "This is a PR"

git push --set-upstream origin my-pr

jx create pr \
  -t "My PR" \
  --body "This is the text that describes the PR
and it can span multiple lines" \
  -b

jx get previews

PR_ADDR=[...]

curl "$PR_ADDR/demo/hello"

helm ls

jx create issue -t "Add unit tests" \
    --body "Add unit tests to the CD process" \
    -b

ISSUE_ID=[...]

git add .

git commit \
  -m "Added unit tests (fixes #$ISSUE_ID)"

git push

jx get issues -b

echo '
functest: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) \\
	test -test.v --run FunctionalTest \\
	--cover
' | tee -a Makefile

echo '
integtest: 
	DURATION=1 \\
	CGO_ENABLED=$(CGO_ENABLED) $(GO) \\
	test -test.v --run ProductionTest \\
	--cover
' | tee -a Makefile

git add .

git commit -m "Added integration tests"

git push

jx get build logs

cat charts/go-demo-6/values.yaml

echo "
  usePassword: false" \
  | tee -a charts/go-demo-6/values.yaml

echo "
  usePassword: false" \
  | tee -a charts/preview/values.yaml

git add .

git commit -m "Removed MongoDB password"

git push

jx get activity -f go-demo-6 -w

jx get applications

STAGING_ADDR=[...] # Replace `[...]` with the URL

curl "$STAGING_ADDR/demo/hello"

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

rm -f ~/.jx/jenkinsAuth.yaml
