resource "azurerm_app_service_plan" "asp" {
  name                = "${var.name}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = var.sku_tier
    size = var.sku_size
  }

  kind = "Linux"
  reserved = true
}

resource "azurerm_linux_web_app" "web" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_app_service_plan.asp.id
  site_config {
    # intentionally left blank
  }

  app_settings = merge({
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }, var.app_settings)

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service" "frontend_app-dmz" {
  name                = "frontend-app-test"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
}