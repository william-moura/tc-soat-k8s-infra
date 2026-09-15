# 🚀 Tech Challenge - Infraestrutura Base Kubernetes (K3s em AWS EC2)

Este repositório contém os scripts do **Terraform** e workflows do **GitHub Actions** para provisionar a infraestrutura base da aplicação no **AWS Academy Learner Lab**, além dos manifestos Kubernetes (K3s) necessários para orquestrar os microsserviços.

---

## 📐 Arquitetura da Infraestrutura

A infraestrutura é provisionada de forma automatizada na AWS respeitando rigorosamente os limites e restrições de compliance do AWS Academy:

* **Computação:** Instância AWS EC2 (`t2.micro` / Amazon Linux 2023) executando um cluster **K3s** (Kubernetes leve).
* **IAM / Segurança:** Perfil `LabInstanceProfile` e chave SSH padrão `vockey`.
* **Rede:** VPC Padrão com Security Group liberando as portas `22` (SSH), `80` (HTTP) e `6443` (Kubernetes API).
* **API Gateway & Lambda:** Integração HTTP API Gateway apontando dinamicamente para a função de autenticação (`tc-soat-auth-lambda`).

---

## 📁 Estrutura do Repositório

```text
.
├── main.tf                 # Configuração de EC2, Security Groups, VPC e IAM
├── apigateway.tf           # Provisionamento do API Gateway v2 e permissões Lambda
├── variables.tf            # Variáveis do Terraform
├── outputs.tf              # Endpoints e IP público da EC2
├── k8s-manifests/          # Manifestos Kubernetes (Deployment, Service, ConfigMap, Ingress)
│   ├── app-deployment.yml
│   └── app-service.yml
└── .github/workflows/
    └── deploy.yml          # Pipeline CI/CD para Terraform Apply e Instalação K3s via SSH