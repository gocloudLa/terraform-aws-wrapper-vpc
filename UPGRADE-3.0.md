# Upgrade from v2.0 to v3.0
If you have a question regarding this upgrade process, please check code in `example/00-simple-vpc` directory:

If you found a bug, please open an issue in this repository.
## List of Changes

1. Moved all VPC resources due to upgrade to local wrappers and modules instead of using public terraform module 

2. Creation of new resources

    * Explicit assoiciation to default VPC-Network-ACL, when not using a custom Network-ACL
        -`module.wrapper_vpc.module.wrapper_vpc.module.subnet["vpc-key"-"subnet-key"].aws_network_acl_association.this`
    * Creation of Transit Gateway resources (see example/02-complete-tgw and example/04-complete-tgw_attachment)
    * Creation of VPN Site-To-Site resources (example/03-complete-vpn) 

## List of backward incompatible changes

### Moved resources

1. moved resources:

#### VPC
  - `module.wrapper_vpc.module.vpc.aws_vpc.this[key]` => `module.wrapper_vpc.module.wrapper_vpc.module.vpc["key"].aws_vpc.this`

#### Subnets
  - `module.wrapper_vpc.module.vpc.aws_subnet.database[key]` => `module.wrapper_vpc.module.wrapper_vpc.module.subnet[key].aws_subnet.this[0]`

#### Route Table
  - `module.wrapper_vpc.module.vpc.aws_route_table.private[0]` => `module.wrapper_vpc.module.wrapper_vpc.module.route-table["key"].aws_route_table.this[0]`

#### Internet Gateway
  - `module.wrapper_vpc.module.vpc.aws_internet_gateway.this[0]` => `module.wrapper_vpc.module.wrapper_vpc.module.internet-gateway["vpc-key"-"igw-key""].aws_internet_gateway.this[0]`
  - `module.wrapper_vpc.module.vpc.aws_route.public_internet_gateway[0]` => `module.wrapper_vpc.module.wrapper_vpc.module.route-association["vpc-key"-"igw-key"].aws_route.default[0]`

