## TODO

- [ ] Code
- [ ] Write
- [ ] Code review
- [ ] Text review
- [ ] Highlights
- [ ] Diagrams
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com

# Creating A Cluster With jx

## Creating A GKE Cluster With jx

```bash
PROJECT=[...] # e.g. devops24-book

jx create cluster gke \
    -n jx-rocks \
    -p $PROJECT \
    -z us-east1-b \
    -m n1-standard-2 \
    --min-num-nodes 3 \
    --max-num-nodes 5 \
    --default-admin-password=admin \
    --default-environment-prefix jx-rocks \
    --prow -b

kubectl -n jx get pods
```

```
NAME                                               READY   STATUS      RESTARTS   AGE
build-controller-6d8c58db8b-wz99p                  1/1     Running     0          55m
buildnum-77bdbb8bb-g59qv                           1/1     Running     0          53m
crier-766b799476-5bdvr                             1/1     Running     0          53m
deck-77bcb6c7cd-jv7tx                              1/1     Running     0          53m
deck-77bcb6c7cd-k6g8x                              1/1     Running     0          53m
hook-7bdd7f86c9-ds6qd                              1/1     Running     0          53m
hook-7bdd7f86c9-lj584                              1/1     Running     0          53m
horologium-7cc979bd5c-jfxln                        1/1     Running     0          53m
jenkins-x-chartmuseum-5b6f9fd646-nh9ng             1/1     Running     0          52m
jenkins-x-controllerbuild-68646c5c9d-t7jkg         1/1     Running     0          52m
jenkins-x-controllercommitstatus-dd46689c8-qs96g   1/1     Running     0          52m
jenkins-x-controllerrole-67dcc687cc-r8lrl          1/1     Running     0          52m
jenkins-x-controllerteam-59bb947b8b-mgndp          1/1     Running     0          52m
jenkins-x-controllerworkflow-76bb4755f6-nnwp5      1/1     Running     0          52m
jenkins-x-docker-registry-fb7878f76-d456t          1/1     Running     0          52m
jenkins-x-gcactivities-1548072000-bnnvh            0/1     Completed   0          40m
jenkins-x-gcactivities-1548073800-rmm68            0/1     Completed   0          10m
jenkins-x-gcpods-1548072000-tnslc                  0/1     Completed   0          40m
jenkins-x-gcpods-1548073800-kwwbr                  0/1     Completed   0          10m
jenkins-x-heapster-c6d44bc95-c2qvx                 2/2     Running     0          52m
jenkins-x-mongodb-7dd488d47b-hxs9v                 1/1     Running     1          52m
jenkins-x-monocular-api-595b688c65-4xgz2           1/1     Running     1          52m
jenkins-x-monocular-prerender-64f989797b-6v5xv     1/1     Running     0          52m
jenkins-x-monocular-ui-67dcd5cd57-c4xt2            1/1     Running     0          52m
jenkins-x-nexus-688df8c75f-4bcj2                   1/1     Running     0          52m
plank-554959d957-655dh                             1/1     Running     0          53m
prow-build-78955d585f-9zs57                        1/1     Running     0          53m
sinker-6fb9f8dbdd-887sk                            1/1     Running     0          53m
tide-cf5f5b8d5-rn5pj                               1/1     Running     0          53m
```

```bash
jx console
```

```
> jenkins-x-chartmuseum
  jenkins-x-docker-registry
  jenkins-x-mongodb
  jenkins-x-monocular-api
  jenkins-x-monocular-prerender
  jenkins-x-monocular-ui
```

```bash
jx get activities

jx create quickstart -l go -p jx-go -b

kubectl -n jx get pods
```

