# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform VPC Networking Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-vpc/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-vpc.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-vpc.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-vpc/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for VPC simplifies the configuration of basic Networking services (VPC / Subnets / Route Tables / IGW / NatGW / NACL / etc).

### ✨ Features

- 🖥️ [Custom EC2 NAT Gateway](#custom-ec2-nat-gateway) - Deploy cost-effective EC2-based NAT Gateway instead of managed NAT Gateway



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-ec2-instance" target="_blank">terraform-aws-modules/ec2-instance/aws</a> | 6.1.1 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-security-group" target="_blank">terraform-aws-modules/security-group/aws</a> | 5.3.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-vpc" target="_blank">terraform-aws-modules/vpc/aws</a> | 6.5.1 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-vpc" target="_blank">terraform-aws-modules/vpc/aws</a> | 6.4.0 |



## 🚀 Quick Start
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
    enable_nat_gateway         = true
  }
```


## 🔧 Additional Features Usage

### Custom EC2 NAT Gateway
Configure a custom EC2 instance as NAT Gateway for private subnet internet access, providing a cost-effective alternative to AWS managed NAT Gateway service.


<details><summary>EC2 NAT Gateway Configuration</summary>

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
  
  # Disable managed NAT Gateway
  enable_nat_gateway = false
  
  # Enable EC2-based NAT Gateway
  enable_ec2_nat_gateway = true
  ec2_nat_gateway_attach_eip = true
}
```


</details>




