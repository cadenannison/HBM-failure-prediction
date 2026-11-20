# AWS tools in PANIC: cheat sheet

| Tool | What it is, in plain words | What PANIC uses it for | Owner | From labs? |
|---|---|---|---|---|
| Terraform | A blueprint file that builds cloud stuff the same way every time | Builds everything below | Tom | Labs 1, 2 |
| VPC | A private network | Keeps the system off the open internet | Tom | Lab 1 |
| IAM | Logins and permissions | One user per teammate, least privilege | Tom | Lab 1 |
| S3 | A giant file cabinet | Raw error logs, scoring logs, model files | Tom | Lab 1 |
| AWS Budgets | A spending alarm | Emails if costs climb | Tom | Lab 1 |
| Kinesis Data Streams | A conveyor belt for live data | Streams errors from the fleet simulator | Tom | **New** |
| Lambda | Code that runs only when triggered | Writes errors to S3; hourly scoring; API routes | Tom, Joe | Labs |
| AWS Glue | A data cleaning and transforming job | Data contract checks and feature counts | Tom | Lab 2 |
| SageMaker Feature Store | A feature library: offline for training, online for live use | Row, column, bank, server features | Tom | Lab 2 |
| MLflow | An experiment notebook | Tracks every training run | RJ | Labs |
| SageMaker Pipelines | An assembly line for ML | Prep, train, evaluate, register | Caden | **New** |
| SageMaker Model Registry | A trophy case with a human approval gate | Approved models per level | Caden | Labs 4, 5 |
| GitHub Actions | Automatic tests on every code change | CI | Caden | Labs |
| EventBridge | A cloud alarm clock | Triggers scoring every hour | Tom | Labs |
| SageMaker serverless endpoint | Runs a model on demand, costs nothing when idle | Returns risk scores | Caden | Labs |
| Step Functions | A flowchart that runs itself, can pause for a human | Retire row / approve bank / sign off drain | Joe | **New** |
| DynamoDB | A fast database | Audit log of every decision | Joe | |
| Amazon SNS | Sends texts and emails | Alerts the on-call engineer | Joe | |
| API Gateway | The front desk for requests | Dashboard talks to the system through it | Joe | **New** (required) |
| Streamlit | A quick Python web app | Fleet dashboard with Approve button | Joe | |
| CloudWatch | Dashboards and alarms | System health, SLOs | Caden | Lab 6 |
| Evidently | Drift checker | Is today's data still like training data? | Caden | Lab 6 |

**New beyond the labs** (counts for "extends in-class learning"): Kinesis, SageMaker Pipelines, Step Functions, API Gateway.

**Course minimum requirements covered:** end to end ingest to monitoring; pipeline services for prep, training, evaluation, deployment; Model Registry; Feature Store; Model Monitoring; API Gateway; documented scaling plan; at least one unique service; demo app with UI and demo script.
