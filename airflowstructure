# Repositório Terraform: Airflow em AKS (Azure)

Este repositório fornece um ponto de partida completo para criar a infraestrutura necessária para rodar o Apache Airflow em produção no Azure AKS, seguindo o guia da Microsoft. Contém arquivos Terraform organizados por responsabilidade, um values.yaml de exemplo para o Helm chart do Airflow e um README explicando os passos.

---

### arquivos incluídos

- providers.tf
- variables.tf
- main.tf
- resource_group.tf
- acr.tf
- storage.tf
- keyvault.tf
- identity.tf
- postgres.tf (template para Azure Database for PostgreSQL - Flexible Server)
- aks.tf
- role_assignments.tf
- helm_airflow.tf
- values-airflow.yaml
- outputs.tf
- README.md

---

--- providers.tf ---
```hcl
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.79.0" # ajuste conforme necessário; escolha versão que suporte oidc_issuer/workload_identity
    }
    kubernetes = { source = "hashicorp/kubernetes" }
    helm       = { source = "hashicorp/helm" }
  }
}

provider "azurerm" {
  features {}
}
```

--- variables.tf ---
```hcl
variable "location" {
  type    = string
  default = "brazilsouth"
}

variable "rg_name" {
  type    = string
  default = "airflow-rg"
}

variable "acr_name" {
  type    = string
  default = "airflowacr${random_string.acr_suffix.result}"
}

variable "cluster_name" {
  type    = string
  default = "airflow-aks"
}

variable "node_count" {
  type    = number
  default = 3
}

variable "node_vm_size" {
  type    = string
  default = "Standard_DS4_v2"
}

variable "postgres_admin_user" {
  type    = string
  default = "airflow_admin"
}

variable "airflow_image_tag" {
  type    = string
  default = "2.9.3"
}
```

--- main.tf ---
```hcl
# entrypoint - includes resources via modules or direct file includes
# This file intentionally small: other components estão em arquivos separados

module "rg" {
  source = "./resource_group.tf"
}
```

--- resource_group.tf ---
```hcl
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
```

--- acr.tf ---
```hcl
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = false
}
```

--- storage.tf ---
```hcl
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
```

--- keyvault.tf ---
```hcl
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

# Exemplo de secret (valor será preenchido após criar resources que geram keys)
resource "azurerm_key_vault_secret" "storage_account_key" {
  name         = "airflow-storage-key"
  value        = azurerm_storage_account.logs.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_storage_account.logs]
}
```

--- identity.tf ---
```hcl
resource "azurerm_user_assigned_identity" "airflow_uai" {
  name                = "airflow-uai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
```

--- postgres.tf (template) ---
```hcl
# Template para Azure Database for PostgreSQL - Flexible Server
# Em produção use servidor gerenciado em subrede privada; este exemplo é um ponto de partida

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "airflow-pg-${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  administrator_login          = var.postgres_admin_user
  administrator_password       = random_password.postgres_password.result
  version                      = "14"
  sku_name                     = "Standard_B2ms"
  storage_mb                   = 32768
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
}

resource "random_password" "postgres_password" {
  length  = 20
  special = true
}

resource "azurerm_key_vault_secret" "postgres_password_secret" {
  name         = "airflow-postgres-password"
  value        = random_password.postgres_password.result
  key_vault_id = azurerm_key_vault.kv.id
}
```

--- aks.tf ---
```hcl
# AKS com OIDC issuer habilitado e workload identity (sintaxe depende da versão do provider azurerm)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "airflowaks"

  default_node_pool {
    name                = "npdefault"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    availability_zones  = ["1","2","3"]
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    managed = true
  }

  # Habilitar OIDC issuer
  oidc_issuer_enabled = true

  # Observação: dependendo do provider, a propriedade workload_identity pode variar.
  # Se seu provider não suportar, considere executar CLI 'az aks update' via null_resource.

  tags = {
    environment = "production"
    created_by  = "terraform"
  }
}

# kube config output (usado mais tarde pelo provider kubernetes)
output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].raw_kube_config
}
```

