
# Alvaro Lopez Alvarez
# TFM UNED - 2023
# Master en ciberseguridad 

data "azurerm_client_config" "current" {}
# --- Rg ---
resource "azurerm_resource_group" "rg-odl" {
  name     = "rg-odl"
  location = "eastus"
}















