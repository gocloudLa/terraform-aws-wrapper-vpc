# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform VPC Networking Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-vpc/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-vpc.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-vpc.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-vpc/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for VPC simplifies the configuration of basic Networking services (VPC / Subnets / Route Tables / IGW / NatGW / NACL / etc).

### ✨ Features



### 🔗 External Modules
| Name | Version |
|------|------:|
| [terraform-aws-modules/ec2-instance/aws](https://github.com/terraform-aws-modules/ec2-instance-aws) | 6.0.2 |
| [terraform-aws-modules/security-group/aws](https://github.com/terraform-aws-modules/security-group-aws) | 5.3.0 |
| [terraform-aws-modules/vpc/aws](https://github.com/terraform-aws-modules/vpc-aws) | 6.0.1 |



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
    enable_nat_gateway         = false
    enable_ec2_nat_gateway     = true
    ec2_nat_gateway_attach_eip = true
  }
```


## 🔧 Additional Features Usage










---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la
- 🐛 **Issues**: [GitHub Issues](https://github.com/gocloudLa/issues)

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 