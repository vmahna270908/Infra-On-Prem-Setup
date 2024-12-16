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