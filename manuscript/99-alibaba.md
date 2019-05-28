https://github.com/jenkins-x/jenkins-x-platform/issues/953

https://github.com/jenkins-x/jx/issues/3326

```bash
# TODO: Commands to activate ROS, NAT GW, Elastic IP, and probably a few other API

# TODO: Commands to create a k8s cluster

kubectl patch \
    storageclass alicloud-disk-ssd \
    --patch '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

jx version

LB_IP=$(kubectl -n kube-system get svc nginx-ingress-lb -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

DOMAIN=jenkinx.$LB_IP.nip.io

echo "nexus:
  enabled: false
" | tee myvalues.yaml

jx install \
    --provider kubernetes \
    --external-ip $LB_IP \
    --domain $DOMAIN \
    --default-admin-password=admin \
    --ingress-namespace kube-system \
    --ingress-deployment nginx-ingress-controller \
    --default-environment-prefix jx-rocks \
    --git-provider-kind github \
    --batch-mode

# TODO: It fails to create all the PVCs.
```