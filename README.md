# Netsensia Concourse Pipeline

![Directorzone Pipeline](images/pipeline.png)

A Concourse pipeline that manages the pipelines of other services within the same Concourse instance.

It provides an opinionated pipeline that can be used easily, and extended, in your application.

Java (Gradle) and NodeJS (yarn) applications are supported.

It will build the application and maintain the infrastructure.

It deploys to Cloud Foundry and uses AWS for backend services such as databases and Elasticsearch instances.

The example image shown above shows the core pipeline that has been extended to include several additional jobs, such as the migration of data from a legacy system.

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

You can add your own infrastructure by adding Terraform configurations to your repository. See [Adding  Custom Infrastructure](#AddingInfrastructure).

#### Deploy (AAT)

The deployment step is a [blue/green deployment](https://docs.cloudfoundry.org/devguide/deploy-apps/blue-green.html) to Cloud Foundry which ensures that the new build is ready for use before switching it with the old one. It will also run a smoke test.

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

<a name="AddingServices"/>

#### Adding Services To Your Infrastructure


Full documentation, including how to set up your own pipeline controller, can be found in the [wiki](https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Netsensia-Deployment-Pipeline).

<a name="AddingInfrastructure"/>

#### Adding Custom Infrastructure