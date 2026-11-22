locals {
  account_region = "${var.region}:${var.host_account_id}"
  sm             = "arn:aws:sagemaker:${local.account_region}"
  cw             = "arn:aws:cloudwatch:${local.account_region}"
  logs           = "arn:aws:logs:${local.account_region}"
  bucket         = "arn:aws:s3:::${var.data_bucket_name}"

  # Paths are reserved as a contract with the forthcoming platform/data stack.
  read_prefixes = {
    lead_ml = ["raw", "features", "experiments", "models", "evaluations", "scoring", "monitoring"]
    mlops   = ["features", "experiments", "models", "evaluations", "scoring", "monitoring", "pipeline-code"]
    app     = ["app", "scoring", "evaluations"]
  }
  write_prefixes = {
    lead_ml = ["raw", "features", "experiments", "evaluations"]
    mlops   = ["models", "evaluations", "monitoring", "pipeline-code"]
    app     = ["app", "scoring"]
  }

  sm_read_resources = [
    for kind in ["training-job", "processing-job", "model", "model-package-group", "model-package", "pipeline", "endpoint", "endpoint-config", "feature-group"] :
    "${local.sm}:${kind}/panic-*"
  ]
  sm_read_actions = [
    "sagemaker:DescribeTrainingJob", "sagemaker:DescribeProcessingJob", "sagemaker:DescribeModel",
    "sagemaker:DescribeModelPackageGroup", "sagemaker:DescribeModelPackage", "sagemaker:DescribePipeline",
    "sagemaker:GetPipelineDefinition", "sagemaker:DescribePipelineExecution", "sagemaker:ListPipelineExecutionSteps",
    "sagemaker:ListPipelineExecutions", "sagemaker:DescribeEndpoint", "sagemaker:DescribeEndpointConfig",
    "sagemaker:DescribeFeatureGroup", "sagemaker:ListTags", "sagemaker:ListModelPackages"
  ]
  sm_discovery_actions = [
    "sagemaker:ListTrainingJobs", "sagemaker:ListProcessingJobs", "sagemaker:ListModels",
    "sagemaker:ListModelPackageGroups", "sagemaker:ListPipelines", "sagemaker:ListEndpoints", "sagemaker:ListEndpointConfigs",
    "sagemaker:ListFeatureGroups"
  ]
  # SageMaker log groups are shared by the service, so only project-prefixed
  # streams can be read there. No whole-group FilterLogEvents on those groups.
  sm_log_groups  = ["/aws/sagemaker/TrainingJobs", "/aws/sagemaker/ProcessingJobs", "/aws/sagemaker/Endpoints/panic-*"]
  app_log_groups = ["/aws/lambda/panic-*", "/aws/vendedlogs/states/panic-*", "/panic/app/*", "/panic/api/*"]
  owned_log_groups = {
    lead_ml = ["/panic/ml/*"]
    mlops   = concat(["/panic/*"], local.app_log_groups, ["/aws/sagemaker/Endpoints/panic-*"])
    app     = local.app_log_groups
  }

  storage_policies = {
    for role in keys(local.role_names) : "${role}/storage" => [
      {
        Sid = "BucketLocation", Effect = "Allow", Action = ["s3:GetBucketLocation"], Resource = [local.bucket]
      },
      {
        Sid       = "ListAssignedPrefixes", Effect = "Allow", Action = ["s3:ListBucket"], Resource = [local.bucket]
        Condition = { StringLike = { "s3:prefix" = flatten([for prefix in local.read_prefixes[role] : ["${prefix}/", "${prefix}/*"]]) } }
      },
      {
        Sid      = "ReadAssignedObjects", Effect = "Allow", Action = ["s3:GetObject"],
        Resource = [for prefix in local.read_prefixes[role] : "${local.bucket}/${prefix}/*"]
      },
      {
        Sid      = "WriteAssignedObjects", Effect = "Allow", Action = ["s3:PutObject", "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts"],
        Resource = [for prefix in local.write_prefixes[role] : "${local.bucket}/${prefix}/*"]
      }
    ]
  }

  observation_policies = {
    for role in keys(local.role_names) : "${role}/observe" => concat([
      {
        Sid      = "ReadProjectDashboards", Effect = "Allow", Action = ["cloudwatch:GetDashboard"],
        Resource = ["arn:aws:cloudwatch::${var.host_account_id}:dashboard/panic-*"]
      },
      {
        Sid      = "ReadProjectAlarms", Effect = "Allow", Action = ["cloudwatch:DescribeAlarms", "cloudwatch:DescribeAlarmHistory", "cloudwatch:ListTagsForResource"],
        Resource = ["${local.cw}:alarm:panic-*"]
      },
      {
        Sid      = "ReadOwnedLogGroups", Effect = "Allow", Action = ["logs:DescribeLogStreams", "logs:FilterLogEvents"],
        Resource = [for group in local.owned_log_groups[role] : "${local.logs}:log-group:${group}:*"]
      },
      {
        Sid      = "ReadOwnedLogStreams", Effect = "Allow", Action = ["logs:GetLogEvents"],
        Resource = [for group in local.owned_log_groups[role] : "${local.logs}:log-group:${group}:log-stream:*"]
      }
      ], role != "app" ? [
      {
        Sid      = "DiscoverSageMakerStreams", Effect = "Allow", Action = ["logs:DescribeLogStreams"],
        Resource = [for group in local.sm_log_groups : "${local.logs}:log-group:${group}:*"]
      },
      {
        Sid = "ReadProjectSageMakerStreams", Effect = "Allow", Action = ["logs:GetLogEvents"],
        Resource = concat(
          [for group in slice(local.sm_log_groups, 0, 2) : "${local.logs}:log-group:${group}:log-stream:panic-*"],
          ["${local.logs}:log-group:/aws/sagemaker/Endpoints/panic-*:log-stream:*"]
        )
      }
      ] : [], var.allow_account_discovery ? [
      {
        Sid      = "RegionalDiscoveryAndMetrics", Effect = "Allow",
        Action   = ["logs:DescribeLogGroups", "cloudwatch:ListMetrics", "cloudwatch:GetMetricData", "cloudwatch:GetMetricStatistics", "cloudwatch:ListDashboards"],
        Resource = ["*"], Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
      }
    ] : [])
  }

  ml_read_policies = {
    for role in ["lead_ml", "mlops"] : "${role}/ml-read" => concat([
      { Sid = "ReadProjectML", Effect = "Allow", Action = local.sm_read_actions, Resource = local.sm_read_resources }
      ], var.allow_account_discovery ? [
      {
        Sid      = "DiscoverRegionalMLResources", Effect = "Allow", Action = local.sm_discovery_actions,
        Resource = ["*"], Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
      }
    ] : [])
  }

  execution_policies = {
    for owner in keys(local.role_names) : "${owner}/pass-roles" => concat([{
      Sid      = "ManageAssignedExecutionRolePolicies", Effect = "Allow",
      Action   = ["iam:GetRole", "iam:GetRolePolicy", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", "iam:PutRolePolicy", "iam:DeleteRolePolicy"],
      Resource = [for role in values(var.execution_roles) : role.arn if role.owner == owner]
      }], [
      for key, role in var.execution_roles : {
        Sid       = "Pass${replace(key, "/[^A-Za-z0-9]/", "")}"
        Effect    = "Allow"
        Action    = ["iam:PassRole"]
        Resource  = [role.arn]
        Condition = { StringEquals = { "iam:PassedToService" = role.service } }
      } if role.owner == owner
    ]) if anytrue([for role in values(var.execution_roles) : role.owner == owner])
  }

  policy_statements = merge(local.storage_policies, local.observation_policies, local.ml_read_policies, local.execution_policies, local.development_policies, {
    "lead_ml/operate" = [
      {
        Sid      = "RunPipeline", Effect = "Allow", Action = ["sagemaker:StartPipelineExecution", "sagemaker:StopPipelineExecution"],
        Resource = ["${local.sm}:pipeline/panic-*", "${local.sm}:pipeline/panic-*/execution/*"]
      },
      {
        Sid      = "ApproveModelPackages", Effect = "Allow", Action = ["sagemaker:UpdateModelPackage"],
        Resource = ["${local.sm}:model-package/panic-*/*"]
      }
    ]
    "mlops/ml-build" = [
      {
        Sid = "ManagePipelinesAndJobs", Effect = "Allow",
        Action = [
          "sagemaker:CreatePipeline", "sagemaker:UpdatePipeline", "sagemaker:DeletePipeline", "sagemaker:StartPipelineExecution", "sagemaker:StopPipelineExecution",
          "sagemaker:CreateTrainingJob", "sagemaker:StopTrainingJob", "sagemaker:CreateProcessingJob", "sagemaker:StopProcessingJob"
        ],
        Resource = [for kind in ["pipeline", "training-job", "processing-job"] : "${local.sm}:${kind}/panic-*"]
      },
      {
        Sid = "ManageModelGroupsAndServing", Effect = "Allow",
        Action = [
          "sagemaker:CreateModelPackageGroup", "sagemaker:CreateModel", "sagemaker:DeleteModel",
          "sagemaker:CreateEndpointConfig", "sagemaker:DeleteEndpointConfig", "sagemaker:CreateEndpoint", "sagemaker:UpdateEndpoint", "sagemaker:DeleteEndpoint",
          "sagemaker:InvokeEndpoint", "sagemaker:AddTags", "sagemaker:DeleteTags"
        ], Resource = local.sm_read_resources
      },
      {
        Sid       = "RegisterPendingModels", Effect = "Allow", Action = ["sagemaker:CreateModelPackage"],
        Resource  = ["${local.sm}:model-package/panic-*/*"],
        Condition = { StringEquals = { "sagemaker:ModelApprovalStatus" = "PendingManualApproval" } }
      }
    ]
    "mlops/monitor" = [
      {
        Sid      = "ManageProjectDashboards", Effect = "Allow", Action = ["cloudwatch:PutDashboard", "cloudwatch:DeleteDashboards"],
        Resource = ["arn:aws:cloudwatch::${var.host_account_id}:dashboard/panic-*"]
      },
      {
        Sid      = "ManageProjectAlarms", Effect = "Allow",
        Action   = ["cloudwatch:PutMetricAlarm", "cloudwatch:DeleteAlarms", "cloudwatch:EnableAlarmActions", "cloudwatch:DisableAlarmActions", "cloudwatch:TagResource", "cloudwatch:UntagResource"],
        Resource = ["${local.cw}:alarm:panic-*"]
      },
      {
        Sid       = "WritePANICMetrics", Effect = "Allow", Action = ["cloudwatch:PutMetricData"], Resource = ["*"],
        Condition = { StringEquals = { "cloudwatch:namespace" = "PANIC", "aws:RequestedRegion" = var.region } }
      },
      {
        Sid      = "ManageMonitoringLogGroups", Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:PutRetentionPolicy", "logs:TagResource", "logs:UntagResource", "logs:ListTagsForResource"],
        Resource = ["${local.logs}:log-group:/panic/*", "${local.logs}:log-group:/panic/*:*"]
      }
    ]
    "app/functions" = [
      {
        Sid = "ManageAppFunctions", Effect = "Allow",
        Action = [
          "lambda:CreateFunction", "lambda:GetFunction", "lambda:GetFunctionConfiguration", "lambda:UpdateFunctionCode", "lambda:UpdateFunctionConfiguration", "lambda:DeleteFunction",
          "lambda:PublishVersion", "lambda:ListVersionsByFunction", "lambda:CreateAlias", "lambda:UpdateAlias", "lambda:DeleteAlias", "lambda:GetAlias", "lambda:ListAliases",
          "lambda:GetPolicy", "lambda:RemovePermission", "lambda:InvokeFunction", "lambda:TagResource", "lambda:UntagResource", "lambda:ListTags",
          "lambda:GetFunctionConcurrency", "lambda:PutFunctionConcurrency", "lambda:DeleteFunctionConcurrency"
        ], Resource = ["arn:aws:lambda:${local.account_region}:function:panic-*", "arn:aws:lambda:${local.account_region}:function:panic-*:*"]
      },
      {
        Sid       = "AllowAPIGatewayInvocation", Effect = "Allow", Action = ["lambda:AddPermission"],
        Resource  = ["arn:aws:lambda:${local.account_region}:function:panic-*", "arn:aws:lambda:${local.account_region}:function:panic-*:*"],
        Condition = { StringEquals = { "lambda:Principal" = "apigateway.amazonaws.com" } }
      },
      {
        Sid      = "ReadOnlineFeaturesAndScore", Effect = "Allow", Action = ["sagemaker:DescribeFeatureGroup", "sagemaker:GetRecord", "sagemaker:BatchGetRecord", "sagemaker:InvokeEndpoint", "sagemaker:DescribeEndpoint"],
        Resource = ["${local.sm}:feature-group/panic-*", "${local.sm}:endpoint/panic-*"]
      },
      {
        Sid      = "ManageAppLogGroups", Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:PutRetentionPolicy", "logs:TagResource", "logs:UntagResource", "logs:ListTagsForResource"],
        Resource = flatten([for group in local.app_log_groups : ["${local.logs}:log-group:${group}", "${local.logs}:log-group:${group}:*"]])
      }
    ]
    "app/workflows-data" = [
      {
        Sid      = "ManageProjectWorkflows", Effect = "Allow",
        Action   = ["states:CreateStateMachine", "states:UpdateStateMachine", "states:DeleteStateMachine", "states:DescribeStateMachine", "states:DescribeStateMachineForExecution", "states:StartExecution", "states:StopExecution", "states:DescribeExecution", "states:GetExecutionHistory", "states:ListExecutions", "states:TagResource", "states:UntagResource", "states:ListTagsForResource"],
        Resource = ["arn:aws:states:${local.account_region}:stateMachine:panic-*", "arn:aws:states:${local.account_region}:execution:panic-*:*"]
      },
      {
        Sid      = "ManageAppTablesWithoutDeleting", Effect = "Allow",
        Action   = ["dynamodb:CreateTable", "dynamodb:UpdateTable", "dynamodb:DescribeTable", "dynamodb:DescribeContinuousBackups", "dynamodb:UpdateContinuousBackups", "dynamodb:DescribeTimeToLive", "dynamodb:UpdateTimeToLive", "dynamodb:ListTagsOfResource", "dynamodb:TagResource", "dynamodb:UntagResource", "dynamodb:GetItem", "dynamodb:BatchGetItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:PutItem", "dynamodb:UpdateItem"],
        Resource = ["arn:aws:dynamodb:${local.account_region}:table/panic-*", "arn:aws:dynamodb:${local.account_region}:table/panic-*/index/*"]
      },
      {
        Sid      = "ManageProjectAlertTopics", Effect = "Allow",
        Action   = ["sns:CreateTopic", "sns:GetTopicAttributes", "sns:ListTagsForResource", "sns:TagResource", "sns:UntagResource", "sns:Publish", "sns:Subscribe", "sns:ListSubscriptionsByTopic"],
        Resource = ["arn:aws:sns:${local.account_region}:panic-*"]
      }
    ]
    }, length(var.api_gateway_api_ids) > 0 ? {
    "app/api" = [
      {
        Sid      = "ManageAssignedAPIs", Effect = "Allow", Action = ["apigateway:GET", "apigateway:POST", "apigateway:PUT", "apigateway:PATCH"],
        Resource = flatten([for id in var.api_gateway_api_ids : [for type in ["apis", "restapis"] : ["arn:aws:apigateway:${var.region}::/${type}/${id}", "arn:aws:apigateway:${var.region}::/${type}/${id}/*"]]])
      },
      {
        Sid      = "DeleteAPIChildrenOnly", Effect = "Allow", Action = ["apigateway:DELETE"],
        Resource = flatten([for id in var.api_gateway_api_ids : [for type in ["apis", "restapis"] : "arn:aws:apigateway:${var.region}::/${type}/${id}/*"]])
      },
      {
        Sid      = "CallAssignedAPIs", Effect = "Allow", Action = ["execute-api:Invoke"],
        Resource = [for id in var.api_gateway_api_ids : "arn:aws:execute-api:${local.account_region}:${id}/*"]
      }
    ]
    } : {}, var.allow_account_discovery ? {
    "app/discovery" = [
      {
        Sid      = "DiscoverRegionalAppResources", Effect = "Allow", Action = ["lambda:ListFunctions", "states:ListStateMachines", "dynamodb:ListTables", "sns:ListTopics"],
        Resource = ["*"], Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
      }
    ]
  } : {})
}
