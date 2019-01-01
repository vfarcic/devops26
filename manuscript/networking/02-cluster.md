## TODO

- [ ] Code (neerajkothari)
- [ ] Code review (vfarcic)
- [ ] Write (neerajkothari)
- [ ] Text review (vfarcic)
- [ ] Diagrams (neerajkothari)
- [ ] Gist (neerajkothari)
- [ ] Review the title (neerajkothari)
- [ ] Proofread (vfarcic)
- [ ] Add to Book.txt (vfarcic)
- [ ] Publish on LeanPub.com (vfarcic)

# Create local cluster with kubadmn

Let's start with some hands-on as we usually do in each chapter and call our old friend vagarnt. We will create local cluster with help of vagrant and virtualbox. Lets clone the latest code from the [vfarcic/k8s-specs](https://github.com/vfarcic/k8s-specs) repository.

I> All the commands from this chapter are available in the [cluster.sh](TODO: link) Gist.

```bash
git clone https://github.com/vfarcic/k8s-specs.git

cd k8s-specs

git pull

cd network/cluster

vagrant up
```

We will create three VMs using ubuntu/xenial64 OS, one master and two nodes. We going to provision all these VMs with necessary components. Let's Check the status if all VMs are up.

```bash
vagrant status
```

```
Current machine states:

master running (virtualbox)
node1  running (virtualbox)
node2  running (virtualbox)
```

We need to ssh in all machines and install all necessary components docker, kubeadm, kubelet, kubectl manually so that we can create kubernetes cluster. Let's enter into master VM and gain root access.

```bash
vagrant ssh master

sudo -i
```

Lets get all the latest packages for our VM before we install anything for kubernetes,

```bash
apt-get update
```

It is going to download several packages and may take some time. Now, Lets install docker,

```bash
apt-get install -y docker.io

docker version
```

```
Client:
 Version:      1.13.1

Server:
 Version:      1.13.1
```

We could have gone for more latest docker package but for the purpose of setting up kubernetes cluster and to keep it simple this is a good enough version. Next, we are going to install kubeadm, kubelet, kubectl. *kubeadm* is utility to bootstrap the cluster more details on this further in the chapter. *kubelet* is a agent run on each machine and particualry on the master used to take *PodSpec* for various kubernetes master components and instruct docker to download needed pods. 

We need to add gpg key and kubernetes repo first and update the packages before we install kubeadm, kubelet and kubectl. 

```bash
curl -s \
    https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key add -
```

```
OK
```

```bash
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update

apt-get install -y kubelet kubeadm kubectl
```

```
Setting up kubelet (1.10.2-00) ...
Setting up kubectl (1.10.2-00) ...
Setting up kubeadm (1.10.2-00) ...
```

```bash
exit

exit
```

We have now all the necessary components on the master VM. Let's repeat this process on each node VM. Since now we understanding of what all involve in installing the necessary packages we can save some time for ourselves and automate the process using `bootstrap.sh` script.    

```bash
cat bootstrap.sh
```

NOTE: Do not execute the commands that follow. They are the output of `cat bootstrap.sh`.

```bash
#!/bin/bash

echo "Installing..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y docker.io kubelet kubeadm kubectl
```

```bash
vagrant ssh node1 -c \
    "sudo chmod +x \
    /vagrant/bootstrap.sh \
    && sudo /vagrant/bootstrap.sh"

vagrant ssh node2 -c \
    "sudo /vagrant/bootstrap.sh"
```

Once we have installed all the required packages on all the VMs, we can start bootstrapping kubernetes cluster. There are several ways we ou can create a kubernetes cluster like the one we have seen in the previous book like kops. In this chapter we will be using *kubeadm*. *kubeadm* is very simple utility to create cluster which makes it very easy to use. It is very lightweight which make it easy to integrate with other tools and more used as building block. 

To form the kubernetes cluster, we need to initialize the master and join the nodes in the cluster. Let's initialized the master. We passing master VM IP we configured in the Vagrantfile. 
    
```bash
vagrant ssh master -c \
    "sudo kubeadm init \
    --apiserver-advertise-address \
    10.100.198.200 \
    --pod-network-cidr 10.244.0.0/16"
```

The output of above command is as follows, removing most of the lines for sake of brevity.   

```
Your Kubernetes master has initialized successfully!

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 10.100.198.200:6443 --token q0xiub.nxs5ux9tjqn9rnb2 --discovery-token-ca-cert-hash sha256:80348065b7738e44b350068f8ab8d551fe5799f1acda2f132775cebb2544e4d2
```

