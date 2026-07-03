locals {
  alert_prefix = var.alert_name_prefix != "" ? var.alert_name_prefix : var.vm_name

  available_memory_threshold_bytes = var.total_memory_mb == null ? null : floor(var.total_memory_mb * 1024 * 1024 * (100 - var.memory_used_threshold_percent) / 100)

  disk_metric_alerts = {
    os_disk_iops = {
      name        = "osdisk-iops-consumed-over"
      metric_name = "OS Disk IOPS Consumed Percentage"
    }
    os_disk_bandwidth = {
      name        = "osdisk-bandwidth-consumed-over"
      metric_name = "OS Disk Bandwidth Consumed Percentage"
    }
    data_disk_iops = {
      name        = "datadisk-iops-consumed-over"
      metric_name = "Data Disk IOPS Consumed Percentage"
    }
    data_disk_bandwidth = {
      name        = "datadisk-bandwidth-consumed-over"
      metric_name = "Data Disk Bandwidth Consumed Percentage"
    }
  }

  active_disk_metric_alerts = var.enable_disk_metric_alerts ? local.disk_metric_alerts : {}

  vm_insights_log_alerts = {
    memory_available_percent = {
      name        = "memory-available-under"
      operator    = "LessThan"
      threshold   = 100 - var.memory_used_threshold_percent
      description = "VM Insights memory used is greater than ${var.memory_used_threshold_percent}%."
      query       = <<-KQL
        InsightsMetrics
        | where Origin == "vm.azm.ms"
        | where Namespace == "Memory" and Name == "AvailableMB"
        | where _ResourceId =~ "${var.vm_resource_id}"
        | extend TotalMemory = toreal(todynamic(Tags)["vm.azm.ms/memorySizeMB"])
        | extend AvailableMemoryPercentage = (toreal(Val) / TotalMemory) * 100.0
        | summarize AggregatedValue = avg(AvailableMemoryPercentage) by bin(TimeGenerated, 15m), Computer, _ResourceId
      KQL
      dimensions = {
        Computer = ["*"]
      }
    }
    os_disk_free_percent = {
      name        = "osdisk-free-under"
      operator    = "LessThan"
      threshold   = 100 - var.disk_consumed_threshold_percent
      description = "VM Insights OS disk used is greater than ${var.disk_consumed_threshold_percent}%."
      query       = <<-KQL
        InsightsMetrics
        | where Origin == "vm.azm.ms"
        | where Namespace == "LogicalDisk" and Name == "FreeSpacePercentage"
        | where _ResourceId =~ "${var.vm_resource_id}"
        | extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])
        | where Disk in ("C:", "/")
        | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, Disk
      KQL
      dimensions = {
        Computer = ["*"]
        Disk     = ["*"]
      }
    }
    data_disk_free_percent = {
      name        = "datadisk-free-under"
      operator    = "LessThan"
      threshold   = 100 - var.disk_consumed_threshold_percent
      description = "VM Insights data disk used is greater than ${var.disk_consumed_threshold_percent}%."
      query       = <<-KQL
        InsightsMetrics
        | where Origin == "vm.azm.ms"
        | where Namespace == "LogicalDisk" and Name == "FreeSpacePercentage"
        | where _ResourceId =~ "${var.vm_resource_id}"
        | extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])
        | where Disk !in ("C:", "/")
        | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, Disk
      KQL
      dimensions = {
        Computer = ["*"]
        Disk     = ["*"]
      }
    }
  }

  active_vm_insights_log_alerts = var.enable_vm_insights_log_alerts ? local.vm_insights_log_alerts : {}
}

resource "azurerm_monitor_metric_alert" "cpu" {
  count = var.enable_cpu_metric_alert ? 1 : 0

  name                = "${local.alert_prefix}-cpu-over-${var.cpu_threshold_percent}"
  resource_group_name = var.alert_resource_group_name
  scopes              = [var.vm_resource_id]
  description         = "AMBA-style VM CPU alert. Average Percentage CPU greater than ${var.cpu_threshold_percent}%."
  severity            = var.severity
  frequency           = var.metric_evaluation_frequency
  window_size         = var.metric_window_size
  enabled             = true
  auto_mitigate       = var.auto_mitigate

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold_percent
  }

  dynamic "action" {
    for_each = toset(var.action_group_ids)
    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_metric_alert" "available_memory" {
  count = var.enable_memory_platform_alert && var.total_memory_mb != null ? 1 : 0

  name                = "${local.alert_prefix}-memory-used-over-${var.memory_used_threshold_percent}"
  resource_group_name = var.alert_resource_group_name
  scopes              = [var.vm_resource_id]
  description         = "AMBA-style VM memory alert. Used memory greater than ${var.memory_used_threshold_percent}% by Available Memory Bytes calculation."
  severity            = var.severity
  frequency           = var.metric_evaluation_frequency
  window_size         = var.metric_window_size
  enabled             = true
  auto_mitigate       = var.auto_mitigate

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = local.available_memory_threshold_bytes
  }

  dynamic "action" {
    for_each = toset(var.action_group_ids)
    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_metric_alert" "disk_consumed_percent" {
  for_each = local.active_disk_metric_alerts

  name                = "${local.alert_prefix}-${each.value.name}-${var.disk_consumed_threshold_percent}"
  resource_group_name = var.alert_resource_group_name
  scopes              = [var.vm_resource_id]
  description         = "AMBA-style VM disk consumed metric alert. ${each.value.metric_name} greater than ${var.disk_consumed_threshold_percent}%."
  severity            = var.severity
  frequency           = "PT1M"
  window_size         = "PT1M"
  enabled             = true
  auto_mitigate       = var.auto_mitigate

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = each.value.metric_name
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.disk_consumed_threshold_percent
  }

  dynamic "action" {
    for_each = toset(var.action_group_ids)
    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "vm_insights" {
  for_each = local.active_vm_insights_log_alerts

  name                    = "${local.alert_prefix}-${each.value.name}-${each.value.threshold}"
  resource_group_name     = var.alert_resource_group_name
  location                = var.location
  scopes                  = [var.log_analytics_workspace_id]
  description             = each.value.description
  severity                = var.severity
  enabled                 = true
  evaluation_frequency    = var.log_evaluation_frequency
  window_duration         = var.log_window_duration
  auto_mitigation_enabled = var.auto_mitigate

  criteria {
    query                   = each.value.query
    time_aggregation_method = "Average"
    operator                = each.value.operator
    threshold               = each.value.threshold
    metric_measure_column   = "AggregatedValue"
    resource_id_column      = "_ResourceId"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }

    dynamic "dimension" {
      for_each = each.value.dimensions
      content {
        name     = dimension.key
        operator = "Include"
        values   = dimension.value
      }
    }
  }

  dynamic "action" {
    for_each = length(var.action_group_ids) > 0 ? [1] : []
    content {
      action_groups = var.action_group_ids
    }
  }
}
