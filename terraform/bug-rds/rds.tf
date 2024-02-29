## local vars

# require provideres block
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>5.0"
        }
    }  
}
 
# Provider block
provider "aws" {
    region = var.aws_region
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}
## DB Subent Group

resource "aws_db_subnet_group" "dac_db_subnet_group" {
  name       = var.db_subnet_group
  subnet_ids = [var.dac_db_subnet_1_id, var.dac_db_subnet_2_id]

  tags = {
    Name = "dac_db_subnet_group"
  }
}

## DB instance

resource "aws_db_instance" "dac_db" {
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_name                    = var.db_name
  identifier              = var.identifier
  username                = local.db_creds.username
  password                = local.db_creds.password
  parameter_group_name    = "default.mysql8.0"
  db_subnet_group_name    = aws_db_subnet_group.dac_db_subnet_group.name
  vpc_security_group_ids  = [var.dac_db_sg_id]
  skip_final_snapshot     = "true"
}

## Add some customization around pwd to make it more secure
data "aws_secretsmanager_secret_version" "creds" {
  # Fill in the name you gave to your secret
  secret_id = var.db_secret
}
