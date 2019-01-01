```bash
cd k8s-specs

git pull

minikube start --vm-driver=virtualbox

minikube addons enable ingress

kubectl config current-context

cat deploy/go-demo-3-bg.yml

kubectl create -f deploy/go-demo-3-bg.yml

IP=$(minikube ip)

PORT=$(kubectl get svc go-demo-3-api \
    -o jsonpath="{.spec.ports[0].nodePort}")

curl -i "http://$IP:$PORT/demo/hello"

kubectl set image \
    -f deploy/go-demo-3-db.yml \
    db=mongo:3.4 \
    --record

kubectl get deployments \
    -l service=go-demo-3,type=api

# TODO: Continue

minikube delete
```

## TODO

- [ ] Code
- [ ] Write
- [ ] Compare with Swarm
- [ ] Text Review
- [ ] Diagrams
- [ ] Code Review
- [ ] Gist
- [ ] Review the title
- [ ] Proofread
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com
- [ ] Publish on TechnologyConversations.com