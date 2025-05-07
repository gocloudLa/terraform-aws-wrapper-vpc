data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

/*----------------------------------------------------------------------*/
/* Network | datasources                                                */
/*----------------------------------------------------------------------*/
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route_tables" "route_tables" {
  for_each =  var.vpn_parameters 

  filter {
    name   = "tag:Name"
    values = each.value.vpn_connection.route_table_names
  }
}
