variable "location" {
  type    = string
  default = "koreacentral"
}

variable "alert_resource_group_name" {
  type = string
}

variable "vm_resource_id" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "total_memory_mb" {
  type = number
}

variable "action_group_ids" {
  type    = list(string)
  default = []
}

variable "enable_vm_insights_log_alerts" {
  type    = bool
  default = false
}

variable "log_analytics_workspace_id" {
  type     = string
  default  = null
  nullable = true
}
