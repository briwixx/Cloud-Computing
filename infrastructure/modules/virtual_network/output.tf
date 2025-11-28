# Retourne l'ID du subnet
output "subnet_id" {
  value = azurerm_subnet.database.id
}