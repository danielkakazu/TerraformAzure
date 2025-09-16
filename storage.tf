resource "azurerm_storage_account" "logs" {
  name                     = lower("airflowsa${random_string.acr_suffix.result}")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
}

resource "azurerm_storage_container" "airflow_logs" {
  name                  = "airflow-logs"
  storage_account_name  = azurerm_storage_account.logs.name
  container_access_type = "private"
}
