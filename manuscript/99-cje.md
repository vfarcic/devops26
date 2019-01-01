# CJE

## Creating A Cluster

```bash
cd cluster

source kops

export BUCKET_NAME=devops23-$(date +%s)

export KOPS_STATE_STORE=s3://$BUCKET_NAME

aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --create-bucket-configuration \
    LocationConstraint=$AWS_DEFAULT_REGION

# Windows only
alias kops="docker run -it --rm \
    -v $PWD/devops23.pub:/devops23.pub \
    -v $PWD/config:/config \
    -e KUBECONFIG=/config/kubecfg.yaml \
    -e NAME=$NAME -e ZONES=$ZONES \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -e KOPS_STATE_STORE=$KOPS_STATE_STORE \
    vfarcic/kops"

kops create cluster \
    --name $NAME \
    --master-count 3 \
    --node-count 3 \
    --node-size t2.xlarge \
    --master-size t2.small \
    --zones $ZONES \
    --master-zones $ZONES \
    --ssh-public-key devops23.pub \
    --networking kubenet \
    --yes

kops validate cluster

# Windows only
kops export kubecfg --name ${NAME}

# Windows only
export \
    KUBECONFIG=$PWD/config/kubecfg.yaml

kubectl create \
    -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/ingress-nginx/v1.6.0.yaml

kubectl --namespace kube-ingress \
    get all
```

## Deploying CJOC

```bash
CLUSTER_DNS=$(aws elb describe-load-balancers \
    | jq -r \
    ".LoadBalancerDescriptions[] \
    | select(.DNSName \
    | contains (\"api\") | not)\
    .DNSName")

echo $CLUSTER_DNS

open "https://downloads.cloudbees.com/cje2/latest/"

RELEASE_URL=[...]

curl -o cje.tgz $RELEASE_URL

tar -xvf cje.tgz

cd cje2_*

ls -l

kubectl get sc -o yaml

cat cje.yml

kubectl create ns jenkins

cat cje.yml \
    | sed -e \
    "s@https://cje.example.com@http://cje.example.com@g" \
    | sed -e \
    "s@cje.example.com@$CLUSTER_DNS@g" \
    | sed -e \
    "s@ssl-redirect: \"true\"@ssl-redirect: \"false\"@g" \
    | kubectl --namespace jenkins \
    create -f - \
    --save-config --record

kubectl -n jenkins \
    rollout status sts cjoc

kubectl -n jenkins \
    get all

open "http://$CLUSTER_DNS/cjoc"

kubectl --namespace jenkins \
    exec cjoc-0 -- \
    cat /var/jenkins_home/secrets/initialAdminPassword

# TODO: Wizard steps

kubectl -n jenkins get pvc

kubectl get pv

# TODO: Create a master called *my-master*

# TODO: Set *Jenkins Master Memory in MB* to *1024*

# TODO: Set *Jenkins Master CPUs* to *0.5*

kubectl --namespace jenkins \
    get all

kubectl --namespace jenkins \
    describe pod my-master-0

kubectl --namespace jenkins \
    logs my-master-0

# TODO: Go to *my-master*

# TODO: Wizard steps

# TODO: Create a new Pipeline job called *my-job*
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

```bash
# TODO: Install BlueOcean

# TODO: Run the job *my-job*

kubectl --namespace jenkins \
    get pods

# TODO: Present different stages of the *jenkins-slave-* Pod

# TODO: Display the results in UI

# TODO: Delete a master

kubectl get pvc

kubectl get pv
```

## Adding External Agents

```bash
kubectl -n jenkins get sts
```

```
NAME        DESIRED   CURRENT   AGE
cjoc        1         1         5m
my-master   1         1         4s
```

```bash
kubectl -n jenkins get svc
```

```
NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)            AGE
cjoc        ClusterIP   100.68.224.12   <none>        80/TCP,50000/TCP   5m
my-master   ClusterIP   100.67.50.225   <none>        80/TCP,50001/TCP   27s
```

```bash
kubectl -n jenkins describe svc my-master
```

```
Name:              my-master
Namespace:         jenkins
Labels:            com.cloudbees.cje.tenant=my-master
                   com.cloudbees.cje.type=master
                   com.cloudbees.pse.tenant=my-master
                   com.cloudbees.pse.type=master
                   tenant=my-master
                   type=master
Annotations:       <none>
Selector:          com.cloudbees.cje.tenant=my-master,com.cloudbees.cje.type=master,com.cloudbees.pse.tenant=my-master,com.cloudbees.pse.type=master,tenant=my-master,type=master
Type:              ClusterIP
IP:                100.64.100.248
Port:              http  80/TCP
TargetPort:        8080/TCP
Endpoints:         100.96.3.6:8080
Port:              agent  50001/TCP
TargetPort:        50001/TCP
Endpoints:         100.96.3.6:50001
Session Affinity:  None
Events:            <none>
```

```bash
open "http://$CLUSTER_DNS/my-master/pluginManager/available"

kubectl run -n jenkins test \
    --image=alpine \
    --restart=Never \
    sleep 10000

kubectl -n jenkins exec -it test \
    -- apk add -U curl

kubectl -n jenkins exec -it test \
    -- curl "my-master:50001"
```

```
Jenkins-Agent-Protocols: Diagnostic-Ping, JNLP4-connect, OperationsCenter2, Ping
Jenkins-Version: 2.107.3.4
Jenkins-Session: 2db6a915
Client: 100.96.4.4
Server: 100.96.3.5
Remoting-Minimum-Version: 2.60
```

```bash
cat cjoc-external-agent.yml
```

```yaml
apiVersion: v1
kind: Service
metadata: 
  name: my-master-jnlp
