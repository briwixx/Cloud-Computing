output "web_app_default_site_hostname" {
  # Build hostname from the resource name since the provider resource does not expose
  # a `default_site_hostname` attribute in this provider version.
  value = "${azurerm_linux_web_app.web.name}.azurewebsites.net"
}

output "web_app_id" {
  value = azurerm_linux_web_app.web.id
}