--- role_assignments.tf ---
```hcl
# Exemplo de atribuição de role AcrPull ao managed identity do kubelet
# Atenção: a forma exata de obter o principal id pode variar entre versões do provider

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "acr_pull_for_kubelet" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  depends_on           = [azurerm_kubernetes_cluster.aks, azurerm_container_registry.acr]
}

# Conceder Key Vault access para a User Assigned Identity
resource "azurerm_role_assignment" "kv_access_for_uai" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.airflow_uai.principal_id
}
```

--- helm_airflow.tf ---
```hcl
# Instalação do Helm chart do Airflow
# Use este recurso se quiser que Terraform também faça o helm release.
# Atenção: o provider kubernetes/helm necessita de configuração com os dados do cluster.

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

resource "helm_release" "airflow" {
  name       = "apache-airflow"
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  namespace  = "airflow"
  create_namespace = true

  values = [file("${path.module}/values-airflow.yaml")]
  depends_on = [azurerm_kubernetes_cluster.aks]
}
```

--- values-airflow.yaml ---
```yaml
# Exemplo de values para o chart do Airflow (ajuste conforme o chart que usar)
images:
  airflow:
    repository: "${azurerm_container_registry.acr.login_server}/airflow"
    tag: "${var.airflow_image_tag}"

airflow:
  fernetKey: "REPLACE_WITH_STRONG_KEY"
  webserver:
    defaultUser:
      enabled: false

logs:
  remoteLogging: true
  remoteLogConnId: "azure_blob"

connections:
  azure_blob:
    type: "wasb"
    extra: "{\"account_name\": \"REPLACE_WITH_STORAGE_ACCOUNT\", \"container\": \"airflow-logs\"}"

# Configure the SQL Alchemy connection to the managed PostgreSQL
# Ex: postgresql+psycopg2://airflow_admin:<password>@<host>:5432/airflow
```

--- outputs.tf ---
```hcl
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "aks_oidc_issuer" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_profile[0].issuer_url
  description = "OIDC issuer URL (useful para federated credentials)"
}
```

--- README.md ---
```md
# Terraform: Airflow on AKS (Azure)

Este repositório cria os recursos essenciais para rodar o Apache Airflow em produção no AKS (Azure) seguindo as recomendações do guia da Microsoft.

## Arquitetura criada
- Resource Group
- Azure Container Registry (ACR)
- Storage Account (para logs)
- Key Vault (segredos)
- Azure Database for PostgreSQL (Flexible Server) - template
- AKS com OIDC issuer habilitado
- User Assigned Identity para External Secrets
- Role assignments (ACR pull, Key Vault access)
- Helm release do Airflow (opcional via Terraform)

## Como usar
1. Ajuste `variables.tf` de acordo com seu ambiente (nomes, local, tamanhos).
2. `terraform init`
3. `terraform plan`
4. `terraform apply` (revisar e aprovar)

> Observação: dependendo da versão do provider `azurerm`, pode ser necessário executar comandos `az aks update` para habilitar OIDC/workload identity após a criação do cluster. Em alguns ambientes esse passo é mais confiável via `az` CLI.

## Push de imagens para o ACR
Depois de criar o ACR, importe as imagens oficiais do Apache Airflow ou faça build/push das suas imagens:

```bash
# exemplo: importar imagem pública para o ACR
az acr import --name <ACR_NAME> --source docker.io/apache/airflow:2.9.3 --image airflow:2.9.3
```

## Deploy do Helm Chart do Airflow
Você pode deixar o Terraform instalar o chart (arquivo helm_airflow.tf) ou usar pipeline CI/CD para aplicar o chart com `helm upgrade --install` apontando para o ACR e usando segredos armazenados no Key Vault.

## Notas importantes
- Use Azure Database for PostgreSQL gerenciado para produção; não rode o DB crítico dentro do cluster.
- Se for usar workload identity e federated credentials para acessar Key Vault, siga os passos do guia MS para criar a federated identity e configurar o External Secrets Operator.
- Sempre revise e aplique políticas de segurança (NSG, Private Link, RBAC) conforme normas da sua empresa.
