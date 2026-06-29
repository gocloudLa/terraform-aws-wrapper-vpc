output "aws_nat_gateway_id" {
  value = var.kind == "aws" ? aws_nat_gateway.this[0].id : null
}

output "ec2_nat_gateway_id" {
  value = var.kind == "ec2" ? module.ec2_nat_gateway[0].primary_network_interface_id : null
}