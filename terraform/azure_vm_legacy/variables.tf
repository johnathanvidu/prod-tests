
variable "tenant_id" {
  type = string
  description = "Tenant id"
}

variable "subscription_id" {
  type = string
  description = "Subscription id"
}

variable "client_id" {
  type = string
  description = "Client id"
}

variable "client_secret" {
  type = string
  description = "Client Secret"
}

variable "vm_name" {
  type = string
  default = "vidovm"
  description = "VM Name"
}

variable "resource_group" {
  type = string
  default = "vido_rg"
  description = "resource group name"
}
