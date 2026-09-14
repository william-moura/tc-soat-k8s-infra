output "ec2_public_ip" {
  description = "IP Público da instância EC2 com Kubernetes K3s"
  value       = aws_instance.k8s_server.public_ip
}

output "ec2_instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.k8s_server.id
}