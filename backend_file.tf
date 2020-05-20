locals {

  backend = <<BACKEND
provider "azurerm" {
  // Uses the Azure CLI token (or env vars) unless managed identity is used
  features {}
  alias   = "backend"
  use_msi = false
}
BACKEND

  backend_full = <<BACKEND_FULL
provider "azurerm" {
  // Uses the Azure CLI token (or env vars) unless managed identity is used
  features {}
  alias   = "backend"
  use_msi = false
}

variable "backend_key_vault_id" {
  description = "Name of the key vault containing the tenant-id, client-id and client-secret."
  type        = string
  default     = "${azurerm_key_vault.state.id}"
  // `az keyvault list --resource-group ${var.resource_group_name} -state --query "[0].id" --output tsv`
}

data "azurerm_key_vault_secret" "backend_tenant_id" {
  provider     = azurerm.backend
  key_vault_id = var.backend_key_vault_id
  name         = "tenant-id"
}

data "azurerm_key_vault_secret" "backend_client_id" {
  provider     = azurerm.backend
  key_vault_id = var.backend_key_vault_id
  name         = "app-id"
}

data "azurerm_key_vault_secret" "backend_client_secret" {
  provider     = azurerm.backend
  key_vault_id = var.backend_key_vault_id
  name         = "client-secret"
}
BACKEND_FULL

}

resource "local_file" "backend" {
  for_each = toset(length(var.backend) > 0 ? [basename(var.backend)] : [])

  filename             = var.backend
  file_permission      = "0644"
  directory_permission = "0755"
  content              = var.backend_full ? local.backend_full : local.backend
}
