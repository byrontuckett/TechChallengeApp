output "app_service_name" {
  value = azurerm_app_service.tca-docker-app.name
}

output "app_service_default_hostname" {
  value = "https://${azurerm_app_service.tca-docker-app.default_site_hostname}"
}

output "db_private_link_endpoint_ip" {
  description = "PostgresSQL Private Link Endpoint IP"
  value       = data.azurerm_private_endpoint_connection.endpoint-connection.private_service_connection.0.private_ip_address
}
