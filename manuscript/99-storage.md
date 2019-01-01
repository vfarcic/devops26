## Cluster

```bash
git clone https://github.com/vfarcic/k8s-specs.git

cd k8s-specs

git pull

cd cluster

source kops

export BUCKET_NAME=devops23-$(date +%s)

aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --create-bucket-configuration \
    LocationConstraint=$AWS_DEFAULT_REGION

export KOPS_STATE_STORE=s3://$BUCKET_NAME

kops create cluster \
    --name $NAME \
    --master-count 3 \
    --master-size t2.small \
    --node-count 3 \
    --node-size t2.medium \
    --zones $ZONES \
    --master-zones $ZONES \
    --ssh-public-key devops23.pub \
    --networking kubenet \
    --authorization RBAC \
    --yes

kops validate cluster

kubectl create \
    -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/ingress-nginx/v1.6.0.yaml

cd ..
```

## NFS

TODO: Commands

## EBS

### EBS Setup

```bash
kubectl create \
    -f storage/jenkins.yml \
    --record --save-config

kubectl -n jenkins \
    rollout status deploy jenkins

kubectl -n jenkins get pvc

kubectl -n jenkins get pv

CLUSTER_DNS=$(kubectl -n jenkins \
    get ing jenkins \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")

open "http://$CLUSTER_DNS/jenkins"

# Login with jdoe/incognito

# Create a new Pipeline job called `my-job`
```

### EBS Fault Tolerance

```bash
NODE=$(kubectl -n jenkins \
    get pods \
    -l=app=jenkins \
    -o jsonpath="{.items[0].spec.nodeName}")

kubectl drain $NODE --force

kubectl -n jenkins \
    get pods -o wide

kubectl -n jenkins \
    describe pod jenkins

kubectl uncordon $NODE

kubectl -n jenkins \
    describe pod jenkins

kubectl -n jenkins \
    get pods -o wide

open "http://$CLUSTER_DNS/jenkins"
```

## EBS Performance

```bash
POD_NAME=$(kubectl -n jenkins \
    get pods \
    -l=app=jenkins \
    -o jsonpath="{.items[*].metadata.name}")

kubectl -n jenkins \
    exec -it $POD_NAME sh
```

* if=/dev/zero (if=/dev/input.file) : The name of the input file you want dd the read from.
* of=/tmp/test1.img (of=/path/to/output.file) : The name of the output file you want dd write the input.file to.
* bs=1G (bs=block-size) : Set the size of the block you want dd to use. 1 gigabyte was written for the test. Please note that Linux will need 1GB of free space in RAM. If your test system does not have sufficient RAM available, use a smaller parameter for bs (such as 128MB or 64MB and so on).
* count=1 (count=number-of-blocks): The number of blocks you want dd to read.
* oflag=dsync (oflag=dsync) : Use synchronized I/O for data. Do not skip this option. This option get rid of caching and gives you good and accurate results
* conv=fdatasyn: Again, this tells dd to require a complete “sync” once, right before it exits. This option is equivalent to oflag=dsync.

```bash
dd if=/dev/zero \
    of=/var/jenkins_home/test1.img \
    bs=1G count=1 oflag=dsync
```

```
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 16.3703 s, 65.6 MB/s
...
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 17.8384 s, 60.2 MB/s
...
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 16.4111 s, 65.4 MB/s
```

```bash
dd if=/dev/zero \
    of=/var/jenkins_home/test2.img \
    bs=10 count=1000 oflag=dsync
```

```
1000+0 records in
1000+0 records out
10000 bytes (10 kB, 9.8 KiB) copied, 1.60102 s, 6.2 kB/s
...
1000+0 records in
1000+0 records out
10000 bytes (10 kB, 9.8 KiB) copied, 1.63599 s, 6.1 kB/s
```

```bash
dd if=/dev/zero \
    of=/var/jenkins_home/test3.img \
    bs=100K count=100 oflag=dsync
```

