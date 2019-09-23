# Netsensia Opinionated Pipeline

![Core Pipeline](images/pipeline.png)

A Concourse pipeline that creates and manages pipelines for other projects.

By adding your project to [repositories.yml](https://github.com/chris-moreton/concourse-pipeline-controller/blob/master/repositories.yml), a pipeline will be created that will:

* Build infrastructure for testing and production environments
* Carry out unit and integration tests
* Perform blue/green deployments with smoke tests
* Determine the environment variables from a vault
* Detect the application framework and deploy accordingly (currently it supports Java, NodeJS and PHP)

## Before You Start

The following are assumed:

* Your organisation has a Concourse instance, set up to run the Opinionated Pipeline. The Netsensia Concourse instance is at https://concourse.wonderpath.com.

If this is not the case, you can read about how to set up the Opinionated Pipeline in the wiki under [Creating Your Own Pipeline Controller](https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Creating-Your-Own-Pipeline-Controller).

## Using the Pipeline Controller

An application will consist of a PRODUCT and COMPONENT. The product is the overarching system or company name, e.g. "directorzone". The component is the name of the service within the PRODUCT, e.g. "api" or "frontend".

Your repository must be named:

    <product>-<component>

e.g.

    directorzone-api

This must be the name of your GitHub repository.

##### Deployment Key

If your project is not open source, you will need to add a deployment key to your repository. Store the key in the following location in CredHub. See [Adding Secrets to CredHub](<https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Adding-Secrets-To-CredHub>) in the wiki for more details on this.

It may be easier to get someone who has the necessary tools installed and/or knows the credentials to authenticate against CredHub.

```
/concourse/<product>/<component>/GITHUB_DEPLOY_KEY
```

Don't forget to add the deploy key to your repository on your git provider, i.e. GitHub or BitBucket.

##### Setting Environment Variables

To set environment variables for your application, add them to CredHub at the following locations:

```
concourse/product/component/aat/env
concourse/product/component/prod/env
```

Example:

```
credhub set -n concourse/directorzone/api/aat/env/PEXELS_AUTH --type value --value ABCDEFG123456
```

##### Set GitHub Owner and Token


```
credhub set -n concourse/directorzone/GITHUB_API_TOKEN --type value --value ****
credhub set -n concourse/directorzone/GITHUB_OWNER --type value --value chris-moreton
```

##### Set AWS Access Keys


```
credhub set -n concourse/directorzone/AWS_ACCESS_KEY_ID --type value --value ****
credhub set -n concourse/directorzone/AWS_SECRET_ACCESS_KEY --type value --value ****
```

##### Choose Services

Services are enabled per component.

```
credhub set -n concourse/directorzone/api/services/MYSQL --type value --value 1
credhub set -n concourse/directorzone/api/services/ELASTIC_SEARCH --type value --value 0
```

Services must be enabled using the ENABLE setting:

```
credhub set -n concourse/directorzone/api/services/ENABLE --type value --value 1
```

##### Add Your Application

Update [repositories.yml](https://github.com/chris-moreton/concourse-pipeline-controller/blob/master/repositories.yml) to include your project.

Create a pull request, and when your PR is merged, your project will now be included in the pipeline and run through the following steps.

Within a few minutes, a pipeline will be created for your application with the following stages:

##### Update Teams

In teams.yml, you will need to give ownership of your repository to the admin user amongst the rest of your team configuration, e.g.

    - name: directorzone
      config:
        roles:
        - name: pipeline-operator
          github:
            users: ["twobyte","Directorzone"]
        - name: owner
          local:
            users: ["admin"]
          github:
            users: ["chris-moreton"]

#### Build

This will build and package your application. Your unit tests will be executed in this step.

| Project Type | Build Command                |
| ------------ | ---------------------------- |
| Java         | ./gradlew build              |
| Node         | npm install && npm run build |

#### Build Infrastructure (AAT)

This first time this stage runs, it will create a Cloud Foundry space for your AAT (automated acceptance testing) environment. It will also create any services that you have requested. See [Adding Services To Your Infrastructure](#AddingServices).

You can add your own infrastructure by adding Terraform configurations to your repository. See [Adding  Custom Infrastructure](#AddingInfrastructure).

#### Deploy (AAT)

The deployment step is a [blue/green deployment](https://docs.cloudfoundry.org/devguide/deploy-apps/blue-green.html) to Cloud Foundry which ensures that the new build is ready for use before switching it with the old one.

##### Smoke Test

After pushing the application to a holding area (blue), it will look for a smoketest file at:

    smoketest/smoketest.sh
    
You can place any commands you like in there. Just ensure that the script returns a zero exit code to indicate success.

#### Functional Tests (AAT)

| Project Type | Test Command         |
| ------------ | -------------------- |
| Java         | ./gradlew functional |
| Node         | yarn test:functional |

#### Build Infrastructure (PROD)

This is where the same infrastructure build for AAT is applied in the PROD environment.

#### Deploy (PROD)

Finally, the application is deployed to production in Cloud Foundry using the same process as the deployment to AAT.

You will be able to look at your deployments using the Cloud Foundry CLI.

Assuming you are logged into the Cloud Foundry instance associated with the pipeline controller, you should see your AAT and PROD environments when you run:

```
cf spaces
```

You should see that two spaces have been created:

```
<product>-aat
<product>-prod
```

You'll noticed that the component is not referenced in the space name. This is because all components within the same product will share the same space.

You can view the applications within the space with:

```
cf target -s <product>-<environment>
cf applications
```

And you can view the services, if any, with:

```
cf services
```

### Adding a Domain Name

Add your domain name in the following location in your CredHub instance:

```
/concourse/<product>/<component>/DOMAIN
```

You also need to add it to the netsensia-infrastructure repository, see [this file for an example](https://github.com/chris-moreton/netsensia-infrastructure/blob/master/terraform/domain_golfingrecord_com.tf).

<a name="ExtendingPipeline"/>

### Extending the Pipeline

This is an example of how the directorzone-api pipeline was extended to include jobs to:

1) Migrate data from a legacy system

2) Move legacy images into an S3 bucket

3) Load test data into AAT

4) Dump and restore data from and into production

![Directorzone Extended Pipeline](images/extended_pipeline.png)

#### Adding Jobs

You can easily add new Concourse jobs to your pipeline which can use resources from the core pipeline as well as their own defined resource.

Simply create the following file:

```
devops/concourse/pipeline.yml
```

And add resource and jobs to it.

In the example below, the pipeline defines a new data-dump resource while also references three resources from the core pipeline.

Behind the scenes, the pipeline controller simply merges the core pipeline with your new resources and jobs, and creates an extended pipeline.


    ---
    resources:
    - name: data-dump
      type: s3
      source:
        bucket: pipeline-controller-dumps
        region_name: eu-west-2
        versioned_file: ((SQL_DUMP_FILENAME)).tar.gz
        access_key_id: ((AWS_ACCESS_KEY_ID))
        secret_access_key: ((AWS_SECRET_ACCESS_KEY))
    jobs:
    - name: restore-database
      public: false
      plan:, e.g.
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


<a name="AddingServices"/>

#### Adding Services To Your Infrastructure


Full documentation, including how to set up your own pipeline controller, can be found in the [wiki](https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Netsensia-Deployment-Pipeline).

<a name="AddingInfrastructure"/>

#### Adding Custom Infrastructure

Create the following directory

    devops/terraform
    
Within this directory, add Terraform files prefixed with "custom-", e.g.

    devops/terraform
            |---------- custom-data.tf
                        custom-resource.tf
                        
##### Access to Pipeline Variables

The following variables are available to use:

    ${var.product}
    ${var.component}
    ${var.environment}
    ${cloudfoundry_space.product_space.id}
    
##### Access to CredHub Values
    
You can create a CredHub resource to access values within your project's vault. For example:

    data "credhub_value" "my_secret_value" {
      name = "/concourse/${var.product}/${var.component}/${var.environment}/MY_SECRET_VALUE"
    }
    
    data "credhub_user" "my_secret_user" {
      name = "/concourse/${var.product}/${var.component}/${var.environment}/MY_SECRET_USER"
    }

## Setting Up A Pipeline Controller

To learn more about how a controller can be configured for a GitHub organisation, please see [Creating Your Own Pipeline Controller](<https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Creating-Your-Own-Pipeline-Controller>) in the project wiki.
