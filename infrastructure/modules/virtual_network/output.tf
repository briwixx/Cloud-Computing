// Exporte l'ID du VNet DMZ
output "dmz_vnet_id" {
	value = azurerm_virtual_network.dmz.id
}

// Exporte l'ID du VNet interne
output "internal_vnet_id" {
	value = azurerm_virtual_network.reseau_interne.id
}

// Exporte l'ID du subnet interne destiné à la base de données
output "database_internal_subnet_id" {
	value = azurerm_subnet.database_internal_subnet.id
}

// Exporte tous les subnets DMZ (utile si besoin)
output "dmz_subnet_ids" {
	value = [
				azurerm_subnet.website_service1_subnet.id,
				azurerm_subnet.website_service2_subnet.id,
				azurerm_subnet.website_service3_subnet.id,
	]
}

// Outputs individuels pour faciliter l'appel depuis le module racine
output "website_service1_subnet_id" {
	value = azurerm_subnet.website_service1_subnet.id
}

output "website_service2_subnet_id" {
	value = azurerm_subnet.website_service2_subnet.id
}

output "website_service3_subnet_id" {
	value = azurerm_subnet.website_service3_subnet.id
}

output "department1_internal_subnet_id" {
	value = azurerm_subnet.department1_internal_subnet.id
}

output "department2_internal_subnet_id" {
	value = azurerm_subnet.department2_internal_subnet.id
}
