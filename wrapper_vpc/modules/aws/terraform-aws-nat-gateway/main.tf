resource "aws_nat_gateway" "this" {
  count = var.kind == "aws" && var.create_nat_gateway ? 1 : 0

  subnet_id = var.subnet_id

  allocation_id                      = var.nat_parameters.connectivity_type == "public" ? aws_eip.this[0].id : null
  connectivity_type                  = lookup(var.nat_parameters, "connectivity_type", "private")
  private_ip                         = lookup(var.nat_parameters, "private_ip", null)
  secondary_allocation_ids           = lookup(var.nat_parameters, "secondary_allocation_ids", null)
  secondary_private_ip_address_count = lookup(var.nat_parameters, "secondary_private_ip_address_count", null)
  secondary_private_ip_addresses     = lookup(var.nat_parameters, "secondary_private_ip_addresses", null)

  tags = var.tags
}

resource "aws_eip" "this" {
  count = var.kind == "aws" && var.create_nat_gateway && var.nat_parameters.connectivity_type == "public" ? 1 : 0

  domain = "vpc"
  tags   = var.tags
}

module "vpc-ec2-nat-gateway" {
  source = "./modules/terraform-aws-vpc-ec2-nat-gateway"

  count = var.kind == "ec2" && var.create_nat_gateway ? 1 : 0

  name = var.tags.Name

  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  attach_eip = lookup(var.nat_parameters, "ec2_nat_gateway_attach_eip", false)

  tags = var.tags
}