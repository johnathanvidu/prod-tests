provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Name = "ubuntu-qualix"
    }
  }
}

# ── Networking ────────────────────────────────────────────────────────────────

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

resource "aws_security_group" "ssh_only" {
  name        = "ubuntu-qualix-ssh"
  description = "Allow SSH inbound for QualiX key-based access"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# ── Key pair ──────────────────────────────────────────────────────────────────

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "ubuntu-qualix-key"
  public_key = tls_private_key.this.public_key_openssh
}

# ── AMI ───────────────────────────────────────────────────────────────────────

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── Instance ──────────────────────────────────────────────────────────────────

resource "aws_instance" "ubuntu_instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.this.id
  security_groups = [aws_security_group.ssh_only.id]
  key_name        = aws_key_pair.this.key_name
}

# ── QualiX link ───────────────────────────────────────────────────────────────

module "qualix_ubuntu_link" {
  source = "./link_maker"

  qualix_ip         = var.qualix_public_ip
  protocol          = "ssh"
  connection_port   = 22
  target_ip_address = var.use_public_ip ? aws_instance.ubuntu_instance.public_ip : aws_instance.ubuntu_instance.private_ip
  target_username   = "ubuntu"
  access_key        = tls_private_key.this.private_key_pem
}
