# AWS Lambda Deployment with Octopus

This repo holds three sample Terraform projects using the [Octopus Terraform provider](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/latest/docs)
to build twi Octopus projects:

* API Gateway - which builds a shared API Gateway that Lambdas are attached to
* Backend Service - A sample REST API backend Lambda exposed via API Gateway

## Applying the Terraform configuration

Each of the three Terraform projects is applied in order to build the API Gateway and Lambda deployment projects.

### Applying the shared configuration

The first step is to apply the Terraform configuration representing shared Octopus resources like library variable sets,
accounts, feeds, and environments. You must define the value of the following variables:

* `octopus_server` is the URL of your Octopus instance.
* `octopus_apikey` is an [API key](https://octopus.com/docs/octopus-rest-api/how-to-create-an-api-key) used to interact with the Octopus instance.
* `octopus_space_id` is the ID of the [space](https://octopus.com/docs/administration/spaces) that the Terraform configuration is applied to.

Run the following commands to initialize and apply the shared Terraform configuration:

```bash
cd shared
terraform init
terraform apply \
  -var=octopus_server=http://yourinstancegoeshere.octopus.app \
  -var=octopus_apikey=API-YOURAPIKEYGOESHERE \
  -var=octopus_space_id=Spaces-1
```

### Applying the API Gateway project configuration

Run the following commands to initialize and apply the API Gateway Terraform configuration:

```bash
cd apigateway
terraform init
terraform apply \
  -var=octopus_server=http://yourinstancegoeshere.octopus.app \
  -var=octopus_apikey=API-YOURAPIKEYGOESHERE \
  -var=octopus_space_id=Spaces-1
```

### Applying the Lambda project configuration

Run the following commands to initialize and apply the API Gateway Terraform configuration:

```bash
cd backend
terraform init
terraform apply \
  -var=octopus_server=http://yourinstancegoeshere.octopus.app \
  -var=octopus_apikey=API-YOURAPIKEYGOESHERE \
  -var=octopus_space_id=Spaces-1
```