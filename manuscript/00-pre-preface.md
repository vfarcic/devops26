# The Next Chapter In The SDLC Tool Chain Evolution

To understand Jenkins X better, we'll start by exploring the (recent) history of building and deploying software. For the sake of brevity, we will not go all the way back to writing software on punch cards. Instead, we'll start at the advent of Jenkins that rose to prominence in the late 00s as Hudson the build server of choice within the Java community.

Hudson solved a growing need for a reliable, consistent and programmable way of building and testing software. In many organizations, it formed the heart of an emerging system, the Software Development Lifecycle processes and toolchain that accompany them.

As software started eating the world, companies began to rely on this toolchain for more and more of their core business success. As the reliance grew, so did the dependence on this toolchain to provide more information than "green build" or "red build". To accommodate this need for more information, the number of tools in the toolchain grew. Test tools, static code analysis, security testing, and lint tools are only a few of the types that emerged.

Once we understood that the quality of code can be measured and that we can design gates that will present us from moving further, we turned our attention to deployment. The more the of the steps proceeding it were automated, the more our focus shifted to the deployment. As a result, many organizations moved from continuous integration (CI) that deals mostly with building and partial testing, to continuous delivery (CD) that adds the latter parts of the software development lifecycle. As a result, continuous delivery tries to define and automate the whole lifecycle of an application, from a commit to a code repository, all the way until a new release is deployed to production. 

NOTE: The sentence that follows sounds like it's not part of the previous (or the next text) paragraph. It's as if a new thought started but did not finish. The paragraph that follows does not speak about the challenge "to integrate well with other tools".
This is the first challenge, the tools need to integrate well with other tools.

With the increase in adoption of CI/CD, the race for "delivering more software faster" started. Soon it becomes obvious that the key was in collaboration. As a result, tools that facilitate it sprouted like mushrooms. The are ranging from ticket and project management systems extending their use cases to brand new Kanban issue trackers. However, significant hurdles had to be overcome for these trackers to provide insight into which issue was related to what changes. In most cases, it is still very much dependant on hygiene and discipline, which is often in short supply when under time pressure. 

NOTE: Is that the challenge from the sentence that follows described in the previous or the next paragraph?
The next challenge, provide a consistent audit trail between changes and the reason for the change - preferably a business reason.

More people used the tools in the SDLC toolchain, and close collaboration with short cycles became the norm via Agile, Scrum, Kanban and the like. This put significant stress on software tools, requiring them to scale, not only vertically but, along with other movements in the industry, to scale horizontally. Needless to say, not every tool survived the transition well. 

NOTE: I think that I only now understood that the flow is "describe a situation, and finish with stating the chalenge." Is that the case? If it is, maybe it would make sense to change it to the other way around. Or, even better, to rephrase those sentences (like that one that follows). Paragraphs are a kind of narrative (that is great, I love it), but they end with a bulletpoint-like statements about a challenge. Maybe the issue is with mixing different styles (narrative vs bullet points)?
This is another challenge; horizontal scaling.

NOTE: The first sentence in the next paragraph is not finishing the tought. It's as if there should be a comma (,) instead of a dot (.) at the end of it.
NOTE: What is CISO?
The mass movement to "digitally transform" any and all organization - eaten by software - with most cases by Agile methodologies. Created several changes, including moving from a siloed corner of the organization to a strategic asset permeating through all departments. This put any tool firmly within the scope of the CISO department, challenging each tool's security profile. 

NOTE: That paragraph contains again abrupt change from a narrative to the bulletpoint-style "challenge".
The move to the strategic asset also created another challenge. Any tool required to make changes in production is now also part of the production environment. This means that those tools cannot go down, that they require rigid and thorough changes to processes, and so on. Another two challenges found, tools need to be High Available or Decentralized - to ensure high uptime - and should support (near) zero downtime upgrades and updates.

We're not done yet. More challenges await! Just as the Operations world moved from vertical scaling to horizontal scaling, there were some other changes in expectations of software systems. Infrastructure As Code, preferably combined with Immutable Infrastructure forces our tools to be configurable out of the box via configuration files or API's. Any tool struggling with this will find itself struggling to survive. 

NOTE: "No more clicking together Build, Test and Deploy jobs via a UI"? Do you mean that jobs should not be created in UIs by clicking on buttons or that we should not join together build test and deploy jobs? Or both? 
NOTE: "- configuration as code". Sounds confusing. That part maybe deserves a sentence on its own?
NOTE: "And the number of times I've heard "why can't we just use one tool?" has been staggering." Is that a new tought subject? If it is, maybe a new paragraph might make sense. It's confusing since it sounds like you are still talking about everything-as-code.
On the development side of things - you know, the Dev in DevOps - expectations of tools have also changed. No more clicking together Build, Test and Deploy jobs via a UI. As everything turns to code, so has the CI/CD Pipeline. The workflow has to be reproducible, sharable and ideally it shouldn't require any separate configuration in the tool that executes it - configuration as code. And the number of times I've heard "why can't we just use one tool?" has been staggering. Although people are not really suggesting that one tool should do all of the things we've covered, people expect to be able to interact with something that can manage it for them, glue everything together so-to-speak. That's a pretty hefty challenge right there.

