# Create The Cluster

```bash
gcloud auth login

REGION=us-east1

ZONES=$(gcloud compute zones list \
    --filter "region:($REGION)" \
    | tail -n +2 \
    | awk '{print $1}' \
    | tr '\n' ',')

echo $ZONES

MACHINE_TYPE=n1-standard-2

gcloud container clusters \
    create devops25 \
    --region $REGION \
    --node-locations $ZONES \
    --machine-type $MACHINE_TYPE \
    --enable-autoscaling \
    --num-nodes 1 \
    --max-nodes 3 \
    --min-nodes 1

kubectl create clusterrolebinding \
    cluster-admin-binding \
    --clusterrole cluster-admin \
    --user $(gcloud config get-value account)
```

# Install Ingress

```bash
kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml
```

# Get Cluster IP

```bash
export LB_IP=$(kubectl -n ingress-nginx \
    get svc ingress-nginx \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo $LB_IP

# Repeat the `export` command if the output is empty
```

## CJE

```bash
open "https://downloads.cloudbees.com/cloudbees-core/cloud/latest/"

# Copy the link address of the `cje2_*_kubernetes.tgz` archive

RELEASE_URL=[...]

curl -o cje.tgz $RELEASE_URL

tar -xvf cloudbees-core*.tgz

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

kubectl -n cje exec cjoc-0 -- cat \
    /var/jenkins_home/secrets/initialAdminPassword

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

## External Agent Attached To A Master (GKE)

```bash
# Create a master with "Allow external agents" checked

MASTER=[...]

AGENT_PORT=$(kubectl -n cje \
    get svc $MASTER-jnlp \
    -o jsonpath="{.spec.ports[0].nodePort}")

echo $AGENT_PORT

# Create a VM

# Create a new agent with *	Tunnel connection through* set to `:$AGENT_PORT`

kubectl -n cje \
    patch svc $MASTER-jnlp \
    -p '{"spec":{"type": "LoadBalancer"}}'

export AGENT_IP=$(kubectl -n cje \
    get svc $MASTER-jnlp \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo $AGENT_IP

# SSH into the VM

sudo apt update

sudo apt install openjdk-8-jdk -y

# Download agent.jar

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
    --region $REGION \
    --quiet
```