## TODO

- [ ] Code
- [ ] Write
- [ ] Code review static GKE
- [ ] Code review serverless GKE
- [ ] Code review static EKS
- [ ] Code review serverless EKS
- [ ] Code review static AKS
- [ ] Code review serverless AKS
- [ ] Code review existing static cluster
- [ ] Code review existing serverless cluster
- [ ] Text review
- [ ] Gist
- [ ] Review titles
- [ ] Proofread
- [ ] Diagrams
- [ ] Add to slides
- [ ] Publish on TechnologyConversations.com
- [ ] Add to Book.txt
- [ ] Publish on LeanPub.com 

# Boot

NOTE: Validated (works) only with serverless GKE

NOTE: Not using `jx` to create a cluster

* Create new **GKE** cluster: [gke-jx-serverless-boot.sh](TODO:)

```bash
# https://jenkins-x.io/getting-started/boot/

kubectl get nodes
```

```
NAME                                     STATUS   ROLES    AGE   VERSION
gke-jx-boot-default-pool-b09d9ef1-2588   Ready    <none>   39m   v1.13.7-gke.8
gke-jx-boot-default-pool-f11b05ed-f16x   Ready    <none>   39m   v1.13.7-gke.8
gke-jx-boot-default-pool-f93be13a-52x6   Ready    <none>   39m   v1.13.7-gke.8
```

```bash
GH_USER=[...]

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-staging

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-production

open "https://github.com/jenkins-x/jenkins-x-boot-config.git"

# Fork it
```

![Figure 18-TODO: TODO:](images/ch18/jx-boot-github.png)

```bash
git clone \
    https://github.com/$GH_USER/jenkins-x-boot-config.git \
    environment-$CLUSTER_NAME-dev

cd environment-$CLUSTER_NAME-dev

cat jx-requirements.yml
```

```yaml
cluster:
  clusterName: ""
  environmentGitOwner: ""
  project: ""
  provider: gke
  zone: ""
gitops: true
environments:
- key: dev
- key: staging
- key: production
ingress:
  domain: ""
  externalDNS: false
  tls:
    email: ""
    enabled: false
    production: false
kaniko: true
secretStorage: local
storage:
  logs:
    enabled: false
    url: ""
  reports:
    enabled: false
    url: ""
  repository:
    enabled: false
    url: ""
versionStream:
  ref: "master"
  url: https://github.com/jenkins-x/jenkins-x-versions.git
webhook: prow
```

```bash
cat jx-requirements.yml \
    | sed -e \
    "s@clusterName: \"\"@clusterName: \"$CLUSTER_NAME\"@g" \
    | tee jx-requirements.yml

cat jx-requirements.yml \
    | sed -e \
    "s@nvironmentGitOwner: \"\"@nvironmentGitOwner: \"$GH_USER\"@g" \
    | tee jx-requirements.yml

cat jx-requirements.yml \
    | sed -e \
    "s@project: \"\"@project: \"$PROJECT\"@g" \
    | tee jx-requirements.yml

cat jx-requirements.yml \
    | sed -e \
    "s@secretStorage: local@secretStorage: vault@g" \
    | tee jx-requirements.yml

# TODO: Change storage to `enabled: true`

# PROVIDER=[...] # e.g., gke

# cat jx-requirements.yml \
#     | sed -e \
#     "s@provider: gke@provider: $PROVIDER@g" \
#     | tee jx-requirements.yml

ZONE=[...] # e.g., us-east1

cat jx-requirements.yml \
    | sed -e \
    "s@zone: \"\"@zone: \"$ZONE\"@g" \
    | tee jx-requirements.yml

cat jx-requirements.yml
```

```yaml
cluster:
  clusterName: "jx-boot"
  environmentGitOwner: "vfarcic"
  project: "devops-26"
  provider: gke
  zone: "us-east1"
gitops: true
environments:
- key: dev
- key: staging
- key: production
ingress:
  domain: ""
  externalDNS: false
  tls:
    email: ""
    enabled: false
    production: false
kaniko: true
secretStorage: vault
storage:
  logs:
    enabled: true
    url: ""
  reports:
    enabled: true
    url: ""
  repository:
    enabled: true
    url: ""
versionStream:
  ref: "master"
  url: https://github.com/jenkins-x/jenkins-x-versions.git
webhook: prow
```

```bash
jx boot

# Questions:
# ? Do you wish to continue? [? for help] (y/N)
# y
# ? Would you like to upgrade to the jx version? [? for help] (Y/n)
# n
# ? Long term log storage bucket URL. Press enter to create and use a new bucket [? for help]
# enter
# ? Long term report storage bucket URL. Press enter to create and use a new bucket [? for help]
# enter
# ? Chart repository bucket URL. Press enter to create and use a new bucket [? for help]
# enter
# ? Jenkins X Admin Username [? for help] (admin)
# enter
# ? Jenkins X Admin Password [? for help]
# anything
# ? Pipeline bot Git username [? for help]
# vfarcic
# ? Pipeline bot Git email address [? for help]
# viktor@farcic.com
# ? Pipeline bot Git token [? for help]
# anything
# ? HMAC token, used to validate incoming webhooks. Press enter to use the generated token [? for help]
# enter
# ? Do you want to configure an external Docker Registry? [? for help] (y/N)
# enter
```

