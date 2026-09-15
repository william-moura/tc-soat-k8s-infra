# 1. Busca a VPC Padrão do AWS Academy
data "aws_vpc" "default" {
  default = true
}

# 2. Busca as Subnets Padrão da VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}

# 3. AMI Amazon Linux 2023 Oficial
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 4. Instância EC2 em estado puro (sem user_data)
resource "aws_instance" "k8s_server" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t3.small"
  subnet_id            = data.aws_subnets.default.ids[0]
  key_name             = "vockey"
  iam_instance_profile = "LabInstanceProfile"

  # Usa o Security Group padrão do próprio laboratório para evitar bloqueio de auditoria
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = {
    Name = "tc-k8s-node"
  }
}

# 5. Security Group Mínimo
resource "aws_security_group" "k8s_sg" {
  name_prefix = "tc-k8s-sg-"
  description = "Security Group K3s AWS Academy"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}