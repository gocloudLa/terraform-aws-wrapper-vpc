/*----------------------------------------------------------------------*/
/* VPC | Variable Definition                                            */
/*----------------------------------------------------------------------*/
variable "tgw_parameters" {
  type        = any
  description = "Tansit gateway parameteres to configure transit gateway module"
  default     = {}
}

variable "tgw_defaults" {
  type        = any
  description = "Tansit gateway defaults parameteres to configure tansit gateway module"
  default     = {}
}
