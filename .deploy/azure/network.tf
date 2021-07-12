resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

# vNet
# ----------
resource "azurerm_virtual_network" "tca-vnet" {
  name                = "${random_string.random.result}-tca-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet for App
# ----------
resource "azurerm_subnet" "app-snet" {
  name                 = "${random_string.random.result}-appsnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.tca-vnet.name
  address_prefixes     = ["10.1.1.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

# Subnet for DB
# ----------
resource "azurerm_subnet" "db-snet" {
  name                 = "${random_string.random.result}-dbsnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.tca-vnet.name
  address_prefixes     = ["10.1.2.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

# Private DNS Zone for Postgres
# ----------
resource "azurerm_private_dns_zone" "dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

# Private Endpoint connection. Deploys the link to the subnet
# ----------
resource "azurerm_private_endpoint" "pe0" {

  name                = "${random_string.random.result}-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.db-snet.id

  depends_on = [
    azurerm_subnet.db-snet,
    azurerm_postgresql_server.postgressql_server
  ]

  private_dns_zone_group {
    name                 = "tcadnszone"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns.id]
  }

  private_service_connection {
    name                           = "${random_string.random.result}-privateserviceconnection"
    private_connection_resource_id = azurerm_postgresql_server.postgressql_server.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

}

# DB Private Endpoint Connecton
# ----------
data "azurerm_private_endpoint_connection" "endpoint-connection" {
  depends_on          = [azurerm_private_endpoint.pe0]
  name                = azurerm_private_endpoint.pe0.name
  resource_group_name = azurerm_resource_group.rg.name
}

# Link the private zone to the virtual network
# ---------
resource "azurerm_private_dns_zone_virtual_network_link" "private-vnet-link" {
  name                  = "pvtlink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.tca-vnet.id
}


# # Private DNS Zone A Record for the DB Server
# # ----------
# resource "azurerm_private_dns_a_record" "dns-db-a-record" {
#   name                = lower(azurerm_postgresql_server.postgressql_server.name)
#   zone_name           = azurerm_private_dns_zone.dns.name
#   resource_group_name = azurerm_resource_group.rg.name
#   ttl                 = 300
#   records             = [data.azurerm_private_endpoint_connection.endpoint-connection.private_service_connection.0.private_ip_address]

#   depends_on = [
#     azurerm_postgresql_server.postgressql_server
#   ]
# }
