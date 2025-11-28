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
