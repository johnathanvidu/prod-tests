variable "vpc_id" {
  description = "The ID of the existing VPC where the subnets will be created"
  type        = string
}

variable "subnets_config" {
  description = "A list of objects defining the subnets to create. Each object specifies the subnet bits, number of subnets, and type."
  type = list(object({
    subnet_bits = number
    num_subnets = number
    type        = string
  }))
  default = []
}
