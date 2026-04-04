# Upgrade from v1.0 to v2.0

If you have a question regarding this upgrade process, please check the code in the `examples/00-simple-vpc` and `examples/01-complete-vpc` directories.

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

## List of Backward Incompatible Changes

### Moved resources

When the module is used as `module "wrapper_vpc" { source = "..." }`, resource addresses changed as follows. Replace `<vpc_key>`, subnet keys, route table names, and NAT/IGW names with your actual identifiers (e.g. `test`, `test-public-us-east-1a`, `test-00-private`, `test-natgw`, `test-00-igw`).

#### VPC

| From (v1) | To (v2) |
|-----------|---------|
| `module.wrapper_vpc.module.vpc.aws_vpc.this[key]` | `module.wrapper_vpc.module.vpc["<vpc_key>"].aws_vpc.this` |

#### Subnets

| From (v1) | To (v2) |
|-----------|---------|
| `module.wrapper_vpc.module.vpc.aws_subnet.database[key]` | `module.wrapper_vpc.module.subnet["<vpc_key>-db-<az>"].aws_subnet.this[0]` |
| `module.wrapper_vpc.module.vpc.aws_subnet.elasticache[key]` | `module.wrapper_vpc.module.subnet["<vpc_key>-elasticache-<az>"].aws_subnet.this[0]` |
| `module.wrapper_vpc.module.vpc.aws_subnet.private[key]` | `module.wrapper_vpc.module.subnet["<vpc_key>-private-<az>"].aws_subnet.this[0]` |
| `module.wrapper_vpc.module.vpc.aws_subnet.public[key]` | `module.wrapper_vpc.module.subnet["<vpc_key>-public-<az>"].aws_subnet.this[0]` |

Subnet keys in v1 are `<vpc_key>-<subnet_group>-<az_name>` (e.g. `test-private-us-east-1a`, `test-public-us-east-1b`).

#### Route tables

| From (v1) | To (v2) |
|-----------|---------|
| `module.wrapper_vpc.module.vpc.aws_route_table.private[0]` | `module.wrapper_vpc.module.route_table["<vpc_key>-00-private"].aws_route_table.this[0]` |
| `module.wrapper_vpc.module.vpc.aws_route_table.public[0]` | `module.wrapper_vpc.module.route_table["<vpc_key>-00-public"].aws_route_table.this[0]` |

#### Internet gateway

| From (v1) | To (v2) |
|-----------|---------|
| `module.wrapper_vpc.module.vpc.aws_internet_gateway.this[0]` | `module.wrapper_vpc.module.internet_gateway["<vpc_key>-00-igw"].aws_internet_gateway.this[0]` |
| `module.wrapper_vpc.module.vpc.aws_route.public_internet_gateway[0]` | `module.wrapper_vpc.module.route_association["<vpc_key>-00-public"].aws_route.default[0]` |

#### AWS NAT gateway

| From (v1) | To (v2) |
|-----------|---------|
| `module.wrapper_vpc.module.vpc.aws_route.private_nat_gateway[0]` | `module.wrapper_vpc.module.route_association["<vpc_key>-00-private"].aws_route.default[0]` |
| `module.wrapper_vpc.module.vpc.aws_eip.nat[0]` | `module.wrapper_vpc.module.nat_gateway["<vpc_key>-natgw"].aws_eip.this[0]` |
| `module.wrapper_vpc.module.vpc.aws_nat_gateway.this[0]` | `module.wrapper_vpc.module.nat_gateway["<vpc_key>-natgw"].aws_nat_gateway.this[0]` |

#### Route table association

| From (v1) | To (v2) |
|-----------|---------|
| `module.wrapper_vpc.module.vpc.aws_route_table_association.database[key]` | `module.wrapper_vpc.module.subnet["<vpc_key>-db-<az>"].aws_route_table_association.this` |
| `module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[key]` | `module.wrapper_vpc.module.subnet["<vpc_key>-elasticache-<az>"].aws_route_table_association.this` |
| `module.wrapper_vpc.module.vpc.aws_route_table_association.private[key]` | `module.wrapper_vpc.module.subnet["<vpc_key>-private-<az>"].aws_route_table_association.this` |
| `module.wrapper_vpc.module.vpc.aws_route_table_association.public[key]` | `module.wrapper_vpc.module.subnet["<vpc_key>-public-<az>"].aws_route_table_association.this` |

