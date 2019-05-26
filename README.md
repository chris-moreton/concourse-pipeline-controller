# Netsensia Concourse Pipeline

You have stumbled across a project which is about 80% complete. This README file may reference things that don't yet exist.

![Core Pipeline](images/pipeline.png)

A Concourse pipeline that manages the pipelines of other services within the same Concourse instance.

It provides an opinionated pipeline that can be enabled for any Java (Gradle) and NodeJS (yarn) application in the same GitHub organisation as the controller is running.

It will build the application and maintain the infrastructure and deploy your application to Cloud Foundry.

It uses AWS for backend services such as databases and Elasticsearch instances.

## Using the Pipeline

The pipeline is fully extendable using Concourse YML configuration.

### The Simplest Pipeline

An application will consist of a PRODUCT and COMPONENT. The product is the overarching system or company name, e.g. "directorzone". The component is the name of the service within the PRODUCT, e.g. "api" or "frontend".

Your repository must be named:

    <product>-<component>

e.g.

    directorzone-api

This must be the name of your GitHub repository.

Update the repositories.yml file to include your project. Included projects must be repositories in the GitHub organisation specified when the pipeline controller was [created](<https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Creating-Your-Own-Pipeline-Controller>).

##### Deployment Key

If your project is not open source, you will need to add a deployment key to your repository. Store the key in the following location in CredHub. See [Adding Secrets to CredHub](<https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Adding-Secrets-To-CredHub>) in the wiki for more details on this.

It may be easier to get someone who has the necessary tools installed and/or knows the credentials to authenticate against CredHub.

```
/concourse/main/<product>-<component>/GITHUB_DEPLOY_KEY
```

Create a pull request, and when your PR is merged, your project will now be included in the pipeline and run through the following steps.

#### Build

This will build and package your application. Your unit tests will be executed in this step.

| Project Type | Build Command   |
| ------------ | --------------- |
| Java         | ./gradlew build |
| Node         | yarn build      |

#### Build Infrastructure (AAT)

This first time this stage runs, it will create a Cloud Foundry space for your AAT (automated acceptance testing) environment. It will also create any services that you have requested. See [Adding Services To Your Infrastructure](#AddingServices).

You can add your own infrastructure by adding Terraform configurations to your repository. See [Adding  Custom Infrastructure](#AddingInfrastructure).

#### Deploy (AAT)

The deployment step is a [blue/green deployment](https://docs.cloudfoundry.org/devguide/deploy-apps/blue-green.html) to Cloud Foundry which ensures that the new build is ready for use before switching it with the old one. It will also run a smoke test.

#### Functional Tests (AAT)

| Project Type | Test Command         |
| ------------ | -------------------- |
| Java         | ./gradlew functional |
| Node         | yarn test:functional |

#### Build Infrastructure (PROD)

This is where the same infrastructure build for AAT is applied in the PROD environment.

#### Deploy (PROD)

Finally, the application is deployed to production in Cloud Foundry.

You will be able to look at your deployments using the Cloud Foundry CLI.

Assuming you are logged into the Cloud Foundry instance associated with the pipeline controller, you should see your AAT and PROD environments when you run:

```
cf spaces
```

You can then target a space with:

```
cf target -s product-aat
```

And view the applications with:

```
cf a
```

And the services, if any, with:

```
cf s
```

### Extending the Pipeline

![Directorzone Extended Pipeline](images/extended_pipeline.png)

#### Adding Jobs

You can easily add new Concourse jobs to your pipeline which can use resources from the core pipeline as well as their own defined resource.

Simple create the following file:

```
devops/concourse/pipeline.yml
```

And add resource and jobs to it.

In the example below, the pipeline defines a new data-dump resource while also references three resources from the core pipeline.

Behind the scenes, the pipeline controller simply merges the core pipeline with your new resources and jobs, and creates an extended pipeline.

```
---
resources:
- name: data-dump
  type: s3
  source:
    bucket: pipeline-controller-dumps
    region_name: eu-west-2
    versioned_file: ((SQL_DUMP_FILENAME)).tar.gz
    access_key_id: ((pipeline-controller/AWS_ACCESS_KEY_ID))
    secret_access_key: ((pipeline-controller/AWS_SECRET_ACCESS_KEY))
jobs:
- name: restore-database
  public: false
  plan:
    - get: packaged-build
      passed:
        - build-infrastructure-prod
      trigger: false
    - get: pipeline-controller
      trigger: false
    - get: source-code
      trigger: false
    - get: data-dump
      trigger: false
    - task: load-data
      file: source-code/devops/concourse/tasks/load-data.yml
      params:
        DB_HOST: ((prod/DB_HOST))
        DB_NAME: ((prod/DB_NAME))
        DB_USER: ((prod/DB_USER.username))
        DB_PASS: ((prod/DB_USER.password))
```

<a name="AddingServices"/>

#### Adding Services To Your Infrastructure


Full documentation, including how to set up your own pipeline controller, can be found in the [wiki](https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Netsensia-Deployment-Pipeline).

<a name="AddingInfrastructure"/>

#### Adding Custom Infrastructure