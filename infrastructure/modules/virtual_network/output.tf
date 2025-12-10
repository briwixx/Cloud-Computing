output "subnet_id" {
  description = "ID de la subnet interne utilisée pour la base de données"
  value       = azurerm_subnet.database_internal_subnet.id
}
