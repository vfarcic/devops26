```bash
jx get teams

jx team something

kubectl get pods

kubectl get secret \
    jenkins \
    -o jsonpath="{.data.jenkins-admin-password}" \
    | base64 --decode; echo

jx console

jx create env
```