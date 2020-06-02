resource "azurerm_log_analytics_workspace" "state" {
  name                = data.azurerm_storage_account.state.name
  resource_group_name = data.azurerm_resource_group.state.name
  location            = data.azurerm_resource_group.state.location
  tags                = data.azurerm_resource_group.state.tags


  sku               = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_monitor_diagnostic_setting" "state" {
  name                       = "key_vault"
  target_resource_id         = azurerm_key_vault.state.id
  storage_account_id         = data.azurerm_storage_account.state.id
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
