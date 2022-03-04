# creates resource groups based on the set variables
resource "azurerm_resource_group" "My_Rgs" {
  count = length(var.resource_groups.key.NAME)
  name = "${var.team}-${var.resource_groups.key.NAME[count.index]}"
  location = var.resource_groups.key.LOCATION[count.index]
}

# Creates 2) 1 vnet, 3 tier subnets, 1 bastion subnet, bastion host, bastion nsg with security rules
module "network" {
  source = "github.com/jorale2415/Terraform_Modules/Mod_N_Tier_Vnet"
  count = 2
  resource_group = "${var.team}-${var.resource_groups.key.NAME[count.index]}"
  vnet = "${var.team}-Vnet${count.index}"
  vnet-address = ["${var.address-space[count.index]}"]
  subnet1 = "${var.team}-${var.subnet1}-${count.index}"
  subnet1-prefix = var.sub1-prefix[count.index]
  subnet2 = "${var.team}-${var.subnet2}-${count.index}"
  subnet2-prefix = var.sub2-prefix[count.index]
  subnet3 = "${var.team}-${var.subnet3}-${count.index}"
  subnet3-prefix = var.sub3-prefix[count.index]
  bastion = var.bastion
  bastion-prefix = var.bastion-prefix[count.index]
  bastion-pip = "${var.team}-${var.bastion-pip}-${count.index}"
  bastion-host = "${var.team}-${var.bastion-host}${count.index}"
  sku = var.sku
  Internet-Bastion-PublicIP-Destination-Ports = var.Internet-Bastion-PublicIP-Destination-Ports
  OutboundVirtualNetwork-Destination-Ports = var.OutboundVirtualNetwork-Destination-Ports
  Destination-Vnet-Address = var.Destination-Vnet-Address[count.index]

  depends_on = [
    azurerm_resource_group.My_Rgs
  ]
}

# Peering between primary region and secondary region
module "Vnet_Peering" {
  source = "github.com/jorale2415/Terraform_Modules/Mod_Vnet_Peering"
  resource_group_1 = "${var.team}-${var.resource_groups.key.NAME[0]}"
  resource_group_2 ="${var.team}-${var.resource_groups.key.NAME[1]}"
  region = var.region
  team = var.team
  depends_on = [
    module.network
  ]
}

# Creates a internal load balancer attached to a VMSS in the business tier subnet
module "Business_Teir" {
  source = "github.com/jorale2415/Terraform_Modules/Mod_VMSS_With_Private_Lb"
  count = 2
  resource_group = "${var.team}-${var.resource_groups.key.NAME[count.index]}"
  key_vault = var.key_vault
  key_vault_rg = var.key_vault_rg 
  secret_username = var.secret_username
  secret_password = var.secret_password
  region = var.region[count.index]
  team = var.team
  vnet = "${var.team}-Vnet${count.index}"
  subnet = "${var.team}-${var.subnet2}-${count.index}"
  frontend_private_ip_address = var.frontend_private_ip_address_business[count.index]

  depends_on = [
    module.network
  ]  
}

# creates 2 app service, 2 app service plans, 1 sql database and 2 sql database servers
module "App_service_and_Sql" {
  source = "github.com/jorale2415/Terraform_Modules/Mod_Sql_Database"
  primary_resource_group_name = "${var.team}-${var.resource_groups.key.NAME[0]}"
  secondary_resource_group_name = "${var.team}-${var.resource_groups.key.NAME[1]}"
  rg1_vnet = "${var.team}-Vnet0"
  rg2_vnet = "${var.team}-Vnet1"
  Db_subnet_primary_region = "${var.team}-${var.subnet3}-0"
  Db_subnet_secondary_region = "${var.team}-${var.subnet3}-1"
  depends_on = [
    module.network,
    azurerm_resource_group.My_Rgs
  ]
}


# Creates an application gateway in the primary and secondary region attached to there respective app service
module "App_Gateway" {
  source = "github.com/jorale2415/Terraform_Modules/Mod_Application_Gateway"
  count = 2
  resource_group = "${var.team}-${var.resource_groups.key.NAME[count.index]}"
  vnet = "${var.team}-Vnet${count.index}"
  subnet_name = "${var.team}-${var.subnet1}-${count.index}"
  app_service_name = var.app_service_names[count.index]
  depends_on = [
    module.network,
    module.App_service_and_Sql
  ]
}

module "Traffic_Manager" {
  source = "github.com/jorale2415/Terraform_Modules/Mod_Traffic_Manager"
  team = var.team
  resource_group1 = "${var.team}-${var.resource_groups.key.NAME[0]}"
  resource_group2 = "${var.team}-${var.resource_groups.key.NAME[1]}"
  resource_group3 = "${var.team}-${var.resource_groups.key.NAME[2]}"
  Traffic_Manager_Profile_Name = "${var.team}-Traffic-Manager"
  Dns_Config_Name = "${var.team}-DNS-Name"
  depends_on = [
    module.App_service_and_Sql,
    module.App_Gateway
  ]
}


