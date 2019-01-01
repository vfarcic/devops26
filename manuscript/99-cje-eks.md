# CJE w/EKS

## Create The Cluster

```bash
# Make sure that you're using eksctl v0.1.4+.

# Follow the instructions from https://github.com/weaveworks/eksctl to intall eksctl.

export AWS_ACCESS_KEY_ID=[...] # Replace [...] with AWS access key ID

export AWS_SECRET_ACCESS_KEY=[...] # Replace [...] with AWS secret access key

export AWS_DEFAULT_REGION=us-west-2

export NAME=devops25

mkdir -p cluster

eksctl create cluster \
    -n $NAME \
    -r $AWS_DEFAULT_REGION \
    --kubeconfig cluster/kubecfg-eks \
    --node-type t2.medium \
    --nodes 3 \
    --nodes-max 9 \
    --nodes-min 3

export KUBECONFIG=$PWD/cluster/kubecfg-eks
```

## Install Ingress

```bash
kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/aws/service-l4.yaml

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/aws/patch-configmap-l4.yaml
```

## Get Cluster IP

```bash
LB_HOST=$(kubectl -n ingress-nginx \
    get svc ingress-nginx \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")

export LB_IP="$(dig +short $LB_HOST \
    | tail -n 1)"

echo $LB_IP

# Repeat the `export` command if the output is empty
```

## CJE

```bash
open "https://downloads.cloudbees.com/cloudbees-core/cloud/latest/"

# Copy the link address of the `cje2_*_kubernetes.tgz` archive

RELEASE_URL=[...]

curl -o cje.tgz $RELEASE_URL

tar -xvf cje.tgz

cd cloudbees-core*

CJE_ADDR=cjoc.$LB_IP.nip.io

echo $CJE_ADDR

kubectl create ns cje

cat cloudbees-core.yml \
    | sed -e \
    "s@https://cje.example.com@http://cje.example.com@g" \
    | sed -e \
    s@cje.example.com@$CJE_ADDR@g \
    | sed -e \
    "s@ssl-redirect: \"true\"@ssl-redirect: \"false\"@g" \
    | kubectl -n cje apply -f -

kubectl -n cje \
    rollout status sts cjoc

open "http://$CJE_ADDR"

PASS=$(kubectl -n cje exec cjoc-0 -- cat \
    /var/jenkins_home/secrets/initialAdminPassword)

echo $PASS

# Copy the password and paste it into the UI

# Finish the setup wizard

USER=[...]

# Create a master

MASTER=[...]

# Create a job
```

```groovy
podTemplate(
    label: 'kubernetes',
    containers: [
        containerTemplate(name: 'maven', image: 'maven:alpine', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'golang', image: 'golang:alpine', ttyEnabled: true, command: 'cat')
    ]
) {
    node('kubernetes') {
        container('maven') {
            stage('build') {
                sh "sleep 5"
                sh 'mvn --version'
            }
            stage('unit-test') {
                sh "sleep 5"
                sh 'java -version'
            }
        }
        container('golang') {
            stage('deploy') {
                sh "sleep 5"
                sh 'go version'
            }
        }
    }
}
```

## External Agent Attached To A Master

```bash
# Create a master with "Allow external agents" checked

MASTER=[...]

AGENT_PORT=$(kubectl -n cje \
    get svc $MASTER-jnlp \
    -o jsonpath="{.spec.ports[0].nodePort}")

echo $AGENT_PORT

# Create a VM

AGENT_IP=[...]

echo $AGENT_IP

kubectl -n cje \
    patch svc $MASTER-jnlp \
    -p '{"spec":{"type": "LoadBalancer"}}'

export AGENT_SERVICE_ADDR=$(kubectl -n cje \
    get svc $MASTER-jnlp \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")

echo $AGENT_SERVICE_ADDR

# Create a new agent with `$AGENT_SERVICE_ADDR:$xxxxxx` as the value of *Tunnel connection through*

SSH_KEY_PATH=[...]

ssh -i $SSH_KEY_PATH ubuntu@$AGENT_IP

sudo apt update

sudo apt install openjdk-8-jdk -y

AGENT_JAR_ADDR=[...]

curl -o agent.jar $AGENT_JAR_ADDR

# Copy & paste the command to connect the agent
```

## Shared Agents

```bash
echo "
apiVersion: v1
kind: Service
metadata:
  labels:
    com.cloudbees.cje.tenant: cjoc
    com.cloudbees.cje.type: cjoc
  name: cjoc-jnlp
spec:
  ports:
  - name: agent
    port: 50000
    protocol: TCP
    targetPort: 50000
  selector:
    com.cloudbees.cje.tenant: cjoc
    com.cloudbees.cje.type: cjoc
  type: LoadBalancer
" | kubectl -n cje apply -f -

export AGENT_SERVICE_ADDR=$(kubectl -n cje \
    get svc cjoc-jnlp \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")

echo $AGENT_SERVICE_ADDR

# Create a new agent with `$AGENT_SERVICE_ADDR:50000` as the value of *Tunnel connection through*

SSH_KEY_PATH=[...]

ssh -i $SSH_KEY_PATH ubuntu@$AGENT_IP

sudo apt update

sudo apt install openjdk-8-jdk -y

AGENT_JAR_ADDR=[...]

curl -o slave.jar $AGENT_JAR_ADDR

# Copy & paste the command to connect the agent
```

## GitLab

```bash
# Install Blue Ocean and GitLab Plugin

# Create a new Multi-Branch Pipeline job

JOB=[...]

# If a master is created through the "advanced" screen
open "http://$CJE_ADDR/$MASTER/user/$USER/configure"

# If a master is created as a "team"
open "http://$CJE_ADDR/teams-$MASTER/user/$USER/configure"

# Click "Show API Token"

API_TOKEN=[...]

# Open GitLab repo console > Settings > Integrations

# If a master is created through the "advanced" screen
echo "http://$USER:$API_TOKEN@$CJE_ADDR/$MASTER/project/$JOB"

# If a master is created as a "team"
echo "http://$USER:$API_TOKEN@$CJE_ADDR/teams-$MASTER/job/$MASTER/project/$JOB" # Doesn't work!!!

# Paste the output to the URL field (leave the Secret Token empty)
```

## What Now?

```bash
gcloud container clusters \
    delete devops25 \
    --zone $ZONE \
    --quiet
```