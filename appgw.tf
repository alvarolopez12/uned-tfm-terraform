# --- Timer to wait until Kv ---
resource "time_sleep" "wait_240_seconds" {
  depends_on = [azurerm_key_vault.kv]

  create_duration = "240s"
}

# --- App GW ---
resource "azurerm_application_gateway" "network" {
  name                = "myAppGateway"
  resource_group_name = azurerm_resource_group.rg-odl.name
  location            = azurerm_resource_group.rg-odl.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 3
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 443
  }

    frontend_port {
    name = var.frontend_port_name
    port = 8443
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip1.id
  }

  backend_address_pool {
    name = var.backend_address_pool_name
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = "app_listener"
  }

    http_listener {
    name                           = var.listener_name2
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = 8443
    protocol                       = "Https"
    ssl_certificate_name           = "app_listener"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.base.id]
  }

  ssl_certificate {
    name                = "app_listener"
    key_vault_secret_id = azurerm_key_vault_certificate.example.secret_id
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
    priority                   = 100
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name2
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name2
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
    priority                   = 101
  }
  depends_on = [time_sleep.wait_240_seconds]
}

# --- App Gw pool association ---
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc01" {
  count                   = 3
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "nic-ipconfig-${count.index + 1}"
  backend_address_pool_id = tolist(azurerm_application_gateway.network.backend_address_pool).0.id
}
