output "vpcs" {
  value = module.vpc
}
output "subnets" {
  value = module.subnet
}
output "route_tables" {
  value = module.route-table
}
# output "routes" {
#   value = module.route-association
# }
# output "nat_gateways" {
#   value = module.nat-gateway
# }
# output "internet_gateways" {
#   value = module.internet-gateway
# }
# output "network_acl" {
#   value = module.network-acl
# }
# output "flow_logs" {
#   value = module.flow-logs
# }
# output "endpoints" {
#   value = module.vpc-endpoint
# }
