# terraform-state-singletenant

## Overview

Bootstraps a single tenant environment for Terraform use, creating:

* Azure Key Vault including access policies and set of secrets
* Log Analytics Workspace for logging secret access to the storage accounts
* Shared Image Gallery
* Service Principal for Terraform use, with optional RBAC assignments
* RBAC assignments for the owner plus optional AAD group
* Resource lock on the resource group to avoid accidental deletes
* Set of outputs

### Pre-requirements

Pre-reqs are:

* resource group
* storage account with a container
* azurerm backend file

The command block below will create those resource and generate boostrap_backend.tf and boostrap_backend.auto.tfvars files for you.

First, log in on the CLI to Azure and check that you are in the right context using `az account show --output jsonc`

Run the following commands:

```bash
location=westeurope
resource_group_name=terraform
container=tfstate

./bootstrap_backend.sh
```

Customise the values if required.

## terraform.tfvars

Create a valid terraform.tfvars file to override the defaults. Example below:

```terraform
terraform_state_aad_group = "terraform-state"

service_principal_name = "terraform"
service_principal_rbac_assignments = [
  {
    role  = "Contributor"
    scope = "/subscriptions/2d31be49-d959-4415-bb65-8aec2c90ba62"
  }
]
```

## Outputs

## List of outputs

String values:

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

HCL compliant text blocks:

* backend
* client_secret
* provider_variables
* environment_variables

> The app_id and client_id outputs are the same, but are provided for convenience.

### backend

Create a backend.tf file:


```bash
terraform output backend > /path/to/backend.tf
```

Example file:

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

### client_secret

Create a client_secret.tf file:

```bash
terraform output backend > /path/to/client_secret.tf
```

Example file:

```hcl
provider "azurerm" {
  // Uses the Azure CLI token (or env vars) unless managed identity is used
  features {}
  alias   = "backend"
  use_msi = false
}

data "azurerm_key_vault_secret" "client_secret" {
  provider     = azurerm.backend
  key_vault_id = "/subscriptions/2d31be49-d959-4415-bb65-8aec2c90ba62/resourceGroups/terraform/providers/Microsoft.KeyVault/vaults/terraformsx80gl24bpp83fh"
  name         = "client-secret"
}
```

## Using the client_secret

Display the provider_variables output.

```bash
terraform output provider_variables
```

Example output:

```terraform

  tenant_id     = "f246eeb7-b820-4971-a083-9e100e084ed0"
  client_id     = "9306c4f0-3049-415c-84fd-2e0e6c416c78"
  client_secret = data.azurerm_key_vault_secret.client_secret.value

```

Copy and paste into your provider block, e.g.

```terraform
provider "azurerm" {
  version = "~> 2.12.0"
  features {}

  subscription_id = "9a52c25a-b883-437e-80a6-f5fc2bccd44e"
  tenant_id       = "f246eeb7-b820-4971-a083-9e100e084ed0"
  client_id       = "9306c4f0-3049-415c-84fd-2e0e6c416c78"
  client_secret   = data.azurerm_key_vault_secret.client_secret.value
}
```
