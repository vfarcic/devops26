```bash
cd storage/nfs

vagrant up nfs

vagrant ssh nfs

sudo apt-get update

sudo apt-get install -y \
    nfs-kernel-server

sudo mkdir /var/nfs/general -p

sudo chown nobody:nogroup /var/nfs/general

echo "/var/nfs/general    *(rw,sync,no_subtree_check)" \
    | sudo tee -a /etc/exports

sudo systemctl restart nfs-kernel-server

sudo ufw status # If should be inactive

# sudo ufw allow from * to any port nfs

# sudo ufw status

exit

# Create a cluster

kubectl create \
    -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/auth/serviceaccount.yaml

kubectl create \
    -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/auth/clusterrole.yaml

kubectl create \
    -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/auth/clusterrolebinding.yaml

NFS_SERVER_ADDR=[...]

curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/deployment.yaml \
    | sed -e "s@10.10.10.60@$NFS_SERVER_ADDR@g" \
    | sed -e "s@/ifs/kubernetes@/var/nfs/general@g" \
    | kubectl create -f -

# kubectl patch deployment nfs-client-provisioner \
#     -p '{"spec":{"template":{"spec":{"serviceAccount":"nfs-client-provisioner"}}}}'

kubectl create \
    -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/class.yaml

kubectl create \
    -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/test-claim.yaml

kubectl create \
    -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/test-pod.yaml

# Confirm that the file was created in the NFS server

kubectl delete \
    -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/test-pod.yaml

kubectl delete \
    -f https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/test-claim.yaml

# Confirm that the folder renamed to archived-???
```