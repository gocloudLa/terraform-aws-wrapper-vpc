# Documentation

## Introducción

El Wrapper de Terraform para VPC simplifica la configuración de los servicios basicos de Networking ( VPC / Subnets / Route Tables / IGW / NatGW / NACL / etc ). 

**Diagrama** <br/>
A continuación se puede ver una imagen que muestra la totalidad de recursos que se pueden desplegar con el wrapper:

<center>![alt text](diagrams/main.png)</center>

---

## Modo de Uso
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
    enable_nat_gateway         = false
    enable_ec2_nat_gateway     = true
    ec2_nat_gateway_attach_eip = true
  }
```

<details>
<summary>Tabla de Variables</summary>

| Variable                               | Variable Description                                              | Type     | Default                                     | Alternatives                                 |
|--------------------------------------- |-------------------------------------------------------------------|----------|---------------------------------------------|----------------------------------------------|
| private_subnets                        | List of private subnets for the VPC.                              | `list`   | []                                          | List of subnet IDs                           |
| public_subnets                         | List of public subnets for the VPC.                               | `list`   | []                                          | List of subnet IDs                           |
| database_subnets                       | List of database subnets for the VPC.                             | `list`   | []                                          | List of subnet IDs                           |
| elasticache_subnets                    | List of Elasticache subnets for the VPC.                          | `list`   | []                                          | List of subnet IDs                           |
| enable_ipv6                            | Enable IPv6 for the VPC.                                          | `bool`   | false                                       | true                                         |
| manage_default_vpc                     | Manage the default VPC.                                           | `bool`   | false                                       | true                                         |
| create_igw                             | Create an Internet Gateway for the VPC.                           | `bool`   | true                                        | false                                        |
| enable_dns_hostnames                   | Enable DNS hostnames in the VPC.                                  | `bool`   | true                                        | false                                        |
| enable_dns_support                     | Enable DNS support in the VPC.                                    | `bool`   | true                                        | false                                        |
| map_public_ip_on_launch                | Automatically assign a public IP on instance launch.              | `bool`   | true                                        | false                                        |
| enable_nat_gateway                     | Enable the NAT Gateway for the VPC.                               | `bool`   | false                                       | true                                         |
| single_nat_gateway                     | Create a single NAT Gateway.                                      | `bool`   | true                                        | false                                        |
| one_nat_gateway_per_az                 | Create one NAT Gateway per Availability Zone.                     | `bool`   | false                                       | true                                         |
| manage_default_network_acl             | Manage the default network ACL for the VPC.                       | `bool`   | true                                        | false                                        |
| default_network_acl_tags               | Tags for the default network ACL.                                 | `map `   | `{ Name = "${local.common_name}-default" }` | Custom tags                                  |
| public_dedicated_network_acl           | Create a dedicated network ACL for public subnets.                | `bool`   | false                                       | true                                         |
| public_inbound_acl_rules               | Inbound rules for public subnets' network ACL.                    | `list`   | []                                          | List of ACL rules                            |
| public_outbound_acl_rules              | Outbound rules for public subnets' network ACL.                   | `list`   | []                                          | List of ACL rules                            |
| private_dedicated_network_acl          | Create a dedicated network ACL for private subnets.               | `bool`   | false                                       | true                                         |
| private_inbound_acl_rules              | Inbound rules for private subnets' network ACL.                   | `list`   | []                                          | List of ACL rules                            |
| private_outbound_acl_rules             | Outbound rules for private subnets' network ACL.                  | `list`   | []                                          | List of ACL rules                            |
| manage_default_route_table             | Manage the default route table for the VPC.                       | `bool`   | true                                        | false                                        |
| default_route_table_propagating_vgws   | List of VGWs to propagate in the default route table.             | `list`   | []                                          | List of VGW IDs                              |
| default_route_table_routes             | Custom routes for the default route table.                        | `list`   | []                                          | List of route definitions                    |
| default_route_table_tags               | Tags for the default route table.                                 | `map `   | `{ Name = "${local.common_name}-default" }` | Custom tags                                  |
| manage_default_security_group          | Manage the default security group for the VPC.                    | `bool`   | true                                        | false                                        |
| default_security_group_ingress         | Ingress rules for the default security group.                     | `list`   | []                                          | List of ingress rules                        |
| default_security_group_egress          | Egress rules for the default security group.                      | `list`   | []                                          | List of egress rules                         |
| default_security_group_tags            | Tags for the default security group.                              | `map `   | `{ Name = "${local.common_name}-default" }` | Custom tags                                  |
| enable_vpn_gateway                     | Enable a VPN Gateway for the VPC.                                 | `bool`   | false                                       | true                                         |
| vpn_gateway_id                         | The ID of an existing VPN Gateway to attach to the VPC.           | `string` | ""                                          | Existing VPN Gateway ID                      |
| vpn_gateway_az                         | The Availability Zone for the VPN Gateway.                        | `string` | null                                        | Any valid AZ                                 |
| propagate_private_route_tables_vgw     | Propagate the VPN Gateway to private route tables.                | `bool`   | false                                       | true                                         |
| propagate_public_route_tables_vgw      | Propagate the VPN Gateway to public route tables.                 | `bool`   | false                                       | true                                         |
| enable_dhcp_options                    | Enable custom DHCP options for the VPC.                           | `bool`   | false                                       | true                                         |
| dhcp_options_domain_name               | Domain name for DHCP options.                                     | `string` | ""                                          | Custom domain name                           |
| dhcp_options_domain_name_servers       | List of domain name servers for DHCP options.                     | `list`   | []                                          | List of IP addresses                         |
| dhcp_options_ntp_servers               | List of NTP servers for DHCP options.                             | `list`   | []                                          | List of NTP server IPs                       |
| dhcp_options_netbios_name_servers      | List of NetBIOS name servers for DHCP options.                    | `list`   | []                                          | List of NetBIOS server IPs                   |
| dhcp_options_netbios_node_type         | NetBIOS node type for DHCP options.                               | `string` | ""                                          | Valid NetBIOS node type                      |
| enable_public_redshift                 | Enable public accessibility for Redshift.                         | `bool`   | false                                       | true                                         |
| enable_flow_log                        | Enable VPC Flow Logs.                                             | `bool`   | false                                       | true                                         |
| create_flow_log_cloudwatch_iam_role    | Create an IAM role for CloudWatch Flow Logs.                      | `bool`   | false                                       | true                                         |
| create_flow_log_cloudwatch_log_group   | Create a CloudWatch log group for Flow Logs.                      | `bool`   | false                                       | true                                         |
| vpc_flow_log_permissions_boundary      | Permissions boundary for the VPC Flow Log role.                   | `string` | null                                        | ARN of the boundary policy                   |
| flow_log_traffic_type                  | Type of traffic to capture in the Flow Log (ALL, ACCEPT, REJECT). | `string` | ""                                          | "ALL", "ACCEPT", "REJECT"                    |
| flow_log_destination_type              | Destination type for Flow Logs (cloud-watch-logs or s3).          | `string` | ""                                          | "cloud-watch-logs", "s3"                     |
| flow_log_log_format                    | Log format for Flow Logs.                                         | `string` | null                                        | Custom log format                            |
| flow_log_destination_arn               | ARN of the destination for Flow Logs.                             | `string` | ""                                          | ARN of the CloudWatch log group or S3 bucket |
| create_elasticache_subnet_group        | Create a subnet group for Elasticache.                            | `bool`   | false                                       | true                                         |
| elasticache_subnet_group_name          | Name for the Elasticache subnet group.                            | `string` | null                                        | Custom name                                  |
| elasticache_subnet_group_tags          | Tags for the Elasticache subnet group.                            | `map`    | {}                                          | Custom tags                                  |
| create_elasticache_subnet_route_table  | Create a route table for the Elasticache subnet.                  | `bool`   | false                                       | true                                         |
| create_database_internet_gateway_route | Create an Internet Gateway route for the database subnet.         | `bool`   | false                                       | true                                         |
| create_database_nat_gateway_route      | Create a NAT Gateway route for the database subnet.               | `bool`   | false                                       | true                                         |
| database_subnet_group_name             | Name for the database subnet group.                               | `string` | ""                                          | Custom name                                  |
| attach_eip                             | Attach an Elastic IP to the NAT Gateway.                          | `bool`   | false                                       | true                                         |

</details>
---

