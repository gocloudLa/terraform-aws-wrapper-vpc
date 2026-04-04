output "vpcs" {
  value = module.vpc
}
output "subnets" {
  value = module.subnet
}
output "route_tables" {
  value = module.route_table
}
# output "routes" {
#   value = module.route_association
# }
# output "nat_gateways" {
#   value = module.nat_gateway
# }
# output "internet_gateways" {
#   value = module.internet_gateway
# }
# output "network_acl" {
#   value = module.network_acl
# }
# output "flow_logs" {
#   value = module.flow_logs
# }
# output "endpoints" {
#   value = module.vpc_endpoint
# }
