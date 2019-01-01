cd k8s-specs

git pull

cd network/cluster

vagrant up

vagrant status

vagrant ssh master

sudo -i

apt-get update

apt-get install -y docker.io

docker version

curl -s \
    https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update

apt-get install -y kubelet kubeadm kubectl

exit

exit

cat bootstrap.sh

vagrant ssh node1 -c \
    "sudo chmod +x \
    /vagrant/bootstrap.sh \
    && sudo /vagrant/bootstrap.sh"

vagrant ssh node2 -c \
    "sudo /vagrant/bootstrap.sh"

vagrant ssh master -c \
    "sudo kubeadm init \
    --apiserver-advertise-address \
    10.100.198.200 \
    --pod-network-cidr 10.244.0.0/16"

JOINCMD="kubeadm join 10.100.198.200:6443 --token 8iffwe.1yggy9ntyhv4p986 --discovery-token-ca-cert-hash sha256:6136526f3a3fb488f1daabfb6c462c29918bb3b837184ea83f592f1f3f63ddc2"

echo $JOINCMD >kube-join.sh

sudo cp /etc/kubernetes/admin.conf \
    /vagrant

vagrant ssh node1 -c \
    "sudo chmod +x \
    /vagrant/kube-join.sh"

vagrant ssh node1 -c \
    "sudo /vagrant/kube-join.sh"

vagrant ssh node2 -c \
    "sudo /vagrant/kube-join.sh"

export KUBECONFIG=$PWD/admin.conf

kubectl get nodes

kubectl -n kube-system get pods

kubectl apply -f flannel.yml

kubectl -n kube-system get pods \
    -l app=flannel

kubectl get nodes

kubectl apply -f nginx-deployment.yaml

kubectl get pods -o wide

vagrant destroy -f