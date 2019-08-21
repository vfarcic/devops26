# Codified Infrastructure

Guest chapter by Patrick Lee Scott – https://patscott.io

* Enable GitOps with Kubernetes

Throughout the book we've been using `jx create cluster` to set up a Kubernetes cluster on the cloud providers of our choosing.

Although simple to create clusters in the manner, we lose a bit of the benefits of codified configurations, which allow for the ability to implement GitOps principals on our infrastructure.

In this chapter I want to share with you another way of accomplishing this using JX, Terraform or EKSCTL, and JX Boot.

`jx boot` is becoming the preferred way to initialize a JX installation and that calls for creating the cluster with Terraform or EKSCTL, etc, ahead of time.

I'll show you two ways to set up some codified infrastructure and then in the next section, show how to initialize them using `jx boot`.

We will also use this opportunity to try out the Jenkins X CloudBees Distribution which you can find here: https://www.cloudbees.com/products/cloudbees-jenkins-x-distribution

## Create a GKE Cluster with Terraform

Let’s set up a Kubernetes cluster using `jx create terraform`.

We won't want to actually install JX using this command, although it is currently possible. There is an escape hatch in the command via the flag `--skip-terraform-apply` which will just go through the tedious process of configuring GCP with service accounts and the correct permissions to manage storage, container registries, and anything else JX may need.

I'll also specify my organization's name in the command which will be used in the generated git repository which contains our new terraform configs.


