terraform {
  backend "azurerm" {
    resource_group_name   = "tfstate-rg"
    storage_account_name  = "tfstateairflow"
    container_name        = "tfstate"
    key                   = "airflow-aks.terraform.tfstate"
  }
}
