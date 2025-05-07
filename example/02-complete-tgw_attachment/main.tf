module "wrapper_base" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    vpc = {
      "test3" = {
        # VPC Parameters
        vpc_cidr = "10.17.0.0/16" #Required
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
              cidr_block  = "10.17.1.0/24"
              az          = "a"
              route_table = "private"
              network_acl = "private"
            }
            "02" = {
              cidr_block  = "10.17.2.0/24"
              az          = "b"
              route_table = "private"
              network_acl = "private"
            }
          }
          "public" = {
            "01" = {
              cidr_block  = "10.17.11.0/24"
              az          = "a"
              route_table = "public"
              network_acl = "public"
            }
            "02" = {
              cidr_block  = "10.17.12.0/24"
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
        ## If TGW is already created, disable creation to only create the VPC attachment from a separe account/vpc 
        create_tgw = false

        ## Use only to creating a VPC attachemnt to an already created TGW resource outside of RAM
        # share_tgw = false
        # amazon_side_asn = "64512" //value used to identify the TGW resource where the attachemnts will be created
        # ram_resource_share_arn = "arn:aws:ram:us-east-1:xxxxxxxx:resource-share/a42896eb-ae42-4556-be24-8427a44552f2" //RAM reference to send request invitation to gain acces to TGW resource

        vpc_attachments = {
          "test3" = {
            subnet_ids = ["private-01", "private-02"] // Only 1 Subnet per AZ

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
          "test3" = {
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