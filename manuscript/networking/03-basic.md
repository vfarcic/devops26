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

# Setup Pod Network using basic CNI plugins

In this section we going to use basic CNI plugins to setup pod network where pods can communicate across nodes. Let's setup a local kubernetes cluster. We have seen details in *Create local cluster with kubadmn  (chapter 2)* to build local kubernetes cluster. In this chapter, we going to save some time for ourselves and automate all commands needed to setup local kubernetes cluster.

Lets pull the latest code from the [vfarcic/k8s-specs](https://github.com/vfarcic/k8s-specs) repository.

I> All the commands from this chapter are available in the [33-networking-basic.sh](TODO: link) Gist.

```bash
cd k8s-specs

git pull

cd network/basic

vagrant up
```

All basics plugins are available by default at `/opt/cni/bin` and installed by *kubernetes-cni* package. We didn't install this package explicitly, since kubelet package has dependency on this one and we have installed kubelet package through out `bootstrap.sh` script. 

We need to provision below CNI conf file for basic plugins we going to use. We using bridge and host-local plugins. Bridge plugin creates a bridge and adds the host and the container to it. The host-local is IPAM plugin maintains a local database of allocated IPs. IPAM plugin will assign a IP for a pod from subnet range we define in CNI conf file.

```
{
	"cniVersion": "0.3.1",
	"name": "mynet",
	"type": "bridge",
	"bridge": "cni0",
	"isGateway": true,
	"ipMasq": true,
	"ipam": {
		"type": "host-local",
		"subnet": "${NODE_SUBNET}",
		"routes": [
			{ "dst": "0.0.0.0/0" }
		]
	}
}
```

Since basic CNI plugin can't find pod network range used by other hosts, We need to supply non-conflicting subnet range ourselves for each host. Below are different subnet values we will use for each host.

```
master -> 10.22.1.0/24
node1 -> 10.22.2.0/24
node2 -> 10.22.3.0/24
```

*Vagrantfile* has a *cni* provisioner which creates file `10-mynet.conf` under `/etc/cni/net.d` directory on each host which is needed by basic CNI plugins. You will see output like this,

```
==> master: Running provisioner: cni (shell)...
    master: 10.22.1.0/24
==> node1: Running provisioner: cni (shell)...
    node1: 10.22.2.0/24
==> node2: Running provisioner: cni (shell)...
    node2: 10.22.3.0/24
```

We also need to established cross nodes routes manually as basic CNI plugins don't provide this feature. *Vagrantfile* has a *route* provisioner to configure cross host routes. You will see output like this,

```
==> node1: Running provisioner: route (shell)...
    node1: configuring route...
    node1: 10.22.3.0/24 via 10.100.198.202 dev enp0s8
==> node2: Running provisioner: route (shell)...
    node2: configuring route...
    node2: 10.22.2.0/24 via 10.100.198.201 dev enp0s8
```

All nodes should be in the ready state. 

```bash
export KUBECONFIG=$PWD/admin.conf

kubectl get nodes
```

```
NAME      STATUS    ROLES     AGE       VERSION
master    Ready     master    6m        v1.10.1
node1     Ready     <none>    4m        v1.10.1
node2     Ready     <none>    3m        v1.10.1
```

## Testing pod network

Now, we should be deploying some pods to see if kubernetes network working fine or not. We will use simple nginx deployment with two replicas.

```bash
kubectl apply -f nginx-deployment.yaml
```

```
deployment "nginx-deployment" created`
```

Below command will tell us if both pods are running and deployed on two different nodes.

```bash
kubectl get pods -o wide
```

```
NAME                                READY     STATUS    RESTARTS   AGE       IP          NODE
nginx-deployment-75675f5897-chm2r   1/1       Running   0          43s       10.22.2.2   node1
nginx-deployment-75675f5897-b4clx   1/1       Running   0          43s       10.22.3.3   node2
```

Lets visualize our pod network,

![Figure : Pod Network through basic CNI plugin](images/ch03/cni-basic-network.png)


With the help of ping we can test whether bridge plugin was able to meet kubernetes network requirements,

* All nodes can communicate with all pods (and vice-versa) without NAT

```bash
vagrant ssh node1 -c \
    "ping 10.22.2.2"    (same node)
```

```
PING 10.22.2.2 (10.22.2.2) 56(84) bytes of data.
64 bytes from 10.22.2.2: icmp_seq=1 ttl=64 time=0.054 ms
```

```bash
vagrant ssh node1 -c \
    "ping 10.22.3.3"    (across node)
```

```
PING 10.22.3.3 (10.22.3.3) 56(84) bytes of data.
64 bytes from 10.22.3.3: icmp_seq=1 ttl=63 time=0.570 ms
```

Above `ping` test confirmed that pods are reachable from same and across hosts.

* All pods can communicate with all other pods without NAT

Lets see if pod on node1 can reach to pod on node2. 

```bash
NODE1_POD_NAME=$(kubectl get pods -o json | jq -r '.items[] | select(.spec.nodeName=="node1") | [.metadata.name] | @tsv')

NODE2_POD_IP=$(kubectl get pods -o json | jq -r '.items[] | select(.spec.nodeName=="node2") | [.status.podIP] | @tsv')

kubectl exec -it $NODE1_POD_NAME \
    ping $NODE2_POD_IP
```

```
PING 10.22.3.3 (10.22.3.3): 48 data bytes
56 bytes from 10.22.3.3: icmp_seq=0 ttl=62 time=1.436 ms
```

Above `ping` test confirmed that pods are reachable from other pods.

## What now?

We have explored the basic CNI plugin for pod network and performed various test. Lets delete the cluster,

```bash
vagrant destroy -f
```
