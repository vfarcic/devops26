## TODO

- [ ] Code
- [ ] Write
- [X] Code review static GKE
- [ ] Code review serverless GKE
- [ ] Code review static EKS
- [ ] Code review serverless EKS
- [ ] Code review static AKS
- [ ] Code review serverless AKS
- [ ] Code review existing static cluster
- [ ] Code review existing serverless cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

## Creating A Kubernetes Cluster With Jenkins X And Importing The Application

## Creating A Kubernetes Cluster With Jenkins X

TODO: Viktor: This text is from some other change. Rewrite it.

If you kept the cluster from the previous chapter, you can skip this section. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [TODO: Viktor](TODO: Viktor) Gist.

For your convenience, the Gists from the previous chapter are available below as well.

* Create new static **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new static **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new static **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** static cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

TODO: Intro to the next section

## Something

```bash
# If serverless
ENVIRONMENT=tekton

# If static
ENVIRONMENT=jx-rocks

rm -rf environment-$ENVIRONMENT-*

# Ignore the `no matches found` error

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-$ENVIRONMENT-staging.git

cd environment-$ENVIRONMENT-staging

echo "- name: postgresql
  version: 4.0.2
  repository: https://kubernetes-charts.storage.googleapis.com" \
    | tee -a env/requirements.yaml

git add .

git commit -m "Added PostgreSQL"

git push

jx get activities \
    --filter environment-$ENVIRONMENT-staging \
    --watch

# Stop with *ctrl+c*

# If serverless
NAMESPACE=cd

# If static
NAMESPACE=jx

kubectl \
    --namespace $NAMESPACE-staging \
    get pods

cd ..

git clone \
    https://github.com/$GH_USER/environment-$ENVIRONMENT-production.git

cd environment-$ENVIRONMENT-production

helm inspect chart stable/postgresql

echo "- name: postgresql
  version: 4.0.2
  repository: https://kubernetes-charts.storage.googleapis.com" \
    | tee -a env/requirements.yaml

helm inspect values stable/postgresql

echo "postgresql:
  replication:
    enabled: true" \
    | tee -a env/values.yaml

git add .

git commit -m "Added PostgreSQL"

git push

jx get activities \
    --filter environment-$ENVIRONMENT-production \
    --watch

# Stop with *ctrl+c*

kubectl \
    --namespace $NAMESPACE-production \
    get pods

# TODO: There is no promotion mechanism.
# TODO: Comment on the option of running only in production.
# TODO: Does not work well with app-specific testss

cd ..

jx create quickstart \
    --language go \
    --project-name prometheus \
    --batch-mode

jx get activities \
    --filter prometheus \
    --watch

# Stop with *ctrl+c*

kubectl \
    --namespace $NAMESPACE-staging \
    get pods

cd prometheus

helm inspect chart stable/prometheus

helm inspect values stable/prometheus

echo "dependencies:
- name: prometheus
  version: 8.11.2
  repository: https://kubernetes-charts.storage.googleapis.com" \
    | tee charts/prometheus/requirements.yaml

git add .

git commit -m "Added Prometheus dependency"

git push

jx get activities \
    --filter prometheus \
    --watch

# Stop with *ctrl+c*

kubectl \
    --namespace $NAMESPACE-staging \
    get pods

rm -f \
    Dockerfile \
    Makefile \
    curlloop.sh \
    main.go \
    skaffold.yaml \
    watch.sh \
    charts/prometheus/templates/*.yaml

rm -rf charts/preview

# TODO: PRs would be difficult because helm does not (yet) support nested dependencies

# If serverless
# TODO: https://github.com/jenkins-x/jx/issues/3961
# TODO: Remove the whole `pullRequest` pipeline
# TODO: Remove the whole `build` lifecycle from the `release` pipeline
# TODO: Modify jenkins-x.yml

# If static
echo 'pipeline {
  agent {
    label "jenkins-go"
  }
  environment {
    ORG = "vfarcic"
    APP_NAME = "prometheus"
    CHARTMUSEUM_CREDS = credentials("jenkins-x-chartmuseum")
  }
  stages {
    /* TODO: Removed
    stage("CI Build and push snapshot") {
      when {
        branch "PR-*"
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container("go") {
          dir("/home/jenkins/go/src/github.com/vfarcic/prometheus") {
            checkout scm
            sh "make linux"
            sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }
          dir("/home/jenkins/go/src/github.com/vfarcic/prometheus/charts/preview") {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
    }
    */
    stage("Build Release") {
      when {
        branch "master"
      }
      steps {
        container("go") {
          dir("/home/jenkins/go/src/github.com/vfarcic/prometheus") {
            checkout scm

            sh "git checkout master"
            sh "git config --global credential.helper store"
            sh "jx step git credentials"

            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
            sh "jx step tag --version \$(cat VERSION)"
            // sh "make build" // TODO: Remove
            // sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml" // TODO: Remove
            // sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)" // TODO: Remove
          } 
        }
      }
    }
    stage("Promote to Environments") {
      when {
        branch "master"
      }
      steps {
        container("go") {
          dir("/home/jenkins/go/src/github.com/vfarcic/prometheus/charts/prometheus") {
            sh "jx step changelog --version v\$(cat ../../VERSION)"

            // release the helm chart
            sh "jx step helm release"

            // promote through all "Auto" promotion Environments
            sh "jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)"
          }
        }
      }
    }
  }
}' | tee Jenkinsfile

git add .

git commit -m "Improved Jenkinsfile"

git push

jx get activities \
    --filter prometheus \
    --watch

# Stop with *ctrl+c*

kubectl \
    --namespace $NAMESPACE-staging \
    get pods

kubectl \
    --namespace $NAMESPACE-staging \
    get ingress

echo 'prom:
  server:
    service:
      annotations:
        fabric8.io/expose: "true"
        fabric8.io/ingress.annotations: "kubernetes.io/ingress.class: nginx"' \
    | tee -a charts/prometheus/values.yaml

git add .

git commit -m "Added ingress"

git push

jx get activities \
    --filter prometheus \
    --watch

kubectl \
    --namespace $NAMESPACE-staging \
    get ingress

PROM_STAGING_ADDR=$(kubectl \
    --namespace $NAMESPACE-staging \
    get ingress prom-server \
    --output jsonpath="{.spec.rules[0].host}")

echo $PROM_STAGING_ADDR

open "http://$PROM_STAGING_ADDR"

jx get applications

# NOTE: Incorrrect. Check the version from GitHub

VERSION=[...]

jx promote prometheus \
    --version $VERSION \
    --env production \
    --batch-mode

kubectl \
    --namespace jx-production \
    get ingress

cd ../environment-$ENVIRONMENT-production

LB_IP=$(kubectl \
  --namespace kube-system \
  get service jxing-nginx-ingress-controller \
  --output jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo $LB_IP

PROM_ADDR=prometheus.$LB_IP.nip.io

echo "prometheus:
  server:
    service:
      annotations: {}
    ingress:
      enabled: true
      hosts:
      - $PROM_ADDR" \
    | tee -a env/values.yaml

git add .

git commit -m "Added prod domain"

git push

jx get activities \
    --filter environment-$ENVIRONMENT-production \
    --watch

kubectl \
    --namespace jx-production \
    get ingress

open "http://$PROM_ADDR"
```

## What Now?

TODO: Viktor: Rewrite

Now is a good time for you to take a break.

If you created a cluster only for the purpose of the exercises we executed, please destroy it. We'll start the next, and each other chapter from scratch as a way to save you from running your cluster longer than necessary and pay more than needed to your hosting vendor. If you created the cluster or installed Jenkins X using one of the Gists from the beginning of this chapter, you'll find the instructions on how to destroy the cluster or uninstall everything at the bottom.

If you did choose to destroy the cluster or to uninstall Jenkins X, please remove the repositories we created as well as the local files. You can use the commands that follow for that. Just remember to replace `[...]` with your GitHub user.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-$ENVIRONMENT-staging

hub delete -y \
  $GH_USER/environment-$ENVIRONMENT-production

hub delete -y $GH_USER/prometheus

rm -rf ~/.jx/environments/$GH_USER/environment-$ENVIRONMENT-*

rm -rf environment-$ENVIRONMENT-*

rm -rf prometheus
```

Finally, you might be planning to move into the next chapter right away. If that's the case, there are no cleanup actions to do. Just keep reading.
