# --- LB ---
resource "azurerm_lb" "test" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.rg-odl.location
  resource_group_name = azurerm_resource_group.rg-odl.name

  frontend_ip_configuration {
    name                 = "publicIPForLB"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

# --- BackEnd Pool ---
resource "azurerm_lb_backend_address_pool" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "BackEndAddressPool"
}

# --- Rule ---
resource "azurerm_lb_rule" "lbrule" {
  loadbalancer_id                = azurerm_lb.test.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 6633
  backend_port                   = 6633
  frontend_ip_configuration_name = "publicIPForLB"
}