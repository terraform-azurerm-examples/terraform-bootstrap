locals {
  backend_file = <<BACKEND
terraform {
  backend "azurerm" {
    resource_group_name  = "${data.azurerm_resource_group.state.name}"
    storage_account_name = "${data.azurerm_storage_account.state.name}"
    container_name       = "${data.azurerm_storage_container.tfstate.name}"
    key                  = "${var.blob_name}"
  }
}
BACKEND

  client_secret_file = <<CLIENT_SECRET
provider "azurerm" {
  // Uses the Azure CLI token (or env vars) unless managed identity is used
  features {}
  alias   = "backend"
  use_msi = false
}

data "azurerm_key_vault_secret" "client_id" {
  provider     = azurerm.backend
  key_vault_id = "${azurerm_key_vault.state.id}"
  name         = "client-id"
}


data "azurerm_key_vault_secret" "client_secret" {
  provider     = azurerm.backend
  key_vault_id = "${azurerm_key_vault.state.id}"
  name         = "client-secret"
}
CLIENT_SECRET

  azurerm_provider_file = <<PROVIDER
provider "azurerm" {
  version             = "${var.azurerm_version_constraint}"
  storage_use_azuread = true

  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

  tenant_id       = "${data.azurerm_client_config.current.tenant_id}"
  subscription_id = var.subscription_id
  client_id       = data.azurerm_key_vault_secret.client_id.value
  client_secret   = data.azurerm_key_vault_secret.client_secret.value
}
PROVIDER
}

//==================================================================

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "resource_group_name" {
  value = data.azurerm_resource_group.state.name
}

output "storage_account_name" {
  value = data.azurerm_storage_account.state.name
}

output "storage_account_id" {
  value = data.azurerm_storage_account.state.id
}

output "tfstate_container_name" {
  value = data.azurerm_storage_container.tfstate.name
}

output "bootstrap_state_blob_name" {
  value = "boostrap.tfstate"
}

output "terraform_state_blob_name" {
  value = var.blob_name
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
  value = local.backend_file
}

output "client_secret" {
  value = local.client_secret_file
}

output "azurerm_provider" {
  value = local.azurerm_provider_file
}

output "provider_variables" {
  value = <<PROVIDER

  tenant_id     = "${data.azurerm_client_config.current.tenant_id}"
  client_id     = "${azuread_service_principal.terraform.application_id}"
  client_secret = data.azurerm_key_vault_secret.client_secret.value
PROVIDER
}

output "environment_variables" {
  value = <<ENVVARS

export ARM_TENANT_ID=${data.azurerm_client_config.current.tenant_id}
export ARM_SUBSCRIPTION_ID=$(az account show --output tsv --query id)
export ARM_CLIENT_ID=${azuread_service_principal.terraform.application_id}
export ARM_CLIENT_SECRET=$(az keyvault secret show --vault-name ${azurerm_key_vault.state.name} --name client-secret --output tsv --query value)
ENVVARS
}

//==================================================================

resource "local_file" "backend" {
  content              = local.backend_file
  filename             = "outputs/backend.tf"
  file_permission      = 0644
  directory_permission = 0755
}

resource "local_file" "client_secret" {
  content              = local.client_secret_file
  filename             = "outputs/client_secret.tf"
  file_permission      = 0644
  directory_permission = 0755
}

resource "local_file" "azurerm_provider" {
  content              = local.azurerm_provider_file
  filename             = "outputs/azurerm_provider.tf"
  file_permission      = 0644
  directory_permission = 0755
}
