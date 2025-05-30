module "wrapper_base" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    vpc = {
      "stg" = {
        # VPC Parameters
        vpc_cidr           = "10.17.0.0/16" #Required
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
            subnet = "public-${data.aws_region.current.name}a"
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
            "${data.aws_region.current.name}a" = {
              cidr_block  = cidrsubnet("10.17.0.0/16", 4, 0)
              az          = "a"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.name}b" = {
              cidr_block  = cidrsubnet("10.17.0.0/16", 4, 1)
              az          = "b"
              route_table = "private"
              network_acl = "private"
            }
            "${data.aws_region.current.name}c" = {
              cidr_block  = cidrsubnet("10.17.0.0/16", 4, 2)
              az          = "c"
              route_table = "private"
              network_acl = "private"
            }
          }
          "public" = {
            "${data.aws_region.current.name}a" = {
              cidr_block  = cidrsubnet("10.17.0.0/16", 4, 3)
              az          = "a"
              route_table = "public"
              network_acl = "public"
            }
            "${data.aws_region.current.name}b" = {
              cidr_block  = cidrsubnet("10.17.0.0/16", 4, 4)
              az          = "b"
              route_table = "public"
              network_acl = "public"
            }
            "${data.aws_region.current.name}c" = {
              cidr_block  = cidrsubnet("10.17.0.0/16", 4, 5)
              az          = "c"
              route_table = "public"
              network_acl = "public"
            }
          }
        }
      }
    }
    tgw = {
      "tgw-01" = {
        ## If TGW is already created, disable creation to only create the VPC attachment from a separe account/vpc 
        create_tgw = false

        ## Use only to creating a VPC attachemnt to an already created TGW resource outside of RAM
        # share_tgw = false
        # amazon_side_asn = "64512" //value used to identify the TGW resource where the attachemnts will be created
        # ram_resource_share_arn = "arn:aws:ram:us-east-1:xxxxxxxx:resource-share/a42896eb-ae42-4556-be24-8427a44552f2" //RAM reference to send request invitation to gain acces to TGW resource

        vpc_attachments = {
          "stg" = {
            subnet_ids = ["private-us-east-1a", "private-us-east-1b", "private-us-east-1c"] // Only 1 Subnet per AZ
            tgw_routes = [
              {
                destination_cidr_block = "10.17.0.0/16"

              },
              {
                blackhole              = true
                destination_cidr_block = "0.0.0.0/0"
              }
          ] }
        }
        vpc_routes = {
          "stg" = {
            "private" = {
              destination_cidr_block = ["10.15.0.0/16", "10.16.0.0/16"]
            }
            "public" = {
              destination_cidr_block = ["10.15.0.0/16", "10.16.0.0/16"]
            }
          }
        }
      }
    }
  }
}