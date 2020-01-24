# Using The Pipeline Extension Model

W> The examples in this chapter work only with serverless Jenkins X.

Jenkins X pipeline extension model is, in my opinion, one of the most exciting and innovative improvements we got with Jenkins X. It allows us to focus on what really matters in our projects and to ignore the steps that are common to others. Understanding the evolution of Jenkins pipelines is vital if we are to adopt the extension model. So, before we dive into extensions, we need to understand better how pipelines evolved over time.

## The Evolution Of Jenkins Jobs And How We Got To The YAML-Based jenkins-x.yml Format

When Jenkins appeared, its pipelines were called Freestyle jobs. There was no way to describe them in code, and they were not kept in version control. We were creating and maintaining those jobs through Jenkins UI by filling input fields, marking checkboxes, and selecting values from drop-down lists. The results were impossible-to-read XML files stored in the Jenkins home directory. Nevertheless, that approach was so great (compared to what existed at the time) that Jenkins become widely adopted overnight. But, that was many years ago and what was great over a decade ago is not necessarily as good today. As a matter of fact, Freestyle jobs are the antithesis of the types of jobs we should be writing today. Tools that create code through drag-and-drop methods are extinct. Not having code in version control is a cardinal sin. Not being able to use our favorite IDE or code editor is unacceptable. Hence, the Jenkins community created Jenkins pipelines.

Jenkins pipelines are an attempt to rethink how we define Jenkins jobs. Instead of the click-type-select approach of Freestyle jobs, pipelines are defined in Jenkins-specific Groovy-based domain specific language (DSL) written in Jenkinsfile and stored in code repositories together with the rest of the code of our applications. That approach managed to accomplish many improvements when compared to Freestyle jobs. A single job could define the entire pipeline, the definition could be stored in the code repository, and we could avoid part of the repetition through the usage of Jenkins Shared Libraries. But, for some users, there was a big problem with Jenkins pipelines.

Using Groovy-based DSL was too big of a jump for some Jenkins users. Switching from click-type-select with Freestyle jobs into Groovy code was too much. We had a significant number of Jenkins users with years of experience in accomplishing results by clicking and selecting options, but without knowing how to write code.

I'll leave aside the discussion in which I'd argue that anyone working in the software industry should be able to write code no matter their role. Instead, I'll admit that having non-coders transition from UI-based into the code-only type of Jenkins jobs posed too much of a challenge. Even if we would agree that everyone in the software industry should know how to write code, there is still the issue of Groovy.

The chances are that Groovy is not your preferred programming language. You might be working with NodeJS, Go, Python, .Net, C, C++, Scala, or one of the myriads of other languages. Even if you are Java developer, Groovy might not be your favorite. Given that the syntax is somehow similar to Java and the fact that both use JVM does not diminish the fact that Groovy and Java are different languages. Jenkins DSL tried to "hide" Groovy, but that did not remove the fact that you had to know (at least basic) Groovy to write Jenkins pipelines. That meant that many had to choose whether to learn Groovy or to switch to something else. So, even though Jenkins pipelines were a significant improvement over Freestyle jobs, there was still work to be done to make them useful to anyone no matter their language preference. Hence, the community came up with the declarative pipeline.

I> Declarative pipelines are not really declarative. No matter the format, pipelines are by their nature sequential.

Declarative pipeline format is a simplified way to write Jenkinsfile definitions. To distinguish one from the other, we call the older pipeline syntax scripted, and the newer declarative pipeline. We got much-needed simplicity. There was no Groovy to learn unless we employ shared libraries. The new pipeline format was simple to learn and easy to write. It served us well, and it was adopted by static Jenkins X. And yet, serverless Jenkins X introduced another change to the format of pipeline definitions. Today, we can think of static Jenkins X with declarative pipelines as a transition towards serverless Jenkins X.

With serverless Jenkins X, we moved into pipelines defined in YAML. Why did we do that? One argument could be that YAML is easier to understand and manage. Another could claim that YAML is the golden-standard for any type of definition, Kubernetes resources being one example. Most of the other tools, especially newer ones, switched to YAML definitions. While those and many other explanations are valid and certainly played a role in making the decision to switch to YAML, I believe that we should look at the change from a different angle.

All Jenkins formats for defining pipelines were based on the fact that it will be Jenkins who will execute them. Freestyle jobs used XML because Jenkins uses XML to store all sorts of information. A long time ago, when Jenkins was created, XML was all the rage. Scripted pipelines use Groovy DSL because pipelines need to interact with Jenkins. Since it is written in Java, Groovy is a natural choice. It is more dynamic than Java. It compiles at runtime allowing us to use it as a scripting mechanism. It can access Jenkins libraries written in Java, and it can access Jenkins itself at runtime. Then we added declarative pipeline that is something between Groovy DSL and YAML. It is a wrapper around the scripted pipeline.

What all those formats have in common is that they are all limited by Jenkins' architecture. And now, with serverless Jenkins X, there is no Jenkins any more.

Saying that Jenkins is gone is not entirely correct. Jenkins lives in Jenkins X. The foundation that served us well is there. The experience from many years of being the leading CI/CD platform was combined with the need to solve challenges that did not exist before. We had to come up with a platform that is Kubernetes-first, cloud-native, fault-tolerant, highly-available, lightweight, with API-first design, and so on and so forth. The result is Jenkins X or, to be more precise, its serverless flavor. It combines some of the best tools on the market with custom code written specifically for Jenkins X. And the result is what we call serverless or next generation Jenkins X.

The first generation of Jenkins X (static flavor) reduced the "traditional" Jenkins to a bare minimum. That allowed the community to focus on building all the new tools needed to bring Jenkins to the next level. It reduced Jenkins' surface and added a lot of new code around it. At the same time, static Jenkins X maintains compatibility with the "traditional" Jenkins. Teams can move to Jenkins X without having to rewrite everything they had before while, at the same time, keeping some level of familiarity.

