locals {
  create_vpc_attachments_tmp = [
    for tgw_key, tgw_config in var.tgw_parameters :
    [
      for vpc_attachments_name, vpc_attachments_values in try(tgw_config.vpc_attachments, {}) :
      {
        "${tgw_key}-${vpc_attachments_name}" = {
          vpc_id = var.vpc_parameter.vpcs[vpc_attachments_name].vpc_id
          subnet_ids = [
            for key in vpc_attachments_values.subnet_ids :
            var.vpc_parameter.subnets["${vpc_attachments_name}-${key}"].id
          ]
          tgw_id                                          = lookup(tgw_config, "create_tgw", true) ? null : data.aws_ec2_transit_gateway.this[tgw_key].id
          appliance_mode_support                          = lookup(vpc_attachments_values, "appliance_mode_support", false)
          dns_support                                     = lookup(vpc_attachments_values, "dns_support", true)
          ipv6_support                                    = lookup(vpc_attachments_values, "ipv6_support", false)
          security_group_referencing_support              = lookup(vpc_attachments_values, "security_group_referencing_support", null)
          transit_gateway_default_route_table_association = lookup(vpc_attachments_values, "transit_gateway_default_route_table_association", true)
          transit_gateway_default_route_table_propagation = lookup(vpc_attachments_values, "transit_gateway_default_route_table_propagation", true)
          tags                                            = merge(local.common_tags, { Name = "${local.common_name}-${tgw_key}-${vpc_attachments_name}" })
        }
      } if((length(lookup(tgw_config, "vpc_attachments", {})) > 0))
    ]
  ]
  create_vpc_attachments = merge(flatten(local.create_vpc_attachments_tmp)...)
}

module "wrapper_tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.12.1"

  for_each = var.tgw_parameters

  create_tgw        = lookup(each.value, "create_tgw", true)
  create_tgw_routes = lookup(each.value, "create_tgw_routes", true)
  share_tgw         = lookup(each.value, "share_tgw", false)

  name                                   = lookup(each.value, "name", "${local.common_name}-${each.key}")
  description                            = lookup(each.value, "description", null)
  amazon_side_asn                        = lookup(each.value, "amazon_side_asn", "64512")
  enable_default_route_table_association = lookup(each.value, "enable_default_route_table_association", true)
  enable_default_route_table_propagation = lookup(each.value, "enable_default_route_table_propagation", true)
  enable_auto_accept_shared_attachments  = lookup(each.value, "enable_auto_accept_shared_attachments", false)
  enable_multicast_support               = lookup(each.value, "enable_multicast_support", false)
  enable_vpn_ecmp_support                = lookup(each.value, "enable_vpn_ecmp_support", true)
  enable_dns_support                     = lookup(each.value, "enable_dns_support", true)

  ram_allow_external_principals = lookup(each.value, "ram_allow_external_principals", false)
  ram_name                      = lookup(each.value, "ram_name", "${local.common_name}-${each.key}")
  ram_principals                = lookup(each.value, "ram_principals", [])
  ram_resource_share_arn        = lookup(each.value, "ram_resource_share_arn", "")

  vpc_attachments                = try(local.create_vpc_attachments, null)
  transit_gateway_cidr_blocks    = lookup(each.value, "transit_gateway_cidr_blocks", [])
  transit_gateway_route_table_id = lookup(each.value, "transit_gateway_route_table_id", null)

  tags = local.common_tags
}

locals {
  create_routes_tmp = [
    for tgw_key, tgw_config in var.tgw_parameters :
    [
      for vpc_name, vpc_values in try(tgw_config.vpc_routes, {}) : [
        for vpc_route_table_name, vpc_route_table_values in try(vpc_values, {}) :
        [
          for key in try(vpc_route_table_values.destination_cidr_block, vpc_route_table_values.destination_ipv6_cidr_block, []) :
          {
            "${vpc_name}-${vpc_route_table_name}-${key}" = {
              route_table_id              = var.vpc_parameter.route_tables["${vpc_name}-${vpc_route_table_name}"].id
              destination_cidr_block      = key
              destination_ipv6_cidr_block = null // to be supported with IPv6
              transit_gateway_id          = lookup(tgw_config, "create_tgw", true) ? module.wrapper_tgw[tgw_key].ec2_transit_gateway_id : data.aws_ec2_transit_gateway.this[tgw_key].id
            }
          } if((length(lookup(tgw_config, "vpc_routes", {})) > 0))
        ]
      ]
    ]
  ]
  create_routes = merge(flatten(local.create_routes_tmp)...)
}

resource "aws_route" "transit_gateway" {
  for_each = local.create_routes

  route_table_id = each.value.route_table_id

  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  transit_gateway_id = each.value.transit_gateway_id
}