```
100+0 records in
100+0 records out
10240000 bytes (10 MB, 9.8 MiB) copied, 0.31181 s, 32.8 MB/s
...
100+0 records in
100+0 records out
10240000 bytes (10 MB, 9.8 MiB) copied, 0.337619 s, 30.3 MB/s
```

```bash
dd if=/var/jenkins_home/test1.img \
    of=/dev/zero \
    bs=1G count=1 oflag=dsync
```

```
TODO: Output
```

```bash
dd if=/var/jenkins_home/test2.img \
    of=/dev/zero \
    bs=10 count=1000 oflag=dsync
```

```
TODO: Output
```

```bash
dd if=/var/jenkins_home/test3.img \
    of=/dev/zero \
    bs=100K count=100 oflag=dsync
```

```
TODO: Output
```

```bash
exit

kubectl delete ns jenkins

# TODO: Other EBS types

# TODO: Prices

kops delete cluster \
    --name $NAME \
    --yes

aws s3api delete-bucket \
    --bucket $BUCKET_NAME
```

## EFS

### Cluster

```bash
cd cluster

source kops

export BUCKET_NAME=devops23-$(date +%s)

aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --create-bucket-configuration \
    LocationConstraint=$AWS_DEFAULT_REGION

export KOPS_STATE_STORE=s3://$BUCKET_NAME

kops create cluster \
    --name $NAME \
    --master-count 3 \
    --master-size t2.small \
    --node-count 3 \
    --node-size t2.medium \
    --zones $ZONES \
    --master-zones $ZONES \
    --ssh-public-key devops23.pub \
    --networking kubenet \
    --authorization RBAC \
    --yes

kops validate cluster

kubectl create \
    -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/ingress-nginx/v1.6.0.yaml

cd ..
```

## Ceph With Rook

### Rook/Ceph Setup

```bash
# https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/rook-operator.yaml
kubectl create \
    -f storage/rook-operator.yml \
    --record --save-config

kubectl -n rook-system \
    rollout status deploy rook-operator

kubectl -n rook-system \
    rollout status ds rook-agent

kubectl -n rook-system get all

# https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/rook-cluster.yaml
# Uncommented `storeType: bluestore`
kubectl create \
    -f storage/rook-cluster.yml \
    --record --save-config

kubectl -n rook \
    rollout status deploy rook-ceph-mgr0

kubectl -n rook get all
```

### Rook Block Storage

```bash
kubectl create -f storage/rook.yml \
    --record --save-config

kubectl get sc

kubectl describe sc rook-block

kubectl -n rook get pool

kubectl -n rook describe pool replicapool

kubectl create \
    -f storage/jenkins-rook-block.yml \
    --record --save-config

kubectl -n jenkins \
    rollout status deploy jenkins

kubectl -n jenkins get pvc

kubectl get pv

CLUSTER_DNS=$(kubectl -n jenkins \
    get ing jenkins \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")

open "http://$CLUSTER_DNS/jenkins"

# Login with jdoe/incognito

# Create a new Pipeline job called `my-job`
```

### Rook Block Fault Tolerance

```bash
NODE=$(kubectl -n jenkins \
    get pods \
    -l=app=jenkins \
    -o jsonpath="{.items[0].spec.nodeName}")

kubectl drain $NODE \
    --force --ignore-daemonsets \
    --delete-local-data

kubectl -n jenkins \
    get pods -o wide

kubectl -n jenkins \
    describe pod jenkins

kubectl get pv

kubectl uncordon $NODE

kubectl -n jenkins \
    describe pod jenkins

kubectl -n jenkins \
    get pods -o wide

open "http://$CLUSTER_DNS/jenkins"
```

## Rook Block Performance

```bash
POD_NAME=$(kubectl -n jenkins \
    get pods \
    -l=app=jenkins \
    -o jsonpath="{.items[*].metadata.name}")

kubectl -n jenkins \
    exec -it $POD_NAME sh
```

