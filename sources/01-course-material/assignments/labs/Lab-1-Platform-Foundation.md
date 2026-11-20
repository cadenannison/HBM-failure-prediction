# Lab 1 — Platform Foundation

- Due (UTC): 2026-09-20T05:59:00Z
- Points: 100
- Submission: online_url

**Assigned:** Thu Sep 3 | **Due:** Sat Sep 19, midnight  
**Chapter:** *AI Platform & Cloud Architecture*  
**Builds on:** Nothing — this is the foundation  
**Structure:** Two parts, one submission, 100 points total

## Objective

Build the NorthStar Retail AI platform skeleton on AWS — twice. First by hand in the console (Part A), then as Terraform code (Part B). The sequence is deliberate: you cannot write good Infrastructure as Code for a system you do not understand at the API level. Part A forces you to understand every resource and why it exists. Part B teaches you what IaC is actually automating.

By the end of this lab, you will have: a mental model of the platform architecture, evidence that you built it manually, and a Terraform codebase that rebuilds it from scratch with a single command.

> **Scope note:** This lab uses a single public subnet to keep the networking simple. Lab 2 adds private subnets, a NAT Gateway, and the data engineer and model monitor IAM roles — once you have context for why each of those components exists.

---

## Starter Kit

* `northstar-scenario-overview.md` — NorthStar Retail case description
* `NorthStar_Retail_AI_Platform.pptx` — the case briefing deck
* `scripts/check-secrets.sh` — the exact credential scan the grader runs on your git history.
* `infrastructure/` — skeleton module structure for Part B: four empty modules (vpc, storage, iam, sagemaker) plus `dev` and `local` environments, every variable declared and documented, every resource left as a TODO.
* `docker-compose.yml`, `Makefile` — LocalStack setup for Task B5
* `aws-account-setup.md` — AWS account setup, credit budget, and cost controls
* `northstar-data-schema.md` — data source schemas

## Getting Your Repository

You will build the NorthStar platform in **one repository for the whole course**.
Every lab extends the previous one — Lab 2 modifies your Lab 1 Terraform rather than
replacing it — so create this repository once, now, and keep working in it all
semester.

1. **Sign in to GitHub first.** The **Use this template** button does not appear
   to signed-out visitors — the page loads, the button simply is not there, which
   looks like a broken link. If you do not have an account, create one now.
2. Go to <https://github.com/byu-cs401r4-f26/cs401r-lab1-template>
3. Click **Use this template** → **Create a new repository**
4. Name it `cs401r-<your-netid>` — no lab number, it is your repository for all seven
   labs — and leave it **Public**
5. Clone it locally and work there

The template holds the same files as the Canvas starter kit zip; use either one.

---

## Tasks & Point Breakdown

| Task | Points |
| --- | --- |
| Lab 1a: Manual Provisioning Tasks A1–A4 below are numbered the way they are graded. | 35 |
| Lab 1b: Infrastructure as Code northstar-ai-platform/ | 45 |
| Shared Deliverables Accepted | 20 |
| **Total** | **100** |

**Full lab guide, rubrics and worked detail:** [Open the full lab guide](https://byu.instructure.com/courses/38938/files/13861218?wrap=1)

## Submission

Submit your repository URL. Tag the commit you want graded `lab1-submit` and push the tag; the TA grades that tag. Your tagged commit must include `docs/lab1-verify-output.txt` — the output of `scripts/verify-lab1.sh`, which you run while your stack is still up and before `terraform destroy`. It cannot be regenerated afterwards. The TA will check out that tag and run `terraform apply` and `terraform destroy` against a clean account.

## Submission

Submit a GitHub repository link before the deadline.
A repo that does not clone cleanly loses 20 points automatically.
Never commit AWS credentials — committed secrets = automatic 0.

**Late policy:** 10% per calendar day. Contact instructor before the deadline, not after.
