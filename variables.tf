variable "key_vault" {
  type = string
  default = "jalex-key-vault"
}
variable "key_vault_rg" {
  type = string
  default = "jalex-storage-rg"
}
variable "secret_username" {
  type = string
  default = "username"
}
variable "secret_password" {
  type = string
  default = "password"
}

variable "asp_name" {
  type = list(string)
  default = ["team5-app-service-plan1","team5-app-service-plan2"]
}
variable "resource_groups" {
  description = "Used to define/create multiple resource groups at a time."
  type = map(
    object({
      NAME = list(string)
      LOCATION = list(string)
    })
  )

  default = {
    "key" = {
      NAME = [ "Primary-RG","Secondary-RG","Traffic-Mgr-RG" ]
      LOCATION = [ "eastus", "westus3", "eastus"  ]
    }
  }
}

variable "region" {
  description = "Region string values"
  type = list(string)
  default = ["eastus","westus3"]
}
variable "team" {
  description = "Team name to help identify resources"
  type = string
  default = "Team5"
}

variable "subnet1" {
  type = string
  default = "Web-Tier"
}
variable "subnet2" {
  type = string
  default = "Business-Tier"
}
variable "subnet3" {
  type = string
  default = "Database-Tier"
}
variable "bastion" {
  type = string
  default = "AzureBastionSubnet"
}

variable "address-space" {
  description = "Address spaces for primary and secondary virtual networks"
  type = list(string)
  default = [ "10.0.0.0/16", "10.1.0.0/16" ]
}
variable "sub1-prefix" {
  description = "Subnet 1 prefix for primary and secondary vnet"
  type = list(string)
  default = ["10.0.1.0/24","10.1.1.0/24"]
}
variable "sub2-prefix" {
  description = "Subnet 2 prefix for primary and secondary vnet"
  type = list(string)
  default = ["10.0.2.0/24","10.1.2.0/24"]
}
variable "sub3-prefix" {
  description = "Subnet 3 prefix for primary and secondary vnet"
  type = list(string)
  default = ["10.0.3.0/24","10.1.3.0/24"]
}
variable "bastion-prefix" {
  description = "Bastion prefix for primary and secondary vnet"
  type = list(string)
  default = ["10.0.4.0/26","10.1.4.0/26"]
}
variable "app_service_names" {
  type = list(string)
  default = ["Team5-app-service-012421","Team5-app-service2-131246" ]
}

variable "bastion-pip" {
  type = string
  default = "bastion-pip"
}
variable "bastion-host" {
  type = string
  default = "bastion-host-000"
}
variable "sku" {
  type = string
  default = "Standard"
}
variable "Internet-Bastion-PublicIP-Destination-Ports" {
  type = string
  default = "443"
}
variable "OutboundVirtualNetwork-Destination-Ports"{
  type = list(string)
  default = ["22","3389"]
}
variable "Destination-Vnet-Address"{
  type = list(string)
  default = ["10.0.0.0/16", "10.1.0.0/16"]
}
variable "frontend_private_ip_address_business" {
  type = list(string)
  default = ["10.0.2.50", "10.1.2.50"]
}

variable "AS_Sku_Tier" {
  type = string
  default = "Standard"
}
variable "AS_Sku_Size" {
  type = list(string)
  default = ["S1","S2"]
}
