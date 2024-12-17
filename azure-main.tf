#Data for the Resource Group
data "azurerm_resource_group" "Prod-RG" {
  name = "Prod-RG"
}

#vNet Creation for the Prod-RG Resource Group
resource "azurerm_virtual_network" "Infra_vNet" {
  name                = var.Infra_vnet_Name
  location            = data.azurerm_resource_group.Prod-RG.location
  resource_group_name = data.azurerm_resource_group.Prod-RG.name
  address_space       = var.Infra_vNet_Address_Space
  tags = {
  type = "vNet"
  RG ="Prod-RG"
  project = "Infra"
  }
}
#Subnet Creation - Domain Controllers
resource "azurerm_subnet" "DC_SubNet" {
  name                 = var.DC_Subnet_Name
  resource_group_name  = data.azurerm_resource_group.Prod-RG.name
  virtual_network_name = azurerm_virtual_network.Infra_vNet.name
  address_prefixes     = var.DC_Subnet_Address_Space
}

#Subnet Creation - Jump Servers
resource "azurerm_subnet" "MGM_SubNet" {
  name                 = var.MGM_Subnet_Name
  resource_group_name  = data.azurerm_resource_group.Prod-RG.name
  virtual_network_name = azurerm_virtual_network.Infra_vNet.name
  address_prefixes     = var.MGM_Subnet_Address_Space
}

#Subnet Creation - Application Servers
resource "azurerm_subnet" "App_SubNet" {
  name                 = var.App_Subnet_Name
  resource_group_name  = data.azurerm_resource_group.Prod-RG.name
  virtual_network_name = azurerm_virtual_network.Infra_vNet.name
  address_prefixes     = var.App_Subnet_Address_Space
}

#Deploying the Domain Controller

#Create the NSG for the DC
resource "azurerm_network_security_group" "DC-NSG" {

  name                = "AZ-DC-NSG"
  location            = data.azurerm_resource_group.Prod-RG.location
  resource_group_name = data.azurerm_resource_group.Prod-RG.name

  # NSG Rule
  security_rule {
    name                       = "Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "Production"
    project = "Infrastructure"
  }

}

# Subnet and NSG association DC
resource "azurerm_subnet_network_security_group_association" "DC_Subnet_NSG_Association" {
  subnet_id                 = azurerm_subnet.DC_SubNet.name
  network_security_group_id = azurerm_network_security_group.DC-NSG.id

}

#Network Interface for the DC
resource "azurerm_network_interface" "DC1-NIC" {
  name                = "AZ-DC1-NIC"
  location            = data.azurerm_resource_group.Prod-RG.location
  resource_group_name = data.azurerm_resource_group.Prod-RG.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.DC_SubNet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.node_address_prefix_dc, 4)
  }
}

