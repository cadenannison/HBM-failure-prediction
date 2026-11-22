# PANIC cross-account IAM

This Terraform stack builds three human project roles in the hosting account, their development permission policies, three platform-owned execution-role permissions boundaries, MFA-protected trust, and outputs for teammate onboarding. It does not create users, passwords, access keys, service execution roles, APIs, buckets, Studio domains/profiles, repositories, or running workloads. Each teammate retains their existing IAM user and MFA in their own account. No apply has been performed.

The default account is `278634873542`, with project resources in `us-east-1`. The provider rejects another account. IAM is global; workload ARNs are limited to the configured account/Region. Source-account policy snippets are outputs for teammates to install themselves; this stack has no credentials for their accounts.

## Permissions to review

| Capability | RJ: `panic-lead-ml` | Caden: `panic-mlops` | Joe: `panic-app` |
|---|---|---|---|
| Data | Read raw/features, experiments/models/evaluations, scoring, monitoring; write raw/features/experiments/evaluations | Read features, experiment/model/evaluation artifacts, pipeline code, scoring/monitoring; write models/evaluations/monitoring/pipeline code | Read app/scoring/evaluation data; write app/scoring data |
| ML | Inspect project ML; create/stop training, processing, transform and tuning jobs; start/stop pipelines; update project model-package approval | Create/update/run/delete project pipelines; create/stop training, processing, transform and tuning jobs; register pending models; create/update/delete endpoints, models/configs | Read online project features, inspect/invoke endpoints |
| Studio | Open assigned profile; manage its apps and private space namespace when configured | Same for Caden's assigned profile/namespace | No Studio access |
| MLflow | Experiment/run/model APIs and UI for `panic-*` tracking servers | Same client access, plus create/update/start/stop/delete `panic-*` tracking servers | No MLflow access |
| ECR images | Pull/read `panic-ml-*` repositories | Create/manage/push/pull/delete `panic-ml-*` repositories/images, including their repository policies | Create/manage/push/pull/delete `panic-app-*` repositories/images, including their repository policies |
| Application | No app mutations | Read app logs for reliability | Manage named app functions, workflows, tables, and alert topics; manage routes/integrations/stages under explicitly assigned API IDs |
| Monitoring | Read project dashboards, alarms, ML log streams | Manage project dashboards, alarms, custom metrics and monitoring log groups | Read project dashboards/alarms and app logs; manage app log retention |
| Execution-role permissions | Inspect, edit inline policies, and pass RJ-owned SageMaker roles | Inspect, edit inline policies, and pass Caden-owned SageMaker roles | Inspect, edit inline policies, and pass Joe-owned Lambda, Step Functions, or API Gateway roles |
| Shared platform, billing | Managed by platform owner | Managed by platform owner | Managed by platform owner |

Every role gets the full defined scope after assumption. The policies use project workload-name patterns, exact API IDs/Studio assignments, and a designated bucket with fixed S3 prefixes. Project naming and prefix patterns cover future resources without enumerating each job, tracking server, image repository, function, or workflow. Most human actions are explicit allowlists; MLflow data-plane actions deliberately use `sagemaker-mlflow:*` on project tracking servers so experiment API changes are covered. Do not use the reserved project names/prefixes for unrelated resources. Tags describe resources but do not enforce this scope. Existing resource policies or additional out-of-band role grants can change effective access; this stack does not claim to enforce a universal account guardrail.

S3 object deletion, DynamoDB table/item deletion, top-level API deletion, SNS topic deletion/attribute administration, human-role administration, networking, and billing administration are absent. Execution-role inline policy management is delegated only to the explicitly assigned owner. RJ can upload new objects and overwrite existing objects under the project's `raw/` and `features/` S3 prefixes; Caden and Joe do not receive those writes. Platform owns resource policies requiring wider authority, SNS delivery subscriptions/cleanup where not covered, and infrastructure teardown. Joe can update app/audit rows, so this is not an immutable audit store. CLI callers use exact prefixes; a console listing at the bucket root is intentionally denied.

