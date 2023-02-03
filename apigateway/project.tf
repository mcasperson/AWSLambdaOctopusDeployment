

# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-1508/Accounts | jq -r '.Items[] | select(.Name=="AWS Account") | .Id')
# terraform import octopusdeploy_aws_account.account_aws_account ${RESOURCE_ID}
resource "octopusdeploy_aws_account" "account_aws_account" {
  name                              = "AWS Account"
  description                       = ""
  environments                      = []
  tenant_tags                       = []
  tenants                           = null
  tenanted_deployment_participation = "Untenanted"
  access_key                        = "AKIAZCSFURGBA4TMNQMC"
  secret_key                        = "${var.account_aws_account}"
}
variable "account_aws_account" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The AWS secret key associated with the account AWS Account"
}

# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-1508/LibraryVariableSets | jq -r '.Items[] | select(.Name=="Octopub") | .Id')
# terraform import octopusdeploy_library_variable_set.library_variable_set_octopub ${RESOURCE_ID}
resource "octopusdeploy_library_variable_set" "library_variable_set_octopub" {
  name        = "Octopub"
  description = ""
}

data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  name = "Hosted Ubuntu"
  ids  = null
  skip = 0
  take = 1
}

variable "octopus_server" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The URL of the Octopus server e.g. https://myinstance.octopus.app."
}
variable "octopus_apikey" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The API key used to access the Octopus server. See https://octopus.com/docs/octopus-rest-api/how-to-create-an-api-key for details on creating an API key."
}
variable "octopus_space_id" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The ID of the Octopus space to populate."
}

data "octopusdeploy_environments" "environment_production" {
  ids          = null
  partial_name = "Production"
  skip         = 0
  take         = 1
}

data "octopusdeploy_environments" "environment_development" {
  ids          = null
  partial_name = "Development"
  skip         = 0
  take         = 1
}

# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-1508/Lifecycles | jq -r '.Items[] | select(.Name=="Infrastructure") | .Id')
# terraform import octopusdeploy_lifecycle.lifecycle_infrastructure ${RESOURCE_ID}
resource "octopusdeploy_lifecycle" "lifecycle_infrastructure" {
  name        = "Infrastructure"
  description = "The application lifecycle."

  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${data.octopusdeploy_environments.environment_development.environments[0].id}"]
    name                                  = "Development"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0

    release_retention_policy {
      quantity_to_keep    = 30
      should_keep_forever = false
      unit                = "Days"
    }

    tentacle_retention_policy {
      quantity_to_keep    = 30
      should_keep_forever = false
      unit                = "Days"
    }
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${data.octopusdeploy_environments.environment_production.environments[0].id}"]
    name                                  = "Production"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0

    release_retention_policy {
      quantity_to_keep    = 30
      should_keep_forever = false
      unit                = "Days"
    }

    tentacle_retention_policy {
      quantity_to_keep    = 30
      should_keep_forever = false
      unit                = "Days"
    }
  }

  release_retention_policy {
    quantity_to_keep    = 1
    should_keep_forever = false
    unit                = "Days"
  }

  tentacle_retention_policy {
    quantity_to_keep    = 30
    should_keep_forever = false
    unit                = "Items"
  }
}

# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-1508/ProjectGroups | jq -r '.Items[] | select(.Name=="Infrastructure") | .Id')
# terraform import octopusdeploy_project_group.project_group_infrastructure ${RESOURCE_ID}
resource "octopusdeploy_project_group" "project_group_infrastructure" {
  name        = "Infrastructure"
  description = "Builds the API Gateway."
}

# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-1508/Projects | jq -r '.Items[] | select(.Name=="API Gateway") | .Id')
# terraform import octopusdeploy_project.project_api_gateway ${RESOURCE_ID}
resource "octopusdeploy_project" "project_api_gateway" {
  name                                 = "API Gateway"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  description                          = "Deploys a shared API Gateway. This project is created and managed by the [Octopus Terraform provider](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/latest/docs). The Terraform files can be found in the [GitHub repo](https://github.com/mcasperson/OctopusBuilder-LAM)."
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${octopusdeploy_lifecycle.lifecycle_infrastructure.id}"
  project_group_id                     = "${octopusdeploy_project_group.project_group_infrastructure.id}"
  included_library_variable_sets       = ["${octopusdeploy_library_variable_set.library_variable_set_octopub.id}"]
  tenanted_deployment_participation    = "Untenanted"

  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "SkipUnavailableMachines"
  }
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeployLabs/octopusdeploy", version = "0.10.1" }
  }
}

data "octopusdeploy_channels" "channel_default" {
  ids          = null
  partial_name = "Default"
  skip         = 0
  take         = 1
}

