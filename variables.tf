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
  default     = {}
}

/*----------------------------------------------------------------------*/
/* TGW | Variable Definition                                            */
/*----------------------------------------------------------------------*/

variable "tgw_parameters" {
  type        = any
  description = "tgw parameteres to configure tgw module"
  default     = {}
}

variable "tgw_defaults" {
  type        = any
  description = "tgw defaults parameteres to configure tgw module"
  default     = {}
}

/*----------------------------------------------------------------------*/
/* VPN | Variable Definition                                            */
/*----------------------------------------------------------------------*/

variable "vpn_parameters" {
  type        = any
  description = "vpn parameteres to configure vpn module"
  default     = {}
}

variable "vpn_defaults" {
  type        = any
  description = "vpn defaults parameteres to configure vpn module"
  default     = {}
}
