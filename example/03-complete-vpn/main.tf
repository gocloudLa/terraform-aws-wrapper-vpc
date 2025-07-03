module "wrapper_vpc" {
  source = "../../"

  metadata = local.metadata

  vpc_parameters = {
    "test1" = {
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
      tags = local.custom_tags
    }
  }

  vpn_parameters = {
    "vpn-01" = {
      # create_vpn = true

      ## se pueden alternar entre los mismos de ser necesario
      vpc_name = "test1" //vpc-name-key
      # tgw = "tgw-01"
      # vpc_id = null
      # tgw_id = null

      ## si los recursos ya se encuentran creados se puede compartir su ID, sino se puede dejar null y completar el resto de la informacion en caso de querer una configuracio custom, si el objeto es nulo se configura por defecto
      virtual_private_gateway = {
        # amazon_side_asn = 64512
        # availability_zone = null

        # virtual_private_gateway_id = null
      }
      customer_gateway = {
        ip_address = "190.210.45.46" // Required, Public IP of client VPN 
        # device_name = null
        # bgp_asn = 65000
        # bgp_asn_extended = null
        # certificate_arn = null

        # customer_gateway_id = null
      }

      ## Configuraciones para los tuneles recursos, si no se define se usa el valor nulo
      vpn_connection = {
        remote_ipv4_network_cidr = "10.22.0.0/16" //cidr block que se comparte de nuestra vpc

        ## si se usa un ruteo estatico para maquinas especificas usar
        # static_routes_only = true
        # static_routes_destinations = ["10.1.8.30/32","10.1.7.140/32" ]
        # route_table_names = ["gcl-lab-00-private", "gcl-lab-00-public"]

        tunnel1_preshared_key                = "123456" # local.secrets.vpn_preshared_key //if the preshared key is stored in a parameter or secret
        tunnel1_ike_versions                 = ["ikev2"]
        tunnel1_startup_action               = "start"
        tunnel1_dpd_timeout_action           = "none"
        tunnel1_phase1_dh_group_numbers      = ["14"]
        tunnel1_phase1_encryption_algorithms = ["AES128"]
        tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
        tunnel1_phase2_dh_group_numbers      = ["14"]
        tunnel1_phase2_encryption_algorithms = ["AES256"]
        tunnel1_phase2_integrity_algorithms  = ["SHA2-256"]
        tunnel1_cloudwatch_log_enabled       = true

        tunnel2_preshared_key                = "123456" # local.secrets.vpn_preshared_key
        tunnel2_ike_versions                 = ["ikev2"]
        tunnel2_startup_action               = "start"
        tunnel2_dpd_timeout_action           = "none"
        tunnel2_phase1_dh_group_numbers      = ["14"]
        tunnel2_phase1_encryption_algorithms = ["AES128"]
        tunnel2_phase1_integrity_algorithms  = ["SHA2-256"]
        tunnel2_phase2_dh_group_numbers      = ["14"]
        tunnel2_phase2_encryption_algorithms = ["AES256"]
        tunnel2_phase2_integrity_algorithms  = ["SHA2-256"]
        tunnel2_cloudwatch_log_enabled       = true
      }

      ## Propagacion y configuracion de rutas si no se quiere usar ruteo estatico
      vpc_routes = {
        "private" = {
          destination_cidr = ["172.0.10.1/24", "172.0.10.2/24"]
        }
        "public" = {
          destination_cidr = ["172.0.10.1/24", "172.0.10.2/24"]
        }
      }
      tags = local.custom_tags
    }
  }
}