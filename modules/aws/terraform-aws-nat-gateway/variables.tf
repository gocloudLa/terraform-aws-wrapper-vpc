################################################################################
# NAT Gateway
################################################################################

variable "create_nat_gateway" {
  description = ""
  type        = bool
  default     = false
}
variable "kind" {
  description = ""
  type        = string
  default     = "aws"
}
variable "subnet_id" {
  description = ""
  type        = string
}
variable "vpc_id" {
  description = ""
  type        = string
}
variable "nat_parameters" {
  description = ""
  type        = any
}
variable "tags" {
  description = ""
  type        = any
}