```
booting up Jenkins X

STEP: validate-git command: /bin/sh -c jx step git validate in dir: env

Git configured for user: Viktor Farcic and email vfarcic@farcic.com

STEP: verify-preinstall command: /bin/sh -c jx step verify preinstall in dir: env

Connecting to cluster jx-boot
Will create public environment repos, if you want to create private environment repos, please set environmentGitPrivate to true jx-requirements.yaml
WARNING: Vault is enabled and TLS is not enabled. This means your secrets will be sent to and from your cluster in the clear. See https://jenkins-x.io/architecture/tls for more information
WARNING: TLS is not enabled so your webhooks will be called using HTTP. This means your webhook secret will be sent to your cluster in the clear. See https://jenkins-x.io/architecture/tls for more information
? Do you wish to continue? Yes

verifying the kubernetes cluster before we try to boot Jenkins X in namespace: jx
we will try to lazily create any missing resources to get the current cluster ready to boot Jenkins X
setting the local kubernetes context to the deploy namespace jx
Now using namespace 'jx' on server 'https://35.229.123.189'.
verifying the CLI packages
verifying the CLI package using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
using version 2.0.695 of jx
the CLI packages seem to be setup correctly kubectl, git, helm

NAME               VERSION
jx                 2.0.695
Kubernetes cluster v1.13.7-gke.8
kubectl            v1.15.3
helm client        v2.14.1+g5270352
git                2.20.1 (Apple Git-117)
? Long term log storage bucket URL. Press enter to create and use a new bucket
The bucket gs://jx-boot-logs-997b82a1-d879-49d1-9b71-b8b71fcf0ee5 does not exist so lets create it
? Long term report storage bucket URL. Press enter to create and use a new bucket
The bucket gs://jx-boot-reports-c9ff9c06-5513-42b8-b1ea-feb0488d99d0 does not exist so lets create it
? Chart repository bucket URL. Press enter to create and use a new bucket
The bucket gs://jx-boot-repository-32bcf1a7-1479-4ab4-ac89-ff4450e940ad does not exist so lets create it
the storage looks good
helm installed and configured
helm client is setup
ensure we have the helm repository https://storage.googleapis.com/chartmuseum.jenkins-x.io
validating the kaniko secret in namespace jx
attempting to lazily create the deploy namespace jx
Configuring Kaniko service account jx-boot-ko for project devops-26
Service Account exists
Downloading service account key
created kaniko Secret: kaniko-secret in namespace: jx
valid: there is a Secret: kaniko-secret in namespace: jx
the cluster looks good, you are ready to 'jx boot' now!


STEP: install-jx-crds command: /bin/sh -c jx upgrade crd in dir: .

Jenkins X CRDs upgraded with success

STEP: install-nginx command: /bin/sh -c jx step helm apply --boot --remote --no-vault --name jxing in dir: systems/jxing

Modified file /Users/vfarcic/code/environment-jx-boot-dev/systems/jxing/Chart.yaml to set the chart to version 1
Copying the helm source directory /Users/vfarcic/code/environment-jx-boot-dev/systems/jxing to a temporary location for building and applying /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-060840734/jxing
Applying helm chart at /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-060840734/jxing as release name jxing to namespace kube-system
verifying the helm requirements versions in dir: . using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
Wrote chart values.yaml /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-060840734/jxing/values.yaml generated from directory tree
generated helm /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-060840734/jxing/values.yaml

nginx-ingress:
  controller:
    extraArgs:
      publish-service: kube-system/jxing-nginx-ingress-controller
    replicaCount: 3
    service:
      omitClusterIP: true
  defaultBackend:
    service:
      omitClusterIP: true
  rbac:
    create: true

Using values files: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-060840734/jxing/values.yaml
verifying the helm requirements versions in dir: . using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
adding version 1.19.1 to dependency nginx-ingress in file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-060840734/jxing/requirements.yaml
adding dependency versions to file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-060840734/jxing/requirements.yaml
Applying Apps chart overrides
Applying chart overrides


STEP: create-install-values command: /bin/sh -c jx step create install values -b in dir: env


Waiting to find the external host name of the ingress controller Service in namespace kube-system with name jxing-nginx-ingress-controller
No domain flag provided so using default  to generate Ingress rules
waiting for external Host on the ingress service jxing-nginx-ingress-controller in namespace kube-system ...

Waiting to find the external host name of the ingress controller Service in namespace kube-system with name jxing-nginx-ingress-controller
No domain flag provided so using default 35.229.50.53.nip.io to generate Ingress rules
defaulting the domain to 35.229.50.53.nip.io and modified /Users/vfarcic/code/environment-jx-boot-dev/jx-requirements.yml
Disabling using external-dns as it currently only works on GKE and not nip.io domains

STEP: install-external-dns command: /bin/sh -c jx step helm apply --boot --remote --no-vault --name jx in dir: systems/external-dns

Modified file /Users/vfarcic/code/environment-jx-boot-dev/systems/external-dns/Chart.yaml to set the chart to version 1
Copying the helm source directory /Users/vfarcic/code/environment-jx-boot-dev/systems/external-dns to a temporary location for building and applying /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-950112292/external-dns
Applying helm chart at /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-950112292/external-dns as release name jx to namespace jx
verifying the helm requirements versions in dir: . using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
Wrote chart values.yaml /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-950112292/external-dns/values.yaml generated from directory tree
generated helm /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-950112292/external-dns/values.yaml

external-dns:
  domainFilters:
  - 35.229.50.53.nip.io
  enabled: false
  google:
    serviceAccountSecret: external-dns-gcp-sa
  provider: google
  rbac:
    create: true
  sources:
  - ingress

Using values files:
verifying the helm requirements versions in dir: . using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
adding version 2.6.0 to dependency external-dns in file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-950112292/external-dns/requirements.yaml
adding dependency versions to file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-950112292/external-dns/requirements.yaml
Applying Apps chart overrides
Applying chart overrides

STEP: install-cert-manager-crds command: /bin/sh -c kubectl apply --wait --validate=true -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml in dir: .

customresourcedefinition.apiextensions.k8s.io/certificates.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/challenges.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/issuers.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/orders.certmanager.k8s.io created

STEP: install-cert-manager command: /bin/sh -c jx step helm apply --boot --remote --no-vault --name jx in dir: systems/cm

Modified file /Users/vfarcic/code/environment-jx-boot-dev/systems/cm/Chart.yaml to set the chart to version 1
Namespace cert-manager created
Copying the helm source directory /Users/vfarcic/code/environment-jx-boot-dev/systems/cm to a temporary location for building and applying /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-336692860/cm
Applying helm chart at /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-336692860/cm as release name jx to namespace cert-manager
verifying the helm requirements versions in dir: . using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
Wrote chart values.yaml /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-336692860/cm/values.yaml generated from directory tree
generated helm /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-336692860/cm/values.yaml

cert-manager:
  enabled: false
  rbac:
    create: true
  webhook:
    enabled: false
webhook:
  enabled: false

Using values files:
verifying the helm requirements versions in dir: . using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
adding version v0.9.1 to dependency cert-manager in file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-336692860/cm/requirements.yaml
adding dependency versions to file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-336692860/cm/requirements.yaml
Applying Apps chart overrides
Applying chart overrides

STEP: install-acme-issuer-and-certificate command: /bin/sh -c jx step helm apply --boot --remote --no-vault --name jx in dir: systems/acme

Modified file /Users/vfarcic/code/environment-jx-boot-dev/systems/acme/Chart.yaml to set the chart to version 1
Copying the helm source directory /Users/vfarcic/code/environment-jx-boot-dev/systems/acme to a temporary location for building and applying /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-328799391/acme
Applying helm chart at /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-328799391/acme as release name jx to namespace jx
verifying the helm requirements versions in dir: . using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
Ignoring templates/cert-manager-prod-certificate.yaml
Ignoring templates/cert-manager-prod-issuer.yaml
Ignoring templates/cert-manager-staging-certificate.yaml
Ignoring templates/cert-manager-staging-issuer.yaml
Wrote chart values.yaml /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-328799391/acme/values.yaml generated from directory tree
generated helm /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-328799391/acme/values.yaml

certmanager:
  email: ""
  enabled: false
  production: "false"
cluster:
  domain: 35.229.50.53.nip.io
  projectID: devops-26

Using values files:
no requirements file: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-328799391/acme/requirements.yaml so not checking for missing versions
Applying Apps chart overrides
Applying chart overrides

STEP: install-vault command: /bin/sh -c jx step boot vault in dir: systems/vault

applying vault ingress in namespace jx for vault name jx-vault-jx-boot
ingress.extensions/jx-vault-jx-boot created
Installing vault-operator...

vault-operator addon succesfully installed.
vault operator installed in namespace jx
finding vault in namespace jx
Creating new system vault
Updated property [core/project].
Service Account exists
Downloading service account key
GCS bucket jx-vault-jx-boot-bucket was created for Vault backend
Creating Vault...
Vault jx-vault-jx-boot created in cluster jx-boot
not exposing vault jx-vault-jx-boot exposed
System vault created named jx-vault-jx-boot in namespace jx.

STEP: helm-populate-params command: /bin/sh -c jx step create values --name parameters in dir: env

defaulting to secret storage scheme vault found from requirements file at /Users/vfarcic/code/environment-jx-boot-dev/jx-requirements.yml
defaulting to secret base path to the cluster name jx-boot found from requirements file at /Users/vfarcic/code/environment-jx-boot-dev/jx-requirements.yml
generated schema file /Users/vfarcic/code/environment-jx-boot-dev/env/parameters.schema.json from template /Users/vfarcic/code/environment-jx-boot-dev/env/parameters.tmpl.schema.json

Waiting for vault to be initialized and unsealed...
? Jenkins X Admin Username admin
? Jenkins X Admin Password [? for help] ***********
? Pipeline bot Git username vfarcic
? Pipeline bot Git email address viktor@farcic.com
? Pipeline bot Git token [? for help] ****************************************
Generated token 6cd94240f40cecf8d4f3ff091505c8aac1ac7e2fb, to use it press enter.
This is the only time you will be shown it so remember to save it
? HMAC token, used to validate incoming webhooks. Press enter to use the generated token [? for help]
? Do you want to configure an external Docker Registry? No


STEP: install-env command: /bin/sh -c jx step helm apply --boot --remote --name jenkins-x --provider-values-dir ../kubeProviders in dir: env

Modified file /Users/vfarcic/code/environment-jx-boot-dev/env/Chart.yaml to set the chart to version 1
Copying the helm source directory /Users/vfarcic/code/environment-jx-boot-dev/env to a temporary location for building and applying /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env
Applying helm chart at /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env as release name jenkins-x to namespace jx
Fetching secrets from vault into directory "/var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env"
verifying the helm requirements versions in dir: . using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
Ignoring templates/.gitignore
Applying the kubernetes overrides at ../kubeProviders/gke/values.tmpl.yaml
Wrote chart values.yaml /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env/values.yaml generated from directory tree
generated helm /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env/values.yaml

controllerbuild:
  enabled: true
controllerteam:
  enabled: false
controllerworkflow:
  enabled: false
docker-registry:
  enabled: false
jenkins:
  enabled: false
jenkins-x-platform:
  JXBasicAuth: *****:{SHA}d6gizhGQ4kEhON/O57h9tQXnH0A=
  PipelineSecrets:
    DockerConfig: |-
      {
          "credHelpers": {
              "gcr.io": "gcr",
              "us.gcr.io": "gcr",
              "eu.gcr.io": "gcr",
              "asia.gcr.io": "gcr",
              "staging-k8s.gcr.io": "gcr"
          }
      }
    GitCreds: https://*******:****************************************@github.com
    GithubToken: ****************************************
    MavenSettingsXML: |-
      <settings>
          <localRepository>/home/jenkins/.mvnrepository</localRepository>
          <!--This sends everything else to /public -->
          <mirrors>
              <mirror>
                  <id>nexus</id>
                  <mirrorOf>external:*</mirrorOf>
                  <url>http://nexus/repository/maven-group/</url>
              </mirror>
          </mirrors>

          <!-- lets disable the download progress indicator that fills up logs -->
          <interactiveMode>false</interactiveMode>

          <servers>
              <server>
                  <id>local-nexus</id>
                  <username>*****</username>
                  <password>***********</password>
              </server>
              <server>
                  <id>nexus</id>
                  <username>*****</username>
                  <password>***********</password>
              </server>
              <server>
                  <id>docker.io</id>
              </server>
          </servers>

          <profiles>
              <profile>
                  <id>nexus</id>
                  <properties>
                      <altDeploymentRepository>local-nexus::default::http://nexus/repository/maven-snapshots/</altDeploymentRepository>
                      <altReleaseDeploymentRepository>local-nexus::default::http://nexus/repository/maven-releases/</altReleaseDeploymentRepository>
                      <altSnapshotDeploymentRepository>local-nexus::default::http://nexus/repository/maven-snapshots/</altSnapshotDeploymentRepository>
                  </properties>

                  <repositories>
                      <repository>
                          <id>central</id>
                          <url>http://central</url>
                          <releases><enabled>true</enabled></releases>
                          <snapshots><enabled>true</enabled></snapshots>
                      </repository>
                  </repositories>
                  <pluginRepositories>
                      <pluginRepository>
                          <id>central</id>
                          <url>http://central</url>
                          <releases><enabled>true</enabled></releases>
                          <snapshots><enabled>true</enabled></snapshots>
                      </pluginRepository>
                  </pluginRepositories>
              </profile>
              <profile>
                  <id>repo.jenkins-ci.org</id>
                  <properties>
                      <altDeploymentRepository>repo.jenkins-ci.org::default::https://repo.jenkins-ci.org/releases/</altDeploymentRepository>
                      <altReleaseDeploymentRepository>repo.jenkins-ci.org::default::https://repo.jenkins-ci.org/releases/</altReleaseDeploymentRepository>
                      <altSnapshotDeploymentRepository>repo.jenkins-ci.org::default::https://repo.jenkins-ci.org/snapshots/</altSnapshotDeploymentRepository>
                  </properties>

              </profile>
              <profile>
                  <id>maven.jenkins-ci.org</id>
                  <properties>
                      <altDeploymentRepository>maven.jenkins-ci.org::default::https://maven.jenkins-ci.org/releases/</altDeploymentRepository>
                      <altReleaseDeploymentRepository>maven.jenkins-ci.org::default::https://maven.jenkins-ci.org/releases/</altReleaseDeploymentRepository>
                      <altSnapshotDeploymentRepository>maven.jenkins-ci.org::default::https://maven.jenkins-ci.org/snapshots/</altSnapshotDeploymentRepository>
                  </properties>

              </profile>
              <profile>
                  <id>release</id>
                  <properties>
                      <gpg.executable>gpg</gpg.executable>
                      <!-- TODO use: .Parameters.gpg.passphrase when it is always populated -->
                      <gpg.passphrase></gpg.passphrase>
                  </properties>
              </profile>
          </profiles>

          <activeProfiles>
              <activeProfile>nexus</activeProfile>
          </activeProfiles>
      </settings>
    SSHConfig: |-
      Host github.com
          User git
          IdentityFile /root/.ssh-git/ssh-key
          StrictHostKeyChecking no
  chartmuseum:
    env:
      secret:
        BASIC_AUTH_PASS: ***********
        BASIC_AUTH_USER: *****
  cleanup:
    enabled: false
  dockerRegistry: gcr.io
  expose:
    enabled: false
  gcactivities:
    args:
    - gc
    - activities
    - --batch-mode
    - --pr-history-limit=30
    cronjob:
      enabled: true
      schedule: 0/30 * * * *
    image:
      repository: gcr.io/jenkinsxio/builder-jx
      tag: 0.1.658
  gcpods:
    cronjob:
      enabled: true
      schedule: 0/30 * * * *
  jenkins:
    Master:
      AdminPassword: ***********
  nexus:
    defaultAdminPassword: ***********
jxboot-resources:
  JenkinsXGitHub:
    password: ****************************************
    username: *******
  certmanager:
    enabled: false
    production: "false"
  cleanup:
    enabled: false
  cluster:
    domain: 35.229.50.53.nip.io
    name: ""
    namespace: jx
    namespaceSubDomain: -jx.
    projectID: devops-26
    serverUrl: ""
    zone: us-east1
  controllerbuild:
    enabled: true
  controllerteam:
    enabled: false
  controllerworkflow:
    enabled: false
  expose:
    enabled: false
  gitops:
    dev:
      dockerRegistryOrg: devops-26
      envOrganisation: *******
      owner: *******
      repo: environment-jx-boot-dev
      server: ""
    gitKind: github
    gitName: github
    gitUrlPathPrefix: ""
    owner: *******
    production:
      owner: *******
      repo: environment-jx-boot-production
      server: ""
    server: https://github.com
    staging:
      owner: *******
      repo: environment-jx-boot-staging
      server: ""
    versionStreamRef: master
    versionStreamUrl: https://github.com/jenkins-x/jenkins-x-versions.git
    webhook: prow
  jenkins:
    enabled: false
  jenkins-x-platform:
    chartmuseum:
      enabled: true
      env:
        open:
          AUTH_ANONYMOUS_GET: true
          DISABLE_API: false
      image:
        tag: v0.7.1
    controllerbuild:
      enabled: true
    jenkins:
      Agent:
        PodTemplates:
          Go:
            Containers:
              Go:
                Image: jenkinsxio/builder-go:latest
          Maven:
            Containers:
              Maven:
                Image: jenkinsxio/builder-maven:latest
            volumes:
            - mountPath: /root/.m2/
              secretName: jenkins-maven-settings
              type: Secret
            - mountPath: /home/jenkins/.docker
              secretName: jenkins-docker-cfg
              type: Secret
          Nodejs:
            Containers:
              Nodejs:
                Image: jenkinsxio/builder-nodejs:latest
    monocular:
      api:
        livenessProbe:
          initialDelaySeconds: 1000
    nexus:
      persistence:
        size: 100Gi
    postinstalljob:
      enabled: "true"
  lighthouse:
    enabled: false
  prow:
    enabled: true
  storage:
    logs:
      url: gs://jx-boot-logs-997b82a1-d879-49d1-9b71-b8b71fcf0ee5
    reports:
      url: gs://jx-boot-reports-c9ff9c06-5513-42b8-b1ea-feb0488d99d0
    repository:
      url: gs://jx-boot-repository-32bcf1a7-1479-4ab4-ac89-ff4450e940ad
  tekton:
    webhook:
      enabled: false
lighthouse:
  enabled: false
  git:
    kind: github
    name: github
    server: https://github.com
  hmacToken: *****************************************
  image:
    repository: gcr.io/jenkinsxio/lighthouse
  replicaCount: 1
  service:
    name: hook
nexus:
  enabled: true
prow:
  buildnum:
    enabled: false
  enabled: true
  hmacToken: *****************************************
  oauthToken: ****************************************
  pipelinerunner:
    args:
    - controller
    - pipelinerunner
    - --use-meta-pipeline=false
    enabled: "true"
  sinker:
    replicaCount: 0
  tillerNamespace: ""
  user: *******
tekton:
  auth:
    git:
      password: ****************************************
      url: https://github.com
      username: *******
  enabled: true
  tillerNamespace: ""
  webhook:
    enabled: false

Using values files:
verifying the helm requirements versions in dir: . using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
adding version 0.0.6 to dependency jxboot-resources in file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env/requirements.yaml
adding version 0.0.42 to dependency tekton in file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env/requirements.yaml
adding version 0.0.1164 to dependency prow in file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env/requirements.yaml
adding version 0.0.82 to dependency lighthouse in file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env/requirements.yaml
adding version 2.0.1119 to dependency jenkins-x-platform in file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env/requirements.yaml
adding dependency versions to file /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-253488004/env/requirements.yaml
Applying Apps chart overrides
Applying chart overrides



STEP: verify-env command: /bin/sh -c jx step verify env in dir: .

validating git repository for dev at URL https://github.com/vfarcic/environment-jx-boot-dev.git
creating environment dev git repository for URL: https://github.com/vfarcic/environment-jx-boot-dev.git to namespace jx
Duplicated Git repository https://github.com/vfarcic/jenkins-x-boot-config to https://github.com/vfarcic/environment-jx-boot-dev
Setting upstream to https://github.com/vfarcic/environment-jx-boot-dev
Created Pull Request: https://github.com/vfarcic/environment-jx-boot-dev/pull/1
Added label jx/boot to Pull Request https://github.com/vfarcic/environment-jx-boot-dev/pull/1
validating git repository for production at URL https://github.com/vfarcic/environment-jx-boot-production.git
creating environment production git repository for URL: https://github.com/vfarcic/environment-jx-boot-production.git to namespace jx-production
Using Git provider github at https://github.com
? Using Git user name: vfarcic
? Using organisation: vfarcic
Creating repository vfarcic/environment-jx-boot-production
Creating Git repository vfarcic/environment-jx-boot-production
Pushed Git repository to https://github.com/vfarcic/environment-jx-boot-production

validating git repository for staging at URL https://github.com/vfarcic/environment-jx-boot-staging.git
creating environment staging git repository for URL: https://github.com/vfarcic/environment-jx-boot-staging.git to namespace jx-staging
Using Git provider github at https://github.com
? Using Git user name: vfarcic
? Using organisation: vfarcic
Creating repository vfarcic/environment-jx-boot-staging
Creating Git repository vfarcic/environment-jx-boot-staging
Pushed Git repository to https://github.com/vfarcic/environment-jx-boot-staging

the git repositories for the environments look good


STEP: log-repos command: /bin/sh -c echo   now populating projects....   in dir: repositories

now populating projects....

STEP: apply-repositories command: /bin/sh -c jx step helm apply --boot --name repos in dir: repositories

Modified file /Users/vfarcic/code/environment-jx-boot-dev/repositories/Chart.yaml to set the chart to version 1
Copying the helm source directory /Users/vfarcic/code/environment-jx-boot-dev/repositories to a temporary location for building and applying /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-993141947/repositories
Applying helm chart at /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-993141947/repositories as release name repos to namespace jx
Fetching secrets from vault into directory "/var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-993141947/repositories"
verifying the helm requirements versions in dir: . using version stream URL: https://github.com/jenkins-x/jenkins-x-versions.git and git ref: master
Ignoring templates/default-group.yaml
Wrote chart values.yaml /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-993141947/repositories/values.yaml generated from directory tree
generated helm /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-993141947/repositories/values.yaml

{}

Using values files:
no requirements file: /var/folders/73/94ypm_917397bvg1y3f7phkc0000gn/T/jx-helm-apply-993141947/repositories/requirements.yaml so not checking for missing versions
Applying Apps chart overrides
Applying chart overrides


STEP: apply-pipeline-schedulers command: /bin/sh -c jx step scheduler config apply --direct=true in dir: prowConfig


STEP: update-webhooks command: /bin/sh -c jx update webhooks --verbose --warn-on-fail in dir: repositories

DEBUG: finding service url for hook in namespace jx
DEBUG: couldn't find service url, attempting to look up via ingress
DEBUG: found service url http://hook-jx.35.229.50.53.nip.io
DEBUG: getting vault name for namespace jx
DEBUG: system vault name from config jx-vault-jx-boot
DEBUG: finding service url for jx-vault-jx-boot in namespace jx
DEBUG: couldn't find service url, attempting to look up via ingress
DEBUG: found service url http://vault-jx.35.229.50.53.nip.io
DEBUG: Connecting to vault on http://vault-jx.35.229.50.53.nip.io
DEBUG: merging pipeline secrets with local secrets
Updating webhooks for Owner: vfarcic and Repository: environment-jx-boot-dev in git server: https://github.com
Checking hooks for repository vfarcic/environment-jx-boot-dev with user vfarcic
Creating GitHub webhook for vfarcic/environment-jx-boot-dev for url http://hook-jx.35.229.50.53.nip.io/hook
DEBUG: getting vault name for namespace jx
DEBUG: system vault name from config jx-vault-jx-boot
DEBUG: finding service url for jx-vault-jx-boot in namespace jx
DEBUG: couldn't find service url, attempting to look up via ingress
DEBUG: found service url http://vault-jx.35.229.50.53.nip.io
DEBUG: Connecting to vault on http://vault-jx.35.229.50.53.nip.io
DEBUG: merging pipeline secrets with local secrets
Updating webhooks for Owner: vfarcic and Repository: environment-jx-boot-production in git server: https://github.com
Checking hooks for repository vfarcic/environment-jx-boot-production with user vfarcic
Creating GitHub webhook for vfarcic/environment-jx-boot-production for url http://hook-jx.35.229.50.53.nip.io/hook
DEBUG: getting vault name for namespace jx
DEBUG: system vault name from config jx-vault-jx-boot
DEBUG: finding service url for jx-vault-jx-boot in namespace jx
DEBUG: couldn't find service url, attempting to look up via ingress
DEBUG: found service url http://vault-jx.35.229.50.53.nip.io
DEBUG: Connecting to vault on http://vault-jx.35.229.50.53.nip.io
DEBUG: merging pipeline secrets with local secrets
Updating webhooks for Owner: vfarcic and Repository: environment-jx-boot-staging in git server: https://github.com
Checking hooks for repository vfarcic/environment-jx-boot-staging with user vfarcic
Creating GitHub webhook for vfarcic/environment-jx-boot-staging for url http://hook-jx.35.229.50.53.nip.io/hook

STEP: verify-install command: /bin/sh -c jx step verify install --pod-wait-time 30m in dir: env

verifying the Jenkins X installation in namespace jx
verifying pods
Checking pod statuses
POD                                          STATUS
crier-bdf994874-vtxck                        Pending
deck-8b49bcfc6-g9mcl                         Pending
deck-8b49bcfc6-qprn4                         Pending
hook-787c4d8fb8-5q5zz                        Pending
hook-787c4d8fb8-fk8c4                        Pending
horologium-5bdb48d8f9-jd7gk                  Pending
jenkins-x-chartmuseum-67f75c4884-crcsr       Running
jenkins-x-controllerbuild-647dd5f44-zlgt2    Running
jenkins-x-controllerrole-7b8fc6d89b-5pb72    Running
jenkins-x-heapster-66754b8fc5-pdj2s          Running
jenkins-x-nexus-57c8447c4-gdk7l              Running
jx-vault-jx-boot-0                           Running
jx-vault-jx-boot-configurer-7d9d646dd5-2qflf Running
pipeline-cc8cb56db-zcdkl                     Pending
pipelinerunner-5474fdd88-qmhxk               Running
plank-5cd9f95df7-4v8hp                       Pending
prow-build-6b7dfcb76b-qf2vh                  Pending
tekton-pipelines-controller-65fff67458-zfjst Running
tide-9ddfd58f9-98cqh                         Pending
vault-operator-798dccf8fc-7cgxg              Running
WARNING: the following pods are not Ready:
Running: jenkins-x-nexus-57c8447c4-gdk7l
Pending: crier-bdf994874-vtxck, deck-8b49bcfc6-g9mcl, deck-8b49bcfc6-qprn4, hook-787c4d8fb8-5q5zz, hook-787c4d8fb8-fk8c4, horologium-5bdb48d8f9-jd7gk, pipeline-cc8cb56db-zcdkl, plank-5cd9f95df7-4v8hp, prow-build-6b7dfcb76b-qf2vh, tide-9ddfd58f9-98cqh

Waiting 30m0s for the pods to become Ready...

WARNING: retrying after error: the following pods are not Ready:
Pending: crier-bdf994874-vtxck, deck-8b49bcfc6-g9mcl, deck-8b49bcfc6-qprn4, hook-787c4d8fb8-5q5zz, hook-787c4d8fb8-fk8c4, horologium-5bdb48d8f9-jd7gk, pipeline-cc8cb56db-zcdkl, plank-5cd9f95df7-4v8hp, prow-build-6b7dfcb76b-qf2vh, tide-9ddfd58f9-98cqh
Running: jenkins-x-nexus-57c8447c4-gdk7l
WARNING: retrying after error: the following pods are not Ready:
Pending: crier-bdf994874-vtxck, deck-8b49bcfc6-g9mcl, deck-8b49bcfc6-qprn4, hook-787c4d8fb8-5q5zz, hook-787c4d8fb8-fk8c4, horologium-5bdb48d8f9-jd7gk, pipeline-cc8cb56db-zcdkl, plank-5cd9f95df7-4v8hp, prow-build-6b7dfcb76b-qf2vh, tide-9ddfd58f9-98cqh
.

WARNING: retrying after error: the following pods are not Ready:
Running: deck-8b49bcfc6-g9mcl, deck-8b49bcfc6-qprn4, hook-787c4d8fb8-fk8c4
Pending: hook-787c4d8fb8-5q5zz, horologium-5bdb48d8f9-jd7gk, pipeline-cc8cb56db-zcdkl, plank-5cd9f95df7-4v8hp, tide-9ddfd58f9-98cqh
WARNING: retrying after error: the following pods are not Ready:
Running: deck-8b49bcfc6-g9mcl, deck-8b49bcfc6-qprn4
Pending: tide-9ddfd58f9-98cqh
WARNING: retrying after error: the following pods are not Ready:
Running: deck-8b49bcfc6-g9mcl, deck-8b49bcfc6-qprn4, tide-9ddfd58f9-98cqh
WARNING: retrying after error: the following pods are not Ready:
Running: deck-8b49bcfc6-qprn4
.
.
.
.
.
.
.

POD                                          STATUS
crier-bdf994874-vtxck                        Running
deck-8b49bcfc6-g9mcl                         Running
deck-8b49bcfc6-qprn4                         Running
hook-787c4d8fb8-5q5zz                        Running
hook-787c4d8fb8-fk8c4                        Running
horologium-5bdb48d8f9-jd7gk                  Running
jenkins-x-chartmuseum-67f75c4884-crcsr       Running
jenkins-x-controllerbuild-647dd5f44-zlgt2    Running
jenkins-x-controllerrole-7b8fc6d89b-5pb72    Running
jenkins-x-heapster-66754b8fc5-pdj2s          Running
jenkins-x-nexus-57c8447c4-gdk7l              Running
jx-vault-jx-boot-0                           Running
jx-vault-jx-boot-configurer-7d9d646dd5-2qflf Running
pipeline-cc8cb56db-zcdkl                     Running
pipelinerunner-5474fdd88-qmhxk               Running
plank-5cd9f95df7-4v8hp                       Running
prow-build-6b7dfcb76b-qf2vh                  Running
tekton-pipelines-controller-65fff67458-zfjst Running
tide-9ddfd58f9-98cqh                         Running
vault-operator-798dccf8fc-7cgxg              Running
verifying the git Secrets
verifying git Secret jx-pipeline-git-github-github
verifying username vfarcic at git server github at https://github.com
found 11 organisations in git server https://github.com: TechnologyConversations, cloudbees, docker-captains, docker-flow, jenkins-x, jenkins-x-buildpacks, jenkins-x-quickstarts, jenkinsci, nuxeo, scbcn, serverless-quickstarts
Validated pipeline user vfarcic on git server https://github.com
git tokens seem to be setup correctly
valid: there is a Secret: kaniko-secret in namespace: jx
installation is currently looking: GOOD
switching to the namespace jx so that you can use jx commands on the installation
Using namespace 'jx' from context named 'gke_devops-26_us-east1_jx-boot' on server 'https://35.229.123.189'.
```

