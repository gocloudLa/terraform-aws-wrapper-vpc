## VPC
module "vpc" {

  source = "./modules/aws/terraform-aws-vpc"

  for_each = var.vpc_parameters

  ## VPC Definition
  cidr_block                           = lookup(each.value, "vpc_cidr", "") ## it does not match example value
  use_ipam_pool                        = lookup(each.value, "use_ipam_pool", false)
  ipv4_ipam_pool_id                    = lookup(each.value, "ipv4_ipam_pool_id", null)
  ipv4_netmask_length                  = lookup(each.value, "ipv4_netmask_length", null)
  enable_ipv6                          = lookup(each.value, "enable_ipv6", false)
  ipv6_cidr_block                      = lookup(each.value, "ipv6_cidr_block", null)
  ipv6_ipam_pool_id                    = lookup(each.value, "ipv6_ipam_pool_id", null)
  ipv6_netmask_length                  = lookup(each.value, "ipv6_netmask_length", null)
  ipv6_cidr_block_network_border_group = lookup(each.value, "ipv6_cidr_block_network_border_group", null)
  instance_tenancy                     = lookup(each.value, "instance_tenancy", "default")
  enable_dns_hostnames                 = lookup(each.value, "enable_dns_hostnames", true)
  enable_dns_support                   = lookup(each.value, "enable_dns_support", true)
  enable_network_address_usage_metrics = lookup(each.value, "enable_network_address_usage_metrics", null)

  ## DHCP Options
  enable_dhcp_options               = lookup(each.value, "enable_dhcp_options", false)
  dhcp_options_domain_name          = lookup(each.value, "dhcp_options_domain_name", "")
  dhcp_options_domain_name_servers  = lookup(each.value, "dhcp_options_domain_name_servers", [])
  dhcp_options_ntp_servers          = lookup(each.value, "dhcp_options_ntp_servers", [])
  dhcp_options_netbios_name_servers = lookup(each.value, "dhcp_options_netbios_name_servers", [])
  dhcp_options_netbios_node_type    = lookup(each.value, "dhcp_options_netbios_node_type", "")

  tags = merge(lookup(each.value, "tags", local.common_tags), { Name = "${local.custom_common_name[each.key]}" })

}

## Internet Gateway
locals {
  create_internet_gateway_tmp = [
    for vpc_key, vpc_config in var.vpc_parameters :
    [
      for internet_gateway_name, internet_gateway_values in try(vpc_config.internet_gateway, {}) :
      {
        "${vpc_key}-${internet_gateway_name}" = merge(internet_gateway_values,
          {
            create_internet_gateway = lookup(internet_gateway_values, "create_internet_gateway", true)
            vpc_key                 = vpc_key,
            enable_ipv6             = lookup(vpc_config, "enable_ipv6", false)
            create_egress_only_igw  = lookup(internet_gateway_values, "create_egress_only_igw", false)
            tags                    = merge(lookup(internet_gateway_values, "tags", local.common_tags), { Name = "${local.custom_common_name[vpc_key]}-${internet_gateway_name}" })
        })
      } if((length(lookup(vpc_config, "internet_gateway", {})) > 0))
    ]
  ]
  create_internet_gateway = merge(flatten(local.create_internet_gateway_tmp)...)
}
module "internet-gateway" {

  source = "./modules/aws/terraform-aws-internet-gateway"

  for_each = local.create_internet_gateway

  create_internet_gateway = each.value.create_internet_gateway
  vpc_id                  = module.vpc[each.value.vpc_key].vpc_id
  create_egress_only_igw  = each.value.create_egress_only_igw
  enable_ipv6             = each.value.enable_ipv6

  tags = each.value.tags
}

## Network ACL rules
locals {
  create_network_acl_tmp = [
    for vpc_key, vpc_config in var.vpc_parameters :
    [
      for network_acl_name, network_acl_values in try(vpc_config.network_acl, {}) :
      {
        "${vpc_key}-${network_acl_name}" = {
          create_network_acl = lookup(network_acl_values, "create_network_acl", true)
          vpc_key            = vpc_key
          rules              = lookup(network_acl_values, "rules", {})
          tags               = merge(lookup(network_acl_values, "tags", local.common_tags), { Name = "${local.custom_common_name[vpc_key]}-${network_acl_name}" })
        }
      } if((length(lookup(vpc_config, "network_acl", {})) > 0))
    ]
  ]
  create_network_acl = merge(flatten(local.create_network_acl_tmp)...)
}
module "network-acl" {

