# ##################### VERSION 2.0 #####################
# module "wrapper_base" {
#   source = "git@gitlab.com:espinlabs/gocloud/infrastructure-engine/customer-wrappers/common/infrastructure.git//base?ref=v2.0.0"

#   metadata = local.metadata

#   vpc_parameters = {
#     vpc_cidr = local.vpc_cidr
#     private_subnets = [
#       cidrsubnet(local.vpc_cidr, 4, 0),
#       cidrsubnet(local.vpc_cidr, 4, 1),
#       cidrsubnet(local.vpc_cidr, 4, 2)
#     ]
#     public_subnets = [
#       cidrsubnet(local.vpc_cidr, 4, 3),
#       cidrsubnet(local.vpc_cidr, 4, 4),
#       cidrsubnet(local.vpc_cidr, 4, 5)
#     ]
#     database_subnets = [
#       cidrsubnet(local.vpc_cidr, 4, 6),
#       cidrsubnet(local.vpc_cidr, 4, 7),
#       cidrsubnet(local.vpc_cidr, 4, 8)
#     ]
#     elasticache_subnets = [
#       cidrsubnet(local.vpc_cidr, 4, 9),
#       cidrsubnet(local.vpc_cidr, 4, 10),
#       cidrsubnet(local.vpc_cidr, 4, 11)
#     ]
#     elasticache_dedicated_network_acl = false

#     default_security_group_ingress = [
#       {
#         "cidr_blocks" = "0.0.0.0/0",
#         "from_port"   = 0,
#         "to_port"     = 0,
#         "protocol"    = "-1"
#       }
#     ]
#     default_security_group_egress = [
#       {
#         "cidr_blocks" = "0.0.0.0/0",
#         "from_port"   = 0,
#         "to_port"     = 0,
#         "protocol"    = "-1"
#       }
#     ]
#     enable_nat_gateway         = false
#     enable_ec2_nat_gateway     = true
#     ec2_nat_gateway_attach_eip = true
#   }

# }

################### UPGRADE 3.0 #####################
module "wrapper_base" {
  source = "../../"
  # source = "git@gitlab.com:espinlabs/gocloud/infrastructure-engine/customer-wrappers/common/infrastructure.git//base?ref=v3.0.0"

  metadata = local.metadata

