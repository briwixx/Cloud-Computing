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

output "connection_string" {
  value = "Server=tcp:${azurerm_mssql_server.server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db.name};Persist Security Info=False;User ID=${var.admin_user};Password=${var.admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

