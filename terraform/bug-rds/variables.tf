variable "aws_region" {
  type = string
  default = "us-east-2"
}
variable "dac_db_subnet_1_id" {
  type = string
}

variable "dac_db_subnet_2_id" {
  type = string
}

variable "dac_db_sg_id" {
  type = string
}

variable "db_secret" {
  type = string
  default = "db-creds"
}

variable "allocated_storage" {
  type = number
  default = 10
}

variable "storage_type" {
  type = string
  default = "gp2"
}

variable "engine" {
  type = string
  default = "mysql"
  validation {
    condition     = contains(["mysql", "postgres", "oracle-ee", "sqlserver-ex", "mariadb", "aurora", "aurora-mysql", "aurora-postgresql"], var.engine)
    error_message = "The engine must be one of: mysql, postgres, oracle-ee, sqlserver-ex, mariadb, aurora, aurora-mysql, aurora-postgresql."
  }
}

variable "engine_version" {
  type = string
  default = "8.0"
}

variable "instance_class" {
  type = string
  default = "db.t2.micro"
}

variable "db_name" {
  type = string
  default = "mydb"
}

variable "identifier" {
  type = string
  default = "dacdb"
}

variable "db_subnet_group" {
  type = string
  default = "vido_db_subnet_group"
}