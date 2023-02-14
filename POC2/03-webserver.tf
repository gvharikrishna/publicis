## Windows Webserver without VM Scaleset, Hosted directly to public

# Create network interface
resource "azurerm_network_interface" "myvmnic" {
  depends_on          = [azurerm_resource_group.rg]
  name                = "myNIC"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id = azurerm_public_ip.vmpip.id
  }
}

# Connect the security group to the network interface
# resource "azurerm_network_interface_security_group_association" "nsgupdate" {
#   network_interface_id      = azurerm_network_interface.myvmnic.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }



/*#Public ip for Jumpbox
resource "azurerm_public_ip" "vmpip" {
  depends_on          = [azurerm_resource_group.rg]
  name                = "vmpip"
  allocation_method   = "Static"
  location            = var.location
  resource_group_name = var.rg
  # sku = "Standard"
}*/

# Windows Jumpbox 
resource "azurerm_network_interface" "jumpbox-interface" {
  name                = "jumpboxnic"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.vmpip.id
    # loadbalancer_id = [azurerm_lb_backend_address_pool.iisbackend.id]
  }
}

# Network Interface Security Group association
resource "azurerm_network_interface_security_group_association" "nsgupdate-jumpbox" {
  network_interface_id      = azurerm_network_interface.jumpbox-interface.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Windows VM
resource "azurerm_windows_virtual_machine" "vm-jumpbox" {
  name                = "vm-jumpbox"
  resource_group_name = var.rg
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.win_admin_user
  admin_password      = var.win_admin_password
  network_interface_ids = [
    azurerm_network_interface.jumpbox-interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


# Windows VM Extension to bootstrap IIS
resource "azurerm_virtual_machine_extension" "webserver11" {
  name                 = "webserver1"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm-jumpbox.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
 {
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
 }
SETTINGS


  tags = {
    environment = "Production"
  }
}