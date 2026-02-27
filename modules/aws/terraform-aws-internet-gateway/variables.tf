################################################################################
# Internet Gateway
################################################################################

variable "create_internet_gateway" {
  description = ""
  type        = bool
  default     = true
}
variable "vpc_id" {
  description = ""
  type        = string
}
variable "create_egress_only_igw" {
  description = ""
  type        = bool
  default     = false
}
variable "enable_ipv6" {
  description = ""
  type        = bool
  default     = false
}
variable "tags" {
  description = ""
  type        = any
}