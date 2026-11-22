output "role_arns" {
  description = "Project roles in the hosting account."
  value       = local.role_arns
}

output "switch_role_urls" {
  description = "Each teammate signs in to their own IAM user with MFA before using this link."
  value       = { for key, name in local.role_names : key => "https://signin.aws.amazon.com/switchrole?account=${var.host_account_id}&roleName=${name}&displayName=${name}" }
}

output "source_account_policies" {
  description = "Each teammate's source administrator attaches only their assigned policy in their own account. This stack does not modify those accounts."
  value = { for key, arn in local.role_arns : key => jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Resource = arn }]
  }) }
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