```
NAME                                               READY   STATUS      RESTARTS   AGE
359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228    0/1     Init:2/3    0          20s
build-controller-6d8c58db8b-wz99p                  1/1     Running     0          58m
buildnum-77bdbb8bb-g59qv                           1/1     Running     0          57m
crier-766b799476-5bdvr                             1/1     Running     0          57m
deck-77bcb6c7cd-jv7tx                              1/1     Running     0          57m
deck-77bcb6c7cd-k6g8x                              1/1     Running     0          57m
hook-7bdd7f86c9-ds6qd                              1/1     Running     0          57m
hook-7bdd7f86c9-lj584                              1/1     Running     0          57m
horologium-7cc979bd5c-jfxln                        1/1     Running     0          57m
jenkins-x-chartmuseum-5b6f9fd646-nh9ng             1/1     Running     0          56m
jenkins-x-controllerbuild-68646c5c9d-t7jkg         1/1     Running     0          56m
jenkins-x-controllercommitstatus-dd46689c8-qs96g   1/1     Running     0          56m
jenkins-x-controllerrole-67dcc687cc-r8lrl          1/1     Running     0          56m
jenkins-x-controllerteam-59bb947b8b-mgndp          1/1     Running     0          56m
jenkins-x-controllerworkflow-76bb4755f6-nnwp5      1/1     Running     0          56m
jenkins-x-docker-registry-fb7878f76-d456t          1/1     Running     0          56m
jenkins-x-gcactivities-1548072000-bnnvh            0/1     Completed   0          44m
jenkins-x-gcactivities-1548073800-rmm68            0/1     Completed   0          14m
jenkins-x-gcpods-1548072000-tnslc                  0/1     Completed   0          44m
jenkins-x-gcpods-1548073800-kwwbr                  0/1     Completed   0          14m
jenkins-x-heapster-c6d44bc95-c2qvx                 2/2     Running     0          56m
jenkins-x-mongodb-7dd488d47b-hxs9v                 1/1     Running     1          56m
jenkins-x-monocular-api-595b688c65-4xgz2           1/1     Running     1          56m
jenkins-x-monocular-prerender-64f989797b-6v5xv     1/1     Running     0          56m
jenkins-x-monocular-ui-67dcd5cd57-c4xt2            1/1     Running     0          56m
jenkins-x-nexus-688df8c75f-4bcj2                   1/1     Running     0          56m
plank-554959d957-655dh                             1/1     Running     0          57m
prow-build-78955d585f-9zs57                        1/1     Running     0          57m
sinker-6fb9f8dbdd-887sk                            1/1     Running     0          57m
tide-cf5f5b8d5-rn5pj                               1/1     Running     0          57m
```

```bash
jx get activities
```

```
STEP                     STARTED AGO DURATION STATUS
vfarcic/jx-go/master #1        1m23s          Running
  Credential Initializer       1m23s       0s Succeeded
  Git Source 0                                Pending https://github.com/vfarcic/jx-go.git
  Jenkins                                     Pending
```

```bash
jx logs -k
```