Serverless Jenkins X is the next stage in the evolution. While static flavor reduced the role of the "traditional" Jenkins, serverless eradicated it. The end result is a combination of Prow, Jenkins Pipeline Operator, Tekton, and quite a few other tools and processes. Some of them (e.g., Prow, Tekton) are open-source projects bundled into Jenkins X while others (e.g., Jenkins Pipeline Operator) are written from scratch. On top of those, we got `jx` as the CLI that allows us to control any aspect of Jenkins X.

Given that there is no "traditional" Jenkins in the serverless flavor of Jenkins X, there is no need to stick with the old formats to define pipelines. Those that do need to continue using `Jenkinsfile` can do so by using static Jenkins X. Those who want to get the most benefit from the new platform will appreciate the benefits of the new YAML-based format defined in `jenkins-x.yml`. More often than not, organizations will combine both. There are use cases when static Jenkins with the support for Jenkinsfile is a good choice, especially in cases when projects already have pipelines running in the "traditional" Jenkins. On the other hand, new projects can be created directly in serverless Jenkins X and use `jenkins-x.yml` to define pipelines.

Unless you just started a new company, there are all sorts of situations and some of them might be better fulfilled with static Jenkins X and Jenkinsfile, others with serverless Jenkins X and jenkins-x.yml, while there are likely going to exist projects that started a long time ago and do not see enough benefit to change. Those can stay in "traditional" Jenkins running outside Kubernetes or in any other tool they might be using.

To summarize, static Jenkins is a "transition" between the "traditional" Jenkins and the final solution (serverless flavor). The former has reduced Jenkins to a bare minimum, while the latter consists of entirely new code written specifically to solve problems we're facing today and leveraging all the latest and greatest technology can offer.

So, Jenkins served us well, and it will continue living for a long time since many applications were written a while ago and might not be good candidates to embrace Kubernetes. Static Jenkins X is for all those who want to transition to Kubernetes without losing all their investment (e.g., Jenkinsfile). Serverless Jenkins X is for all those who seek the full power of Kubernetes and want to be genuinely cloud-native.

I> For now (April 2019), serverless Jenkins X works only with GitHub. Until that is corrected, using any other Git platform might be yet another reason to stick with static Jenkins X. The rest of the text will assume that you do use GitHub or that you can wait for a while longer until the support for other Git platforms is added.

Long story short, Serverless Jenkins X uses YAML in jenkins-x.yml to describe pipelines, while more traditional Jenkins as well as static Jenkins X rely on Groovy DSL defined in Jenkinsfile. Freestyle jobs are deprecated for quite a long time, so we'll ignore their existence. Whether you prefer Jenkinsfile or jenkins-x.yml format will depend on quite a few factors, so let's break down those that matter the most.

If you already use Jenkins, you are likely used to Jenkinsfile and might want to keep it for a while longer.

If you have complex pipelines, you might want to stick with the scripted pipeline in Jenkinsfile. That being said, I do not believe that anyone should have complex pipelines. Those that do usually tried to solve problems in the wrong place. Pipelines (of any kind) are not supposed to have complex logic. Instead, they should define orchestration of automated tasks defined somewhere else. For example, instead of having tens or hundreds of lines of pipeline code that defines how to deploy our application, we should move that logic into a script and simply invoke it from the pipeline. That logic is similar to what `jx promote` does. It performs semi-complex logic, but from the pipeline point of view it is a simple step with a single command. If we do adopt that approach, there is no need for complex pipelines and, therefore, there is no need for Jenkins' scripted pipeline. Declarative is more than enough when using Jenkinsfile.

If you do want to leverage all the latest and greatest that Jenkins X (serverless flavor) brings, you should switch to YAML format defined in the `jenkins-x.yml` file.

Therefore, use Jenkinsfile with static Jenkins X if you already have pipelines and you do not want to rewrite them. Stop using scripted pipelines as an excuse for misplaced complexity. Adopt serverless Jenkins X with YAML-based format for all other cases.

But you probably know all that by now. You might be even wondering why do we go through history lessons now? The reason for the reminiscence lies in the "real" subject I want to discuss. We'll talk about *code repetition*, and we had to set the scene for what's coming next.

## Getting Rid Of Repetition

Copying and pasting code is a major sin among developers. One of the first things we learn as software engineers is that duplicated code is hard to maintain and prone to errors. That's why we are creating libraries. We do not want to repeat ourselves, so we even came up with a commonly used acronym DRY (don't repeat yourself).

Having that in mind, all I can say is that Jenkins users are sinful.

When we create pipelines through static Jenkins X, every project gets a Jenkinsfile based on the pipeline residing in the build pack we chose. If we have ten projects, there will be ten identical copies of the same Jenkinsfile. Over time, we'll modify those Jenkinsfiles, and they might not all be precisely the same. Even in those cases, most of the Jenkinsfile contents will remain untouched. It does not matter whether 100% of Jenkinsfile is repeated across projects or it that number drops to 25%. There is a high level of repetition.

In the past, we fought such repetition through shared libraries. We would encapsulate repeated lines into Groovy libraries and invoke then from any pipeline that needs to use those features. But we abandoned that approach with Jenkins X since Jenkins shared libraries have quite a few deficiencies. They can be written only in Groovy, and that might not be a language everyone wants to learn. They cannot be (easily) tested in isolation. We'd need to run a Jenkins pipeline that invokes the library as a way of testing it. Finally, we could not (easily) run them locally (without Jenkins).

