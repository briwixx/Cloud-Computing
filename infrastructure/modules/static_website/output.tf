output "static_website_url" {
  value = azurerm_storage_account.static_site.primary_web_endpoint
}
