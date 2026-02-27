output "id" {
  value = aws_subnet.this[0].id
}
output "arn" {
  value = aws_subnet.this[0].arn
}
output "ipv6_cidr_block_association_id" {
  value = aws_subnet.this[0].ipv6_cidr_block_association_id
}