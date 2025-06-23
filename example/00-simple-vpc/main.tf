module "wrapper_vpc" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    vpc = {
      "test" = {
        # VPC Parameters
        vpc_cidr = "10.130.0.0/16"
        internet_gateway = {
          "00-igw" = {}
        }
        nat_gateway = {
          "natgw" = {
            subnet = "public-${data.aws_region.current.name}a"
            kind   = "ec2" # OPCION AWS
            nat_parameters = {
              ec2_nat_gateway_attach_eip = true,
              connectivity_type          = "public"
            }
          }
        }
        route_table = {
          "00-private" = {
            routes = {
            }
            default_route = {
              network_interface = "natgw"
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
            "${data.aws_region.current.name}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 0)
              az          = "a"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.name}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 1)
              az          = "b"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.name}c" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 2)
              az          = "c"
              route_table = "00-private"
              network_acl = ""
            }
          }
          "public" = {
            "${data.aws_region.current.name}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 3)
              az          = "a"
              route_table = "00-public"
              network_acl = ""
            }
            "${data.aws_region.current.name}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 4)
              az          = "b"
              route_table = "00-public"
              network_acl = ""
            }
            "${data.aws_region.current.name}c" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 5)
              az          = "c"
              route_table = "00-public"
              network_acl = ""
            }
          }
          "db" = {
            "${data.aws_region.current.name}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 6)
              az          = "a"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.name}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 7)
              az          = "b"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.name}c" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 8)
              az          = "c"
              route_table = "00-private"
              network_acl = ""
            }
          }
          "elasticache" = {
            "${data.aws_region.current.name}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 9)
              az          = "a"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.name}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 10)
              az          = "b"
              route_table = "00-private"
              network_acl = ""
            }
            "${data.aws_region.current.name}c" = {
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

      # "prod" = {
      #   vpc_cidr = "10.16.0.0/16"
      #   internet_gateway = {
      #     "00-igw" = {}
      #   }
      #   nat_gateway = {
      #     "00-nat" = {
      #       subnet = "public-02"
      #       kind   = "aws" # OPCION AWS
      #     }
      #   }
      #   route_table = {
      #     "00-private" = {
      #       routes = {
      #       }
      #       default_route = {
      #         nat_gateway = "00-nat"
      #       }
      #     }
      #     "00-public" = {
      #       routes = {
      #       }
      #       default_route = {
      #         gateway = "00-igw"
      #       }
      #     }
      #     "00-databases" = {
      #       routes = {
      #       }
      #       default_route = {
      #         nat_gateway = "00-nat"
      #       }
      #     }
      #   }
      #   network_acl = {
      #     "00" = {
      #       rules = {}
      #     }
      #   }
      #   subnets = {
      #     "private" = {
      #       "01" = {
      #         cidr_block  = "10.16.1.0/24"
      #         az          = "a"
      #         route_table = "00-private"
      #         network_acl = "00"
      #       }
      #       "02" = {
      #         cidr_block  = "10.16.2.0/24"
      #         az          = "b"
      #         route_table = "00-private"
      #         network_acl = "00"
      #       }
      #       "03" = {
      #         cidr_block  = "10.16.3.0/24"
      #         az          = "c"
      #         route_table = "00-private"
      #         network_acl = "00"
      #       }
      #     }
      #     "public" = {
      #       "01" = {
      #         cidr_block  = "10.16.101.0/24"
      #         az          = "a"
      #         route_table = "00-public"
      #         network_acl = "00"
      #       }
      #       "02" = {
      #         cidr_block  = "10.16.102.0/24"
      #         az          = "b"
      #         route_table = "00-public"
      #         network_acl = "00"
      #       }
      #       "03" = {
      #         cidr_block  = "10.16.103.0/24"
      #         az          = "c"
      #         route_table = "00-public"
      #         network_acl = "00"
      #       }
      #     }
      #     "db" = {
      #       "01" = {
      #         cidr_block  = "10.16.201.0/24"
      #         az          = "a"
      #         route_table = "00-databases"
      #         network_acl = "00"
      #       }
      #       "02" = {
      #         cidr_block  = "10.16.202.0/24"
      #         az          = "b"
      #         route_table = "00-databases"
      #         network_acl = "00"
      #       }
      #       "03" = {
      #         cidr_block  = "10.16.203.0/24"
      #         az          = "c"
      #         route_table = "00-databases"
      #         network_acl = "00"
      #       }
      #     }
      #     "elasticache" = {
      #       "01" = {
      #         cidr_block  = "10.16.211.0/24"
      #         az          = "a"
      #         route_table = "00-databases"
      #         network_acl = "00"
      #       }
      #       "02" = {
      #         cidr_block  = "10.16.212.0/24"
      #         az          = "b"
      #         route_table = "00-databases"
      #         network_acl = "00"
      #       }
      #       "03" = {
      #         cidr_block  = "10.16.213.0/24"
      #         az          = "c"
      #         route_table = "00-databases"
      #         network_acl = "00"
      #       }
      #     }
      #   }
      #   endpoints = {
      #     "00" = {
      #       service         = "s3"
      #       service_type    = "Gateway"
      #       route_table_ids = ["00-private", "00-public", "00-databases"]
      #       policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
      #     },
      #     "01" = {
      #       service         = "dynamodb"
      #       service_type    = "Gateway"
      #       route_table_ids = ["00-private", "00-public", "00-databases"]
      #       policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      #     }
      #   }
      # }
    }
    tgw = {}
    vpn = {}
  }
}