```bash
git --no-pager diff origin/master..HEAD
```

```
diff --git a/env/parameters.yaml b/env/parameters.yaml
new file mode 100644
index 0000000..3a3a1ef
--- /dev/null
+++ b/env/parameters.yaml
@@ -0,0 +1,10 @@
+adminUser:
+  password: vault:jx-boot/adminUser:password
+  username: admin
+enableDocker: false
+pipelineUser:
+  email: viktor@farcic.com
+  token: vault:jx-boot/pipelineUser:token
+  username: vfarcic
+prow:
+  hmacToken: vault:jx-boot/prow:hmacToken
diff --git a/jenkins-x.yml b/jenkins-x.yml
index dbf2cd8..171d6bb 100644
--- a/jenkins-x.yml
+++ b/jenkins-x.yml
@@ -1,110 +1,204 @@
 buildPack: none
 pipelineConfig:
   pipelines:
-    release:
+    pullRequest:
       pipeline:
         agent:
           image: gcr.io/jenkinsxio/builder-go:0.1.686
-        environment:
-          - name: DEPLOY_NAMESPACE
-            value: jx
         stages:
-          - name: release
-            steps:
-              - name: validate-git
-                dir: /workspace/source/env
-                command: jx
-                args: ['step','git','validate']
-              - name: verify-preinstall
-                dir: /workspace/source/env
-                command: jx
-                args: ['step','verify','preinstall']
-              - name: install-jx-crds
-                command: jx
-                args: ['upgrade','crd']
-              - name: install-nginx
-                dir: /workspace/source/systems/jxing
-                command: jx
-                args: ['step','helm','apply', '--boot', '--remote', '--no-vault', '--name', 'jxing']
-                env:
-                  - name: DEPLOY_NAMESPACE
-                    value: kube-system
-              - name: create-install-values
-                dir: /workspace/source/env
-                command: jx
-                args: ['step','create','install', 'values', '-b']
-              - name: install-external-dns
-                dir: /workspace/source/systems/external-dns
-                command: jx
-                args: ['step','helm','apply', '--boot', '--remote', '--no-vault', '--name', 'jx']
-              - name: install-cert-manager-crds
-                dir: /workspace/source
-                command: kubectl
-                args: ['apply', '--wait', '--validate=true', '-f', 'https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml']
-                env:
-                  - name: DEPLOY_NAMESPACE
-                    value: cert-manager
-              - name: install-cert-manager
-                dir: /workspace/source/systems/cm
-                command: jx
-                args: ['step','helm','apply', '--boot', '--remote', '--no-vault', '--name', 'jx']
-                env:
-                  - name: DEPLOY_NAMESPACE
-                    value: cert-manager
-              - name: install-acme-issuer-and-certificate
-                dir: /workspace/source/systems/acme
-                command: jx
-                args: ['step','helm','apply', '--boot', '--remote', '--no-vault', '--name', 'jx']
-              - name: install-vault
-                dir: /workspace/source/systems/vault
-                command: jx
-                args: ['step', 'boot','vault']
-              - name: helm-populate-params
-                dir: /workspace/source/env
-                command: jx
-                args: ['step', 'create', 'values', '--name', 'parameters']
-              - name: install-env 
-                dir: /workspace/source/env
-                command: jx
-                args: ['step','helm','apply', '--boot', '--remote', '--name', 'jenkins-x', '--provider-values-dir', '../kubeProviders']
-              - name: verify-env
-                dir: /workspace/source
-                command: jx
-                args: ['step','verify','env']
-              - name: log-repos
-                dir: /workspace/source/repositories
-                command: echo
-                args:
-                  - ""
-                  - ""
-                  - "now populating projects...."
-                  - ""
-                  - ""
-              - name: apply-repositories
-                dir: /workspace/source/repositories
-                command: jx
-                args: ['step','helm','apply', '--boot', '--name', 'repos']
-              - name: apply-pipeline-schedulers
-                dir: /workspace/source/prowConfig
-                command: jx
-                args: ['step','scheduler','config', 'apply', '--direct=true']
-              - name: update-webhooks
-                dir: /workspace/source/repositories
-                command: jx
-                args: ['update','webhooks','--verbose', '--warn-on-fail']
-              - name: verify-install
-                dir: /workspace/source/env
-                command: jx
-                args: ['step','verify','install', '--pod-wait-time', '30m']
-    pullRequest:
+        - name: pr
+          steps:
+          - args:
+            - build
+            command: make
+            dir: /workspace/source/env
+            name: helm-build
+    release:
       pipeline:
         agent:
           image: gcr.io/jenkinsxio/builder-go:0.1.686
+        environment:
+        - name: DEPLOY_NAMESPACE
+          value: jx
+        - name: GIT_AUTHOR_NAME
+          value: vfarcic
+        - name: GIT_AUTHOR_EMAIL
+          value: viktor@farcic.com
         stages:
-          - name: pr
-            steps:
-              - name: helm-build
-                dir: /workspace/source/env
-                command: make
-                args: ['build']
-
+        - name: release
+          steps:
+          - args:
+            - step
+            - git
+            - validate
+            command: jx
+            dir: /workspace/source/env
+            name: validate-git
+          - args:
+            - step
+            - verify
+            - preinstall
+            command: jx
+            dir: /workspace/source/env
+            name: verify-preinstall
+          - args:
+            - upgrade
+            - crd
+            command: jx
+            name: install-jx-crds
+          - args:
+            - step
+            - helm
+            - apply
+            - --boot
+            - --remote
+            - --no-vault
+            - --name
+            - jxing
+            command: jx
+            dir: /workspace/source/systems/jxing
+            env:
+            - name: DEPLOY_NAMESPACE
+              value: kube-system
+            name: install-nginx
+          - args:
+            - step
+            - create
+            - install
+            - values
+            - -b
+            command: jx
+            dir: /workspace/source/env
+            name: create-install-values
+          - args:
+            - step
+            - helm
+            - apply
+            - --boot
+            - --remote
+            - --no-vault
+            - --name
+            - jx
+            command: jx
+            dir: /workspace/source/systems/external-dns
+            name: install-external-dns
+          - args:
+            - apply
+            - --wait
+            - --validate=true
+            - -f
+            - https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
+            command: kubectl
+            dir: /workspace/source
+            env:
+            - name: DEPLOY_NAMESPACE
+              value: cert-manager
+            name: install-cert-manager-crds
+          - args:
+            - step
+            - helm
+            - apply
+            - --boot
+            - --remote
+            - --no-vault
+            - --name
+            - jx
+            command: jx
+            dir: /workspace/source/systems/cm
+            env:
+            - name: DEPLOY_NAMESPACE
+              value: cert-manager
+            name: install-cert-manager
+          - args:
+            - step
+            - helm
+            - apply
+            - --boot
+            - --remote
+            - --no-vault
+            - --name
+            - jx
+            command: jx
+            dir: /workspace/source/systems/acme
+            name: install-acme-issuer-and-certificate
+          - args:
+            - step
+            - boot
+            - vault
+            command: jx
+            dir: /workspace/source/systems/vault
+            name: install-vault
+          - args:
+            - step
+            - create
+            - values
+            - --name
+            - parameters
+            command: jx
+            dir: /workspace/source/env
+            name: helm-populate-params
+          - args:
+            - step
+            - helm
+            - apply
+            - --boot
+            - --remote
+            - --name
+            - jenkins-x
+            - --provider-values-dir
+            - ../kubeProviders
+            command: jx
+            dir: /workspace/source/env
+            name: install-env
+          - args:
+            - step
+            - verify
+            - env
+            command: jx
+            dir: /workspace/source
+            name: verify-env
+          - args:
+            - ""
+            - ""
+            - now populating projects....
+            - ""
+            - ""
+            command: echo
+            dir: /workspace/source/repositories
+            name: log-repos
+          - args:
+            - step
+            - helm
+            - apply
+            - --boot
+            - --name
+            - repos
+            command: jx
+            dir: /workspace/source/repositories
+            name: apply-repositories
+          - args:
+            - step
+            - scheduler
+            - config
+            - apply
+            - --direct=true
+            command: jx
+            dir: /workspace/source/prowConfig
+            name: apply-pipeline-schedulers
+          - args:
+            - update
+            - webhooks
+            - --verbose
+            - --warn-on-fail
+            command: jx
+            dir: /workspace/source/repositories
+            name: update-webhooks
+          - args:
+            - step
+            - verify
+            - install
+            - --pod-wait-time
+            - 30m
+            command: jx
+            dir: /workspace/source/env
+            name: verify-install
diff --git a/jx-requirements.yml b/jx-requirements.yml
index 269d0ad..5681b64 100644
--- a/jx-requirements.yml
+++ b/jx-requirements.yml
@@ -1,34 +1,63 @@
 cluster:
-  clusterName: ""
-  environmentGitOwner: ""
-  project: ""
+  clusterName: jx-boot
+  environmentGitOwner: vfarcic
+  gitKind: github
+  gitName: github
+  gitServer: https://github.com
+  namespace: jx
+  project: devops-26
   provider: gke
-  zone: ""
-gitops: true
+  zone: us-east1
 environments:
-- key: dev
-- key: staging
-- key: production
+- ingress:
+    domain: ""
+    externalDNS: false
+    namespaceSubDomain: ""
+    tls:
+      email: ""
+      enabled: false
+      production: false
+  key: dev
+- ingress:
+    domain: ""
+    externalDNS: false
+    namespaceSubDomain: ""
+    tls:
+      email: ""
+      enabled: false
+      production: false
+  key: staging
+- ingress:
+    domain: ""
+    externalDNS: false
+    namespaceSubDomain: ""
+    tls:
+      email: ""
+      enabled: false
+      production: false
+  key: production
+gitops: true
 ingress:
-  domain: ""
+  domain: 35.229.50.53.nip.io
   externalDNS: false
+  namespaceSubDomain: -jx.
   tls:
     email: ""
     enabled: false
     production: false
 kaniko: true
-secretStorage: local
+secretStorage: vault
 storage:
   logs:
-    enabled: false
-    url: ""
+    enabled: true
+    url: gs://jx-boot-logs-997b82a1-d879-49d1-9b71-b8b71fcf0ee5
   reports:
-    enabled: false
-    url: ""
+    enabled: true
+    url: gs://jx-boot-reports-c9ff9c06-5513-42b8-b1ea-feb0488d99d0
   repository:
-    enabled: false
-    url: ""
+    enabled: true
+    url: gs://jx-boot-repository-32bcf1a7-1479-4ab4-ac89-ff4450e940ad
 versionStream:
-  ref: "master"
+  ref: master
   url: https://github.com/jenkins-x/jenkins-x-versions.git
 webhook: prow
```