```
➜  ~ jxc create terraform --organisation-name='patrickleet' --skip-terraform-apply=true
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?redirect_uri=http%3A%2F%2Flocalhost%3A8085%2F&prompt=select_account&response_type=code&client_id=32555940559.apps.googleusercontent.com&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fappengine.admin+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcompute+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth&access_type=offline


Checking Terraform Version...
Determined terraform version as 0.12.6
Terraform version appears to be valid
Git configured for user: Patrick Scott and email pat@patscott.io
? How many clusters shall we create? 1
? Cluster 1 name: dev
? Cluster 1 provider: gke
? Would you like to install Jenkins X in cluster dev No
WARNING: WARNING: The current user cannot query secrets in the namespace default: Failed to get the development environment Get https://localhost:6443/api/v1/namespaces/default: dial tcp [::1]:6443: connect: connection refused
WARNING: failed to find development namespace - Get https://localhost:6443/api/v1/namespaces/default: dial tcp [::1]:6443: connect: connection refused
Using Git provider GitHub at https://github.com
? Do you wish to use group1001-ci as the Git user name? No
? Git user name? patrickleet-deploy
? GitHub username: patrickleet-deploy
To be able to create a repository on GitHub we need an API Token
Please click this URL and generate a token 
https://github.com/settings/tokens/new?scopes=repo,read:user,read:org,user:email,write:repo_hook,delete_repo

Then COPY the token and enter it below:

? API Token: ****************************************
? Which organisation do you want to use? patrickleet-org
? Enter the new repository name:  organisation-patrickleet
Creating repository patrickleet-org/organisation-patrickleet
Creating Git repository patrickleet-org/organisation-patrickleet
Creating config for cluster dev
? Google Cloud Project: patrickleet-dev
? Google Cloud Zone: us-central1-a
? Google Cloud Machine Type: n1-standard-2
? Would you like use preemptible VMs? Yes
? Would you like to access Google Cloud Storage / Google Container Registry? Yes
? Would you like to enable Cloud Build, Container Registry & Container Analysis APIs? Yes
? Minimum number of Nodes 3
? Maximum number of Nodes 5
Created /Users/patrick.scottgroup1001.com/.jx/organisations/organisation-patrickleet/clusters/dev/terraform/terraform.tf
Pushed Git repository /Users/patrick.scottgroup1001.com/.jx/organisations/organisation-patrickleet
Creating Clusters...
Creating/Updating 1 clusters
Creating/Updating cluster dev
Applying Terraform changes
No GCP service account provided, creating patrickleet-dev-tf
Unable to find service account patrickleet-dev-tf, checking if we have enough permission to create
Creating service account patrickleet-dev-tf
Assigning role roles/owner
Downloading service account key
Created GCP service account: /Users/patrick.scottgroup1001.com/.jx/organisations/organisation-patrickleet/clusters/dev/patrickleet-dev-tf.key.json
Created GCS bucket: patrickleet-dev-patrickleet-terraform-state in region us-central1
Initialising Terraform
Showing Terraform Plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_container_cluster.jx-cluster will be created
  + resource "google_container_cluster" "jx-cluster" {
      + additional_zones            = (known after apply)
      + cluster_autoscaling         = (known after apply)
      + cluster_ipv4_cidr           = (known after apply)
      + description                 = "jx k8s cluster"
      + enable_binary_authorization = (known after apply)
      + enable_kubernetes_alpha     = false
      + enable_legacy_abac          = false
      + enable_tpu                  = (known after apply)
      + endpoint                    = (known after apply)
      + id                          = (known after apply)
      + initial_node_count          = 3
      + instance_group_urls         = (known after apply)
      + ip_allocation_policy        = (known after apply)
      + location                    = (known after apply)
      + logging_service             = "logging.googleapis.com"
      + master_version              = (known after apply)
      + monitoring_service          = "monitoring.googleapis.com"
      + name                        = "patrickleet-dev"
      + network                     = "default"
      + node_locations              = (known after apply)
      + node_version                = (known after apply)
      + project                     = (known after apply)
      + region                      = (known after apply)
      + remove_default_node_pool    = true
      + resource_labels             = {
          + "create-time"  = "20190821142351"
          + "created-by"   = "patrick-scottgroup1001-com"
          + "created-with" = "terraform"
        }
      + services_ipv4_cidr          = (known after apply)
      + subnetwork                  = (known after apply)
      + zone                        = "us-central1-a"

      + addons_config {
          + horizontal_pod_autoscaling {
              + disabled = (known after apply)
            }

          + http_load_balancing {
              + disabled = (known after apply)
            }

          + kubernetes_dashboard {
              + disabled = (known after apply)
            }

          + network_policy_config {
              + disabled = (known after apply)
            }
        }

      + master_auth {
          + client_certificate     = (known after apply)
          + client_key             = (sensitive value)
          + cluster_ca_certificate = (known after apply)
          + password               = (sensitive value)
          + username               = (known after apply)

          + client_certificate_config {
              + issue_client_certificate = (known after apply)
            }
        }

      + network_policy {
          + enabled  = (known after apply)
          + provider = (known after apply)
        }

      + node_config {
          + disk_size_gb      = (known after apply)
          + disk_type         = (known after apply)
          + guest_accelerator = (known after apply)
          + image_type        = (known after apply)
          + labels            = (known after apply)
          + local_ssd_count   = (known after apply)
          + machine_type      = (known after apply)
          + metadata          = (known after apply)
          + min_cpu_platform  = (known after apply)
          + oauth_scopes      = (known after apply)
          + preemptible       = (known after apply)
          + service_account   = (known after apply)
          + tags              = (known after apply)

          + sandbox_config {
              + sandbox_type = (known after apply)
            }

          + taint {
              + effect = (known after apply)
              + key    = (known after apply)
              + value  = (known after apply)
            }

          + workload_metadata_config {
              + node_metadata = (known after apply)
            }
        }

      + node_pool {
          + initial_node_count  = (known after apply)
          + instance_group_urls = (known after apply)
          + max_pods_per_node   = (known after apply)
          + name                = (known after apply)
          + name_prefix         = (known after apply)
          + node_count          = (known after apply)
          + version             = (known after apply)

          + autoscaling {
              + max_node_count = (known after apply)
              + min_node_count = (known after apply)
            }

          + management {
              + auto_repair  = (known after apply)
              + auto_upgrade = (known after apply)
            }

          + node_config {
              + disk_size_gb      = (known after apply)
              + disk_type         = (known after apply)
              + guest_accelerator = (known after apply)
              + image_type        = (known after apply)
              + labels            = (known after apply)
              + local_ssd_count   = (known after apply)
              + machine_type      = (known after apply)
              + metadata          = (known after apply)
              + min_cpu_platform  = (known after apply)
              + oauth_scopes      = (known after apply)
              + preemptible       = (known after apply)
              + service_account   = (known after apply)
              + tags              = (known after apply)

              + sandbox_config {
                  + sandbox_type = (known after apply)
                }

              + taint {
                  + effect = (known after apply)
                  + key    = (known after apply)
                  + value  = (known after apply)
                }

              + workload_metadata_config {
                  + node_metadata = (known after apply)
                }
            }
        }
    }

  # google_container_node_pool.jx-node-pool will be created
  + resource "google_container_node_pool" "jx-node-pool" {
      + cluster             = "patrickleet-dev"
      + id                  = (known after apply)
      + initial_node_count  = (known after apply)
      + instance_group_urls = (known after apply)
      + location            = (known after apply)
      + max_pods_per_node   = (known after apply)
      + name                = "default-pool"
      + name_prefix         = (known after apply)
      + node_count          = 3
      + project             = (known after apply)
      + region              = (known after apply)
      + version             = (known after apply)
      + zone                = "us-central1-a"

      + autoscaling {
          + max_node_count = 5
          + min_node_count = 3
        }

      + management {
          + auto_repair  = true
          + auto_upgrade = false
        }

      + node_config {
          + disk_size_gb      = 100
          + disk_type         = (known after apply)
          + guest_accelerator = (known after apply)
          + image_type        = (known after apply)
          + labels            = (known after apply)
          + local_ssd_count   = (known after apply)
          + machine_type      = "n1-standard-2"
          + metadata          = (known after apply)
          + oauth_scopes      = [
              + "https://www.googleapis.com/auth/cloud-platform",
              + "https://www.googleapis.com/auth/compute",
              + "https://www.googleapis.com/auth/devstorage.full_control",
              + "https://www.googleapis.com/auth/logging.write",
              + "https://www.googleapis.com/auth/monitoring",
              + "https://www.googleapis.com/auth/service.management",
              + "https://www.googleapis.com/auth/servicecontrol",
            ]
          + preemptible       = true
          + service_account   = (known after apply)
        }
    }

  # google_project_service.cloudbuild-api will be created
  + resource "google_project_service" "cloudbuild-api" {
      + disable_on_destroy = false
      + id                 = (known after apply)
      + project            = "patrickleet-dev"
      + service            = "cloudbuild.googleapis.com"
    }

  # google_project_service.cloudkms-api will be created
  + resource "google_project_service" "cloudkms-api" {
      + disable_on_destroy = false
      + id                 = (known after apply)
      + project            = "patrickleet-dev"
      + service            = "cloudkms.googleapis.com"
    }

  # google_project_service.cloudresourcemanager-api will be created
  + resource "google_project_service" "cloudresourcemanager-api" {
      + disable_on_destroy = false
      + id                 = (known after apply)
      + project            = "patrickleet-dev"
      + service            = "cloudresourcemanager.googleapis.com"
    }

  # google_project_service.compute-api will be created
  + resource "google_project_service" "compute-api" {
      + disable_on_destroy = false
      + id                 = (known after apply)
      + project            = "patrickleet-dev"
      + service            = "compute.googleapis.com"
    }

  # google_project_service.containeranalysis-api will be created
  + resource "google_project_service" "containeranalysis-api" {
      + disable_on_destroy = false
      + id                 = (known after apply)
      + project            = "patrickleet-dev"
      + service            = "containeranalysis.googleapis.com"
    }

  # google_project_service.containerregistry-api will be created
  + resource "google_project_service" "containerregistry-api" {
      + disable_on_destroy = false
      + id                 = (known after apply)
      + project            = "patrickleet-dev"
      + service            = "containerregistry.googleapis.com"
    }

  # google_project_service.iam-api will be created
  + resource "google_project_service" "iam-api" {
      + disable_on_destroy = false
      + id                 = (known after apply)
      + project            = "patrickleet-dev"
      + service            = "iam.googleapis.com"
    }

  # google_storage_bucket.lts-bucket will be created
  + resource "google_storage_bucket" "lts-bucket" {
      + bucket_policy_only = (known after apply)
      + force_destroy      = false
      + id                 = (known after apply)
      + location           = "EU"
      + name               = "patrickleet-dev-lts"
      + project            = (known after apply)
      + self_link          = (known after apply)
      + storage_class      = "STANDARD"
      + url                = (known after apply)
    }

Plan: 10 to add, 0 to change, 0 to destroy.

Warning: "zone": [DEPRECATED] use location instead

  on .jx/organisations/organisation-patrickleet/clusters/dev/terraform/main.tf line 52, in resource "google_container_node_pool" "jx-node-pool":
  52: resource "google_container_node_pool" "jx-node-pool" {



Warning: "zone": [DEPRECATED] Use location instead

  on .jx/organisations/organisation-patrickleet/clusters/dev/terraform/main.tf line 86, in resource "google_container_cluster" "jx-cluster":
  86: resource "google_container_cluster" "jx-cluster" {



------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
? Would you like to apply this plan? Yes
Skipping Terraform apply
Skipping jx install
```












