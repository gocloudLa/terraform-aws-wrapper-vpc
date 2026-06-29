# Upgrade from v1.0 to v2.0

If you have a question regarding this upgrade process, please check the code in the `examples/complete` and `examples/simple` directories.

If you found a bug, please open an issue in this repository.

## List of Changes

1. **Module structure** – All VPC resources were moved into local wrappers and modules (under `modules/aws/`) instead of using a single public Terraform VPC module. The root module now uses `for_each` over `vpc_parameters` and creates discrete resources per VPC, subnet, route table, NAT gateway, and internet gateway.

2. **Input interface** – The flat input (e.g. `private_subnets`, `public_subnets`, `enable_nat_gateway`) was replaced by a structured **`vpc_parameters`** map. Each key is a VPC id; each value defines `vpc_cidr`, `internet_gateway`, `nat_gateway`, `route_table`, `network_acl`, `subnets`, `endpoints`, and optionally `flow_logs`. See `README.yml` or `examples/00-simple-vpc` for the new structure.

3. **New resources**
   - Explicit association to the default VPC Network ACL when not using a custom NACL:  
     `module.wrapper_vpc.module.subnet["<vpc_key>-<subnet_group>-<az>"].aws_network_acl_association.this`  
     (when a custom NACL is attached via `network_acl` in subnet config).
   - Default NACL and default route table are managed at the wrapper level:  
     `module.wrapper_vpc.aws_default_network_acl.this["<vpc_key>"]`,  
     `module.wrapper_vpc.aws_default_route_table.this["<vpc_key>"]`.

4. **NAT gateway** – NAT is configured per VPC via `vpc_parameters.<vpc_key>.nat_gateway` with optional `kind = "aws"` (managed NAT) or `kind = "ec2"` (EC2-based NAT). Route tables reference the NAT by name in `default_route.network_interface` or `default_route.nat_gateway`.

5. **VPC endpoints** – Endpoints are defined per VPC under `vpc_parameters.<vpc_key>.endpoints` (map of endpoint keys to service, service_type, route_table_ids, policy, etc.).

## Example upgrade procedure
### Legacy `vpc_parameter` block ( v1.0 ) `main..tf`
```hcl
vpc_parameters = {
  vpc_cidr = local.vpc_cidr
  private_subnets = [
    cidrsubnet(local.vpc_cidr, 4, 0),
    cidrsubnet(local.vpc_cidr, 4, 1),
    cidrsubnet(local.vpc_cidr, 4, 2)
  ]
  public_subnets = [
    cidrsubnet(local.vpc_cidr, 4, 3),
    cidrsubnet(local.vpc_cidr, 4, 4),
    cidrsubnet(local.vpc_cidr, 4, 5)
  ]
  database_subnets = [
    cidrsubnet(local.vpc_cidr, 4, 6),
    cidrsubnet(local.vpc_cidr, 4, 7),
    cidrsubnet(local.vpc_cidr, 4, 8)
  ]
  elasticache_subnets = [
    cidrsubnet(local.vpc_cidr, 4, 9),
    cidrsubnet(local.vpc_cidr, 4, 10),
    cidrsubnet(local.vpc_cidr, 4, 11)
  ]
  elasticache_dedicated_network_acl = false

  default_security_group_ingress = [
    {
      "cidr_blocks" = "0.0.0.0/0",
      "from_port"   = 0,
      "to_port"     = 0,
      "protocol"    = "-1"
    }
  ]
  default_security_group_egress = [
    {
      "cidr_blocks" = "0.0.0.0/0",
      "from_port"   = 0,
      "to_port"     = 0,
      "protocol"    = "-1"
    }
  ]
  enable_ec2_nat_gateway     = true
  ec2_nat_gateway_attach_eip = true
  enable_nat_gateway         = false
}
```

