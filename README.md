# Terraform: Airflow no AKS (Azure)

Infraestrutura completa para rodar Apache Airflow em produção no AKS, usando Terraform.

## Estrutura
- Resource Group
- ACR
- Storage Account
- Key Vault
- AKS (OIDC)
- User Assigned Identity
- Role Assignments
- Helm release (opcional)
- PostgreSQL Flexible Server (template)

## Como usar
1. Clone o repositório no HPC:
   ```bash
   git clone https://github.com/<usuario>/terraform-airflow-aks.git
   cd terraform-airflow-aks
   ```

2. Configure variáveis de ambiente do Service Principal se necessário:
   ```bash
   export ARM_SUBSCRIPTION_ID=xxxx
   export ARM_TENANT_ID=xxxx
   export ARM_CLIENT_ID=xxxx
   export ARM_CLIENT_SECRET=xxxx
   ```

3. Inicialize o Terraform:
   ```bash
   terraform init
   ```

4. Planeje e aplique:
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

## Observações
- Ajuste variáveis em `variables.tf`.
- State remoto configurado em `backend.tf` (Azure Storage).
- Imagens do Airflow devem ser importadas para o ACR manualmente.
