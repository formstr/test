locals {
  vm_size = {
    default = "Standard_F2"
    prod = "Standard_D2s_v3"
    test = "Standard_B2s"
    dev = "Standard_B1s"
  }
}

locals {
  rg_names = {
    default = "rob-default-rg"
    prod = "rob-prod-rg"
    test = "rob-test-rg"
    dev = "rob-dev-rg"
  }
}

locals {
  rg_locations = {
    default = "eastus"
    prod = "centralus"
    test = "westus"
    dev = "centralindia"
  }
}

locals {
  vm_name = {
    default = "rob-default-rg"
    prod = "rob-prod-rg"
    test = "rob-test-rg"
    dev = "rob-dev-rg"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_names[terraform.workspace]
  location = local.rg_locations[terraform.workspace]
}
resource "azurerm_virtual_network" "vnet" {
  name                = "rob-network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5", "8.8.8.8"]
}

resource "azurerm_subnet" "sub" {
  name                 = "rob-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "rob-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "rob-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  depends_on = [azurerm_subnet.sub]
}

resource "azurerm_network_security_group" "rob-linux-sg" {
  name                = "rob-linux-sg1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  security_rule {
    name                       = "allowssh"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allowhttp"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allowinternet-for-linux"
    priority                   = 104
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface_security_group_association" "rob-linux-insg-assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.rob-linux-sg.id
  depends_on                = [azurerm_network_interface.nic, azurerm_network_security_group.rob-linux-sg]
}


