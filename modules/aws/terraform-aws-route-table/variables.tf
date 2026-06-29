################################################################################
# Route Table
################################################################################
variable "create_route_table" {
  description = ""
  type        = bool
  default     = false
}
variable "vpc_id" {
  description = ""
  type        = string
}
# variable "routes" {
#   description = ""
#   type        = any
# }
# variable "default_route" {
#   description = ""
#   type        = any
# }
variable "tags" {
  description = ""
  type        = any
  default     = {}
}