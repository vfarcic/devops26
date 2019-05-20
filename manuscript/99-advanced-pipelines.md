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

# Extending Jenkins X Pipelines

W> The examples in this chapter work only with serverless Jenkins X.

So far we relied mostly on pipelines created for us through build packs. No matter how much effort the community puts into creating build packs, it is almost certain that they will not fulfil all our needs. Every organization has something "special" and that inevitably leads to discrepancies between generic and tailor-made pipelines. So far, we did extend our pipelines but we did not yet explore the benefits additional instructions might provide. The time has come to extend them beyond out-of-the-box steps.

You can think of the subject of this chapter as advanced pipelines, but that would be an overstatement. No matter whether you're using static of serverless pipelines, they are always simple. Or, to be more precise, they should be simple since their goal is not to define complex logic but rather to orchestrate automation defined somewhere else (e.g., scripts). That does not mean that there are no complex pipelines, but rather that those cases often reflect missunderstanding and the desire to solve problems in wrong places.

I> Pipelines are orchestrators of automation and should not contain complex logic.

As always, we need a cluster with Jenkins X so that we can experiment with some new concepts and hopefuly improve our Jenkins X knowledge.

## Creating A Kubernetes Cluster With Jenkins X

TODO: Rewrite

You can skip this section if you kept the cluster from the previous chapter and it contains serverless Jenkins X. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [13-pipeline-extension-model.sh](https://gist.github.com/60556b4844afb120581f7dfeb9280bda) Gist.

For your convenience, the Gists that will create a new serverless Jenkins X cluster or install it inside an existing one are as follows.

* Create new static **GKE** cluster: [gke-jx.sh](https://gist.github.com/86e10c8771582c4b6a5249e9c513cd18)
* Create new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/a04269d359685bbd00a27643b5474ace)
* Create new static **EKS** cluster: [eks-jx.sh](https://gist.github.com/dfaf2b91819c0618faf030e6ac536eac)
* Create new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/69a4cbc65d8cb122d890add5997c463b)
* Create new static **AKS** cluster: [aks-jx.sh](https://gist.github.com/6e01717c398a5d034ebe05b195514060)
* Create new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/a7cb7a28b7e84590fbb560b16a0ee98c)
* Use an **existing** static cluster: [install.sh](https://gist.github.com/3dd5592dc5d582ceeb68fb3c1cc59233)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/f592c72486feb0fb1301778de08ba31d)

TODO: Check whether the branch is correct

I> The commands that follow will reset your *go-demo-6* `master` with the contents of the `extension-model` branch that contains all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

```bash
cd go-demo-6

git pull

git checkout extension-model

git merge -s ours master --no-edit

git checkout master

git merge extension-model

git push

cd ..
```

Now we can explore Jenkins X Pipeline Extension Model.

## What Are We Trying To Do?

It would be silly to explore in more depth Jenkins X pipeline syntax using random and irrelevant examples. Instead, we'll define some real and tangible goals. No matterr whether they fit your specific needs, having improvements objectives should guide us in our effort to learn by producing tangible outcomes.

What is our go-demo-6 pipeline missing? The answer can be a huge list that usually depends on your needs and processes. Nevertheless, they are a few important improvement we are likely going to agree on.

We are not waiting until deployment of our releases rolls out. As a result, functional tests are likely going to fail or execute against the old release. We can avoid that easily by executing `kubectl rollout status` before running funcional and other types of tests that require a live application. That is definitely a better solution than executing `sleep` that is likely going to run longer than needed or be too short and end up with the same result as if we do not run it at all.

The steps we added so far (at least when using serverless Jenkins) were not named. As a result, it is sometimes hard to follow progress through `jx get activities` as well as to deduce which part of logs belongs too which step.

TODO: Add the rest of the improments

All in all, the improvements we'll try to add to our pipelines are as follows.

* Wait until new release rolls out
* Name all the steps to simplify tracking and debugging
* 

```bash
cd go-demo-6

# If not already imported
jx import --pack go --batch-mode

jx get activities \
    --filter go-demo-6 \
    --watch
```

```
STEP                                          STARTED AGO DURATION STATUS
vfarcic/go-demo-6/master #1                         8m10s    1m32s Succeeded Version: 1.0.96
  from build pack                                   8m10s    1m32s Succeeded
    Build Container Build                           8m10s      26s Succeeded
    Build Make Build                                8m13s      25s Succeeded
    Build Post Build                                8m10s      26s Succeeded
    Git Merge                                       8m14s       1s Succeeded
    Git Source Vfarcic Go Demo 6 Master Qrv88       9m26s       0s Succeeded https://github.com/vfarcic/go-demo-6
    Promote Changelog                               8m10s      32s Succeeded
    Promote Helm Release                             8m9s      40s Succeeded
    Promote Jx Promote                               8m9s    1m30s Succeeded
    Setup Jx Git Credentials                        8m13s       0s Succeeded
    Nop                                              8m8s    1m30s Succeeded
  Promote: staging                                  7m24s      45s Succeeded
    PullRequest                                     7m24s      45s Succeeded  PullRequest: https://github.com/vfarcic/environment-tekton-staging/pull/1 Merge SHA: daee76f2a2204c10d35c8b71c110078ba2c2b2bd
    Update                                          6m39s       0s Succeeded
```

```bash
# Cancel with *ctrl+c*

git checkout -b better-pipeline
```

## Named Steps And Multi-Line Commands

TODO: Continue text

So far I tried my best to hide a big problem with execution of functional tests in our pipelines. They are executed after promotion

```bash
cat jenkins-x.yml
```

```yaml
buildPack: go
pipelineConfig:
  pipelines:
    pullRequest:
      build:
        preSteps:
        - command: make unittest
      promote:
        steps:
        - command: ADDRESS=`jx get preview --current 2>&1` make functest
```

```yaml
buildPack: go
pipelineConfig:
  pipelines:
    pullRequest:
      build:
        preSteps:
        - name: unit-tests
          command: make unittest
      promote:
        steps:
        - name: rollout
          command: |
            NS=$(echo cd-$REPO_OWNER-go-demo-6-$BRANCH_NAME | tr '[:upper:]' '[:lower:]')
            kubectl -n $NS rollout status deployment preview-preview
        - name: functional-tests
          command: ADDRESS=`jx get preview --current 2>&1` make functest
```

```bash
# Also available from https://gist.github.com/vfarcic/a0a3202e1426c44f8dea305618806f97

jx step syntax validate pipeline

git add .

git commit -m "rollout status"

git push \
    --set-upstream origin better-pipeline

# TODO: Confirm that `jx create pullrequest` works with forked repo

jx create pullrequest \
  --title "Better pipeline" \
  --body "What I can say?" \
  --batch-mode

BRANCH=[...] # e.g., PR-72

jx get activities \
    --filter go-demo-6 \
    --watch
```

```
vfarcic/go-demo-6/PR-76 #1                                 3m48s    1m56s Succeeded
  from build pack                                          3m48s    1m56s Succeeded
    Build Container Build                                  3m48s      36s Succeeded
    Build Make Linux                                       3m51s      35s Succeeded
    Build Step2                                            3m51s      33s Succeeded
    Git Merge                                              3m52s       4s Succeeded
    Git Source Vfarcic Go Demo 6 Pr 76 Serverl Ggnvn       3m52s       1s Succeeded https://github.com/vfarcic/go-demo-6
    Postbuild Post Build                                   3m48s      37s Succeeded
    Promote Functional Tests                               3m47s    1m55s Succeeded
    Promote Jx Preview                                     3m48s    1m11s Succeeded
    Promote Make Preview                                   3m48s      52s Succeeded
    Promote Rollout                                        3m48s    1m52s Succeeded
    Nop                                                    3m47s    1m55s Succeeded
  Preview                                                  2m38s           https://github.com/vfarcic/go-demo-6/pull/76
    Preview Application                                    2m38s           http://go-demo-6.cd-vfarcic-go-demo-6-pr-76.35.227.63.73.nip.io
```

```bash
# Cancel with *ctrl+c*

# https://github.com/jenkins-x/jx/issues/4016

jx get build logs \
    --filter go-demo-6 \
    --branch $BRANCH
```

```
getting the log for build vfarcic/go-demo-6/PR-76 #1 serverless-jenkins stage from build pack and container build-step-promote-rollout
Waiting for deployment "preview-preview" rollout to finish: 0 of 3 updated replicas are available...
Waiting for deployment "preview-preview" rollout to finish: 1 of 3 updated replicas are available...
Waiting for deployment "preview-preview" rollout to finish: 2 of 3 updated replicas are available...
deployment "preview-preview" successfully rolled out
getting the log for build vfarcic/go-demo-6/PR-76 #1 serverless-jenkins stage from build pack and container build-step-promote-functional-tests
```

## Agent

```yaml
buildPack: go
pipelineConfig:
  pipelines:
    pullRequest:
      build:
        preSteps:
        - name: unit-tests
          command: make unittest
      promote:
        steps:
        - name: rollout
          command: |
            NS=$(echo cd-$REPO_OWNER-go-demo-6-$BRANCH_NAME | tr '[:upper:]' '[:lower:]')
            kubectl -n $NS rollout status deployment preview-preview
        - name: api-tests
          command: newman run test-data/postman.json -n 100
          agent:
            image: postman/newman:4-alpine
        - name: functional-tests
          command: ADDRESS=`jx get preview --current 2>&1` make functest
```

```bash
jx step syntax validate pipeline

git add .

git commit -m "Postman"

git push

jx get build logs \
    --filter go-demo-6 \
    --branch $BRANCH
```

## Loops

TODO: Continue commands

TODO: https://github.com/jenkins-x/jx/issues/3975

```yaml
buildPack: go
pipelineConfig:
  pipelines:
    pullRequest:
      build:
        preSteps:
        - name: unit-tests
          command: make unittest
        - loop:
            variable: ARCH
            values:
            - arch-1
            - arch-2
            - arch-3
            steps:
            - name: something
              command: echo ${ARCH}
      promote:
        steps:
        - name: rollout
          command: |
            NS=$(echo cd-$REPO_OWNER-go-demo-6-$BRANCH_NAME | tr '[:upper:]' '[:lower:]')
            kubectl -n $NS rollout status deployment preview-preview
        - name: functional-tests
          command: ADDRESS=`jx get preview --current 2>&1` make functest
```

```bash
jx step syntax validate pipeline

git add .

git commit -m "Multi-architecture"

git push

jx get activities \
    --filter go-demo-6 \
    --watch

# Cancel with *ctrl+c*

jx get build logs \
    --filter go-demo-6 \
    --branch $BRANCH
```

# TODO: Agent
# TODO: ChatConfig
# TODO: ConfigMapKeySelector
# TODO: Container
# TODO: EnvVar
# TODO: EnvVarSource
# TODO: IssueTrackerConfig
# TODO: ObjectFieldSelector
# TODO: ParsedPipeline
# TODO: PipelineConfig
# TODO: PipelineExtends
# TODO: PipelineLifecycle
# TODO: PipelineLifecycles
# TODO: PipelineOverride
# TODO: Pipelines
# TODO: Post
# TODO: PostAction
# TODO: PreviewEnvironmentConfig
# TODO: ProjectConfig
# TODO: Quantity
# TODO: ResourceFieldSelector
# TODO: RootOptions
# TODO: SecretKeySelector
# TODO: Stage
# TODO: StageOptions
# TODO: Stash
# TODO: Step
# TODO: Timeout
# TODO: Unstash
# TODO: WikiConfig

# TODO: AddonConfig

jx step syntax schema
```

```json
JSON schema for jenkins-x.yml:
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "$ref": "#/definitions/ProjectConfig",
  "definitions": {
    "AddonConfig": {
      "properties": {
        "name": {
          "type": "string"
        },
        "version": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "Agent": {
      "properties": {
        "container": {
          "type": "string"
        },
        "dir": {
          "type": "string"
        },
        "image": {
          "type": "string"
        },
        "label": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "ChatConfig": {
      "properties": {
        "developerChannel": {
          "type": "string"
        },
        "kind": {
          "type": "string"
        },
        "url": {
          "type": "string"
        },
        "userChannel": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "ConfigMapKeySelector": {
      "properties": {
        "key": {
          "type": "string"
        },
        "name": {
          "type": "string"
        },
        "optional": {
          "type": "boolean"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "Container": {
      "additionalProperties": true,
      "type": "object"
    },
    "EnvVar": {
      "properties": {
        "name": {
          "type": "string"
        },
        "value": {
          "type": "string"
        },
        "valueFrom": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/EnvVarSource"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "EnvVarSource": {
      "properties": {
        "configMapKeyRef": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/ConfigMapKeySelector"
        },
        "fieldRef": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/ObjectFieldSelector"
        },
        "resourceFieldRef": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/ResourceFieldSelector"
        },
        "secretKeyRef": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/SecretKeySelector"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "IssueTrackerConfig": {
      "properties": {
        "kind": {
          "type": "string"
        },
        "project": {
          "type": "string"
        },
        "url": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "ObjectFieldSelector": {
      "properties": {
        "apiVersion": {
          "type": "string"
        },
        "fieldPath": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "ParsedPipeline": {
      "properties": {
        "agent": {
          "$ref": "#/definitions/Agent"
        },
        "env": {
          "items": {
            "$ref": "#/definitions/EnvVar"
          },
          "type": "array"
        },
        "environment": {
          "items": {
            "$ref": "#/definitions/EnvVar"
          },
          "type": "array"
        },
        "options": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/RootOptions"
        },
        "post": {
          "items": {
            "$ref": "#/definitions/Post"
          },
          "type": "array"
        },
        "stages": {
          "items": {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "$ref": "#/definitions/Stage"
          },
          "type": "array"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "PipelineConfig": {
      "properties": {
        "agent": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/Agent"
        },
        "env": {
          "items": {
            "$ref": "#/definitions/EnvVar"
          },
          "type": "array"
        },
        "environment": {
          "type": "string"
        },
        "extends": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/PipelineExtends"
        },
        "pipelines": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/Pipelines"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "PipelineExtends": {
      "properties": {
        "file": {
          "type": "string"
        },
        "import": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "PipelineLifecycle": {
      "properties": {
        "preSteps": {
          "items": {
            "$ref": "#/definitions/Step"
          },
          "type": "array"
        },
        "replace": {
          "type": "boolean"
        },
        "steps": {
          "items": {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "$ref": "#/definitions/Step"
          },
          "type": "array"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "PipelineLifecycles": {
      "properties": {
        "build": {
          "$ref": "#/definitions/PipelineLifecycle"
        },
        "pipeline": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/ParsedPipeline"
        },
        "postBuild": {
          "$ref": "#/definitions/PipelineLifecycle"
        },
        "preBuild": {
          "$ref": "#/definitions/PipelineLifecycle"
        },
        "promote": {
          "$ref": "#/definitions/PipelineLifecycle"
        },
        "setVersion": {
          "$ref": "#/definitions/PipelineLifecycle"
        },
        "setup": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/PipelineLifecycle"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "PipelineOverride": {
      "properties": {
        "name": {
          "type": "string"
        },
        "pipelines": {
          "items": {
            "type": "string"
          },
          "type": "array"
        },
        "stages": {
          "items": {
            "type": "string"
          },
          "type": "array"
        },
        "step": {
          "$ref": "#/definitions/Step"
        },
        "steps": {
          "items": {
            "$ref": "#/definitions/Step"
          },
          "type": "array"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "Pipelines": {
      "properties": {
        "feature": {
          "$ref": "#/definitions/PipelineLifecycles"
        },
        "overrides": {
          "items": {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "$ref": "#/definitions/PipelineOverride"
          },
          "type": "array"
        },
        "post": {
          "$ref": "#/definitions/PipelineLifecycle"
        },
        "pullRequest": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/PipelineLifecycles"
        },
        "release": {
          "$ref": "#/definitions/PipelineLifecycles"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "Post": {
      "properties": {
        "actions": {
          "items": {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "$ref": "#/definitions/PostAction"
          },
          "type": "array"
        },
        "condition": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "PostAction": {
      "properties": {
        "name": {
          "type": "string"
        },
        "options": {
          "patternProperties": {
            ".*": {
              "type": "string"
            }
          },
          "type": "object"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "PreviewEnvironmentConfig": {
      "properties": {
        "disabled": {
          "type": "boolean"
        },
        "maximumInstances": {
          "type": "integer"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "ProjectConfig": {
      "properties": {
        "addons": {
          "items": {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "$ref": "#/definitions/AddonConfig"
          },
          "type": "array"
        },
        "buildPack": {
          "type": "string"
        },
        "buildPackGitRef": {
          "type": "string"
        },
        "buildPackGitURL": {
          "type": "string"
        },
        "chat": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/ChatConfig"
        },
        "dockerRegistryHost": {
          "type": "string"
        },
        "dockerRegistryOwner": {
          "type": "string"
        },
        "env": {
          "items": {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "$ref": "#/definitions/EnvVar"
          },
          "type": "array"
        },
        "issueTracker": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/IssueTrackerConfig"
        },
        "noReleasePrepare": {
          "type": "boolean"
        },
        "pipelineConfig": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/PipelineConfig"
        },
        "previewEnvironments": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/PreviewEnvironmentConfig"
        },
        "wiki": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/WikiConfig"
        },
        "workflow": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "Quantity": {
      "additionalProperties": false,
      "type": "object"
    },
    "ResourceFieldSelector": {
      "properties": {
        "containerName": {
          "type": "string"
        },
        "divisor": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/Quantity"
        },
        "resource": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "RootOptions": {
      "properties": {
        "containerOptions": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/Container"
        },
        "retry": {
          "type": "integer"
        },
        "timeout": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/Timeout"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "SecretKeySelector": {
      "properties": {
        "key": {
          "type": "string"
        },
        "name": {
          "type": "string"
        },
        "optional": {
          "type": "boolean"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "Stage": {
      "properties": {
        "agent": {
          "$ref": "#/definitions/Agent"
        },
        "env": {
          "items": {
            "$ref": "#/definitions/EnvVar"
          },
          "type": "array"
        },
        "environment": {
          "items": {
            "$ref": "#/definitions/EnvVar"
          },
          "type": "array"
        },
        "name": {
          "type": "string"
        },
        "options": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/StageOptions"
        },
        "parallel": {
          "items": {
            "$ref": "#/definitions/Stage"
          },
          "type": "array"
        },
        "post": {
          "items": {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "$ref": "#/definitions/Post"
          },
          "type": "array"
        },
        "stages": {
          "items": {
            "$ref": "#/definitions/Stage"
          },
          "type": "array"
        },
        "steps": {
          "items": {
            "$ref": "#/definitions/Step"
          },
          "type": "array"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "StageOptions": {
      "properties": {
        "containerOptions": {
          "$ref": "#/definitions/Container"
        },
        "retry": {
          "type": "integer"
        },
        "stash": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/Stash"
        },
        "timeout": {
          "$ref": "#/definitions/Timeout"
        },
        "unstash": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/Unstash"
        },
        "workspace": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "Stash": {
      "properties": {
        "files": {
          "type": "string"
        },
        "name": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "Step": {
      "properties": {
        "agent": {
          "$ref": "#/definitions/Agent"
        },
        "args": {
          "items": {
            "type": "string"
          },
          "type": "array"
        },
        "command": {
          "type": "string"
        },
        "comment": {
          "type": "string"
        },
        "container": {
          "type": "string"
        },
        "dir": {
          "type": "string"
        },
        "env": {
          "items": {
            "$ref": "#/definitions/EnvVar"
          },
          "type": "array"
        },
        "groovy": {
          "type": "string"
        },
        "image": {
          "type": "string"
        },
        "loop": {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "$ref": "#/definitions/Loop"
        },
        "name": {
          "type": "string"
        },
        "options": {
          "patternProperties": {
            ".*": {
              "type": "string"
            }
          },
          "type": "object"
        },
        "sh": {
          "type": "string"
        },
        "step": {
          "type": "string"
        },
        "steps": {
          "items": {
            "$ref": "#/definitions/Step"
          },
          "type": "array"
        },
        "when": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "Timeout": {
      "properties": {
        "time": {
          "type": "integer"
        },
        "unit": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "Unstash": {
      "properties": {
        "dir": {
          "type": "string"
        },
        "name": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    },
    "WikiConfig": {
      "properties": {
        "kind": {
          "type": "string"
        },
        "space": {
          "type": "string"
        },
        "url": {
          "type": "string"
        }
      },
      "additionalProperties": false,
      "type": "object"
    }
  }
}
```

```bash
jx step syntax schema --buildpack

jx step syntax validate pipeline

jx step syntax validate buildpacks
```

TODO: https://cloudbees.atlassian.net/wiki/spaces/JO/pages/914326154/YAML+Syntax+Reference?utm_term=page&utm_source=connie-slack&utm_medium=referral-external

TODO: If static, use build pack pipelines as much as possible

TODO: Multiple pipeline files: https://github.com/jenkins-x/jenkins-x-versions

TODO: https://github.com/jenkins-x/prow-config-tekton/blob/master/prow/config.yaml#L628-L646

TODO: Blank build pack: https://github.com/jenkins-x/jenkins-x-versions/blob/master/jenkins-x-tekton.yml

TODO: Change the agent/image

TODO: Replace a lifecycle

TODO: https://jenkins-x.io/architecture/jenkins-x-pipelines/#default-environment-variables

TODO: Create a pipeline from scratch

TODO: https://github.com/jenkins-x/jx/pull/3934

## What Now?

TODO: Rewrite

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you chose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-tekton-staging

hub delete -y \
  $GH_USER/environment-tekton-production

rm -rf ~/.jx/environments/$GH_USER/environment-tekton-*
```
