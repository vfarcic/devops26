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

# Advanced Serverless Jenkins X Pipelines

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

```bash
cd go-demo-6

# TODO: Agent
# TODO: ChatConfig
# TODO: ConfigMapKeySelector
# TODO: Container
# TODO: EnvVar
# TODO: EnvVarSource
# TODO: IssueTrackerConfig
# TODO: Loop
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
    "Loop": {
      "properties": {
        "steps": {
          "items": {
            "$ref": "#/definitions/Step"
          },
          "type": "array"
        },
        "values": {
          "items": {
            "type": "string"
          },
          "type": "array"
        },
        "variable": {
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
