resource "random_id" "suffix" {
  byte_length = 3
}

resource "azurerm_storage_account" "function_storage" {
  name                     = "functstorage${random_id.suffix.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "function_plan" {
  name                = "function-plan-${random_id.suffix.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function_app" {
  name                       = "counter-function-${random_id.suffix.hex}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  zip_deploy_file = "${path.module}/../function_code/function.zip"

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  app_settings = {
    SQL_SERVER   = var.sql_server
    SQL_DATABASE = var.sql_database
    SQL_USER     = var.sql_user
    SQL_PASSWORD = var.sql_password
  }
}
