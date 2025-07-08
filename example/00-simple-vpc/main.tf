module "wrapper_base" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    vpc = {
      # "ex" = { ## with EC2-NAT
      #   vpc_cidr = "10.130.0.0/16"
      #   internet_gateway = {
      #     "00-igw" = {}
      #   }
      #   nat_gateway = {
      #     "natgw" = {
      #       subnet = "public-${data.aws_region.current.region}a"
      #       kind   = "ec2" # OPCION AWS
      #       nat_parameters = {
      #         ec2_nat_gateway_attach_eip = true,
      #         connectivity_type          = "public"
      #       }
      #     }
      #   }
      #   route_table = {
      #     "00-private" = {
      #       routes = {
      #       }
      #       default_route = {
      #         network_interface = "natgw"
      #       }
      #     }
      #     "00-public" = {
      #       routes = {
      #       }
      #       default_route = {
      #         gateway = "00-igw"
      #       }
      #     }
      #   }
      #   network_acl = {}
      #   subnets = {
      #     "private" = {
      #       "${data.aws_region.current.region}a" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 0)
      #         az          = "a"
      #         route_table = "00-private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}b" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 1)
      #         az          = "b"
      #         route_table = "00-private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}c" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 2)
      #         az          = "c"
      #         route_table = "00-private"
      #         network_acl = ""
      #       }
      #     }
      #     "public" = {
      #       "${data.aws_region.current.region}a" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 3)
      #         az          = "a"
      #         route_table = "00-public"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}b" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 4)
      #         az          = "b"
      #         route_table = "00-public"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}c" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 5)
      #         az          = "c"
      #         route_table = "00-public"
      #         network_acl = ""
      #       }
      #     }
      #     "db" = {
      #       "${data.aws_region.current.region}a" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 6)
      #         az          = "a"
      #         route_table = "00-private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}b" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 7)
      #         az          = "b"
      #         route_table = "00-private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}c" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 8)
      #         az          = "c"
      #         route_table = "00-private"
      #         network_acl = ""
      #       }
      #     }
      #     "elasticache" = {
      #       "${data.aws_region.current.region}a" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 9)
      #         az          = "a"
      #         route_table = "00-private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}b" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 10)
      #         az          = "b"
      #         route_table = "00-private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}c" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 11)
      #         az          = "c"
      #         route_table = "00-private"
      #         network_acl = ""
      #       }
      #     }
      #   }
      #   endpoints = {
      #     "00" = {
      #       service         = "s3"
      #       service_type    = "Gateway"
      #       route_table_ids = ["00-private", "00-public"]
      #       policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
      #     },
      #     "01" = {
      #       service         = "dynamodb"
      #       service_type    = "Gateway"
      #       route_table_ids = ["00-private", "00-public"]
      #       policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      #     }
      #   }
      # }
      "ex" = { ## with AWS-NAT
        vpc_cidr = "10.130.0.0/16"
        internet_gateway = {
          "00-igw" = {}
        }
        nat_gateway = {
          "natgw" = {
            subnet = "public-${data.aws_region.current.region}a"
            kind   = "aws" # OPCION AWS
            # nat_parameters = {
            #   ec2_nat_gateway_attach_eip = true,
            #   connectivity_type          = "public"
            # }
          }
        }
        route_table = {
          "00-private" = {
            routes = {
            }
            default_route = {
              nat_gateway = "natgw"
            }
          }
          "00-public" = {
            routes = {
            }
            default_route = {
              gateway = "00-igw"
            }
          }
        }
        network_acl = {}
        subnets = {
          "private" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 0)
              az          = "a"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 1)
              az          = "b"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 2)
              az          = "c"
              route_table = "00-private"
              network_acl = ""
            }
          }
          "public" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 3)
              az          = "a"
              route_table = "00-public"
              network_acl = ""
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 4)
              az          = "b"
              route_table = "00-public"
              network_acl = ""
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 5)
              az          = "c"
              route_table = "00-public"
              network_acl = ""
            }
          }
          "db" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 6)
              az          = "a"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 7)
              az          = "b"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 8)
              az          = "c"
              route_table = "00-private"
              network_acl = ""
            }
          }
          "elasticache" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 9)
              az          = "a"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 10)
              az          = "b"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 11)
              az          = "c"
              route_table = "00-private"
              network_acl = ""
            }
          }
        }
        endpoints = {
          "00" = {
            service         = "s3"
            service_type    = "Gateway"
            route_table_ids = ["00-private", "00-public"]
            policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
          },
          "01" = {
            service         = "dynamodb"
            service_type    = "Gateway"
            route_table_ids = ["00-private", "00-public"]
            policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
          }
        }
      }
    }
    tgw = {}
    vpn = {}
  }
}