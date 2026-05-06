module "wrapper_base" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    "vpc-01" = {
      vpc_cidr = local.vpc_cidr
      internet_gateway = {
        "igw" = {}
      }
      nat_gateway = {
        "natgw" = {
          subnet = "public-a"
          kind   = "ec2"
          nat_parameters = {
            ec2_nat_gateway_attach_eip = true,
            connectivity_type          = "public"
          }
        }
        # for AWs NatGW
        # "natgw" = {
        #   subnet = "public-a"
        #   kind   = "aws"
        # }
      }
      route_table = {
        "private" = {
          routes = {
          }
          default_route = {
            network_interface = "natgw"
            # nat_gateway = "natgw" # for AWS NatGW
          }
        }
        "public" = {
          routes = {
          }
          default_route = {
            gateway = "igw"
          }
        }
      }
      network_acl = {
      }
      subnets = {
        "private" = {
          "a" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 0)
            az          = "a"
            route_table = "private"
            network_acl = ""
          }
          "b" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 1)
            az          = "b"
            route_table = "private"
            network_acl = ""
          }
          "c" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 2)
            az          = "c"
            route_table = "private"
            network_acl = ""
          }
        }
        "public" = {
          "a" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 3)
            az          = "a"
            route_table = "public"
            network_acl = ""
            map_public_ip_on_launch = true
          }
          "b" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 4)
            az          = "b"
            route_table = "public"
            network_acl = ""
            map_public_ip_on_launch = true
          }
          "c" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 5)
            az          = "c"
            route_table = "public"
            network_acl = ""
            map_public_ip_on_launch = true
          }
        }
        "db" = {
          "a" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 6)
            az          = "a"
            route_table = "private"
            network_acl = ""
          }
          "b" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 7)
            az          = "b"
            route_table = "private"
            network_acl = ""
          }
          "c" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 8)
            az          = "c"
            route_table = "private"
            network_acl = ""
          }
        }
        "elasticache" = {
          "a" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 9)
            az          = "a"
            route_table = "private"
            network_acl = ""
          }
          "b" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 10)
            az          = "b"
            route_table = "private"
            network_acl = ""
          }
          "c" = {
            cidr_block  = cidrsubnet(local.vpc_cidr, 4, 11)
            az          = "c"
            route_table = "private"
            network_acl = ""
          }
        }
      }
      endpoints = {
        "s3" = {
          service         = "s3"
          service_type    = "Gateway"
          route_table_ids = ["private", "public"]
          policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
        },
        "dynamodb" = {
          service         = "dynamodb"
          service_type    = "Gateway"
          route_table_ids = ["private", "public"]
          policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
        }
      }
    }
  }
}