# Project IAM access plan

Decision (updated November 23, 2026): host the project in your AWS account and create a separate IAM user there for each teammate. Each person signs in with their own password and MFA, then switches into their assigned project role. This replaces the earlier cross-account plan because teammates do not have existing IAM identities. Users belong to the account; teammates do not use its root identity. Use an IAM administrator for routine provisioning. The hosting account receives project charges; reimbursement remains a team decision. AWS Organizations and IAM Identity Center are not required.

This is the setup specification, not a deployed configuration. A read-only STS identity check succeeded on November 21, 2026: the configured identity is `arn:aws:iam::278634873542:user/tesplin`. The configured Region is `us-east-1`. Administrative privileges and the account plan have not been verified. Resource ARNs and execution-role policies must be filled in before deployment. No IAM users, roles, or policies were created during this planning step.

The development permission baseline is implemented as a reviewable [Terraform IAM stack](../../../infra/iam/README.md). It creates three IAM users, their scoped self-service policies, three MFA-protected project roles and their development policies, and three platform-owned execution-role boundaries. It outputs usernames, the account sign-in URL, Switch Role links, and boundary ARNs. Passwords and keys are not generated or stored in Terraform. It has not been applied. The previously checked account identity/Region still need verification at deployment time.

## People and roles

Based on `../team-and-roles.md` and `../../05-diagrams/html-sources/gantt.html`:

| Person | IAM user in hosting account | Assigned project role | Responsibilities and access |
|---|---|---|---|
| RJ, Lead and ML | `panic-rj` | `panic-lead-ml` | Read and write project raw/features data in S3, including uploading/replacing objects; read evaluation results; write experiment artifacts, model cards, and evaluations to designated S3 prefixes; inspect project models, jobs, metrics, and logs; create project ML jobs, use assigned Studio/MLflow; start pipelines; approve/reject project model packages. |
| Caden, MLOps and reliability | `panic-caden` | `panic-mlops` | Create/update/run project SageMaker pipelines and jobs; register models and deploy project endpoints; manage MLflow tracking servers and ML images; use assigned Studio; manage project monitoring jobs, dashboards, alarms, and logs; read features and scoring logs; write model and monitoring artifacts. |
| Joe, App and business | `panic-joe` | `panic-app` | Manage project Lambda functions, assigned API Gateway APIs, Step Functions workflows, SNS topics, DynamoDB tables, and app images; invoke the project endpoint and read online features; read/write designated app data and scoring-log prefixes; read project operational metrics. |
| You, Data and platform | `tesplin`; administrative privileges to be verified | Platform administration | Own project policies, role trust, execution roles, Terraform foundation, networking, data ingestion, Glue, Feature Store, Kinesis, EventBridge, budgets, and final teardown. Keep the root identity for account-level recovery and tasks requiring root. |

Model approval ownership needs a small clarification: the Gantt assigns model approval to RJ, while the team-role document includes registry approval under Caden. Proposed resolution: RJ approves model quality; Caden implements the registry/deployment mechanism. Record any different team decision before finalizing those permissions. IAM permission to update approval status alone does not enforce an approved-model-only deployment gate; deployment code must enforce that gate too.

## Initial permission decisions

These are the implemented draft defaults to review before deployment:

| Decision | Default |
|---|---|
| RJ's cloud training access | Create/stop project training, processing, transform and tuning jobs; start/stop existing project pipelines. Studio access is templated for RJ's assigned profile, apps and private spaces. |
| Model approval | RJ may update project model packages; Caden registers with `PendingManualApproval` and deploys endpoints. Pipeline and execution-role policies must preserve the approval gate. |
| Caden's lifecycle access | Create/update/delete project pipelines, models/configs, endpoints; create/stop training/processing jobs; manage project dashboards and alarms. |
| Anticipated development services | RJ/Caden can use project MLflow tracking servers; Caden manages those servers. Caden manages ML ECR repositories/images; Joe manages app repositories/images; RJ can pull ML images. Caden can also use an assigned Studio workspace. Naming patterns cover future matching resources. |
| Joe's lifecycle access | Create/update/delete project functions and workflows; create/update app tables and topics; manage children of assigned APIs. Top-level API, table, and topic deletion stays with platform. |
| Shared data | RJ can upload/replace objects in the project's S3 `raw/` and `features/` prefixes. Caden and Joe lack those writes. All human roles lack S3 object deletion. Read/write access to other fixed prefixes follows the matrix in the Terraform README. This does not grant Feature Store record ingestion or feature-group administration. |
| App audit data | Joe may write/update rows while developing the app; this is not immutable audit storage. |
| API and execution roles | Exact API IDs and approved execution-role ARNs must be supplied. Empty inputs grant no API access or PassRole. |
| Service-role delegation | Each teammate can inspect, edit inline permission policies on, and pass their explicitly assigned execution roles: RJ/Caden for SageMaker; Joe for Lambda/Step Functions/API Gateway. Platform creates roles, trust, and permission boundaries and controls the maximum scope. Actual boundary attachment is checked before delegation. |
| Console discovery | By default, allow limited regional lists and account-wide CloudWatch metrics reads. A switch removes these grants if stricter access is preferred. |
| Shared platform | Human-role administration, execution-role creation/trust/boundaries, networking, Glue, Feature Store creation/ingestion, Kinesis, EventBridge, billing, and final teardown stay with platform. |

