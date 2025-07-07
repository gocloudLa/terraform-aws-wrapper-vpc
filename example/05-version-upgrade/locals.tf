locals {

  metadata = {
    aws_region  = "us-east-1"
    environment = "prd"

    public_domain  = "rext.cloud"
    private_domain = "rext"

    key = {
      company = "rxt"
      region  = "use1"
      env     = "prd"
    }
  }

  common_name = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  common_tags = {
    "company"     = local.metadata.key.company
    "provisioner" = "terraform"
    "environment" = local.metadata.environment
    "created-by"  = "GoCloud.la"
  }

  # Only needed in version < 3.X
  vpc_cidr = "10.130.0.0/16"
}
