################################################################################
# VPC Flow Log
################################################################################

output "vpc_flow_log_id" {
  description = "The ID of the Flow Log resource"
  value       = try(aws_flow_log.this[0].id, null)
}

output "vpc_flow_log_destination_arn" {
  description = "The ARN of the destination for VPC Flow Logs"
  value       = local.flow_log_destination_arn
}

output "vpc_flow_log_destination_type" {
  description = "The type of the destination for VPC Flow Logs"
  value       = var.flow_log_destination_type
}

output "vpc_flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN of the IAM role used when pushing logs to Cloudwatch log group"
  value       = local.flow_log_iam_role_arn
}

output "vpc_flow_log_deliver_cross_account_role" {
  description = "The ARN of the IAM role used when pushing logs cross account"
  value       = try(aws_flow_log.this[0].deliver_cross_account_role, null)
}