The [development service bundles](../../../infra/iam/README.md#when-studio-mlflow-ecr-or-another-service-is-added) are implemented up front. Project-named MLflow tracking servers, ML/app ECR repositories, and ML jobs are covered without listing each future resource. Studio requires exact domain/profile assignments and private-space namespaces from foundation outputs; API IDs and execution-role assignments remain explicit. The generated runtime ceilings include S3/log/metric access, image pulls, MLflow, project ML or app runtime work, and Joe's task-token callbacks. They preserve RJ-only raw/features writes and keep human-role/trust/boundary administration with platform. Initial IAM apply creates boundaries; foundation attaches them to service roles before delegation is enabled. Athena/KMS, Unified Studio, MLflow Apps, GitHub OIDC, and new service families remain explicit choices requiring scope updates. Mock tests check generated configuration; live IAM Access Analyzer validation and cross-account workflow checks remain prerequisites for deployment acceptance.

## Local-user sign-in and MFA

The flow is: individual IAM user in account `278634873542` -> password change and MFA enrollment -> MFA-authenticated `sts:AssumeRole` -> assigned project role -> project resources. Users are created under IAM path `/panic-team/`; the console username is just `panic-rj`, `panic-caden`, or `panic-joe`. Human project roles and execution-role permissions retain the agreed development scopes.

### Information and setup

No external account IDs, IAM user ARNs, passwords, or MFA codes are needed from teammates. Confirm who receives each username and whether they need console access, CLI access, or both.

1. Use an IAM administrator profile for the hosting account; verify account ID, privileges, and Region before planning/applying. Retain the root identity for account recovery and tasks requiring it. If the account's newer sign-up experience does not support IAM console users, confirm its supported access/activation path first; this change does not authorize an account-plan upgrade.
2. Configure `teammate_user_names` or keep the defaults. Review Terraform's plan: it creates the three users, self-service policies, role trust, development policies, and execution-role boundaries. It creates no console passwords/access keys or MFA devices. If users already exist, inspect/import them instead of duplicating them.
3. After apply, use IAM > Users > each user > Security credentials > Enable console access. Generate a unique temporary password and require a change at next sign-in. Deliver the account sign-in URL, username, and temporary password privately. Do not put credentials in Git, Terraform variables/state, or project documentation. The user already has permission to change their own password; no additional administrator policy is needed on the user.
4. Each teammate signs in, replaces their temporary password, opens My security credentials, and registers MFA. Use an authenticator device name such as `panic-rj-phone`, `panic-caden-phone`, or `panic-joe-phone`; permissions cover only that user's own name or `<username>-*` device namespace. The teammate keeps their seed/QR code and MFA codes private.
5. Sign out and sign back in with MFA, then open the assigned Switch Role link. The project's full scoped permissions activate only in that role. Without MFA, the user can perform credential onboarding but cannot assume a project role.
6. Test their assigned-role access, a representative project task, and denial of another teammate's role or credential management. Lost MFA is recovered by the administrator after identifying the teammate. Deactivation of enrolled MFA and access-key management require an MFA-authenticated user session.

Account sign-in URL: <https://278634873542.signin.aws.amazon.com/console/>

Planned Switch Role links (usable after apply and enrollment):

- RJ: <https://signin.aws.amazon.com/switchrole?account=278634873542&roleName=panic-lead-ml&displayName=PANIC-ML>
- Caden: <https://signin.aws.amazon.com/switchrole?account=278634873542&roleName=panic-mlops&displayName=PANIC-MLOps>
- Joe: <https://signin.aws.amazon.com/switchrole?account=278634873542&roleName=panic-app&displayName=PANIC-App>

The user policy permits their own first-login password change and MFA enrollment before MFA, with no direct project-service grants. This avoids the first-login lockout caused by attaching AWS's strict generic deny-without-MFA example unchanged. Role trust and the user policy both require MFA for `AssumeRole`. No account-wide password policy is changed by Terraform.

### CLI and Terraform

After MFA enrollment, a teammate who needs CLI/Terraform can return to their IAM user session (exit the project role) and create/manage their own access key while authenticated with MFA. Configure credentials privately in a local `panic-user` source profile. Terraform never creates keys, and keys alone do not allow assuming the project role without MFA.

Example local AWS config for Joe with an authenticator named `panic-joe-phone`:

```ini
[profile panic-app]
role_arn = arn:aws:iam::278634873542:role/panic-app
source_profile = panic-user
mfa_serial = arn:aws:iam::278634873542:mfa/panic-joe-phone
role_session_name = joe
duration_seconds = 3600
region = us-east-1
```

The CLI prompts for a TOTP MFA code when obtaining fresh role credentials. Verify with `aws sts get-caller-identity --profile panic-app`. For Terraform, set `AWS_PROFILE=panic-app` and use `allowed_account_ids = ["278634873542"]` in the workload provider; configure the backend's account restriction separately where supported. If using a security-key-only setup, verify its supported CLI flow before relying on this TOTP example. CI will use a separate GitHub OIDC role, not a teammate's access key or MFA device.

User identities, passwords, role trust, and boundaries are controlled by platform administration. Each teammate retains self-service credential management and their agreed execution-role inline policy access. If old cross-account trust had been deployed, reviewing/applying the revised trust and revoking any old active role sessions are part of migration; the earlier planning work did not deploy it.

## Permission changes and offboarding

Teammates can deploy and manage resources allowed by their project role, including the required creation/update/read operations within the agreed scope. They cannot edit their human role's policies/trust or grant themselves another role. They can create, update, and delete inline permission policies on their explicitly assigned execution roles; trust, role creation/deletion, managed-policy editing/attachments, and permission boundaries stay with platform. Only roles with the declared platform-owned boundary attached qualify for delegation. The full human role is scoped to their responsibilities; it is not account administrator access.

For new direct human access or a wider execution-role boundary, they submit an issue or pull request containing the task, exact denied API action, resource ARN, caller identity, and requested duration. Platform applies that change through Terraform. If the missing permission belongs to an assigned execution role and is already allowed by its boundary, the owner can update the inline policy themselves through their component Terraform. Credential self-service does not let them expand their human role's permissions.

To offboard, disable the teammate's local console login and access keys, remove project role access, and revoke active role sessions. Remove additional project/resource-policy grants if any exist. Clean up administrator-managed credentials and enrolled MFA before deleting the local IAM user. Terraform does not force-delete their credentials. These users are managed in the hosting account; no personal AWS account changes are involved.

## Resource boundaries

- Use `panic-` resource names and `Project=PANIC`, `Environment=dev`, and `Owner` tags where supported. Names and tags are conventions; the actual policies must enforce access.
- Scope service actions to explicit project ARNs and S3 prefixes where supported. S3 bucket listing and object permissions need separate statements, including prefix restrictions on listing.
- Pick the deployment Region before authoring service policies. The current CLI region setting is `us-east-1`; that setting alone does not establish the intended account or deployment Region.
- Permit console discovery operations using `Resource: "*"` only where the API requires it. Some list operations can reveal resource names outside the project; document these exceptions.
- Keep human-role IAM mutation, execution-role trust/boundaries/creation, shared networking, budgets configuration, and account-wide teardown with platform administration. Delegate inline policy editing for only the owner's explicitly assigned execution roles. Teammates may delete/recreate their owned development components where needed, but cannot delete shared raw data or foundation resources.
- Keep Terraform state for the foundation separate from teammate component state. Grant state access only to the relevant component prefix; state may contain sensitive resource configuration.
- Pre-create API Gateway APIs through platform Terraform and grant Joe access to those exact API IDs. Do not rely on a display-name prefix to scope API Gateway management ARNs. Add tag-based creation controls only for supported actions.
- Joe can use public Pricing Calculator estimates and sanitized cost reports for economics. Do not grant billing administration or account-wide cost visibility by default.
- Add Athena/Glue catalog reads and query-result-prefix writes only if RJ or Caden actually queries Feature Store offline data with Athena. Add access to the specific KMS keys if customer-managed encryption requires it.

## Separate execution roles

People's project roles deploy and operate components. AWS services execute workloads using their own service roles, with independently scoped policies and service trust:

| Workload | Execution-role scope |
|---|---|
| Glue feature processing | Read raw inputs, write feature outputs, ingest designated feature groups, and write its logs. |
| SageMaker pipeline/training | Read training data and code, run the pipeline's required jobs, write model/evaluation artifacts, register project models, and write logs. Separate pipeline orchestration from job execution where needed. |
| SageMaker endpoint | Read the approved model artifacts and required image; write endpoint logs. |
| Drift monitoring | Read scoring logs and reference data; write drift reports and project metrics/logs. |
| Scoring/API Lambda | Read designated online feature groups, invoke designated endpoint, perform only the required app-table/workflow actions, and write logs/scoring outputs. Split functions' roles when their permissions differ. |
| Step Functions | Invoke only designated action/approval functions, publish to its alert topic, and write permitted audit data as required by the workflow. |
| EventBridge Scheduler, if selected | Invoke only the replay/scoring target. An EventBridge rule invoking Lambda instead uses a scoped Lambda resource policy; choose the trigger mechanism before defining permissions. |
| GitHub Actions, when deployed | Trust only the team's repository and approved branch/environment through OIDC; deploy only its owned component and pass only approved service roles. |

Grant `iam:PassRole` only for the exact execution-role ARNs a person's component needs and constrain it with `iam:PassedToService`. Grant inline policy editing on the same owner-assigned roles only after verifying the approved boundary is attached. Never permit passing/editing human or platform administrator roles or arbitrary account roles. Anyone who can deploy code using an execution role can effectively exercise that execution role's permissions, so review both policies and the boundary together. Broad IAM role creation/editing is not delegated.

## Setup and acceptance checklist

1. Confirm the hosting account, administrator privileges, account plan, and Region. The earlier STS check established only the caller's identity. Confirm ownership of charges and reimbursement before inviting the team. Keep all project workloads in the hosting account; any resources a teammate runs directly in a personal account have their own billing implications.
2. Inventory actual bucket/prefix, feature group, model package group, endpoint, API, function, workflow, table, topic, and log-group identifiers. Create the foundation and necessary service roles through platform Terraform.
3. Review the three Terraform-managed IAM users, credential self-service policies, project-role policies, and MFA-protected local-user trust policies. Validate action/resource compatibility using AWS IAM Access Analyzer policy validation. No external account IDs/ARNs are needed.
4. After the reviewed apply, enable console passwords privately, require a password reset, and have teammates enroll MFA. Test their Switch Role links and any needed CLI profiles. Organizations membership is unnecessary.
5. Verify each IAM user can assume only its assigned role; verify password-only access, another user's credentials, and another teammate's role are inaccessible. Verify the effective account ID before project actions.
6. Run one representative authorized task per role: RJ reads training data and writes an evaluation, Caden runs a small pipeline and deploys a test model, and Joe invokes the endpoint through an app function and writes an audit event.
7. Verify human-role/trust/boundary changes, editing another owner's execution roles, unrelated resource access, unapproved `PassRole`, and shared raw-data deletion are denied. Verify each owner can manage their own execution-role inline policies and that the boundary limits resulting workload permissions. Fix individual missing permissions based on the failed API call rather than adding a broad full-access policy.
8. Retain CloudTrail evidence of identity and resource changes. Test any additional API, ECR, Athena, KMS, and service-role dependencies encountered by the actual workflow before calling the role fully operational.
9. After submission, tear down billable resources, disable local teammate logins/keys, revoke active project role sessions, and clean up users, MFA, and project roles/policies when no longer needed.

## References

- [IAM user creation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
- [Console passwords](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_admin-change-user.html)
- [Self-service MFA/password policy caveat](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html)
- [MFA-protected API and role access](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_configure-api-require.html)
- [Console role switching](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html)
- [Restricting iam:PassRole](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html)