`allow_account_discovery=true` permits a small documented set of account-wide reads/listing in the selected Region: ML/app resource names, log-group names, dashboard names, and CloudWatch metric data. These AWS APIs cannot all be limited to project ARNs. Set it to `false` for stricter API access with reduced console/dashboard functionality. Describing streams in SageMaker's shared training/processing groups can expose other stream names, but log contents are limited to `panic-*` streams. CloudWatch metric publishing is separately limited to namespace `PANIC`.

Registry authentication (`ecr:GetAuthorizationToken`) and MLflow UI authentication (`sagemaker-mlflow:AccessUI`) also need `Resource: "*"` and remain enabled in strict mode, with a deployment-Region condition. Repository operations and tracking-server data/URL access are separately scoped. Runtime ceilings also allow Step Functions callback APIs without resource-level ARNs; those APIs require the matching task token in addition to IAM authorization.

## Dependencies and limits

- Collect verified source IAM user ARNs and confirm MFA first. Root, Identity Center sessions, and arbitrary federated roles are not supported by this IAM-user trust configuration.
- Create the project data bucket separately. Data ingestion execution roles write raw/features during normal processing; RJ can also directly upload or replace objects in those S3 prefixes for data preparation and corrections. This S3 grant does not grant SageMaker Feature Store record ingestion or feature-group administration.
- This stack creates platform-owned boundaries at `/panic-boundaries/lead-ml`, `/panic-boundaries/mlops`, and `/panic-boundaries/app`. Foundation creates execution roles separately under `/panic-execution/` and attaches the owner's boundary. Supply exact role ARNs, one owner per role, intended service, and the corresponding `permissions_boundary_arn`. The stack reads the actual role and refuses delegation if its ARN or attached boundary differs from the assignment and generated owner boundary. It does not create roles or attach boundaries to them.
- Each owner can inspect, create, edit, and delete inline permission policies on only their assigned execution roles. The delegated actions are `iam:GetRole`, `iam:GetRolePolicy`, `iam:ListRolePolicies`, `iam:ListAttachedRolePolicies`, `iam:PutRolePolicy`, and `iam:DeleteRolePolicy`, plus service-constrained `iam:PassRole`. They may use the inline JSON policy editor, AWS CLI, or `aws_iam_role_policy` in their component Terraform. IAM role-list discovery is not granted; open the assigned role directly or use its exact name with CLI/Terraform.
- Role creation/deletion, trust changes, managed-policy attachments/version edits, and boundary changes remain with platform. The generated boundaries cover each owner's S3 prefixes, project logs/metrics, approved image pulls, feature lookups, and planned ML/app work. RJ/Caden's runtime ceilings deliberately permit `sagemaker:*` on enumerated project ML resource types; they exclude domain/profile/network administration and feature-group mutations. Caden's ceiling explicitly denies package approval updates and creation of packages not marked pending. Joe's ceiling covers data operations, function/workflow invocation, alerts, and approval callbacks. Boundaries contain no runtime permission-policy editing or general role assumption. They grant nothing on their own: owners write the inline policies their workloads actually need. Changing to an unlisted AWS service still needs a boundary update.
- Keep execution-role inline policy resources in the owner's component Terraform state. Platform manages role existence/trust/boundaries and any base managed policies, without exclusive inline-policy ownership; two states must not manage the same inline policy. Service-role policy editing is not equivalent to changing one's human role. Deploying code can exercise the service role's effective permissions, so review both scopes together.
- `execution_roles={}` grants no execution-role editing or `PassRole`, so operations requiring a service role remain blocked until approved roles are supplied. RJ can still start an existing pipeline without directly receiving that pipeline execution role's permissions; give RJ a separate assigned role when self-service editing is needed. Do not assign the same execution-role ARN to RJ and Caden.
- Create API Gateway APIs with platform Terraform and supply their IDs. `api_gateway_api_ids=[]` grants no API management/invocation access. Joe can configure child resources but cannot create new top-level APIs or delete the platform-owned API. API tagging endpoints, custom domains, and account-wide API logging settings remain with platform.
- Studio permission templates are implemented for IAM-auth SageMaker AI Studio. Populate `studio_workspaces` from platform domain/profile outputs; without assignments no Studio policy is granted. Each owner has an exact profile and a unique `panic-rj-`/`panic-caden-` private-space namespace. This does not provision or manage the shared domain/profile, configure networking/EFS, or cover SageMaker Unified Studio. Studio runtime access comes from its assigned service role and the generated execution boundary.
- Hosted MLflow client/lifecycle and ECR image bundles are implemented up front using the naming contract. No server/repository must be running before preparing the IAM policy. Use an artifact location under a prefix writable by the tracking-server role, such as `models/mlflow/` for Caden's server role. Register MLflow models with names beginning `panic-` so automatic SageMaker registry group names stay within the project scope. This covers MLflow tracking servers, not the newer generated-ID MLflow Apps variant.
- `additional_image_repository_arns` optionally adds exact AWS/vendor prebuilt ECR repositories to runtime pull ceilings. Runtime image policies still need corresponding pull grants. Athena/Glue SQL queries, customer-managed KMS keys, Unified Studio/MLflow Apps, and GitHub OIDC deployment remain separate infrastructure choices. Add their scopes when selected; these broader grants do not allow every possible AWS service.
- Configure Step Functions log-delivery integration and its service execution permissions in the foundation/workload stack. This IAM stack does not grant people account-wide log delivery/resource-policy mutation.
- Caden must register model packages with `ModelApprovalStatus=PendingManualApproval`. RJ can use `UpdateModelPackage`, which can also update metadata; IAM does not isolate an approval-only API field. CI/workflow code must enforce an approved-model-only deployment gate. Since Caden controls model code/endpoints, these human roles alone do not enforce separation against a malicious deployer.
- Budgets/alerts and quotas belong to the foundation; IAM scoping does not impose a dollar spending cap.

