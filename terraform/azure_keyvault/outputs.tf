output "keyvault_name" {
  description = "Name of the provisioned Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "keyvault_id" {
  description = "Azure resource ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "keyvault_uri" {
  description = "Vault URI for accessing secrets"
  value       = azurerm_key_vault.kv.vault_uri
}
