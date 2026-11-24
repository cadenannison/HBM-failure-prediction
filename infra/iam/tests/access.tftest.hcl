# Mocked plan tests: no credentials, AWS reads, or AWS writes.
mock_provider "aws" {}

variables {
  data_bucket_name = "panic-test-data"
}

run "default_role_boundaries" {
  command = plan

  assert {
    condition = alltrue([for key, policy in output.trust_policies :
      jsondecode(policy).Statement[0].Principal.AWS == "arn:aws:iam::${var.host_account_id}:user/panic-team/${var.teammate_user_names[key]}" &&
      jsondecode(policy).Statement[0].Condition.Bool["aws:MultiFactorAuthPresent"] == "true"
    ])
    error_message = "Every role must trust only its assigned host-account user and require MFA."
  }
  assert {
    condition = alltrue(flatten([for document in values(output.policy_documents) : [
      for statement in jsondecode(document).Statement : alltrue([
        for action in statement.Action : (!strcontains(action, "*") ||
        (action == "sagemaker-mlflow:*" && statement.Resource == ["arn:aws:sagemaker:${var.region}:${var.host_account_id}:mlflow-tracking-server/panic-*"])) &&
        !startswith(action, "iam:") && !startswith(action, "sts:")
      ])
    ]]))
    error_message = "Human roles must not grant IAM administration/role chaining; wildcard actions are limited to project MLflow data APIs."
  }
  assert {
    condition = alltrue([for key, document in output.policy_documents :
      !strcontains(document, "s3:DeleteObject") && !strcontains(document, "s3:DeleteBucket") &&
      !strcontains(document, "dynamodb:DeleteTable") && !strcontains(document, "dynamodb:DeleteItem")
    ])
    error_message = "Shared data and app tables must not be deletable by teammates."
  }
  assert {
    condition = alltrue([for key in ["mlops", "app"] : alltrue([
      for resource in jsondecode(output.policy_documents["${key}/storage"]).Statement[3].Resource :
      !strcontains(resource, "/raw/") && !strcontains(resource, "/features/")
    ])])
    error_message = "Caden and Joe must not gain raw-data or feature-prefix writes."
  }
  assert {
    condition = (
      contains(jsondecode(output.policy_documents["lead_ml/storage"]).Statement[3].Action, "s3:PutObject") &&
      alltrue([for prefix in ["raw", "features"] :
        contains(jsondecode(output.policy_documents["lead_ml/storage"]).Statement[3].Resource, "arn:aws:s3:::${var.data_bucket_name}/${prefix}/*") &&
        contains(jsondecode(output.policy_documents["lead_ml/storage"]).Statement[2].Resource, "arn:aws:s3:::${var.data_bucket_name}/${prefix}/*")
      ]) &&
      alltrue([for resource in jsondecode(output.policy_documents["lead_ml/storage"]).Statement[3].Resource :
        startswith(resource, "arn:aws:s3:::${var.data_bucket_name}/")
      ])
    )
    error_message = "RJ must be able to read/write raw data and features within only the designated project bucket."
  }
  assert {
    condition = (contains(jsondecode(output.policy_documents["lead_ml/operate"]).Statement[1].Action, "sagemaker:UpdateModelPackage") &&
    !anytrue([for key, document in output.policy_documents : strcontains(document, "sagemaker:UpdateModelPackage") if startswith(key, "mlops/")]))
    error_message = "RJ owns model approval; Caden's human role must not update approval status."
  }
  assert {
    condition = (jsondecode(output.policy_documents["mlops/ml-build"]).Statement[2].Condition.StringEquals["sagemaker:ModelApprovalStatus"] == "PendingManualApproval" &&
      contains(jsondecode(output.policy_documents["mlops/ml-build"]).Statement[1].Action, "sagemaker:CreateEndpoint") &&
    contains(jsondecode(output.policy_documents["app/functions"]).Statement[0].Action, "lambda:UpdateFunctionCode"))
    error_message = "Preserve pending registration, endpoint deployment, and app code deployment."
  }
  assert {
    condition     = !contains(keys(output.policy_documents), "app/api") && !anytrue([for key in keys(output.policy_documents) : endswith(key, "/pass-roles")])
    error_message = "No API or execution-role identifiers must mean no corresponding grants."
  }
  assert {
    condition     = alltrue([for name, policy in aws_iam_policy.project : can(regex("^[A-Za-z0-9+=,.@_-]+$", policy.name)) && length(policy.policy) <= 6144])
    error_message = "Generated policy names and sizes must satisfy IAM limits."
  }
  assert {
    condition = (
      contains(jsondecode(output.policy_documents["lead_ml/compute"]).Statement[0].Action, "sagemaker:CreateTrainingJob") &&
      contains(jsondecode(output.policy_documents["mlops/mlflow"]).Statement[3].Action, "sagemaker:CreateMlflowTrackingServer") &&
      contains(jsondecode(output.policy_documents["mlops/images"]).Statement[1].Action, "ecr:PutImage") &&
      contains(jsondecode(output.policy_documents["app/images"]).Statement[1].Action, "ecr:PutImage") &&
      !contains(jsondecode(output.policy_documents["lead_ml/images"]).Statement[1].Action, "ecr:PutImage") &&
      jsondecode(output.policy_documents["app/images"]).Statement[1].Resource == ["arn:aws:ecr:${var.region}:${var.host_account_id}:repository/panic-app-*"]
    )
    error_message = "Development bundles must cover cloud experiments, MLflow operations, and owner-scoped image workflows."
  }
  assert {
    condition = alltrue([for owner, document in output.execution_boundary_documents :
      length(document) <= 6144 && !strcontains(document, "iam:PutRolePolicy") && !strcontains(document, "sts:AssumeRole") &&
      alltrue([for statement in jsondecode(document).Statement :
        !contains(statement.Action, "s3:PutObject") ||
        (owner == "lead_ml" || (!contains(statement.Resource, "arn:aws:s3:::${var.data_bucket_name}/raw/*") && !contains(statement.Resource, "arn:aws:s3:::${var.data_bucket_name}/features/*")))
      ])
    ])
    error_message = "Runtime ceilings must fit IAM limits, preserve data ownership, and exclude runtime IAM policy editing/role assumption."
  }
}

