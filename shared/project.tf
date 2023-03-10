terraform {
  required_providers {
    octopusdeploy = { source = "OctopusDeployLabs/octopusdeploy", version = "0.10.1" }
  }
}

provider "octopusdeploy" {
  address  = "${var.octopus_server}"
  api_key  = "${var.octopus_apikey}"
  space_id = "${var.octopus_space_id}"
}

resource "octopusdeploy_maven_feed" "sales_maven_feed" {
  download_attempts              = 10
  download_retry_backoff_seconds = 20
  feed_uri                       = "https://octopus-sales-public-maven-repo.s3.ap-southeast-2.amazonaws.com/snapshot"
  name                           = "Sales Maven Feed"
}


resource "octopusdeploy_library_variable_set" "library_variable_set_octopub" {
  name        = "Octopub"
  description = ""
}

resource "octopusdeploy_variable" "library_variable_set_octopub_aws_account_0" {
  owner_id     = "${octopusdeploy_library_variable_set.library_variable_set_octopub.id}"
  value        = "${octopusdeploy_aws_account.account_aws_account.id}"
  name         = "AWS.Account"
  type         = "AmazonWebServicesAccount"
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

resource "octopusdeploy_environment" "environment_development" {
  name                         = "Development"
  description                  = "An environment for the development team."
  allow_dynamic_infrastructure = true
  use_guided_failure           = false
  sort_order                   = 0

  jira_extension_settings {
    environment_type = "unmapped"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = false
  }
}

resource "octopusdeploy_environment" "environment_production" {
  name                         = "Production"
  description                  = "The production environment."
  allow_dynamic_infrastructure = true
  use_guided_failure           = false
  sort_order                   = 0

  jira_extension_settings {
    environment_type = "unmapped"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = false
  }
}

resource "octopusdeploy_aws_account" "account_aws_account" {
  name                              = "AWS Account"
  description                       = ""
  environments                      = []
  tenant_tags                       = []
  tenants                           = null
  tenanted_deployment_participation = "Untenanted"
  access_key                        = "${var.account_aws_account_access}"
  secret_key                        = "${var.account_aws_account}"
}
variable "account_aws_account" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The AWS secret key associated with the account AWS Account"
}
variable "account_aws_account_access" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The AWS access key associated with the account AWS Account"
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

