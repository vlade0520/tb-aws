/*
* # GFT AWS LZ Transit Gateway Network Manager Service Terraform module
*
* Usage: Generic Terraform module to Enable TGW Network Manager Service.
*/

locals {
  gn_tags = merge(  {"Name" = format("%s", var.global_network_name)}, var.tags,)
}
#--tags ${local.gn_tags}
#--region ${var.region}

resource "null_resource" "aws_lz_ena_net_manager" {
  provisioner "local-exec" {
    command = "aws networkmanager create-global-network --description ${var.global_network_description}"
    #command = "aws networkmanager create-global-network --description 'Head offices global network' --region us-west-2 --profile network-account"
  }
}