# Group Project Charter: review against the assignment

Reviewed Nov 20, 2026. Source: `Group Project Charter.docx` (text in `group-project-charter.md`, rendered copy in `Group Project Charter.pdf`, images in `charter-media/media/`).

Due **Sat Nov 21, 11:59 PM** on Canvas. 5 pts. Assignment text: `../01-course-material/assignments/final-project/`.

## Checklist

| Charter item (assignment) | In the docx? | Notes |
|---|---|---|
| Project title | Yes | PANIC, with the interposer definition |
| Vision (problem, goal, why it matters) | Yes | Could add one hard number (see below) |
| Roles and responsibilities | Yes | Names and roles listed |
| Values, commitments, communication | Yes | Weekly standup, Discord, Gantt |
| Architecture diagram **and description** | Diagram only | **Missing the written description.** Draft below |
| AWS Pricing Calculator estimate | No | Optional now, required at the end |
| Project plan with Gantt chart and milestones | Gantt only | Milestones are on the chart; a short list below it reads better |

## Fixes before submitting

1. **Add the architecture description** under the diagram (draft below).
2. **Swap the Gantt image.** The one in the docx says "Flight simulator"; it should be "Fleet simulator". The fixed image is `../05-diagrams/hbm-early-warning-gantt.png`.
3. **Map teammates to names.** Both images say Teammate 1 to 4. Add one line under each image: *Teammate 1 = RJ Gammoh, Teammate 2 = Tom Esplin, Teammate 3 = Caden Annison, Teammate 4 = Joe Gerard.* (Or regenerate the images with names.)
4. **Small text fixes:** "hardwork" → "hard work"; "holding a weekly a standup meeting" → "holding a weekly standup meeting"; "discord" → "Discord".
5. **Optional:** add a milestone list and one cost line (below).

## Draft: architecture description

> PANIC runs on AWS in four layers. **Data in:** a fleet simulator replays real Calchas HBM error logs and generates a synthetic data center, streaming errors through Kinesis Data Streams. A Lambda function writes the raw log to S3, an AWS Glue job checks it against a data contract and builds features, and SageMaker Feature Store keeps them offline for training and online for scoring. **Training:** SageMaker Pipelines prepares data, trains one model per level (row, column, bank, server), evaluates it and registers it in the Model Registry, where a person approves it before release. GitHub Actions tests every code change and MLflow tracks every run. **Serving and actions:** every hour EventBridge triggers a scoring Lambda that reads online features and calls a serverless SageMaker endpoint. Step Functions then retires risky rows automatically, waits for an operator to approve isolating a bank, and requires human sign-off before draining a server, logging every decision to DynamoDB. **People and operations:** a Streamlit dashboard talks to API Gateway to show fleet risk and approve actions, Amazon SNS alerts the on-call engineer, and CloudWatch plus Evidently watch for errors and drift. Everything is built with Terraform in a VPC, with an IAM user per teammate, an AWS Budgets alert and a teardown script.

## Draft: milestones

| Date | Milestone | Graded? |
|---|---|---|
| Sat Nov 21 | Charter submitted | Yes, 5 pts |
| Tue Nov 24 | Model pipeline complete (laptop baselines per level) | Suggested |
| Thu Dec 10 | Code complete; optional dry run in class | Suggested |
| Wed Dec 16, 3 to 6 PM, 1230 TRNB | Presentation and live demo (15 min + 5 Q&A) | Yes |
| Thu Dec 17, 11:59 PM | Final submission to the group GitHub | Yes |

Lab 6 (Sat Nov 28) and Lab 7 (Tue Dec 1) overlap week 2.

## Optional: stronger vision line

> During Meta's 54-day Llama 3 405B run on 16,384 H100 GPUs, HBM3 failures caused 72 of 419 unexpected interruptions. At $4 per GPU-hour and one hour lost per crash, each one costs about $65,000.