```bash
git push

jx get activities --watch
```

```
STEP                                                 STARTED AGO DURATION STATUS
vfarcic/environment-jx-boot-dev/master #1                  15m4s    1m53s Failed
  release                                                  15m4s    1m53s Failed
    Credential Initializer Gjl8q                           15m4s       0s Succeeded
    Working Dir Initializer 6nqj9                          15m4s       1s Succeeded
    Place Tools                                            15m3s       2s Succeeded
    Git Source Vfarcic Environment Jx Boot Dev Dzndj       15m1s    1m42s Succeeded https://github.com/vfarcic/environment-jx-boot-dev.git
    Git Merge                                             13m19s       1s Succeeded
    Validate Git                                          13m18s       1s Succeeded
    Verify Preinstall                                     13m17s       1s Failed
    Install Jx Crds                                       13m16s       0s Succeeded
    Install Nginx                                         13m16s       0s Succeeded
    Create Install Values                                 13m16s       0s Succeeded
    Install External Dns                                  13m16s       1s Succeeded
    Install Cert Manager Crds                             13m15s       0s Succeeded
    Install Cert Manager                                  13m15s       0s Succeeded
    Install Acme Issuer And Certificate                   13m15s       1s Succeeded
    Install Vault                                         13m14s       0s Succeeded
    Helm Populate Params                                  13m14s       0s Succeeded
    Install Env                                           13m14s       1s Succeeded
    Verify Env                                            13m13s       0s Succeeded
    Log Repos                                             13m13s       1s Succeeded
    Apply Repositories                                    13m12s       0s Succeeded
    Apply Pipeline Schedulers                             13m12s       0s Succeeded
    Update Webhooks                                       13m12s       1s Succeeded
    Verify Install                                        13m11s       0s Succeeded
```

