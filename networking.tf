# --- VNET ---
resource "azurerm_virtual_network" "vnet1" {
  name                = "myVNet"
  resource_group_name = azurerm_resource_group.rg-odl.name
  location            = azurerm_resource_group.rg-odl.location
  address_space       = ["10.21.0.0/16"]
}

# --- Subnets ---
resource "azurerm_subnet" "frontend" {
  name                 = "myAGSubnet"
  resource_group_name  = azurerm_resource_group.rg-odl.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.21.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "myBackendSubnet"
  resource_group_name  = azurerm_resource_group.rg-odl.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.21.1.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg-odl.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.21.2.0/24"]
}

# --- Public IPs ---
resource "azurerm_public_ip" "pip1" {
  name                = "myAGPublicIPAddress"
  resource_group_name = azurerm_resource_group.rg-odl.name
  location            = azurerm_resource_group.rg-odl.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "odl-public-133112"
}

resource "azurerm_public_ip" "test" {
  name                = "publicIPForLB"
  resource_group_name = azurerm_resource_group.rg-odl.name
  location            = azurerm_resource_group.rg-odl.location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "bastionip" {
  name                = "bastionip"
  location            = azurerm_resource_group.rg-odl.location
  resource_group_name = azurerm_resource_group.rg-odl.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# --- NSG attached to Subnet Backend ---
resource "azurerm_network_security_group" "nsgsubnet" {
  name                = "subnet-nsg"
  location            = azurerm_resource_group.rg-odl.location
  resource_group_name = azurerm_resource_group.rg-odl.name

  security_rule {
    name                       = "allow6633"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6633"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow8181"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8181"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.nsgsubnet.id
}