resource "random_password" "postgres_password" {
  length  = 20
  special = true
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "airflow-pg-${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  administrator_login    = var.postgres_admin_user
  administrator_password = random_password.postgres_password.result
  version                = "14"
  sku_name               = "B_Standard_B2ms"
  storage_mb             = 32768
  backup_retention_days  = 7
  geo_redundant_backup_enabled = false
}

resource "azurerm_key_vault_secret" "postgres_password_secret" {
  name         = "airflow-postgres-password"
  value        = random_password.postgres_password.result
  key_vault_id = azurerm_key_vault.kv.id
}
