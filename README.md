# Concourse Pipeline Controller

## One Job To Control Them All

This is a single-job Concourse pipeline that manages the pipelines of other services within the same Concourse instance.

It scans specified Git code repositories for updates to pipeline configurations. 

When an update is detected, the updated pipeline configuration is applied and the pipeline is triggered.

This allows developers working on the specified Git repositories to manage the pipeline without needing to install anything on their local machines.

It also enforces a consistency of pipeline configuration across projects.

Not in place yet, this controller will also provide common components for pipelines to bring further conistency across projects and to provide out-of-the-box solutions for service developers.

## Setting up Your Own Instance of This Controller

If you already have this controller running with a Concourse instance, you should jump straight to the [Using the Controller](#setup_pipeline_controller) section.

### Prerequisites

To use the opinionated pipeline initialiser, you will need:

* A Concourse Server
* A CredHub Server
* The Fly CLI
* The CredHub CLI

I recommend using [Control Tower](https://github.com/EngineerBetter/control-tower) to setup Concourse and CredHub.

### Setting the Pipeline Initialiser pipeline itself

To set this up on a new Concourse instance, you'll need a fork of this project, as you will need to make changes to the config.yml file and push it to GitHub.

To bootstrap the pipeline initialiser, you need to run:

    cd devops/concourse/
    CONCOURSE_SERVER=https://concourse.example.com CONCOURSE_ADMIN_PASSWORD=[YOUR_PASSWORD_HERE] ./init-me.sh
  
### Setting credentials

Set the following CredHub secrets. They're not all necessarily secret, but this is a simple way to centralise the configuration.
    
     # The password for the Concourse "admin" user
    /concourse/main/pipeline-initialiser/CONCOURSE_ADMIN_PASSWORD  
    
    # The deploy key for this repository - store as the "ssh" type
    /concourse/main/pipeline-initialiser/GITHUB_DEPLOY_KEY         
        
<a name="setup_pipeline_controller"/>

## Using the Controller

## Add Repositories to be Scanned

To cause a repository to be included in the scans, update the devops/concourse/pipeline.yml file and create a pull request.

Once the pull request is merged into master, your project will be scanned for new commits. 

When a new commit is found, the pipeline configuration will first be updated with any new changes and then the ***build*** job from the pipeline will be triggered.
      
For private repositories, you will need to add the correct deploy key to the CredHub location specified in the **deploy_key_credhub_location** field. Public repositories do not need to have this field.

## Configure the Pipeline in your Projects

When you make commits to a repository that is registered with the pipeline controller, your repository will be scanned periodically for changes.

During a scan, the controller will look for a pipeline.yml file.

    devops
        concourse
            pipeline.yml
