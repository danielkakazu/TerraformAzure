resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  number  = true
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}
