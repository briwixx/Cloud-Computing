resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name             # Nom du réseau virtuel
  address_space       = [var.address_space]       # Plage d'adresses IP du réseau virtuel
  location            = var.location              # Région Azure où le réseau virtuel sera créé
  resource_group_name = var.resource_group_name   # Nom du groupe de ressources où le réseau virtuel sera déployé
}

resource "azurerm_subnet" "database" {
  name                 = "database-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}