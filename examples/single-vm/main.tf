terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "vm_baseline_alerts" {
  source = "../../modules/vm-baseline-alerts"

  location                  = var.location
  alert_resource_group_name = var.alert_resource_group_name
  vm_resource_id            = var.vm_resource_id
  vm_name                   = var.vm_name

  action_group_ids = var.action_group_ids

  cpu_threshold_percent           = 10
  memory_used_threshold_percent   = 5
  disk_consumed_threshold_percent = 5

  total_memory_mb = var.total_memory_mb

  enable_cpu_metric_alert       = true
  enable_memory_platform_alert  = true
  enable_disk_metric_alerts     = true
  enable_vm_insights_log_alerts = var.enable_vm_insights_log_alerts

  log_analytics_workspace_id = var.log_analytics_workspace_id
}

output "metric_alert_ids" {
  value = module.vm_baseline_alerts.metric_alert_ids
}

output "scheduled_query_alert_ids" {
  value = module.vm_baseline_alerts.scheduled_query_alert_ids
}
