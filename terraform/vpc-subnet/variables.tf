variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "create_subnet" {
  type        = bool
  description = "Whether to create a public subnet within the VPC"
  default     = true
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for the subnet. Only used when create_subnet is true."
  default     = "10.0.1.0/24"
}