### New `vpc_parameter` block ( v2.0 ) `main.tf`
```hcl
vpc_parameters = {
  "vpc-01" = {
    vpc_cidr = local.vpc_cidr
    internet_gateway = {
      "igw" = {}
    }
    nat_gateway = {
      "natgw" = {
        subnet = "public-a"
        kind   = "ec2"
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
          gateway = "igw"
        }
      }
    }
    network_acl = {
    }
    subnets = {
      "private" = {
        "a" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 0)
          az          = "a"
          route_table = "private"
          network_acl = ""
        }
        "b" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 1)
          az          = "b"
          route_table = "private"
          network_acl = ""
        }
        "c" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 2)
          az          = "c"
          route_table = "private"
          network_acl = ""
        }
      }
      "public" = {
        "a" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 3)
          az          = "a"
          route_table = "public"
          network_acl = ""
          map_public_ip_on_launch = true
        }
        "b" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 4)
          az          = "b"
          route_table = "public"
          network_acl = ""
          map_public_ip_on_launch = true
        }
        "c" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 5)
          az          = "c"
          route_table = "public"
          network_acl = ""
          map_public_ip_on_launch = true
        }
      }
      "db" = {
        "a" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 6)
          az          = "a"
          route_table = "private"
          network_acl = ""
        }
        "b" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 7)
          az          = "b"
          route_table = "private"
          network_acl = ""
        }
        "c" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 8)
          az          = "c"
          route_table = "private"
          network_acl = ""
        }
      }
      "elasticache" = {
        "a" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 9)
          az          = "a"
          route_table = "private"
          network_acl = ""
        }
        "b" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 10)
          az          = "b"
          route_table = "private"
          network_acl = ""
        }
        "c" = {
          cidr_block  = cidrsubnet(local.vpc_cidr, 4, 11)
          az          = "c"
          route_table = "private"
          network_acl = ""
        }
      }
    }
    endpoints = {
      "s3" = {
        service         = "s3"
        service_type    = "Gateway"
        route_table_ids = ["private", "public"]
        policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
      },
      "dynamodb" = {
        service         = "dynamodb"
        service_type    = "Gateway"
        route_table_ids = ["private", "public"]
        policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      }
    }
  }
}
```

### Additional required resources ( v2.0 ) `datasources.tf`
```hcl
data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "s3_endpoint_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
```

