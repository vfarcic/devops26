## CJE2

```bash
brew cask install minishift

brew install openshift-cli

minishift start \
    --memory 10240 \
    --disk-size 20480 \
    --cpus 3

IP=$(minishift ip)

echo $IP

NAME=$(echo $IP | tr '.' '-')

echo $NAME

open "https://$IP:8443"

# Ignore SSL warning

# User/pass = developer/developer or admin/admin

oc config get-contexts

oc config set current-context \
    default/$NAME:8443/system:admin

open "https://downloads.cloudbees.com/cje2/latest/"

# Copy the link to cje2_*openshift.tgz

RELEASE_URL=[...]

curl -o cje.tgz $RELEASE_URL

tar -xvf cje.tgz

cd cje2-openshift

ls -l

cat cje.yml

oc create ns cje

CJE_DNS=cjoc-cje.$IP.nip.io

echo $CJE_DNS

oc get pv

oc describe pv pv0010

cat cje.yml

cat cje.yml \
    | sed -e \
    "s@insecureEdgeTerminationPolicy: Redirect@insecureEdgeTerminationPolicy: Allow@g" \
    | sed -e \
    "s@https://cje.example.com@http://$CJE_DNS@g" \
    | sed -e \
    "s@namespace: myproject@namespace: cje@g" \
    | oc -n cje \
    create -f - --save-config --record

oc -n cje rollout status sts cjoc

oc -n cje get all

oc get pv | grep Bound

open "http://$CJE_DNS/cjoc"

oc -n cje exec cjoc-0 -- \
    cat /var/jenkins_home/secrets/initialAdminPassword

# TODO: Create a master with 1GB and 0.5 CPU

oc -n cje get events -w

oc -n cje get all

oc get pv | grep Bound

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
                sh 'mvn --version'
            }
            stage('unit-test') {
                sh 'java -version'
            }
        }
        container('golang') {
            stage('deploy') {
                sh 'go version'
            }
        }
    }
}
```

```bash
# TODO: Run the job *my-job*

oc -n cje get pods

# TODO: Present different stages of the *jenkins-slave-* Pod

# TODO: Display the results in UI

# TODO: Delete a master

oc get pv

# oc create ns build

# Update the job
```

## What Now?

```bash
minishift delete -f --clear-cache

kubectl config delete-cluster $NAME:8443

kubectl config delete-cluster 127-0-0-1:8443

kubectl config delete-context /$NAME:8443/developer

kubectl config delete-context default/$NAME:8443/system:admin

kubectl config delete-context minishift

kubectl config delete-context myproject/$NAME:8443/developer

kubectl config delete-context myproject/$NAME:8443/system:admin

kubectl config delete-context default/127-0-0-1:8443/system:admin

kubectl config unset users.developer/$NAME:8443

kubectl config unset users.system:admin/$NAME:8443

kubectl config unset users.system:admin/127-0-0-1:8443

kubectl config view
```