variable "library_variable_set_octopub_aws_region_1" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The value associated with the variable AWS.Region"
  default     = "ap-southeast-2"
}
resource "octopusdeploy_variable" "library_variable_set_octopub_aws_region_1" {
  owner_id     = "${octopusdeploy_library_variable_set.library_variable_set_octopub.id}"
  value        = "${var.library_variable_set_octopub_aws_region_1}"
  name         = "AWS.Region"
  type         = "String"
  description  = ""
  is_sensitive = false

  scope {
    actions      = []
    channels     = []
    environments = []
    machines     = []
    roles        = null
    tenant_tags  = null
  }
  depends_on = []
}

variable "library_variable_set_octopub_aws_cloudformation_apigatewaystack_0" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The value associated with the variable AWS.CloudFormation.ApiGatewayStack"
  default     = "OctopubApiGateway"
}
resource "octopusdeploy_variable" "library_variable_set_octopub_aws_cloudformation_apigatewaystack_0" {
  owner_id     = "${octopusdeploy_library_variable_set.library_variable_set_octopub.id}"
  value        = "${var.library_variable_set_octopub_aws_cloudformation_apigatewaystack_0}"
  name         = "AWS.CloudFormation.ApiGatewayStack"
  type         = "String"
  description  = ""
  is_sensitive = false

  scope {
    actions      = []
    channels     = []
    environments = []
    machines     = []
    roles        = null
    tenant_tags  = null
  }
  depends_on = []
}

variable "api_gateway_aws_account_0" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The value associated with the variable AWS.Account"
  default     = "octopusdeploy_aws_account.account_aws_account"
}
resource "octopusdeploy_variable" "api_gateway_aws_account_0" {
  owner_id     = "${octopusdeploy_project.project_api_gateway.id}"
  value        = "${var.api_gateway_aws_account_0}"
  name         = "AWS.Account"
  type         = "AmazonWebServicesAccount"
  description  = ""
  is_sensitive = false

  scope {
    actions      = []
    channels     = []
    environments = []
    machines     = []
    roles        = null
    tenant_tags  = null
  }
  depends_on = []
}

provider "octopusdeploy" {
  address  = "${var.octopus_server}"
  api_key  = "${var.octopus_apikey}"
  space_id = "${var.octopus_space_id}"
}

resource "octopusdeploy_deployment_process" "deployment_process_project_api_gateway" {
  project_id = "${octopusdeploy_project.project_api_gateway.id}"

  step {
    condition           = "Success"
    name                = "Create API Gateway"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsRunCloudFormation"
      name                               = "Create API Gateway"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Aws.CloudFormation.Tags" = jsonencode([
          {
            "value" = "#{Octopus.Environment.Name | Replace \" .*\" \"\"}"
            "key" = "Environment"
          },
          {
            "key" = "DeploymentProject"
            "value" = "API_Gateway"
          },
        ])
        "Octopus.Action.Aws.CloudFormationTemplateParameters" = jsonencode([])
        "Octopus.Action.Aws.Region" = "#{AWS.Region}"
        "Octopus.Action.Aws.CloudFormationStackName" = "#{AWS.CloudFormation.ApiGatewayStack}"
        "Octopus.Action.Aws.CloudFormationTemplate" = "Resources:\n  RestApi:\n    Type: 'AWS::ApiGateway::RestApi'\n    Properties:\n      Description: My API Gateway\n      Name: Octopus Workflow Builder\n      BinaryMediaTypes:\n        - '*/*'\n      EndpointConfiguration:\n        Types:\n          - REGIONAL\n  Health:\n    Type: 'AWS::ApiGateway::Resource'\n    Properties:\n      RestApiId:\n        Ref: RestApi\n      ParentId:\n        'Fn::GetAtt':\n          - RestApi\n          - RootResourceId\n      PathPart: health\n  Api:\n    Type: 'AWS::ApiGateway::Resource'\n    Properties:\n      RestApiId:\n        Ref: RestApi\n      ParentId:\n        'Fn::GetAtt':\n          - RestApi\n          - RootResourceId\n      PathPart: api\n  Web:\n    Type: 'AWS::ApiGateway::Resource'\n    Properties:\n      RestApiId: !Ref RestApi\n      ParentId: !GetAtt\n        - RestApi\n        - RootResourceId\n      PathPart: '{proxy+}'\nOutputs:\n  RestApi:\n    Description: The REST API\n    Value: !Ref RestApi\n  RootResourceId:\n    Description: ID of the resource exposing the root resource id\n    Value:\n      'Fn::GetAtt':\n        - RestApi\n        - RootResourceId\n  Health:\n    Description: ID of the resource exposing the health endpoints\n    Value: !Ref Health\n  Api:\n    Description: ID of the resource exposing the api endpoint\n    Value: !Ref Api\n  Web:\n    Description: ID of the resource exposing the web app frontend\n    Value: !Ref Web\n"
        "Octopus.Action.Aws.CloudFormationTemplateParametersRaw" = jsonencode([])
        "Octopus.Action.Aws.TemplateSource" = "Inline"
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.AwsAccount.Variable" = "AWS.Account"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []
      features                           = []
    }

    properties   = {}
    target_roles = []
  }
}

