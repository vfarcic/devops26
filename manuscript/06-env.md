- [ ] Code
- [ ] Write
- [X] Code review GKE
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

Git is the de-facto code repository standard. That's where we keep our code. Hardly anyone argues against that statement today. Where we might disagree is whether Git is the only source of truth.

When I speak with teams and ask them whether Git is their only source of truth, almost everyone always answer "yes". However, when I start digging, it usually turns out that's not true. Can you recreate everything only using code in Git? By everything, I mean the whole cluster and everything running in it? Is your whole production system described in a single repository? If the answer to that question is "yes", you are doing a great job, but we're not yet done with questioning. Can any change to your system be applied by making a pull request, without pressing any buttons in Jenkins or any other tool? If your answer is still "yes", you are most likely already applying GitOps principles.

GitOps is a way to do Continuous Delivery. It assumes that Git is a single source of truth and that both infrastructure and applications are defined using declarative syntax (e.g., YAML). Changes to infrastructure or applications are made by pushing changes to Git, not by clicking buttons in Jenkins.

Developers understood the need for having a single source of truth for their applications a while back. Nobody argues any more that eveerything an application needs must be stored in the repository of that application. That's where the code is, that's where the tests are, that's where build scripts are located, and that's where the pipeline of that application is defined. The part that is not yet that common is to apply the same principles to infrastructure. We can think of an environment (e.g., production) as an application. As such, everything we need related to an environment must be stored in a single Git repository. As such, we should be able to recreate the whole environment, from nothing to everything, by executing a single process based only on information in that repository. We can also leverage development principles we apply to applications. A rollback is done by reverting the code to one of the Git revisions. Accepting a change to an environment is a process that starts with a pull request. And so on, and so forth.

The major challenge in applying GitOps principles is to unify the steps specific to an application with those related to creation of the whole environment. At some moment, pipeline dedicated to our application needs to push a change to the repository that contains an environment. In turn, since every process is initiated through a Git webhook fired when there is a change, pushing something to an environment repo should initiate another pipeline.

To illustrate that, we'll imagine a typical flow of a CD pipeline. In a simplified version, it would have the following stages.

* Build
* Test
* Release
* Deploy

Where many diverge from "Git as the only source of truth" is in the release phase. Teams often build a Docker image and deploy it to a cluster without storing the information about the specific release to Git. Stating that the information about the release is stored in Jenkins breaks the principle of having a single source of truth. It prevents us from being able to recreate the whole production system through information from a single Git repository. Similarly, saying that the information about the release is stored as a Git tag also breaks the principle of having everything stored in declarative format that allows us to recreate the whole system from a single repository. The correct way to execute the before mentioned flow would be to have two pipelines. A push to the application repository would initiate a pipeline that would build, test, and package the application. It would end by pushing a change to the repository that defines the whole production environment. In turn, that would would initiate a different pipeline that would redeploy the whole production environment, not only the new release of the application in question. That way, we would always have a single source of truth. Nothing is done without pushing code to a code repository. For all that to work, we need to assemble a process and to leverage a few tools.

TODO: Diagram

Having everything defined in code and stored in Git is not enough. We need those definitions and that code to be used reliably. Reproducibility is one of the key features we're loiking for. Unfortunatelly, we (humans) are not good at performing reproducible actions. We make mistakes and we are incapable of doing the exactly the same thing twice. We are not reliable. Machines are. Given that the conditions did not change, a script will do exactly the same thing every time we run it. A declarative approach to define things gives us idempotency. Where we do excel is creativity. We are good at writing scripts and configurations, but not are running them. Ideally, every single action performed anywhere inside our systems should be executed by a machine, not by us. We accimplish those things by storing the code in a repository, and letting all the actions execute as a result of a webhook firing an event on every push of a change.

But why do we want to use declarative syntax to describe our systems? The main reason is in idempotency provided through our experssion of a desire, instead of an imperative statement. If we say create ten servers. We might end up with fifteen if there are already five nodes running. On the other hand, if we declaratively expess that there should be tend servers, we can have a system that will check how many do we have, and increase or decrease the

Was that explanation confusing? Are you wondering whether it makes sense and if it does how to do that? Worry not. Our next mission is to put GitOps into practice and use practical examples to explain GitOps principles and implementation. Everything will become much clearer soon. But, as in the previous chapters, we need to create the cluster first.

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

You know the story. We need a cluster with Jenkins X up-and-running, unless you kept the one from the before.

I> All the commands from this chapter are available in the [06-env.sh](TODO:) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Use an **existing** cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)

```bash
jx version

TODO: Output
```

```bash
cd go-demo-6
```

I> The commands that follow will reset your master branch with the contents of the `buildpack` branch that contains all the changes we did in the previous chapter. Please execute them if you are unsure whether you did all the exercises correctly.

```bash
git checkout buildpack

git merge -s ours master --no-edit

git checkout master

git merge orig

git push
```

I> If you destroyed the cluster at the end of the previous chapter, we'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specificaly for the execises we'll perform next.

```bash
jx import -b

jx get activity -f go-demo-6 -w
```

Please wait until the activity of the application shows that all the steps were executed successfully, and stop the watcher by pressing *ctrl+c*.

Now we can explore GitOps through Jenkins X environment.

## Exploring Jenkins X Environments

We'll continue using the *go-demo-6* application. This time, we'll dive deeper into the role of the staging environment and how it relates to the process executed when we push a change to an application. So, let's take a look at the environments we currently have.

TODO: Continue the text

```bash
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

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-staging.git

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
    https://bit.ly/2Dr1Kfk

cat Jenkinsfile
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


## Exploring And Adapting The Production Environment

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

# TODO: `jx create env`

# TODO: `jx delete env`

# TODO: `jx edit env``
```

## What Now?


```bash
# New
cd ..

# New
rm -rf environment-jx-rocks-*

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -f ~/.jx/jenkinsAuth.yaml
```