# --- NICs ---
resource "azurerm_network_interface" "nic" {
  count               = 3
  name                = "nic-${count.index + 1}"
  location            = azurerm_resource_group.rg-odl.location
  resource_group_name = azurerm_resource_group.rg-odl.name

  ip_configuration {
    name                          = "nic-ipconfig-${count.index + 1}"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
  }
}

# --- Disks ---
resource "azurerm_managed_disk" "test" {
  count                = 3
  name                 = "datadisk_existing_${count.index}"
  location             = azurerm_resource_group.rg-odl.location
  resource_group_name  = azurerm_resource_group.rg-odl.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

# --- VMs ---
resource "azurerm_virtual_machine" "vm" {
  count               = 3
  name                = "myVM${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg-odl.name
  location            = azurerm_resource_group.rg-odl.location
  vm_size             = "Standard_DS1_v2"
  availability_set_id = azurerm_availability_set.avset.id

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  storage_os_disk {
    name              = "myosdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.test.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.test.*.id, count.index)
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = element(azurerm_managed_disk.test.*.disk_size_gb, count.index)
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  
}

# --- Availability Set ---
resource "azurerm_availability_set" "avset" {
  name                         = "avset"
  location                     = azurerm_resource_group.rg-odl.location
  resource_group_name          = azurerm_resource_group.rg-odl.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  managed                      = true
}