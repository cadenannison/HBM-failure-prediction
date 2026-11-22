locals {
  role_names = {
    lead_ml = "panic-lead-ml"
    mlops   = "panic-mlops"
    app     = "panic-app"
  }
  role_arns = { for key, name in local.role_names : key => "arn:aws:iam::${var.host_account_id}:role/${name}" }
  trust_policies = {
    for key, principal in var.source_user_arns : key => jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid       = "AssignedExternalUserWithMFA"
        Effect    = "Allow"
        Principal = { AWS = principal }
        Action    = "sts:AssumeRole"
        Condition = { Bool = { "aws:MultiFactorAuthPresent" = "true" } }
      }]
    })
  }
  # Each bundle is a separate managed policy to stay within IAM's 6,144-byte limit.
  policy_documents = { for key, statements in local.policy_statements : key => jsonencode({
    Version   = "2012-10-17"
    Statement = statements
  }) }
}

# Read the actual role before granting permission to edit it. Merely naming a
# boundary in tfvars is not sufficient: foundation must attach it first.
data "aws_iam_role" "execution" {
  for_each = {
    for key, role in var.execution_roles : key => role
    if can(regex("^arn:aws:iam::${var.host_account_id}:role/panic-execution/[A-Za-z0-9+=,.@_-]+$", role.arn)) &&
    ((contains(["lead_ml", "mlops"], role.owner) && role.service == "sagemaker.amazonaws.com") ||
    (role.owner == "app" && contains(["lambda.amazonaws.com", "states.amazonaws.com", "apigateway.amazonaws.com"], role.service)))
  }
  name = element(reverse(split("/", each.value.arn)), 0)

  lifecycle {
    postcondition {
      condition = (self.arn == each.value.arn && self.permissions_boundary == each.value.permissions_boundary_arn &&
      self.permissions_boundary == local.execution_boundary_arns[each.value.owner])
      error_message = "The exact execution role must already have its declared platform-owned permissions boundary attached before self-service edits can be granted."
    }
  }
}

resource "aws_iam_role" "teammate" {
  for_each             = local.role_names
  name                 = each.value
  description          = "PANIC ${each.key}: external IAM user with MFA; project-scoped access"
  assume_role_policy   = local.trust_policies[each.key]
  max_session_duration = 3600
  tags                 = { Owner = each.key }

  lifecycle {
    precondition {
      condition     = length([for key in keys(local.policy_documents) : key if startswith(key, "${each.key}/")]) <= 10
      error_message = "This role exceeds the default 10 managed-policy attachments; regroup bundles or deliberately increase the IAM quota."
    }
  }
}

resource "aws_iam_policy" "project" {
  for_each    = local.policy_documents
  name        = "panic-${replace(replace(each.key, "_", "-"), "/", "-")}"
  description = "PANIC scoped permissions: ${each.key}"
  policy      = each.value

  lifecycle {
    precondition {
      condition     = length(each.value) <= 6144
      error_message = "Split this policy bundle: IAM managed policies allow at most 6,144 non-whitespace characters."
    }
  }
}

resource "aws_iam_role_policy_attachment" "project" {
  for_each   = local.policy_documents
  role       = aws_iam_role.teammate[split("/", each.key)[0]].name
  policy_arn = aws_iam_policy.project[each.key].arn
  # No edit/PassRole attachments are applied until all execution-role checks pass.
  depends_on = [data.aws_iam_role.execution, aws_iam_policy.execution_boundary]
}
