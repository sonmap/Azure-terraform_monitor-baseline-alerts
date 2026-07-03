output "metric_alert_ids" {
  description = "Metric alert resource IDs."
  value = merge(
    { for k, v in azurerm_monitor_metric_alert.disk_consumed_percent : k => v.id },
    var.enable_cpu_metric_alert ? { cpu = azurerm_monitor_metric_alert.cpu[0].id } : {},
    var.enable_memory_platform_alert && var.total_memory_mb != null ? { available_memory = azurerm_monitor_metric_alert.available_memory[0].id } : {}
  )
}

output "scheduled_query_alert_ids" {
  description = "Scheduled query alert resource IDs."
  value       = { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.vm_insights : k => v.id }
}