spec: 
  type: LoadBalancer
  selector: 
    com.cloudbees.cje.tenant: my-master
    com.cloudbees.cje.type: master
  ports: 
  - name: jnlp
    port: 50001
    protocol: TCP
```

```bash
kubectl -n jenkins apply \
    -f cjoc-external-agent.yml

kubectl -n jenkins get svc
```

```
NAME             TYPE           CLUSTER-IP       EXTERNAL-IP        PORT(S)            AGE
cjoc             ClusterIP      100.68.224.12    <none>             80/TCP,50000/TCP   9m
my-master        ClusterIP      100.67.50.225    <none>             80/TCP,50001/TCP   4m
my-master-jnlp   LoadBalancer   100.66.137.105   aa8bf9bbc5e66...   50001:30321/TCP    7s
```

```bash
kubectl -n jenkins exec -it test \
    -- curl "my-master-jnlp:50001"

aws elb \
    describe-load-balancers | jq -r \
    ".LoadBalancerDescriptions[] \
    | select(.DNSName \
    | contains (\"api-devops23\") \
    | not).DNSName"
```

```
a3dce7d095e6511e88427020e8f23467-730017751.us-east-2.elb.amazonaws.com
aa8bf9bbc5e6611e88427020e8f23467-1056573600.us-east-2.elb.amazonaws.com
```

```bash
DNS=$(kubectl -n jenkins \
    get svc my-master-jnlp \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")

echo $DNS

PORT=$(kubectl -n jenkins \
    get svc my-master-jnlp \
    -o jsonpath="{.spec.ports[0].nodePort}")

echo $PORT

curl "$DNS:50001"
```

```
Jenkins-Agent-Protocols: Diagnostic-Ping, JNLP4-connect, OperationsCenter2, Ping
Jenkins-Version: 2.107.3.4
Jenkins-Session: 2db6a915
Client: 172.20.72.48
Server: 100.96.3.5
Remoting-Minimum-Version: 2.60
```

```bash
open "http://$CLUSTER_DNS/my-master/computer/new"

# Create A *Permanent Agent* called *my-agent*

# Choose *Launch agent via Java Web Start*

# Click the *Advanced* button

echo $DNS # Copy the output

# Paste the output to *Tunnel connection through* with `:50001`

# Click the *Save* button

# Click the *my-agent* link

# SSH into to a server outside the cluster

# Install Java

JAR_ADDR=[...]

# Replace `[...]` with the link to the JAR.

curl -o agent.jar $JAR_ADDR

# Go back to the agent screen, copy the command, and paste it in the terminal
```

```
May 23, 2018 9:48:27 AM org.jenkinsci.remoting.engine.WorkDirManager initializeWorkDir
INFO: Using /tmp/remoting as a remoting work directory
Both error and output logs will be printed to /tmp/remoting
May 23, 2018 9:48:28 AM hudson.remoting.jnlp.Main createEngine
INFO: Setting up agent: my-agent
May 23, 2018 9:48:28 AM hudson.remoting.jnlp.Main$CuiListener <init>
INFO: Jenkins agent is running in headless mode.
May 23, 2018 9:48:28 AM org.jenkinsci.remoting.engine.WorkDirManager initializeWorkDir
INFO: Using /tmp/remoting as a remoting work directory
May 23, 2018 9:48:28 AM hudson.remoting.jnlp.Main$CuiListener status
INFO: Locating server among [http://a3dce7d095e6511e88427020e8f23467-730017751.us-east-2.elb.amazonaws.com/my-master/]
May 23, 2018 9:48:28 AM org.jenkinsci.remoting.engine.JnlpAgentEndpointResolver resolve
INFO: Remoting server accepts the following protocols: [JNLP4-connect, Ping, Diagnostic-Ping, OperationsCenter2]
May 23, 2018 9:48:28 AM hudson.remoting.jnlp.Main$CuiListener status
INFO: Agent discovery successful
  Agent address: aa8bf9bbc5e6611e88427020e8f23467-1056573600.us-east-2.elb.amazonaws.com
  Agent port:    50001
  Identity:      43:a2:0d:6b:a4:71:73:8f:be:c3:3d:db:8b:da:50:7b
May 23, 2018 9:48:28 AM hudson.remoting.jnlp.Main$CuiListener status
INFO: Handshaking
May 23, 2018 9:48:28 AM hudson.remoting.jnlp.Main$CuiListener status
INFO: Connecting to aa8bf9bbc5e6611e88427020e8f23467-1056573600.us-east-2.elb.amazonaws.com:50001
May 23, 2018 9:48:28 AM hudson.remoting.jnlp.Main$CuiListener status
INFO: Trying protocol: JNLP4-connect
May 23, 2018 9:48:33 AM hudson.remoting.jnlp.Main$CuiListener status
INFO: Remote identity confirmed: 43:a2:0d:6b:a4:71:73:8f:be:c3:3d:db:8b:da:50:7b
May 23, 2018 9:48:34 AM hudson.remoting.jnlp.Main$CuiListener status
INFO: Connected
```

## Destroying The Cluster

```bash
kops delete cluster \
    --name $NAME \
    --yes

aws s3api delete-bucket \
    --bucket $BUCKET_NAME
```
