provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

resource "helm_release" "airflow" {
  name            = "apache-airflow"
  repository      = "https://airflow.apache.org"
  chart           = "airflow"
  namespace       = "airflow"
  create_namespace = true

  values      = [file("${path.module}/values-airflow.yaml")]
  depends_on  = [azurerm_kubernetes_cluster.aks]
}
