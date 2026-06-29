output "vpc_id" {
  value = try(aws_vpc.this[0].id, null)
}

output "vpc_arn" {
  value = try(aws_vpc.this[0].arn, null)
}

output "vpc_name" {
  value = try(aws_vpc.this[0].tags_all.Name, null)
}

# output "dhcp_options_id" {
#   value = aws_vpc_dhcp_options.this[0].id
# }

# output "dhcp_options_arn" {
#   value = aws_vpc_dhcp_options.this[0].arn
# }

output "security_group_id" {
  value = try(aws_default_security_group.default[0].id, null)
}

output "default_route_table_id" {
  value = try(aws_vpc.this[0].default_route_table_id, null)
}

output "default_network_acl_id" {
  value = try(aws_vpc.this[0].default_network_acl_id, null)
}