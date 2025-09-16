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

2. Exporte as credenciais do service principal (se não estiverem configuradas no ambiente):
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

4. Planeje a execução:
   ```bash
   terraform plan -out=tfplan
   ```

5. Aplique a infraestrutura:
   ```bash
   terraform apply tfplan
   ```

> Observação: todos os recursos `.tf` na raiz são carregados automaticamente pelo Terraform.
