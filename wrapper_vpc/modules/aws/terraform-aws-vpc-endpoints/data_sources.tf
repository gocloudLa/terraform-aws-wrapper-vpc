data "aws_vpc_endpoint_service" "this" {
  for_each = local.endpoints

  service      = try(each.value.service, null)
  service_name = try(each.value.service_name, null)

  filter {
    name   = "service-type"
    values = [try(each.value.service_type, "Gateway")]
  }
}