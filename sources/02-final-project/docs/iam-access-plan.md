# Project IAM access plan

Decision: host the project in your AWS account and give each teammate a scoped cross-account role. Teammates sign in using existing IAM users with MFA in their own AWS accounts, then switch into their assigned role in the hosting account. This supersedes the earlier plan to create teammate IAM users in the hosting account. The hosting account receives the project's charges; reimbursement remains a team decision. AWS Organizations and IAM Identity Center are not required for this arrangement.

This is the setup specification, not a deployed configuration. A read-only STS identity check succeeded on November 21, 2026: the configured identity is `arn:aws:iam::278634873542:user/tesplin`. The configured Region is `us-east-1`. Administrative privileges and the account plan have not been verified. Resource ARNs and execution-role policies must be filled in before deployment. No IAM users, roles, or policies were created during this planning step.

The development permission baseline is implemented as a reviewable [Terraform IAM stack](../../../infra/iam/README.md). It creates three cross-account roles, their policies, and three platform-owned execution-role boundaries. It outputs source-account permission snippets, Switch Role links, and boundary ARNs. It has not been applied. The README documents grants, naming patterns, exclusions, optional inputs, and workload dependencies.

## People and roles

Based on `../team-and-roles.md` and `../../05-diagrams/html-sources/gantt.html`:

| Person | Source identity | Assigned role in hosting account | Responsibilities and access |
|---|---|---|---|
| RJ, Lead and ML | Existing IAM user ARN, pending | `panic-lead-ml` | Read and write project raw/features data in S3, including uploading/replacing objects; read evaluation results; write experiment artifacts, model cards, and evaluations to designated S3 prefixes; inspect project models, jobs, metrics, and logs; start the agreed training pipeline; approve/reject project model packages. |
| Caden, MLOps and reliability | Existing IAM user ARN, pending | `panic-mlops` | Create/update/run project SageMaker pipelines and jobs; register models and deploy project endpoints; manage project monitoring jobs, dashboards, alarms, and logs; read features and scoring logs; write model and monitoring artifacts. |
| Joe, App and business | Existing IAM user ARN, pending | `panic-app` | Manage project Lambda functions, API Gateway APIs, Step Functions workflows, SNS topics, and DynamoDB tables; invoke the project endpoint and read online features; read/write designated app data and scoring-log prefixes; read project operational metrics. |
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

## Cross-account sign-in and MFA

The flow is: teammate's existing IAM user with MFA -> `sts:AssumeRole` -> assigned project role in account `278634873542` -> project resources in that account. All three project roles live in the hosting account. Teammates' source-account administrator permissions do not transfer into the project role. Their own account permissions remain under their own control; we control access to the hosting account through its role trust and role permission policies.

We skip creating teammate IAM users, temporary passwords, password resets, and duplicate MFA registrations in the hosting account. Each teammate remains responsible for maintaining their source identity and MFA. If someone does not already have a usable IAM user with MFA, they must first set one up in their own account; a root login or a Builder ID alone is insufficient for this flow.

### Information to collect

| Person | AWS account ID | Exact IAM user ARN, including any path | MFA enabled | Console / CLI needed | Can add source-account policy |
|---|---|---|---|---|---|
| RJ | Pending | Pending | Pending | Pending | Pending |
| Caden | Pending | Pending | Pending | Pending | Pending |
| Joe | Pending | Pending | Pending | Pending | Pending |

Each person can obtain their current caller identity from `aws sts get-caller-identity`, or copy their IAM user ARN from the console. An ARN of the form `arn:aws:sts::...:assumed-role/...` indicates a role session rather than an IAM user and needs separate review. Never collect passwords, access keys, MFA seeds, QR codes, recovery codes, or one-time MFA codes. Account IDs and ARNs are identifiers, not credentials.

### Setup order

1. Collect and verify each teammate's exact source IAM user ARN, MFA status, and need for console/CLI access. They or their source-account administrator must be able to grant `sts:AssumeRole` on their assigned destination role.
2. Define the full agreed project permissions and required resource ARNs for each role. Create the destination roles and policies through platform Terraform. Start with a one-hour maximum role session.
3. Each destination role trusts only its assigned source user ARN and requires `aws:MultiFactorAuthPresent` to be true. Do not trust an entire external account without narrowing the allowed principal. Recreating a trusted IAM user may require updating the trust policy because its underlying principal ID changes.
4. Give each teammate the small source-account permission policy below for their assigned role. They or their source administrator attach it to their IAM user or an appropriate group. This does not grant direct access to project resources; it allows obtaining the destination role's temporary credentials. Existing source-account administrator access may already allow this action, subject to other restrictions.
5. Give each teammate their destination role ARN and Switch Role link. They sign into their source IAM user with MFA and switch into the project role. No credentials are exchanged between accounts.
6. Confirm the assumed identity is in account `278634873542`, run a representative project task, and verify another teammate's role is inaccessible. They receive the full scoped role immediately after successful assumption; they do not need a separate staged user-enrollment policy in the hosting account.

