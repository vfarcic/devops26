## Jenkins

```bash
JENKINS_ADDR=jenkins.$LB_IP.nip.io

# TODO: Add prometheus plugin to the values

helm install helm/jenkins \
    --name jenkins \
    --namespace cd \
    --set jenkins.Master.HostName=$JENKINS_ADDR \
    --set jenkins.Master.CredentialsXmlSecret="" \
    --set jenkins.Master.SecretsFilesSecret=""

kubectl -n cd \
    rollout status \
    deployment jenkins

JENKINS_PASS=$(kubectl -n cd \
    get secret jenkins \
    -o jsonpath="{.data.jenkins-admin-password}" \
    | base64 --decode; echo)

echo $JENKINS_PASS

open "http://$JENKINS_ADDR"
```
