# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a new resource group
resource "azurerm_resource_group" "Deop" {
  name     = "DeopRG"
  location = "canadacentral"
}

# Create a new virtual network
resource "azurerm_virtual_network" "Deop" {
  name                = "DeopVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Deop.location
  resource_group_name = azurerm_resource_group.Deop.name
}

# Create a new subnet
resource "azurerm_subnet" "Deop" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.Deop.name
  virtual_network_name = azurerm_virtual_network.Deop.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a new public IP address
resource "azurerm_public_ip" "Deop" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.Deop.location
  resource_group_name = azurerm_resource_group.Deop.name
  allocation_method   = "Static"
}

# Create a new network interface
resource "azurerm_network_interface" "Deop" {
  name                = "myNetworkInterface"
  location            = azurerm_resource_group.Deop.location
  resource_group_name = azurerm_resource_group.Deop.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.Deop.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Deop.id
  }
}

# Create a new virtual machine
resource "azurerm_virtual_machine" "Deop" {
  name                  = "DeopVM"
  location              = azurerm_resource_group.Deop.location
  resource_group_name   = azurerm_resource_group.Deop.name
  network_interface_ids = [azurerm_network_interface.Deop.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "myVM"
    admin_username = "alijon"
    admin_password = "Adminpassword1"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

