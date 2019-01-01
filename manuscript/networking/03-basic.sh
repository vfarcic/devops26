cd k8s-specs

git pull

cd basic

vagrant up

export KUBECONFIG=$PWD/admin.conf

kubectl get nodes

kubectl apply -f nginx-deployment.yaml

kubectl get pods -o wide

vagrant ssh node1 -c \
    "ping 10.22.2.2"

vagrant ssh node1 -c \
    "ping 10.22.3.3"

NODE1_POD_NAME=$(kubectl get pods -o json | jq -r '.items[] | select(.spec.nodeName=="node1") | [.metadata.name] | @tsv')

NODE2_POD_IP=$(kubectl get pods -o json | jq -r '.items[] | select(.spec.nodeName=="node2") | [.status.podIP] | @tsv')

kubectl exec -it $NODE1_POD_NAME \
    ping $NODE2_POD_IP

vagrant destroy -f
