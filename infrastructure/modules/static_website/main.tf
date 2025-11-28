resource "azurerm_storage_account" "static_site" {
  name                     = "storagetodo${random_id.rand.hex}"
  resource_group_name      = var.resource_group_name   
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document     = "index.html"
    error_404_document = "index.html"
  }
}

resource "random_id" "rand" {
  byte_length = 4
}

resource "azurerm_storage_blob" "index_html" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.static_site.name
  storage_container_name = "$web"
  type                   = "Block"
  source = "${path.module}/../frontend_files/index.html"
  content_type           = "text/html"

  depends_on = [
    azurerm_storage_account.static_site
  ]
}
