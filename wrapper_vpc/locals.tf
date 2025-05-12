locals {
  metadata = var.metadata

  common_name = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  common_tags = {
    "company"     = local.metadata.key.company
    "provisioner" = "terraform"
    "environment" = local.metadata.environment
    "created-by"  = "GoCloud.la"
  }

  custom_common_name = {
    for vpc_key, vpc_config in var.vpc_parameters :
    vpc_key => (
      lookup(vpc_config, "custom_common_name", "") != "" ?
      vpc_config.custom_common_name :
      local.common_name
    )
  }

}