```
jx create terraform --no-default-environments=true
```

1. This opens our browser and prompts us to log in and authorize our google cloud account

![Figure 17-1: Google SSO Auth Screen](images/ch17/account-2.png)

1. Back in the terminal we are prompted:
```
? How many clusters shall we create? (1)
```

The default suggestion is 1. 

In more advanced scenarios it may be beneficial to run more than one cluster. For example, you may decide to have a dev cluster, a staging cluster, and a production cluster so workloads or compromises could not affect one another.

With those considerations in mind, let’s chose 1 for now, knowing we can always add more later.

1. At this point, JX will suggests a series of other values we can just use the default values on, and Yes when it asks us to install JX as well.
```
? Cluster 1 name: dev
? Cluster 1 provider: gke
? Would you like to install Jenkins X in cluster dev (Y/n) Y
```

4. If your global Git user and email is configured, JX will ask if you’d like to use it. Otherwise it will collect it from you:
```
? Do you wish to use patrickleet as the Git user name? Yes
? Which organisation do you want to use? patrickleet
```

5. Next, JX prompts for the repository name. This is where your Terraform config will be stored.
```   
Enter the new repository name:  (organisation-gemebony)
```

I suggest following the suggested naming convention of prefixing with `organization` or `org`. This is a repository that keeps track of the different clusters that make up an organization.

