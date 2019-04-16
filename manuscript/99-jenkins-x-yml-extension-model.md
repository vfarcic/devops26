## Using The Extension Model in jenkins-x.yaml

https://jenkins-x.io/architecture/jenkins-x-pipelines/#customising-the-pipelines

TODO: Figure out why it fails with `replace: false`

```bash
echo "pipelineConfig:
  pipelines:
    release:
      setup:
        replace: true
        steps:
        - sh: echo 'Injected into the setup phase'
      preBuild:
        replace: true
        steps:
        - sh: echo 'Injected into the preBuild phase'
      build:
        replace: true
        steps:
        - sh: echo 'Injected into the build phase'
      postBuild:
        replace: true
        steps:
        - sh: echo 'Injected into the postBuild phase'
      promote:
        replace: true
        steps:
        - sh: echo 'Injected into the promote phase'
" | tee -a jenkins-x.yml

git add .

git commit -m "Lifecycle example"

git push

jx get activities -f jx-go -w

jx get build logs

# Add pullRequest and feature pipelines
```