  source = "./modules/aws/terraform-aws-network-acl"

  for_each = local.create_network_acl

  create_network_acl = lookup(each.value, "create_network_acl", true)
  vpc_id             = module.vpc[each.value.vpc_key].vpc_id
  rules              = lookup(each.value, "rules", {})

  tags = each.value.tags
}

resource "aws_default_network_acl" "this" {
  for_each = var.vpc_parameters

  default_network_acl_id = module.vpc[each.key].default_network_acl_id #aws_vpc.mainvpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = each.value.vpc_cidr #aws_default_vpc.mainvpc.cidr_block
    from_port  = 0
    to_port    = 0
  }
  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

## Route Table
locals {
  create_route_table_tmp = [
    for vpc_key, vpc_config in var.vpc_parameters :
    [
      for route_table_name, route_table_values in try(vpc_config.route_table, {}) :
      {
        "${vpc_key}-${route_table_name}" = {
          vpc_key              = vpc_key
          create_route_table   = lookup(route_table_values, "create_route_table", true)
          create_default_route = lookup(route_table_values, "default_route", {}) == {} ? false : true
          tags                 = merge(local.common_tags, { Name = "${local.custom_common_name[vpc_key]}-${route_table_name}" })
        }
      } if((length(lookup(vpc_config, "route_table", {})) > 0))
    ]
  ]
  create_route_table = merge(flatten(local.create_route_table_tmp)...)
}
module "route-table" {

  source = "./modules/aws/terraform-aws-route-table"

  for_each = local.create_route_table

  create_route_table = each.value.create_route_table
  vpc_id             = module.vpc[each.value.vpc_key].vpc_id

  tags = each.value.tags
}

resource "aws_default_route_table" "this" {
  for_each = var.vpc_parameters

  default_route_table_id = module.vpc[each.key].default_route_table_id # aws_vpc.example.default_route_table_id

  route = []

  tags = each.value.tags
}

## Subnets
locals {
  create_subnets_tmp = [
    for vpc_key, vpc_config in var.vpc_parameters :
    [
      for subnet_group_name, subnet_group_values in try(vpc_config.subnets, {}) :
      [
        for subnet_name, subnet_values in try(subnet_group_values, {}) :
        {
          "${vpc_key}-${subnet_group_name}-${subnet_name}" = {

            create_subnet     = lookup(subnet_values, "create_subnet", true)
            vpc_id            = module.vpc[vpc_key].vpc_id
            cidr_block        = lookup(subnet_values, "cidr_block", null)
            availability_zone = "${data.aws_region.current.name}${subnet_values.az}"
            #availability_zone_id = ## if zone name fails, check regions
            ## Configurations
            enable_dns64                                   = lookup(subnet_values, "enable_dns64", false)
            enable_resource_name_dns_aaaa_record_on_launch = lookup(subnet_values, "enable_resource_name_dns_aaaa_record_on_launch", false)
            enable_resource_name_dns_a_record_on_launch    = lookup(subnet_values, "enable_resource_name_dns_a_record_on_launch", false)
            private_dns_hostname_type_on_launch            = lookup(subnet_values, "private_dns_hostname_type_on_launch", null)
            map_public_ip_on_launch                        = lookup(subnet_values, "map_public_ip_on_launch", false)
            enable_lni_at_device_index                     = lookup(subnet_values, "enable_lni_at_device_index", null)

            ## IPv6
            ipv6_native                     = lookup(subnet_values, "outpost_arn", null)
            ipv6_cidr_block                 = lookup(subnet_values, "outpost_arn", null)
            assign_ipv6_address_on_creation = lookup(subnet_values, "outpost_arn", null)

            ## Customer owned IPs
            map_customer_owned_ip_on_launch = lookup(subnet_values, "map_customer_owned_ip_on_launch", null)
            customer_owned_ipv4_pool        = lookup(subnet_values, "customer_owned_ipv4_pool", null)
            outpost_arn                     = lookup(subnet_values, "outpost_arn", null)

            route_table = lookup(subnet_values, "route_table", "") != "" ? module.route-table["${vpc_key}-${subnet_values.route_table}"].id : ""                                            #module.route-table[subnet_values.route_table].id #"${local.custom_common_name[vpc_key]}-${subnet_values.route_table}" : "${vpc_key}-default"
            network_acl = lookup(subnet_values, "network_acl", "") != "" ? module.network-acl["${vpc_key}-${subnet_values.network_acl}"].id : aws_default_network_acl.this["${vpc_key}"].id #"${local.custom_common_name[vpc_key]}-${subnet_values.network_acl}" : "${vpc_key}-default"

            tags = lookup(subnet_values, "tags", merge(local.common_tags, { Name = "${local.custom_common_name[vpc_key]}-${subnet_group_name}-${subnet_name}" }))

          }
        } if((length(lookup(vpc_config, "subnets", {})) > 0))
      ]
    ]
  ]
  create_subnets = merge(flatten(local.create_subnets_tmp)...)
}
module "subnet" {

