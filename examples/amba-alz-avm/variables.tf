variable "location" {
  type    = string
  default = "koreacentral"
}

variable "management_subscription_id" {
  type        = string
  description = "Management subscription ID. Leave empty to use current Azure CLI subscription."
  default     = ""
}

variable "root_management_group_name" {
  type        = string
  description = "Root management group name for AMBA ALZ policy assignments."
  default     = "alz"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where AMBA managed identity/action resources are deployed."
  default     = "rg-amba-monitoring-001"
}

variable "user_assigned_managed_identity_name" {
  type    = string
  default = "id-amba-prod-001"
}

variable "action_group_email" {
  type        = list(string)
  description = "Email receivers for AMBA action group."
  default     = []
}

variable "amba_disable_tag_name" {
  type    = string
  default = "MonitorDisable"
}

variable "amba_disable_tag_values" {
  type    = list(string)
  default = ["true", "Test", "Dev", "Sandbox"]
}

variable "amba_library_ref" {
  type        = string
  description = "AMBA library reference used by Azure/alz provider."
  default     = "2026.06.2"
}

variable "amba_module_version" {
  type    = string
  default = "0.1.1"
}

variable "alz_module_version" {
  type    = string
  default = "0.21.0"
}

variable "tags" {
  type = map(string)
  default = {
    _deployed_by_amba = true
  }
}
