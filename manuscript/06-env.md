- [ ] Code
- [ ] Write
- [ ] Code review GKE
- [ ] Code review EKS
- [ ] Code review AKS
- [ ] Code review existing cluster
- [ ] Text review
- [ ] Diagrams
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Undestranding GitOps Principles

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

## Exploring Environments

---

```bash
cd go-demo-6

# Only if you had troubles to follow the previous chapter
git checkout buildpack

# Only if you had troubles to follow the previous chapter
git merge -s ours master --no-edit

# Only if you had troubles to follow the previous chapter
git checkout master

# Only if you had troubles to follow the previous chapter
git merge orig

# Only if you had troubles to follow the previous chapter
rm -rf charts

# Only if you had troubles to follow the previous chapter
git push

# Only if NOT reusing the cluster from the previous chapter
jx import --pack go-mongo -b

# Only if NOT reusing the cluster from the previous chapter
jx get activity -f go-demo-6 -w

# Only if NOT reusing the cluster from the previous chapter
# Press *ctrl+c*

jx get env
```

```
NAME       LABEL       KIND        PROMOTE NAMESPACE     ORDER CLUSTER SOURCE                                                         REF PR
dev        Development Development Never   jx            0                                                                                
staging    Staging     Permanent   Auto    jx-staging    100           https://github.com/vfarcic/environment-jx-rocks-staging.git        
production Production  Permanent   Manual  jx-production 200           https://github.com/vfarcic/environment-jx-rocks-production.git     
```

```bash
jx get env -p Auto
```

```
NAME    LABEL   KIND      PROMOTE NAMESPACE  ORDER CLUSTER SOURCE                                                      REF PR
staging Staging Permanent Auto    jx-staging 100           https://github.com/vfarcic/environment-jx-rocks-staging.git     
```

```bash
jx get env -p Manual
```

```
NAME       LABEL      KIND      PROMOTE NAMESPACE     ORDER CLUSTER SOURCE                                                         REF PR
production Production Permanent Manual  jx-production 200           https://github.com/vfarcic/environment-jx-rocks-production.git     
```

```bash
jx get env -p Never
```

```
NAME LABEL       KIND        PROMOTE NAMESPACE ORDER CLUSTER SOURCE REF PR
dev  Development Development Never   jx        0                        
```


## Exploring And Adapting The Staging Environment

---

```bash
cd ..

GH_USER=[...]

git clone https://github.com/$GH_USER/environment-jx-rocks-staging.git

cd environment-jx-rocks-staging

ls -1
```

```
Jenkinsfile
LICENSE
Makefile
README.md
env
```

```bash
cat Makefile
```

```
CHART_REPO := http://jenkins-x-chartmuseum:8080
DIR := "env"
NAMESPACE := "jx-staging"
OS := $(shell uname)

build: clean
	rm -rf requirements.lock
	helm version
	helm init
	helm repo add releases ${CHART_REPO}
	helm repo add jenkins-x http://chartmuseum.jenkins-x.io
	helm dependency build ${DIR}
	helm lint ${DIR}

install: 
	helm upgrade ${NAMESPACE} ${DIR} --install --namespace ${NAMESPACE} --debug

delete:
	helm delete --purge ${NAMESPACE}  --namespace ${NAMESPACE}

clean:
```

```bash
echo 'test:
	ADDRESS=`kubectl -n jx-staging \\
	get ing go-demo-6 \\
	-o jsonpath="{.spec.rules[0].host}"` \\
	go test -v' \
    | tee -a Makefile

# NOTE: There is a tab instead of spaces before `go test`

curl -sSLo integration_test.go \
    https://bit.ly/2Do5LRN

cat integration_test.go

cat Jenkinsfile
```

```groovy
pipeline {
  options {
    disableConcurrentBuilds()
  }
  agent {
    label "jenkins-maven"
  }
  environment {
    DEPLOY_NAMESPACE = "jx-staging"
  }
  stages {
    stage('Validate Environment') {
      steps {
        container('maven') {
          dir('env') {
            sh 'jx step helm build'
          }
        }
      }
    }
    stage('Update Environment') {
      when {
        branch 'master'
      }
      steps {
        container('maven') {
          dir('env') {
            sh 'jx step helm apply'
          }
        }
      }
    }
  }
}
```

```bash
# Change `label "jenkins-maven"` with `label "jenkins-go"`

# Change `container('maven')` with `container('go')`

# Add the following stage
```

```groovy
    stage('Test') {
      when {
        branch 'master'
      }
      steps {
        container('go') {
          sh 'make test'
        }
      }
    }
```

```bash
curl -sSLo Jenkinsfile \
    https://bit.ly/2TB2Mw5
```

```bash
ls -1 env
```

```
Chart.yaml
requirements.yaml
templates
values.yaml
```

```bash
cat env/requirements.yaml
```

```yaml
dependencies:
- alias: expose
  name: exposecontroller
  repository: http://chartmuseum.jenkins-x.io
  version: 2.3.89
- alias: cleanup
  name: exposecontroller
  repository: http://chartmuseum.jenkins-x.io
  version: 2.3.89
- name: go-demo-6
  repository: http://jenkins-x-chartmuseum:8080
  version: 0.0.131
```

```bash
git add .

git commit -m "Added tests"

git push

jx get activity \
    -f environment-jx-rocks-staging \
    -w

jx get build logs \
    $GH_USER/environment-jx-rocks-staging/master

jx console

# Open the last build inside the *environment-jx-rocks-staging* job

kubectl -n jx-staging get pods

# The Pods were not updated (it's idempotent)
```


## Changing Prod Environment

---

```bash
cd ..

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-production.git

cd environment-jx-rocks-production

echo 'test:
	ADDRESS=`kubectl -n jx-production \\
	get ing go-demo-6 \\
	-o jsonpath="{.spec.rules[0].host}"` \\
	go test -v' \
    | tee -a Makefile

# NOTE: There is a tab instead of spaces before `go test`

curl -sSLo integration_test.go \
    https://bit.ly/2Do5LRN

curl -sSLo Jenkinsfile \
    https://bit.ly/2BsUQWM

git add .

git commit -m "Added tests"

git push

jx get activity \
    -f environment-jx-rocks-production \
    -w

# It failed because we did not deploy *go-demo-6* to production

# Explain what happens when there are multiple applications
```
