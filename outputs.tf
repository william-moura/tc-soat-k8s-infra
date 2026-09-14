output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint do cluster EKS"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Nome do Cluster EKS"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID da VPC provisionada"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "IDs das subnets privadas"
}

output "api_gateway_url" {
  value       = aws_apigatewayv2_api.auth_gw.api_endpoint
  description = "URL do API Gateway"
}