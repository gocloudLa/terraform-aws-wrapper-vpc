data "aws_region" "current" {
  # Call this API only if create_vpc and enable_flow_log are true
  count = var.enable_flow_log ? 1 : 0
}

data "aws_caller_identity" "current" {
  # Call this API only if create_vpc and enable_flow_log are true
  count = var.enable_flow_log ? 1 : 0
}

data "aws_partition" "current" {
  # Call this API only if create_vpc and enable_flow_log are true
  count = var.enable_flow_log ? 1 : 0
}

data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  statement {
    sid = "AWSVPCFlowLogsAssumeRole"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = ["sts:AssumeRole"]

    dynamic "condition" {
      for_each = var.flow_log_cloudwatch_iam_role_conditions
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  statement {
    sid = "AWSVPCFlowLogsPushToCloudWatch"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = local.flow_log_group_arns
  }
}