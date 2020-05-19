locals {
  terraform_state_aad_group = toset(length(var.terraform_state_aad_group) > 0 ? [var.terraform_state_aad_group] : [])
}

data "azuread_group" "terraform_state_aad_group" {
  for_each = local.terraform_state_aad_group
  name     = each.value
}

resource "azurerm_storage_account" "state" {
  name                = local.terraform_uniq
  resource_group_name = azurerm_resource_group.state.name
  location            = azurerm_resource_group.state.location
  tags                = azurerm_resource_group.state.tags

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.container
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "terraform_state_owner" {
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "terraform_state_aad_group" {
  for_each = local.terraform_state_aad_group

  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_group.terraform_state_aad_group[each.value].object_id
}
