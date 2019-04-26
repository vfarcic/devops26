# Links to gists for creating a cluster with jx
# gke-jx.sh: https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18
# eks-jx.sh: https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac
# aks-jx.sh: https://gist.github.com/6e01717c398a5d034ebe05b195514060
# install.sh: https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233

cd go-demo-6

git checkout master

jx import --batch-mode

jx get activities -f go-demo-6 -w

jx get applications

jx create devpod -b

jx rsh -d

cd go-demo-6

curl -L \
  -o /usr/local/bin/jx-release-version \
  https://github.com/jenkins-x/jx-release-version/releases/download/v1.0.17/jx-release-version-linux

chmod +x \
  /usr/local/bin/jx-release-version

git tag

jx-release-version

git tag v1.0.0

jx-release-version

exit

jx delete devpod

# Add `VERSION := 1.0.0` to Makefile`

jx-release-version

cat Jenkinsfile

cat Jenkinsfile

git add .

git commit -m "Finally 1.0.0"

git push

jx get activities -f go-demo-6 -w

jx get applications

GH_USER=[...]

open "https://github.com/$GH_USER/go-demo-6/releases"

echo "A silly change" | tee README.md

git add .

git commit -m "A silly change"

git push

jx get activity -f go-demo-6 -w

cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*