```
Waiting for a running Knative build pod in namespace jx
Found newest pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-credential-initializer
{"level":"warn","ts":1548074636.630049,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074636.6314034,"logger":"fallback-logger","caller":"creds-init/main.go:40","msg":"Credentials initialized."}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-git-source-0
{"level":"warn","ts":1548074638.4099896,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074638.6809788,"logger":"fallback-logger","caller":"git-init/main.go:92","msg":"Successfully cloned \"https://github.com/vfarcic/jx-go.git\" @ \"master\" in path \"/workspace\""}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-credential-initializer
{"level":"warn","ts":1548074636.630049,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074636.6314034,"logger":"fallback-logger","caller":"creds-init/main.go:40","msg":"Credentials initialized."}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-git-source-0
{"level":"warn","ts":1548074638.4099896,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074638.6809788,"logger":"fallback-logger","caller":"git-init/main.go:92","msg":"Successfully cloned \"https://github.com/vfarcic/jx-go.git\" @ \"master\" in path \"/workspace\""}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-credential-initializer
{"level":"warn","ts":1548074636.630049,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074636.6314034,"logger":"fallback-logger","caller":"creds-init/main.go:40","msg":"Credentials initialized."}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-git-source-0
{"level":"warn","ts":1548074638.4099896,"logger":"fallback-logger","caller":"logging/config.go:65","msg":"Fetch GitHub commit ID from kodata failed: \"ref: refs/heads/test\" is not a valid GitHub commit ID"}
{"level":"info","ts":1548074638.6809788,"logger":"fallback-logger","caller":"git-init/main.go:92","msg":"Successfully cloned \"https://github.com/vfarcic/jx-go.git\" @ \"master\" in path \"/workspace\""}
Init container on pod: 359b6f4c-1d7a-11e9-9457-30230373a07c-pod-667228 is: build-step-jenkins
Picked up _JAVA_OPTIONS: -Xmx400m
Started
Running in Durability level: PERFORMANCE_OPTIMIZED
  18.979 [id=34]        WARNING i.f.k.c.i.VersionUsageUtils#alert: The client is using resource type 'customresourcedefinitions' with unstable version 'v1beta1'
[Pipeline] node
Running on Jenkins in /tmp/jenkinsTests.tmp/jenkins2826394166145323058test/workspace/job
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Declarative: Checkout SCM)
[Pipeline] checkout
[Pipeline] }
[Pipeline] // stage
[Pipeline] withCredentials
[Pipeline] {
[Pipeline] withEnv
[Pipeline] {
[Pipeline] stage
[Pipeline] { (CI Build and push snapshot)
Stage "CI Build and push snapshot" skipped due to when conditional
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Build Release)
[Pipeline] dir
Running in /home/jenkins/go/src/github.com/vfarcic/jx-go
[Pipeline] {
[Pipeline] git
Cloning the remote Git repository
Cloning repository https://github.com/vfarcic/jx-go.git
 > git init /home/jenkins/go/src/github.com/vfarcic/jx-go # timeout=10
Fetching upstream changes from https://github.com/vfarcic/jx-go.git
 > git --version # timeout=10
 > git fetch --tags --progress https://github.com/vfarcic/jx-go.git +refs/heads/*:refs/remotes/origin/*
 > git config remote.origin.url https://github.com/vfarcic/jx-go.git # timeout=10
 > git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git config remote.origin.url https://github.com/vfarcic/jx-go.git # timeout=10
Fetching upstream changes from https://github.com/vfarcic/jx-go.git
 > git fetch --tags --progress https://github.com/vfarcic/jx-go.git +refs/heads/*:refs/remotes/origin/*
 > git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
Checking out Revision ac61663c66a30230f1fe2673564a7322b51b60ed (refs/remotes/origin/master)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f ac61663c66a30230f1fe2673564a7322b51b60ed
 > git branch -a -v --no-abbrev # timeout=10
 > git checkout -b master ac61663c66a30230f1fe2673564a7322b51b60ed
Commit message: "Draft create"
First time build. Skipping changelog.
[Pipeline] sh
+ jx-release-version
+ echo 0.0.1
[Pipeline] sh
+ cat VERSION
+ jx step tag --version 0.0.1
Tag v0.0.1 created and pushed to remote origin
[Pipeline] sh
+ make build
CGO_ENABLED=0 GO15VENDOREXPERIMENT=1 go build -ldflags '' -o bin/jx-go main.go
[Pipeline] sh
+ cat VERSION
+ export VERSION=0.0.1
+ skaffold build -f skaffold.yaml
Starting build...
Building [changeme]...
Sending build context to Docker daemon  6.506MB
Step 1/4 : FROM scratch
 --->
Step 2/4 : EXPOSE 8080
 ---> Running in 6ead86484cb6
 ---> 0a3b6cbce573
Step 3/4 : ENTRYPOINT /jx-go
 ---> Running in 84f3c1aa9628
 ---> 4bad0075d276
Step 4/4 : COPY ./bin/ /
 ---> ff8869653123
Successfully built ff8869653123
The push refers to a repository [10.31.244.225:5000/vfarcic/jx-go]
e8a596b3e697: Preparing
e8a596b3e697: Pushed
0.0.1: digest: sha256:02cb565d8740e235df2945b1592c80852aca9eea930a7d4d5d769d4edaf9d83c size: 528
Build complete in 1.553868918s
Starting test...
Test complete in 4.755µs
changeme -> 10.31.244.225:5000/vfarcic/jx-go:0.0.1
[Pipeline] sh
+ cat VERSION
+ jx step post build --image 10.31.244.225:5000/vfarcic/jx-go:0.0.1
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Promote to Environments)
[Pipeline] dir
Running in /home/jenkins/go/src/github.com/vfarcic/jx-go/charts/jx-go
[Pipeline] {
[Pipeline] sh
+ cat ../../VERSION
+ jx step changelog --version v0.0.1
Using batch mode as inside a pipeline
Generating change log from git ref ac61663c66a30230f1fe2673564a7322b51b60ed => cf74c26c064005d5ccd359c821bb931f23e7b4c2
Failed to enrich commits with issues: User.jenkins.io "" is invalid: metadata.name: Required value: name or generateName is required
Failed to enrich commits with issues: User.jenkins.io "" is invalid: metadata.name: Required value: name or generateName is required
Finding issues in commit messages using git format
No release found for vfarcic/jx-go and tag v0.0.1 so creating a new release
Updated the release information at https://github.com/vfarcic/jx-go/releases/tag/v0.0.1
generated: /home/jenkins/go/src/github.com/vfarcic/jx-go/charts/jx-go/templates/release.yaml
Created Release jx-go-0-0-1 resource in namespace jx
Updating PipelineActivity vfarcic-jx-go-master-1 with version 0.0.1
Updated PipelineActivities vfarcic-jx-go-master-1 with release notes URL: https://github.com/vfarcic/jx-go/releases/tag/v0.0.1
[Pipeline] sh
+ jx step helm release
No $CHART_REPOSITORY defined so using the default value of: http://jenkins-x-chartmuseum:8080
Adding missing Helm repo: releases http://jenkins-x-chartmuseum:8080
Successfully added Helm repository releases.
Adding missing Helm repo: jenkins-x http://chartmuseum.jenkins-x.io
Successfully added Helm repository jenkins-x.
No $CHART_REPOSITORY defined so using the default value of: http://jenkins-x-chartmuseum:8080
Uploading chart file jx-go-0.0.1.tgz to http://jenkins-x-chartmuseum:8080/api/charts
Received 201 response: {"saved":true}
[Pipeline] sh
+ cat ../../VERSION
+ jx promote -b --all-auto --timeout 1h --version 0.0.1
prow based install so skip waiting for the merge of Pull Requests to go green as currently there is an issue with gettingstatuses from the PR, see https://github.com/jenkins-x/jx/issues/2410
Promoting app jx-go version 0.0.1 to namespace jx-staging
No changes made to the GitOps Environment source code. Code must be up to date!
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withCredentials
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```

