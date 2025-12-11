############################################
# Réseau DMZ pour la communication avec l'extérieur
resource "azurerm_virtual_network" "dmz" {
  name                = "reseau_dmz"             
  address_space       = ["10.1.0.0/16"]     
  location            = var.location          
  resource_group_name = var.resource_group_name   
}
# Réseau interne pour les ressources internes
resource "azurerm_virtual_network" "reseau_interne" {
  name                = "reseau_interne"             
  address_space       = ["10.2.0.0/16"]       
  location            = var.location             
  resource_group_name = var.resource_group_name   
}

######################################
##### La zone DMZ va être séparée en 3 sous-réseaux service1, service2 et service3
#Sous-réseaux DMZ :
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

#Le réseau interne va être séparé en 3 sous-réseaux : base de données, department1 et department2
#Sous-réseaux internes :
resource "azurerm_subnet" "database_internal_subnet" {
  name                 = "database_internal-subnet"
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


##################################
#Peering entre les deux réseaux --> Autoriser la communication entre les deux réseaux DMZ et internal
resource "azurerm_virtual_network_peering" "internal_to_dmz" {
  name                      = "internal-to-dmz"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.reseau_interne.name
  remote_virtual_network_id = azurerm_virtual_network.dmz.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "dmz_to_internal" {
  name                      = "dmz-to-internal"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.dmz.name
  remote_virtual_network_id = azurerm_virtual_network.reseau_interne.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}


#####################################
#NSG pour le dmz --> Filtre le trafic entrant et sortant du sous-réseau DMZ
resource "azurerm_network_security_group" "dmz_nsg" {
  name                = "dmz-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTP-Inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
#Associer le NSG aux subnets DMZ
resource "azurerm_subnet_network_security_group_association" "dmz_nsg_association1" {
  subnet_id                 = azurerm_subnet.website_service1_subnet.id
  network_security_group_id = azurerm_network_security_group.dmz_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "dmz_nsg_association2" {
  subnet_id                 = azurerm_subnet.website_service2_subnet.id
  network_security_group_id = azurerm_network_security_group.dmz_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "dmz_nsg_association3" {
  subnet_id                 = azurerm_subnet.website_service3_subnet.id
  network_security_group_id = azurerm_network_security_group.dmz_nsg.id
}
######################################
# NSG pour le réseau interne
# inbound pas bloqués car bloqués par défaut par Azure
resource "azurerm_network_security_group" "internal_nsg" {
  name                = "internal-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-from-DMZ"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.website_service1_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Deny-TCP-others"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-out-to-DMZ"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.website_service1_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }
}
#Associer le NSG aux subnets internes
resource "azurerm_subnet_network_security_group_association" "internal_nsg_association1" {
  subnet_id                 = azurerm_subnet.database_internal_subnet.id
  network_security_group_id = azurerm_network_security_group.internal_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "internal_nsg_association2" {
  subnet_id                 = azurerm_subnet.department1_internal_subnet.id
  network_security_group_id = azurerm_network_security_group.internal_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "internal_nsg_association3" {
  subnet_id                 = azurerm_subnet.department2_internal_subnet.id
  network_security_group_id = azurerm_network_security_group.internal_nsg.id
}