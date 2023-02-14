terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.43.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.location
  tags = {
    "Environment" = "Production"
    "Owner"       = "IT"
    "Cost Center" = "Business"
  }
}

resource "azurerm_storage_account" "hari-storage" {
  name                     = "hariblob"
  resource_group_name      = var.rg
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"


  tags = {
    "Environment" = "Prod"
  }
}

resource "azurerm_storage_container" "hari-blob" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.hari-storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "hari_storage_blob" {
  name                   = "apache.sh"
  storage_account_name   = azurerm_storage_account.hari-storage.name
  storage_container_name = azurerm_storage_container.hari-blob.name
  type                   = "Block"
  source                 = "apache.sh"
}