#### Default VPC resources

| From (v1) | To (v2) |
|-----------|---------|
| `module.wrapper_vpc.module.vpc.aws_default_network_acl.this[0]` | `module.wrapper_vpc.aws_default_network_acl.this["<vpc_key>"]` |
| `module.wrapper_vpc.module.vpc.aws_default_route_table.default[0]` | `module.wrapper_vpc.aws_default_route_table.this["<vpc_key>"]` |
| `module.wrapper_vpc.module.vpc.aws_default_security_group.this[0]` | `module.wrapper_vpc.module.vpc["<vpc_key>"].aws_default_security_group.default` |

#### VPC endpoints

| From (v1) | To (v2) |
|-----------|---------|
| `module.wrapper_vpc.module.vpc_endpoint.aws_vpc_endpoint.this["s3"]` | `module.wrapper_vpc.module.vpc_endpoint["<vpc_key>"].aws_vpc_endpoint.this["00"]` (endpoint key from your `endpoints` map) |
| `module.wrapper_vpc.module.vpc_endpoint.aws_vpc_endpoint.this["dynamodb"]` | `module.wrapper_vpc.module.vpc_endpoint["<vpc_key>"].aws_vpc_endpoint.this["01"]` |

#### EC2 NAT gateway

| From (v1) | To (v2) |
|-----------|---------|
| `module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_eip.this[0]` | `module.wrapper_vpc.module.nat_gateway["<vpc_key>-natgw"].module.vpc-ec2-nat-gateway[0].aws_eip.this[0]` |
| `module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_route.this[0]` | `module.wrapper_vpc.module.route_association["<vpc_key>-00-private"].aws_route.default[0]` |
| `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_instance_profile.this[0]` | `module.wrapper_vpc.module.nat_gateway["<vpc_key>-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_instance_profile.this[0]` |
| `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role.this[0]` | `module.wrapper_vpc.module.nat_gateway["<vpc_key>-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role.this[0]` |
| `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]` | `module.wrapper_vpc.module.nat_gateway["<vpc_key>-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]` |
| `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.ignore_ami[0]` | `module.wrapper_vpc.module.nat_gateway["<vpc_key>-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_instance.ignore_ami[0]` |
| `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group.this[0]` | `module.wrapper_vpc.module.nat_gateway["<vpc_key>-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group.this[0]` |
| `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.egress_rules[0]` | `module.wrapper_vpc.module.nat_gateway["<vpc_key>-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.egress_rules[0]` |
| `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.ingress_rules[0]` | `module.wrapper_vpc.module.nat_gateway["<vpc_key>-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.ingress_rules[0]` |

---

## Example upgrade procedure: add a `moved` block

Use the following as a template. Replace `wrapper_vpc` with your module name, `test` with your VPC key, and adjust AZs and resource names to match your configuration.

