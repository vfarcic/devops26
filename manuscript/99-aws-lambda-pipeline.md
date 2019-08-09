## Requirements

* AWS account
* [aws CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* Access keys
* TODO: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html

```bash
export AWS_ACCESS_KEY_ID=[...]

export AWS_SECRET_ACCESS_KEY=[...]

export AWS_DEFAULT_REGION=[...]

aws lambda list-functions
```

## Languages (July 2019)

* .NET Core 2.1 (C#)
* Go 1.x
* Java 8
* Node.js 8.10
* Node.js 10.x
* Python 2.7
* Python 3.6
* Python 3.7
* Ruby 2.5
* Custom runtime

## Limits

* Concurrent executions: 1000 (can be increased)
* Function and layer storage: 75 GB (can be increased)
* Function memory allocation: 128 MB to 3,008 MB, in 64 MB increments.
* Function timeout: 900 seconds (15 minutes)
* Function environment variables: 4 KB
* Function resource-based policy: 20 KB
* Function layers: 5 layers
* Invocation frequency (requests per second):
  * 10 x concurrent executions limit (synchronous – all sources)
  * 10 x concurrent executions limit (asynchronous – non-AWS sources)
  * Unlimited (asynchronous – AWS service sources)
* Invocation payload (request and response):
  * 6 MB (synchronous)
  * 256 KB (asynchronous)
* Deployment package size:
  * 50 MB (zipped, for direct upload)
  * 250 MB (unzipped, including layers)
  * 3 MB (console editor)
* Test events (console editor): 10
* /tmp directory storage: 512 MB
* File descriptors: 1024
* Execution processes/threads: 1024

## Standalone function

TODO: Code

## Function with a network storage

TODO: Code

## Function with a DB

TODO: Code

## Communication with other functions

TODO: Code

## Communication with other applications

TODO: Code

## Logging

TODO: Code

## CD

TODO: Code