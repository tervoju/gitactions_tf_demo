// Event hub namespace
output "event_hub_namespace_id" {
  value = azurerm_eventhub_namespace.ns.id
}

output "event_hub_namespace_name" {
  value = azurerm_eventhub_namespace.ns.name
}


// Edge event hub
output "event_hub_id" {
  value = azurerm_eventhub.hub.id
}

output "event_hub_name" {
    value = azurerm_eventhub.hub.name
}
