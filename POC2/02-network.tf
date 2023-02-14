# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  depends_on          = [azurerm_virtual_network.vnet]
  name                = "nsg1"
  location            = var.location
  resource_group_name = var.rg

  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "RDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# VNET 
resource "azurerm_virtual_network" "vnet" {
  depends_on          = [azurerm_resource_group.rg]
  name                = var.vnet
  location            = var.location
  resource_group_name = var.rg
  address_space       = ["10.80.0.0/16"]
  # dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Production"
  }
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet1
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.80.1.0/24"]
}

# resource "azurerm_subnet" "vpnsubnet" {
#   name                 = "GatewaySubnet"
#   resource_group_name  = var.rg
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.80.2.0/24"]
# }


#  VPN
#  resource "azurerm_virtual_network_gateway" "vpn" {
#   depends_on = [azurerm_resource_group.rg]
#   name                = var.vpn
#   location            = var.location
#   resource_group_name = var.rg

#   type     = "Vpn"
#   vpn_type = "RouteBased"

#   active_active = false
#   enable_bgp    = false
#   sku           = "Basic"

#   ip_configuration {
#     name                          = "vnetGatewayConfig"
#     public_ip_address_id          = azurerm_public_ip.pip.id
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.vpnsubnet.id
#    }
#     vpn_client_configuration {
#     address_space = ["10.82.0.0/24"]
#   }
# }