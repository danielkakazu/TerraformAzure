output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "aks_oidc_issuer" {
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_profile[0].issuer_url
  description = "OIDC issuer URL (useful para federated credentials)"
}