run "assigned_api_and_execution_roles" {
  command = plan
  override_data {
    target = data.aws_iam_role.execution["training"]
    values = {
      arn                  = "arn:aws:iam::278634873542:role/panic-execution/training"
      permissions_boundary = "arn:aws:iam::278634873542:policy/panic-boundaries/mlops"
    }
  }
  override_data {
    target = data.aws_iam_role.execution["scoring"]
    values = {
      arn                  = "arn:aws:iam::278634873542:role/panic-execution/scoring"
      permissions_boundary = "arn:aws:iam::278634873542:policy/panic-boundaries/app"
    }
  }
  override_data {
    target = data.aws_iam_role.execution["rj_training"]
    values = {
      arn                  = "arn:aws:iam::278634873542:role/panic-execution/rj-training"
      permissions_boundary = "arn:aws:iam::278634873542:policy/panic-boundaries/lead-ml"
    }
  }
  variables {
    api_gateway_api_ids = ["abc123"]
    studio_workspaces = {
      lead_ml = { domain_id = "d-test123", user_profile_name = "panic-rj", space_name_prefix = "panic-rj-" }
      mlops   = { domain_id = "d-test123", user_profile_name = "panic-caden", space_name_prefix = "panic-caden-" }
    }
    execution_roles = {
      training = {
        owner                    = "mlops"
        arn                      = "arn:aws:iam::278634873542:role/panic-execution/training"
        service                  = "sagemaker.amazonaws.com"
        permissions_boundary_arn = "arn:aws:iam::278634873542:policy/panic-boundaries/mlops"
      }
      scoring = {
        owner                    = "app"
        arn                      = "arn:aws:iam::278634873542:role/panic-execution/scoring"
        service                  = "lambda.amazonaws.com"
        permissions_boundary_arn = "arn:aws:iam::278634873542:policy/panic-boundaries/app"
      }
      rj_training = {
        owner                    = "lead_ml"
        arn                      = "arn:aws:iam::278634873542:role/panic-execution/rj-training"
        service                  = "sagemaker.amazonaws.com"
        permissions_boundary_arn = "arn:aws:iam::278634873542:policy/panic-boundaries/lead-ml"
      }
    }
  }
  assert {
    condition = (jsondecode(output.policy_documents["app/pass-roles"]).Statement[1].Resource == ["arn:aws:iam::278634873542:role/panic-execution/scoring"] &&
      jsondecode(output.policy_documents["app/pass-roles"]).Statement[1].Condition.StringEquals["iam:PassedToService"] == "lambda.amazonaws.com" &&
    !strcontains(output.policy_documents["app/pass-roles"], "panic-execution/training"))
    error_message = "Joe may pass only his exact service role to its intended service."
  }
  assert {
    condition = alltrue([for owner, name in { lead_ml = "rj-training", mlops = "training", app = "scoring" } :
      jsondecode(output.policy_documents["${owner}/pass-roles"]).Statement[0].Resource == ["arn:aws:iam::278634873542:role/panic-execution/${name}"] &&
      contains(jsondecode(output.policy_documents["${owner}/pass-roles"]).Statement[0].Action, "iam:PutRolePolicy") &&
      contains(jsondecode(output.policy_documents["${owner}/pass-roles"]).Statement[0].Action, "iam:DeleteRolePolicy")
    ])
    error_message = "Each teammate must be able to edit only their assigned execution roles' inline policies."
  }
  assert {
    condition = alltrue(flatten([for document in values(output.policy_documents) : [
      for statement in jsondecode(document).Statement : alltrue([
        for action in statement.Action : !startswith(action, "iam:") || contains([
          "iam:GetRole", "iam:GetRolePolicy", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:PassRole"
        ], action)
      ])
    ]]))
    error_message = "Delegation must not grant trust/boundary changes, managed-policy edits, or human-role administration."
  }
  assert {
    condition = (alltrue([for resource in jsondecode(output.policy_documents["app/api"]).Statement[0].Resource : strcontains(resource, "/abc123")]) &&
    alltrue([for resource in jsondecode(output.policy_documents["app/api"]).Statement[1].Resource : endswith(resource, "/abc123/*")]))
    error_message = "API grants must target assigned IDs; deleting the top-level API remains with platform."
  }
  assert {
    condition = alltrue([for owner in ["lead_ml", "mlops", "app"] :
      length([for key in keys(output.policy_documents) : key if startswith(key, "${owner}/")]) <= 10
    ])
    error_message = "Even with Studio and execution delegation, roles must fit the default 10 managed-policy attachments."
  }
  assert {
    condition = (
      jsondecode(output.policy_documents["lead_ml/studio"]).Statement[0].Resource == ["arn:aws:sagemaker:${var.region}:${var.host_account_id}:user-profile/d-test123/panic-rj"] &&
      !strcontains(output.policy_documents["lead_ml/studio"], "panic-caden") &&
      !strcontains(output.policy_documents["mlops/studio"], "panic-rj") &&
      jsondecode(output.policy_documents["lead_ml/studio"]).Statement[3].Condition.StringEquals["sagemaker:SpaceSharingType"] == "Private"
    )
    error_message = "Studio access must isolate each profile and private-space namespace."
  }
}

