```bash
# Create a Kubernetes cluster

# Install Ingress

# Install tiller

helm repo add gitlab https://charts.gitlab.io/

helm repo update

LB_IP=[...]

helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --set global.hosts.domain=gitlab.$LB_IP.nip.io \
  --set global.hosts.externalIP=$LB_IP \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set gitlab-runner.install=false

kubectl -n gitlab \
    rollout status \
    deployment gitlab-unicorn
```