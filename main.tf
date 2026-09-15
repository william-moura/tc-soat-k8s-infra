# main.tf

# 1. Obtém o Account ID REAL da conta do AWS Academy dinamicamente
data "aws_caller_identity" "current" {}

# 2. Busca a VPC Padrão do AWS Academy
data "aws_vpc" "default" {
  default = true
}

# 3. Subnets válidas (exclui us-east-1e para t3.small)
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

# 4. AMI Amazon Linux 2023 Oficial (Obrigatória no AWS Academy)
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

# 5. Security Group com name_prefix
resource "aws_security_group" "k8s_sg" {
  name_prefix = "tc-k8s-sg-"
  description = "Security Group para K3s no AWS Academy"
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

  lifecycle {
    create_before_destroy = true
  }
}

# 6. EC2 Instância no AWS Academy
resource "aws_instance" "k8s_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.small"
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true
  key_name                    = "vockey"
  iam_instance_profile        = "LabInstanceProfile"

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }

  tags = {
    Name = "tc-k8s-node"
  }
}