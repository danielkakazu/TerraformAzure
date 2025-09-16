data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "acr_pull_for_kubelet" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  depends_on           = [azurerm_kubernetes_cluster.aks, azurerm_container_registry.acr]
}

resource "azurerm_role_assignment" "kv_access_for_uai" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.airflow_uai.principal_id
}
