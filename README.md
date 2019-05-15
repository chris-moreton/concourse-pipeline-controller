# Concourse Pipeline Initialiser

This is a Concourse pipeline that scans specified Git code repositories for updates to pipeline configurations. When an update is detected, the new pipeline configuration is applied and the first job in the pipeline is triggered.

This allows developers working on the specified Git repositories to manage the pipeline without needing to install anything on their local machines.

It also enforeces a consistency of pipeline configuration across projects.

If you wish to set this up on your own Concourse server, following the instructions starting at **Setting the pipeline**

## Configure the pipeline

To cause a repository to be included in the scans, update the repositories.yml file and create a pull request. Once the pull request
is merged into master, your project will be scanned for new commits. When a new commit is found, the pipeline configuration will first
be updated with any new changes and then the ***build*** job from the pipeline will be triggered.

## Configure your project

## Setting the pipeline

    CONCOURSE_SERVER=https://concourse.example.com CONCOURSE_ADMIN_PASSWORD=xxxx sh devops/concourse/init-me.sh
  
## Setting credentials

Set the following CredHub secrets

    /concourse/main/concourse/AWS_SECRET_ACCESS_KEY
    /concourse/main/concourse/AWS_ACCESS_KEY_ID
    /concourse/main/concourse/CONCOURSE_ADMIN_PASSWORD

  


