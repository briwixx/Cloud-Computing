variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  description = "Nom de la Web App"
  type        = string
  default     = "my-webapp"
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "sku_size" {
  type    = string
  default = "F1"
}

variable "runtime_stack" {
  description = "Ex: 'DOTNETCORE|6.0' ou 'NODE|18-lts' ; utilisé pour site_config"
  type        = string
  default     = "NODE|18-lts"
}

variable "app_settings" {
  type    = map(string)
  default = {}
}