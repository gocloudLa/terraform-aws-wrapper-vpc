module "wrapper_vpc" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    vpc = {

      "prod" = {
        # VPC Parameters
        vpc_cidr           = "10.15.0.0/16" #Required
        custom_common_name = ""

        ## Default tenancy delegates the decistion of the tenancy type on the ec2 resource creation.
        # instance_tenancy                     = "default"

        ## If the ipv4 an IPam IPv4 resource was created
        # ipv4_ipam_pool_id                    = null
        # ipv4_netmask_length                  = null

        ## If ipv6 is enabled
        # enable_ipv6                          = false
        # ipv6_cidr_block                      = null
        # ipv6_ipam_pool_id                    = null
        # ipv6_netmask_length                  = null
        # ipv6_cidr_block_network_border_group = null

        ## DNS resolution and netwrok addres metrics resolution
        # enable_dns_hostnames                 = true
        # enable_dns_support                   = true
        # enable_network_address_usage_metrics = null

        ## DHCP Options
        # enable_dhcp_options               = false
        # dhcp_options_domain_name          = ""
        # dhcp_options_domain_name_servers  = []
        # dhcp_options_ntp_servers          = []
        # dhcp_options_netbios_name_servers = []
        # dhcp_options_netbios_node_type    = ""

        flow_logs = {
          "00" = {
            ## Defines wich resources the flow logs will be using
            enable_flow_log = false
            # create_flow_log_cloudwatch_iam_role             = true
            # create_flow_log_cloudwatch_log_group            = true
            # flow_log_destination_arn                        = false
            # flow_log_cloudwatch_iam_role_arn                = false
            # flow_log_cloudwatch_log_group_name_prefix       = false
            # flow_log_cloudwatch_log_group_kms_key_id        = null

            ## Configuration of resource
            # vpc_flow_log_permissions_boundary               = null
            # flow_log_cloudwatch_log_group_retention_in_days = 365
            # flow_log_traffic_type                           = "ALL"
            # flow_log_destination_type                       = "cloud-watch-logs"
            # flow_log_log_format                             = null
            # flow_log_max_aggregation_interval               = 600
            # flow_log_hive_compatible_partitions             = false
            # flow_log_per_hour_partition                     = false
          }
        }
        internet_gateway = {
          "igw" = {
            ## Configuration of Internet Gateway resource
            # create_internet_gateway     = true
            # create_egress_only_igw      = false
            # route_table_id              = false
            # enable_ipv6                 = false
            # destination_ipv6_cidr_block = false
          }
        }
        nat_gateway = {
          "natgw" = {
            subnet = "public-${data.aws_region.current.region}a"
            kind   = "aws" # OPCION AWS
            # create_nat_gateway = true
            # nat_parameters     = {
            #   ec2_nat_gateway_attach_eip = false
            # }
          }
          # "natgw-02" = {
          #   subnet = "public-02"
          #   kind   = "ec2" # OPCION EC2
          #   # create_nat_gateway = true
          #   # nat_parameters     = {
          #   #   connectivity_type                  = "private"
          #   #   private_ip                         = null
          #   #   secondary_allocation_ids           = null
          #   #   secondary_private_ip_address_count = null
          #   #   secondary_private_ip_addresses     = null
          #   # }
          # }
        }
        route_table = {
          "private" = {
            # create_route_table = true
            routes = {
              # "00" = {
              #   destination_cidr_block      = "16.0.0.0/16"
              #   destination_ipv6_cidr_block = null
              #   destination_prefix_list_id  = null

              #   ## target
              #   nat_gateway_id       = null
              #   gateway_id           = null
              #   network_interface    = null
              #   egress_only_gateway_id = null
              #   vpc_endpoint_id        = null

              #   vpc_peering_connection_id = module.vpc_peering_connection["example"].id
              #   transit_gateway_id        = null
              #   carrier_gateway_id        = null
              #   core_network_arn          = null
              #   local_gateway_id          = null
              # }
            }
            default_route = {
              nat_gateway = "natgw"
            }
          }
          "public" = {
            # create_route_table = true
            routes = {
            }
            default_route = {
              gateway = "igw"
            }
          }
        }
        network_acl = {
          "private" = {
            rules = {
              # "99" = {
              #   egress          = false
              #   protocol        = "-1"
              #   rule_action     = "allow"
              #   cidr_block      = "0.0.0.0/0"
              #   from_port       = null
              #   to_port         = null
              #   ipv6_cidr_block = null
              #   icmp_type       = null
              #   icmp_code       = null
              # }
            }
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

              # create_subnet                                  = true
              ## Configurations
              # enable_dns64                                   = false
              # enable_resource_name_dns_aaaa_record_on_launch = false
              # enable_resource_name_dns_a_record_on_launch    = false
              # private_dns_hostname_type_on_launch            = null
              # map_public_ip_on_launch                        = true
              # enable_lni_at_device_index                     = null

              # ## IPv6
              # ipv6_native                     = null
              # ipv6_cidr_block                 = null
              # assign_ipv6_address_on_creation = null

              # ## Customer owned IPs
              # map_customer_owned_ip_on_launch = null
              # customer_owned_ipv4_pool        = null
              # outpost_arn                     = null

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
    }
  }
}