locals {
  mlflow_servers = ["${local.sm}:mlflow-tracking-server/panic-*"]
  ml_job_resources = [for kind in ["training-job", "processing-job", "transform-job", "hyper-parameter-tuning-job"] :
    "${local.sm}:${kind}/panic-*"
  ]
  ml_job_actions = [
    "sagemaker:CreateTrainingJob", "sagemaker:StopTrainingJob", "sagemaker:DescribeTrainingJob",
    "sagemaker:CreateProcessingJob", "sagemaker:StopProcessingJob", "sagemaker:DescribeProcessingJob",
    "sagemaker:CreateTransformJob", "sagemaker:StopTransformJob", "sagemaker:DescribeTransformJob",
    "sagemaker:CreateHyperParameterTuningJob", "sagemaker:StopHyperParameterTuningJob", "sagemaker:DescribeHyperParameterTuningJob",
    "sagemaker:ListTrainingJobsForHyperParameterTuningJob", "sagemaker:AddTags", "sagemaker:DeleteTags", "sagemaker:ListTags"
  ]
  image_repositories = {
    lead_ml = ["arn:aws:ecr:${local.account_region}:repository/panic-ml-*"]
    mlops   = ["arn:aws:ecr:${local.account_region}:repository/panic-ml-*"]
    app     = ["arn:aws:ecr:${local.account_region}:repository/panic-app-*"]
  }
  image_pull_actions = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer", "ecr:BatchCheckLayerAvailability"]
  image_manage_actions = concat(local.image_pull_actions, [
    "ecr:CreateRepository", "ecr:DeleteRepository", "ecr:DescribeRepositories", "ecr:DescribeImages", "ecr:ListImages",
    "ecr:InitiateLayerUpload", "ecr:UploadLayerPart", "ecr:CompleteLayerUpload", "ecr:PutImage", "ecr:BatchDeleteImage",
    "ecr:GetLifecyclePolicy", "ecr:PutLifecyclePolicy", "ecr:DeleteLifecyclePolicy", "ecr:GetRepositoryPolicy", "ecr:SetRepositoryPolicy", "ecr:DeleteRepositoryPolicy",
    "ecr:PutImageTagMutability", "ecr:PutImageScanningConfiguration", "ecr:StartImageScan", "ecr:DescribeImageScanFindings",
    "ecr:TagResource", "ecr:UntagResource", "ecr:ListTagsForResource"
  ])
  workspace_resources = {
    for owner, workspace in var.studio_workspaces : owner => {
      domain  = "${local.sm}:domain/${workspace.domain_id}"
      profile = "${local.sm}:user-profile/${workspace.domain_id}/${workspace.user_profile_name}"
      spaces  = "${local.sm}:space/${workspace.domain_id}/${workspace.space_name_prefix}*"
      apps = [
        "${local.sm}:app/${workspace.domain_id}/${workspace.user_profile_name}/*/*",
        "${local.sm}:app/${workspace.domain_id}/${workspace.space_name_prefix}*/*/*"
      ]
    }
  }

  development_policies = merge(
    {
      for owner in ["lead_ml", "mlops"] : "${owner}/compute" => concat([
        { Sid = "DevelopProjectMLJobs", Effect = "Allow", Action = local.ml_job_actions, Resource = local.ml_job_resources },
        {
          Sid      = "ReadOnlineFeaturesAndTestModels", Effect = "Allow",
          Action   = ["sagemaker:GetRecord", "sagemaker:BatchGetRecord", "sagemaker:InvokeEndpoint"],
          Resource = ["${local.sm}:feature-group/panic-*", "${local.sm}:endpoint/panic-*"]
        }
        ], var.allow_account_discovery ? [{
          Sid      = "DiscoverJobVariants", Effect = "Allow", Action = ["sagemaker:ListTransformJobs", "sagemaker:ListHyperParameterTuningJobs"],
          Resource = ["*"], Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
      }] : [])
    },
    {
      for owner in ["lead_ml", "mlops"] : "${owner}/mlflow" => concat([
        {
          # Deliberately permit future MLflow experiment/run APIs on project
          # tracking servers. This does not grant sagemaker:* control-plane APIs.
          Sid = "UseProjectMLflow", Effect = "Allow", Action = ["sagemaker-mlflow:*"], Resource = local.mlflow_servers
        },
        {
          Sid    = "OpenProjectTrackingServer", Effect = "Allow",
          Action = ["sagemaker:DescribeMlflowTrackingServer", "sagemaker:CreatePresignedMlflowTrackingServerUrl"], Resource = local.mlflow_servers
        },
        {
          # AccessUI has no resource-level scope; data-plane requests and URL
          # creation still require the named tracking-server permissions above.
          Sid      = "MLflowUIAuthentication", Effect = "Allow", Action = ["sagemaker-mlflow:AccessUI"],
          Resource = ["*"], Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
        }
        ], owner == "mlops" ? [{
          Sid      = "ManageProjectTrackingServers", Effect = "Allow",
          Action   = ["sagemaker:CreateMlflowTrackingServer", "sagemaker:UpdateMlflowTrackingServer", "sagemaker:StartMlflowTrackingServer", "sagemaker:StopMlflowTrackingServer", "sagemaker:DeleteMlflowTrackingServer", "sagemaker:AddTags", "sagemaker:DeleteTags", "sagemaker:ListTags"],
          Resource = local.mlflow_servers
          }] : [], var.allow_account_discovery ? [{
          Sid      = "DiscoverTrackingServers", Effect = "Allow", Action = ["sagemaker:ListMlflowTrackingServers"],
          Resource = ["*"], Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
      }] : [])
    },
    {
      for owner in keys(local.role_names) : "${owner}/images" => [
        {
          Sid      = "AuthenticateContainerRegistry", Effect = "Allow", Action = ["ecr:GetAuthorizationToken"],
          Resource = ["*"], Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
        },
        {
          Sid      = "ProjectContainerImages", Effect = "Allow",
          Action   = owner == "lead_ml" ? concat(local.image_pull_actions, ["ecr:DescribeRepositories", "ecr:DescribeImages", "ecr:ListImages"]) : local.image_manage_actions,
          Resource = local.image_repositories[owner]
        }
      ]
    },
    {
      for owner, workspace in var.studio_workspaces : "${owner}/studio" => concat([
        {
          Sid      = "OpenAssignedStudioProfile", Effect = "Allow", Action = ["sagemaker:CreatePresignedDomainUrl", "sagemaker:DescribeUserProfile"],
          Resource = [local.workspace_resources[owner].profile]
        },
        {
          Sid = "ReadAssignedDomain", Effect = "Allow", Action = ["sagemaker:DescribeDomain"], Resource = [local.workspace_resources[owner].domain]
        },
        {
          Sid      = "ManageAssignedStudioApps", Effect = "Allow", Action = ["sagemaker:CreateApp", "sagemaker:DescribeApp", "sagemaker:DeleteApp", "sagemaker:AddTags", "sagemaker:ListTags"],
          Resource = local.workspace_resources[owner].apps
        },
        {
          Sid      = "CreateOwnedPrivateSpaces", Effect = "Allow", Action = ["sagemaker:CreateSpace", "sagemaker:UpdateSpace"],
          Resource = [local.workspace_resources[owner].spaces],
          Condition = { StringEquals = {
            "sagemaker:OwnerUserProfileArn" = local.workspace_resources[owner].profile,
            "sagemaker:SpaceSharingType"    = "Private"
          } }
        },
        {
          Sid      = "ManageOwnedSpaces", Effect = "Allow", Action = ["sagemaker:DescribeSpace", "sagemaker:DeleteSpace", "sagemaker:AddTags", "sagemaker:ListTags"],
          Resource = [local.workspace_resources[owner].spaces]
        }
        ], var.allow_account_discovery ? [{
          Sid      = "DiscoverStudioResources", Effect = "Allow", Action = ["sagemaker:ListDomains", "sagemaker:ListUserProfiles", "sagemaker:ListApps", "sagemaker:ListSpaces"],
          Resource = ["*"], Condition = { StringEquals = { "aws:RequestedRegion" = var.region } }
      }] : [])
    }
  )
}