  vpc_parameters = {
    vpc = {
      # VPC with EC2-NAT
      "" = {
        vpc_cidr = "10.130.0.0/16"
        internet_gateway = {
          "" = {}
        }
        nat_gateway = {
          "natgw" = {
            subnet = "public-${data.aws_region.current.region}a"
            kind   = "ec2" # OPCION AWS
            nat_parameters = {
              ec2_nat_gateway_attach_eip = true,
              connectivity_type          = "public"
            }
          }
        }
        route_table = {
          "private" = {
            routes = {
            }
            default_route = {
              network_interface = "natgw"
            }
          }
          "public" = {
            routes = {
            }
            default_route = {
              gateway = ""
            }
          }
        }
        network_acl = {}
        subnets = {
          "private" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 0)
              az          = "a"
              route_table = "private"
              network_acl = ""
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 1)
              az          = "b"
              route_table = "private"
              network_acl = ""
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 2)
              az          = "c"
              route_table = "private"
              network_acl = ""
            }
          }
          "public" = {
            "${data.aws_region.current.region}a" = {
              cidr_block              = cidrsubnet("10.130.0.0/16", 4, 3)
              az                      = "a"
              route_table             = "public"
              network_acl             = ""
              map_public_ip_on_launch = true
            }
            "${data.aws_region.current.region}b" = {
              cidr_block              = cidrsubnet("10.130.0.0/16", 4, 4)
              az                      = "b"
              route_table             = "public"
              network_acl             = ""
              map_public_ip_on_launch = true
            }
            "${data.aws_region.current.region}c" = {
              cidr_block              = cidrsubnet("10.130.0.0/16", 4, 5)
              az                      = "c"
              route_table             = "public"
              network_acl             = ""
              map_public_ip_on_launch = true
            }
          }
          "db" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 6)
              az          = "a"
              route_table = "private"
              network_acl = ""
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 7)
              az          = "b"
              route_table = "private"
              network_acl = ""
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 8)
              az          = "c"
              route_table = "private"
              network_acl = ""
            }
          }
          "elasticache" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 9)
              az          = "a"
              route_table = "private"
              network_acl = ""
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 10)
              az          = "b"
              route_table = "private"
              network_acl = ""
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.130.0.0/16", 4, 11)
              az          = "c"
              route_table = "private"
              network_acl = ""
            }
          }
        }
        endpoints = {
          "00" = {
            service         = "s3"
            service_type    = "Gateway"
            route_table_ids = ["private", "public"]
            policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
          },
          "01" = {
            service         = "dynamodb"
            service_type    = "Gateway"
            route_table_ids = ["private", "public"]
            policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
          }
        }
      }
      ## VPC with AWS-NAT
      # "" = { 
      #   vpc_cidr = "10.130.0.0/16"
      #   internet_gateway = {
      #     "" = {}
      #   }
      #   nat_gateway = {
      #     ## Depends on the subnet used in the NAT
      #     "us-east-1a" = {
      #       subnet = "public-${data.aws_region.current.region}a"
      #       kind   = "aws" # OPCION AWS
      #       # nat_parameters = {
      #       #   ec2_nat_gateway_attach_eip = true,
      #       #   connectivity_type          = "public"
      #       # }
      #     }
      #   }
      #   route_table = {
      #     "private" = {
      #       routes = {
      #       }
      #       default_route = {
      #         nat_gateway = "us-east-1a"
      #       }
      #     }
      #     "public" = {
      #       routes = {
      #       }
      #       default_route = {
      #         gateway = ""
      #       }
      #     }
      #   }
      #   network_acl = {}
      #   subnets = {
      #     "private" = {
      #       "${data.aws_region.current.region}a" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 0)
      #         az          = "a"
      #         route_table = "private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}b" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 1)
      #         az          = "b"
      #         route_table = "private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}c" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 2)
      #         az          = "c"
      #         route_table = "private"
      #         network_acl = ""
      #       }
      #     }
      #     "public" = {
      #       "${data.aws_region.current.region}a" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 3)
      #         az          = "a"
      #         route_table = "public"
      #         network_acl = ""
      #         map_public_ip_on_launch = true
      #       }
      #       "${data.aws_region.current.region}b" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 4)
      #         az          = "b"
      #         route_table = "public"
      #         network_acl = ""
      #         map_public_ip_on_launch = true
      #       }
      #       "${data.aws_region.current.region}c" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 5)
      #         az          = "c"
      #         route_table = "public"
      #         network_acl = ""
      #         map_public_ip_on_launch = true
      #       }
      #     }
      #     "db" = {
      #       "${data.aws_region.current.region}a" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 6)
      #         az          = "a"
      #         route_table = "private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}b" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 7)
      #         az          = "b"
      #         route_table = "private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}c" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 8)
      #         az          = "c"
      #         route_table = "private"
      #         network_acl = ""
      #       }
      #     }
      #     "elasticache" = {
      #       "${data.aws_region.current.region}a" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 9)
      #         az          = "a"
      #         route_table = "private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}b" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 10)
      #         az          = "b"
      #         route_table = "private"
      #         network_acl = ""
      #       }
      #       "${data.aws_region.current.region}c" = {
      #         cidr_block  = cidrsubnet("10.130.0.0/16", 4, 11)
      #         az          = "c"
      #         route_table = "private"
      #         network_acl = ""
      #       }
      #     }
      #   }
      #   endpoints = {
      #     "00" = {
      #       service         = "s3"
      #       service_type    = "Gateway"
      #       route_table_ids = ["private", "public"]
      #       policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
      #     },
      #     "01" = {
      #       service         = "dynamodb"
      #       service_type    = "Gateway"
      #       route_table_ids = ["private", "public"]
      #       policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      #     }
      #   }
      # }
    }
    tgw = {}
    vpn = {}
  }
}

