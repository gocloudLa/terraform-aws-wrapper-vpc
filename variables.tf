/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* VPC | Variable Definition                                            */
/*----------------------------------------------------------------------*/

variable "vpc_parameters" {
  type        = any
  description = "vpc parameteres to configure vpc module"
  default     = {}
}

variable "vpc_defaults" {
  type        = any
  description = "vpc defaults parameteres to configure vpc module"
  default = {
    vpc = {}
    tgw = {}
    vpn = {}
  }
}
