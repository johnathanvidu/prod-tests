output "public_ip" {
  value = azurerm_windows_virtual_machine.example.network_interface_ids[0]
}

output "password" {
  value = azurerm_windows_virtual_machine.example.admin_password
  sensitive = true
}
