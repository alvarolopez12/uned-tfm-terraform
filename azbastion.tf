# --- Az Bastion ---
resource "azurerm_bastion_host" "bastion" {
  name                = "bastion"
  location            = azurerm_resource_group.rg-odl.location
  resource_group_name = azurerm_resource_group.rg-odl.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastionip.id
  }
}

