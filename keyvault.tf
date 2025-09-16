data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "airflow-kv-${random_string.acr_suffix.result}"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_enabled         = true
  purge_protection_enabled    = false
}

resource "azurerm_key_vault_secret" "storage_account_key" {
  name         = "airflow-storage-key"
  value        = azurerm_storage_account.logs.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_storage_account.logs]
}