By using the default values, that’s one cluster called `dev`.

I’ll name mine `organization-terraform-jx`

6. Next, you’ll need to select the Google Cloud settings

Here are the settings I used:
```
? Google Cloud Zone: us-east1-b
? Google Cloud Machine Type: n1-standard-2
? Minimum number of Nodes 3
? Maximum number of Nodes 5
```

7. Finally, at this point, JX will create a terraform configuration using a template it maintains. It will then ask you if you want to apply this template.

```
? Would you like to apply this plan? (y/N)
```

If you’ve used Terraform before you’ll recognize the terraform output.

Apply the plan.

For me it took 5m20s to create the cluster, and then, another few minutes to create the NodePool.

The NodePool is the group of Worker Nodes that can be autoscaled within the bounds we defined earlier.

As discussed earlier, Autoscaling comes out of the box in GKE, so we are all set there.

Eventually we will get the message 
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

After the terraform plan is applied, JX immediately begins installing Jenkins X on our cluster because we gave it permission earlier.

We will be prompted with all the normal JX install prompts such as configuring ingress and setting the GitHub user for pipelines. You know what to do here so we won't get into it again.

### Your terraform repository

When you created your cluster using the `jx create terraform` command, you also provided GitHub credentials to do so.

JX created a repository and pushed it up to GitHub for you.

