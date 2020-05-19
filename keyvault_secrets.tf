resource "azurerm_key_vault_secret" "tenant_id" {
  name         = "tenant-id" // Only alphanumerics and hyphens allowed
  key_vault_id = azurerm_key_vault.state.id
  value        = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_secret" "resource_group" {
  name         = "resource-group-name"
  key_vault_id = azurerm_key_vault.state.id
  value        = azurerm_resource_group.state.name
}


resource "azurerm_key_vault_secret" "storage_account_name" {
  name         = "storage-account-name"
  key_vault_id = azurerm_key_vault.state.id
  value        = azurerm_storage_account.state.name
}

resource "azurerm_key_vault_secret" "storage_account_id" {
  name         = "storage-account-id"
  key_vault_id = azurerm_key_vault.state.id
  value        = azurerm_storage_account.state.id
}

resource "azurerm_key_vault_secret" "container_name" {
  name         = "container-name"
  key_vault_id = azurerm_key_vault.state.id
  value        = azurerm_storage_container.tfstate.name
}

resource "azurerm_key_vault_secret" "blob_name" {
  name         = "blob-name"
  key_vault_id = azurerm_key_vault.state.id
  value        = var.blob
}

resource "azurerm_key_vault_secret" "app_id" {
  name         = "app-id"
  key_vault_id = azurerm_key_vault.state.id
  value        = azuread_application.terraform.application_id
}

resource "azurerm_key_vault_secret" "app_object_id" {
  name         = "app-object-id"
  key_vault_id = azurerm_key_vault.state.id
  value        = azuread_application.terraform.id
}

resource "azurerm_key_vault_secret" "sp_object_id" {
  name         = "sp-object-id"
  key_vault_id = azurerm_key_vault.state.id
  value        = azuread_service_principal.terraform.id
}

resource "azurerm_key_vault_secret" "client_id" {
  name         = "client-id"
  key_vault_id = azurerm_key_vault.state.id
  value        = azuread_service_principal.terraform.application_id
}

resource "azurerm_key_vault_secret" "client_secret" {
  name         = "client-secret"
  key_vault_id = azurerm_key_vault.state.id
  value        = azuread_service_principal_password.terraform.value
}