provider "azurerm" {
  features {}
}

module "vm_baseline_alerts" {
  source = "./modules/vm-baseline-alerts"

  location                  = var.location
  alert_resource_group_name = var.alert_resource_group_name
  vm_resource_id            = var.vm_resource_id
  vm_name                   = var.vm_name

  action_group_ids = var.action_group_ids

  cpu_threshold_percent           = var.cpu_threshold_percent
  memory_used_threshold_percent   = var.memory_used_threshold_percent
  disk_consumed_threshold_percent = var.disk_consumed_threshold_percent

  total_memory_mb = var.total_memory_mb

  enable_cpu_metric_alert       = var.enable_cpu_metric_alert
  enable_memory_platform_alert  = var.enable_memory_platform_alert
  enable_disk_metric_alerts     = var.enable_disk_metric_alerts
  enable_vm_insights_log_alerts = var.enable_vm_insights_log_alerts

  log_analytics_workspace_id = var.log_analytics_workspace_id
}
