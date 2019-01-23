# Preface

TODO: Rewrite

Kubernetes is probably the biggest project we know. It is vast, and yet many think that after a few weeks or months of reading and practice they know all there is to know about it. It's much bigger than that, and it is growing faster than most of us can follow. How far did you get in Kubernetes adoption?

From my experience, there are four main phases in Kubernetes adoption.

In the first phase, we create a cluster and learn intricacies of Kube API and different types of resources (e.g., Pods, Ingress, Deployments, StatefulSets, and so on). Once we are comfortable with the way Kubernetes works, we start deploying and managing our applications. By the end of this phase, we can shout "**look at me, I have things running in my production Kubernetes cluster, and nothing blew up!**" I explained most of this phase in [The DevOps 2.3 Toolkit: Kubernetes](https://amzn.to/2GvzDjy).

The second phase is often automation. Once we become comfortable with how Kubernetes works and we are running production loads, we can move to automation. We often adopt some form of continuous delivery (CD) or continuous deployment (CDP). We create Pods with the tools we need, we build our software and container images, we run tests, and we deploy to production. When we're finished, most of our processes are automated, and we do not perform manual deployments to Kubernetes anymore. We can say that **things are working and I'm not even touching my keyboard**. I did my best to provide some insights into CD and CDP with Kubernetes in [The DevOps 2.4 Toolkit: Continuous Deployment To Kubernetes](https://amzn.to/2NkIiVi).

The third phase is in many cases related to monitoring, alerting, logging, and scaling. The fact that we can run (almost) anything in Kubernetes and that it will do its best to make it fault tolerant and highly available, does not mean that our applications and clusters are bulletproof. We need to monitor the cluster, and we need alerts that will notify us of potential issues. When we do discover that there is a problem, we need to be able to query metrics and logs of the whole system. We can fix an issue only once we know what the root cause is. In highly dynamic distributed systems like Kubernetes, that is not as easy as it looks.

Further on, we need to learn how to scale (and de-scale) everything. The number of Pods of an application should change over time to accommodate fluctuations in traffic and demand. Nodes should scale as well to fulfill the needs of our applications.

Kubernetes already has the tools that provide metrics and visibility into logs. It allows us to create auto-scaling rules. Yet, we might discover that Kuberentes alone is not enough and that we might need to extend our system with additional processes and tools. This phase is the subject of this book. By the time you finish reading it, you'll be able to say that **your clusters and applications are truly dynamic and resilient and that they require minimal manual involvement. We'll try to make our system self-adaptive.**

I mentioned the fourth phase. That, dear reader, is everything else. The last phase is mostly about keeping up with all the other goodies Kubernetes provides. It's about following its roadmap and adapting our processes to get the benefits of each new release.

Eventually, you might get stuck and will be in need of help. Or you might want to write a review or comment on the book's content. Please join the [DevOps20](http://slack.devops20toolkit.com/) Slack workspace and post your thoughts, ask questions, or participate in a discussion. If you prefer a more one-on-one communication, you can use Slack to send me a private message or send an email to viktor@farcic.com. All the books I wrote are very dear to me, and I want you to have a good experience reading them. Part of that experience is the option to reach out to me. Don't be shy.

Please note that this one, just as the previous books, is self-published. I believe that having no intermediaries between the writer and the reader is the best way to go. It allows me to write faster, update the book more frequently, and have more direct communication with you. Your feedback is part of the process. No matter whether you purchased the book while only a few or all chapters were written, the idea is that it will never be truly finished. As time passes, it will require updates so that it is aligned with the change in technology or processes. When possible, I will try to keep it up to date and release updates whenever that makes sense. Eventually, things might change so much that updates are not a good option anymore, and that will be a sign that a whole new book is required. **I will keep writing as long as I continue getting your support.**

# Overview

TODO: Rewrite

We'll explore some of the skills and knowledge required for operating Kubernetes clusters. We'll deal with subjects that are often not studied at the very beginning but only after we get bored with Kubernetes' core features like Pod, ReplicaSets, Deployments, Ingress, PersistentVolumes, and so on. We'll master subjects we often dive into after we learn the basics and after we automate all the processes. We'll explore **monitoring**, **alerting**, **logging**, **auto-scaling**, and other subjects aimed at making our cluster **resilient**, **self-sufficient**, and **self-adaptive**.

# About the Author

Viktor Farcic is a Developer Advocate at [CloudBees](https://www.cloudbees.com/), a member of the [Docker Captains](https://www.docker.com/community/docker-captains) group, and author.

He coded using a plethora of languages starting with Pascal (yes, he is old), Basic (before it got Visual prefix), ASP (before it got .Net suffix), C, C++, Perl, Python, ASP.Net, Visual Basic, C#, JavaScript, Java, Scala, etc. He never worked with Fortran. His current favorite is Go.

His big passions are containers, distributed systems, microservices, continuous delivery and deployment (CD) and test-driven development (TDD).

He often speaks at community gatherings and conferences.

He wrote [The DevOps Toolkit Series](http://www.devopstoolkitseries.com/) and [Test-Driven Java Development](https://www.packtpub.com/application-development/test-driven-java-development).

His random thoughts and tutorials can be found in his blog [TechnologyConversations.com](https://technologyconversations.com/).

# Dedication

To Sara, the only person that truly matters in this world.

# Audience

TODO: Rewrite

I assume that you are familiar with Kubernetes and that there is no need to explain how Kube API works, nor the difference between master and worker nodes, and especially not resources and constructs like Pods, Ingress, Deployments, StatefulSets, ServiceAccounts, and so on. If that is not you, this content might be too advanced, and I recommend you go through [The DevOps 2.3 Toolkit: Kubernetes](https://amzn.to/2GvzDjy) first. I hope that you are already a Kubernetes ninja apprentice, and you are interested in how to make your cluster more resilient, scalable, and self-adaptive. If that's the case, this is the book for you. Read on.

# Requirements

TODO: Rewrite

The book assumes that you already know how to operate a Kubernetes cluster so we won't go into details how to create one nor we'll explore Pods, Deployments, StatefulSets, and other commonly used Kubernetes resources. If that assumption is not correct, you might want to read [The DevOps 2.3 Toolkit: Kubernetes](https://amzn.to/2GvzDjy) first.

Apart from assumptions based on knowledge, there are some technical requirements as well. If you are a **Windows user**, please run all the examples from **Git Bash**. It will allow you to run the same commands as MacOS and Linux users do through their terminals. Git Bash is set up during [Git](https://git-scm.com/download/win) installation. If you don't have it already, please re-run Git setup.

Since we'll use a Kubernetes cluster, we'll need **[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)**. Most of the applications we'll run inside the cluster will be installed using **[Helm](https://helm.sh/)**, so please make sure that you have the client installed as well. Finally, install **[jq](https://stedolan.github.io/jq/)** as well. It's a tool that helps us format and filter JSON output.

Finally, we'll need a Kubernetes cluster. All the examples are tested using **Docker for Desktop**, **minikube**, **Google Kubernetes Engine (GKE)**, **Amazon Elastic Container Service for Kubernetes (EKS)**, and **Azure Kubernetes Service (AKS)**. I will provide requirements (e.g., number of nodes, CPU, memory, Ingress, etc.) for each of those Kubernetes flavors.

You're free to apply the lessons to any of the tested Kubernetes platforms, or you might choose to use a different one. There is no good reason why the examples from this book shouldn't work in every Kubernetes flavor. You might need to tweak them here and there, but I'm confident that won't be a problem. If you run into any issue, please contact me through the [DevOps20 slack workspace](http://slack.devops20toolkit.com) or by sending me an email to viktor@farcic.com. I'll do my best to help out. If you do use a Kuberentes cluster other then one of those I tested, I'd appreciate your help in expanding the list.

Before you select a Kubernetes flavor, you should know that not all the features will be available everywhere. In case of local clusters based on **Docker for Desktop** or **minikube**, scaling nodes will not be possible since both are single-node clusters. Other clusters might not be able to use more specific features. I'll use this opportunity to compare different platforms and give you additional insights you might want to use if you're evaluating which Kubernetes distribution to use and where to host it. Or, you can choose to run some chapters with a local cluster and switch to a multi-node cluster only for the parts that do not work in local. That way you'll save a few bucks by having a cluster in Cloud for very short periods.

If you're unsure which Kubernetes flavor to select, choose GKE. It is currently the most advanced and feature-rich managed Kubernetes on the market. On the other hand, if you're already used to EKS or AKS, they are, more or less, OK as well. Most, if not all of the things featured in this book will work. Finally, you might prefer to run a cluster locally, or you're using a different (probably on-prem) Kubernetes platform. In that case, you'll learn what you're missing and which things you'll need to build on top of "standard offerings" to accomplish the same result.
