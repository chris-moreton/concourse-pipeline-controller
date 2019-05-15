# Prerequisites and How to Get Them

To use the opinionated pipeline initialiser, you will need:

* A Concourse Server
* A CredHub Server
* The Fly CLI
* The CredHub CLI

## Setup Concourse and CredHub

I recommend using [Control Tower](https://github.com/EngineerBetter/control-tower) to setup Concourse and CredHub.

## Setting the Pipeline Initialiser pipeline itself

To bootstrap the pipeline initialiser, you need to run:

    CONCOURSE_SERVER=https://concourse.example.com CONCOURSE_ADMIN_PASSWORD=[YOUR_PASSWORD_HERE] sh devops/concourse/init-me.sh
  
## Setting credentials

Set the following CredHub secrets

    /concourse/main/pipeline-initialiser/AWS_SECRET_ACCESS_KEY
    /concourse/main/pipeline-initialiser/AWS_ACCESS_KEY_ID
    /concourse/main/pipeline-initialiser/CONCOURSE_ADMIN_PASSWORD