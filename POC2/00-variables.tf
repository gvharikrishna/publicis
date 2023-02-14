variable "rg" {
  default = "hari-poc"
}

variable "location" {
  default = "eastus"
}

variable "vnet" {
  default = "hari-vnet1"
}

variable "subnet1" {
  default = "subnet1"
}

variable "vpn" {
  default = "vpn"
}

variable "pip" {
  default = "pip"
}

variable "vmpip" {
  default = "vmpip"
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Default password for admin account"
  default     = "Computer@123"
}

variable "win_admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
  default     = "adminuser"
}

variable "win_admin_password" {
  description = "Default password for admin account"
  default     = "Computer@123"
}