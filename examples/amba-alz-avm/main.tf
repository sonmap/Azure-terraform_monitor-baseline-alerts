terraform {
  required_version = "~> 1.9"

  required_providers {
    alz = {
      source  = "Azure/alz"
      version = "~> 0.21.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.2"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

data "azapi_client_config" "current" {}

provider "alz" {
  library_references = [{
    path = "platform/amba"
    ref  = var.amba_library_ref
  }]
}

provider "azurerm" {
  alias           = "management"
  subscription_id = var.management_subscription_id != "" ? var.management_subscription_id : data.azapi_client_config.current.subscription_id
  features {}
}

module "amba_alz" {
  source  = "Azure/avm-ptn-monitoring-amba-alz/azurerm"
  version = var.amba_module_version

  providers = {
    azurerm = azurerm.management
  }

  location                            = var.location
  root_management_group_name          = var.root_management_group_name
  resource_group_name                 = var.resource_group_name
  tags                                = var.tags
  user_assigned_managed_identity_name = var.user_assigned_managed_identity_name
}

module "amba_policy" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = var.alz_module_version

  architecture_name               = "amba"
  location                        = var.location
  parent_resource_id              = data.azapi_client_config.current.tenant_id
  policy_assignments_dependencies = [module.amba_alz.user_assigned_managed_identity_resource_id]

  policy_default_values = {
    amba_alz_management_subscription_id          = jsonencode({ value = var.management_subscription_id != "" ? var.management_subscription_id : data.azapi_client_config.current.subscription_id })
    amba_alz_resource_group_location             = jsonencode({ value = var.location })
    amba_alz_resource_group_name                 = jsonencode({ value = var.resource_group_name })
    amba_alz_resource_group_tags                 = jsonencode({ value = var.tags })
    amba_alz_user_assigned_managed_identity_name = jsonencode({ value = var.user_assigned_managed_identity_name })
    amba_alz_disable_tag_name                    = jsonencode({ value = var.amba_disable_tag_name })
    amba_alz_disable_tag_values                  = jsonencode({ value = var.amba_disable_tag_values })
    amba_alz_action_group_email                  = jsonencode({ value = var.action_group_email })
    amba_alz_sha_action_group_resources          = jsonencode({
      value = {
        actionGroupEmail = var.action_group_email
      }
    })
  }
}
