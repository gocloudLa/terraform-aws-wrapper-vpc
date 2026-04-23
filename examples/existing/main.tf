module "wrapper_vpc" {
  source = "../../"

  metadata = local.metadata

  # Lo esperado de este example es que se generesn en democorp.cloud-lab
  # Dos subnets dmc-lab-new-a / dmc-lab-new-b ( o similar )
  vpc_parameters = {
    "existing" = {
      # VPC Parameters
      vpc_id = "vpc-0a09d7d0d1fe4acf2"
      create_vpc = false # Opcional si es necesario
      subnets = {
        "new1" = {
          "a" = {
            cidr_block  = cidrsubnet("10.15.0.0/16", 4, 0)
            az          = "a"
            route_table_id = "rtb-07598499baa060b01"
            network_acl    = "acl-0a1fc3cc329a8d3ea"
            create_subnet  = false

          }
          "a" = {
            cidr_block  = cidrsubnet("10.15.0.0/16", 4, 2)
            az          = "b"
            route_table_id = "rtb-07598499baa060b01"
            network_acl    = "acl-0a1fc3cc329a8d3ea"
            create_subnet  = false

          }
        }
      }
    }

  }
}