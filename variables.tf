variable "location" {
  type        = string
  description = "Azure region used by scheduled query alert resources."
  default     = "koreacentral"
}

variable "alert_resource_group_name" {
  type        = string
  description = "Resource group where Azure Monitor alert rules will be created."
}

variable "vm_resource_id" {
  type        = string
  description = "Target Azure VM resource ID."
}

variable "vm_name" {
  type        = string
  description = "Target VM name. Used for alert rule naming."
}

variable "action_group_ids" {
  type        = list(string)
  description = "Existing Azure Monitor Action Group resource IDs to attach to alerts."
  default     = []
}

variable "cpu_threshold_percent" {
  type        = number
  description = "CPU threshold percentage. Requested default: 10."
  default     = 10
}

variable "memory_used_threshold_percent" {
  type        = number
  description = "Memory used threshold percentage. The platform alert converts this to Available Memory Bytes."
  default     = 5
}

variable "disk_consumed_threshold_percent" {
  type        = number
  description = "Disk consumed threshold percentage for Azure VM disk IOPS/Bandwidth consumed metrics."
  default     = 5
}

variable "total_memory_mb" {
  type        = number
  description = "VM total memory in MB. Required when enable_memory_platform_alert is true."
  default     = null
  nullable    = true
}

variable "enable_cpu_metric_alert" {
  type        = bool
  description = "Create Percentage CPU platform metric alert."
  default     = true
}

variable "enable_memory_platform_alert" {
  type        = bool
  description = "Create Available Memory Bytes platform metric alert. Requires total_memory_mb."
  default     = true
}

variable "enable_disk_metric_alerts" {
  type        = bool
  description = "Create Azure VM disk consumed percentage platform metric alerts."
  default     = true
}

variable "enable_vm_insights_log_alerts" {
  type        = bool
  description = "Create VM Insights scheduled query alerts for OS-level memory/filesystem percentages."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace resource ID. Required when enable_vm_insights_log_alerts is true."
  default     = null
  nullable    = true
}
