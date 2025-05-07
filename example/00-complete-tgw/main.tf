module "wrapper_base" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    vpc = {
      "test1" = {
        # VPC Parameters
        vpc_cidr = "10.15.0.0/16" #Required
        flow_logs = {
          "00" = {
          }
        }
        internet_gateway = {
          "igw" = {}
        }
        nat_gateway = {
          "natgw" = {
            subnet = "public-01"
            kind   = "ec2" # OPCION EC2
          }
        }
        route_table = {
          "default" = {
            # Modifies aws_default_route_table
          }
          "private" = {
            routes = {
            }
            default_route = {
              network_interface = "natgw"
            }
          }
          "public" = {
            routes = {}
            default_route = {
              gateway = "igw"
            }
          }
        }
        network_acl = {
          "default" = {
            # Modifies aws_default_network_acl
          }
          "private" = {
            rules = {

            }
          }
          "public" = {
            rules = {}
          }
        }
        subnets = {
          "private" = {
            "01" = {
              cidr_block  = "10.15.1.0/24"
              az          = "a"
              route_table = "private"
              network_acl = "private"
            }
            "02" = {
              cidr_block  = "10.15.2.0/24"
              az          = "b"
              route_table = "private"
              network_acl = "private"
            }
          }
          "public" = {
            "01" = {
              cidr_block  = "10.15.11.0/24"
              az          = "a"
              route_table = "public"
              network_acl = "public"
            }
            "02" = {
              cidr_block  = "10.15.12.0/24"
              az          = "b"
              route_table = "public"
              network_acl = "public"
            }
          }
        }
      }
      "test2" = {
        # VPC Parameters
        vpc_cidr = "10.16.0.0/16" #Required
        flow_logs = {
          "00" = {
          }
        }
        internet_gateway = {
          "igw" = {}
        }
        nat_gateway = {
          "natgw" = {
            subnet = "public-01"
            kind   = "ec2" # OPCION EC2
          }
        }
        route_table = {
          "default" = {
            # Modifies aws_default_route_table
          }
          "private" = {
            routes = {
            }
            default_route = {
              network_interface = "natgw"
            }
          }
          "public" = {
            routes = {}
            default_route = {
              gateway = "igw"
            }
          }
        }
        network_acl = {
          "default" = {
            # Modifies aws_default_network_acl
          }
          "private" = {
            rules = {

            }
          }
          "public" = {
            rules = {}
          }
        }
        subnets = {
          "private" = {
            "01" = {
              cidr_block  = "10.16.1.0/24"
              az          = "a"
              route_table = "private"
              network_acl = "private"
            }
            "02" = {
              cidr_block  = "10.16.2.0/24"
              az          = "b"
              route_table = "private"
              network_acl = "private"
            }
          }
          "public" = {
            "01" = {
              cidr_block  = "10.16.11.0/24"
              az          = "a"
              route_table = "public"
              network_acl = "public"
            }
            "02" = {
              cidr_block  = "10.16.12.0/24"
              az          = "b"
              route_table = "public"
              network_acl = "public"
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
        ram_principals = ["058264150413"]
        # ram_allow_external_principals = false
        # ram_name                      = null
        enable_auto_accept_shared_attachments = true

        ## Managing TGW VPC Attachments
        vpc_attachments = {
          "test1" = {  //must be the same vpc_name
            subnet_ids                                      = ["private-01", "private-02"] // Only 1 Subnet per AZ
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
          }
          "test2" = {
            dns_support                                     = true
            ipv6_support                                    = false
            subnet_ids                                      = ["private-01", "private-02"] // Only 1 Subnet per AZ
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
          "test1" = {
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
          "test2" = {
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