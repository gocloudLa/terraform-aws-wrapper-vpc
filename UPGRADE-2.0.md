# Upgrade from v1.x to v2.0

If you have a question regarding this upgrade process, please check code in `examples` directory:

If you found a bug, please open an issue in this repository.

## List of Changes

1. Moved resources

  - `aws_instance.this` => `aws_instance.ignore_ami`

## List of backward incompatible changes

### Moved resources

1. moved resources:

  - `module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.this[0]` => `module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.ignore_ami[0]`

Example upgrade procedure for VPC, add `moved.tf` file

```hcl
moved {
  from = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.this[0]
  to   = module.base.module.wrapper_vpc.module.vpc-ec2-nat-gateway.module.ec2_instance[0].aws_instance.ignore_ami[0]
}
```
