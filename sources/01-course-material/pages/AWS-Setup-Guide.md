# AWS Setup Guide

_Updated: 2026-11-20T03:09:28Z_

# AWS Setup Guide

Complete before Lab 1.

## Step 1 — Activate AWS Academy Courses

Accept the invitation in your BYU email. Do not enter a personal credit card.

## Step 2 — Create an AWS Free-Tier Account

Watch this walkthrough: <https://www.youtube.com/watch?v=vDtXk6QlRpo&t=3s>

Follow the instructions to create an AWS Free Tier account:

* Create Root Account with Multi-Factor Authentication (MFA)
* Create Admin Account

## Step 3 — Set a Budget Alert

Billing → Budgets → Create Budget. Set an alert at $1 to catch initial charges.

## Step 4 — Install Terraform

```
brew tap hashicorp/tap   # macOS
brew install hashicorp/tap/terraform
terraform version        # verify 1.16.1+
```

Instructions for Windows or Linux: [https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli "https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli")

## Step 5 — Configure AWS CLI

```
python3 -m pip install awscli
aws configure   # region: us-east-1
```

## Cost Guardrails

* Stop Studio instances when not in use — they bill hourly.
* Use ml.t3.medium for development; ml.m5.xlarge for training only.
* Delete SageMaker endpoints after each lab submission.
* Be especially mindful of MLflow servers.