You can find this repo in your machine in the `~/.jx/organisations/organizsation-yourcluster` folder.

Within that folder are a couple of more files and subdirectories.

```
➜  cd ~/.jx/organisations/organisation-terraform-jx
➜  organisation-terraform-jx git:(master) ✗ ls
README.md build.sh  clusters
```

I used the default `dev` cluster name so my terraform config is in `clusters/dev/terraform`

```
➜  organisation-terraform-jx git:(master) ✗ cd clusters/dev/terraform
➜  terraform git:(master) ✗ ls
README.md        output.tf        terraform.tfvars
main.tf          terraform.tf     variables.tf
```

It contains 6 files, one is a README. 

The others:

1. main.tf - As suggested by it's name, this is the bulk of the configuration.

In main, the actual "cluster" is declared, as well as the "node_pool".

The cluster is the GKE cluster.

The node pool is where all of the worker nodes run in an autoscaling group.

There is also a bit of boilerplate to use terraform with google.

Let's take a look at the `resource` declarations for the node pool and the cluster.

```
resource "google_container_cluster" "jx-cluster" {
  name                     = "${var.cluster_name}"
  description              = "jx k8s cluster"
  zone                     = "${var.gcp_zone}"
  enable_kubernetes_alpha  = "${var.enable_kubernetes_alpha}"
  enable_legacy_abac       = "${var.enable_legacy_abac}"
  initial_node_count       = "${var.min_node_count}"
  remove_default_node_pool = "true"
  logging_service          = "${var.logging_service}"
  monitoring_service       = "${var.monitoring_service}"

  resource_labels {
	created-by = "${var.created_by}"
	created-timestamp = "${var.created_timestamp}"
	created-with = "terraform"
  }

  lifecycle {
    ignore_changes = ["node_pool"]
  }
}
```

And the node pool, which again, contains our cluster's worker nodes.

```
resource "google_container_node_pool" "jx-node-pool" {
  name       = "default-pool"
  zone       = "${var.gcp_zone}"
  cluster    = "${google_container_cluster.jx-cluster.name}"
  node_count = "${var.min_node_count}"

  node_config {
    preemptible  = "${var.node_preemptible}"
    machine_type = "${var.node_machine_type}"
    disk_size_gb = "${var.node_disk_size}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }

  autoscaling {
	min_node_count = "${var.min_node_count}"
	max_node_count = "${var.max_node_count}"
  }

  management {
    auto_repair  = "${var.auto_repair}"
    auto_upgrade = "${var.auto_upgrade}"
  }

}
```

There are more available options for each available in the terraform docs for google cloud resources.

Throughout the two `resources` above, there are references to `"${var.*}"` variables all over the place.

The values for these variables are coming from the file `terraform.tfvars`.

Before variables can be used, they also must be first defined in `variables.tf`.

`terraform.tf` simply configures `gcs` as the backend - this is Google Cloud.

And finally, `output.tf` declares variables that will be calculated and output, that can then be referenced programatically, and are also output for easy human consumption after changes are applied.

I hope you've noticed that Terraform is declaritive, kinda like HTML and CSS, and Kubernetes.

You describe the infrastructure you want, and then terraform makes it so.

Let's try making some changes.

### Initializing our Terraform client

When we created the terraform cluster, it was using `1.9.x` at the time of this writing.

It's a good idea to run the latest stable version, so let's start with an upgrade. We can only upgrade one minor version at a time without getting an error.

This means we will need to apply a few updates in order to get to the latest version.