* if=/dev/zero (if=/dev/input.file) : The name of the input file you want dd the read from.
* of=/tmp/test1.img (of=/path/to/output.file) : The name of the output file you want dd write the input.file to.
* bs=1G (bs=block-size) : Set the size of the block you want dd to use. 1 gigabyte was written for the test. Please note that Linux will need 1GB of free space in RAM. If your test system does not have sufficient RAM available, use a smaller parameter for bs (such as 128MB or 64MB and so on).
* count=1 (count=number-of-blocks): The number of blocks you want dd to read.
* oflag=dsync (oflag=dsync) : Use synchronized I/O for data. Do not skip this option. This option get rid of caching and gives you good and accurate results
* conv=fdatasyn: Again, this tells dd to require a complete “sync” once, right before it exits. This option is equivalent to oflag=dsync.

```bash
dd if=/dev/zero \
    of=/var/jenkins_home/test1.img \
    bs=1G count=1 oflag=dsync
```

```
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 32.9552 s, 32.6 MB/s
...
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 37.8857 s, 28.3 MB/s
...
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 33.5949 s, 32.0 MB/s
```

```bash
dd if=/dev/zero \
    of=/var/jenkins_home/test2.img \
    bs=10 count=1000 oflag=dsync
```

```
1000+0 records in
1000+0 records out
10000 bytes (10 kB, 9.8 KiB) copied, 8.57959 s, 1.2 kB/s
...
1000+0 records in
1000+0 records out
10000 bytes (10 kB, 9.8 KiB) copied, 8.6172 s, 1.2 kB/s
...
1000+0 records in
1000+0 records out
10000 bytes (10 kB, 9.8 KiB) copied, 9.46219 s, 1.1 kB/s
```

```bash
dd if=/dev/zero \
    of=/var/jenkins_home/test3.img \
    bs=100K count=100 oflag=dsync
```

```
100+0 records in
100+0 records out
10240000 bytes (10 MB, 9.8 MiB) copied, 1.02447 s, 10.0 MB/s
...
100+0 records in
100+0 records out
10240000 bytes (10 MB, 9.8 MiB) copied, 1.45304 s, 7.0 MB/s
```

```bash
dd if=/var/jenkins_home/test1.img \
    of=/dev/zero \
    bs=1G count=1 oflag=dsync
```

```
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 7.02301 s, 153 MB/s
```

```bash
dd if=/var/jenkins_home/test2.img \
    of=/dev/zero \
    bs=10 count=1000 oflag=dsync
```

```
1000+0 records in
1000+0 records out
10000 bytes (10 kB, 9.8 KiB) copied, 0.00155354 s, 6.4 MB/s
```

```bash
dd if=/var/jenkins_home/test3.img \
    of=/dev/zero \
    bs=100K count=100 oflag=dsync
```

```
100+0 records in
100+0 records out
10240000 bytes (10 MB, 9.8 MiB) copied, 0.138094 s, 74.2 MB/s
```

```bash
exit

kubectl delete ns jenkins
```

### Rook Block Multiple Replicas

```bash
kubectl create \
    -f storage/demo-rook-block.yml \
    --record --save-config

kubectl rollout status deploy demo

kubectl get all

kubectl get pvc

kubectl get pv

kubectl get events

kubectl delete -f storage/demo-rook-block.yml
```

### Rook Shared 

```bash
kubectl create \
    -f storage/demo-rook-fs.yml \
    --record --save-config

kubectl rollout status deploy demo

POD_1=$(kubectl get pods -l app=demo \
    -o jsonpath="{.items[0].metadata.name}")

POD_2=$(kubectl get pods -l app=demo \
    -o jsonpath="{.items[0].metadata.name}")

POD_3=$(kubectl get pods -l app=demo \
    -o jsonpath="{.items[0].metadata.name}")

kubectl exec -it $POD_1 touch /tmp/hello

kubectl exec -it $POD_2 ls /tmp

kubectl exec -it $POD_3 rm /tmp/hello

kubectl exec -it $POD_2 ls /tmp
```

