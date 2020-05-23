output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "resource_group_name" {
  value = azurerm_resource_group.state.name
}

output "storage_account_name" {
  value = azurerm_storage_account.state.name
}

output "storage_account_id" {
  value = azurerm_storage_account.state.id
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "blob_name" {
  value = var.blob
}

output "app_id" {
  value = azuread_application.terraform.application_id
}

output "app_object_id" {
  value = azuread_application.terraform.id
}

output "sp_object_id" {
  value = azuread_service_principal.terraform.id
}

output "client_id" {
  value = azuread_service_principal.terraform.application_id
}

output "rbac_authorizations" {
  value = local.rbac_assignments
}

output "key_vault_name" {
  value = azurerm_key_vault.state.name
}

output "key_vault_id" {
  value = azurerm_key_vault.state.id
}

output "backend" {
  value = local.backend
}

output "backend_full" {
  value = local.backend_full
}

output "example_provider_variables" {
  value = <<PROVIDER
  tenant_id     = data.azurerm_key_vault_secret.tenant_id.value
  client_id     = data.azurerm_key_vault_secret.client_id.value
  client_secret = data.azurerm_key_vault_secret.client_secret.value
PROVIDER
}

output "example_environment_variables" {
  value = <<ENVVARS
export ARM_TENANT_ID=${data.azurerm_client_config.current.tenant_id}
export ARM_SUBSCRIPTION_ID=$(az account show --output tsv --query id)
export ARM_CLIENT_ID=${azuread_service_principal.terraform.application_id}
export ARM_CLIENT_SECRET=$(az keyvault secret show --vault-name ${azurerm_key_vault.state.name} --name client-secret --output tsv --query value)
ENVVARS
}
