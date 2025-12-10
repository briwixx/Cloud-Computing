terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
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

resource "azurerm_service_plan" "backend_plan" {
  name                = "backend-plan-${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = module.resource_group.name
  os_type             = "Linux"
  sku_name            = "B1"   # minimum pour Node sur Linux
}

resource "azurerm_linux_web_app" "backend_app" {
  name                = "backend-app-${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = module.resource_group.name
  service_plan_id     = azurerm_service_plan.backend_plan.id

  site_config {
    application_stack {
      node_version = "20-lts"
    }
  }

  app_settings = {
    DB_CONNECTION_STRING = module.database.connection_string
  }
}


resource "null_resource" "deploy_frontend" {
  depends_on = [
    azurerm_app_service.frontend_app
  ]

  # Si le zip change, Terraform re-déclenche le déploiement
  triggers = {
    zip_hash = filesha256("${path.module}/app.zip")
  }

  provisioner "local-exec" {
    command = "az webapp deployment source config-zip --resource-group ${module.resource_group.name} --name ${azurerm_app_service.frontend_app.name} --src ${path.module}/app.zip"
  }
}

resource "null_resource" "deploy_backend" {
  depends_on = [
    azurerm_linux_web_app.backend_app
  ]

  triggers = {
    zip_hash = filesha256("${path.module}/backend.zip")
  }

  provisioner "local-exec" {
    command = "az webapp deployment source config-zip --resource-group ${module.resource_group.name} --name ${azurerm_linux_web_app.backend_app.name} --src ${path.module}/backend.zip"
  }
}
