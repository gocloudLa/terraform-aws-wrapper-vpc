locals {

  custom_common_name = {
    for vpc_key, vpc_config in var.vpc_parameters :
    vpc_key => (
      lookup(vpc_config, "custom_common_name", "") != "" ?
      vpc_config.custom_common_name :
      local.common_name
    )
  }
}