```hcl
# VPC
moved {
  from = module.wrapper_vpc.module.vpc.aws_vpc.this[0]
  to   = module.wrapper_vpc.module.vpc["test"].aws_vpc.this
}

# Subnets (adjust keys and AZs to your setup)
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.database[0]
  to   = module.wrapper_vpc.module.subnet["test-db-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.database[1]
  to   = module.wrapper_vpc.module.subnet["test-db-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.database[2]
  to   = module.wrapper_vpc.module.subnet["test-db-us-east-1c"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.elasticache[0]
  to   = module.wrapper_vpc.module.subnet["test-elasticache-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.elasticache[1]
  to   = module.wrapper_vpc.module.subnet["test-elasticache-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.elasticache[2]
  to   = module.wrapper_vpc.module.subnet["test-elasticache-us-east-1c"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.private[0]
  to   = module.wrapper_vpc.module.subnet["test-private-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.private[1]
  to   = module.wrapper_vpc.module.subnet["test-private-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.private[2]
  to   = module.wrapper_vpc.module.subnet["test-private-us-east-1c"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.public[0]
  to   = module.wrapper_vpc.module.subnet["test-public-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.public[1]
  to   = module.wrapper_vpc.module.subnet["test-public-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.public[2]
  to   = module.wrapper_vpc.module.subnet["test-public-us-east-1c"].aws_subnet.this[0]
}

# Route tables
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table.private[0]
  to   = module.wrapper_vpc.module.route_table["test-00-private"].aws_route_table.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table.public[0]
  to   = module.wrapper_vpc.module.route_table["test-00-public"].aws_route_table.this[0]
}

# Internet gateway
moved {
  from = module.wrapper_vpc.module.vpc.aws_internet_gateway.this[0]
  to   = module.wrapper_vpc.module.internet_gateway["test-00-igw"].aws_internet_gateway.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route.public_internet_gateway[0]
  to   = module.wrapper_vpc.module.route_association["test-00-public"].aws_route.default[0]
}

# AWS NAT gateway (if used)
moved {
  from = module.wrapper_vpc.module.vpc.aws_route.private_nat_gateway[0]
  to   = module.wrapper_vpc.module.route_association["test-00-private"].aws_route.default[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_eip.nat[0]
  to   = module.wrapper_vpc.module.nat_gateway["test-natgw"].aws_eip.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_nat_gateway.this[0]
  to   = module.wrapper_vpc.module.nat_gateway["test-natgw"].aws_nat_gateway.this[0]
}

# Route table associations
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.database[0]
  to   = module.wrapper_vpc.module.subnet["test-db-us-east-1a"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.database[1]
  to   = module.wrapper_vpc.module.subnet["test-db-us-east-1b"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.database[2]
  to   = module.wrapper_vpc.module.subnet["test-db-us-east-1c"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[0]
  to   = module.wrapper_vpc.module.subnet["test-elasticache-us-east-1a"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[1]
  to   = module.wrapper_vpc.module.subnet["test-elasticache-us-east-1b"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[2]
  to   = module.wrapper_vpc.module.subnet["test-elasticache-us-east-1c"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.private[0]
  to   = module.wrapper_vpc.module.subnet["test-private-us-east-1a"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.private[1]
  to   = module.wrapper_vpc.module.subnet["test-private-us-east-1b"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.private[2]
  to   = module.wrapper_vpc.module.subnet["test-private-us-east-1c"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.public[0]
  to   = module.wrapper_vpc.module.subnet["test-public-us-east-1a"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.public[1]
  to   = module.wrapper_vpc.module.subnet["test-public-us-east-1b"].aws_route_table_association.this
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.public[2]
  to   = module.wrapper_vpc.module.subnet["test-public-us-east-1c"].aws_route_table_association.this
}

# Default VPC resources
moved {
  from = module.wrapper_vpc.module.vpc.aws_default_network_acl.this[0]
  to   = module.wrapper_vpc.aws_default_network_acl.this["test"]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_default_route_table.default[0]
  to   = module.wrapper_vpc.aws_default_route_table.this["test"]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_default_security_group.this[0]
  to   = module.wrapper_vpc.module.vpc["test"].aws_default_security_group.default
}

# VPC endpoints
moved {
  from = module.wrapper_vpc.module.vpc_endpoint.aws_vpc_endpoint.this["s3"]
  to   = module.wrapper_vpc.module.vpc_endpoint["test"].aws_vpc_endpoint.this["00"]
}
moved {
  from = module.wrapper_vpc.module.vpc_endpoint.aws_vpc_endpoint.this["dynamodb"]
  to   = module.wrapper_vpc.module.vpc_endpoint["test"].aws_vpc_endpoint.this["01"]
}

# EC2 NAT gateway (if used)
moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_eip.this[0]
  to   = module.wrapper_vpc.module.nat_gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].aws_eip.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_route.this[0]
  to   = module.wrapper_vpc.module.route_association["test-00-private"].aws_route.default[0]
}
moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_instance_profile.this[0]
  to   = module.wrapper_vpc.module.nat_gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_instance_profile.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role.this[0]
  to   = module.wrapper_vpc.module.nat_gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]
  to   = module.wrapper_vpc.module.nat_gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]
}
moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.ignore_ami[0]
  to   = module.wrapper_vpc.module.nat_gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_instance.ignore_ami[0]
}
moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group.this[0]
  to   = module.wrapper_vpc.module.nat_gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.egress_rules[0]
  to   = module.wrapper_vpc.module.nat_gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.egress_rules[0]
}
moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.ingress_rules[0]
  to   = module.wrapper_vpc.module.nat_gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.ingress_rules[0]
}
```
