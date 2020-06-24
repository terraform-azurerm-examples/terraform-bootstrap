# terraform-bootstrap

## Background

It is easy to set up a service principal in Azure for Terraform use, but in production there are some good questions:

1. Where do I store the credentials?
1. How do I give the right access to read those credentials?
1. How do I track who has accessed the credentials?
1. How do I safely reference those credentials without including secrets in my Terraform root modules?
1. What can those other root modules use as their backend state?

This repo addresses those concerns, and is helpful in bootstrapping a single tenant environment.

## Overview

Bootstraps a single tenant environment for Terraform use, creating:

* Azure Key Vault including access policies and set of secrets
* Log Analytics Workspace for logging secret access to the storage accounts
* Service Principal for Terraform use, with optional RBAC assignments
* RBAC assignments for the owner plus optional AAD group
* Resource lock on the resource group to avoid accidental deletes
* Set of outputs

## Context

Before running the bootstrap , log in on the CLI to Azure and check that you are in the right context using `az account show --output jsonc`

## Bootstrap

Run the following command:

```bash
./bootstrap_backend.sh
```

The script will create

* resource group with you as Owner
* storage account (plus container) with you as Storage Blob Data Owner
* boostrap_backend.tf
* boostrap_backend.auto.tfvars containing
  * resource_group_name
  * storage_account_name
  * container_name
  * azurerm_version_constraint

> The azurerm_version will attempt to pull the latest version from the repo. E.g. "~> 2.15"

## Overriding the variable defaults

If you wish to override the variable defaults then create a valid terraform.tfvars. Example below:

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

> The service_principal_rbac_assignments array defaults to [] and will therefore give the service principal no RBAC permissions. You can either define the role assignments here to capture it as code, or assign manually in the portal. Note that you can use `"Current"` as the scope value and it willsubstitute it with the subscriptionId for the current context.

## Resources created

* Service principal with random password
* Key vault with access policies for owner and service principal
* Secrets for the client id and secret
* Log analytics workspace with setting for the key vault
* Storage account role assignments
* Optional RBAC role assignments if specified
* Generated files in the outputs subfolder

If an AAD group was specified then it will also be given access to the storage account and key vault.

## Outputs

### Terraform Outputs

Simple string values:

* tenant_id
* resource_group_name
* storage_account_name
* storage_account_id
* container_name
* app_id
* app_object_id
* sp_object_id
* client_id
* rbac_authorizations
* key_vault_name
* key_vault_id

> The app_id and client_id outputs are the same, but are provided for convenience.

HCL compliant text blocks:

* backend
* client_secret
* provider_variables
* environment_variables

> Example use: `terraform output environment_variables >> ~/.bashrc`

### Output Files

The following files are generated, and may be copied into new Terraform root modules to quickly make use of the service principal, key vault and storage account.

* outputs/azurerm_provider.tf
* outputs/backend.tf
* outputs/bootstrap_secrets.tf

> You are not compelled to use the files as is, or at all.

## Test

1. Create a new directory containing the files. e.g.

    ```bash
    mkdir -m 755 /git/myTerraformTest
    cp outputs/*.tf /git/myTerraformTest
    cd /git/myTerraformTest
    ```

1. Edit the name of the key in the backend.tf file

1. `terraform init`
1. `terraform validate`
1. `terraform plan`
1. `terraform apply`

The config will successfully use the service principal and store the state file in the storage account.
