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
