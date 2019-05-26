# Netsensia Concourse Pipeline

![Directorzone Pipeline](https://i.ibb.co/2M1sgH3/Screenshot-from-2019-05-21-17-40-22.png)

This is a single-job Concourse pipeline that manages the pipelines of other services within the same Concourse instance.

It provides an opinionated pipeline that can be used, and extended, in your application.

You do not need to have any additional software installed locally to manage your pipeline, and pipeline changes will be
automatically applied before triggering your pipeline.

It will build the application infrastructure, depending upon which configuration values are provided in CredHub. The following infrastructure is used:

---------------------
|Service|Description|
|-------|-----------|
|Cloud Foundry|Applications are deployed to a Cloud Foundry instance, the spaces, applications and services are configured automatically|
|MySQL RDS|If CredHub DB_USER is provided, an RDS instance will be created and attached to your application as a Cloud Foundry service|

Java (Gradle) and NodeJS (yarn) builds are supported - the pipeline will detect the langauge and build and deploy it accordingly.

## Using the Pipeline

At its simplest, a developer need only provide three configuration values (stored in CredHub):

    PRODUCT
    COMPONENT
    
And add a netsensia-pipeline.yml file in the following location

    /devops/netsensia-pipeline.yml

   
Full documentation, including how to set up your own pipeline controller, can be found in the [wiki](https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Netsensia-Deployment-Pipeline).


