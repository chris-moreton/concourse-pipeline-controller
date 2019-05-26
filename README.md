# Netsensia Concourse Pipeline

![Directorzone Pipeline](images/pipeline.png)

A Concourse pipeline that manages the pipelines of other services within the same Concourse instance.

It provides an opinionated pipeline that can be used easily, and extended, in your application.

It will build the application infrastructure, depending upon which configuration values are provided in CredHub. 

It deploys to Cloud Foundry and uses AWS for backend services such as databases and Elasticsearch instances.

Java (Gradle) and NodeJS (yarn) builds are supported - the pipeline will detect the langauge and build and deploy it accordingly.

## Using the Pipeline

The pipeline is fully extendable using Concourse YML configuration.

### The simplest pipeline

An application will consist of a PRODUCT and COMPONENT. The product is the overarching system or company name, e.g. "directorzone". The component is the name of the service within the PRODUCT, e.g. "api" or "frontend".

Your repository must be named:

    product-component

e.g.

    directorzone-api

Update the repositories.yml file to include your project.

Create a pull request, and when your PR is merged, your project will now be included in the pipeline and run through the following steps.

#### Build

This will build and package your application. Your unit tests will be executed in this step.

| Project Type | Build Command   |
| ------------ | --------------- |
| Java         | ./gradlew build |
| Node         | yarn build      |

#### Build Infrastructure (AAT)

This first time this stage runs, it will create a Cloud Foundry space for your AAT (automated acceptance testing) environment. It will also create any services that you have requested. See [Adding Services To Your Infrastructure](#AddingServices).

You can add your own infrastructure by adding Terraform configurations to your repository. See [Adding  Custom Infrastructure](#AddingInfrastructure)

3) Deploy (AAT)
4) Build Infrastructure (PROD)
5) Deploy (PROD)

### Extending the Pipeline

<a href="#AddingServices"/>

#### Adding Services To Your Infrastructure


Full documentation, including how to set up your own pipeline controller, can be found in the [wiki](https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Netsensia-Deployment-Pipeline).

#### Adding Custom Infrastructure