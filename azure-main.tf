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

# Public IP for the DC
resource "azurerm_public_ip" "dc_public_ip" {
  name = var.AZ-DC1
  location            = data.azurerm_resource_group.Prod-RG.location
  resource_group_name = data.azurerm_resource_group.Prod-RG.name
  allocation_method   = "Dynamic"
  tags = {
  type = "Public IP"
  RG ="Prod-RG"
  project = "Infra"
  }
}

# Network Interface - DC
resource "azurerm_network_interface" "dc_nic" {
  name = var.DC1-NIC
  location            = data.azurerm_resource_group.Prod-RG.location
  resource_group_name = data.azurerm_resource_group.Prod-RG.name
  tags = {
  type = "NIC"
  RG ="Prod-RG"
  project = "Infra"
  }

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.DC_SubNet.id
    #private_ip_address_allocation = "Dynamic"
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.node_address_prefix_dc, 4)
    public_ip_address_id          = azurerm_public_ip.dc_public_ip.id
  }
}

# NSG DC
resource "azurerm_network_security_group" "dc_nsg" {

  name                = "AZ-DC-NSG"
  location            = data.azurerm_resource_group.Prod-RG.location
  resource_group_name = data.azurerm_resource_group.Prod-RG.name

  # Security rule 
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
  type = "NSG"
  RG ="Prod-RG"
  project = "Infra"
  }

}

# Subnet and NSG association DC
resource "azurerm_subnet_network_security_group_association" "dc_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.DC_SubNet.id
  network_security_group_id = azurerm_network_security_group.dc_nsg.id

}




