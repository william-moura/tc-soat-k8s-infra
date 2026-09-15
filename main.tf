# 1. Busca a VPC Padrão do AWS Academy
data "aws_vpc" "default" {
  default = true
}

# 2. Busca uma Subnet Padrão dentro dessa VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3. Busca a AMI Ubuntu Oficial (Canonical)
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

# 4. Instância EC2 compatível com as regras do Learner Lab
resource "aws_instance" "k8s_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true
  key_name                    = "vockey" # Key pair padrão gerada automaticamente pelo AWS Academy

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  # Configuração de disco padrão permitida no AWS Academy
  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    encrypted             = false # O Academy rejeita chaves de criptografia customizadas
    delete_on_termination = true
  }

  tags = {
    Name = "tc-k8s-node"
  }
}

# 5. Security Group
resource "aws_security_group" "k8s_sg" {
  name        = "tc-k8s-sg"
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
}