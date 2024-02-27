// Event hub namespace
output "event_hub_namespace_id" {
  value = azurerm_eventhub_namespace.iot.id
}

output "event_hub_namespace_name" {
  value = azurerm_eventhub_namespace.iot.name
}


// Edge event hub
output "k8s_event_hub_id" {
  value = azurerm_eventhub.iot_k8s.id
}

output "k8s_event_hub_name" {
  value = azurerm_eventhub.iot_k8s.name
}

output "k8s_write_connection" {
  value     = azurerm_eventhub_authorization_rule.iot_k8s.primary_connection_string
  sensitive = true
}

output "k8s_read_connection" {
  value     = azurerm_eventhub_authorization_rule.ua_twin.primary_connection_string
  sensitive = true
}

// History event hub
output "twin_event_hub_id" {
  value = azurerm_eventhub.digital_twin.id
}

output "twin_event_hub_name" {
  value = azurerm_eventhub.digital_twin.name
}

output "twin_primary_connection" {
  value     = azurerm_eventhub_authorization_rule.digital_twin.primary_connection_string
  sensitive = true
}

output "twin_secondary_connection" {
  value     = azurerm_eventhub_authorization_rule.digital_twin.secondary_connection_string
  sensitive = true
}
