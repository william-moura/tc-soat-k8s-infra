# 1. Busca a VPC Padrão
data "aws_vpc" "default" {
  default = true
}

# 2. Subnets filtradas para zonas compatíveis
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

# 3. AMI Ubuntu Oficial Canonical
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 4. Instância EC2
resource "aws_instance" "k8s_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro" # t3.micro é o padrão indiscutível aceito no Academy
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true
  key_name                    = "vockey"

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }

  # Script de inicialização seguro sem quebras
  user_data = <<-EOF
              #!/bin/bash
              echo "EC2 Started" > /tmp/status.txt
              EOF

  tags = {
    Name = "tc-k8s-node"
  }
}

# 5. Security Group com Prefix
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