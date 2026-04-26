variable "resource_group" {
  type        = string
  description = "Name of the Azure resource group where the Key Vault will be created"
}

variable "keyvault_name" {
  type        = string
  description = "Name of the Key Vault (must be globally unique, 3-24 alphanumeric and hyphens)"
  default     = "torque-sample-kv"
}

variable "sku_name" {
  type        = string
  description = "SKU for the Key Vault (standard or premium)"
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be either 'standard' or 'premium'."
  }
}

variable "environment_tag" {
  type        = string
  description = "Value for the environment tag applied to the Key Vault"
  default     = "dev"
}
