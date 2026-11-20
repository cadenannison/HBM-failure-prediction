# NorthStar Retail — Case Overview

_Updated: 2026-11-20T03:09:27Z_

# NorthStar Retail — Case Overview

**NorthStar Retail** is a fictional specialty retailer: 400 stores across North America, growing e-commerce presence, ~$3.2B annual revenue.

## AI Systems

| System | Type | Business Goal |
| --- | --- | --- |
| Churn Prediction | Batch ML (XGBoost) | Identify at-risk customers 90 days before churn |
| Offer Generation | LLM / RAG | Personalize retention offers |
| Customer Service Agent | Agentic AI | Handle inquiries and escalations autonomously |

## Recommended Repository Structure

```
northstar-ai-platform/
├── infrastructure/    ← Lab 1: Terraform IaC
├── data/              ← Lab 2: Pipelines and features
├── models/            ← Lab 3: Model development
├── pipeline/          ← Lab 4: CI/CD
├── deployment/        ← Lab 5: Deployment
├── monitoring/        ← Lab 6: Observability
└── docs/              ← Written reports
```
