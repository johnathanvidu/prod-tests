# require provideres block
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>6.0"
        }
    }  
}

# Provider block
provider "aws" {
    region = var.aws_region
}

locals {
  default_qualix_instance_type = "t3a.small"
}

# Create EC2 Keypair

resource "tls_private_key" "ec2_key_data" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "Keypair" {
  key_name   = "Keypair-${var.env_id}"
  public_key = tls_private_key.ec2_key_data.public_key_openssh
}

resource "aws_secretsmanager_secret" "private_key" {
  name = "ec2-private-key-${var.env_id}"
}

resource "aws_secretsmanager_secret_version" "private_key_version" {
  secret_id     = aws_secretsmanager_secret.private_key.id
  secret_string = tls_private_key.ec2_key_data.private_key_pem
}

# Get latest Amazon Linux 2023 AMI

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]          # or "al2023-ami-kernel-*" 
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnet" "app_subnet" {
  id = var.app_subnet_id
}

# QualiX Section
# Guacamole App
resource "aws_instance" "sandbox_QualiX_instance" {
  ami = data.aws_ami.al2023.id
  instance_type = local.default_qualix_instance_type
  key_name = aws_key_pair.Keypair.key_name
  subnet_id = data.aws_subnet.app_subnet.id
  vpc_security_group_ids = [ aws_security_group.Guac_Security_Group.id ]
  user_data = "${file("qualix.sh")}"
  tags = {Name = "QualiX"}
}

resource "aws_security_group" "Guac_Security_Group" {
  name = "QualiX Security Group"
  description = "QualiX Security Group"
  vpc_id = data.aws_subnet.app_subnet.vpc_id
  ingress {
    description = "public port access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "public port access"
    from_port   = 443
    to_port     = 443
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


