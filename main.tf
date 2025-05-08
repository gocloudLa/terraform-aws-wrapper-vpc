module "wrapper_vpc" {
  source = "./wrapper_vpc"

  metadata = var.metadata

  vpc_parameters = var.vpc_parameters.vpc
  vpc_defaults   = var.vpc_defaults.vpc

}

module "wrapper_tgw" {
  source = "./wrapper_tgw"

  metadata = var.metadata

  tgw_parameters = try(var.vpc_parameters.tgw, {})
  tgw_defaults   = var.vpc_defaults.tgw

  vpc_parameter = module.wrapper_vpc
}

module "wrapper_vpn" {
  source = "./wrapper_vpn"

  metadata = var.metadata

  vpn_parameters = try(var.vpc_parameters.vpn, {})
  vpn_defaults   = var.vpc_defaults.vpn

  vpc_parameter = module.wrapper_vpc
  tgw_parameter = module.wrapper_tgw
}