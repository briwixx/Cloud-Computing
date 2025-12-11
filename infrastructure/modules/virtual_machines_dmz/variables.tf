variable "vm_name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "subnet_id" { type = string }                # <-- lien vers le module virtual_network
variable "admin_username" { type = string }
variable "admin_password" { type = string }
variable "vm_size" {
	type    = string
	default = "Standard_B1s"
}

variable "image_publisher" {
	type    = string
	default = "Canonical"
}

variable "image_offer" {
	type    = string
	default = "UbuntuServer"
}

variable "image_sku" {
	type    = string
	default = "20_04-lts"
}

variable "ssh_public_key" {
  type = string
}

variable "create_public_ip" {
	description = "Whether to create a public IP for the VM"
	type        = bool
	default     = false
}
