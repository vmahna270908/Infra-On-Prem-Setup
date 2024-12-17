variable "Infra_vnet_Name" {
  type        = string
  default     = "AZ-Infra-vNet"
  description = "Infrastructure Virtual Network Name"
}

variable "Infra_vNet_Address_Space" {
  type        = list(string)
  default     = ["172.16.0.0/24"]
  description = "Infrastructure Virtual Network Address Space"
}

variable "DC_Subnet_Name" {
  type        = string
  default     = "AZ-Infra-DC-Subnet"
  description = "Domain Controller Subnet Name"
}

variable "DC_Subnet_Address_Space" {
  type        = list(string)
  default     = ["172.16.0.0/29"]
  description = "Domain Controller Subnet Address Space"
}

variable "MGM_Subnet_Name" {
  type        = string
  default     = "AZ-Infra-MGM-Subnet"
  description = "Management Subnet Name"
}

variable "MGM_Subnet_Address_Space" {
  type        = list(string)
  default     = ["172.16.0.8/29"]
  description = "Management Subnet Address Space"
}

variable "App_Subnet_Name" {
  type        = string
  default     = "AZ-Infra-App-Subnet"
  description = "Application Subnet Name"
}

variable "App_Subnet_Address_Space" {
  type        = list(string)
  default     = ["172.16.0.16/28"]
  description = "Application Subnet Address Space"
}

variable "AZ-DC1" {
  type        = string
  default     = "AZ-DC1"
  description = "Domain Controller 1 Name"
}

variable "node_address_prefix_dc" {
  default = "172.16.0.0/29"
}

variable "domainusername" {
  type        = string
  default     = "Skywalker"
  description = "Domain Username"
}

variable "domainpassword" {
  type        = string
  default     = "mt4cebwU!"
  description = "Domain Useraccount Password"
}

variable "active_directory_domain" {
  default = "Cloud2Build.ca"
  description = "The name of the Active Directory domain"
}

variable "active_directory_netbios_name" {
  default = "Cloud2Build"
  description = "The netbios name of the Active Directory domain"
}