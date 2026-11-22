locals {
  execution_boundary_arns = { for owner in keys(local.role_names) : owner =>
    "arn:aws:iam::${var.host_account_id}:policy/panic-boundaries/${replace(owner, "_", "-")}"
  }
  runtime_log_streams = { for owner in keys(local.role_names) : owner => concat(
    [for group in local.owned_log_groups[owner] : "${local.logs}:log-group:${group}:log-stream:*"],
    owner != "app" ? [
      "${local.logs}:log-group:/aws/sagemaker/TrainingJobs:log-stream:panic-*",
      "${local.logs}:log-group:/aws/sagemaker/ProcessingJobs:log-stream:panic-*",
      "${local.logs}:log-group:/aws/sagemaker/Endpoints/panic-*:log-stream:*"
    ] : []
  ) }
  execution_boundary_documents = { for owner in keys(local.role_names) : owner => jsonencode({
    Version = "2012-10-17"
    Statement = concat(local.storage_policies["${owner}/storage"], [
      {
        Sid      = "RuntimeLogs", Effect = "Allow", Action = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:GetLogEvents"],
        Resource = local.runtime_log_streams[owner]
      },
      {
        Sid      = "RuntimeLogGroups", Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:DescribeLogStreams"],
        Resource = [for group in concat(local.owned_log_groups[owner], owner != "app" ? local.sm_log_groups : []) : "${local.logs}:log-group:${group}:*"]
      },
      {
        Sid       = "RuntimeMetrics", Effect = "Allow", Action = ["cloudwatch:PutMetricData"], Resource = ["*"],
        Condition = { StringEquals = { "cloudwatch:namespace" = "PANIC", "aws:RequestedRegion" = var.region } }
      },
      {
        Sid       = "RuntimeRegistryAuthentication", Effect = "Allow", Action = ["ecr:GetAuthorizationToken"], Resource = ["*"],
        Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
      },
      {
        Sid      = "RuntimeImagePull", Effect = "Allow", Action = local.image_pull_actions,
        Resource = concat(local.image_repositories[owner], sort(tolist(var.additional_image_repository_arns)))
      },
      {
        Sid      = "RuntimeFeatureLookupAndScoring", Effect = "Allow",
        Action   = ["sagemaker:DescribeFeatureGroup", "sagemaker:GetRecord", "sagemaker:BatchGetRecord", "sagemaker:DescribeEndpoint", "sagemaker:InvokeEndpoint"],
        Resource = ["${local.sm}:feature-group/panic-*", "${local.sm}:endpoint/panic-*"]
      }
      ], [for statement in [
        {
          # Broader ceiling for experimentation. The inline policy still decides
          # which of these capabilities an individual workload actually receives.
          Sid      = "RuntimeMLDevelopment", Effect = "Allow", Action = ["sagemaker:*"],
          Resource = concat(local.ml_job_resources, [for kind in ["pipeline", "model", "model-package-group", "model-package", "endpoint", "endpoint-config", "mlflow-tracking-server"] : "${local.sm}:${kind}/panic-*"])
        },
        {
          Sid = "RuntimeMLflow", Effect = "Allow", Action = ["sagemaker-mlflow:*"], Resource = local.mlflow_servers
        }
        ] : statement if owner != "app"], [for statement in [
        {
          Sid      = "RuntimeAppData", Effect = "Allow",
          Action   = ["dynamodb:GetItem", "dynamodb:BatchGetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:Query", "dynamodb:Scan"],
          Resource = ["arn:aws:dynamodb:${local.account_region}:table/panic-*", "arn:aws:dynamodb:${local.account_region}:table/panic-*/index/*"]
        },
        {
          Sid      = "RuntimeFunctions", Effect = "Allow", Action = ["lambda:InvokeFunction"],
          Resource = ["arn:aws:lambda:${local.account_region}:function:panic-*"]
        },
        {
          Sid      = "RuntimeWorkflows", Effect = "Allow", Action = ["states:StartExecution", "states:StopExecution", "states:DescribeExecution", "states:GetExecutionHistory"],
          Resource = ["arn:aws:states:${local.account_region}:stateMachine:panic-*", "arn:aws:states:${local.account_region}:execution:panic-*:*"]
        },
        {
          Sid = "RuntimeAlerts", Effect = "Allow", Action = ["sns:Publish"], Resource = ["arn:aws:sns:${local.account_region}:panic-*"]
        },
        {
          # Callback APIs have no resource-level authorization; possession of the
          # correct task token is additionally required by Step Functions.
          Sid      = "RuntimeApprovalCallbacks", Effect = "Allow", Action = ["states:SendTaskSuccess", "states:SendTaskFailure", "states:SendTaskHeartbeat"],
          Resource = ["*"], Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
        }
        ] : statement if owner == "app"], [for statement in [
        {
          Sid = "KeepApprovalWithLead", Effect = "Deny", Action = ["sagemaker:UpdateModelPackage"], Resource = ["${local.sm}:model-package/panic-*/*"]
        },
        {
          Sid       = "RegisterPendingOnly", Effect = "Deny", Action = ["sagemaker:CreateModelPackage"], Resource = ["${local.sm}:model-package/panic-*/*"],
          Condition = { StringNotEquals = { "sagemaker:ModelApprovalStatus" = "PendingManualApproval" } }
        }
        ] : statement if owner == "mlops"], [for key, role in var.execution_roles : {
        Sid       = "Pass${replace(key, "/[^A-Za-z0-9]/", "")}", Effect = "Allow", Action = ["iam:PassRole"], Resource = [role.arn],
        Condition = { StringEquals = { "iam:PassedToService" = role.service } }
    } if role.owner == owner])
  }) }
}

# Platform owns these ceilings. They grant nothing on their own; foundation
# attaches them to execution roles, whose inline policies are owned by teammates.
resource "aws_iam_policy" "execution_boundary" {
  for_each    = local.execution_boundary_documents
  name        = replace(each.key, "_", "-")
  path        = "/panic-boundaries/"
  description = "PANIC ${each.key} execution-role development ceiling"
  policy      = each.value

  lifecycle {
    precondition {
      condition     = length(each.value) <= 6144
      error_message = "The execution boundary exceeds IAM's 6,144-character limit; reduce or regroup its resource patterns."
    }
  }
}
