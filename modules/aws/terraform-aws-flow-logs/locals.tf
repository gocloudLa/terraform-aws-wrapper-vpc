locals {
  # Only create flow log if user selected to create a VPC as well
  enable_flow_log = var.enable_flow_log

  create_flow_log_cloudwatch_iam_role  = local.enable_flow_log && var.flow_log_destination_type != "s3" && var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = local.enable_flow_log && var.flow_log_destination_type != "s3" && var.create_flow_log_cloudwatch_log_group

  flow_log_destination_arn                  = local.create_flow_log_cloudwatch_log_group ? try(aws_cloudwatch_log_group.flow_log[0].arn, null) : var.flow_log_destination_arn
  flow_log_iam_role_arn                     = var.flow_log_destination_type != "s3" && local.create_flow_log_cloudwatch_iam_role ? try(aws_iam_role.vpc_flow_log_cloudwatch[0].arn, null) : var.flow_log_cloudwatch_iam_role_arn
  flow_log_cloudwatch_log_group_name_suffix = var.flow_log_cloudwatch_log_group_name_suffix == "" ? var.vpc_id : var.flow_log_cloudwatch_log_group_name_suffix
  flow_log_group_arns = [
    for log_group in aws_cloudwatch_log_group.flow_log :
    "arn:${data.aws_partition.current[0].partition}:logs:${data.aws_region.current[0].region}:${data.aws_caller_identity.current[0].account_id}:log-group:${log_group.name}:*"
  ]
}