Tight integrations with our favorite other tools are also expected, no developer aimed tool is complete without at least some IDE integrations (e.g., Visual Studio Code). And if the pipeline is building sources from GitHub, it is expected to manage the webhooks and events that come with it. 

Many of these challenges were insurmountable in the past for organizations except for the likes of Google, Microsoft, Facebook and the like. But the democritization of software services through Open Source and Public Initiatives have brought these within the reach of most organizations. Yet, why waste time and resources on building it yourself, if you can consume it directly? Many organizations have struggled with building the same kind of SDLC toolchain and ended up reinventing the wheel. The time is ripe for the light at the end of the tunnel, for suites of SDLC toolchains to bring you all the power the tech giants have had, without having to build it yourself.

### Challenges Summarized

NOTE: The statement that Jenkins X "can help you tackle most if not all of them with great ease" should probably come after the points, not before. Also, statements like that usually come at the end of the intro/history. Yuo start from the past (you did), and end with the present or the future. The reason I'm mentioning that is because the bullet points and especially the next sub-chapter ("Anatomy Of The New Chain") look like they do not belong there, but above. It's as if you closed the story (chapter) with that sentence, only to reopen it in the middle right after it.
To summarize the challenges we discovered here is a list of challenges an SDLC toolchain must tackle this day and age. And as we will see, Jenkins X can help you tackle most if not all of them with great ease.

NOTE: The list that follows is not the "summary" of the challenges since some of them were not mentioned before. For example, I don't recall "can recreate the environment from a source definition" being described before. At least, there is no "recreate" anywhere in the text.

1. scale the toolchain to fit demand
1. track all the changes going on within the SDLC toolchain
1. simplify deployment across platforms/languages/frameworks
1. include infrastructure/platform in the CI cycle of the application
1. every tool must be automatable from scratch with either an API or (preferred) declarative configuration
1. only take resources when being used (ScaleToZero)
1. can define workflow from beginning to end (programmable/declarative definition)
1. allows the creation of opinionated workflows that allows overrides and enables extensions
1. can recreate the environment from a source definition
1. will enable you to get started right away with delivering applications
1. single API/Interface/CLI to manage workflow
1. supports/integrates with popular development tools

## Anatomy Of The New Chain

Talking about the challenges and how we arrived at them can be a bit abstract. So let us look at what a present-day state of the art of SDLC toolchain might look like.

We'll dissect the model into a few parts. Mind you, while tools might intersect, the idea is to look at the SDLC. So "data" refers to the data produced by the SDLC, not by the applications themselves.

NOTE: What follows is probably cool, but its hard to understand. Explain it first, put it as bullet points later as a way to summarize what you just explained. Or, at least, provide a context for those points (the same applies to the table that comes next).
* **Workflow**: how does a change in SCM end up as it intended effect in the correct environment
* **Telemetry**: we need continuous telemetry about the state of our SDLC toolchain and application landscape. Monitoring, logging, auditing, etc.
* **Artifacts**:  we need to permanently - or at least for an X amount of time - store artifacts generated within the SDLC. Docker images, Java Jar's, Helm Charts, etc.
* **Environments**: we will manage environments via the SDLC as well. With the advent of GitOps, this will be done via X as Code via our Git repository.

### Expectation table

| Component       | Runtime Type  | Storage Type    | Sizing                   |
|--------------    |--------------    |--------------    |----------------------    |
| Workflow           | Event-Based    | Ephemeral        | Predictive Autoscale    |
| Telemetry         | Permanent        | Temporary        | Reactive Autoscale         |
| Artifacts            | Event-Based    | Permanent        | Reactive Autoscale        |
| Environments  | Permanent       | Permanent        | Predictive Autoscale     |

* **Runtime Type**: does the tool or process run always, or should it be reactive, only exist when it is triggered by an event
* **Storage Type**: is there any need to store data, if there is, do we store it until the end of its life (ignoring cleanups/boundaries) or do we merely store it for a fixed time and does it lose it value after it
* **Sizing**: should the scale automatically, and if so, should it be reactive or predictive (as it, "we know there's no builds on Sunday, so Sunday there's 0 build infra)

### GitOps Model

Translating the `Workflow`, `Telemetry`, `Artifacts`, and `Environments` into a model we can come up with something like the model below. It takes all the challenges we've seen, picks up lessons taken from GitHub workflows, GitOps, and the Observability movement to distill a generic picture.

We have the `Telemetry` part on the left, providing our insights. We have our `Artifacts` on the right, the things we've built and want to deploy - else there's no need to keep them. In middle's top, we have our `Workflow`, flowing from our source through our Pipeline and feeding the other three parts. Telemetry flows to the left, produced Artifacts to the right and we create change requests (e.g. via PullRequests) to our GitOps environments in middle bottom. 

![Figure 00-1: GitOps Abstract Model](images/ch00/gitops-model.png)
