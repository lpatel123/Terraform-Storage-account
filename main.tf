terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.111.0"
    }
  }
}
provider "azurerm" {
  #skip_provider_registration = "true"
  subscription_id = "09b77a0a-5d5e-48de-ac23-606c036df15e"
  tenant_id = "524d6af4-f6e6-4472-9533-cf02e57bdeef"
  client_id = "e73e6aae-0f93-4ec6-bc75-a413304792f1"
  client_secret = "4EC8Q~mWPy3sc31jHCQHun4m6U6vJE.b-OOl-bjG"
  features {}
}

   
   resource "azurerm_resource_group" "RG1" {
     name     = var.Resource_group_name
     location = var.location
   }




   # Reference the existing VNet and Subnet
   data "azurerm_virtual_network" "cws-vnet-dev" {
     name                = var.vnet_name
     resource_group_name = var.Existing_rg
   }

   data "azurerm_subnet" "cws-subnet-dev" {
     name                 = var.subnet_name
     virtual_network_name = data.azurerm_virtual_network.cws-vnet-dev.name
     resource_group_name  = data.azurerm_virtual_network.cws-vnet-dev.resource_group_name
   }

   resource "azurerm_network_interface" "cws-NIF-dev" {
     name                = "${var.Virtual_Machine_name}-nic"
     location            = var.location
     resource_group_name = var.Resource_group_name

     ip_configuration {
       name                          = "internal"
       subnet_id                     = data.azurerm_subnet.cws-subnet-dev.id
       private_ip_address_allocation = "Dynamic"
     }
   }

   resource "azurerm_virtual_machine" "cws-vm" {
     name                  = var.Virtual_Machine_name
     location              = var.location
     resource_group_name   = var.Resource_group_name
     network_interface_ids = [azurerm_network_interface.cws-NIF-dev.id]
     vm_size               = "Standard_DS1_v2"
     delete_os_disk_on_termination = "true"

     storage_image_reference {
       publisher = "RedHat"
       offer     = "RHEL"
       sku       = "8-gen2"
       version   = "latest"
     }  
     storage_os_disk {
       name              = "${var.Virtual_Machine_name}-disk"
       caching           = "ReadWrite"
       create_option     = "FromImage"
       managed_disk_type = "Standard_LRS"
       
     }
      os_profile {
       computer_name  = "Terraformvm1"
       admin_username = var.admin_username
       admin_password = var.admin_password# Use a more secure password or use SSH keys
     }

     os_profile_linux_config {
       disable_password_authentication = false
     }
   }
