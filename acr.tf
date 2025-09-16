resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_container_registry" "acr" {
  name                = "airflowacr${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = false
}
