resource "azurerm_user_assigned_identity" "airflow_uai" {
  name                = "airflow-uai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
