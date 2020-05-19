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
  value = <<BACKEND
terraform {
  backend "azurerm" {
    resource_group_name  = "${azurerm_resource_group.state.name}"
    storage_account_name = "${azurerm_storage_account.state.name}"
    container_name       = "${var.container}"
    key                  = "${var.blob}"
  }
}
BACKEND
}