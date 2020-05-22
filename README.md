# terraform-state-singletenant

## Overview

Creates a resource group containing

* key vault
* storage account
* log analytics workspace

Creates a service principal for use by Terraform, as well as setting up the storage account for remote state use.

## Example terraform.tfvars

```terraform
terraform_state_aad_group = "terraform-state"

service_principal_name = "terraform"
service_principal_rbac_assignments = [
  {
    role  = "Contributor"
    scope = "/subscriptions/9a52c25a-b883-437e-80a6-ff4c2bccd44e"
  }
]

backend      = "/home/richeney/test/backend.tf"
backend_full = true
```

## Outputs

* tenant_id
* resource_group_name
* storage_account_name
* storage_account_id
* container_name
* blob_name
* app_id
* app_object_id
* sp_object_id
* client_id
* rbac_authorizations
* key_vault_name
* key_vault_id
* backend
* backend_full
* example_provider_variables

> The app_id and client_id outputs are the same, but are provided for convenience.

## Default backend.tf

Specify `backend = /path/to/backend.tf` to generate a standard azurerm backend file. E.g.:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "terraformi9s2gsfcjefvmqb"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

### Full backend.tf

If you also specify `backend_full=true` then it will create a larger config. E.g.:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "terraformi9s2gsfcjefvmqb"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

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
```

## Example

If you have the fuller version of the backend.tf then you can use the data values in your azurerm provider to avoid including secrets in repositories:

```terraform
provider "azurerm" {
  version = "~> 2.7.0"
  features {}

  subscription_id = "9a52c25a-b883-437e-80a6-f5fc2bccd44e"

  tenant_id     = data.azurerm_key_vault_secret.tenant_id.value
  client_id     = data.azurerm_key_vault_secret.client_id.value
  client_secret = data.azurerm_key_vault_secret.client_secret.value
}
```

These values are also found in the example_provider_variables output.