run "discovery_can_be_disabled" {
  command = plan
  variables { allow_account_discovery = false }
  assert {
    condition = alltrue(flatten([for document in values(output.policy_documents) : [
      for statement in jsondecode(document).Statement :
      !contains(statement.Resource, "*") || alltrue([for action in statement.Action : contains([
        "cloudwatch:PutMetricData", "ecr:GetAuthorizationToken", "sagemaker-mlflow:AccessUI"
      ], action)])
    ]]))
    error_message = "Strict mode must remove discovery reads; only namespace-scoped metrics and required registry/MLflow authentication remain unscoped."
  }
}

run "reject_duplicate_users" {
  command = plan
  variables {
    teammate_user_names = {
      lead_ml = "panic-rj"
      mlops   = "panic-rj"
      app     = "panic-joe"
    }
  }
  expect_failures = [var.teammate_user_names]
}

run "reject_wildcard_username" {
  command = plan
  variables {
    teammate_user_names = {
      lead_ml = "panic-*"
      mlops   = "panic-caden"
      app     = "panic-joe"
    }
  }
  expect_failures = [var.teammate_user_names]
}

run "local_user_onboarding_is_self_scoped" {
  command = plan
  assert {
    condition = alltrue([for owner, document in output.user_policy_documents :
      contains(jsondecode(document).Statement[1].Action, "iam:ChangePassword") &&
      contains(jsondecode(document).Statement[1].Action, "iam:EnableMFADevice") &&
      jsondecode(document).Statement[1].Resource == ["arn:aws:iam::${var.host_account_id}:user/panic-team/${var.teammate_user_names[owner]}"] &&
      jsondecode(document).Statement[4].Resource == [output.role_arns[owner]] &&
      jsondecode(document).Statement[4].Condition.Bool["aws:MultiFactorAuthPresent"] == "true" &&
      jsondecode(document).Statement[3].Condition.Bool["aws:MultiFactorAuthPresent"] == "true" &&
      alltrue(flatten([for statement in jsondecode(document).Statement : [for action in statement.Action :
        startswith(action, "iam:") || action == "sts:AssumeRole"
      ]]))
    ])
    error_message = "Users need first-login password/MFA setup for themselves, assigned-role-only MFA access, and no direct project-service grants."
  }
  assert {
    condition = alltrue([for owner, document in output.user_policy_documents :
      jsondecode(document).Statement[2].Resource == [
        "arn:aws:iam::${var.host_account_id}:mfa/${var.teammate_user_names[owner]}",
        "arn:aws:iam::${var.host_account_id}:mfa/${var.teammate_user_names[owner]}-*"
      ] &&
      jsondecode(document).Statement[3].Resource == ["arn:aws:iam::${var.host_account_id}:user/panic-team/${var.teammate_user_names[owner]}"] &&
      !strcontains(document, "iam:PutUserPolicy") && !strcontains(document, "iam:AttachUserPolicy") && !strcontains(document, "iam:CreateLoginProfile")
    ])
    error_message = "Credential management must stay within each user's own namespace and exclude permission/password administration."
  }
  assert {
    condition     = length(aws_iam_user.teammate) == 3 && alltrue([for user in values(aws_iam_user.teammate) : user.path == "/panic-team/" && user.force_destroy == false])
    error_message = "Create exactly three project users without force-deleting their credentials."
  }
}