## Configure and review

Use Terraform >= 1.9 and an administrator profile for the hosting account. Copy the example locally and replace every placeholder:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
$env:AWS_PROFILE = 'your-host-admin-profile'
terraform init
terraform fmt -check
terraform validate
terraform test
terraform plan -out=iam.tfplan
terraform show iam.tfplan
```

These commands assume this directory is the working directory. `terraform test` uses a mocked AWS provider and performs no AWS reads/writes; it checks trust, escalation boundaries, approval ownership, storage protection, input rejection, and conditional API/PassRole grants. A real `plan` reads the hosting account and needs credentials. Provider downloads require network access. Example source accounts/users are fictitious; never apply them.

After policy review and receiving the real teammate identities, use `terraform apply iam.tfplan` to deploy the reviewed plan. Deployment has not been performed. Local state and variable files are ignored; the dependency lock file should be committed. IAM state has no generated credentials in this design, but still contains account/user identifiers. Move to a restricted remote backend before multiple people administer this stack. Keep its state separate from component states.

After apply, retrieve onboarding details:

```powershell
terraform output role_arns
terraform output switch_role_urls
terraform output source_account_policies
terraform output execution_boundary_arns
```

Each teammate or their source administrator attaches only the returned policy for their own role. They sign into their existing IAM user with MFA, open the Switch Role link, and verify identity. For CLI setup, see the [access plan](../../sources/02-final-project/docs/iam-access-plan.md). You never need their source credentials or MFA codes.

For the initial foundation rollout, first apply this IAM stack with `execution_roles={}` to create human roles and the three boundaries. Foundation then creates the service roles with the returned boundary ARNs. Populate `execution_roles` and any Studio/API assignments, review, and apply the IAM stack again to enable delegation and workspace access. This is an initial dependency sequence, not a new approval for every future resource matching an existing pattern. Boundary changes are applied centrally; owner inline policies stay in their component states. The boundary includes only same-owner assigned `PassRole` targets, so pipelines passing nested job roles need those assignments populated too.

## Before calling access ready

Run IAM Access Analyzer policy validation against the rendered policies, then perform real MFA-protected cross-account assumption tests. Mock Terraform tests validate generated configuration; they do not execute AWS authorization or verify that every application's service dependency is satisfied. Check one positive workflow per role, including RJ uploading/replacing raw and feature objects, and negative tests for another user's role, no MFA, unrelated resources, Caden/Joe raw/feature writes, S3 object deletion, and unapproved PassRole. Use CloudTrail and exact denied API calls to refine any missing dependency.

For human-role or boundary changes, teammates submit a policy pull request or the denied action/resource and task; platform reviews and applies it. For their assigned execution roles' inline policies, teammates can apply changes themselves from component Terraform, within the boundary. To offboard, remove cross-account trust and revoke active sessions before deleting roles. Removing trust alone does not invalidate credentials already issued. Teammates retain their own accounts and MFA.

## When Studio, MLflow, ECR, or another service is added

Known development dependencies are implemented in `development.tf` and `execution-boundaries.tf`:

| Implemented bundle | Owner and scope |
|---|---|
| Studio use | RJ and Caden can use their designated project Studio profiles, apps, and private space namespaces when assignments are configured. Their runtime roles get matching data/experiment ceilings. Platform owns the shared domain/profiles and networking. |
| MLflow use | RJ and Caden can access the designated project tracking server and the experiment/run/model operations required by their work. Include the separate `sagemaker-mlflow` API permissions, not just tracking-server management. Preserve the model approval decision in the registration/deployment flow. |
| MLflow operations | Caden manages the designated tracking server's lifecycle and its assigned execution role's inline policies; the server's role/boundary covers project artifact storage and required registry operations. |
| ECR images | Caden manages `panic-ml-*`; Joe manages `panic-app-*`; RJ can pull ML images. Repository lifecycle, image operations and repository-policy management are included for the owning developers. Runtime boundaries include approved image pulls and separate registry authentication. |
| Existing data/model/app/monitoring dependencies | Include the known S3 prefixes, Feature Store lookups, model package groups, endpoints, workflows, tables, topics, and logs for each owner's task in the initial human policies and execution-role ceilings. Add Athena/KMS dependencies if the chosen data/encryption design actually uses them. |

Use deterministic project names to define resource ARN scopes before the named resources exist where the service supports this. Wire generated domain IDs, user profiles/spaces, API IDs, and other generated identifiers from foundation Terraform outputs into the IAM configuration. In the current standalone stack, execution roles and their boundaries must exist before delegation is enabled; future foundation integration should express those dependencies explicitly. Adding the workload should then populate the approved bundle's resource references instead of requiring a new permission design or manually attaching policies in the console.

Define each execution-role boundary to cover its owner's planned workload from the start. Owners can adjust inline permissions inside that preapproved scope themselves. New direct access, resources outside the naming/ownership contract, or genuinely new services still require a platform policy change. Do not broaden human-role or boundary editing authority merely to avoid specifying the known dependencies.

Access is not automatically granted by enabling an arbitrary service. For these implemented bundles, future matching resource names are already covered; Studio/API/generated execution identities are populated through platform Terraform inputs. Changes outside the initial scopes follow this workflow:

| Change | Who applies it |
|---|---|
| A person needs direct console/API access outside their implemented bundle | Platform updates that person's human-role policy in this stack. Matching MLflow/ECR/job resources need no per-resource change; Studio assignment inputs are populated once provisioned. |
| An existing app/job needs a permission already permitted by its boundary | The owner updates their assigned execution role's inline policy. |
| A workload needs a new resource/service outside the current boundary, or needs a new execution role | Platform updates the boundary or creates/assigns the role first; the owner then manages its inline permissions. |

Exact actions depend on whether MLflow is local or hosted and whether ECR images are built-in or project-owned. Merely granting a job role ECR pull does not allow the human to push images, and granting a human Studio access does not give the Studio execution role data access. Keep the human permissions, runtime permissions, and boundary for each known service together in its Terraform implementation. IAM preparation does not require starting billable Studio apps or MLflow servers early.

## References

- [AWS cross-account roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html)
- [MFA in role trust](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_configure-api-require.html)
- [PassRole restrictions](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html)
- [Execution-role policy editing](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_update-role-permissions.html)
- [Permissions boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)
- [SageMaker action/resource reference](https://docs.aws.amazon.com/service-authorization/latest/reference/list_sagemaker.html)
- [API Gateway action/resource reference](https://docs.aws.amazon.com/service-authorization/latest/reference/list_apigatewayv2.html)
- [Terraform AWS IAM role resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
- [SageMaker MLflow IAM requirements](https://docs.aws.amazon.com/sagemaker/latest/dg/mlflow-create-tracking-server-iam.html)
- [ECR repository-scoped push permissions](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-push-iam.html)
