# Public Ip address of LB
resource "azurerm_public_ip" "lbpip" {
  depends_on          = [azurerm_resource_group.rg]
  name                = "lbpip"
  allocation_method   = "Static"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Standard"
}

#Public Ip for win iis
resource "azurerm_public_ip" "iispip" {
  depends_on          = [azurerm_resource_group.rg]
  name                = "iispip"
  allocation_method   = "Static"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Standard"
}


# Network Load Balancer
resource "azurerm_lb" "winvmss_lb" {
  name                = "winvmss_lb"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Standard"


  frontend_ip_configuration {
    name                 = "VMSS"
    public_ip_address_id = azurerm_public_ip.lbpip.id
    #zones = ["1","3"]
  }

  frontend_ip_configuration {
    name                 = "win-IIS"
    public_ip_address_id = azurerm_public_ip.iispip.id

  }
}

# LB Backend Pool for VMSS
resource "azurerm_lb_backend_address_pool" "backendpool" {
  name            = "backend"
  loadbalancer_id = azurerm_lb.winvmss_lb.id
}

# LB Backend Pool for IIS Server
resource "azurerm_lb_backend_address_pool" "iisbackend" {
  name            = "iisbackend"
  loadbalancer_id = azurerm_lb.winvmss_lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "win-pool" {
  #network_interface_id    = "${azurerm_network_interface.test.id}"
  network_interface_id  = azurerm_network_interface.jumpbox-interface.id
  ip_configuration_name = "internal"
  #backend_address_pool_id = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.iisbackend.id
}


# LB Probe
resource "azurerm_lb_probe" "http_probe" {
  name            = "http_probe"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.winvmss_lb.id
}

resource "azurerm_lb_probe" "win_iis_probe" {
  name            = "win_iis_probe"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.winvmss_lb.id
}


# Lb Rules for Port 80
resource "azurerm_lb_rule" "lb_rule" {
  name                           = "lb_rule_http"
  loadbalancer_id                = azurerm_lb.winvmss_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "VMSS"
  probe_id                       = azurerm_lb_probe.http_probe.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.backendpool.id]
}

resource "azurerm_lb_rule" "iis_rule" {
  name                           = "lb_rule_iis_http"
  loadbalancer_id                = azurerm_lb.winvmss_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "win-IIS"
  probe_id                       = azurerm_lb_probe.win_iis_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.iisbackend.id]
}

# LB probe for RDP
resource "azurerm_lb_probe" "rdp_probe" {
  name            = "rdp_probe"
  protocol        = "Tcp"
  port            = 3389
  loadbalancer_id = azurerm_lb.winvmss_lb.id
}

# LB rule for RDP
resource "azurerm_lb_rule" "rdp_lb_rule" {
  name                           = "lb_rule_rdp"
  loadbalancer_id                = azurerm_lb.winvmss_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "VMSS"
  probe_id                       = azurerm_lb_probe.rdp_probe.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.backendpool.id]
}

resource "azurerm_lb_probe" "win_rdp_probe" {
  name            = "win_rdp_probe"
  protocol        = "Tcp"
  port            = 3389
  loadbalancer_id = azurerm_lb.winvmss_lb.id
}

resource "azurerm_lb_rule" "win_rdp_rule" {
  name                           = "win_rdp_rule"
  loadbalancer_id                = azurerm_lb.winvmss_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "win-IIS"
  probe_id                       = azurerm_lb_probe.win_iis_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.iisbackend.id]
}
# resource "azurerm_lb_rule" "rdp_win_rule" {
# name    = "lb_rule_win_rdp"
# loadbalancer_id = azurerm_lb.winvmss_lb.id
# protocol                       = "Tcp"
# frontend_port                  = 3389
# backend_port                   = 3389
# frontend_ip_configuration_name = "win-IIS"
# probe_id                       = azurerm_lb_probe.http_probe.id
# }
# LB probe for SSH
resource "azurerm_lb_probe" "ssh_probe" {
  name            = "ssh_probe"
  protocol        = "Tcp"
  port            = 22
  loadbalancer_id = azurerm_lb.winvmss_lb.id
}


# LB rule for SSH
resource "azurerm_lb_rule" "ssh_lb_rule" {
  name                           = "lb_rule_SSH"
  loadbalancer_id                = azurerm_lb.winvmss_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "VMSS"
  probe_id                       = azurerm_lb_probe.ssh_probe.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.backendpool.id]
}


# # Allow Inboud NAT to Backend VM
# resource "azurerm_lb_nat_pool" "inbound_http" {
#   resource_group_name            = var.rg
#   loadbalancer_id                = azurerm_lb.winvmss_lb.id
#   name                           = "httppool"
#   protocol                       = "Tcp"
#   frontend_port_start            = 80
#   frontend_port_end              = 81
#   backend_port                   = 80
#   frontend_ip_configuration_name = "PublicIP"
# }