### Rook Shared Fault Tolerance

```bash
kubectl create \
    -f storage/jenkins-rook-fs.yml \
    --save-config --record

kubectl -n jenkins \
    rollout status deploy jenkins

NODE=$(kubectl -n jenkins \
    get pods \
    -l=app=jenkins \
    -o jsonpath="{.items[0].spec.nodeName}")

kubectl drain $NODE \
    --force --ignore-daemonsets \
    --delete-local-data

kubectl -n jenkins \
    get pods -o wide

kubectl -n jenkins \
    describe pod jenkins

kubectl get pv

kubectl uncordon $NODE

kubectl -n jenkins \
    describe pod jenkins

kubectl -n jenkins \
    get pods -o wide

open "http://$CLUSTER_DNS/jenkins"
```

## Rook Shared Performance

```bash
POD_NAME=$(kubectl -n jenkins \
    get pods \
    -l=app=jenkins \
    -o jsonpath="{.items[*].metadata.name}")

kubectl -n jenkins \
    exec -it $POD_NAME sh
```

* if=/dev/zero (if=/dev/input.file) : The name of the input file you want dd the read from.
* of=/tmp/test1.img (of=/path/to/output.file) : The name of the output file you want dd write the input.file to.
* bs=1G (bs=block-size) : Set the size of the block you want dd to use. 1 gigabyte was written for the test. Please note that Linux will need 1GB of free space in RAM. If your test system does not have sufficient RAM available, use a smaller parameter for bs (such as 128MB or 64MB and so on).
* count=1 (count=number-of-blocks): The number of blocks you want dd to read.
* oflag=dsync (oflag=dsync) : Use synchronized I/O for data. Do not skip this option. This option get rid of caching and gives you good and accurate results
* conv=fdatasyn: Again, this tells dd to require a complete “sync” once, right before it exits. This option is equivalent to oflag=dsync.

```bash
dd if=/dev/zero \
    of=/var/jenkins_home/test1.img \
    bs=1G count=1 oflag=dsync
```

```
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 10.4359 s, 103 MB/s
```

```bash
dd if=/dev/zero \
    of=/var/jenkins_home/test2.img \
    bs=10 count=1000 oflag=dsync
```

```
1000+0 records in
1000+0 records out
10000 bytes (10 kB, 9.8 KiB) copied, 8.9961 s, 1.1 kB/s
```

```bash
dd if=/dev/zero \
    of=/var/jenkins_home/test3.img \
    bs=100K count=100 oflag=dsync
```

```
100+0 records in
100+0 records out
10240000 bytes (10 MB, 9.8 MiB) copied, 1.05203 s, 9.7 MB/s
```

```bash
dd if=/var/jenkins_home/test1.img \
    of=/dev/zero \
    bs=1G count=1 oflag=dsync
```

```
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 8.23009 s, 130 MB/s
```

```bash
dd if=/var/jenkins_home/test2.img \
    of=/dev/zero \
    bs=10 count=1000 oflag=dsync
```

```
1000+0 records in
1000+0 records out
10000 bytes (10 kB, 9.8 KiB) copied, 0.00105753 s, 9.5 MB/s
```

```bash
dd if=/var/jenkins_home/test3.img \
    of=/dev/zero \
    bs=100K count=100 oflag=dsync
```

```
100+0 records in
100+0 records out
10240000 bytes (10 MB, 9.8 MiB) copied, 0.082091 s, 125 MB/s
```

```bash
exit

kubectl delete ns jenkins
```

## GlusterFS With Heketi

TODO: Code

## Quartermaster (https://github.com/coreos/quartermaster)

TODO: Code

## What Now?

```bash
kops delete cluster \
    --name $NAME \
    --yes

aws s3api delete-bucket \
    --bucket $BUCKET_NAME
```