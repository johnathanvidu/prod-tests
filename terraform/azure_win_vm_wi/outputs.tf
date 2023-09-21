output "public_ip" {
  value = azurerm_public_ip.example.ip_address
}

output "password" {
  value = azurerm_windows_virtual_machine.example.admin_password
  sensitive = true
}
