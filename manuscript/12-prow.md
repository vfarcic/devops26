## Exploring prow

- [ ] Job execution for testing, batch processing, artifact publishing.
- [ ] GitHub events are used to trigger post-PR-merge (postsubmit) jobs and on-PR-update (presubmit) jobs.
- [ ] Support for multiple execution platforms and source code review sites.
- [ ] Pluggable GitHub bot automation that implements /foo style commands and enforces configured policies/processes.
- [ ] GitHub merge automation with batch testing logic.
- [ ] Front end for viewing jobs, merge queue status, dynamically generated help information, and more.
- [ ] Automatic deployment of source control based config.
- [ ] Automatic GitHub org/repo administration configured in source control.
- [ ] Designed for multi-org scale with dozens of repositories. (The Kubernetes Prow instance uses only 1 GitHub bot token!)
- [ ] High availability as benefit of running on Kubernetes. (replication, load balancing, rolling updates...)
- [ ] JSON structured logs.
- [ ] Prometheus metrics.