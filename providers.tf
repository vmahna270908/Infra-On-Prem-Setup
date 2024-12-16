#Azure Provider source and version being used
##
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
  backend "azurerm" {
  }   
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}