Terraform generally works in two steps:
1. Create a plan with `terraform plan`
2. Apply the plan with `terraform apply`

You should be able to see the current `plan` by running `terraform plan` that terraform creates before changing anything.

It should say there are no changes, because we haven't actually changed anything yet, but, if you try it, you'll find instead you get an error.

```
➜  terraform git:(master) terraform plan
Backend reinitialization required. Please run "terraform init".
Reason: Initial configuration of the requested backend "gcs"

The "backend" is the interface that Terraform uses to store state,
perform operations, etc. If this message is showing up, it means that the
Terraform configuration you're using is using a custom configuration for
the Terraform backend.

Changes to backend configurations require reinitialization. This allows
Terraform to setup the new configuration, copy existing state, etc. This is
only done during "terraform init". Please run that command now then try again.

If the change reason above is incorrect, please verify your configuration
hasn't changed and try again. At this point, no changes to your existing
configuration or state have been made.

Failed to load backend: Initialization required. Please see the error message above.
```

It tells us `Backend reinitialization required. Please run "terraform init".`.

Ok. Let's comply with the instructions given to us and run `terraform init`.

```
➜  terraform git:(master) terraform init

Initializing the backend...

Error configuring the backend "gcs": storage.NewClient() failed: dialing: google: could not find default credentials. See https://developers.google.com/accounts/docs/application-default-credentials for more information.

Please update the configuration in your Terraform files to fix this error
then run this command again.
```

No dice.

This is because we need to use the security key!

If you haven't modified anything since creating your cluster, then the key should be located up one directory level and named after your organization and .gitignored so it doesn't get checked into source control.

Google Cloud's SDK expects the location of the file to be set as an environment variable for it to work.

Run the following command to do so:

```
export GOOGLE_APPLICATION_CREDENTIALS=../jx-terraform-jx-dev.key.json
```

Now we should be able to successfully perform the init command.

```
➜  terraform git:(master) terraform init

Initializing the backend...

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "google" (1.19.1)...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Success!

### Upgrading the master version

With terraform initialized, we should be able to upgrade the cluster now.

To do so we need to make a change to `main.tf`.

While we are at it, let's make our cluster more resilient to failure by using additional availability zones.

The change to do this is actually quite simple.

Inside of the file `main.tf` add the following option to the `jx-cluster` config.

```
min_master_version       = "1.10"
```

Here is the full resource definition for clarity:

```
resource "google_container_cluster" "jx-cluster" {
  name                     = "${var.cluster_name}"
  description              = "jx k8s cluster"
  zone                     = "${var.gcp_zone}"
  enable_kubernetes_alpha  = "${var.enable_kubernetes_alpha}"
  enable_legacy_abac       = "${var.enable_legacy_abac}"
  initial_node_count       = "${var.min_node_count}"
  remove_default_node_pool = "true"
  logging_service          = "${var.logging_service}"
  monitoring_service       = "${var.monitoring_service}"
  min_master_version       = "1.10"

  resource_labels {
	created-by = "${var.created_by}"
	created-timestamp = "${var.created_timestamp}"
	created-with = "terraform"
  }

  lifecycle {
    ignore_changes = ["node_pool"]
  }
}
```

We should refactor this into a variable, but let's just start with trying this change, and we will refactor later on.

First we need to create a plan.

```
terraform plan -var credentials=$GOOGLE_APPLICATION_CREDENTIALS -out upgrade-1.10.plan
```

A plan file will be created as a result as `upgrade-1.10.plan` which we specified with the -out flag.

Here is the output from my console:

```
➜  terraform git:(master) ✗ terraform plan -var credentials=$GOOGLE_APPLICATION_CREDENTIALS -out upgrade-1.10.plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

google_container_cluster.jx-cluster: Refreshing state... (ID: lynxmeadow-dev)
google_container_node_pool.jx-node-pool: Refreshing state... (ID: us-east1-b/lynxmeadow-dev/default-pool)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  ~ google_container_cluster.jx-cluster
      min_master_version: "" => "1.10"


Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

