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
  sku = "Basic"
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

#VM for the DC
resource "azurerm_windows_virtual_machine" "windows_vm_domaincontroller" {
  name  = var.AZ-DC1
  location              = azurerm_resource_group.dc_rg.location
  resource_group_name   = azurerm_resource_group.dc_rg.name
  network_interface_ids = [azurerm_network_interface.dc_nic.id]
  size                  = "Standard_D2s_v3"
  admin_username        = var.domainusername
  admin_password        = var.domainpassword
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
  type = "VM"
  RG ="Prod-RG"
  project = "Infra"
  }
}

locals { 
  import_command       = "Import-Module ADDSDeployment"
  password_command     = "$password = ConvertTo-SecureString ${vvar.domainpassword} -AsPlainText -Force"
  install_ad_command   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  configure_ad_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${var.active_directory_domain} -DomainNetbiosName ${var.active_directory_netbios_name} -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command     = "shutdown -r -t 10"
  exit_code_hack       = "exit 0"
  powershell_command   = "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
}

resource "azurerm_virtual_machine_extension" "create-active-directory-forest" {
  name                 = "create-active-directory-forest"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  virtual_machine_id = azurerm.virtual_machine_id.windows_vm_domaincontroller.id

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}








