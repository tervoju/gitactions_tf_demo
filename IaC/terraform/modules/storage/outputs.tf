output "storage_account_id" {
  value = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "storage_account_connection_string" {
  value = azurerm_storage_account.storage.primary_connection_string
}

output "storage_container_name" {
  value = var.create_blob ? azurerm_storage_container.storage[0].name : null
}