# # VPC
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_vpc.this[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.vpc["test"].aws_vpc.this
# }

# # Subnets
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.database[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1a"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.database[1]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1b"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.database[2]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1c"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.elasticache[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1a"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.elasticache[1]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1b"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.elasticache[2]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1c"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.private[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1a"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.private[1]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1b"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.private[2]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1c"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.public[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1a"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.public[1]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1b"].aws_subnet.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_subnet.public[2]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1c"].aws_subnet.this[0]
# }

# # Route Table
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table.private[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.route-table["test-00-private"].aws_route_table.this[0]
# }
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table.public[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.route-table["test-00-public"].aws_route_table.this[0]
# }

# # Default Route
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_internet_gateway.this[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.internet-gateway["test-00-igw"].aws_internet_gateway.this[0]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route.public_internet_gateway[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.route-association["test-00-public"].aws_route.default[0]
# }

# # Route Table association
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.database[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1a"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.database[1]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1b"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.database[2]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1c"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1a"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[1]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1b"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[2]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1c"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.private[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1a"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.private[1]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1b"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.private[2]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1c"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.public[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1a"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.public[1]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1b"].aws_route_table_association.this
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_route_table_association.public[2]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1c"].aws_route_table_association.this
# }

# # Default VPC Resources
# moved {
#   from = module.wrapper_vpc.module.vpc.aws_default_network_acl.this[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.aws_default_network_acl.this["test"]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_default_route_table.default[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.aws_default_route_table.this["test"]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc.aws_default_security_group.this[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.vpc["test"].aws_default_security_group.default
# }

# # VPC Endpoints
# moved {
#   from = module.wrapper_vpc.module.vpc-endpoint.aws_vpc_endpoint.this["s3"]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.vpc-endpoint["test"].aws_vpc_endpoint.this["00"]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc-endpoint.aws_vpc_endpoint.this["dynamodb"]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.vpc-endpoint["test"].aws_vpc_endpoint.this["01"]
# }

# # EC2 Nat-Gateway
# moved {
#   from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_eip.this[0]
#   to = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].aws_eip.this[0]
# } ## if using Elastic IP with the EC2-NAT

# moved {
#   from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_route.this[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.route-association["test-00-private"].aws_route.default[0]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_instance_profile.this[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_instance_profile.this[0]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role.this[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role.this[0]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.ignore_ami[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_instance.ignore_ami[0]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group.this[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group.this[0]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.egress_rules[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.egress_rules[0]
# }

# moved {
#   from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.ingress_rules[0]
#   to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.ingress_rules[0]
# }