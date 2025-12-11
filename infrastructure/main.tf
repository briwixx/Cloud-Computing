terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_id" "suffix" {
  byte_length = 6
}

##########
#Resource Group
module "resource_group" {
  source = "./modules/resource_group"
  resource_group_name = "Cloud-computing-project"
  location            = var.location
  suffix             = random_id.suffix.hex
}

#Virtual Network
module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = module.resource_group.name
  location            = var.location
  vnet_name           = "vnet-10-0-0-0-16"
  address_space       = "10.0.0.0/16"
}
###########
#Database
module "database" {
  source              = "./modules/database"
  database_name       = "counter"
  resource_group_name = module.resource_group.name
  location            = var.location
  admin_user          = "adminuser"
  admin_password      = "P@ssword123"
  # Utiliser le subnet interne exporté par le module virtual_network
  subnet_id           = module.virtual_network.database_internal_subnet_id
  suffix              = random_id.suffix.hex
}
##########
#Web App
resource "azurerm_app_service_plan" "plan" {
  name                = "plan-test"
  location            = var.location
  resource_group_name = module.resource_group.name
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "frontend_app" {
  name                = "frontend-app-test${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = module.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
}

resource "azurerm_app_service" "backend_app" {
  name                = "backend-app-test${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = module.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
}

########
# Virtual Machines in DMZ
module "virtual_machines_dmz" {
  source              = "./modules/virtual_machines_dmz"
  vm_name             = "vm-dmz1"
  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.virtual_network.website_service1_subnet_id
  admin_username      = "adminuser"
  admin_password      = "I_sen123456"
  ssh_public_key      = "./.ssh/.ssh.pub"
}
module "virtual_machines_dmz_2" {
  source              = "./modules/virtual_machines_dmz"
  vm_name             = "vm-dmz2"
  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.virtual_network.website_service2_subnet_id
  admin_username      = "adminuser"
  admin_password      = "I_sen123456"
  ssh_public_key      = "./.ssh/.ssh.pub"
}
#########
# Virtual Machines in Internal Network
module "virtual_machines_internal" {
  source              = "./modules/virtual_machines_internal"
  vm_name             = "vm-internal1"
  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.virtual_network.department1_internal_subnet_id
  admin_username      = "adminuser"
  admin_password      = "I_sen123456"
  ssh_public_key      = "./.ssh/.ssh.pub"
}