module "wrapper_vpc" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    "test1" = {
      vpc_cidr = "10.15.0.0/16"
      internet_gateway = {
        "igw" = {}
      }
      nat_gateway = {
        "natgw" = {
          subnet = "public"
          kind   = "aws" # OPCION AWS
        }
      }
      route_table = {
        "default" = {
          # Modifica aws_default_route_table
        }
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
            gateway = "igw-01"
          }
        }
      }
      network_acl = {
        "default" = {
          # Modifica aws_default_network_acl
        }
        "custom" = {
          rules = {}
        }
      }
      subnets = {
        "private" = {
          "01" = {
            cidr_block  = "10.15.1.0/24"
            az          = "a"
            route_table = "private"
            network_acl = "custom"
          }
          "02" = {
            cidr_block  = "10.15.2.0/24"
            az          = "b"
            route_table = "private"
            network_acl = "custom"
          }
        }
        "public" = {
          "01" = {
            cidr_block  = "10.15.11.0/24"
            az          = "a"
            route_table = "public"
            network_acl = "custom"
          }
          "02" = {
            cidr_block  = "10.15.12.0/24"
            az          = "b"
            route_table = "public"
            network_acl = "custom"
          }
        }
      }
    }
    "test2" = {
      vpc_cidr = "10.16.0.0/16"
      internet_gateway = {
        "igw" = {}
      }
      nat_gateway = {
        "natgw" = {
          subnet = "public"
          kind   = "aws" # OPCION AWS
        }
      }
      route_table = {
        "default" = {
          # Modifica aws_default_route_table
        }
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
            gateway = "igw-01"
          }
        }
      }
      network_acl = {
        "default" = {
          # Modifica aws_default_network_acl
        }
        "custom" = {
          rules = {}
        }
      }
      subnets = {
        "private" = {
          "01" = {
            cidr_block  = "10.15.1.0/24"
            az          = "a"
            route_table = "private"
            network_acl = "custom"
          }
          "02" = {
            cidr_block  = "10.15.2.0/24"
            az          = "b"
            route_table = "private"
            network_acl = "custom"
          }
        }
        "public" = {
          "01" = {
            cidr_block  = "10.15.11.0/24"
            az          = "a"
            route_table = "public"
            network_acl = "custom"
          }
          "02" = {
            cidr_block  = "10.15.12.0/24"
            az          = "b"
            route_table = "public"
            network_acl = "custom"
          }
        }
      }
    }
  }
}