resource "aws_route_table" "this" {
  count = var.create_route_table ? 1 : 0

  vpc_id = var.vpc_id
  tags   = var.tags
}