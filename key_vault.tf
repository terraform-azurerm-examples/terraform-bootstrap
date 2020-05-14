resource "azurerm_key_vault" "state" {
  name                = local.terraform_uniq
  location            = azurerm_resource_group.state.location
  resource_group_name = azurerm_resource_group.state.name
  tags                = azurerm_resource_group.state.tags

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"
}

resource "azurerm_key_vault_access_policy" "terraform_state_owner" {
  key_vault_id = azurerm_key_vault.state.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = []

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

resource "azurerm_key_vault_access_policy" "terraform_state_service_principal" {
  key_vault_id = azurerm_key_vault.state.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_service_principal.terraform-state.object_id

  key_permissions = []

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

resource "azurerm_key_vault_access_policy" "terraform_state_group" {
  for_each = local.terraform_state_group

  key_vault_id = azurerm_key_vault.state.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_group.terraform_state_group[each.value].object_id

  key_permissions = []

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}