```bash
# ctrl+c

# https://github.com/jenkins-x/jx/issues/5279

kubectl get pods
```

```
NAME                                                         READY   STATUS      RESTARTS   AGE
crier-bdf994874-vtxck                                        1/1     Running     0          24m
deck-8b49bcfc6-g9mcl                                         1/1     Running     0          24m
deck-8b49bcfc6-qprn4                                         1/1     Running     0          24m
hook-787c4d8fb8-5q5zz                                        1/1     Running     0          24m
hook-787c4d8fb8-fk8c4                                        1/1     Running     0          24m
horologium-5bdb48d8f9-jd7gk                                  1/1     Running     0          24m
jenkins-x-chartmuseum-67f75c4884-crcsr                       1/1     Running     0          25m
jenkins-x-controllerbuild-647dd5f44-zlgt2                    1/1     Running     0          25m
jenkins-x-controllerrole-7b8fc6d89b-5pb72                    1/1     Running     0          25m
jenkins-x-heapster-66754b8fc5-pdj2s                          2/2     Running     0          22m
jenkins-x-nexus-57c8447c4-gdk7l                              1/1     Running     0          25m
jx-vault-jx-boot-0                                           3/3     Running     0          45m
jx-vault-jx-boot-configurer-7d9d646dd5-2qflf                 1/1     Running     0          45m
pipeline-cc8cb56db-zcdkl                                     1/1     Running     0          24m
pipelinerunner-5474fdd88-qmhxk                               1/1     Running     0          24m
plank-5cd9f95df7-4v8hp                                       1/1     Running     0          24m
prow-build-6b7dfcb76b-qf2vh                                  1/1     Running     0          24m
tekton-pipelines-controller-65fff67458-zfjst                 1/1     Running     0          24m
tide-9ddfd58f9-98cqh                                         1/1     Running     0          24m
vault-operator-798dccf8fc-7cgxg                              1/1     Running     0          46m
vfarcic-environment-jx-boot-dev-1-release-q666j-pod-9e21be   0/20    Completed   0          15m
```

