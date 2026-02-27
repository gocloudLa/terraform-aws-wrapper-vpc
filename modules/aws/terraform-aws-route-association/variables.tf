################################################################################
# Route Table
################################################################################
variable "create_default_route" {
  description = ""
  type        = bool
  default     = false
}
variable "route_table_id" {
  description = ""
  type        = string
}
variable "routes" {
  description = ""
  type        = any
}
variable "default_route" {
  description = ""
  type        = any
}
variable "tags" {
  description = ""
  type        = any
  default     = {}
}