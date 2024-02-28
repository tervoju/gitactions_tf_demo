output "key_vault_id" {
  value = azurerm_key_vault.vault.id
}

output "key_vault_name" {
  value = azurerm_key_vault.vault.name
}

output "rbac_role_id" {
  value = azurerm_role_assignment.officer.id
}
