/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

variable "vpc_parameter" {
  type        = any
  description = "vpc parameteres to configure vpn module"
  default     = {}
}

variable "tgw_parameter" {
  type        = any
  description = "tgw parameteres to configure vpn module"
  default     = {}
}

/*----------------------------------------------------------------------*/
/* VPN | Variable Definition                                            */
/*----------------------------------------------------------------------*/
variable "vpn_parameters" {
  type        = any
  description = "VPN parameteres to configure VPN module"
  default     = {}
}

variable "vpn_defaults" {
  type        = any
  description = "VPN defaults parameteres to configure VPN module"
  default     = {}
}

# /*----------------------------------------------------------------------*/
# /* CLIENT VPN | Variable Definition                                            */
# /*----------------------------------------------------------------------*/
# variable "client_vpn_parameters" {
#   type        = any
#   description = "Cient VPN parameteres to configure Cient VPN module"
#   default     = {}
# }

# variable "client_vpn_defaults" {
#   type        = any
#   description = "Cient VPN defaults parameteres to configure Cient VPN module"
#   default     = {}
# }