## 📑 Inputs
| Name                                    | Description                                                                                       | Type     | Default                                             | Required |
| --------------------------------------- | ------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------- | -------- |
| create_database_internet_gateway_route  | Create an Internet Gateway route for the database subnet.                                         | `bool`   | `false`                                             | no       |
| create_database_nat_gateway_route       | Create a NAT Gateway route for the database subnet.                                               | `bool`   | `false`                                             | no       |
| create_elasticache_subnet_group         | Create a subnet group for Elasticache.                                                            | `bool`   | `false`                                             | no       |
| create_elasticache_subnet_route_table   | Create a route table for the Elasticache subnet.                                                  | `bool`   | `false`                                             | no       |
| create_flow_log_cloudwatch_iam_role     | Create an IAM role for CloudWatch Flow Logs.                                                      | `bool`   | `false`                                             | no       |
| create_flow_log_cloudwatch_log_group    | Create a CloudWatch log group for Flow Logs.                                                      | `bool`   | `false`                                             | no       |
| create_igw                              | Create an Internet Gateway for the VPC.                                                           | `bool`   | `true`                                              | no       |
| create_private_nat_gateway_route        | Controls if a NAT gateway route should be created to give internet access to the private subnets. | `bool`   | `true`                                              | no       |
| database_subnet_group_name              | Name for the database subnet group.                                                               | `string` | `""`                                                | no       |
| database_subnets                        | List of database subnets for the VPC.                                                             | `list`   | `[]`                                                | no       |
| database_subnet_names                   | Explicit values to use in the Name tag on database subnets.                                       | `list`   | `[]`                                                | no       |
| default_network_acl_tags                | Tags for the default network ACL.                                                                 | `null`   | `{ Name = "${local.common_name}-default" }`         | no       |
| default_route_table_propagating_vgws    | List of VGWs to propagate in the default route table.                                             | `list`   | `[]`                                                | no       |
| default_route_table_routes              | Custom routes for the default route table.                                                        | `list`   | `[]`                                                | no       |
| default_route_table_tags                | Tags for the default route table.                                                                 | `null`   | `{ Name = "${local.common_name}-default" }`         | no       |
| default_security_group_egress           | Egress rules for the default security group.                                                      | `list`   | `[]`                                                | no       |
| default_security_group_ingress          | Ingress rules for the default security group.                                                     | `list`   | `[]`                                                | no       |
| default_security_group_tags             | Tags for the default security group.                                                              | `null`   | `{ Name = "${local.common_name}-default" }`         | no       |
| dhcp_options_domain_name                | Domain name for DHCP options.                                                                     | `string` | `""`                                                | no       |
| dhcp_options_domain_name_servers        | List of domain name servers for DHCP options.                                                     | `list`   | `[]`                                                | no       |
| dhcp_options_netbios_name_servers       | List of NetBIOS name servers for DHCP options.                                                    | `list`   | `[]`                                                | no       |
| dhcp_options_netbios_node_type          | NetBIOS node type for DHCP options.                                                               | `string` | `""`                                                | no       |
| dhcp_options_ntp_servers                | List of NTP servers for DHCP options.                                                             | `list`   | `[]`                                                | no       |
| ec2_nat_gateway_attach_eip              | Attach an Elastic IP to the EC2 NAT Gateway.                                                      | `bool`   | `false`                                             | no       |
| elasticache_dedicated_network_acl       | Create a dedicated network ACL for Elasticache subnets.                                           | `bool`   | `false`                                             | no       |
| elasticache_subnet_group_name           | Name for the Elasticache subnet group.                                                            | `string` | `null`                                              | no       |
| elasticache_subnet_group_tags           | Tags for the Elasticache subnet group.                                                            | `map`    | `{}`                                                | no       |
| elasticache_subnets                     | List of Elasticache subnets for the VPC.                                                          | `list`   | `[]`                                                | no       |
| elasticache_subnet_names                | Explicit values to use in the Name tag on elasticache subnets.                                    | `list`   | `[]`                                                | no       |
| enable_dhcp_options                     | Enable custom DHCP options for the VPC.                                                           | `bool`   | `false`                                             | no       |
| enable_dns_hostnames                    | Enable DNS hostnames in the VPC.                                                                  | `bool`   | `true`                                              | no       |
| enable_dns_support                      | Enable DNS support in the VPC.                                                                    | `bool`   | `true`                                              | no       |
| enable_ec2_nat_gateway                  | Enable EC2-based NAT Gateway instead of managed NAT Gateway.                                      | `bool`   | `false`                                             | no       |
| enable_flow_log                         | Enable VPC Flow Logs.                                                                             | `bool`   | `false`                                             | no       |
| enable_ipv6                             | Enable IPv6 for the VPC.                                                                          | `bool`   | `false`                                             | no       |
| enable_nat_gateway                      | Enable the NAT Gateway for the VPC.                                                               | `bool`   | `false`                                             | no       |
| enable_public_redshift                  | Enable public accessibility for Redshift.                                                         | `bool`   | `false`                                             | no       |
| enable_vpn_gateway                      | Enable a VPN Gateway for the VPC.                                                                 | `bool`   | `false`                                             | no       |
| external_nat_ip_ids                     | List of EIP IDs to be assigned to the NAT Gateways.                                               | `list`   | `[]`                                                | no       |
| flow_log_cloudwatch_iam_role_conditions | Additional conditions of the CloudWatch role assumption policy.                                   | `list`   | `[]`                                                | no       |
| flow_log_destination_arn                | ARN of the destination for Flow Logs.                                                             | `string` | `""`                                                | no       |
| flow_log_destination_type               | Destination type for Flow Logs (cloud-watch-logs or s3).                                          | `string` | `""`                                                | no       |
| flow_log_log_format                     | Log format for Flow Logs.                                                                         | `string` | `null`                                              | no       |
| flow_log_traffic_type                   | Type of traffic to capture in the Flow Log (ALL, ACCEPT, REJECT).                                 | `string` | `""`                                                | no       |
| igw_tags                                | Additional tags for the internet gateway.                                                         | `map`    | `{}`                                                | no       |
| instance_tenancy                        | A tenancy option for instances launched into the VPC.                                             | `string` | `"default"`                                         | no       |
| manage_default_network_acl              | Manage the default network ACL for the VPC.                                                       | `bool`   | `true`                                              | no       |
| manage_default_route_table              | Manage the default route table for the VPC.                                                       | `bool`   | `true`                                              | no       |
| manage_default_security_group           | Manage the default security group for the VPC.                                                    | `bool`   | `true`                                              | no       |
| manage_default_vpc                      | Manage the default VPC.                                                                           | `bool`   | `false`                                             | no       |
| map_public_ip_on_launch                 | Automatically assign a public IP on instance launch.                                              | `bool`   | `true`                                              | no       |
| name                                    | Name to be used on all the resources as identifier.                                               | `string` | `local.common_name`                                 | no       |
| nat_gateway_tags                        | Additional tags for the NAT gateways.                                                             | `map`    | `{}`                                                | no       |
| nat_eip_tags                            | Additional tags for the NAT EIP.                                                                  | `map`    | `{}`                                                | no       |
| one_nat_gateway_per_az                  | Create one NAT Gateway per Availability Zone.                                                     | `bool`   | `false`                                             | no       |
| private_dedicated_network_acl           | Create a dedicated network ACL for private subnets.                                               | `bool`   | `false`                                             | no       |
| private_inbound_acl_rules               | Inbound rules for private subnets' network ACL.                                                   | `list`   | `[]`                                                | no       |
| private_outbound_acl_rules              | Outbound rules for private subnets' network ACL.                                                  | `list`   | `[]`                                                | no       |
| private_subnets                         | List of private subnets for the VPC.                                                              | `list`   | `[]`                                                | no       |
| private_subnet_names                    | Explicit values to use in the Name tag on private subnets.                                        | `list`   | `[]`                                                | no       |
| private_route_table_tags                | Additional tags for the private route tables.                                                     | `map`    | `{}`                                                | no       |
| propagate_private_route_tables_vgw      | Propagate the VPN Gateway to private route tables.                                                | `bool`   | `false`                                             | no       |
| propagate_public_route_tables_vgw       | Propagate the VPN Gateway to public route tables.                                                 | `bool`   | `false`                                             | no       |
| public_dedicated_network_acl            | Create a dedicated network ACL for public subnets.                                                | `bool`   | `false`                                             | no       |
| public_inbound_acl_rules                | Inbound rules for public subnets' network ACL.                                                    | `list`   | `[]`                                                | no       |
| public_outbound_acl_rules               | Outbound rules for public subnets' network ACL.                                                   | `list`   | `[]`                                                | no       |
| public_subnets                          | List of public subnets for the VPC.                                                               | `list`   | `[]`                                                | no       |
| public_subnet_names                     | Explicit values to use in the Name tag on public subnets.                                         | `list`   | `[]`                                                | no       |
| public_route_table_tags                 | Additional tags for the public route tables.                                                      | `map`    | `{}`                                                | no       |
| reuse_nat_ips                           | Should be true if you don't want EIPs to be created for your NAT Gateways.                        | `bool`   | `false`                                             | no       |
| secondary_cidr_blocks                   | List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool.            | `list`   | `[]`                                                | no       |
| single_nat_gateway                      | Create a single NAT Gateway.                                                                      | `bool`   | `true`                                              | no       |
| vpc_block_public_access_exclusions      | A map of VPC block public access exclusions.                                                      | `null`   | `{}`                                                | no       |
| vpc_block_public_access_options         | A map of VPC block public access options.                                                         | `null`   | `{}`                                                | no       |
| vpc_cidr                                | The CIDR block for the VPC.                                                                       | `string` | `""`                                                | no       |
| vpc_endpoint_s3_tags                    | Additional tags for the VPC S3 Endpoint.                                                          | `map`    | `{ Name = "${local.common_name}-s3-vpc-endpoint" }` | no       |
| vpc_flow_log_permissions_boundary       | Permissions boundary for the VPC Flow Log role.                                                   | `string` | `null`                                              | no       |
| vpn_gateway_az                          | The Availability Zone for the VPN Gateway.                                                        | `string` | `null`                                              | no       |
| vpn_gateway_id                          | The ID of an existing VPN Gateway to attach to the VPC.                                           | `string` | `""`                                                | no       |
| tags                                    | A map of tags to assign to resources.                                                             | `map`    | `{}`                                                | no       |








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