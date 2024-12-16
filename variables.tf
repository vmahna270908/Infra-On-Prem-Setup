variable "Infra_vnet_Name" {
  type        = string
  default     = "AZ-Infra-vNet"
  description = "Infrastructure Virtual Network Name"
}

variable "Infra_vNet_Address_Space" {
  type        = list(string)
  default     = ["10.0.4.0/24"]
  description = "Infrastructure Virtual Network Address Space"
}

variable "DC_Subnet_Name" {
  type        = string
  default     = "AZ-Infra-Subnet"
  description = "Domain Controller Subnet Name"
}

variable "DC_Subnet_Address_Space" {
  type        = list(string)
  default     = ["10.0.4.0/29"]
  description = "Domain Controller Subnet Address Space"
}