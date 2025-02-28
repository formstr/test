# resource "azurerm_resource_group" "rg" {
#   name     = "rob-rg"
#   location = "centralindia"
# }
# resource "azurerm_virtual_network" "vnet" {
#   name                = "rob-network"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = ["10.0.0.0/16"]
#   dns_servers         = ["10.0.0.4", "10.0.0.5", "8.8.8.8"]
#   depends_on          = [azurerm_resource_group.rg]
# }

# resource "azurerm_subnet" "sub" {
#   name                 = "rob-subnet"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
#   depends_on           = [azurerm_virtual_network.vnet]
# }

# resource "azurerm_public_ip" "pip" {
#   name                = "rob-pip"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   allocation_method   = "Static"
#   depends_on          = [azurerm_resource_group.rg]
# }

# resource "azurerm_network_interface" "nic" {
#   name                = "rob-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.sub.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.pip.id
#   }
#   depends_on = [azurerm_subnet.sub]
# }

# resource "azurerm_network_security_group" "rob-linux-sg" {
#   name                = "rob-linux-sg1"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location

#   security_rule {
#     name                       = "allowssh"
#     priority                   = 102
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = var.ssh-port
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "allowhttp"
#     priority                   = 103
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = var.web-port
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "allowinternet-for-linux"
#     priority                   = 104
#     direction                  = "Outbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }


# resource "azurerm_network_interface_security_group_association" "rob-linux-insg-assoc" {
#   network_interface_id      = azurerm_network_interface.nic.id
#   network_security_group_id = azurerm_network_security_group.rob-linux-sg.id
#   depends_on                = [azurerm_network_interface.nic, azurerm_network_security_group.rob-linux-sg]
# }

# resource "azurerm_linux_virtual_machine" "linux-vm" {
#   name                            = "rob-linux-machine"
#   resource_group_name             = azurerm_resource_group.rg.name
#   location                        = azurerm_resource_group.rg.location
#   size                            = "Standard_F2"
#   admin_username                  = "rob"
#   admin_password                  = "easy@1"
#   disable_password_authentication = "false"
#   network_interface_ids = [
#     azurerm_network_interface.nic.id
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#   connection {
#     type     = "ssh"
#     user     = self.admin_username
#     password = self.admin_password
#     host     = self.public_ip_address
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt update",
#       "sudo apt install nginx -y"
#     ]
#   }

#     provisioner "local-exec" {
#     command = "echo ${self.public_ip_address} >> my_public_ip.txt"
#   }

#   # Copies the configs.d folder to /etc/configs.d
#   provisioner "file" {
#     source      = "log.txt"
#     destination = "/tmp/log.txt"
#   }

#   depends_on = [azurerm_network_interface.nic]
# }

# output "my_public_ipname" {
#   value = azurerm_public_ip.pip.ip_address
  
# }

# module "azure_vm" {
#   #source = "D:/VS Terraform/custom modules"
#   source = "git::https://github.com/formstr/azure_vm.git"
#   rg_name = "rob-module-rg"
# rg_location = "centralindia"
# cidr = "10.0.0.0/16"
# vm_size = "Standard_F2"
# admin_username = "rob"
# admin_password = "rob@123"
# address_prefixes = ["10.0.1.0/24"]
# }

############################################################################################################
# locals {
#   vm_size = {
#     default = "Standard_F2"
#     prod = "Standard_D2s_v3"
#     test = "Standard_B2s"
#     dev = "Standard_B1s"
#   }
# }

# locals {
#   rg_names = {
#     default = "rob-default-rg"
#     prod = "rob-prod-rg"
#     test = "rob-test-rg"
#     dev = "rob-dev-rg"
#   }
# }

# locals {
#   rg_locations = {
#     default = "eastus"
#     prod = "centralus"
#     test = "westus"
#     dev = "centralindia"
#   }
# }

# locals {
#   vm_name = {
#     default = "rob-default-rg"
#     prod = "rob-prod-rg"
#     test = "rob-test-rg"
#     dev = "rob-dev-rg"
#   }
# }

# resource "azurerm_resource_group" "rg" {
#   name     = "rob-default-rg"
#   location = "centralindia"
# }
# resource "azurerm_virtual_network" "vnet" {
#   name                = "rob-network"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = ["10.0.0.0/16"]
#   dns_servers         = ["10.0.0.4", "10.0.0.5", "8.8.8.8"]
# }

# resource "azurerm_subnet" "sub" {
#   name                 = "rob-subnet"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# resource "azurerm_public_ip" "pip" {
#   name                = "rob-pip"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   allocation_method   = "Static"
# }

# resource "azurerm_network_interface" "nic" {
#   name                = "rob-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.sub.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.pip.id
#   }
#   depends_on = [azurerm_subnet.sub]
# }

# resource "azurerm_network_security_group" "rob-linux-sg" {
#   name                = "rob-linux-sg1"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location

#   security_rule {
#     name                       = "allowssh"
#     priority                   = 102
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = var.ssh-port
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "allowhttp"
#     priority                   = 103
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = var.web-port
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "allowinternet-for-linux"
#     priority                   = 104
#     direction                  = "Outbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }


# resource "azurerm_network_interface_security_group_association" "rob-linux-insg-assoc" {
#   network_interface_id      = azurerm_network_interface.nic.id
#   network_security_group_id = azurerm_network_security_group.rob-linux-sg.id
#   depends_on                = [azurerm_network_interface.nic, azurerm_network_security_group.rob-linux-sg]
# }

# resource "azurerm_linux_virtual_machine" "linux-vm" {
#   name                            = "rob-vm"
#   resource_group_name             = azurerm_resource_group.rg.name
#   location                        = azurerm_resource_group.rg.location
#   size                            = "Standard_F2"
#   admin_username                  = "rob"
#   admin_password                  = "easy@1"
#   disable_password_authentication = "false"
#   network_interface_ids = [
#     azurerm_network_interface.nic.id
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

# }
# resource "azurerm_storage_account" "storage" {
#   name                     = "robfunkynameforstorage"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# resource "azurerm_storage_container" "storagecontainer" {
#   name                  = "linux-container"
#   storage_account_id    = azurerm_storage_account.storage.id
#   container_access_type = "private"
# }