  source = "./modules/aws/terraform-aws-subnet"

  for_each = local.create_subnets

  create_subnet                                  = each.value.create_subnet
  vpc_id                                         = each.value.vpc_id
  cidr_block                                     = each.value.cidr_block
  availability_zone                              = each.value.availability_zone != "" ? each.value.availability_zone : null
  availability_zone_id                           = each.value.availability_zone == "" ? each.value.availability_zone_id : null
  enable_dns64                                   = each.value.enable_dns64
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  private_dns_hostname_type_on_launch            = each.value.private_dns_hostname_type_on_launch
  map_public_ip_on_launch                        = each.value.map_public_ip_on_launch
  enable_lni_at_device_index                     = each.value.enable_lni_at_device_index
  ipv6_native                                    = each.value.outpost_arn
  ipv6_cidr_block                                = each.value.outpost_arn
  assign_ipv6_address_on_creation                = each.value.outpost_arn
  map_customer_owned_ip_on_launch                = each.value.map_customer_owned_ip_on_launch
  customer_owned_ipv4_pool                       = each.value.customer_owned_ipv4_pool
  outpost_arn                                    = each.value.outpost_arn
  route_table                                    = each.value.route_table
  network_acl                                    = each.value.network_acl
  tags                                           = each.value.tags
}

## NAT Gateway
locals {
  create_nat_gateway_tmp = [
    for vpc_key, vpc_config in var.vpc_parameters :
    [
      for nat_gateway_name, nat_gateway_values in try(vpc_config.nat_gateway, {}) :
      {
        "${vpc_key}-${nat_gateway_name}" = {
          vpc_key            = "${vpc_key}"
          create_nat_gateway = lookup(nat_gateway_values, "create_nat_gateway", true)
          kind               = lookup(nat_gateway_values, "kind", "aws")
          subnet             = lookup(nat_gateway_values, "subnet", null)
          nat_parameters     = lookup(nat_gateway_values, "nat_parameters", { connectivity_type = "public" })
          tags               = merge(lookup(nat_gateway_values, "tags", local.common_tags), { Name = "${local.custom_common_name[vpc_key]}-${nat_gateway_name}" })
        }
      } if((length(lookup(vpc_config, "nat_gateway", {})) > 0))
    ]
  ]
  create_nat_gateway = merge(flatten(local.create_nat_gateway_tmp)...)
}
module "nat-gateway" {
  source = "./modules/aws/terraform-aws-nat-gateway"

  for_each = local.create_nat_gateway

  create_nat_gateway = each.value.create_nat_gateway
  kind               = each.value.kind
  vpc_id             = module.vpc[each.value.vpc_key].vpc_id
  subnet_id          = module.subnet["${each.value.vpc_key}-${each.value.subnet}"].id
  nat_parameters     = each.value.nat_parameters

  tags = each.value.tags
}

