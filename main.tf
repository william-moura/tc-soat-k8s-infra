terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

# 2. Busca as Subnets Padrão da VPC existente
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Busca dinamicamente a AMI Ubuntu 22.04 LTS oficial da Canonical
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Dona oficial do Ubuntu - Permitida no AWS Academy)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "k8s_sg" {
  name_prefix        = "tc-k8s-ec2-sg"
  description = "Security Group para EC2 com K3s"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "k8s_server" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.small"
  key_name             = "vockey"
  iam_instance_profile = "LabInstanceProfile"
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = {
    Name = "tc-k8s-node"
  }
}