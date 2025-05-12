module "wrapper_vpc" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    vpc = {
      "dev" = {
        name_prefix = true
        vpc_cidr    = "10.15.0.0/16"
        internet_gateway = {
          "00-igw" = {}
        }
        nat_gateway = {
          "00-nat" = {
            subnet = "public-01"
            kind   = "ec2" # OPCION AWS
          }
        }
        route_table = {
          "00-private" = {
            routes = {
            }
            default_route = {
              network_interface = "00-nat"
            }
          }
          "00-public" = {
            routes = {
            }
            default_route = {
              gateway = "00-igw"
            }
          }
          "00-databases" = {
            routes = {
            }
            default_route = {
              network_interface = "00-nat"
            }
          }
        }
        network_acl = {
          "00" = {
            rules = {}
          }
        }
        subnets = {
          "private" = {
            "01" = {
              cidr_block  = "10.15.1.0/24"
              az          = "a"
              route_table = "00-private"
              network_acl = "00"
            }
            "02" = {
              cidr_block  = "10.15.2.0/24"
              az          = "b"
              route_table = "00-private"
              network_acl = "00"
            }
            "03" = {
              cidr_block  = "10.15.3.0/24"
              az          = "c"
              route_table = "00-private"
              network_acl = "00"
            }
          }
          "public" = {
            "01" = {
              cidr_block  = "10.15.101.0/24"
              az          = "a"
              route_table = "00-public"
              network_acl = "00"
            }
            "02" = {
              cidr_block  = "10.15.102.0/24"
              az          = "b"
              route_table = "00-public"
              network_acl = "00"
            }
            "03" = {
              cidr_block  = "10.15.103.0/24"
              az          = "c"
              route_table = "00-public"
              network_acl = "00"
            }
          }
          "db" = {
            "01" = {
              cidr_block  = "10.15.201.0/24"
              az          = "a"
              route_table = "00-databases"
              network_acl = "00"
            }
            "02" = {
              cidr_block  = "10.15.202.0/24"
              az          = "b"
              route_table = "00-databases"
              network_acl = "00"
            }
            "03" = {
              cidr_block  = "10.15.203.0/24"
              az          = "c"
              route_table = "00-databases"
              network_acl = "00"
            }
          }
          "elasticache" = {
            "01" = {
              cidr_block  = "10.15.211.0/24"
              az          = "a"
              route_table = "00-databases"
              network_acl = "00"
            }
            "02" = {
              cidr_block  = "10.15.212.0/24"
              az          = "b"
              route_table = "00-databases"
              network_acl = "00"
            }
            "03" = {
              cidr_block  = "10.15.213.0/24"
              az          = "c"
              route_table = "00-databases"
              network_acl = "00"
            }
          }
        }
        endpoints = {
          "00" = {
            service         = "s3"
            service_type    = "Gateway"
            route_table_ids = ["00-private", "00-public", "00-databases"]
            policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
          },
          "01" = {
            service         = "dynamodb"
            service_type    = "Gateway"
            route_table_ids = ["00-private", "00-public", "00-databases"]
            policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
          }
        }
      }
      "prod" = {
        vpc_cidr = "10.16.0.0/16"
        internet_gateway = {
          "00-igw" = {}
        }
        nat_gateway = {
          "00-nat" = {
            subnet = "public-02"
            kind   = "aws" # OPCION AWS
          }
        }
        route_table = {
          "00-private" = {
            routes = {
            }
            default_route = {
              nat_gateway = "00-nat"
            }
          }
          "00-public" = {
            routes = {
            }
            default_route = {
              gateway = "00-igw"
            }
          }
          "00-databases" = {
            routes = {
            }
            default_route = {
              nat_gateway = "00-nat"
            }
          }
        }
        network_acl = {
          "00" = {
            rules = {}
          }
        }
        subnets = {
          "private" = {
            "01" = {
              cidr_block  = "10.16.1.0/24"
              az          = "a"
              route_table = "00-private"
              network_acl = "00"
            }
            "02" = {
              cidr_block  = "10.16.2.0/24"
              az          = "b"
              route_table = "00-private"
              network_acl = "00"
            }
            "03" = {
              cidr_block  = "10.16.3.0/24"
              az          = "c"
              route_table = "00-private"
              network_acl = "00"
            }
          }
          "public" = {
            "01" = {
              cidr_block  = "10.16.101.0/24"
              az          = "a"
              route_table = "00-public"
              network_acl = "00"
            }
            "02" = {
              cidr_block  = "10.16.102.0/24"
              az          = "b"
              route_table = "00-public"
              network_acl = "00"
            }
            "03" = {
              cidr_block  = "10.16.103.0/24"
              az          = "c"
              route_table = "00-public"
              network_acl = "00"
            }
          }
          "db" = {
            "01" = {
              cidr_block  = "10.16.201.0/24"
              az          = "a"
              route_table = "00-databases"
              network_acl = "00"
            }
            "02" = {
              cidr_block  = "10.16.202.0/24"
              az          = "b"
              route_table = "00-databases"
              network_acl = "00"
            }
            "03" = {
              cidr_block  = "10.16.203.0/24"
              az          = "c"
              route_table = "00-databases"
              network_acl = "00"
            }
          }
          "elasticache" = {
            "01" = {
              cidr_block  = "10.16.211.0/24"
              az          = "a"
              route_table = "00-databases"
              network_acl = "00"
            }
            "02" = {
              cidr_block  = "10.16.212.0/24"
              az          = "b"
              route_table = "00-databases"
              network_acl = "00"
            }
            "03" = {
              cidr_block  = "10.16.213.0/24"
              az          = "c"
              route_table = "00-databases"
              network_acl = "00"
            }
          }
        }
        endpoints = {
          "00" = {
            service         = "s3"
            service_type    = "Gateway"
            route_table_ids = ["00-private", "00-public", "00-databases"]
            policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
          },
          "01" = {
            service         = "dynamodb"
            service_type    = "Gateway"
            route_table_ids = ["00-private", "00-public", "00-databases"]
            policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
          }
        }
      }
    }
    tgw = {}
    vpn = {}
  }
}