```bash
# In your case token will be different so copy kubeadm join string here from your output of init command.
JOINCMD="kubeadm join 10.100.198.200:6443 --token 8iffwe.1yggy9ntyhv4p986 --discovery-token-ca-cert-hash sha256:6136526f3a3fb488f1daabfb6c462c29918bb3b837184ea83f592f1f3f63ddc2"

echo $JOINCMD >kube-join.sh
```

There is lot going on here. If we go through the output in detail then these are things `kube init' command doing.

* It did pre-flight checks to make confirm pre-requisites. It does several system level check like port, user, hostname, directories, etc.
* It generated certificates and keys for cluster to operate securely.
* It wrote .conf files for all the kubernetes components.
* It wrote pod specs (yaml files) for api server, controller, scheduler and etcd.
* Now, kubelet going to boot up the control plane using the above written yaml files. It going to download all the images and configure kubernetes components.
* It generated token which we going to use for nodes to join.
* It also enabled addons kube-dns and kube-proxy.

Copy the config file `admin.conf` to manage this cluster from our laptop. *Vagrant* mounts our local working dir as `/vagrant` in the VMs. We also going to create file `/vagrant/kube-join.sh` with `kubeadm join` command to later access into node VM. 

```bash
vagrant ssh master -c \
    "sudo cp /etc/kubernetes/admin.conf \
    /vagrant"
```

Let's exit from the master VM. We need to ssh into each node VM and run the join command from the output of init command. 

```bash
vagrant ssh node1 -c \
    "sudo chmod +x \
    /vagrant/kube-join.sh"

vagrant ssh node1 -c \
    "sudo /vagrant/kube-join.sh"

vagrant ssh node2 -c \
    "sudo /vagrant/kube-join.sh"
``` 

Now, validate if all nodes joined.

```bash
export KUBECONFIG=$PWD/admin.conf

kubectl get nodes
```

```
NAME      STATUS     ROLES     AGE       VERSION
master    NotReady   master    6m        v1.10.0
node1     NotReady   <none>    2m        v1.10.0
node2     NotReady   <none>    1m        v1.10.0
```

It showing all nodes are not in ready state. Let's check why this is happening. 

```bash
kubectl -n kube-system get pods
```

```
NAME                             READY     STATUS    RESTARTS   AGE
etcd-master                      1/1       Running   0          1m
kube-apiserver-master            1/1       Running   0          1m
kube-controller-manager-master   1/1       Running   0          1m
kube-dns-86f4d74b45-gj7tl        0/3       Pending   0          40m
kube-proxy-pw925                 1/1       Running   0          1m
kube-proxy-qdkrx                 1/1       Running   0          1m
kube-proxy-qfd4t                 1/1       Running   0          40m
kube-scheduler-master            1/1       Running   0          1m
```

We see *kube-dns* pod is in the pending state. This is happening because we haven't installed pod network yet. We going to demonstrate quickly without going into the details that cluster is in ready state and we can deploy our application pods. We will install pod networking using *flannel*.

```bash
kubectl apply -f flannel.yml
```

To validate if network installed properly, It may take some time before flannel pods are in running state.

```bash
kubectl -n kube-system get pods \
    -l app=flannel
```

```
NAME                    READY     STATUS    RESTARTS   AGE
kube-flannel-ds-59hmh   1/1       Running   0          45s
kube-flannel-ds-v8m8f   1/1       Running   0          45s
kube-flannel-ds-zzkf7   1/1       Running   0          45s
```

Once pod network is established, all nodes in the cluster should be in the ready state.

```bash
kubectl get nodes
```

```
NAME      STATUS    ROLES     AGE       VERSION
master    Ready     master    8m        v1.10.2
node1     Ready     <none>    3m        v1.10.2
node2     Ready     <none>    3m        v1.10.2
```

Now, we can deploy some pods to see if kubernetes cluster is working fine or not. We will use simple nginx deployment with two replicas.

```bash
kubectl apply -f nginx-deployment.yaml
```

```
deployment "nginx-deployment" created
```

Below command will tell us if both pods are running and deployed on two different nodes.

```bash
kubectl get pods -o wide
```

```
NAME                                READY     STATUS    RESTARTS   AGE       IP           NODE
nginx-deployment-75675f5897-4dm42   1/1       Running   0          2m        10.244.1.2   node1
nginx-deployment-75675f5897-rfj56   1/1       Running   0          2m        10.244.3.3   node2
```

## What now?

We have explored the local kubernetes cluster setup via kubeadm. Lets delete the cluster,

```bash
vagrant destroy -f
```
