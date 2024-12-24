output "vm1_id" {
  value = azurerm_virtual_machine.example[0].id
}

output "vm2_id" {
  value = azurerm_virtual_machine.example[1].id
}
