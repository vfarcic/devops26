```bash
git clone https://github.com/IBM/deploy-ibm-cloud-private.git

cd deploy-ibm-cloud-private

vagrant up

open "https://192.168.27.100:8443"

# Login with admin/admin

CJE_ADDR=jenkins.192.168.27.100.nip.io

cat cloudbees-core.yml \
    | sed -e \
    "s@https://cje.example.com@http://cje.example.com@g" \
    | sed -e \
    s@cje.example.com@$CJE_ADDR@g \
    | sed -e \
    "s@ssl-redirect: \"true\"@ssl-redirect: \"false\"@g" \
    | kubectl apply -f -

kubectl rollout status sts cjoc

open "http://$CJE_ADDR/cjoc"

kubectl -n kube-system describe daemonset.apps/nginx-ingress-controller
```

```yaml
Name:           nginx-ingress-controller
Selector:       app=nginx-ingress-controller,component=nginx-ingress-controller,release=nginx-ingress
Node-Selector:  proxy=true
Labels:         app=nginx-ingress-controller
                chart=nginx-ingress-0.13.0
                component=nginx-ingress-controller
                heritage=Tiller
                release=nginx-ingress
Annotations:    <none>
Desired Number of Nodes Scheduled: 1
Current Number of Nodes Scheduled: 1
Number of Nodes Scheduled with Up-to-date Pods: 1
Number of Nodes Scheduled with Available Pods: 1
Number of Nodes Misscheduled: 0
Pods Status:  1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx-ingress-controller
           component=nginx-ingress-controller
           release=nginx-ingress
  Init Containers:
   sysctl:
    Image:      ibmcom/nginx-ingress-controller:0.13.0
    Port:       <none>
    Host Port:  <none>
    Command:
      sh
      -c
      sysctl -w net.core.somaxconn=32768; sysctl -w net.ipv4.ip_local_port_range="32768 65535"
    Environment:  <none>
    Mounts:       <none>
  Containers:
   nginx-ingress:
    Image:       ibmcom/nginx-ingress-controller:0.13.0
    Ports:       80/TCP, 443/TCP
    Host Ports:  80/TCP, 443/TCP
    Args:
      /nginx-ingress-controller
      --default-backend-service=$(POD_NAMESPACE)/default-backend
      --configmap=$(POD_NAMESPACE)/nginx-ingress-controller
      --report-node-internal-ip-address=true
      --annotations-prefix=ingress.kubernetes.io
      --enable-ssl-passthrough=true
      --publish-status-address=192.168.27.100
    Requests:
      cpu:      500m
      memory:   512Mi
    Liveness:   http-get http://:10254/healthz delay=10s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get http://:10254/healthz delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:
      POD_NAME:        (v1:metadata.name)
      POD_NAMESPACE:   (v1:metadata.namespace)
    Mounts:           <none>
  Volumes:            <none>
Events:               <none
```

```bash
kubectl -n kube-system describe service/icp-management-ingress
```

```yaml
Name:              icp-management-ingress
Namespace:         kube-system
Labels:            chart=icp-management-ingress-2.2.0
                   heritage=Tiller
                   kubernetes.io/cluster_service=true
                   release=icp-management-ingress
Annotations:       <none>
Selector:          k8s-app=icp-management-ingress
Type:              ClusterIP
IP:                10.0.0.132
Port:              https  8443/TCP
TargetPort:        8443/TCP
Endpoints:         10.1.219.79:8443
Session Affinity:  None
Events:            <none>
```

```bash
kubectl -n kube-system describe daemonset.apps/icp-management-ingress
```

```yaml
Name:           icp-management-ingress
Selector:       component=icp-management-ingress,k8s-app=icp-management-ingress,release=icp-management-ingress
Node-Selector:  role=master
Labels:         app=icp-management-ingress
                chart=icp-management-ingress-2.2.0
                component=icp-management-ingress
                heritage=Tiller
                release=icp-management-ingress
Annotations:    <none>
Desired Number of Nodes Scheduled: 1
Current Number of Nodes Scheduled: 1
Number of Nodes Scheduled with Up-to-date Pods: 1
Number of Nodes Scheduled with Available Pods: 1
Number of Nodes Misscheduled: 0
Pods Status:  1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:       component=icp-management-ingress
                k8s-app=icp-management-ingress
                release=icp-management-ingress
  Annotations:  scheduler.alpha.kubernetes.io/critical-pod=
  Containers:
   icp-management-ingress:
    Image:       ibmcom/icp-management-ingress:2.2.0
    Ports:       8080/TCP, 8443/TCP
    Host Ports:  8080/TCP, 8443/TCP
    Command:
      /icp-management-ingress
    Environment:
      CLUSTER_DOMAIN:  cluster.local
      WLP_CLIENT_ID:   <set to the key 'WLP_CLIENT_ID' in secret 'platform-oidc-credentials'>  Optional: false
      POD_NAME:         (v1:metadata.name)
      POD_NAMESPACE:    (v1:metadata.namespace)
    Mounts:
      /opt/ibm/router/nginx/html/dcos-metadata from router-ui-config (rw)
  Volumes:
   router-ui-config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      icp-management-ingress-config
    Optional:  false
Events:        <none>
```