### Required moved resources ( v2.0 ) `moved.tf`
```hcl
# VPC
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_vpc.this[0]
  to   = module.base.module.wrapper_vpc.module.vpc["vpc-01"].aws_vpc.this[0]
}

# Subnets (adjust keys and AZs to your setup)
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.database[0]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-db-a"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.database[1]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-db-b"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.database[2]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-db-c"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.elasticache[0]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-elasticache-a"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.elasticache[1]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-elasticache-b"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.elasticache[2]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-elasticache-c"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.private[0]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-private-a"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.private[1]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-private-b"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.private[2]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-private-c"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.public[0]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-public-a"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.public[1]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-public-b"].aws_subnet.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_subnet.public[2]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-public-c"].aws_subnet.this[0]
}

# Route tables
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table.private[0]
  to   = module.base.module.wrapper_vpc.module.route_table["vpc-01-private"].aws_route_table.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table.public[0]
  to   = module.base.module.wrapper_vpc.module.route_table["vpc-01-public"].aws_route_table.this[0]
}

# Internet gateway
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_internet_gateway.this[0]
  to   = module.base.module.wrapper_vpc.module.internet_gateway["vpc-01-igw"].aws_internet_gateway.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route.public_internet_gateway[0]
  to   = module.base.module.wrapper_vpc.module.route_association["vpc-01-public"].aws_route.default[0]
}

# Route table associations
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.database[0]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-db-a"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.database[1]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-db-b"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.database[2]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-db-c"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[0]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-elasticache-a"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[1]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-elasticache-b"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[2]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-elasticache-c"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.private[0]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-private-a"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.private[1]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-private-b"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.private[2]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-private-c"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.public[0]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-public-a"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.public[1]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-public-b"].aws_route_table_association.this
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_route_table_association.public[2]
  to   = module.base.module.wrapper_vpc.module.subnet["vpc-01-public-c"].aws_route_table_association.this
}

# Default VPC resources
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_default_network_acl.this[0]
  to   = module.base.module.wrapper_vpc.aws_default_network_acl.this["vpc-01"]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_default_route_table.default[0]
  to   = module.base.module.wrapper_vpc.aws_default_route_table.this["vpc-01"]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc.aws_default_security_group.this[0]
  to   = module.base.module.wrapper_vpc.module.vpc["vpc-01"].aws_default_security_group.default[0]
}

# VPC endpoints
moved {
  from = module.base.module.wrapper_vpc.module.vpc-endpoint.aws_vpc_endpoint.this["s3"]
  to   = module.base.module.wrapper_vpc.module.vpc_endpoint["vpc-01"].aws_vpc_endpoint.this["s3"]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc-endpoint.aws_vpc_endpoint.this["dynamodb"]
  to   = module.base.module.wrapper_vpc.module.vpc_endpoint["vpc-01"].aws_vpc_endpoint.this["dynamodb"]
}

# EC2 NAT gateway (if used)
moved {
  from = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_eip.this[0]
  to   = module.base.module.wrapper_vpc.module.nat_gateway["vpc-01-natgw"].module.ec2_nat_gateway[0].aws_eip.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_route.this[0]
  to   = module.base.module.wrapper_vpc.module.route_association["vpc-01-private"].aws_route.default[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_instance_profile.this[0]
  to   = module.base.module.wrapper_vpc.module.nat_gateway["vpc-01-natgw"].module.ec2_nat_gateway[0].module.ec2_instance[0].aws_iam_instance_profile.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role.this[0]
  to   = module.base.module.wrapper_vpc.module.nat_gateway["vpc-01-natgw"].module.ec2_nat_gateway[0].module.ec2_instance[0].aws_iam_role.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]
  to   = module.base.module.wrapper_vpc.module.nat_gateway["vpc-01-natgw"].module.ec2_nat_gateway[0].module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.ignore_ami[0]
  to   = module.base.module.wrapper_vpc.module.nat_gateway["vpc-01-natgw"].module.ec2_nat_gateway[0].module.ec2_instance[0].aws_instance.ignore_ami[0]
}

moved {
  from = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group.this[0]
  to   = module.base.module.wrapper_vpc.module.nat_gateway["vpc-01-natgw"].module.ec2_nat_gateway[0].module.security_group[0].aws_security_group.this[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.egress_rules[0]
  to   = module.base.module.wrapper_vpc.module.nat_gateway["vpc-01-natgw"].module.ec2_nat_gateway[0].module.security_group[0].aws_security_group_rule.egress_rules[0]
}
moved {
  from = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.ingress_rules[0]
  to   = module.base.module.wrapper_vpc.module.nat_gateway["vpc-01-natgw"].module.ec2_nat_gateway[0].module.security_group[0].aws_security_group_rule.ingress_with_cidr_blocks[0]
}

# # AWS NAT gateway (if used)
# moved {
#   from = module.base.module.wrapper_vpc.module.vpc.aws_route.private_nat_gateway[0]
#   to   = module.base.module.wrapper_vpc.module.route_association["vpc-01-private"].aws_route.default[0]
# }
# moved {
#   from = module.base.module.wrapper_vpc.module.vpc.aws_eip.nat[0]
#   to   = module.base.module.wrapper_vpc.module.nat_gateway["vpc-01-natgw"].aws_eip.this[0]
# }
# moved {
#   from = module.base.module.wrapper_vpc.module.vpc.aws_nat_gateway.this[0]
#   to   = module.base.module.wrapper_vpc.module.nat_gateway["vpc-01-natgw"].aws_nat_gateway.this[0]
# }
```
