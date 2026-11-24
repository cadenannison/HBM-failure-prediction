output "role_arns" {
  description = "Project roles in the hosting account."
  value       = local.role_arns
}

output "switch_role_urls" {
  description = "Each teammate signs in to their IAM user in the hosting account with MFA before using this link."
  value       = { for key, name in local.role_names : key => "https://signin.aws.amazon.com/switchrole?account=${var.host_account_id}&roleName=${name}&displayName=${name}" }
}

output "teammate_users" {
  description = "Created IAM usernames/ARNs for private console-password setup. No passwords or keys are generated."
  value = { for owner, name in var.teammate_user_names : owner => {
    user_name       = name
    user_arn        = local.user_arns[owner]
    role_arn        = local.role_arns[owner]
    mfa_device_name = "${name}-phone"
  } }
}

output "console_sign_in_url" {
  description = "Shared account sign-in URL; every teammate has their own username, password, and MFA."
  value       = "https://${var.host_account_id}.signin.aws.amazon.com/console/"
}

output "user_policy_documents" {
  description = "Reviewable credential self-service and MFA-protected assigned-role access; no direct project-service grants."
  value       = local.user_policy_documents
}

output "policy_documents" {
  description = "Reviewable destination permission policies, including before apply."
  value       = local.policy_documents
}

output "trust_policies" {
  description = "Reviewable exact-principal, MFA-protected role trust."
  value       = local.trust_policies
}

output "execution_boundary_arns" {
  description = "Platform foundation attaches the owner's boundary to each service role before assigning it here."
  value       = local.execution_boundary_arns
}

output "execution_boundary_documents" {
  description = "Reviewable runtime ceilings for planned data, ML, container, and app dependencies."
  value       = local.execution_boundary_documents
}
