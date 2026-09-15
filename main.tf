# 1. Busca a VPC Padrão
data "aws_vpc" "default" {
  default = true
}

# 2. Subnets filtradas para zonas compatíveis (evita us-east-1e)
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

# 3. AMI Amazon Linux 2023 Oficial (Aprovada 100% no AWS Academy)
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

# 4. Instância EC2 compatível com as regras rígidas do Learner Lab
resource "aws_instance" "k8s_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true
  key_name                    = "vockey"
  iam_instance_profile        = "LabInstanceProfile"

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Instalação do K3s no Amazon Linux 2023
              curl -sfL https://get.k3s.io | sh -
              EOF

  tags = {
    Name = "tc-k8s-node"
  }
}

# 5. Security Group
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