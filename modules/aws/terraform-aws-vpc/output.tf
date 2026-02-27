output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_arn" {
  value = aws_vpc.this.arn
}

output "vpc_name" {
  value = aws_vpc.this.tags_all.Name
}

# output "dhcp_options_id" {
#   value = aws_vpc_dhcp_options.this[0].id
# }

# output "dhcp_options_arn" {
#   value = aws_vpc_dhcp_options.this[0].arn
# }

output "security_group_id" {
  value = aws_default_security_group.default.id
}

output "default_route_table_id" {
  value = aws_vpc.this.default_route_table_id
}

output "default_network_acl_id" {
  value = aws_vpc.this.default_network_acl_id
}