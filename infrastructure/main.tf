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
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_id" "suffix" {
  byte_length = 6
}

# ---------------------------------------------------------
# Resource Group
# ---------------------------------------------------------
module "resource_group" {
  source              = "./modules/resource_group"
  resource_group_name = "Cloud-computing-project"
  location            = var.location
  suffix              = random_id.suffix.hex
}

# ---------------------------------------------------------
# Virtual Network
# ---------------------------------------------------------
module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = module.resource_group.name
  location            = var.location
  vnet_name           = "vnet-10-0-0-0-16"
  address_space       = "10.0.0.0/16"
}

# ---------------------------------------------------------
# Database
# ---------------------------------------------------------
module "database" {
  source              = "./modules/database"
  database_name       = "counter"
  resource_group_name = module.resource_group.name
  location            = var.location
  admin_user          = "adminuser"
  admin_password      = "P@ssword123"
  subnet_id           = module.virtual_network.database_internal_subnet_id
  suffix              = random_id.suffix.hex
}

# ---------------------------------------------------------
# Frontend App Service
# ---------------------------------------------------------
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
  name                = "frontend-app-${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = module.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
}

# ---------------------------------------------------------
# Backend App Service
# ---------------------------------------------------------
resource "azurerm_service_plan" "backend_plan" {
  name                = "backend-plan-${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = module.resource_group.name
  os_type             = "Linux"
  sku_name            = "B1"
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

# ---------------------------------------------------------
# FRONTEND CONFIG.JS GENERATION
# ---------------------------------------------------------
locals {
  backend_url = "https://${azurerm_linux_web_app.backend_app.default_hostname}"
}

resource "local_file" "frontend_config" {
  content = templatefile(
    "${path.module}/../login/js/config.js.tftpl",
    { backend_url = local.backend_url }
  )
  filename = "${path.module}/../login/js/config.js"
}

# ---------------------------------------------------------
# ZIP FRONTEND
# ---------------------------------------------------------
data "archive_file" "frontend_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../login"
  output_path = "${path.module}/app.zip"

  depends_on = [local_file.frontend_config]
}

# ---------------------------------------------------------
# ZIP BACKEND
# ---------------------------------------------------------
data "archive_file" "backend_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../backend"
  output_path = "${path.module}/backend.zip"
}



# ---------------------------------------------------------
# DEPLOY FRONTEND
# ---------------------------------------------------------
resource "null_resource" "deploy_frontend" {
  depends_on = [
    azurerm_app_service.frontend_app,
    data.archive_file.frontend_zip
  ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "az webapp deploy --resource-group ${module.resource_group.name} --name ${azurerm_app_service.frontend_app.name} --src-path ${data.archive_file.frontend_zip.output_path} --type zip"
  }
}


# On déploie le backend Node.js dans l'App Service Linux après sa création
resource "null_resource" "deploy_backend" {
  depends_on = [
    azurerm_linux_web_app.backend_app,
    data.archive_file.backend_zip
  ]

  triggers = {
    zip_hash = data.archive_file.backend_zip.output_base64sha256
  }

  provisioner "local-exec" {
    command = "az webapp deploy --resource-group ${module.resource_group.name} --name ${azurerm_linux_web_app.backend_app.name} --src-path ${data.archive_file.backend_zip.output_path} --type zip"
  }
}


# ---------------------------------------------------------
# OUTPUTS
# ---------------------------------------------------------
output "backend_url" {
  value = azurerm_linux_web_app.backend_app.default_hostname
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