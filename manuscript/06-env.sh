# Links to gists for creating a cluster with jx
# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# eks-jx.sh: https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac
# aks-jx.sh: https://gist.github.com/6e01717c398a5d034ebe05b195514060
# install.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

cd go-demo-6

git checkout buildpack

git merge -s ours master --no-edit

git checkout master

git merge buildpack

git push

jx import --batch-mode

jx get activity -f go-demo-6 -w

jx get env

jx get env -p Auto

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-staging.git

cd environment-jx-rocks-staging

ls -1

cat Makefile

echo 'test:
	ADDRESS=`kubectl \
	--namespace jx-staging \\
	get ingress go-demo-6 \\
	-o jsonpath="{.spec.rules[0].host}"` \\
	go test -v' \
    | tee -a Makefile

curl -sSLo integration_test.go \
    https://bit.ly/2Do5LRN

cat integration_test.go

cat Jenkinsfile

curl -sSLo Jenkinsfile \
    https://bit.ly/2Dr1Kfk

ls -1 env

cat env/requirements.yaml

git add .

git commit \
    --message "Added tests"

git push

jx get activity \
    -f environment-jx-rocks-staging

jx get build logs \
    $GH_USER/environment-jx-rocks-staging/master

jx console

kubectl --namespace jx-staging get pods

cat env/requirements.yaml

jx create env \
    --name pre-production \
    --label Pre-Production \
    --namespace jx-pre-production \
    --promotion Manual \
    --batch-mode

jx get env

jx edit env \
    --name pre-production \
    --promotion Auto

jx delete env pre-production

GH_USER=[...]

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