While shared libraries can be used with static Jenkins X, we probably should not go down that route. Instead, I believe that a much better way to encapsulate features is by writing executables. Instead of being limited to Groovy, we can write an executable in Bash, Go, Python, or any other language that allows us to execute code. Such executables (usually scripts) can be easily tested locally, they can be used by developers with Jenkins X, and can be executed from inside pipelines. If you take another look at any Jenkins X pipeline, you'll see that there are no plugins, and there are no shared libraries. It's mostly a series of `sh` commands that execute Shell commands (e.g., `cat`, `jx`, etc.). Such pipelines are easy to understand, easy to run with or without Jenkins X (e.g., on a laptop), and easy to maintain. Both plugins and shared libraries are dead.

Why do I believe that plugins are dead? To answer that question we need to take a look behind the reasons for their existence. Most plugins are created either to isolate users from even basic commands or because the applications they integrate with do not have decent API.

Isolating anyone from basic commands is just silly. For example, using a plugin that will build a Docker image instead of merely executing `docker image build` is beyond comprehension. On the other hand, if we do need to integrate with an application that does not have an API and CLI, we are better off throwing that application to thrash. It's not 1999 anymore. Every application has a good API, and most have a CLI. Those that don't are unworthy our attention.

So, there are no more plugins, and we should not use shared libraries. All repetitive features should be in executables (e.g., script). With that in mind, do we still have repetition? We do. Even if all the features (e.g., deployment to production) are in scripts reused across pipelines, we are still bound to repeat a lot of orchestration code.

A good example is Jenkinsfile pipelines created when we import a project or create a new one through the `jx create quickstart` command. Each project gets around 80 lines of Jenkinsfile. All those based on the same language will have exactly the same Jenkinsfile. Even those based on different programming languages will be mostly the same. The all have to check out the code, to create release notes, to run some form of tests, to deploy releases to some environments, and so on and so forth. All those lines in Jenkinsfile only deal with orchestration since most of the features are in executables (e.g., `jx promote`). Otherwise, we'd jump from around 80 to hundreds or even thousands of lines of repetitive code. Now, even if half of those 80 lines are repeated, that's still 40 lines of repetition. That is not bad by itself. However, we are likely going to have a hard time if we need to apply a fix or change the logic across multiple projects.

The serverless flavor of Jenkins X solves the problem of unnecessary repetition through the **pipeline extension model**. We'll see it in action soon. For now, we need a cluster with Jenkins X up-and-running.

## Creating A Kubernetes Cluster With Jenkins X

You can skip this section if you kept the cluster from the previous chapter and it contains serverless Jenkins X. Otherwise, we'll need to create a new Jenkins X cluster.