```bash
# Cancel with ctrl+c after `Finished: SUCCESS`

jx get build logs -f jx-go # Available for a few hours

# The same output as `jx logs -k`

jx get pipelines
```

```
Name                                           URL LAST_BUILD STATUS DURATION
jenkins-x/dummy/master                         N/A N/A        N/A    N/A
vfarcic/environment-jx-rocks-production/master N/A N/A        N/A    N/A
vfarcic/environment-jx-rocks-staging/master    N/A N/A        N/A    N/A
vfarcic/jx-go/master                           N/A N/A        N/A    N/A
```

```bash
jx get build logs \
    -f environment-jx-rocks-staging # Available for a few hours

jx get apps

ADDR=$(kubectl -n jx-staging \
    get ing jx-go \
    -o jsonpath="{.spec.rules[0].host}")

curl "http://$ADDR"
```

TODO: prow

TODO: UI through Deck

TODO: Centralized logging

TODO: Changes to Jenkinsfile

```bash

```

```bash
# If GKE
gcloud container clusters \
    delete jx-rocks \
    --zone us-east1-b \
    --quiet

# If GKE
# Remove unused disks to avoid reaching the quota (and save a bit of money)
gcloud compute disks delete \
    $(gcloud compute disks list \
    --filter="-users:*" \
    --format="value(id)")

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

hub delete -y $GH_USER/jx-go

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf jx-go

rm -f ~/.jx/jenkinsAuth.yaml
```