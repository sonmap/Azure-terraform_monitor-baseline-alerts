output "metric_alert_ids" {
  description = "Metric alert resource IDs."
  value       = module.vm_baseline_alerts.metric_alert_ids
}

output "scheduled_query_alert_ids" {
  description = "Scheduled query alert resource IDs."
  value       = module.vm_baseline_alerts.scheduled_query_alert_ids
}
