# Renvoie URL du serveur SQL Azure
output "sql_connection_string" {
  value =azurerm_mssql_server.server.fully_qualified_domain_name
}

# Renvoie le nom du serveur SQL Azure
output "server_name" {
  value = azurerm_mssql_server.server.name
}

# FQDN du serveur SQL (ex: server123.database.windows.net)
output "sql_server_fqdn" {
  value = azurerm_mssql_server.server.fully_qualified_domain_name
}

# Nom de la base (ex: mydatabase)
output "sql_database_name" {
  value = azurerm_mssql_database.db.name
}

# Login admin
output "sql_admin_user" {
  value = azurerm_mssql_server.server.administrator_login
}

# Mot de passe admin
output "sql_admin_password" {
  value     = azurerm_mssql_server.server.administrator_login_password
  sensitive = true
}