locals {
  create_default_route_tmp = [
    for vpc_key, vpc_config in var.vpc_parameters :
    [
      for route_table_name, route_table_values in try(vpc_config.route_table, {}) :
      {
        "${vpc_key}-${route_table_name}" = {
          create = true

          destination_cidr_block = "0.0.0.0/0"
          # destination_ipv6_cidr_block = try(route_table_values.default_route.destination_ipv6_cidr_block, null) == null && can(route_table_values.default_route.destination_cidr_block) ? null : "::/0"

          # destination_prefix_list_id = try(route_table_values.default_route.vpc_endpoint_id, null)

          nat_gateway_id = try(module.nat-gateway["${vpc_key}-${route_table_values.default_route.nat_gateway}"].aws_nat_gateway_id, route_table_values.default_route.nat_gateway_id, null)

          gateway_id = try(module.internet-gateway["${vpc_key}-${route_table_values.default_route.gateway}"].id, route_table_values.default_route.gateway_id, null)

          network_interface_id = try(module.nat-gateway["${vpc_key}-${route_table_values.default_route.network_interface}"].ec2_nat_gateway_id, route_table_values.default_route.network_interface_id, null)

          egress_only_gateway_id = try(module.internet-gateway["${vpc_key}-${route_table_values.route_values.egress_only_gateway}"].egress_only_id, route_table_values.route_values.egress_only_gateway_id, null)

          vpc_endpoint_id = try(route_table_values.default_route.vpc_endpoint_id, null)
          #try(module.vpc-endpoint["${vpc_key}-${route_table_values.default_route.vpc_endpoint}"].endpoint_id, route_table_values.default_route.vpc_endpoint_id, null)

          transit_gateway_id = try(route_table_values.default_route.transit_gateway_id, null)
          #try(module.transit-gateway["${vpc_key}-${route_table_values.default_route.transit_gateway}"].transit-gateway-id, route_table_values.default_route.transit_gateway_id, null)

          vpc_peering_connection_id = try(route_table_values.default_route.vpc_peering_connection_id, null)
          #try( module.vpc-peering["${vpc_key}-${route_table_values.default_route.vpc_peering_connection}"].peering_id, route_table_values.default_route.vpc_peering_connection_id, null)

          core_network_arn = try(route_table_values.default_route.core_network_arn, null)
          #try(module.nat-gateway["${vpc_key}-${route_table_values.default_route.core_network}"].core_id, route_table_values.default_route.core_network_arn, null)

          carrier_gateway_id = try(route_table_values.default_route.carrier_gateway_id, null)
          #try( module.nat-gateway["${vpc_key}-${route_table_values.default_route.carrier_gateway}"].ec2_nat_gateway_id, route_table_values.default_route.carrier_gateway_id, null)

          local_gateway_id = try(route_table_values.default_route.local_gateway_id, null)
          #try(module.nat-gateway["${vpc_key}-${route_table_values.default_route.local_gateway}"].ec2_nat_gateway_id, route_table_values.default_route.local_gateway_id, null)

          tags = merge(local.common_tags, { Name = "${local.custom_common_name[vpc_key]}-${route_table_name}" })
        }
      } if((length(lookup(route_table_values, "default_route", {})) > 0))
    ]
  ]
  create_default_route = merge(flatten(local.create_default_route_tmp)...)

  create_route_tmp = [
    for vpc_key, vpc_config in var.vpc_parameters :
    [
      for route_table_name, route_table_values in try(vpc_config.route_table, {}) :
      {
        "${vpc_key}-${route_table_name}" = {
          for route_name, route_values in try(route_table_values.routes, {}) :
          "${route_name}" => {

            destination_cidr_block      = try(route_values.destination_cidr_block, null)
            destination_ipv6_cidr_block = try(route_values.destination_ipv6_cidr_block, null)

            #destination_prefix_list_id  = try(module.prefix-list["${vpc_key}-${route_table_values.route_values.destination_prefix_list}"].aws_destination_prefix_list_id, route_table_values.route_values.destination_prefix_list_id, null)

            nat_gateway_id = try(module.nat-gateway["${vpc_key}-${route_table_values.route_values.nat_gateway}"].aws_nat_gateway_id, route_table_values.route_values.nat_gateway_id, null)

            gateway_id = try(module.internet-gateway["${vpc_key}-${route_table_values.route_values.gateway}"].id, route_table_values.route_values.gateway_id, null)

            network_interface_id = try(module.nat-gateway["${vpc_key}-${route_table_values.route_values.network_interface}"].ec2_nat_gateway_id, route_table_values.route_values.network_interface_id, null)

            egress_only_gateway_id = try(module.internet-gateway["${vpc_key}-${route_table_values.route_values.egress_only_gateway}"].egress_only_id, route_table_values.route_values.egress_only_gateway_id, null)

            vpc_endpoint_id = try(route_table_values.route_values.vpc_endpoint_id, null)
            #try(module.vpc-endpoint["${vpc_key}-${route_table_values.route_values.vpc_endpoint}"].endpoint_id, route_table_values.route_values.vpc_end   point_id, null)   

            transit_gateway_id = try(route_table_values.route_values.transit_gateway_id, null)
            #try(module.transit-gateway["${vpc_key}-${route_table_values.route_values.transit_gateway}"].transit-gateway-id, route_table_values.default_   route.transit_gateway_id, null)   

            vpc_peering_connection_id = try(route_table_values.route_values.vpc_peering_connection_id, null)
            #try( module.vpc-peering["${vpc_key}-${route_table_values.route_values.vpc_peering_connection}"].peering_id, route_table_values.default_rout   e.vpc_peering_connection_id, null)  

            core_network_arn = try(route_table_values.route_values.core_network_arn, null)
            #try(module.nat-gateway["${vpc_key}-${route_table_values.route_values.core_network}"].core_id, route_table_values.route_values.core_network   _arn, null)   

            carrier_gateway_id = try(route_table_values.route_values.carrier_gateway_id, null)
            #try( module.nat-gateway["${vpc_key}-${route_table_values.route_values.carrier_gateway}"].ec2_nat_gateway_id, route_table_values.default_rou   te.carrier_gateway_id, null)  

            local_gateway_id = try(route_table_values.route_values.local_gateway_id, null)
            #try(module.nat-gateway["${vpc_key}-${route_table_values.route_values.local_gateway}"].ec2_nat_gateway_id, route_table_values.route_values.local_gateway_id, null)

            tags = merge(local.common_tags, { Name = "${local.custom_common_name[vpc_key]}-${route_table_name}" })
          }
        }
      }
    ]
  ]
  create_route = merge(flatten(local.create_route_tmp)...)

}
module "route-association" {

