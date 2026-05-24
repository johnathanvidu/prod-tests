variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
}

variable "engine_version" {
  description = "OpenSearch engine version (e.g. OpenSearch_3.3, OpenSearch_2.11, OpenSearch_1.3)"
  type        = string
  default     = "OpenSearch_3.3"
}

variable "instance_type" {
  description = "OpenSearch instance type (e.g. t3.small.search, t3.medium.search)"
  type        = string
  default     = "t3.small.search"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "volume_size_gb" {
  description = "EBS volume size in GB"
  type        = number
  default     = 10
}

variable "master_user_name" {
  description = "Master username for OpenSearch fine-grained access control"
  type        = string
}

variable "master_user_password" {
  description = "Master password for OpenSearch fine-grained access control"
  type        = string
  sensitive   = true
}
