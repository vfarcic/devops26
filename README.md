# Idea

Developer Productivity at large, holistic.

## Concepts

### Core

Tagline: People, Process & Technology, the holy triangle of any (tech) work.

ps. these are stupid title's, but I think it gives an idea

PART I: Why you can't buy DevOps
* Where should productivity be sought
    * What is productivity?
    * What should we be productive in?
    * How do you measure productivity?
* Digital transformation (or however you want to call it) involves People, Process, Technology
    * demonstrate this with some in-depth examples
* Centralization & Control kills productivity
    * automation + decentralization can save it (how? see later)

PART II: Its about people
* Never automate without re-evaluate 
    * why is a process/practice there, what does it serve in the Goal of the company?
* Improving your productivity is like dieiting, if you want to lose weight fast you can cut off an arm, but you'll still be prone to cardiac arrest
    * learn new behavior gradually, evolve your processes, let your people learn
    * these new behaviors can be reinforced with technical practices
    * but if you learn to eat more McDonalds even faster it might still be on the fast track to an early grave
* What technical practices are ***proven*** to be beneficial? (think State of DevOps)
    * How do you implement them?
    * What are different aspects that come into play?
    * commoditization of tasks/roles (think Cloud VM's)
    * democratization of high-tech solutions (think Kubernetes)

PART III: How to help people in their technical jobs
* How do you support the benefical practices with technology? (this would be the big)
    * base concepts: CI, CD, CDP, Infrastructure as Code, GitOps, Immutable Infrastructure, Centers Of Excellence, Shared Services teams
* conceptual decisions:
    * central vs. decentral
    * T-shaped skilling, E-shaped skilling
    * platformization
* scenario based explanations:
    * startup in cloud
    * large org with silos
    * smb with some legacy some new

### Total Cost

* Total Cost of Ownership
    * Runtime cost
        * average runtime cost
        * peak runtime cost
    * Development cost
    * Maintenance cost

The total cost of ownership of any software is incredibly complex.

There many ways in which you categorize the different kinds of costs. Such as development cost and maintenance cost.

In this case, I will split the costs into three categories: development, maintenance, and runtime. 

Development: the cost of creating the initial release, changing features and creating new features.
Maintenance: I see maintenance as having to spend time and energy on keeping the software running as it should, without changing the *intended* functional use.
Runtime: The software runs somewhere, be that a custom data center, a managed Kubernetes cluster or as a Function in a Serverless/FaaS solution. It consumes data and perhaps other services, such as Sentry, PagerDuty, storage services, license costs, etc..

These three interact with each other in complicated ways. To avoid license costs, we can build our custom implementation of some algorithm, but that will increase development cost and is likely to increase maintenance cost as well. 

You can cut down on development cost by not writing any tests and ship it. This practice is likely to increase maintenance and runtime costs. That might sound bad, but if the software is out there to prove that people want to *pay* for this, it might be acceptable, as any effort spent on software no one is using is 100% wasted. Whereas rewriting software later to compensate for lack of initial quality is only partially lost time.

Another thing that pops into my mind is the on-going discussion about Serverless. Take Java, for example; we've had many different ways of running Java applications at scale. One big clustered Application Server (think WebLogic, WebSphere, JBoss), a collection of lightweight application servers (Tomcat, TomEE), in Docker containers and now Serverless. The cost of the JVM runtime itself in these equations is challenging to measure. In Containers or serverless, it is likely we pay more for resources for several runtimes which are isolated from each other. But these might reduce the cost of Development - only a single JVM in Tomcat is easier to work with -  and maintenance due to more isolated runtimes - more entities, but each much simpler.

ToDo:
* find out any existing research on this
* find out if there is any research that has any (statistical) significant ways of reducing overall costs one could apply
* find out good resources which dive into this problem
* come up with advice on how to deal with these complexities

### Lower level concepts

* Human biology / psychology
    * attention span & residue
    * multi-tasking
    * "deep work"
    * thinking fast & slow
* Human groups
    * Conway's law
    * Open Floor Plans
    * Basics of Innovation (Innovation vs. Creativity)
    * Psychological Safety (Google Re:Work)
* Commoditization of work
    * Undifferentiated Heavy Lifting
    * Automating humans jobs away (note: )
* Centralization vs. Decentralization
* Grow vs. Build vs. Buy
* Cost of Delay
* Effectiveness vs. Efficiency
    * Theory of constraints
* Dangers of Automation

## References

### Books

### Papers

### Blog posts

### Software

#### SonarQube

* pick a solid database you can upgrade at least every x months as the data store
* don't scan branches unless there's a special reason
* as much as possible, use the appropriate language-specific build tools to do the analysis
    * provide ample examples of how to add the analysis to your pipeline specific to your language
* give internal demonstrations/training on what it does and helps you with
* don't use it as a build breaker, more like keeping tabs on trends
    * for current codebase status, make sure developers can scan on their own machine with IDE plugins/CLI
* create expert groups for creating & maintaining language specific rulesets & profiles
    * establish a process for managing false positives
* if you want to report with aggregates, buy the plugin from SonarSource
    * comes with a great API for managing separate groups/levels with auto-matching for project id's
    * if you want high-level aggregate reporting with your own key statistics, use the API's
