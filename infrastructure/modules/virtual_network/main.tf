resource "azurerm_virtual_network" "dmz" {
  name                = "reseau_dmz"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network" "reseau_interne" {
  name                = "reseau_interne"
  address_space       = ["10.2.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network_peering" "dmz_to_internal" {
  name                      = "dmz-to-internal"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.dmz.name
  remote_virtual_network_id = azurerm_virtual_network.reseau_interne.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# DMZ Subnets
resource "azurerm_subnet" "website_service1_subnet" {
  name                 = "website_service1-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dmz.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "website_service2_subnet" {
  name                 = "website_service2-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dmz.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet" "website_service3_subnet" {
  name                 = "website_service3-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dmz.name
  address_prefixes     = ["10.1.3.0/24"]
}

# Internal Subnets
resource "azurerm_subnet" "database_internal_subnet" {
  name                 = "database_internal-subnet"      # nom côté Azure
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.reseau_interne.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "department1_internal_subnet" {
  name                 = "Department1_internal-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.reseau_interne.name
  address_prefixes     = ["10.2.2.0/24"]
}

resource "azurerm_subnet" "department2_internal_subnet" {
  name                 = "Department2_internal-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.reseau_interne.name
  address_prefixes     = ["10.2.3.0/24"]
}