```bash
cat jenkins-x.yml
```

```yaml
buildPack: none
pipelineConfig:
  pipelines:
    pullRequest:
      pipeline:
        agent:
          image: gcr.io/jenkinsxio/builder-go:0.1.686
        stages:
        - name: pr
          steps:
          - args:
            - build
            command: make
            dir: /workspace/source/env
            name: helm-build
    release:
      pipeline:
        agent:
          image: gcr.io/jenkinsxio/builder-go:0.1.686
        environment:
        - name: DEPLOY_NAMESPACE
          value: jx
        - name: GIT_AUTHOR_NAME
          value: vfarcic
        - name: GIT_AUTHOR_EMAIL
          value: viktor@farcic.com
        stages:
        - name: release
          steps:
          - args:
            - step
            - git
            - validate
            command: jx
            dir: /workspace/source/env
            name: validate-git
          - args:
            - step
            - verify
            - preinstall
            command: jx
            dir: /workspace/source/env
            name: verify-preinstall
          - args:
            - upgrade
            - crd
            command: jx
            name: install-jx-crds
          - args:
            - step
            - helm
            - apply
            - --boot
            - --remote
            - --no-vault
            - --name
            - jxing
            command: jx
            dir: /workspace/source/systems/jxing
            env:
            - name: DEPLOY_NAMESPACE
              value: kube-system
            name: install-nginx
          - args:
            - step
            - create
            - install
            - values
            - -b
            command: jx
            dir: /workspace/source/env
            name: create-install-values
          - args:
            - step
            - helm
            - apply
            - --boot
            - --remote
            - --no-vault
            - --name
            - jx
            command: jx
            dir: /workspace/source/systems/external-dns
            name: install-external-dns
          - args:
            - apply
            - --wait
            - --validate=true
            - -f
            - https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
            command: kubectl
            dir: /workspace/source
            env:
            - name: DEPLOY_NAMESPACE
              value: cert-manager
            name: install-cert-manager-crds
          - args:
            - step
            - helm
            - apply
            - --boot
            - --remote
            - --no-vault
            - --name
            - jx
            command: jx
            dir: /workspace/source/systems/cm
            env:
            - name: DEPLOY_NAMESPACE
              value: cert-manager
            name: install-cert-manager
          - args:
            - step
            - helm
            - apply
            - --boot
            - --remote
            - --no-vault
            - --name
            - jx
            command: jx
            dir: /workspace/source/systems/acme
            name: install-acme-issuer-and-certificate
          - args:
            - step
            - boot
            - vault
            command: jx
            dir: /workspace/source/systems/vault
            name: install-vault
          - args:
            - step
            - create
            - values
            - --name
            - parameters
            command: jx
            dir: /workspace/source/env
            name: helm-populate-params
          - args:
            - step
            - helm
            - apply
            - --boot
            - --remote
            - --name
            - jenkins-x
            - --provider-values-dir
            - ../kubeProviders
            command: jx
            dir: /workspace/source/env
            name: install-env
          - args:
            - step
            - verify
            - env
            command: jx
            dir: /workspace/source
            name: verify-env
          - args:
            - ""
            - ""
            - now populating projects....
            - ""
            - ""
            command: echo
            dir: /workspace/source/repositories
            name: log-repos
          - args:
            - step
            - helm
            - apply
            - --boot
            - --name
            - repos
            command: jx
            dir: /workspace/source/repositories
            name: apply-repositories
          - args:
            - step
            - scheduler
            - config
            - apply
            - --direct=true
            command: jx
            dir: /workspace/source/prowConfig
            name: apply-pipeline-schedulers
          - args:
            - update
            - webhooks
            - --verbose
            - --warn-on-fail
            command: jx
            dir: /workspace/source/repositories
            name: update-webhooks
          - args:
            - step
            - verify
            - install
            - --pod-wait-time
            - 30m
            command: jx
            dir: /workspace/source/env
            name: verify-install
```

