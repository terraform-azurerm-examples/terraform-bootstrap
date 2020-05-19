locals {
  service_principal_name = var.service_principal_suffix ? "${var.service_principal_name}-${random_string.terraform.result}" : var.service_principal_name

  storage_rbac_assignment = [{
    scope = azurerm_storage_account.state.id,
    role  = "Storage Blob Data Contributor"
  }]

  rbac_assignments = {
    for assignment in var.service_principal_rbac_assignments :
    md5("${assignment.role}-${assignment.scope}") => assignment // Should remain as a predictable hash key
  }
}

resource "random_password" "terraform" {
  length  = 128
  special = false
  upper   = true
  lower   = true
  number  = true
}

resource "azuread_application" "terraform" {
  name = local.service_principal_name

  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000" // Azure Active Directory Graph

    resource_access {
      id   = "824c81eb-e3f8-4ee6-8f6d-de7f50d565b7" // Application.ReadWrite.OwnedBy
      type = "Role"
    }

    resource_access {
      id   = "5778995a-e1bf-45b8-affa-663a9f3f4d04" // Directory.Read.All
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "terraform" {
  application_id = azuread_application.terraform.application_id
}

resource "azuread_service_principal_password" "terraform" {
  service_principal_id = azuread_service_principal.terraform.id
  value                = random_password.terraform.result
  end_date_relative    = "43200m"
}

resource "azurerm_role_assignment" "terraform-state-storage" {
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.terraform.object_id
}


resource "azurerm_role_assignment" "terraform-state-rbac" {
  for_each = local.rbac_assignments

  scope                = each.value["scope"]
  role_definition_name = each.value["role"]
  principal_id         = azuread_service_principal.terraform.object_id
}