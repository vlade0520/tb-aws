### VPC --->
/*Using terraform VPC module, see https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/2.29.0 */

module "vpc_shared_services" {
  source  = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.sharedservices-account
  }
  name = var.vpc_sharedservices_name
  cidr = var.vpc_sharedservices_cidr
  azs             = [local.primary_az,local.secondary_az]
  private_subnets = var.vpc_sharedservices_private_subnets_cidr
  public_subnets  =  var.vpc_sharedservices_public_subnets_cidr

  enable_nat_gateway = var.enable_nat_gateway_sharedservices
  enable_vpn_gateway = var.enable_vpn_gateway_sharedservices

  tags = { (var.tag_key_project_id) = var.awslz_proj_id, (var.tag_key_environment) = var.awslz_environment, (var.tag_key_account_id) = local.sharedservices_account_id, (var.tag_key_name) = "sharedservices" }
}

module "vpc_sharedservices_twg_attachment" {
  source  = "./modules/transit-gateway/tgw-vpc-attachment"

  providers = {
    aws = aws.sharedservices-account
  }

  attach_name = format("aws_lz_sharedservices_vpc_attach_%s",local.sharedservices_account_id)
  subnets_ids = module.vpc_shared_services.private_subnets
  vpc_id = module.vpc_shared_services.vpc_id
  transit_gateway_id = module.aws_lz_tgw.tgw_id
  tags = { (var.tag_key_project_id) = var.awslz_proj_id, (var.tag_key_environment) = var.awslz_environment, (var.tag_key_account_id) = local.sharedservices_account_id}
} 

module "internet_route_sharedservices"{
  source  = "./modules/route"
  providers = {
    aws = aws.sharedservices-account
  }
  route_table = module.vpc_shared_services.private_route_table_ids
  destination = var.internet_cidr_sharedservices
  transit_gateway = module.aws_lz_tgw.tgw_id
}

module "internal_route_sharedservices"{
  source  = "./modules/route"
  providers = {
    aws = aws.sharedservices-account
  }
  route_table = module.vpc_shared_services.private_route_table_ids
  destination = var.internal_traffic_cidr_sharedservices
  transit_gateway = module.aws_lz_tgw.tgw_id
}

#SECURITY ROLES
 module "aws_lz_iam_security_admin_sharedservices" {
   source = "./modules/iam"
 
   providers = {
     aws = aws.sharedservices-account
   }

   role_name = "${local.security_role_name}"
   assume_role_policy = "${data.aws_iam_policy_document.aws_lz_assume_role_security.json}"
   role_tags = { (var.tag_key_project_id) = var.awslz_proj_id, (var.tag_key_environment) = var.awslz_environment, (var.tag_key_account_id) = local.sharedservices_account_id }

   #attachment
  role_policy_attach = true
  policy_arn = local.administrator_access_arn
 }

  module "aws_lz_iam_security_audit_sharedservices" {
   source = "./modules/iam"
   providers = {
     aws = aws.sharedservices-account
   }

   role_name = "${local.security_role_name_audit}"
   assume_role_policy = "${data.aws_iam_policy_document.aws_lz_assume_role_security.json}"
   role_tags = { (var.tag_key_project_id) = var.awslz_proj_id, (var.tag_key_environment) = var.awslz_environment, (var.tag_key_account_id) = local.sharedservices_account_id }
   #attachment
   role_policy_attach = true
   policy_arn = local.read_only_access_arn
  }

# EKS cluster
module "aws_lz_eks_eagleconsole_cluster" {
  source = "./modules/eks"
  providers = {
    aws = aws.sharedservices-account
  }

  eks_cluster_name          = var.ec_eks_cluster_name
  eks_iam_role_name         = var.ec_eks_role_name
  subnets                   = module.vpc_shared_services.private_subnets

  node_group_name           = var.ec_eks_node_group_name
  node_group_role_name      = var.ec_eks_node_group_role_name
  node_group_subnets        = module.vpc_shared_services.private_subnets
  node_group_instance_types = var.ec_eks_node_group_instance_types
}
# END EKS cluster

# Key pair
module "sharedservices_account_keypair" {
  source = "./modules/key-pairs"
  providers = {
    aws = aws.sharedservices-account
  }

  key_name    = var.shared_services_deployment_key_name
  public_key  = var.env_deployment_key
  tags        = { generation_date = var.env_generation_date } 
}
# END Key pair