This plan was saved to: upgrade-1.10.plan

To perform exactly these actions, run the following command to apply:
    terraform apply "upgrade-1.10.plan"

```

A couple things to point out:
1. The method of updating is "update in-place". This means that the resource will be updated in place as it says, rather than destroyed and recreated.
2. The plan summary is shown below the detailed changes: `Plan: 0 to add, 1 to change, 0 to destroy.`

Let's try applying it.

```
➜  terraform git:(master) ✗ terraform apply upgrade-1.10.plan
google_container_cluster.jx-cluster: Modifying... (ID: lynxmeadow-dev)
  min_master_version: "" => "1.10"
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 10s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 20s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 30s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 40s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 50s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 1m0s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 1m10s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 1m20s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 1m30s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 1m40s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 1m50s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 2m0s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 2m10s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 2m20s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 2m30s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 2m40s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 2m50s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 3m0s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 3m10s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 3m20s elapsed)
google_container_cluster.jx-cluster: Still modifying... (ID: lynxmeadow-dev, 3m30s elapsed)
google_container_cluster.jx-cluster: Modifications complete after 3m38s (ID: lynxmeadow-dev)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

cluster_endpoint = 35.190.175.169
cluster_master_version = 1.10.9-gke.5
```

Great! The output shows our new master version is 1.10.

Let's run `kubectl get nodes` to check!

```
➜  terraform git:(master) ✗ k get nodes
NAME                                            STATUS   ROLES    AGE   VERSION
gke-lynxmeadow-dev-default-pool-1d82f151-5dpw   Ready    <none>   8d    v1.9.7-gke.11
gke-lynxmeadow-dev-default-pool-1d82f151-bh48   Ready    <none>   8d    v1.9.7-gke.11
gke-lynxmeadow-dev-default-pool-1d82f151-ngdj   Ready    <none>   8d    v1.9.7-gke.11
```

Uh oh! What happened to 1.10! All of the worker nodes are still reporting version 1.9.

The MASTER nodes have been upgraded, but the WORKER nodes have not.

This is actually according to plan. There are multiple ways to proceed with upgrading our worker nodes:

1. Creating additional "node_pool" resources in our terraform config - you can apply, drain the current nodes in the first node pool, and then remove the original node pool.
2. Setting autoupgrade to true

Let's go with Google's autoupgrade feature for now.

### Upgrading worker nodes

In `main.tf` in the resource `google_container_node_pool` named `jx-node-pool` - there is a section called `management` with a couple of options we can configure.

```
resource "google_container_node_pool" "jx-node-pool" {
  # ...

  management {
    auto_repair  = "${var.auto_repair}"
    auto_upgrade = "${var.auto_upgrade}"
  }

}
```

As you can see, each of the management settings are passed in as a variable.

`auto_upgrade` is the one we want. 

This setting will allow our worker nodes in this node pool to automatically upgrade to the version of the master nodes. 

It will do this process one node at a time as to not distrupt highly avaiable services.

Head on over to `terraform.tfvars` and change the value of `auto_upgrade` to `true`.

We can then create and apply a new plan as we did before.

```
terraform plan -var credentials=$GOOGLE_APPLICATION_CREDENTIALS -out autoupgrade.plan

terraform apply "autoupgrade.plan"
```

Let's check out the output:

```
➜  terraform git:(master) ✗ terraform apply "autoupgrade.plan"
Acquiring state lock. This may take a few moments...
google_container_node_pool.jx-node-pool: Modifying... (ID: us-east1-b/lynxmeadow-dev/default-pool)
  management.0.auto_upgrade: "false" => "true"
google_container_node_pool.jx-node-pool: Modifications complete after 2s (ID: us-east1-b/lynxmeadow-dev/default-pool)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

