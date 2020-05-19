provider "azuread" {
  version = "~> 0.8.0"
}

provider "random" {
  version = "~> 2.2"
}

provider "local" {
  version = "~> 1.4"
}

provider "azurerm" {
  version = "~> 2.9"
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "state" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "random_string" "terraform" {
  length  = 15
  special = false
  lower   = true
  upper   = false
  number  = true
}

locals {
  terraform_uniq = "terraform${random_string.terraform.result}"
}
