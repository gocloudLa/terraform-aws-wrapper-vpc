# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform VPC Networking Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-vpc/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-vpc.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-vpc.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-vpc/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for VPC simplifies the configuration of basic Networking services (VPC / Subnets / Route Tables / IGW / NatGW / NACL / VPC Endpoints / Flow Logs) using a structured map of VPCs and local AWS modules.

### ✨ Features

- 🖥️ [Custom EC2 NAT Gateway](#custom-ec2-nat-gateway) - Deploy cost-effective EC2-based NAT Gateway instead of managed NAT Gateway

- 🌐 [Per-VPC top-level attributes](#per-vpc-top-level-attributes) - VPC CIDR, IPAM, DNS, DHCP options and tags inside each `vpc_parameters.<key>`

- 🔌 [internet_gateway map](#internet_gateway-map) - Define one or more Internet Gateways per VPC

- 🛡️ [network_acl map](#network_acl-map) - Dedicated Network ACLs per VPC

- 📍 [subnets map](#subnets-map) - Nested map of subnet groups and AZs with full subnet options

- 🔀 [nat_gateway map](#nat_gateway-map) - AWS or EC2 NAT Gateways per VPC

- 🛤️ [route_table map](#route_table-map) - Route tables with default route and optional extra routes

- 📋 [flow_logs map](#flow_logs-map) - VPC Flow Logs to CloudWatch or S3

- 🔗 [endpoints map](#endpoints-map) - Gateway and Interface VPC endpoints



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-ec2-instance" target="_blank">terraform-aws-modules/ec2-instance/aws</a> | 6.3.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-security-group" target="_blank">terraform-aws-modules/security-group/aws</a> | 5.3.1 |



## 🚀 Quick Start
```hcl
module "wrapper_vpc" {
  source = "path/to/terraform-aws-wrapper-vpc"

  metadata = {
    key = {
      company = "myco"
      region  = "use1"
      env     = "prd"
    }
    environment = "Production"
    common_name = "myco-prd"  # optional; defaults to company-env
    common_tags = {}          # optional
  }

  vpc_parameters = {
    "main" = {
      vpc_cidr = "10.130.0.0/16"
      internet_gateway = {
        "00-igw" = {}
      }
      nat_gateway = {
        "natgw" = {
          subnet = "public-${data.aws_region.current.name}a"
          kind   = "aws"
        }
      }
      route_table = {
        "00-private" = {
          default_route = { network_interface = "natgw" }
        }
        "00-public" = {
          default_route = { gateway = "00-igw" }
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
        }
      }
      endpoints = {
        "00" = { service = "s3", service_type = "Gateway", route_table_ids = ["00-private", "00-public"], policy = null }
        "01" = { service = "dynamodb", service_type = "Gateway", route_table_ids = ["00-private", "00-public"], policy = null }
      }
    }
  }
}
```


## 🔧 Additional Features Usage

### Custom EC2 NAT Gateway
Configure a custom EC2 instance as NAT Gateway for private subnet internet access, providing a cost-effective alternative to AWS managed NAT Gateway service.


<details><summary>EC2 NAT Gateway Configuration</summary>

```hcl
vpc_parameters = {
  "main" = {
    vpc_cidr = "10.130.0.0/16"
    internet_gateway = { "00-igw" = {} }
    nat_gateway = {
      "natgw" = {
        subnet = "public-${data.aws_region.current.name}a"
        kind   = "ec2"
        nat_parameters = {
          ec2_nat_gateway_attach_eip = true
          connectivity_type          = "public"
        }
      }
    }
    route_table = {
      "00-private" = { default_route = { network_interface = "natgw" } }
      "00-public"  = { default_route = { gateway = "00-igw" } }
    }
    network_acl = {}
    subnets     = { ... }
  }
}
```


</details>


### Per-VPC top-level attributes
Top-level keys for each VPC entry. Omit optional keys to use defaults.


<details><summary>Per-VPC top-level example</summary>

```hcl
vpc_parameters = {
  "main" = {
    custom_common_name = "myco-prd-main"

    vpc_cidr                           = "10.130.0.0/16"
    use_ipam_pool                      = false
    ipv4_ipam_pool_id                  = null
    ipv4_netmask_length                = null
    enable_ipv6                        = false
    ipv6_cidr_block                    = null
    ipv6_ipam_pool_id                  = null
    ipv6_netmask_length                = null
    ipv6_cidr_block_network_border_group = null

    instance_tenancy                     = "default"
    enable_dns_hostnames                 = true
    enable_dns_support                   = true
    enable_network_address_usage_metrics = null

    enable_dhcp_options               = false
    dhcp_options_domain_name          = ""
    dhcp_options_domain_name_servers  = []
    dhcp_options_ntp_servers          = []
    dhcp_options_netbios_name_servers = []
    dhcp_options_netbios_node_type    = ""

    tags = { "extra" = "value" }
  }
}
```


</details>


### internet_gateway map
Map of IGW names to optional config. Each key becomes an IGW; values can override create flags and tags.


<details><summary>internet_gateway example</summary>

```hcl
internet_gateway = {
  "00-igw" = {
    create_internet_gateway = true
    create_egress_only_igw  = false
    tags                    = {}
  }
}
```


</details>


### network_acl map
Map of NACL names to rules and tags. Subnets reference these by name via `network_acl`.


<details><summary>network_acl example</summary>

```hcl
network_acl = {
  "private-nacl" = {
    create_network_acl = true
    rules              = {}
    tags               = {}
  }
}
```


</details>


### subnets map
Structure is `subnets.<group>.<az_key>`. Each subnet can set route_table, network_acl, and optional DNS/IPv6/outpost options.


<details><summary>subnets example</summary>

```hcl
subnets = {
  "private" = {
    "${data.aws_region.current.name}a" = {
      create_subnet  = true
      cidr_block     = cidrsubnet("10.130.0.0/16", 4, 0)
      az             = "a"
      route_table    = "00-private"
      network_acl    = "private-nacl"
      enable_dns64   = false
      enable_resource_name_dns_aaaa_record_on_launch = false
      enable_resource_name_dns_a_record_on_launch    = false
      private_dns_hostname_type_on_launch            = null
      map_public_ip_on_launch = false
      enable_lni_at_device_index = null
      outpost_arn                     = null
      map_customer_owned_ip_on_launch = null
      customer_owned_ipv4_pool        = null
      tags = {}
    }
  }
  "public" = {
    "${data.aws_region.current.name}a" = {
      create_subnet  = true
      cidr_block     = cidrsubnet("10.130.0.0/16", 4, 3)
      az             = "a"
      route_table    = "00-public"
      network_acl    = ""
      map_public_ip_on_launch = true
      tags = {}
    }
  }
}
```


</details>


### nat_gateway map
Map of NAT names to config. Use `kind = "aws"` or `"ec2"`. Subnet key must match `{group}-{region}{az}` (e.g. `public-us-east-1a`).


<details><summary>nat_gateway example</summary>

```hcl
nat_gateway = {
  "natgw" = {
    create_nat_gateway = true
    kind               = "aws"
    subnet             = "public-${data.aws_region.current.name}a"
    nat_parameters = {
      connectivity_type                  = "public"
      private_ip                         = null
      secondary_allocation_ids           = null
      secondary_private_ip_address_count = null
      secondary_private_ip_addresses     = null
      ec2_nat_gateway_attach_eip = false
    }
    tags = {}
  }
}
```


</details>


### route_table map
Map of route table names to config. `default_route` sets 0.0.0.0/0 via `gateway`, `network_interface`, or `nat_gateway` (by name). `routes` adds named routes.


<details><summary>route_table example</summary>

```hcl
route_table = {
  "00-private" = {
    create_route_table = true
    default_route = {
      nat_gateway            = "natgw"
      nat_gateway_id         = null
      gateway                = null
      gateway_id             = null
      network_interface     = null
      network_interface_id   = null
      vpc_endpoint_id        = null
      transit_gateway_id     = null
      vpc_peering_connection_id = null
      core_network_arn       = null
      carrier_gateway_id     = null
      local_gateway_id       = null
    }
    routes = {
      "to-onprem" = {
        destination_cidr_block      = "10.0.0.0/8"
        destination_ipv6_cidr_block = null
        transit_gateway_id          = "tgw-xxx"
      }
    }
  }
  "00-public" = {
    create_route_table = true
    default_route = { gateway = "00-igw" }
    routes = {}
  }
}
```


</details>


### flow_logs map
Map of flow log names to destination, IAM, and format options.


<details><summary>flow_logs example</summary>

```hcl
flow_logs = {
  "default" = {
    enable_flow_log                                 = true
    create_flow_log_cloudwatch_iam_role             = true
    create_flow_log_cloudwatch_log_group            = true
    vpc_flow_log_permissions_boundary               = null
    flow_log_traffic_type                           = "ALL"
    flow_log_destination_type                       = "cloud-watch-logs"
    flow_log_log_format                             = null
    flow_log_destination_arn                        = ""
    flow_log_cloudwatch_iam_role_arn                = ""
    flow_log_cloudwatch_log_group_name_prefix       = ""
    flow_log_cloudwatch_log_group_retention_in_days = 365
    flow_log_cloudwatch_log_group_kms_key_id        = null
    flow_log_max_aggregation_interval               = 600
    flow_log_hive_compatible_partitions             = false
    flow_log_per_hour_partition                     = false
    tags                                            = {}
  }
}
```


</details>


### endpoints map
Map of endpoint keys to service name, type (Gateway/Interface), route tables, and optional policy.


<details><summary>endpoints example</summary>

```hcl
endpoints = {
  "00" = {
    service             = "s3"
    service_name        = null
    service_type        = "Gateway"
    route_table_ids     = ["00-private", "00-public"]
    policy              = data.aws_iam_policy_document.s3_endpoint_policy.json
    private_dns_enabled = false
    security_group_ids  = []
    tags                = {}
  }
  "01" = {
    service         = "dynamodb"
    service_type    = "Gateway"
    route_table_ids = ["00-private", "00-public"]
    policy          = null
    tags            = {}
  }
}
```


</details>




## 📑 Inputs
| Name           | Description                                                                                                | Type       | Default   | Required   |
| -------------- | ---------------------------------------------------------------------------------------------------------- | ---------- | --------- | ---------- |
| Name           | Description                                                                                                | Type       | Default   | Required   |
| ------         | -------------                                                                                              | ------     | --------- | ---------- |
| metadata       | Metadata for naming and tagging (key.company, key.env, key.region, environment, common_name, common_tags). | `object`   | n/a       | yes        |
| vpc_parameters | Map of VPC configurations. Each key is a VPC id; value supports the attributes below.                      | `map(any)` | `{}`      | no         |
| vpc_defaults   | Default values applied across vpc_parameters (optional).                                                   | `any`      | `{}`      | no         |







## ⚠️ Important Notes
- Each key under `vpc_parameters` is a VPC identifier. Subnet keys are built as `{vpc_key}-{subnet_group}-{az_name}` (e.g. `main-public-us-east-1a`).
- NAT gateway `subnet` must reference the subnet group and AZ (e.g. `public-us-east-1a`) so the module can resolve `module.subnet["{vpc_key}-{subnet}"]`.
- Route table `default_route` can use `gateway` (IGW name), `network_interface` (NAT name), or `nat_gateway` (NAT name) to set the default 0.0.0.0/0 route.
- See `examples/00-simple-vpc` and `examples/01-complete-vpc` for full configurations.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 