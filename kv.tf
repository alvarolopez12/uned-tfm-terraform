# --- Identity for Kv ---
resource "azurerm_user_assigned_identity" "base" {
  resource_group_name = azurerm_resource_group.rg-odl.name
  location            = azurerm_resource_group.rg-odl.location
  name                = "mi-appgw-keyvault"
}

# --- Kv ---
resource "azurerm_key_vault" "kv" {
  name                = "kv-rg-12321-ala"
  resource_group_name = azurerm_resource_group.rg-odl.name
  location            = azurerm_resource_group.rg-odl.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  access_policy {
    object_id = data.azurerm_client_config.current.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id

    certificate_permissions = [
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "SetIssuers",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Restore",
      "Restore",
      "Set"
    ]
  }

  access_policy {
    object_id = azurerm_user_assigned_identity.base.principal_id
    tenant_id = data.azurerm_client_config.current.tenant_id

    secret_permissions = [
      "Get"
    ]
  }
}

output "secret_identifier" {
  value = azurerm_key_vault_certificate.example.secret_id
}

# --- Self Sign Certificate ---
resource "azurerm_key_vault_certificate" "example" {
  name         = "generated-cert01"
  key_vault_id = azurerm_key_vault.kv.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["internal.contoso.com", "domain.hello.world"]
      }

      subject            = "CN=odl-public-133112.eastus.cloudapp.azure.com"
      validity_in_months = 12
    }
  }
}