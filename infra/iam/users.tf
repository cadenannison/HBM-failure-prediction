resource "aws_iam_user" "teammate" {
  for_each      = var.teammate_user_names
  name          = each.value
  path          = "/panic-team/"
  force_destroy = false
  tags          = { Owner = each.key }
}

locals {
  user_policy_documents = { for owner, name in var.teammate_user_names : owner => jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "ViewCredentialSetup", Effect = "Allow", Action = ["iam:GetAccountPasswordPolicy", "iam:ListVirtualMFADevices"], Resource = ["*"]
      },
      {
        # Permit first-login password replacement and MFA enrollment without
        # granting any project-resource access before MFA is configured.
        Sid      = "OwnPasswordAndMFAEnrollment", Effect = "Allow",
        Action   = ["iam:GetUser", "iam:ChangePassword", "iam:GetMFADevice", "iam:ListMFADevices", "iam:EnableMFADevice", "iam:ResyncMFADevice"],
        Resource = [local.user_arns[owner]]
      },
      {
        Sid      = "OwnVirtualMFADevices", Effect = "Allow", Action = ["iam:CreateVirtualMFADevice", "iam:DeleteVirtualMFADevice"],
        Resource = ["arn:aws:iam::${var.host_account_id}:mfa/${name}", "arn:aws:iam::${var.host_account_id}:mfa/${name}-*"]
      },
      {
        Sid       = "ManageOwnCredentialsAfterMFA", Effect = "Allow",
        Action    = ["iam:DeactivateMFADevice", "iam:CreateAccessKey", "iam:DeleteAccessKey", "iam:ListAccessKeys", "iam:UpdateAccessKey"],
        Resource  = [local.user_arns[owner]],
        Condition = { Bool = { "aws:MultiFactorAuthPresent" = "true" } }
      },
      {
        Sid       = "AssumeAssignedProjectRole", Effect = "Allow", Action = ["sts:AssumeRole"], Resource = [local.role_arns[owner]],
        Condition = { Bool = { "aws:MultiFactorAuthPresent" = "true" } }
      }
    ]
  }) }
}

resource "aws_iam_user_policy" "self_service" {
  for_each = var.teammate_user_names
  name     = "panic-self-service-and-assume-role"
  user     = aws_iam_user.teammate[each.key].name
  policy   = local.user_policy_documents[each.key]
}

# Console passwords are set privately by the administrator after apply, with
# password reset required. Do not add login-profile/access-key resources here:
# generated credentials would be persisted in Terraform state. Teammates enroll
# their own MFA and can create their own CLI key only in an MFA-authenticated
# user session. All project actions require the separate MFA-protected role.
