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

#Database
module "database" {
  source              = "./modules/database"
  database_name       = "counter"
  resource_group_name = module.resource_group.name
  location            = var.location
  admin_user          = "adminuser"
  admin_password      = "P@ssword123"
  subnet_id           = module.virtual_network.subnet_id
  suffix             = random_id.suffix.hex
}


module "static_website" {
  source              = "./modules/static_website"
  resource_group_name = module.resource_group.name
  location            = var.location
}
