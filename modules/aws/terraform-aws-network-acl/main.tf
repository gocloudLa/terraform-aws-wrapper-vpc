################################################################################
# Network ACL
################################################################################
resource "aws_network_acl" "this" {
  count = var.create_network_acl ? 1 : 0

  vpc_id = var.vpc_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = var.tags
}

resource "aws_network_acl_rule" "this" {
  for_each = var.rules

  network_acl_id = aws_network_acl.this[0].id

  rule_number     = each.key
  egress          = lookup(each.value, "egress", false)
  protocol        = lookup(each.value, "protocol", "-1")
  rule_action     = lookup(each.value, "rule_action", "allow")
  cidr_block      = lookup(each.value, "cidr_block", "0.0.0.0/0")
  from_port       = lookup(each.value, "from_port", null)
  to_port         = lookup(each.value, "to_port", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
  icmp_type       = lookup(each.value, "icmp_type", null)
  icmp_code       = lookup(each.value, "icmp_code", null)

}


