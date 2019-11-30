```bash
git clone \
    https://github.com/vfarcic/fargate-specs.git

cd fargate-specs

export AWS_ACCESS_KEY_ID=[...]

export AWS_SECRET_ACCESS_KEY=[...]

export AWS_DEFAULT_REGION=us-east-1

aws ecs create-cluster \
    --cluster-name devops25

open "https://us-west-2.console.aws.amazon.com/ecs/home?region=$AWS_DEFAULT_REGION"

aws ecs list-clusters

aws ecs register-task-definition \
    --cli-input-json \
    file://$PWD/tasks/jenkins.json

# NOTE: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html

# TODO: LB

# TODO: Persist JENKINS_HOME

aws ecs list-task-definitions

aws ecs create-service \
    --cluster devops25 \
    --service-name jenkins \
    --task-definition jenkins:3 \
    --desired-count 1 \
    --launch-type "FARGATE" \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-abcd1234],securityGroups=[sg-abcd1234]}"
```

## What Now?

```bash
aws ecs delete-cluster --cluster devops25
```