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
