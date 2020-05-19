# terraform-state-singletenant

## Overview

Creates a resource group containing

* key vault
* storage account
* log analytics workspace

Creates a service principal for use by Terraform, as well as setting up the storage account for remote state use.

Can output a backend.tf file if var.backend is specified.

**Add diagram and more info plus list of variables.**

## Example use

You can then refer to the key vault's secrets to drive service principal usage

### backend.tf

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "terraformi9s2gj2cjefvmqb"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

### genesis.tf

```hcl
provider "azurerm" {
  // Rides on Azure CLI token or env vars to access the keyvault unless managed identity is used
  features {}
  alias   = "genesis"
  use_msi = false
}

variable "genesis_key_vault_id" {
  description = "Name of the key vault containing the tenant-id, client-id and client-secret."
  type        = string
  default     = "/subscriptions/9a52c25a-b883-437e-80a6-ff4c2bccd44e/resourceGroups/terraform-state/providers/Microsoft.KeyVault/vaults/terraformi9s2gj2cjefvmqb"
  // Probably `az keyvault list --resource-group terraform-state --query "[0].id" --output tsv`
}

data "azurerm_key_vault_secret" "tenant_id" {
  provider     = azurerm.genesis
  key_vault_id = var.genesis_key_vault_id
  name         = "tenant-id"
}

data "azurerm_key_vault_secret" "client_id" {
  provider     = azurerm.genesis
  key_vault_id = var.genesis_key_vault_id
  name         = "app-id"
}

data "azurerm_key_vault_secret" "client_secret" {
  provider     = azurerm.genesis
  key_vault_id = var.genesis_key_vault_id
  name         = "client-secret"
}
```

### main.tf

```terraform
provider "azurerm" {
  version = "~> 2.7.0"
  features {}

  subscription_id = "9a52c25a-b883-437e-80a6-ff4c2bccd44e"

  tenant_id     = data.azurerm_key_vault_secret.tenant_id.value
  client_id     = data.azurerm_key_vault_secret.client_id.value
  client_secret = data.azurerm_key_vault_secret.client_secret.value
}

resource "azurerm_resource_group" "test" {
  name     = "myTestResourceGroup"
  location = "West Europe"

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}
```
