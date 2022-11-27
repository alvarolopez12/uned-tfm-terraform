terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.97.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "5d498653-580f-4e59-a2fb-df5c716e2524"
  tenant_id       = "9a9e6d81-92f6-462f-8c71-fdbbf82e76ca"
}