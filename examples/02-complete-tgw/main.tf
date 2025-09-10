module "wrapper_vpc" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    vpc = {
      "prod2" = {
        # VPC Parameters
        vpc_cidr           = "10.15.0.0/16" #Required
        custom_common_name = ""

        flow_logs = {
          "00" = {
            ## Defines wich resources the flow logs will be using
            enable_flow_log = false
          }
        }
        internet_gateway = {
          "igw" = {
          }
        }
        nat_gateway = {
          "natgw" = {
            subnet = "public-${data.aws_region.current.region}a"
            kind   = "aws" # OPCION AWS
          }
        }
        route_table = {
          "private" = {
            routes = {
            }
            default_route = {
              nat_gateway = "natgw"
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
          "private" = {
            rules = {}
          }
          "public" = {
            rules = {}
          }
        }
        subnets = {
          "private" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 0)
              az          = "a"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 1)
              az          = "b"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 2)
              az          = "c"
              route_table = "private"
              network_acl = "private"
            }
          }
          "public" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 3)
              az          = "a"
              route_table = "public"
              network_acl = "public"
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 4)
              az          = "b"
              route_table = "public"
              network_acl = "public"
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 5)
              az          = "c"
              route_table = "public"
              network_acl = "public"
            }
          }
          "db" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 6)
              az          = "a"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 7)
              az          = "b"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 8)
              az          = "c"
              route_table = "private"
              network_acl = "private"
            }
          }
          "elasticache" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 9)
              az          = "a"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 10)
              az          = "b"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.15.0.0/16", 4, 11)
              az          = "c"
              route_table = "private"
              network_acl = "private"
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
      "dev" = {
        # VPC Parameters
        vpc_cidr           = "10.16.0.0/16" #Required
        custom_common_name = ""

        flow_logs = {
          "00" = {
            ## Defines wich resources the flow logs will be using
            enable_flow_log = false
          }
        }
        internet_gateway = {
          "igw" = {
          }
        }
        nat_gateway = {
          "natgw" = {
            subnet = "public-${data.aws_region.current.region}a"
            kind   = "ec2" # OPCION AWS
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
              gateway = "igw"
            }
          }
        }
        network_acl = {
          "private" = {
            rules = {}
          }
          "public" = {
            rules = {}
          }
        }
        subnets = {
          "private" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.16.0.0/16", 4, 0)
              az          = "a"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.16.0.0/16", 4, 1)
              az          = "b"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.16.0.0/16", 4, 2)
              az          = "c"
              route_table = "private"
              network_acl = "private"
            }
          }
          "public" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.16.0.0/16", 4, 3)
              az          = "a"
              route_table = "public"
              network_acl = "public"
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.16.0.0/16", 4, 4)
              az          = "b"
              route_table = "public"
              network_acl = "public"
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.16.0.0/16", 4, 5)
              az          = "c"
              route_table = "public"
              network_acl = "public"
            }
          }
          "db" = {
            "${data.aws_region.current.region}a" = {
              cidr_block  = cidrsubnet("10.16.0.0/16", 4, 6)
              az          = "a"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.region}b" = {
              cidr_block  = cidrsubnet("10.16.0.0/16", 4, 7)
              az          = "b"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.region}c" = {
              cidr_block  = cidrsubnet("10.16.0.0/16", 4, 8)
              az          = "c"
              route_table = "private"
              network_acl = "private"
            }
          }
        }
      }
    }

    tgw = {
      "tgw-01" = {
        # Variables to deploy transit gateway resource

        # create_tgw = true
        # create_tgw_routes = false

        # description                            = "Transit Gateway 01"
        # amazon_side_asn                        = "64512"
        # enable_default_route_table_association = true
        # enable_default_route_table_propagation = true
        # enable_multicast_support               = false
        # enable_vpn_ecmp_support                = true
        # enable_dns_support                     = true

        # transit_gateway_cidr_blocks    = []
        # transit_gateway_route_table_id = null

        ## Allow the sharing of the TGW using RAM
        share_tgw = true
        ## If enabled you can administer which accounts will have access to the TGW resources
        ram_principals = ["123456789"]
        # ram_allow_external_principals = false
        # ram_name                      = null
        enable_auto_accept_shared_attachments = true

        ## Managing TGW VPC Attachments
        vpc_attachments = {
          "prod2" = {                                                                                                            //must be the same vpc_name
            subnet_ids                                      = ["private-us-east-1a", "private-us-east-1b", "private-us-east-1c"] // Only 1 Subnet per AZ
            dns_support                                     = true
            ipv6_support                                    = false
            transit_gateway_default_route_table_association = true
            transit_gateway_default_route_table_propagation = true
            tgw_routes = [
              {
                destination_cidr_block = "10.15.0.0/16"

              },
              {
                blackhole              = true
                destination_cidr_block = "0.0.0.0/0"
              }
            ]
            vpc_routes = {
              "private" = {
                destination_cidr_block = [
                  "10.16.0.0/16", # TEST2
                  "10.17.0.0/16"  # TEST3
                ]
              }
              "public" = {
                destination_cidr_block = [
                  "10.16.0.0/16", # TEST2
                  "10.17.0.0/16"  # TEST3
                ]
              }
            }

          }
          "dev" = {
            dns_support                                     = true
            ipv6_support                                    = false
            subnet_ids                                      = ["private-us-east-1a", "private-us-east-1b", "private-us-east-1c"] // Only 1 Subnet per AZ
            transit_gateway_default_route_table_association = true
            transit_gateway_default_route_table_propagation = true

            tgw_routes = [
              {
                destination_cidr_block = "10.16.0.0/16"

              },
              {
                blackhole              = true
                destination_cidr_block = "0.0.0.0/0"
              }
            ]
          }
        }
        ## Managing route association of route tables of attached VPC's
        vpc_routes = {
          "prod2" = {
            "private" = {
              destination_cidr_block = [
                "10.16.0.0/16", # TEST2
                "10.17.0.0/16"  # TEST3
              ]
            }
            "public" = {
              destination_cidr_block = [
                "10.16.0.0/16", # TEST2
                "10.17.0.0/16"  # TEST3
              ]
            }
          }
          "dev" = {
            "private" = {
              destination_cidr_block = [
                "10.15.0.0/16", # TEST1
                "10.17.0.0/16"  # TEST3
              ]
            }
            "public" = {
              destination_cidr_block = [
                "10.15.0.0/16", # TEST1
                "10.17.0.0/16"  # TEST3
              ]
            }
          }
        }
      }
    }
  }

}