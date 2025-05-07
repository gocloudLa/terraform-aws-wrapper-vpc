################################################################################
# Subnets
################################################################################

variable "create_network_acl" {
  description = ""
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "rules" {
  description = ""
  type        = any
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = any
}