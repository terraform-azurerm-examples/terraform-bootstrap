#!/bin/bash

read -e -i westeurope -p "Azure region        : " location
read -e -i terraform  -p "resource group name : " resource_group_name
read -e -i tfstate    -p "container name      : " container_name

location=${location:-westeurope}
resource_group_name=${resource_group_name:-terraform}
container_name=${container:-tfstate}

az group create --name $resource_group_name --location $location --output jsonc

# Check to see if existing storage account exists
jmespath_query="[? tags.created_by == 'bootstrap_backend.sh']|[0].name"
storage_account_name=$(az storage account list --resource-group $resource_group_name --query "$jmespath_query" --output tsv)

if [ -n "$storage_account_name" ]
then
  echo "Found existing storage account $storage_account_name in $resource_group_name. Reusing."
else
  storage_account_name=terraform$(tr -dc "[:lower:][:digit:]" < /dev/urandom | head -c 15)
  az storage account create --name $storage_account_name --resource-group $resource_group_name --kind StorageV2 --sku Standard_RAGRS --tags created_by=bootstrap_backend.sh
fi

storage_account_key=$(az storage account keys list --resource-group $resource_group_name --account-name $storage_account_name --output tsv --query "[1].value")
az storage container create --name $container_name --account-name $storage_account_name --account-key $storage_account_key

cat > bootstrap_backend.tf <<BOOTSTRAP_BACKEND
terraform {
  backend "azurerm" {
    resource_group_name  = "$resource_group_name"
    storage_account_name = "$storage_account_name"
    container_name       = "$container_name"
    key                  = "bootstrap.tfstate"

  }
}

BOOTSTRAP_BACKEND

echo "bootstrap_backend.tf:"
cat bootstrap_backend.tf

cat > bootstrap_backend.auto.tfvars <<BOOTSTRAP_BACKEND_TFVARS
resource_group_name  = "$resource_group_name"
storage_account_name = "$storage_account_name"
container_name       = "$container_name"

BOOTSTRAP_BACKEND_TFVARS

echo "bootstrap_backend.auto.tfvars:"
cat bootstrap_backend.auto.tfvars

exit 0