  source = "./modules/aws/terraform-aws-route-association"

  for_each = local.create_route_table

  route_table_id       = module.route-table[each.key].id
  create_default_route = each.value.create_default_route
  routes               = try(local.create_route[each.key], {})
  default_route        = try(local.create_default_route[each.key], { create = false })

  tags = each.value.tags

}

# Flow Logs
locals {
  create_flow_logs_tmp = [
    for vpc_key, vpc_config in var.vpc_parameters :
    [
      for flow_logs_name, flow_logs_values in try(vpc_config.flow_logs, {}) :
      {
        "${vpc_key}-${flow_logs_name}" = {
          enable_flow_log                                 = lookup(flow_logs_values, "enable_flow_log", false)
          create_flow_log_cloudwatch_iam_role             = lookup(flow_logs_values, "create_flow_log_cloudwatch_iam_role", true)
          create_flow_log_cloudwatch_log_group            = lookup(flow_logs_values, "create_flow_log_cloudwatch_log_group", true)
          vpc_flow_log_permissions_boundary               = lookup(flow_logs_values, "vpc_flow_log_permissions_boundary", null)
          flow_log_traffic_type                           = lookup(flow_logs_values, "flow_log_traffic_type", "ALL")
          flow_log_destination_type                       = lookup(flow_logs_values, "flow_log_destination_type", "cloud-watch-logs")
          flow_log_log_format                             = lookup(flow_logs_values, "flow_log_log_format", null)
          flow_log_destination_arn                        = lookup(flow_logs_values, "flow_log_destination_arn", false)
          flow_log_cloudwatch_iam_role_arn                = lookup(flow_logs_values, "flow_log_cloudwatch_iam_role_arn", false)
          flow_log_cloudwatch_log_group_name_prefix       = lookup(flow_logs_values, "flow_log_cloudwatch_log_group_name_prefix", false)
          flow_log_cloudwatch_log_group_retention_in_days = lookup(flow_logs_values, "flow_log_cloudwatch_log_group_retention_in_days", 365)
          flow_log_cloudwatch_log_group_kms_key_id        = lookup(flow_logs_values, "flow_log_cloudwatch_log_group_kms_key_id", null)
          flow_log_max_aggregation_interval               = lookup(flow_logs_values, "flow_log_max_aggregation_interval", 600)
          flow_log_hive_compatible_partitions             = lookup(flow_logs_values, "flow_log_hive_compatible_partitions", false)
          flow_log_per_hour_partition                     = lookup(flow_logs_values, "flow_log_per_hour_partition", false)
          vpc_id                                          = module.vpc[vpc_key].vpc_id
          tags                                            = merge(local.common_tags, { Name = "${local.custom_common_name[vpc_key]}-${flow_logs_name}" })
        }
      } if((length(lookup(vpc_config, "flow_logs", {})) > 0))
    ]
  ]
  create_flow_logs = merge(flatten(local.create_flow_logs_tmp)...)
}
module "flow-logs" {

