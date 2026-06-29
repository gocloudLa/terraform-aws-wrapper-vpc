output "id" {
  value = aws_internet_gateway.this[0].id
}

output "egress_only_id" {
  value = length(aws_egress_only_internet_gateway.this) > 0 ? aws_egress_only_internet_gateway.this[0].id : null
}