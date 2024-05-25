terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  cloud {
    organization = "minpyo"

    workspaces {
      name = "terraform-demo"
    }
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    # subscription_id   = "<azure_subscription_id>"
    # tenant_id         = "<azure_subscription_tenant_id>"
    # client_id         = "<service_principal_appid>"
    # client_secret     = "<service_principal_password>"
  }
}