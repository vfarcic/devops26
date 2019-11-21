# Links to gists for creating a Kubernetes cluster with Jenkins X
# gke-jx-boot.sh: https://gist.github.com/1eff2069aa68c4aee29c35b94dd9467f

jx add app jx-app-ui

jx get activities \
    --filter environment-$CLUSTER_NAME-dev/master \
    --watch

UI_ADDR=$(kubectl get ing jxui \
    --output jsonpath="{.spec.rules[0].host}")

open "http://$UI_ADDR"

GH_USER=[...]

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-staging

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-production
