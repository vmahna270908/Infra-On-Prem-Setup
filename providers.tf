terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.13.0"
    }
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "Prod-RG"
    storage_account_name = "terraformstatefile2"
    container_name       = "terraformstatefile"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features{}
}
##