```bash
kubectl get ns
```

```
NAME           STATUS   AGE
cert-manager   Active   50m
default        Active   109m
jx             Active   57m
kube-public    Active   109m
kube-system    Active   109m
```

```bash
jx get env
```

```bash
cd ..

jx create quickstart \
    --filter golang-http \
    --project-name jx-boot \
    --batch-mode
```

```
error: failed to load quickstarts: failed to load quickstarts: Running in batch mode and no default Git username found
```

```bash
# https://github.com/jenkins-x/jx/issues/5380

jx create quickstart \
    --filter golang-http
```

```
? github username: vfarcic
To be able to create a repository on github we need an API Token
Please click this URL and generate a token
https://github.com/settings/tokens/new?scopes=repo,read:user,read:org,user:email,write:repo_hook,delete_repo

Then COPY the token and enter it below:

? API Token: ****************************************

Using Git provider github at https://github.com
? Do you wish to use vfarcic as the Git user name? Yes
? Which organisation do you want to use? vfarcic
? Enter the new repository name:  jx-boot
Creating repository vfarcic/jx-boot
Generated quickstart at /Users/vfarcic/code/jx-boot
### NO charts folder /Users/vfarcic/code/jx-boot/charts/golang-http
Created project at /Users/vfarcic/code/jx-boot
The directory /Users/vfarcic/code/jx-boot is not yet using git
? Would you like to initialise git now? Yes
? Commit message:  Initial import

Git repository created
performing pack detection in folder /Users/vfarcic/code/jx-boot
--> Draft detected Go (65.746753%)
selected pack: /Users/vfarcic/.jx/draft/packs/github.com/jenkins-x-buildpacks/jenkins-x-kubernetes/packs/go
replacing placeholders in directory /Users/vfarcic/code/jx-boot
app name: jx-boot, git server: github.com, org: vfarcic, Docker registry org: devops-26
skipping directory "/Users/vfarcic/code/jx-boot/.git"
Pushed Git repository to https://github.com/vfarcic/jx-boot
Creating GitHub webhook for vfarcic/jx-boot for url http://hook-jx.35.229.50.53.nip.io/hook
regenerated Prow configuration
WARNING: No author for commit: a44e9e973df6f966ef8dc9f8e78875b5107cfbd9
WARNING: No author for commit: a44e9e973df6f966ef8dc9f8e78875b5107cfbd9

Watch pipeline activity via:    jx get activity -f jx-boot -w
Browse the pipeline log via:    jx get build logs vfarcic/jx-boot/master
You can list the pipelines via: jx get pipelines
When the pipeline is complete:  jx get applications

For more help on available commands see: https://jenkins-x.io/developing/browsing/
```

