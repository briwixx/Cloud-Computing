# Renvoie URL du serveur SQL Azure
output "sql_connection_string" {
  value =azurerm_mssql_server.server.fully_qualified_domain_name
}

# Renvoie le nom du serveur SQL Azure
output "server_name" {
  value = azurerm_mssql_server.server.name
}

# Renvoie le nom de la base de données créée
output "database_name" {
  value = azurerm_mssql_database.db.name
}