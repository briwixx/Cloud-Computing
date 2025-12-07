# Configuration du fournisseur AzureRM
provider "azurerm" {
  features {}
    subscription_id = "90304447-11f6-4097-a50d-23555344115e"  # Ton ID de souscription Azure
}

# Test pour vérifier la création du réseau virtuel
run "check_virtual_network" {
  command = apply

  variables {
    vnet_name            = var.vnet_name
    address_space        = var.address_space
    location             = var.location
    resource_group_name  = var.resource_group_name
  }

  # Vérifier que le réseau virtuel existe et que ses propriétés sont correctes
  assert {
    condition     = azurerm_virtual_network.vnet.name == var.vnet_name
    error_message = "Le nom du réseau virtuel est incorrect"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.address_space[0] == var.address_space
    error_message = "L'espace d'adresses du réseau virtuel est incorrect"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.location == var.location
    error_message = "La localisation du réseau virtuel est incorrecte"
  }
}

run "check_subnet" {
  command = apply

  variables {
    resource_group_name  = var.resource_group_name
    vnet_name            = var.vnet_name
  }

  # Vérifier que le sous-réseau existe et que ses propriétés sont correctes
  assert {
    condition     = azurerm_subnet.database.name == "database-subnet"
    error_message = "Le nom du sous-réseau est incorrect"
  }

  assert {
    condition     = azurerm_subnet.database.address_prefixes[0] == "10.0.1.0/24"
    error_message = "Le préfixe d'adresse du sous-réseau est incorrect"
  }
}