I> All the commands from this chapter are available in the [13-pipeline-extension-model.sh](https://gist.github.com/ca1d91973560dc0bd385c471437069ab) Gist.

For your convenience, the Gists that will create a new serverless Jenkins X cluster or install it inside an existing one are as follows.

* Create a new serverless **GKE** cluster: [gke-jx-serverless.sh](https://gist.github.com/fe18870a015f4acc34d91c106d0d43c8)
* Create a new serverless **EKS** cluster: [eks-jx-serverless.sh](https://gist.github.com/f4a1df244d1852ee250e751c7191f5bd)
* Create a new serverless **AKS** cluster: [aks-jx-serverless.sh](https://gist.github.com/b07f45f6907c2a1c71f45dbe0df8d410)
* Use an **existing** serverless cluster: [install-serverless.sh](https://gist.github.com/7b3b3d90ecd7f343effe4fff5241d037)

We will not need the `jx-prow` project we created in the previous chapter. If you are reusing the cluster and Jenkins X installation, you might want to remove it and save a bit of resources.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
GH_USER=[...]

jx delete application \
    $GH_USER/jx-prow \
    --batch-mode
```

I> The commands that follow will reset your *go-demo-6* `master` with the contents of the `versioning` branch that contains all the changes we did so far. Please execute them only if you are unsure whether you did all the exercises correctly.

```bash
cd go-demo-6

git pull

git checkout versioning-tekton

git merge -s ours master --no-edit

git checkout master

git merge versioning-tekton

git push

cd ..
```

If you ever restored a branch at the beginning of a chapter, the chances are that there is a reference to my user (`vfarcic`). We'll change that to Google project since that's what Knative will expect to be the location of the container images.

W> Please execute the commands that follow only if you are using **GKE** and if you ever restored a branch at the beginning of a chapter (like in the snippet above).

```bash
cd go-demo-6

cat charts/go-demo-6/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | sed -e \
    "s@devops-26@$PROJECT@g" \
    | tee charts/go-demo-6/Makefile

cat charts/preview/Makefile \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | sed -e \
    "s@devops-26@$PROJECT@g" \
    | tee charts/preview/Makefile

cat skaffold.yaml \
    | sed -e \
    "s@vfarcic@$PROJECT@g" \
    | sed -e \
    "s@devops-26@$PROJECT@g" \
    | tee skaffold.yaml

cd ..
```

I> If you destroyed the cluster at the end of the previous chapter, you'll need to import the *go-demo-6* application again. Please execute the commands that follow only if you created a new cluster specifically for the exercises from this chapter.

```bash
cd go-demo-6

jx import --batch-mode

jx get activities \
    --filter go-demo-6 \
    --watch

cd ..
```

Now we can explore Jenkins X Pipeline Extension Model.

## Exploring Build Pack Pipelines

As a reminder, we'll take another quick look at the `jenkins-x.yml` file.

```bash
cd go-demo-6

cat jenkins-x.yml
```

The output is as follows.

```yaml
buildPack: go
```

The pipeline is as short as it can be. It tells Jenkins that it should use the pipeline from the build pack `go`.

We already explored build packs and learned how we can extend them to fit out specific needs. But, we skipped discussing one of the key files in build packs. I intentionally avoided talking about the `pipeline.yaml` file because it uses the new format introduced in serverless Jenkins X. Given that at the time we explored build packs we did not yet know about the existence of serverless Jenkins X, it would have been too early to discuss new pipelines. Now that you are getting familiar with the serverless flavor, we can go back and explore `pipeline.yaml` located in each of the build packs.

```bash
open "https://github.com/jenkins-x-buildpacks/jenkins-x-kubernetes"
```

Open *packs* followed with the *go* directory. We can see that *pipeline.yaml* is one of the build pack files, so let's take a closer look.

```bash
curl "https://raw.githubusercontent.com/jenkins-x-buildpacks/jenkins-x-kubernetes/master/packs/go/pipeline.yaml"
```

If you remember Jenkinsfile we used before, you'll notice that this pipeline is functionally the same. However, it is written in a different format. It's the same format used for pipelines in serverless Jenkins X. If we import that build pack into static Jenkins X, it gets translated into Jenkinsfile, mainly for compatibility reasons. On the other hand, if we are using serverless Jenkins X, it does not get translated into anything. Instead, we get the `jenkins-x.yml` file with the single line `buildPack: go` that tells the system to use the pipeline from the build pack, instead of copying it into the application repository.

Let us quickly digest the key sections of the `pipeline.yaml` file. It starts with the `extends` instruction that is as follows.

```yaml
extends:
  import: classic
  file: go/pipeline.yaml
```

The `extends` section is similar to how we extend libraries in most programming languages. It tells the system that it should use the build pack `go/pipeline.yaml` from the `classic` mode. That's the one we'd use if we choose `Library Workloads: CI+Release but no CD` when we installed Jenkins X. Those pipelines are meant for the flows that do not involve deployments. Since there is an overlap between `Library` and `Kubernetes` and we do not want to repeat ourselves, the `Kubenetes` one extends the `Library` (the name `classic` might be misleading).

Further down is the collection of `pipelines`.  The output, limited to the pipeline names is as follows.

```yaml
...
pipelines:
  pullRequest:
    ...
  release:
    ...
```

There are three types of pipelines; `pullRequest`, `release`, and `feature`. In the definition we see in front of us there are only the first two since `feature` pipelines are not very common.

It should be evident that the `pullRequest` pipeline is executed when we create PR. The `release` is run when we push or merge something into the master branch. Finally, `feature` is used with long term feature branches. Since trunk based or short term branches are the recommended model, `feature` is not included in build pack pipelines. You can add it yourself if you do prefer the model of using long-term branches

Each pipeline can have one of the following lifecycles: `setup`, `setversion`, `prebuild`, `build`, `postbuild`, and `promote`. If we go back to the definition in front of us, the output, limited to the lifecycles of the `pullRequest` pipeline, is as follows.

```yaml
...
pipelines:
  pullRequest:
    build:
      ...
    postBuild:
      ...
    promote:
      ...
```

In the YAML we're exploring, the `pullRequest` pipeline has lifecycles `build`, `postbuild`, and `promote`, while `release` has only `build` and `promote`.

Inside a lifecycle is any number of steps containing `sh` (the command) and an optional `name`, `comment`, and a few other instructions.

As an example, the full definition of the `build` lifecycle of the `pullRequest` pipeline is as follows.

```yaml
...
pipelines:
  pullRequest:
    build:
      steps:
      - sh: export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml
        name: container-build
...
```

Do not worry if the new pipeline format is confusing. It is very straightforward, and we'll explore it in more depth soon.

Before we move on, if you were wondering whether does the extension of the `classic` pipeline come from, it is in the `jenkins-x-buildpacks/jenkins-x-classic` repository. The one used with Go can be retrieved through the command that follows.

```bash
curl "https://raw.githubusercontent.com/jenkins-x-buildpacks/jenkins-x-classic/master/packs/go/pipeline.yaml"
```

The classic pipeline that serves as the base follows the same logic with pipelines, lifecycle, and steps. The significant difference is that it introduces a few additional instructions like `comment` and `when`. I'm sure you can get what the former does. The latter (`when`) is a conditional that defines whether the step should be executed in static (`!prow`) or in serverless (`prow`) Jenkins X.

As you can see, even though the new format for pipelines is used directly only in serverless Jenkins X, it is vital to understand it even if you're using the static flavor. Pipelines defined in build packs are using the new format and translating it into Jenkinsfile used with static Jenkins X, or extending them if we're using the serverless flavor. If you decide to extend community-maintained buildpacks, you will need to know how the new YAML-based format works, even if the end result will be Jenkinsfile.

By now, the first activity of the newly imported *go-demo-6* project should have finished. Let's take a look at the result.

```bash
jx get activities \
    --filter go-demo-6 \
    --watch
```

The output is as follows.

```
STEP                                          STARTED AGO DURATION STATUS
vfarcic/go-demo-6/master #1                         6m57s     5m2s Succeeded Version: 1.0.56
  from build pack                                   6m57s     5m2s Succeeded
    Credential Initializer Pmvfj                    6m57s       0s Succeeded
    Git Source Vfarcic Go Demo 6 Master Nck5w       6m55s       0s Succeeded https://github.com/vfarcic/go-demo-6
    Place Tools                                     6m52s       0s Succeeded
    Git Merge                                       5m41s       0s Succeeded
    Setup Jx Git Credentials                        3m51s       1s Succeeded
    Build Make Build                                3m49s      16s Succeeded
    Build Container Build                           3m30s       4s Succeeded
    Build Post Build                                3m24s       0s Succeeded
    Promote Changelog                               3m23s       6s Succeeded
    Promote Helm Release                            3m16s       9s Succeeded
    Promote Jx Promote                               3m6s    1m11s Succeeded
  Promote: staging                                   3m2s     1m7s Succeeded
    PullRequest                                      3m2s     1m7s Succeeded  PullRequest: https://github.com/vfarcic/environment-jx-rocks-staging/pull/1 Merge SHA: d6ed094a9803681dab1d0ae7b8501eac10e7703a
    Update                                          1m55s       0s Succeeded
```

We saw a similar output many times before and you might be wondering where does Jenkins X gets the names of the activity steps. They are a combination of the lifecycle and the name of a step from the pipeline which, in this case, is defined in the build pack. That's the same pipeline we explored previously. We can see all that from the output of the activity. If states that the pipeline is `from build pack`. Further down are the steps.

The first few steps are not defined in any pipeline. No matter what we specify, Jenkins X will perform a few setup tasks. The rest of the steps in the activity output is a combination of the lifecycle (e.g., `Promote`) and the step name (e.g., `jx-promote` > `Jx Promote`).

Now that we demystified the meaning of `buildPack: go` in our pipeline, you are probably wondering how to extend it.

## Extending Build Pack Pipelines

We already saw that pipelines based on the new format have a single line `buildPack: go`. To be more precise, those that are created based on a build pack are like that. While you can certainly create a pipeline from scratch, most use cases benefit from having a good base inherited from a build pack. For some, the base will be everything they need, but for others it will not. There is a high probability that you will need to extend those pipelines by adding your own steps or even to replace a whole lifecycle (e.g., `promote`). Our next mission is to figure out how to accomplish that. We'll explore how to extend pipelines used with serverless Jenkins X.

As any good developer (excluding those who work directly with the master branch), we'll start by creating a new branch.

```bash
git checkout -b extension
```

Since we need to make a change that will demonstrate how pipelines work, instead of making a minor modification like adding a random text to the README.md file, we'll do something we should have done a long time ago. We'll increase the number of replicas of our application. We'll ignore the fact that we should probably create a HorizontalPodAutoscaler and simply increase the `replicaCount` value in `values.yaml` from `1` to `3`.

Given that I want to make it easy for you, we'll execute a command that will make a change instead of asking you to open the `value.yaml` file in your favorite editor and update it manually.

```bash
cat charts/go-demo-6/values.yaml \
    | sed -e \
    's@replicaCount: 1@replicaCount: 3@g' \
    | tee charts/go-demo-6/values.yaml
```

We'll need to make another set of changes. The reason will become apparent later. For now, please note that the tests have a hard-coded `http://` followed with a variable that is used to specify the IP or the domain. As you'll see soon, we'll fetch a fully qualified address so we'll need to remove `http://` from the tests.

```bash
cat functional_test.go \
    | sed -e \
    's@fmt.Sprintf("http://@fmt.Sprintf("@g' \
    | tee functional_test.go

cat production_test.go \
    | sed -e \
    's@fmt.Sprintf("http://@fmt.Sprintf("@g' \
    | tee production_test.go
```

Now that we fixed the problem with the tests and increased the number of replicas (even though that was not necessary for the examples we'll run), we can proceed and start extending our out-of-the-box pipeline.

As it is now, the pipeline inherited from the build pack does not contain validations. It does almost everything else we need it to do except to run tests. We'll start with unit tests.

Where should we add unit tests? We need to choose the pipeline, the lifecycle, and the mode. Typically, this would be the moment when I'd need to explain in greater detail the syntax of the new pipeline format. Given that it would be a lengthy process, we'll add the step first, and explain what we did.

```bash
echo "buildPack: go
pipelineConfig:
  pipelines:
    pullRequest:
      build:
        preSteps:
        - command: make unittest" \
    | tee jenkins-x.yml
```

What did we do?

 Unit tests should probably be executed when we create a pull request, so we defined a step inside the `pullrequest` pipeline. It could have been `release` or `feature` as well. We already explored under which conditions each of those are executed.

Each time a pipeline is executed, it goes through a series of lifecycles. The `setup` lifecycle prepares the pipeline environment, `setversion` configures the version of the release, `prebuild` prepares the environment for the build steps, `build` builds the binaries and other artifacts, `postbuild` is usually used for additional validations like security scanning, and, finally, `promote` executes the process of installing the release to one or more environments.

In most cases, running unit tests does not require compilation nor a live application, so we can execute them early. The right moment is probably just before we build the binaries. That might compel you to think that we should select the `prebuild` lifecycle assuming that building is done in the `build` phase. That would be true only if we would be choosing the lifecycle we want to replace. While that is possible as well, we'll opt for extending one of the phases. So, please defined our step inside the `build`.

We already commented that we want to extend the existing `build` lifecycle, so we chose to use `preSteps` mode. There are others, and we'll discuss them later. The `preSteps` mode will add a new step before those in the `build` lifecycle inherited from the build pack. That way, our unit tests will run before we build the artifacts.

The last entry is the `command` that will be executed as a step. It will run `make unittest`.

That's it. We added a new step to our `jenkins-x.yml`.

Let's see what we got.

```bash
cat jenkins-x.yml
```

The output is as follows.

```yaml
buildPack: go
pipelineConfig:
  pipelines:
    pullRequest:
      build:
        preSteps:
        - command: make unittest
```

We can see that the `buildPack: go` is still there so our pipeline will continue doing whatever is defined in that build pack. Below is the `pipelineConfig` section that, in this context, extends the one defined in build pack. The `agent` is empty (`{}`), so it will continue using the agent defined in the build pack.

The `pipelines` section extends the `build` lifecycle of the `pullRequest` pipeline. By specifying `preStep`, we know that it will execute `make unittest` before any of the out-of-the-box steps defined in the same lifecycle.

Now that we extended our pipeline, we'll push the changes to GitHub, create a pull request, and observe the outcome.

```bash
git add .

git commit \
    --message "Trying to extend the pipeline"

git push --set-upstream origin extension

jx create pullrequest \
    --title "Extensions" \
    --body "What I can say?" \
    --batch-mode
```

The last command created a pull request, and the address should be in the output. We'll put that URL together with the name of the branch into environment variables since we'll need them later.

W> Please replace the first `[...]` with the full address of the pull request (e.g., https://github.com/vfarcic/go-demo-6/pull/56) and the second with `PR-[PR_ID]` (e.g., PR-56). You can extract the ID from the last segment of the pull request address.

```bash
PR_ADDR=[...] # e.g., `https://github.com/vfarcic/go-demo-6/pull/56`

BRANCH=[...] # e.g., `PR-56`
```

The easiest way to deduce whether our extended pipeline works correctly is through logs.

```bash
jx get build logs \
    --filter go-demo-6 \
    --branch $BRANCH
```

If you get the `error: no Tekton pipelines have been triggered which match the current filter` message, you were probably too fast, and the pipeline did not yet start running. In that case, wait for a few moments and re-execute the `jx get build logs` command.

The output is too big to be presented here. What matters is the part that follows.

```
...
=== RUN   TestMainUnitTestSuite
=== RUN   TestMainUnitTestSuite/Test_HelloServer_Waits_WhenDelayIsPresent
=== RUN   TestMainUnitTestSuite/Test_HelloServer_WritesHelloWorld
=== RUN   TestMainUnitTestSuite/Test_HelloServer_WritesNokEventually
=== RUN   TestMainUnitTestSuite/Test_HelloServer_WritesOk
=== RUN   TestMainUnitTestSuite/Test_PersonServer_InvokesUpsertId_WhenPutPerson
=== RUN   TestMainUnitTestSuite/Test_PersonServer_Panics_WhenFindReturnsError
=== RUN   TestMainUnitTestSuite/Test_PersonServer_Panics_WhenUpsertIdReturnsError
=== RUN   TestMainUnitTestSuite/Test_PersonServer_WritesPeople
=== RUN   TestMainUnitTestSuite/Test_RunServer_InvokesListenAndServe
=== RUN   TestMainUnitTestSuite/Test_SetupMetrics_InitializesHistogram
--- PASS: TestMainUnitTestSuite (0.01s)
    --- PASS: TestMainUnitTestSuite/Test_HelloServer_Waits_WhenDelayIsPresent (0.00s)
    --- PASS: TestMainUnitTestSuite/Test_HelloServer_WritesHelloWorld (0.00s)
    --- PASS: TestMainUnitTestSuite/Test_HelloServer_WritesNokEventually (0.00s)
    --- PASS: TestMainUnitTestSuite/Test_HelloServer_WritesOk (0.00s)
    --- PASS: TestMainUnitTestSuite/Test_PersonServer_InvokesUpsertId_WhenPutPerson (0.00s)
    --- PASS: TestMainUnitTestSuite/Test_PersonServer_Panics_WhenFindReturnsError (0.00s)
    --- PASS: TestMainUnitTestSuite/Test_PersonServer_Panics_WhenUpsertIdReturnsError (0.00s)
    --- PASS: TestMainUnitTestSuite/Test_PersonServer_WritesPeople (0.00s)
    --- PASS: TestMainUnitTestSuite/Test_RunServer_InvokesListenAndServe (0.00s)
    --- PASS: TestMainUnitTestSuite/Test_SetupMetrics_InitializesHistogram (0.00s)
PASS
ok      go-demo-6       0.011s
...
```

We can see that our unit tests are indeed executed.

In our context, what truly matters is the output after the tests. It shows that the application binary and container images were built. That proves that the new step did not replace anything, but that it was added among those defined in the build pack. Since we specified the mode as part of `preSteps`, it was added before the existing steps in the `build` lifecycle.

As I'm sure you already know, unit tests are often not enough and we should add some form of tests against the live application. We should probably add functional tests to the pipeline. But, before we do that, we need to create one more target in the Makefile.

W> Remember what we said before about `Makefile`. It expects tabs as indentation. Please make sure that the command that follows is indeed using tabs and not spaces, if you're typing the commands instead of copying and pasting from the Gist.

```bash
echo 'functest: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) \\
	test -test.v --run FunctionalTest \\
	--cover
' | tee -a Makefile
```

Now we can add the `functest`  target to the `pullrequest` pipeline. But, before we do that, we need to decide when is the best moment to run them. Since they require a new release to be installed, and we already know from the past experience that installations and upgrades are performed through promotions, we should already have an idea where to put them. So, we'll add functional tests to the `pullrequest` pipeline, into the `promote` lifecycle, and with the `post` mode. That way, those tests will run after the promotion is finished, and our release based on the PR is up-and-running.

But, there is a problem that we need to solve or, to be more precise, there is an improvement we could do.

Functional tests need to know the address of the application under tests. Since each pull request is deployed into its own namespace and the app is exposed through a dynamically created address, we need to figure out how to retrieve that URL. Fortunately, there is a command that allows us to retrieve the address of the current pull request. The bad news is that we cannot (easily) run it locally, so you'll need to trust me when I say that `jx get preview --current` will return the full address of the PR deployed with the `jx preview` command executed as the last step in the `promote` lifecycle of the `pullrequest` pipeline.

Having all that in mind, the command we will execute is as follows.

```bash
echo '      promote:
        steps:
        - command: ADDRESS=`jx get preview --current 2>&1` make functest' | \
    tee -a jenkins-x.yml
```

Just as before, the output confirms that `jenkins-x.yml` was updated, so let's take a peek at how it looks now.

```bash
cat jenkins-x.yml
```

The output is as follows.

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

As you can see, the new step follows the same pattern. It is defined inside the `pullRequest` pipeline as the `promote` lifecycle and inside the `steps` mode. You can easily conclude that `preSteps` are executed before those defined in the same lifecycle of the build pack, and `steps` are running after.

Now, let's push the change before we confirm that everything works as expected.

```bash
git add .

git commit \
    --message "Trying to extend the pipeline"

git push
```

Please wait for a few moments until the new pipeline run starts, before we retrieve the logs.

```bash
jx get build logs \
    --filter go-demo-6 \
    --branch $BRANCH
```

You should be presented with a choice of pipeline runs. The choices should be as follows.

```
> vfarcic/go-demo-6/PR-64 #2 serverless-jenkins
  vfarcic/go-demo-6/PR-64 #1 serverless-jenkins
```

If you do not see the new run, please cancel the command with *ctrl+c*, wait for a while longer, and re-execute the `jx get build logs` command. 

The result of the functional tests should be near the bottom of the output. You should see something similar to the output that follows.

```
...
CGO_ENABLED=0 GO15VENDOREXPERIMENT=1 go \
test -test.v --run FunctionalTest \
--cover
=== RUN   TestFunctionalTestSuite
=== RUN   TestFunctionalTestSuite/Test_Hello_ReturnsStatus200
2019/04/26 10:58:31 Sending a request to http://go-demo-6.jx-vfarcic-go-demo-6-pr-57.34.74.193.252.nip.io/demo/hello
=== RUN   TestFunctionalTestSuite/Test_Person_ReturnsStatus200
2019/04/26 10:58:31 Sending a request to http://go-demo-6.jx-vfarcic-go-demo-6-pr-57.34.74.193.252.nip.io/demo/person
--- PASS: TestFunctionalTestSuite (0.26s)
    --- PASS: TestFunctionalTestSuite/Test_Hello_ReturnsStatus200 (0.13s)
    --- PASS: TestFunctionalTestSuite/Test_Person_ReturnsStatus200 (0.13s)
PASS
coverage: 1.4% of statements
ok      go-demo-6       0.271s
```

While we are still exploring the basics of extending build pack pipelines, we might just as well take a quick look at what happens if a pipeline run fails. Instead of deliberately introducing a bug in the code of the application, we'll add another round of tests, but this time in a way that will certainly fail.

```bash
echo '        - command: ADDRESS=http://this-domain-does-not-exist.com make functest' | \
    tee -a jenkins-x.yml
```

As you can see, we added the execution of the same tests. The only difference is that the address of the application under test is now `http://this-domain-does-not-exist.com`. That will surely fail and allow us to see what happens when something goes wrong.

Let's push the changes.

```bash
git add .

git commit \
    --message "Added sully tests"

git push
```

Just as before, we need to wait for a few moments until the new pipeline run starts, before we retrieve the logs.

```bash
jx get build logs \
    --filter go-demo-6 \
    --branch $BRANCH
```

If the previous run was `#2`, you should be presented with a choice to select run `#3`. Please do so.

At the very bottom of the output, you should see that the pipeline run failed. That should not be a surprise since we specified an address that does not exist. We wanted it to fail, but not so that we can see that in logs. Instead, the goal is to see how we would be notified that something went wrong.

Let's see what we get if we open pull request in GitHub.

```bash
open "$PR_ADDR"
```

We can see the whole history of everything that happened to that pull request, including the last comment that states that the `serverless-jenkins` test failed. Later on, we'll explore how to run multiple pipelines in parallel. For now, it might be important to note that GitHub does not know which specific test failed, but that it treats the entire pipeline as a single unit. Nevertheless, it is recorded in GitHub that there is an issue. Its own notification mechanism should send emails to all interested parties, and we can see from the logs what went wrong. Later on we'll explore the new UI designed specifically for Jenkins X. For now, we can get all the information we need without it.

You will also notice that the comment states that we can re-run tests by writing `/retest` or `/test this` as a comment. That's how we can re-execute the same pipeline in case a failure is not due to a "real" problem but caused by flaky tests or some temporary issue.

W> At the time of this writing (May 2019) `/retest` and `/test this` commands do not yet work. But that does not mean that it doesn't by the time you're reading this, so please try it out.

![Figure 13-1: A pull request with failed tests](images/ch13/prow-failed.png)

Before we move into the next subject, we'll remove the step with the silly test that always fails, and leave the repository in a good state.

```bash
cat jenkins-x.yml \
  | sed '$ d' \
  | tee jenkins-x.yml

git add .

git commit \
    --message "Removed the silly test"

git push
```

The first command removed the last line from `jenkins-x.yml`, and the rest is the "standard" `push` to GitHub.

Now that our repository is back into the "working" state, we should explore the last available mode.

We used the `pre` mode to inject steps before those inherited from a build pack. Similarly, we saw that we can inject them after using the `post` mode. If we'd like to replace all the steps from a build pack lifecycle, we could select the `replace` mode. There's probably no need to go through an exercise that would show that in action since the process is the same as for any other mode. The only difference is in what is added to `jenkins-x.yml`.

Before you start replacing lifecycles, be aware that you'd need to redo them completely. If, for example, you replace the steps in the `build` lifecycle, you'd need to make sure that you are implementing all the steps required to build your application. We rarely do that since Jenkins X build packs come with sane defaults and those are seldom removed. Nevertheless, there are cases when we do NOT want what Jenkins X offers and we might wish to reimplement a complete lifecycle by specifying steps through the `replace` mode.

Now that we added unit and functional tests, we should probably add some kind of integration tests as well.

## Extending Environment Pipelines

We could add integration tests in pipelines of our applications, but that's probably not the right place. The idea behind integration tests is to validate whether the system is integrated (hence the name). So, pipelines used to deploy to environments are probably better candidates for such tests. We already did a similar change with the static Jenkins X by modifying Jenkinsfile in staging and production repositories. Let's see how we can accomplish a similar effect through the new format introduced in serverless Jenkins X.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

git clone \
    https://github.com/$GH_USER/environment-jx-rocks-staging.git

cd environment-jx-rocks-staging
```

We cloned the `environment-jx-rocks-staging` repository that contains the always-up-to-date definition of our staging environment. Let's take a look at the `jenkins-x.yml` file that controls the processes executed whenever a change is pushed to that repo.

```bash
cat jenkins-x.yml
```

The output is as follows.

```yaml
env:
- name: DEPLOY_NAMESPACE
  value: jx-staging
pipelineConfig:
  agent: {}
  env:
  - name: DEPLOY_NAMESPACE
    value: jx-staging
  pipelines: {}
```

This pipeline might be a bit confusing since there is no equivalent to `buildPack: go` we saw before. On the one hand, the pipeline is too short to be a full representation of the processes that result in deployments to the staging environment. On the other, there is no indication that this pipeline extends a pipeline from a buildpack. A pipeline is indeed inherited from a buildpack, but that is hidden by Jenkins X "magic" that, in my opinion, is not intuitive.

When that pipeline is executed, it will run whatever is defined in the build pack `environment`. Let's take a look at the details.

```bash
curl https://raw.githubusercontent.com/jenkins-x-buildpacks/jenkins-x-kubernetes/master/packs/environment/pipeline.yaml
```

```yaml
extends:
  import: classic
  file: pipeline.yaml
agent:
  label: jenkins-go
  container: gcr.io/jenkinsxio/builder-go
pipelines:
  release:
    build:
      steps:
        - dir: env
          steps:
            - sh: jx step helm apply
              name: helm-apply

  pullRequest:
    build:
      steps:
        - dir: env
          steps:
            - sh: jx step helm build
              name: helm-build
```

That should be familiar. It is functionally the same as environment pipelines we explored before when we used Jenkinsfile. Just as with the `go` buildpack, it extends a common `pipeline.yaml` located in the root of the `jenkins-x-classic` repository. The "classic" pipeline is performing common operations like checking out the code during the `setup` lifecycle, as well as some cleanup at the end of pipeline runs. If you're interested in details, please visit the [jenkins-x-buildpacks/jenkins-x-classic](https://github.com/jenkins-x-buildpacks/jenkins-x-classic) repository and open `packs/pipeline.yaml`.

If we go back to the `curl` output, we can see that there are only two steps. The first is running in the `build` lifecycle of the `release` pipeline. It applies the chart to the environment specified in the variable `DEPLOY_NAMESPACE`. The second step `jx step helm build` that is actually used to lint the chart and confirm that it is syntactically correct. That step is also executed during the `build` lifecycle but inside the `pullRequest` pipeline.

If our mission is to add integration tests, they should probably run after the application is deployed to an environment. That means that we should add a step to the `release` pipeline and that it must run after the current build step that executes `jx step helm apply`. We could add a new step as a `post` mode of the `build` lifecycle, or we can use any other lifecycle executed after `build`. In any case, the only important thing is that our integration tests run after the deployment performed during the `build` lifecycle. To make things more interesting, we'll choose the `postbuild` lifecycle.

Please execute the command that follows.

```bash
cat jenkins-x.yml \
    | sed -e \
    's@pipelines: {}@pipelines:\
    release:\
      postBuild:\
        steps:\
        - command: echo "Running integ tests!!!"@g' \
    | tee jenkins-x.yml
```

As you can see, we won't run "real" tests, but simulate them through a simple `echo`. Our goal is to explore serverless Jenkins X pipelines and not to dive into testing, so I believe that a simple message like that one should be enough.

Now that we added a new step we can take a look at what we got.

```bash
cat jenkins-x.yml
```

The output is as follows.

```yaml
env:
- name: DEPLOY_NAMESPACE
  value: jx-staging
pipelineConfig:
  env:
  - name: DEPLOY_NAMESPACE
    value: jx-staging
  pipelines:
    release:
      postBuild:
        steps:
        - command: echo "Running integ tests!!!"
```

As you can see, the `pipelines` section was expanded to include our new step following the same pattern as the one we saw when we extended the *go-demo-6* pipeline.

All that's left is to push the change before we confirm that everything works as expected.

```bash
git add .

git commit \
    --message "Added integ tests"

git push
```

Just as before, we need to wait for a few moments until the new pipeline run starts, before we can retrieve the logs.

```bash
jx get build logs \
    --filter environment-jx-rocks-staging \
    --branch master
```

You should be presented with a choice which run to select. If the new one is present (e.g., `#3`), please select it. Otherwise, wait for a few moments more and repeat the `jx get build logs` command.

The last line of the output should display the message `Running integ tests!!!`, thus confirming that the change to the staging environment pipeline works as expected.

That's it. We created a PR that run unit and functional tests, and now we also have (a simulation of) integration tests that will be executed every time anything is deployed to the staging environment. If that would be "real" application with "real" tests, our next action should be to approve the pull request and let the system to the rest.

```bash
open "$PR_ADDR"
```

Feel free to go down the "correct" route of adding a colleague to the `OWNERS` file in the *master* branch and to the collaborators list. After you're done, let the colleague write a comment with a slash command `/approve` or `/lgtm`. We already did those things in the previous chapter so you should know the drill. Or, you can be lazy (as I am), and just skip all that and click the *Merge pull request* button. Since the purpose of this chapter is not to explore ChatOps, you'll be forgiven for taking a shortcut.

When you're done merging the PR to the master branch, please click the *Delete branch* button in GitHub's pull request screen. There's no need to keep it any longer.

## What Now?

Now you need to decide whether to continue using the cluster or to destroy it. If you choose to destroy it or to uninstall Jenkins X, you'll find the instructions at the bottom of the Gist you chose at the beginning of this chapter.

If you destroyed the cluster or you uninstalled Jenkins X, please remove the repositories and the local files we created. You can use the commands that follow for that.

W> Please replace `[...]` with your GitHub user before executing the commands that follow.

```bash
cd ..

GH_USER=[...]

hub delete -y \
  $GH_USER/environment-jx-rocks-staging

hub delete -y \
  $GH_USER/environment-jx-rocks-production

rm -rf ~/.jx/environments/$GH_USER/environment-jx-rocks-*

rm -rf environment-jx-rocks-staging
```