#### AWS NAT Gateway
moved {
  - `module.wrapper_vpc.module.vpc.aws_route.private_nat_gateway[0]` => `module.wrapper_vpc.module.wrapper_vpc.module.route-association["vpc-key"-"rt-key"].aws_route.default[0]`
  - `module.wrapper_vpc.module.vpc.aws_eip.nat[0]` => `module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["vpc-key"-"natgw-key"].aws_eip.this[0]`
  - `module.wrapper_vpc.module.vpc.aws_nat_gateway.this[0] ` => `module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["vpc-key"-"natgw-key"].aws_nat_gateway.this[0]`

#### Route Table Asociation
  - `module.wrapper_vpc.module.vpc.aws_route_table_association.database[0]` => `module.wrapper_vpc.module.wrapper_vpc.module.subnet["key"].aws_route_table_association.this`

#### Default VPC Resources
  - `module.wrapper_vpc.module.vpc.aws_default_network_acl.this[0]` => `module.wrapper_vpc.module.wrapper_vpc.aws_default_network_acl.this["vpc-key"]`
  - `module.wrapper_vpc.module.vpc.aws_default_route_table.default[0]` => `module.wrapper_vpc.module.wrapper_vpc.aws_default_route_table.this["vpc-key"]`
  - `module.wrapper_vpc.module.vpc.aws_default_security_group.this[0]` => `module.wrapper_vpc.module.wrapper_vpc.module.vpc["vpc-key"].aws_default_security_group.default`

#### VPC Endpoints
  - `module.wrapper_vpc.module.vpc-endpoint.aws_vpc_endpoint.this["key"]` => `module.wrapper_vpc.module.wrapper_vpc.module.vpc-endpoint["vpc-key"].aws_vpc_endpoint.this["endpoint-key"]`

#### EC2 Nat-Gateway
  - `module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_eip.this[0]` => `module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["vpc-key"-"ec2-nat-key"].module.vpc-ec2-nat-gateway[0].aws_eip.this[0]` 
  - `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_instance_profile.this[0]` =>  `module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["vpc-key"-"ec2-nat-key"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_instance_profile.this[0]`
  - `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role.this[0]` =>  `module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["vpc-key"-"ec2-nat-key"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role.this[0]`
  - `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]` => `module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["vpc-key"-"ec2-nat-key"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]`
  - `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.ignore_ami[0]` =>  `module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["vpc-key"-"ec2-nat-key"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_instance.ignore_ami[0]`
  - `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group.this[0]` =>  `module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["vpc-key"-"ec2-nat-key"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group.this[0]`
  - `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.egress_rules[0]` => `module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["vpc-key"-"ec2-nat-key"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.egress_rules[0]`
  - `module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.ingress_rules[0]` =>  `module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["vpc-key"-"ec2-nat-key"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.ingress_rules[0]`
 
Example upgrade procedure for VPC, add `moved.tf` file

```hcl
# VPC
moved {
  from = module.wrapper_vpc.module.vpc.aws_vpc.this[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.vpc["test"].aws_vpc.this
}

# Subnets
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.database[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.database[1]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.database[2]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1c"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.elasticache[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.elasticache[1]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.elasticache[2]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1c"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.private[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.private[1]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.private[2]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1c"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.public[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1a"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.public[1]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1b"].aws_subnet.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_subnet.public[2]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1c"].aws_subnet.this[0]
}

# Route Table
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table.private[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.route-table["test-00-private"].aws_route_table.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table.public[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.route-table["test-00-public"].aws_route_table.this[0]
}

# IGW
moved {
  from = module.wrapper_vpc.module.vpc.aws_internet_gateway.this[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.internet-gateway["test-00-igw"].aws_internet_gateway.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_route.public_internet_gateway[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.route-association["test-00-public"].aws_route.default[0]
}

# if using AWS NAT-GW
moved {
  from = module.wrapper_vpc.module.vpc.aws_route.private_nat_gateway[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.route-association["test-00-private"].aws_route.default[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_eip.nat[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].aws_eip.this[0]
}
moved {
  from = module.wrapper_vpc.module.vpc.aws_nat_gateway.this[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].aws_nat_gateway.this[0]
}

# Route Table association
moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.database[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1a"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.database[1]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1b"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.database[2]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-db-us-east-1c"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1a"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[1]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1b"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.elasticache[2]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-elasticache-us-east-1c"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.private[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1a"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.private[1]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1b"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.private[2]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-private-us-east-1c"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.public[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1a"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.public[1]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1b"].aws_route_table_association.this
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_route_table_association.public[2]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.subnet["test-public-us-east-1c"].aws_route_table_association.this
}

# Default VPC Resources
moved {
  from = module.wrapper_vpc.module.vpc.aws_default_network_acl.this[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.aws_default_network_acl.this["test"]
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_default_route_table.default[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.aws_default_route_table.this["test"]
}

moved {
  from = module.wrapper_vpc.module.vpc.aws_default_security_group.this[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.vpc["test"].aws_default_security_group.default
}

# VPC Endpoints
moved {
  from = module.wrapper_vpc.module.vpc-endpoint.aws_vpc_endpoint.this["s3"]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.vpc-endpoint["test"].aws_vpc_endpoint.this["00"]
}

moved {
  from = module.wrapper_vpc.module.vpc-endpoint.aws_vpc_endpoint.this["dynamodb"]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.vpc-endpoint["test"].aws_vpc_endpoint.this["01"]
}

# EC2 Nat-Gateway
moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_eip.this[0]
  to = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].aws_eip.this[0]
} ## if using Elastic IP with the EC2-NAT

moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.aws_route.this[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.route-association["test-00-private"].aws_route.default[0]
}

moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_instance_profile.this[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_instance_profile.this[0]
}

moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role.this[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role.this[0]
}

moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_iam_role_policy_attachment.this["AmazonSSMManagedEC2InstanceDefaultPolicy"]
}

moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.ignore_ami[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.ec2_instance[0].aws_instance.ignore_ami[0]
}

moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group.this[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group.this[0]
}

moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.egress_rules[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.egress_rules[0]
}

moved {
  from = module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.security_group[0].aws_security_group_rule.ingress_rules[0]
  to   = module.wrapper_vpc.module.wrapper_vpc.module.nat-gateway["test-natgw"].module.vpc-ec2-nat-gateway[0].module.security_group[0].aws_security_group_rule.ingress_rules[0]
}
```