Source-account permission policy, shown for Joe; use the assigned role ARN for each person:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "arn:aws:iam::278634873542:role/panic-app"
  }]
}
```

Destination role trust template, shown for Joe. Replace the example account ID and user path with Joe's verified IAM user ARN before deployment. This trust policy controls who can assume the role; the role's separate permission policy controls project access.

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"AWS": "arn:aws:iam::111122223333:user/REPLACE_WITH_JOE_USER_PATH"},
    "Action": "sts:AssumeRole",
    "Condition": {"Bool": {"aws:MultiFactorAuthPresent": "true"}}
  }]
}
```

Planned console links (usable only after roles and source permissions exist):

- RJ: <https://signin.aws.amazon.com/switchrole?account=278634873542&roleName=panic-lead-ml&displayName=PANIC-ML>
- Caden: <https://signin.aws.amazon.com/switchrole?account=278634873542&roleName=panic-mlops&displayName=PANIC-MLOps>
- Joe: <https://signin.aws.amazon.com/switchrole?account=278634873542&roleName=panic-app&displayName=PANIC-App>

### CLI and Terraform

Use their existing source-account credential profile to obtain temporary role credentials. Example in the teammate's local AWS config for Joe; replace the source account and MFA device name:

```ini
[profile panic-app]
role_arn = arn:aws:iam::278634873542:role/panic-app
source_profile = personal
mfa_serial = arn:aws:iam::111122223333:mfa/REPLACE_WITH_DEVICE_NAME
role_session_name = joe
duration_seconds = 3600
region = us-east-1
```

The source profile `personal` must resolve to the approved IAM user; configure any source credentials privately on the teammate's computer. This TOTP-based flow prompts for an MFA code when obtaining fresh role credentials. Then verify with `aws sts get-caller-identity --profile panic-app`. For Terraform, set `AWS_PROFILE=panic-app` and use `allowed_account_ids = ["278634873542"]` in the provider; set the state backend's account restriction separately if supported by the chosen backend. This helps avoid deployment into a personal account by mistake.

Do not store source keys, MFA codes, or session credentials in the repository or Terraform state. Teammates never give source credentials to the project administrator. For someone using only a hardware security key or a different credential provider, verify the supported CLI MFA flow before adopting this TOTP example. GitHub Actions will use a separate OIDC role in the hosting account.

### Login-method exceptions

This plan specifically supports an IAM user with MFA. Identity Center, other federated roles, school lab roles, and the newer AWS sign-up experience may present different source identities and policy restrictions. Federated MFA does not automatically populate `aws:MultiFactorAuthPresent` for the trust condition shown above. Confirm a supported source identity/MFA design before enabling that person's access; do not simply remove MFA enforcement to make a role session work. If a school account prevents source policy changes, use a suitable personal IAM identity or revisit the local-user option for that person.

## Permission changes and offboarding

Teammates can deploy and manage resources allowed by their project role, including the required creation/update/read operations within the agreed scope. They cannot edit their human role's policies/trust or grant themselves another role. They can create, update, and delete inline permission policies on their explicitly assigned execution roles; trust, role creation/deletion, managed-policy editing/attachments, and permission boundaries stay with platform. Only roles with the declared platform-owned boundary attached qualify for delegation. The full human role is scoped to their responsibilities; it is not account administrator access.

For new direct human access or a wider execution-role boundary, they submit an issue or pull request containing the task, exact denied API action, resource ARN, caller identity, and requested duration. Platform applies that change through Terraform. If the missing permission belongs to an assigned execution role and is already allowed by its boundary, the owner can update the inline policy themselves through their component Terraform. Their own account's administrator privileges cannot expand their destination human role's permissions.

To offboard, remove the source identity from destination role trust and revoke active role sessions. Remove project grants and resource-policy access if any were added outside the role. Do not disable or delete identities, keys, or MFA devices in a teammate's personal account. They can remove the source `AssumeRole` permission themselves.

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
3. Translate the table above into three customer-managed role policies, three MFA-protected cross-account trust policies, and source-account `AssumeRole` policy snippets. Validate action/resource compatibility using AWS IAM Access Analyzer policy validation. Do not create teammate IAM users in the hosting account.
4. Have teammates verify source MFA and attach their source permission policy, then test the supplied Switch Role links and any needed CLI profiles. Organizations membership is unnecessary.
5. Verify each source identity can assume only its assigned destination role; verify attempts without MFA, from another source identity, or to assume another teammate's role fail. Verify the effective account ID before project actions.
6. Run one representative authorized task per role: RJ reads training data and writes an evaluation, Caden runs a small pipeline and deploys a test model, and Joe invokes the endpoint through an app function and writes an audit event.
7. Verify human-role/trust/boundary changes, editing another owner's execution roles, unrelated resource access, unapproved `PassRole`, and shared raw-data deletion are denied. Verify each owner can manage their own execution-role inline policies and that the boundary limits resulting workload permissions. Fix individual missing permissions based on the failed API call rather than adding a broad full-access policy.
8. Retain CloudTrail evidence of identity and resource changes. Test any additional API, ECR, Athena, KMS, and service-role dependencies encountered by the actual workflow before calling the role fully operational.
9. After submission, tear down billable resources, remove cross-account trust, revoke active project role sessions, and remove project roles/policies when no longer needed. Teammates keep control of their personal IAM users and credentials.

## References

- [AWS cross-account role setup](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html)
- [MFA-protected API and role access](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_configure-api-require.html)
- [Console role switching](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html)
- [Restricting iam:PassRole](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html)
