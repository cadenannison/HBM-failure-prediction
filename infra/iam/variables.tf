variable "host_account_id" {
  description = "Account hosting all project roles and workloads."
  type        = string
  default     = "278634873542"
  validation {
    condition     = can(regex("^[0-9]{12}$", var.host_account_id))
    error_message = "Use a 12-digit AWS account ID."
  }
}

variable "region" {
  description = "Deployment Region in the standard AWS partition."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^(us|eu|ap|ca|sa|me|af|il|mx)-(central|north|south|east|west|northeast|northwest|southeast|southwest)-[0-9]+$", var.region))
    error_message = "Use a Region in the standard aws partition."
  }
}

variable "teammate_user_names" {
  description = "IAM users created in the hosting account: lead_ml (RJ), mlops (Caden), app (Joe). Users receive self-service credentials and MFA-protected access to their assigned project role."
  type        = map(string)
  default = {
    lead_ml = "panic-rj"
    mlops   = "panic-caden"
    app     = "panic-joe"
  }
  validation {
    condition     = toset(keys(var.teammate_user_names)) == toset(["lead_ml", "mlops", "app"])
    error_message = "Provide exactly the lead_ml, mlops, and app keys."
  }
  validation {
    condition = alltrue([
      for name in values(var.teammate_user_names) :
      can(regex("^panic-[a-z0-9-]{1,58}$", name))
    ])
    error_message = "Use IAM usernames beginning panic-, with lowercase letters, digits or hyphens, at most 64 characters and no paths/wildcards."
  }
  validation {
    condition     = length(distinct(values(var.teammate_user_names))) == length(var.teammate_user_names)
    error_message = "Assign a different IAM user to each role."
  }
  validation {
    condition = alltrue(flatten([for name in values(var.teammate_user_names) : [
      for other in values(var.teammate_user_names) : name == other || !startswith(other, "${name}-")
    ]]))
    error_message = "Usernames must not overlap MFA name prefixes (for example panic-rj and panic-rj-other)."
  }
}

variable "data_bucket_name" {
  description = "Existing/platform-managed project data bucket. This stack never creates or configures a bucket."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.data_bucket_name))
    error_message = "Use a bucket name without ARN syntax, wildcards, or a path."
  }
}

variable "api_gateway_api_ids" {
  description = "Platform-created HTTP or REST API IDs Joe may manage. Empty grants no API Gateway access."
  type        = set(string)
  default     = []
  validation {
    condition     = alltrue([for id in var.api_gateway_api_ids : can(regex("^[a-z0-9]+$", id))])
    error_message = "Use exact API IDs without paths or wildcards."
  }
}

variable "execution_roles" {
  description = "Existing service roles and their verified platform-owned permission boundaries. Each role has one owner (lead_ml, mlops, app) who can edit its inline permissions and pass it to its intended service."
  type = map(object({
    owner                    = string
    arn                      = string
    service                  = string
    permissions_boundary_arn = string
  }))
  default = {}
  validation {
    condition = alltrue([
      for role in values(var.execution_roles) :
      can(regex("^arn:aws:iam::${var.host_account_id}:role/panic-execution/[A-Za-z0-9+=,.@_-]+$", role.arn)) &&
      contains(["lead_ml", "mlops", "app"], role.owner) &&
      can(regex("^arn:aws:iam::${var.host_account_id}:policy/panic-boundaries/[A-Za-z0-9+=,.@_-]+$", role.permissions_boundary_arn)) &&
      ((contains(["lead_ml", "mlops"], role.owner) && role.service == "sagemaker.amazonaws.com") ||
      (role.owner == "app" && contains(["lambda.amazonaws.com", "states.amazonaws.com", "apigateway.amazonaws.com"], role.service)))
    ])
    error_message = "Use exact host-account /panic-execution/ role ARNs, /panic-boundaries/ policy ARNs, and a service appropriate for the owner."
  }
  validation {
    condition     = length(distinct([for role in values(var.execution_roles) : role.arn])) == length(var.execution_roles)
    error_message = "An execution role can have only one assignment; use separate roles for different owners."
  }
}

variable "allow_account_discovery" {
  description = "Permit documented read/list operations that cannot be restricted to project ARNs, including account-wide metrics reads. Disable for stricter API-only use."
  type        = bool
  default     = true
}

variable "studio_workspaces" {
  description = "Platform-provisioned Studio domains/profiles for RJ and/or Caden. Space prefixes must be unique per owner. Empty grants no Studio access."
  type = map(object({
    domain_id         = string
    user_profile_name = string
    space_name_prefix = string
  }))
  default = {}
  validation {
    condition = alltrue([for owner, workspace in var.studio_workspaces :
      contains(["lead_ml", "mlops"], owner) &&
      can(regex("^d-[a-z0-9]+$", workspace.domain_id)) &&
      can(regex("^panic-[a-z0-9-]+$", workspace.user_profile_name)) &&
      can(regex("^panic-[a-z0-9]+-$", workspace.space_name_prefix))
    ])
    error_message = "Studio assignments require lead_ml/mlops, an exact domain ID, a panic- profile, and a prefix such as panic-rj-."
  }
  validation {
    condition = length(distinct([for workspace in values(var.studio_workspaces) :
      "${workspace.domain_id}/${workspace.space_name_prefix}"
    ])) == length(var.studio_workspaces)
    error_message = "Do not share a Studio space prefix across owners in one domain."
  }
  validation {
    condition = length(distinct([for workspace in values(var.studio_workspaces) :
      "${workspace.domain_id}/${workspace.user_profile_name}"
    ])) == length(var.studio_workspaces)
    error_message = "Each Studio user profile can have only one owner."
  }
}

variable "additional_image_repository_arns" {
  description = "Exact ECR repositories for approved third-party/AWS prebuilt images; runtime ceilings grant pull only. Project repositories are covered by name patterns."
  type        = set(string)
  default     = []
  validation {
    condition = alltrue([for arn in var.additional_image_repository_arns :
      can(regex("^arn:aws:ecr:${var.region}:[0-9]{12}:repository/[a-z0-9][a-z0-9._/-]*$", arn))
    ])
    error_message = "Use exact ECR repository ARNs in the deployment Region, without wildcard resources."
  }
}