# VPC
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_vpc.this[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.vpc[""].aws_vpc.this
}

# Subnets
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.database[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-db-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.database[1]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-db-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.database[2]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-db-us-east-1c"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.elasticache[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-elasticache-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.elasticache[1]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-elasticache-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.elasticache[2]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-elasticache-us-east-1c"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.private[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-private-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.private[1]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-private-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.private[2]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-private-us-east-1c"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.public[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-public-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.public[1]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-public-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_subnet.public[2]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-public-us-east-1c"].aws_subnet.this[0]
}

# Route Table
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table.private[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.route-table["-private"].aws_route_table.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table.public[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.route-table["-public"].aws_route_table.this[0]
}

# IGW
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_internet_gateway.this[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.internet-gateway["-"].aws_internet_gateway.this[0]
}
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route.public_internet_gateway[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.route-association["-public"].aws_route.default[0]
}
# Route Table association
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.database[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-db-us-east-1a"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.database[1]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-db-us-east-1b"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.database[2]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-db-us-east-1c"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-elasticache-us-east-1a"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[1]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-elasticache-us-east-1b"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[2]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-elasticache-us-east-1c"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.private[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-private-us-east-1a"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.private[1]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-private-us-east-1b"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.private[2]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-private-us-east-1c"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.public[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-public-us-east-1a"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.public[1]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-public-us-east-1b"].aws_route_table_association.this
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route_table_association.public[2]
  to   = module.wrapper_base.module.wrapper_vpc.module.subnet["-public-us-east-1c"].aws_route_table_association.this
}

# Default VPC Resources
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_default_network_acl.this[0]
  to   = module.wrapper_base.module.wrapper_vpc.aws_default_network_acl.this[""]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_default_route_table.default[0]
  to   = module.wrapper_base.module.wrapper_vpc.aws_default_route_table.this[""]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_default_security_group.this[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.vpc[""].aws_default_security_group.default
}

# VPC Endpoints
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-endpoint.aws_vpc_endpoint.this["s3"]
  to   = module.wrapper_base.module.wrapper_vpc.module.vpc-endpoint[""].aws_vpc_endpoint.this["00"]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-endpoint.aws_vpc_endpoint.this["dynamodb"]
  to   = module.wrapper_base.module.wrapper_vpc.module.vpc-endpoint[""].aws_vpc_endpoint.this["01"]
}

# # if using AWS NAT-GW
# moved {
#   from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_route.private_nat_gateway[0]
#   to   = module.wrapper_base.module.wrapper_vpc.module.route-association["-private"].aws_route.default[0]
# }
# moved {
#   from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_eip.nat[0]
#   to   = module.wrapper_base.module.wrapper_vpc.module.nat-gateway["-us-east-1a"].aws_eip.this[0]
# }
# moved {
#   from = module.wrapper_base.module.wrapper_vpc.module.vpc.aws_nat_gateway.this[0]
#   to   = module.wrapper_base.module.wrapper_vpc.module.nat-gateway["-us-east-1a"].aws_nat_gateway.this[0]
# }

# EC2 Nat-Gateway
## if using Elastic IP with the EC2-NAT
moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_eip.this[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.nat-gateway["-natgw"].module.vpc-ec2-nat-gateway[0].aws_eip.this[0]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_route.this[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.route-association["-private"].aws_route.default[0]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_instance_profile.this[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.nat-gateway["-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_instance_profile.this[0]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role.this[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.nat-gateway["-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role.this[0]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]
  to   = module.wrapper_base.module.wrapper_vpc.module.nat-gateway["-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.ignore_ami[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.nat-gateway["-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_instance.ignore_ami[0]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group.this[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.nat-gateway["-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group.this[0]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.egress_rules[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.nat-gateway["-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.egress_rules[0]
}

moved {
  from = module.wrapper_base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.ingress_rules[0]
  to   = module.wrapper_base.module.wrapper_vpc.module.nat-gateway["-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.ingress_rules[0]
}