resource "azurerm_linux_virtual_machine_scale_set" "vmscaleset" {
  depends_on          = [azurerm_resource_group.rg]
  name                = "harilinuxvmss"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = var.admin_user
  admin_password      = var.admin_password
  # OS reference
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  # OS Disk Reference
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  disable_password_authentication = false

  /*  custom_data = base64encode("${file("apache.sh")}")*/

  # Boot Diagnostics
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.hari-storage.primary_blob_endpoint
  }

  # Network Interface
  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backendpool.id]
      primary                                = true
    }
  }
}

# Extension used to configure the Apache on Scaleset VM
resource "azurerm_virtual_machine_scale_set_extension" "linux-ext" {
  name                         = "lnx-webserver"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmscaleset.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings                     = <<SETTINGS
    {
        "script": "${filebase64("apache.sh")}"
    }
    SETTINGS
}


#  VMSS Auto Scalling
resource "azurerm_monitor_autoscale_setting" "vmss" {
  depends_on          = [azurerm_lb.winvmss_lb]
  name                = "WebserverAutoscale"
  resource_group_name = var.rg
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmscaleset.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmscaleset.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}