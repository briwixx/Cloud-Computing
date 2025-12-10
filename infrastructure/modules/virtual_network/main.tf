resource "azurerm_virtual_network" "dmz" {
  name                = "reseau_dmz"             # Nom du réseau virtuel
  address_space       = ["10.1.0.0/16"]       # Plage d'adresses IP du réseau virtuel
  location            = var.location              # Région Azure où le réseau virtuel sera créé
  resource_group_name = var.resource_group_name   # Nom du groupe de ressources où le réseau virtuel sera déployé
}
# Réseau interne pour les ressources internes
resource "azurerm_virtual_network" "reseau_interne" {
  name                = "reseau_interne"             # Nom du réseau virtuel
  address_space       = ["10.2.0.0/16"]       # Plage d'adresses IP du réseau virtuel
  location            = var.location              # Région Azure où le réseau virtuel sera créé
  resource_group_name = var.resource_group_name   # Nom du groupe de ressources où le réseau virtuel sera déployé
}
#Pour faire le lien entre DMZ et réseau interne -> peering
resource "azurerm_virtual_network_peering" "dmz_to_internal" {
  name                      = "dmz-to-internal"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.dmz.name
  remote_virtual_network_id = azurerm_virtual_network.reseau_interne.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

#DMZ Subnets
resource "azurerm_subnet" "website_service1-subnet" {
  name                 = "website_service1-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dmz.name
  address_prefixes     = ["10.1.1.0/24"]
}
resource "azurerm_subnet" "website_service2-subnet" {
  name                 = "website_service2-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dmz.name
  address_prefixes     = ["10.1.2.0/24"]
}
resource "azurerm_subnet" "website_service3-subnet" {
  name                 = "website_service3-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dmz.name
  address_prefixes     = ["10.1.3.0/24"]
}

#Internal Subnets
resource "azurerm_subnet" "database_internal-subnet" {
  name                 = "database_internal-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.reseau_interne.name
  address_prefixes     = ["10.2.1.0/24"]
}
resource "azurerm_subnet" "Department1_internal-subnet" {
  name                 = "Department1_internal-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.reseau_interne.name
  address_prefixes     = ["10.2.2.0/24"]
}
resource "azurerm_subnet" "Department2_internal-subnet" {
  name                 = "Department2_internal-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.reseau_interne.name
  address_prefixes     = ["10.2.3.0/24"]
}