  source = "./modules/aws/terraform-aws-flow-logs"

  for_each = local.create_flow_logs

  enable_flow_log                                 = each.value.enable_flow_log
  create_flow_log_cloudwatch_iam_role             = each.value.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group            = each.value.create_flow_log_cloudwatch_log_group
  vpc_flow_log_permissions_boundary               = each.value.vpc_flow_log_permissions_boundary
  flow_log_traffic_type                           = each.value.flow_log_traffic_type
  flow_log_destination_type                       = each.value.flow_log_destination_type
  flow_log_log_format                             = each.value.flow_log_log_format
  flow_log_destination_arn                        = each.value.flow_log_destination_arn
  flow_log_cloudwatch_log_group_name_prefix       = each.value.flow_log_cloudwatch_log_group_name_prefix
  flow_log_cloudwatch_log_group_retention_in_days = each.value.flow_log_cloudwatch_log_group_retention_in_days
  flow_log_cloudwatch_log_group_kms_key_id        = each.value.flow_log_cloudwatch_log_group_kms_key_id
  flow_log_max_aggregation_interval               = each.value.flow_log_max_aggregation_interval
  flow_log_hive_compatible_partitions             = each.value.flow_log_hive_compatible_partitions
  flow_log_per_hour_partition                     = each.value.flow_log_per_hour_partition
  vpc_id                                          = each.value.vpc_id

  tags = each.value.tags

}

locals {
  create_endpoints_tmp = [
    for vpc_key, vpc_config in var.vpc_parameters :
    {
      "${vpc_key}" = {
        for endpoint_name, endpoint_values in try(vpc_config.endpoints, {}) :
        "${endpoint_name}" => {
          service      = try(endpoint_values.service, null)
          service_name = try(endpoint_values.service_name, null)
          service_type = try(endpoint_values.service_type, null)
          route_table_ids = flatten([
            for key in keys(local.create_route_table) : module.route-table[key].id
            if length(regexall("${vpc_key}", key)) > 0
          ])
          policy              = try(endpoint_values.policy, null)
          private_dns_enabled = try(endpoint_values.private_dns_enabled, false)
          security_group_ids  = try(endpoint_values.security_group_ids, [])

          tags = merge(local.common_tags, { Name = "${local.custom_common_name[vpc_key]}-${endpoint_values.service}-vpc-endpoint" })
        }
      }
    }
  ]
  create_endpoints = merge(flatten(local.create_endpoints_tmp)...)
}


module "vpc-endpoint" {
  source = "./modules/aws/terraform-aws-vpc-endpoints"

  for_each = var.vpc_parameters

  vpc_id    = module.vpc[each.key].vpc_id
  endpoints = local.create_endpoints[each.key]

}

# module "vpc-peering" {  
#   source = "./modules/aws/terraform-aws-vpc-endpoints"

#   for_each = var.vpc__parameters

#   peer_owner_id =
#   peer_vpc_id =
#   vpc_id = 
#   auto_accept = 
#   peer_region = 
#   accepter = 
#   requester =
#   tags = 
# }