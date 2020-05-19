resource "azurerm_log_analytics_workspace" "state" {
  name                = local.terraform_uniq
  location            = azurerm_resource_group.state.location
  resource_group_name = azurerm_resource_group.state.name
  tags                = azurerm_resource_group.state.tags

  sku               = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_monitor_diagnostic_setting" "state" {
  name                       = "key_vault"
  target_resource_id         = azurerm_key_vault.state.id
  storage_account_id         = azurerm_storage_account.state.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.state.id


  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 28
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}
