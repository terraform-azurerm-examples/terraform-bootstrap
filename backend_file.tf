resource "local_file" "backend" {
  for_each = toset(length(var.backend) > 0 ? [basename(var.backend)] : [])

  filename             = var.backend
  file_permission      = "0644"
  directory_permission = "0755"
  content              = <<BACKEND
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