```bash
jx get activity \
    --filter jx-boot/master \
    --watch
```

```
STEP                                        STARTED AGO DURATION STATUS
vfarcic/jx-boot/master #1                          4m6s    3m58s Succeeded Version: 0.0.1
  from build pack                                  4m6s    3m58s Succeeded
    Credential Initializer Rdf44                   4m6s       0s Succeeded
    Working Dir Initializer M48hd                  4m6s       1s Succeeded
    Place Tools                                    4m5s       2s Succeeded
    Git Source Vfarcic Jx Boot Master Mbct2        4m3s    1m27s Succeeded https://github.com/vfarcic/jx-boot.git
    Git Merge                                     2m36s       0s Succeeded
    Setup Jx Git Credentials                      2m36s       1s Succeeded
    Build Make Build                              2m35s      35s Succeeded
    Build Container Build                          2m0s       4s Succeeded
    Build Post Build                              1m56s       1s Succeeded
    Promote Changelog                             1m55s       5s Succeeded
    Promote Helm Release                          1m50s       8s Succeeded
    Promote Jx Promote                            1m42s    1m34s Succeeded
  Promote: staging                                1m34s    1m26s Succeeded
    PullRequest                                   1m34s    1m26s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-boot-staging/pull/1 Merge SHA: 05080b127abdd1e3b22d79c7e74933e9f6727f78
    Update                                           8s       0s Succeeded
```

```bash
# ctrl+c

jx get activity \
    --filter environment-$CLUSTER_NAME-staging/master \
    --watch
```

```
STEP                                                 STARTED AGO DURATION STATUS
vfarcic/environment-jx-boot-staging/master #1              1m12s     1m3s Succeeded
  from build pack                                          1m12s     1m3s Succeeded
    Credential Initializer W4kk6                           1m12s       0s Succeeded
    Working Dir Initializer Tsnlf                          1m12s       1s Succeeded
    Place Tools                                            1m11s       1s Succeeded
    Git Source Vfarcic Environment Jx Boot Sta Pl4lm       1m10s       7s Succeeded https://github.com/vfarcic/environment-jx-boot-staging.git
    Git Merge                                               1m3s       1s Succeeded
    Setup Jx Git Credentials                                1m2s       1s Succeeded
    Build Helm Apply                                        1m1s      52s Succeeded
```

```bash
# ctrl+c

kubectl get namespaces
```

```
NAME           STATUS   AGE
cert-manager   Active   94m
default        Active   152m
jx             Active   100m
jx-staging     Active   91s
kube-public    Active   152m
kube-system    Active   152m
```

```bash
jx get applications --env staging
```

```
APPLICATION STAGING PODS URL
jx-boot     0.0.1   1/1  http://jx-boot.jx-staging.35.229.50.53.nip.io
```

```bash
STAGING_ADDR=[...]

curl $STAGING_ADDR

cd environment-$CLUSTER_NAME-dev

cat env/parameters.yaml
```

```yaml
adminUser:
  password: vault:jx-boot/adminUser:password
  username: admin
enableDocker: false
pipelineUser:
  email: viktor@farcic.com
  token: vault:jx-boot/pipelineUser:token
  username: vfarcic
prow:
  hmacToken: vault:jx-boot/prow:hmacToken
```

```bash
# It should do nothing

kubectl get pods | grep docker

# It's empty

cat env/parameters.yaml \
    | sed -e \
    "s@enableDocker: false@enableDocker: true@g" \
    | tee env/parameters.yaml
```

```yaml
adminUser:
  password: vault:jx-boot/adminUser:password
  username: admin
enableDocker: true
pipelineUser:
  email: viktor@farcic.com
  token: vault:jx-boot/pipelineUser:token
  username: vfarcic
prow:
  hmacToken: vault:jx-boot/prow:hmacToken
```

```bash
git status

git add .

git commit -m "Initial setup"

git push

jx get activities \
    --filter environment-$CLUSTER_NAME-dev \
    --watch

# TODO: Continue when https://github.com/jenkins-x/jx/issues/5381 is fixed


kubectl get pods | grep docker

cd ../jx-boot

echo "Testing Docker Hub" \
    | tee README.md

git add .

git commit -m "A silly change"

git push --set-upstream origin master

jx get activity \
    --filter jx-boot/master \
    --watch

# ctrl+c

jx get activity \
    --filter environment-$CLUSTER_NAME-staging/master \
    --watch

# ctrl+c

# TODO: `ingress` section in `jx-requirements.yml`

# TODO: Change to external Docker registry

# TODO: Explore the files

# TODO: Destroy the cluster, create a new one, and re-run `jx boot`

# TODO: Explore storage

# TODO: Extend the pipeline

# TODO: jx profile cloudbees

# TODO: jx profile oss

# TODO: Add gloo, istio, flagger

# TODO: CB distribution

# TODO: Backup buckets

# TODO: Destroy the cluster and create a new using the same `jx-boot` repository
```

## What Now?

```bash
cd ..

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-dev

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-staging

hub delete -y \
    $GH_USER/environment-$CLUSTER_NAME-production

hub delete -y \
    $GH_USER/jx-boot

rm -rf environment-$CLUSTER_NAME-dev

rm -rf jx-boot

# Delete storage
```