resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "airflowaks"

  default_node_pool {
    name       = "npdefault"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    tenant_id              = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = []
  }

  oidc_issuer_enabled = true

  tags = {
    environment = "production"
    created_by  = "terraform"
  }
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_admin_config[0].raw_kube_config
  sensitive = true
}
