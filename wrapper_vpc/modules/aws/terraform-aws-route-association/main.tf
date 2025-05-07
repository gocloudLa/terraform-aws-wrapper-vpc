################################################################################
# Route Table
################################################################################
resource "aws_route" "this" {
  for_each = var.routes

  route_table_id = var.route_table_id
  ## destination
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  destination_prefix_list_id  = each.value.destination_prefix_list_id

  ## target
  nat_gateway_id       = each.value.nat_gateway_id
  gateway_id           = each.value.gateway_id
  network_interface_id = each.value.network_interface_id

  carrier_gateway_id        = each.value.carrier_gateway_id
  core_network_arn          = each.value.core_network_arn
  egress_only_gateway_id    = each.value.egress_only_gateway_id
  local_gateway_id          = each.value.local_gateway_id
  transit_gateway_id        = each.value.transit_gateway_id
  vpc_endpoint_id           = each.value.vpc_endpoint_id
  vpc_peering_connection_id = each.value.vpc_peering_connection_id
}

resource "aws_route" "default" {
  count = var.create_default_route ? 1 : 0

  route_table_id = var.route_table_id
  ## destination
  destination_cidr_block      = try(var.default_route.destination_cidr_block, null)
  destination_ipv6_cidr_block = try(var.default_route.destination_ipv6_cidr_block, null)
  destination_prefix_list_id  = try(var.default_route.destination_prefix_list_id, null)

  ## target
  gateway_id             = try(var.default_route.gateway_id, null)
  nat_gateway_id         = try(var.default_route.nat_gateway_id, null)
  network_interface_id   = try(var.default_route.network_interface_id, null)
  egress_only_gateway_id = try(var.default_route.egress_only_gateway_id, null)

  core_network_arn          = try(var.default_route.core_network_arn, null)
  carrier_gateway_id        = try(var.default_route.carrier_gateway_id, null)
  local_gateway_id          = try(var.default_route.local_gateway_id, null)
  transit_gateway_id        = try(var.default_route.transit_gateway_id, null)
  vpc_endpoint_id           = try(var.default_route.vpc_endpoint_id, null)
  vpc_peering_connection_id = try(var.default_route.vpc_peering_connection_id, null)
}