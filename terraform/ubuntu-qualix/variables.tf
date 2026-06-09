variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "qualix_public_ip" {
  description = "Public IP or hostname of the QualiX server"
  type        = string
}

variable "use_public_ip" {
  description = "Connect QualiX to the instance's public IP. Set false to use the private IP"
  type        = bool
  default     = true
}