cluster_endpoint = 35.190.175.169
cluster_master_version = 1.10.9-gke.5
```

Now when we run `kubectl get nodes` we should be able to see the upgrade starting, with one of the node's status switched to `SchedulingDisabled` which prevents further containers from being scheduled to run on that node. 

It also begins the process of draining that node's containers and rescheduling them elsewhere.

```
➜  k get nodes
NAME                                            STATUS                     ROLES    AGE   VERSION
gke-lynxmeadow-dev-default-pool-1d82f151-5dpw   Ready,SchedulingDisabled   <none>   8d    v1.9.7-gke.11
gke-lynxmeadow-dev-default-pool-1d82f151-bh48   Ready                      <none>   8d    v1.9.7-gke.11
gke-lynxmeadow-dev-default-pool-1d82f151-ngdj   Ready                      <none>   8d    v1.9.7-gke.11
```

Eventually, that node will be brought down completely. 

```
➜  k get nodes
NAME                                            STATUS   ROLES    AGE   VERSION
gke-lynxmeadow-dev-default-pool-1d82f151-bh48   Ready    <none>   8d    v1.9.7-gke.11
gke-lynxmeadow-dev-default-pool-1d82f151-ngdj   Ready    <none>   8d    v1.9.7-gke.11
```

And brought up again with the new version, while the process begins on the next node.

```
➜  terraform git:(master) ✗ k get nodes
NAME                                            STATUS                     ROLES    AGE   VERSION
gke-lynxmeadow-dev-default-pool-1d82f151-5dpw   Ready                      <none>   33s   v1.10.9-gke.5
gke-lynxmeadow-dev-default-pool-1d82f151-bh48   Ready,SchedulingDisabled   <none>   8d    v1.9.7-gke.11
gke-lynxmeadow-dev-default-pool-1d82f151-ngdj   Ready                      <none>   8d    v1.9.7-gke.11
```

Eventually, all of the worker nodes will be replaced with new nodes running the newer version.

When you are ready to upgrade your cluster another version, repeat the process.

Let's refactor that version number variable to make it easier, and more maintainable.

### Refactoring master version to a variable

It wasn't great to hardcode the value into the configuration as we did, so let's refactor that.

First we need to create the variable in `variables.tf`

Add the following to the end of the file.

```
variable "min_master_version" {
  description = "(Optional) The minimum version of the master. GKE will auto-update the master to new versions, so this does not guarantee the current master version--use the read-only master_version field to obtain that. If unset, the cluster's version will be set by GKE to the version of the most recent official release (which is not necessarily the latest version)."
}
```

We don't need a default as it is optional, and GKE itself will set a default when one is not provided.

Next, in `terraform.tfvars` add:

```
min_master_version = "1.11"
```

To the end of the file. We've set the min master version higher to `1.11`.

Lastly, we need to switch out the hardcoded config for the variable in `main.tf`

```
min_master_version       = "${var.min_master_version}"
```

With our version refactored into a variable, and, the variable set to a newer version `1.11`, we need to create another plan and apply it.

```
terraform plan -var credentials=$GOOGLE_APPLICATION_CREDENTIALS -out change-to-var.plan
```

You should see 
```
  ~ google_container_cluster.jx-cluster
      min_master_version: "1.10" => "1.11"
```
in the output.

And finally, let's apply the plan:

```
terraform apply "change-to-var.plan"
```

It will take around 20 minutes for everything to be upgraded including your worker nodes which will autoupgrade once the master does as well.

Here is the eventual output:

```
➜  k get nodes
NAME                                            STATUS   ROLES    AGE   VERSION
gke-lynxmeadow-dev-default-pool-1d82f151-5dpw   Ready    <none>   1h    v1.11.2-gke.18
gke-lynxmeadow-dev-default-pool-1d82f151-bh48   Ready    <none>   1h    v1.11.2-gke.18
gke-lynxmeadow-dev-default-pool-1d82f151-ngdj   Ready    <none>   1h    v1.11.2-gke.18
```
