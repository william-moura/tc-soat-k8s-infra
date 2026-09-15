# 🚀 Tech Challenge - Infraestrutura Base Kubernetes (K3s em AWS EC2)

> 📌 **Nota:** Este repositório é parte integrante do ecossistema **Tech Challenge**. Para conferir a visão geral da aplicação, acesse o repositório principal: [tech-challenge](https://github.com/william-moura/tech-challenge).

Este repositório gerencia a infraestrutura base de computação e o orquestrador Kubernetes no **AWS Academy Learner Lab** utilizando **Terraform** e **GitHub Actions**.

---

## 📐 Componentes Provisionados

* **Computação:** Instância EC2 (`t2.micro`, Amazon Linux 2023) executando um cluster **K3s**.
* **Rede & Segurança:** Security Group liberando portas `22` (SSH), `80` (HTTP Ingress), `443` (HTTPS) e `6443` (Kubernetes API).
* **Roteamento & Entrada:** AWS API Gateway HTTP v2 (`tc-soat-api-gateway`) configurado para invocar a Lambda de Autenticação.
* **Manifestos Kubernetes:** Gerenciamento dos arquivos YAML em `k8s-manifests/` (`app-deployment.yml`, `app-service.yml`, `tc-app-config`, `tc-app-secret`).

---

## 📁 Estrutura de Arquivos

.
├── main.tf                 # Provisionamento de EC2, VPC Data, Security Group e IAM Profile
├── apigateway.tf           # Provisionamento do API Gateway v2 e permissão de invocação Lambda
├── variables.tf            # Declaração das variáveis do Terraform
├── outputs.tf              # Exposição do IP público da EC2 e ID do API Gateway
├── k8s-manifests/          # Manifestos de Deployment, Service, ConfigMap e Secrets do K3s
└── .github/workflows/
    └── deploy.yml          # Pipeline CI/CD para execução do Terraform Apply e Bootstrap do K3s

---

## 🔑 Variáveis & Secrets (GitHub Actions)

As seguintes Secrets temporárias da AWS precisam ser atualizadas antes de cada execução da pipeline em **Settings > Secrets and variables > Actions**:

| Secret | Descrição |
| :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Chave de acesso temporária (AWS Details > AWS CLI) |
| `AWS_SECRET_ACCESS_KEY` | Chave secreta temporária (AWS Details > AWS CLI) |
| `AWS_SESSION_TOKEN` | Token de sessão temporário (AWS Details > AWS CLI) |
| `EC2_SSH_KEY` | Conteúdo do arquivo de chave privada `vockey.pem` |

---

## ⚙️ Fluxo do Terraform & CI/CD

1. **Terraform Apply:** Cria a instância EC2 com a AMI Amazon Linux 2023, vincula a chave `vockey` e configura a rota HTTP no API Gateway apontando para a Lambda `tc-soat-auth-lambda`.
2. **K3s Bootstrapping:** A pipeline conecta na EC2 via SSH, realiza o `dnf install -y git`, instala o K3s (`get.k3s.io`) e aguarda o endpoint `/readyz` da API do Kubernetes responder HTTP 200 OK.
3. **Registry Authentication:** Cria a Secret `ghcr-secret` no namespace `default` permitindo o download de imagens privadas do GitHub Container Registry.