run "reject_overlapping_mfa_namespaces" {
  command = plan
  variables {
    teammate_user_names = {
      lead_ml = "panic-rj"
      mlops   = "panic-rj-other"
      app     = "panic-joe"
    }
  }
  expect_failures = [var.teammate_user_names]
}

run "reject_passing_human_role" {
  command = plan
  variables {
    execution_roles = {
      escalation = {
        owner                    = "app"
        arn                      = "arn:aws:iam::278634873542:role/panic-mlops"
        service                  = "lambda.amazonaws.com"
        permissions_boundary_arn = "arn:aws:iam::278634873542:policy/panic-boundaries/app"
      }
    }
  }
  expect_failures = [var.execution_roles]
}

run "reject_wrong_service_owner" {
  command = plan
  variables {
    execution_roles = {
      training = {
        owner                    = "app"
        arn                      = "arn:aws:iam::278634873542:role/panic-execution/training"
        service                  = "sagemaker.amazonaws.com"
        permissions_boundary_arn = "arn:aws:iam::278634873542:policy/panic-boundaries/app"
      }
    }
  }
  expect_failures = [var.execution_roles]
}

run "reject_execution_role_without_boundary" {
  command = plan
  variables {
    execution_roles = {
      scoring = {
        owner                    = "app"
        arn                      = "arn:aws:iam::278634873542:role/panic-execution/scoring"
        service                  = "lambda.amazonaws.com"
        permissions_boundary_arn = "arn:aws:iam::278634873542:policy/panic-boundaries/app"
      }
    }
  }
  override_data {
    target = data.aws_iam_role.execution["scoring"]
    values = {
      arn                  = "arn:aws:iam::278634873542:role/panic-execution/scoring"
      permissions_boundary = ""
    }
  }
  expect_failures = [data.aws_iam_role.execution["scoring"]]
}

run "reject_execution_role_with_different_boundary" {
  command = plan
  variables {
    execution_roles = {
      scoring = {
        owner                    = "app"
        arn                      = "arn:aws:iam::278634873542:role/panic-execution/scoring"
        service                  = "lambda.amazonaws.com"
        permissions_boundary_arn = "arn:aws:iam::278634873542:policy/panic-boundaries/app"
      }
    }
  }
  override_data {
    target = data.aws_iam_role.execution["scoring"]
    values = {
      arn                  = "arn:aws:iam::278634873542:role/panic-execution/scoring"
      permissions_boundary = "arn:aws:iam::278634873542:policy/panic-boundaries/other"
    }
  }
  expect_failures = [data.aws_iam_role.execution["scoring"]]
}

run "reject_shared_studio_space_namespace" {
  command = plan
  variables {
    studio_workspaces = {
      lead_ml = { domain_id = "d-test123", user_profile_name = "panic-rj", space_name_prefix = "panic-shared-" }
      mlops   = { domain_id = "d-test123", user_profile_name = "panic-caden", space_name_prefix = "panic-shared-" }
    }
  }
  expect_failures = [var.studio_workspaces]
}

run "approved_vendor_images_are_pull_only" {
  command = plan
  variables {
    additional_image_repository_arns = ["arn:aws:ecr:us-east-1:111122223333:repository/vendor-training"]
  }
  assert {
    condition = alltrue([for document in values(output.execution_boundary_documents) :
      length([for statement in jsondecode(document).Statement : statement if
        contains(statement.Resource, "arn:aws:ecr:us-east-1:111122223333:repository/vendor-training") &&
        statement.Action == ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer", "ecr:BatchCheckLayerAvailability"]
      ]) == 1 && !strcontains(document, "ecr:PutImage") && !strcontains(document, "ecr:SetRepositoryPolicy")
    ])
    error_message = "Runtime image access must include approved repositories for pull without adding image push/policy mutation."
  }
}
