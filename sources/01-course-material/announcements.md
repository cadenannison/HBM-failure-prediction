# Announcements (oldest first)

## Please fill out the "Getting to Know You" survey under Week 1.

_Posted: 2026-09-07T18:24:05Z_

I didn't mention this in class. Several people found it and filled it out. Thank you! This will help me understand where you're at with this material and how I can fine-tune the class to your interests and needs. Also, I just love learning more about you. This is already turning out to be a fantastic group. I'm very excited and honored to be working with you this semester.

Best,

Dr. T.

---

## Reading Quiz Changes

_Posted: 2026-09-11T21:19:59Z_

Dear Students:

* Going forward, all quizzes will open today and be due by midnight on the day of the class lecture.
* You are encouraged to complete the reading and quiz **before** the lecture. Additionally, we removed the time limit. Feel free to look at the quiz questions before you begin the reading or reference the reading as you work through the quiz.
* Finally, you get one attempt, and there are no make-ups or extensions, but don't stress; you can earn up to 5% extra credit (more details to come).
* The goal is to motivate you to read the material and come prepared for class discussion.

Warm Regards,

Dr. T.

---

## Extra Credit for Razzing the Professor!

_Posted: 2026-09-12T00:11:26Z_

How many times do you get to point out the obvious foolishness, ignorance, or folly of your professors, and they actually want to hear it?! That is what this extra credit is all about. Your reading chapters are riddled with errors. Can you find them? If so, you'll get up to a 5% boost on your grade. The assignments are live and organized by reading assignment. You can get up to 5 points per reading. But it's not really about the points; it's about taking pride in showing that you know something better than the white-haired guy who is supposed to know everything. This exercise should genuinely aid in analyzing and understanding the material more effectively. Good luck and happy hunting!

Dr T.

---

## Lab 1 correction: Pre-Flight LocalStack section removed, template updated

_Posted: 2026-09-14T01:40:08Z_

Several of you noticed that the **Pre-Flight: LocalStack Sanity Check** section in Lab 1 referenced a `northstar-ai-platform/` folder and a `docker-compose.yml` that do not exist in the template. That was my error, and it could not have worked as written. Thank you to the student who flagged it.

**What changed (Lab 1 guide, starter kit, and GitHub template are all updated):**

* The Pre-Flight section is gone. Skip it and start at Task A1. Nothing about Lab 1a changes.
* LocalStack is used only in **Task B5**, at the end of Part B. The template now ships the `docker-compose.yml`, `Makefile`, and `infrastructure/environments/local/` that task needs. From the repo root, `make local-validate` does the whole thing and writes `docs/lab1b-localstack-output.txt`. Commit that file.
* The Terraform skeleton folder is now named `infrastructure/`, which is what `scripts/verify-lab1.sh` and the rubric already expected. Keep that name.

**If you already created your repository from the template:** re-download the Lab 1 starter kit from Canvas (or pull from [the template repo](https://github.com/byu-cs401r4-f26/cs401r-lab1-template)), copy in `docker-compose.yml`, `Makefile`, `scripts/verify-lab1.sh`, and `infrastructure/environments/local/`, and rename `terraform-module-template/` to `infrastructure/` if you have not already. Any module code you have written moves with it.

---

## Lab 1 starter kit fix: public subnet CIDR default was wrong

_Posted: 2026-09-14T20:39:12Z_

A defect in the Lab 1 starter kit has been corrected. If you copied the template or downloaded the zip before **Sunday, Sep 14**, read this.

**What was wrong.** The `vpc` module shipped with `public_subnet_cidr` defaulting to `10.0.1.0/24`. The spec, and the rubric, require `10.0.100.0/24`. If you wired the module without overriding that variable, your subnet on AWS is the wrong CIDR.

**What changed in the template** (now live on GitHub and in the Canvas zip):

* `modules/vpc/variables.tf` — `public_subnet_cidr` now defaults to `10.0.100.0/24`; a new `availability_zone` variable defaults to `us-east-1a`
* `modules/sagemaker/variables.tf` — new `instance_type` variable, default `ml.t3.medium`
* `environments/dev/variables.tf` — all seven Task B4 variables are now declared (only three shipped before). The commented module blocks in `dev/main.tf` show how to pass them through.
* `scripts/verify-lab1.sh` — the “Part A (50 pts)” banner now says 35. Cosmetic.
* LocalStack (Task B5) now expects `10.0.100.0/24` too. One spec, one CIDR.

**What you need to do.** Do not re-copy the template; you would lose your work. Instead:

1. Check your dev subnet: `grep -rn public_subnet_cidr infrastructure/`. If the effective value is not `10.0.100.0/24`, set it — either change the default in `modules/vpc/variables.tf` or pass `public_subnet_cidr = "10.0.100.0/24"` in `environments/dev/main.tf`.
2. Make sure all seven variables from Task B4 exist in `environments/dev/variables.tf` with descriptions. Add the ones you are missing.
3. If you have already applied, `terraform apply` again — changing a subnet CIDR replaces the subnet, and the SageMaker Domain depends on it, so expect the Domain to be recreated (8–12 minutes). Do it before you run `verify-lab1.sh` and destroy.

**Grading.** A `10.0.1.0/24` subnet in your submission will not be penalized for this lab, since the kit caused it. Everything else in the rubric stands.

Three file names in the lab guide were also made consistent with what `verify-lab1.sh` checks: `docs/lab1-studio-shutdown.png`, `docs/lab1-adr.md`, `docs/lab1b-localstack-output.txt`. If you already saved a file under an older name from an earlier version of the guide, rename it; the script tells you which ones are missing.

Lab 1 is still due **Saturday, Sep 19, midnight**.

---

## Lab 1 — screenshot filenames and an updated verify-lab1.sh (read before you tag)

_Posted: 2026-09-16T22:47:06Z_

Three small changes to Lab 1 before Saturday's deadline. None change
what you build; they change how you name and package the evidence.

**1. Screenshots now have standard filenames.** Save
every rubric screenshot in `docs/` with the names below.
**For Lab 1 only, the TA will accept any clearly named
screenshot** — if yours are already taken and named sensibly, you
are fine. From Lab 2 on, the filenames in the rubric are required.

| Task | File | What it must show |
| --- | --- | --- |
| A2 | `docs/lab1a-vpc.png` | VPC: name, CIDR `10.0.0.0/16`, DNS hostnames Enabled |
| A2 | `docs/lab1a-subnet.png` | `northstar-dev-public-1`, CIDR, AZ |
| A2 | `docs/lab1a-igw.png` | IGW Attached, VPC ID |
| A2 | `docs/lab1a-route-table.png` | `0.0.0.0/0 → igw-*` and subnet association |
| A3 | `docs/lab1a-s3-properties.png` | Versioning, SSE-S3, public access blocked |
| A3 | `docs/lab1a-s3-prefixes.png` | `raw/ processed/ features/ artifacts/` |
| A3 | `docs/lab1a-iam-role.png` | Trust relationships + Permissions tabs |
| A4 | `docs/lab1a-domain.png` | Domain InService with VPC/subnet/SG IDs |
| A4 | `docs/lab1-studio-shutdown.png` | Unchanged |
| B2 | `docs/lab1b-domain.png`, `lab1b-s3.png`, `lab1b-subnet.png`, `lab1b-iam-role.png` | Terraform-built resources in the console |

Do not rebuild anything to retake a screenshot. Renaming a file is
all that is ever needed.

**2. Architecture diagram source file.** Task A1 now
asks for `docs/lab1-architecture-diagram.drawio` (or the same
base name with your tool's native extension) instead of
`lab1-architecture-diagram-source.*`. Rename if needed.

**3. `scripts/verify-lab1.sh` was updated**
to also check for `docs/lab1-architecture-diagram.png`. If
you created your repo before today, replace your copy:

```
curl -fsSL https://raw.githubusercontent.com/byu-cs401r4-f26/cs401r-lab1-template/main/scripts/verify-lab1.sh -o scripts/verify-lab1.sh
```

Then re-run it **while your stack is still up** and
commit the fresh `docs/lab1-verify-output.txt`. If you have
already run `terraform destroy`, keep the output you have;
the old script's checks are still valid, you just will not have the
diagram line, and you do not need to redo anything.

The full list of everything that must be committed is in the new
**Submitting Lab 1** section at the end of the lab,
including a table of which tasks need screenshots and which do not.

Due date is unchanged: **Saturday, September 19,
midnight.** Tag `lab1-submit` and submit your repo URL
in Canvas.

---

## Lab 1 — NoSuchBucket from make local-validate: the bucket name needs the account ID

_Posted: 2026-09-17T02:45:07Z_

A student found a defect in the Lab 1 starter kit. If
`make local-validate` fails with
**`NoSuchBucket`**, this is why.

**The problem.** `infrastructure/README.md`
gave `"${var.project}-${var.environment}-data"` as the
bucket-naming example. That is incomplete. The Lab 1 spec (Architecture
Reference), the comment at the top of
`modules/storage/main.tf`, and the Makefile all expect the
AWS account ID appended:
`northstar-dev-data-<account-id>`. If you followed the
README line, your bucket is named `northstar-local-data` and
the Makefile is looking for
`northstar-local-data-000000000000`.

The suffix is not cosmetic. S3 bucket names are global across all of
AWS, so without it the second person in this class to run
`terraform apply` gets `BucketAlreadyExists`.

**The fix** — in `modules/storage/main.tf`,
read the account ID from the caller and use it in the name:

```
data "aws_caller_identity" "current" {}

locals {
  bucket_name = "${var.project}-${var.environment}-data-${data.aws_caller_identity.current.account_id}"
}
```

Use `local.bucket_name` for the
`aws_s3_bucket`. That one line gives
`northstar-local-data-000000000000` on LocalStack and
`northstar-dev-data-<your account>` on AWS with no
special-casing. Re-run `make local-validate`.

**The kit is fixed.** The README now shows the full
pattern, and the Makefile reads the bucket name from
`terraform output s3_bucket_name` instead of hardcoding it,
so a naming mismatch shows up in the rubric rather than as a confusing
`NoSuchBucket`. Updating is optional; your existing Makefile
works once the bucket name has the suffix. If you want the current
versions:

```
curl -fsSL https://raw.githubusercontent.com/byu-cs401r4-f26/cs401r-lab1-template/main/Makefile -o Makefile
curl -fsSL https://raw.githubusercontent.com/byu-cs401r4-f26/cs401r-lab1-template/main/infrastructure/README.md -o infrastructure/README.md
```

If you already ran `make local-validate` successfully,
nothing here applies to you.

---

## Lab 2 — new Makefile in the starter kit (use LOCAL_OUT= so you do not overwrite Lab 1 evidence)

_Posted: 2026-09-17T16:33:59Z_

The Lab 2 starter kit now includes a
**`Makefile`** that replaces the one you got in
Lab 1. Copy it over your existing one before you run LocalStack
validation for Lab 2.

**Why.** Your Lab 1 Makefile always writes its output to
`docs/lab1b-localstack-output.txt`. Running
`make local-validate` during Lab 2 would silently overwrite
your Lab 1 evidence. The new Makefile takes an output path:

```
make local-validate LOCAL_OUT=docs/lab2-localstack-output.txt
```

The Lab 2 assignment text has been updated to use that command. The
new Makefile also reads the bucket name from
`terraform output` (see yesterday's announcement) and
confirms that no NAT Gateway was created locally.

**To get it:**

```
curl -fsSL https://raw.githubusercontent.com/byu-cs401r4-f26/cs401r-lab2-template/main/Makefile -o Makefile
```

or download the Lab 2 starter kit zip from Canvas. Commit the new
Makefile with the rest of your Lab 2 work. If you have already created a
repo from the Lab 2 template today, check whether your
`Makefile` has a `LOCAL_OUT ?=` line near the top;
if it does, you already have the new one.

---

## Lab 2 corrections: time-window anchor, dedup key, and data contract template

_Posted: 2026-09-23T17:52:32Z_

I've corrected three errors in the [Lab 2 instructions](https://byu.instructure.com/courses/38938/assignments/1476008). The Canvas assignment and lab guide are updated. The starter kit and template repo didn't change, so you don't need to download anything new.

### 1. Task 3: anchor your time windows to `FEATURE_CUTOFF` (this one can change your results)

The lab said to compute recency and frequency windows "relative to the maximum `purchase_date` in the dataset." **That was wrong.** The latest date in the data is 2026-06-30, which is the end of the holdout window. If you measure from that date, the holdout leaks into your features. Every churner ends up with recency of at least 90 days and every active customer with less, so recency gives away the label.

**Do this instead:** measure every window backwards from `FEATURE_CUTOFF` (T = 2026-04-01), the constant already in `feature_engineer.py`. The starter script's docstring already said this. The lab text contradicted it.

**If you already wrote `compute_rfm_features` using `max(purchase_date)`, change it before you submit.** Here's how to check: with correct windows, the churn rate is about 22%, and the verify script's line `features: label not trivially separable by recency` reads PASS.

### 2. Task 2 rubric: deduplicate on `transaction_id`, not `customer_id`

The rubric row said the verify script checks for "no duplicate `customer_id` rows." That's backwards, and the script has always checked `transaction_id`. `processed/customers/` has **one row per transaction**, so each customer appears on many rows. Your processed output should have about 157,600 rows and 9,999 customers. If it has about 10,000 rows, you deduplicated on the wrong key.

### 3. Task 4 data contract template: added a Grain section

The template listed "No duplicate `customer_id` rows" as a quality guarantee. That contradicts the grain above, and your own data would violate it. The template now has a **Grain** section ("one row per transaction"), and the guarantee reads "No duplicate `transaction_id` rows." If you've already started your contract, update both lines.

If your code already follows the kit docstrings, you probably don't need to change anything. Lab 2 is still due **Saturday, October 3, at midnight**. Post questions in the discussion board or bring them to class.

---

## Lab 2/3 wording clarification: "holdout" is now "outcome window"

_Posted: 2026-09-24T16:16:38Z_

A wording clarification for [Lab 2](https://byu.instructure.com/courses/38938/assignments/1476008), with a matching change in Lab 3. **Nothing you have built needs to change.**

Lab 2's time split puts features before T = 2026-04-01 and takes `churn_label` from the 90 days after. It **builds your labeled rows. It is not a train/test split.** Every customer becomes one labeled row: 13 features describing their behavior up to T, paired with a ground-truth label saying whether they bought anything in the following 90 days. Churn is a fact about the future, so the label can only come from what happened after T.

The lab text used to call that label window the "holdout." In ML, "holdout" usually means a test set, and Lab 3 uses it that way. To avoid the collision, the lab text now calls the label window the **outcome window**. The train/test split happens in Lab 3, where you split the ~10,000 labeled rows into training and test sets. Lab 3's metrics table now says "AUC-ROC (test set)."

**No code changes.** The starter code still names that DataFrame `holdout` (in `split_windows` and `attach_churn_label`). Keep the name.

Lab 2 is still due **Saturday, October 3, at midnight**.

---

## Pre-Lab 3 simplified: Bedrock access is now a 10-minute check, due Friday Oct 2

_Posted: 2026-09-29T23:22:41Z_

[Pre-Lab 3](https://byu.instructure.com/courses/38938/assignments/1476014) is now much shorter, and the due date has moved to **Friday, October 2, at midnight**.

Several of you reported calling Bedrock models without going through the setup steps. You were right. AWS retired the Bedrock "Model access" page in October 2025. Models are now enabled by default, and third-party models subscribe themselves the first time you call them. Most of the old setup is unnecessary.

**What Pre-Lab 3 asks now:**

1. Run the verification script in Step 1 of the guide.
2. If both lines print `PASS`, you are done. Save the output to `docs/bedrock-access-verification.txt`.
3. If either line fails, Step 2 of the guide lists the exact error messages and the fix for each.

**Removed:** the manual model agreement step, the quota check, and the paragraph justifying a quota increase. The deliverable is now only the Step 1 output. If you already submitted the longer version, you don't need to change anything.

**Anthropic still requires a one-time use-case form.** If the Claude line fails with `ResourceNotFoundException: Model use case details have not been submitted`, submit the form (console or Python, both in the guide) and re-run the script.

**The one problem that still needs time:** if your very first Claude call returns `ThrottlingException: Too many tokens per day`, your account has a zero initial quota. That's the reason this pre-lab was assigned early. Waiting won't clear it, and the Service Quotas console may show normal numbers anyway. Open an AWS Support case as described in the guide, and send me the case ID the same day. If you're still blocked on Friday, submit the failing output and your case ID instead.

Track A of Lab 3 needs no Bedrock, so a pending Support case won't stop you from starting the lab.

---

## Pre-Lab 4 retired: Lab 4 now trains on spot, no quota request needed

_Posted: 2026-09-30T19:10:51Z_

[Pre-Lab 4](https://byu.instructure.com/courses/38938/assignments/1476015) is **retired**. You don't need an on-demand SageMaker training quota increase, and there's nothing to submit.

**Why.** On a new AWS account, the on-demand training quota is 0 for every instance type. That's why Pre-Lab 4 existed. Spot training is different: `ml.m5.large` spot training has a default quota of **4**. Lab 4's pipeline now trains on managed spot capacity (`use_spot_instances=True`, `max_wait=3600`), so it runs on a brand-new account with no request. I ran the full Lab 4 pipeline on spot today to confirm it. It trained, registered the model, and was billed for 54 seconds.

**If you already filed a request or submitted the file:** nothing is wasted and there's nothing to undo. A pending or approved quota costs nothing unless you run jobs against it, and your submission stays on record.

**What changed in the lab guides:**

* **Lab 4** no longer lists Pre-Lab 4 as a prerequisite. The quota section now explains the spot setting and why it matters. Keep `use_spot_instances=True` in your estimator. If you remove it, you're back to a quota of zero.
* **Lab 3** still doesn't require a SageMaker training job. If you want to run one, use the same spot setting. The guide now shows how.

[Pre-Lab 3](https://byu.instructure.com/courses/38938/assignments/1476014) is unaffected and still due **Friday, October 2, at midnight**.

---

## Lab 3: teardown script added to the starter kit (plus two guide fixes)

_Posted: 2026-10-01T23:06:20Z_

The [Lab 3](https://byu.instructure.com/courses/38938/assignments/1476009) starter kit was missing `scripts/teardown-lab3.sh`, the script the Teardown section tells you to run. Its output, `docs/lab3-teardown-output.txt`, is the Task 4 teardown gate. It's now in the kit.

**Get it one of two ways:**

* Download the Lab 3 starter kit from Canvas again, or
* Copy `scripts/teardown-lab3.sh` from [cs401r-lab3-template](https://github.com/byu-cs401r4-f26/cs401r-lab3-template/tree/main/scripts) into the `scripts/` folder of your repo.

Nothing else in the kit changed, so don't overwrite your other Lab 3 files.

**How to read the output.** A clean account ends with *"Lab 3 teardown complete"* and every line marked `OK`. If any line says `CHECK FAILED`, the AWS call itself didn't work. That usually means expired credentials or the wrong profile or region. Fix that and re-run. Don't submit a file that has `CHECK FAILED` or `STILL PRESENT` in it.

Two smaller wording fixes in the Lab 3 guide, both left over from the Pre-Lab changes:

* The **Task 4 Bedrock row** now matches the simplified Pre-Lab 3. It needs the verification file with both checks `PASS`, or the failing output plus your AWS Support case ID. No quota justification.
* The cost table no longer says you need a training quota increase. Training jobs are optional in Lab 3, and if you run one, use spot.

---

## Lab 2 teardown script fix (replace it before you submit) + Lab 4 heads-up

_Posted: 2026-10-01T23:18:28Z_

**[Lab 2](https://byu.instructure.com/courses/38938/assignments/1476008): updated teardown script.** `scripts/teardown-lab2.sh` had a bug. If an AWS call failed, usually because of expired credentials or the wrong profile, its final check still printed `OK`. That could produce a teardown report that says "clean" while resources such as a NAT Gateway or the Studio EFS volume keep billing.

The new version:

* stops immediately, without deleting anything, if the AWS CLI isn't authenticated
* marks any check whose AWS call fails as `CHECK FAILED` and exits with an error, instead of printing `OK`

**What to do:** replace `scripts/teardown-lab2.sh` in your repo with the new copy. Get it from the Lab 2 starter kit on Canvas or from [cs401r-lab2-template](https://github.com/byu-cs401r4-f26/cs401r-lab2-template/tree/main/scripts). Don't overwrite any other files.

**If you already ran it:** the old version gave a wrong answer only when AWS calls failed. If your run ended with "Teardown complete", you're very likely fine. To be certain, run the new version once. It's safe to run again on an account that's already torn down. Your submission needs a report with every line `OK`. Don't submit one that shows `CHECK FAILED` or `STILL PRESENT`.

Lab 2 is still due **Saturday, October 3, at midnight**.

---

**Heads-up for [Lab 4](https://byu.instructure.com/courses/38938/assignments/1476010) (opens Oct 15).** Lab 4's CI/CD pipeline trains *your* Lab 3 churn model. The Lab 4 starter kit includes `models/churn/churn_model.py`. You'll fill in its `train()` function using your Lab 3 preprocessing, model, recency baseline and `evaluate_model()`. The function returns the trained model plus the metrics the Lab 4 tests check: precision and recall in the top 10%, and the lift confidence interval. It runs on SageMaker spot capacity, so you don't need a quota request. Nothing to do now. Keeping your Lab 3 training code in clean, separate functions will make that step quick.

---

## Lab 2: commit your verify output before teardown (+ clarifications)

_Posted: 2026-10-02T17:55:27Z_

**[Lab 2](https://byu.instructure.com/courses/38938/assignments/1476008): one new file to commit before teardown, plus clarifications.** The lab page has been updated ahead of tomorrow's deadline (Sat Oct 3, midnight).

**Already submitted?** If you tagged `lab2-submit` and submitted in Canvas before this announcement, you do **not** need to produce the new file in item 1 or change your apply log (item 3). You will not lose points for either. Do not move your tag. Item 2 still applies to you if you have not yet committed your destroy output.

1. **New deliverable: `docs/lab2-verify-output.txt`.** While your stack is still deployed and both Glue jobs have succeeded, run:  
   `bash scripts/verify-lab2.sh 2>&1 | tee docs/lab2-verify-output.txt`  
   Commit it, then tag. *Why:* the TA has no access to your AWS account, and your infrastructure is gone by grading time. This file is the evidence for most of the Task 1–3 rubric. It cannot be regenerated after teardown.
2. **Destroy output goes on `main`, after you tag.** You tear down after you submit, so `docs/lab2-destroy-output.txt` can never be inside the tagged commit. Commit it to `main` and leave `lab2-submit` where it is. The TA checks the destroy output on `main`, separately from the tag.
3. **Append, don't overwrite, the apply log.** Tasks 2 and 3 each run `terraform apply` again. Use `tee -a ../../../docs/lab2-extend-output.txt` for those runs so the record of the SageMaker domain change from Task 1 survives.
4. **Correction: an `event_time` type mismatch is not silent.** The lab previously said `PutRecord` accepts a mismatched value and silently drops it. Tested on AWS: it rejects the call with a `ValidationError` naming the feature, and the feature job fails. If your feature engineering job failed at the ingest step, check that `event_time` is declared `Fractional`.
5. **Spec clarifications (nothing new to build).** The Architecture Reference now lists the security group's self-referencing ingress rule and the Glue `NETWORK` connection. Both were already required, as the Task 2 callout described. The infrastructure connection map is also corrected: the *public* route table sends `0.0.0.0/0` to the Internet Gateway, not to the NAT Gateway. Check your diagrams against it.

No starter-kit file changed in a way that affects your work. Two comment and message strings were corrected; you do not need to re-download.

---

## Lab 2 submission instructions clarified

_Posted: 2026-10-03T23:35:46Z_

Lab 2 submission instructions were clarified today. If you already tagged `lab2-submit`, you do not need to redo anything.

If you have not yet torn down, run `verify-lab2.sh` and commit its output (`docs/lab2-verify-output.txt`) before tagging. After teardown, push `docs/lab2-destroy-output.txt` to `main` and leave the tag in place.

---

## Lab 3: what to commit as evidence (new script, no penalty this term)

_Posted: 2026-10-12T18:19:34Z_

Lab 3 now spells out exactly what evidence to commit for each rubric item. The TA grades your `lab3-submit` tag and cannot see your AWS account, so your MLflow runs, your Model Registry entry and the Athena query behind your training data do not count until they are in your repo. The lab never said that clearly. That's on me, and it is fixed.

**What changed** (details in the [Lab 3 assignment](https://byu.instructure.com/courses/38938/assignments/1476009), new section *Evidence You Submit*):

* Every rubric table now has an **Evidence** column naming the exact file.
* A new script, `scripts/collect-lab3-evidence.sh`, exports your MLflow runs, registry versions and Athena query into `docs/lab3-evidence/`, checks every required file, and confirms your reported numbers match what you tracked and registered.
* Your evaluation report now goes in its own file, `docs/lab3-evaluation-report.md`. Your demo notebook goes in `notebooks/lab3-demo.ipynb`, committed with its outputs.

**What to do**

1. Download the updated [Lab 3 starter kit](https://byu.instructure.com/courses/38938/files/14452900) and copy the two new files, `scripts/collect-lab3-evidence.sh` and `scripts/collect_lab3_evidence.py`, into your repo's `scripts/` folder. Nothing else in the kit changed, so do not overwrite your own work.
2. In your training code, print the Athena query ID after the query runs (the one-liner is in Task 1).
3. Run your final training run with `--output-data-dir docs/lab3-evidence` and save its output with `2>&1 | tee docs/lab3-evidence/train-final.log`.
4. Before teardown: `bash scripts/collect-lab3-evidence.sh --track B` (or `--track C`). Fix anything marked FAIL and run it again. Then tear down, commit, tag and push.

**Grading this term:** because this was added five days before the deadline, **missing evidence files will not cost you points on Lab 3.** If the TA cannot confirm an item from your repo, they will ask you for a short screen-share instead. Submitting the evidence is still the fastest route to full marks with no follow-up. The deadline does not change: Saturday, Oct 17, 11:59 PM.

Questions: post in the discussion board or come to office hours.

Dr. T

---

## Lab 3 Track B: RAGAS targets no longer graded (here's why, and what counts)

_Posted: 2026-10-12T19:04:36Z_

**Track B students: the RAGAS targets are no longer graded.** If your offer-generation scores will not reach faithfulness 0.80, answer relevancy 0.75 and context recall 0.70, the problem is not your pipeline or the model.

We built a careful pipeline from the starter kit and ran it through the same evaluation harness you have. It scored faithfulness 0.47–0.68, answer relevancy 0.38–0.45 and context recall 0.53–0.58. Even with the *entire* policy corpus handed to the judge, context recall cannot get above about 0.67. The harness's ground truths include statements the policy documents never make, and answer relevancy was designed for question answering, not for writing offers. A stronger model does not fix this: switching the judge to Claude Sonnet left the scores unchanged. That is our defect, and it is fixed for next year.

**What the 15 evaluation points are for now** (details in the [Lab 3 assignment](https://byu.instructure.com/courses/38938/assignments/1476009), Track B):

* **5:** run the harness on all 4 cases at least twice; report per-case scores, the mean and the range; name the judge model.
* **6:** for each metric, explain specifically what limits it, citing a case or a claim.
* **4:** make one change to your pipeline and report before/after scores. A change that did not help still earns full marks if you measured it honestly.

**Three things that measurably help:**

* Add the customer profile as an extra entry in `contexts`. The judge cannot see the profile otherwise, so it marks every profile fact in your offer as unsupported. This lifted faithfulness from 0.38 to 0.60 in our run.
* Cut filler and invented terms ("We've missed you!", "use within 14 days"). Each one counts as an unsupported claim.
* A `NaN` score means a judge call failed (usually Bedrock throttling). It is not a zero. Re-run it.

If you already wrote up why you missed the targets, you have probably done most of the diagnosis. Keep it. The deadline is unchanged: Saturday, Oct 17, 11:59 PM.

Dr. T

---

## Lab 3 Track C now runs on Amazon Bedrock AgentCore (+ harness fix)

_Posted: 2026-10-14T21:43:49Z_

Class,

**If you chose Track A + Track B, nothing below changes your work**, apart from the one-line note at the end.

### Track C changed on Oct 12

Track C (the customer service agent) no longer asks you to write the agent loop yourself. You now deploy the agent on **Amazon Bedrock AgentCore**, AWS's platform for running agents in production, with Terraform:

* **Harness:** AWS runs the agent loop (Claude Haiku 4.5).
* **Gateway:** serves the five NorthStar tools from one Lambda function.
* **Policy:** a Cedar rule at the gateway enforces the $50 credit cap *before* the tool runs, so it holds even if the model is talked out of it.

The starter kit provides almost all of it, in a **separate Terraform root** (`infrastructure/environments/agent/`). Your work is three marked `TODO (student)` items in `main.tf`, then proving the cap with `agent/policy_tests.py`, then running the evaluation. **Do not touch your Labs 1–2 Terraform:** its AWS provider version has no AgentCore support, which is why the agent has its own root.

Read the new *Track C* section of the Lab 3 guide before you start. It covers prerequisites (boto3 ≥ 1.43.57, AWS CLI ≥ 2.36), what each TODO's error looks like, and the cost rule: **leave the 60-second idle timeout alone.** At AWS's default, the same evaluation costs about five times as much. The rubric is still 35 points; Track C's evaluation item now includes the policy tests.

Get the updated kit from Canvas (*Lab Starter Kits*) or [cs401r-lab3-template](https://github.com/byu-cs401r4-f26/cs401r-lab3-template). The new and replaced files are `agent/`, `infrastructure/environments/agent/`, `scripts/teardown-lab3.sh` and `scripts/collect_lab3_evidence.py`. The teardown script now also destroys the agent stack.

### Evaluation harness fix (Oct 14)

`LocalAgentEvaluator(...).run(...)` in `evaluation_harness.py` crashed with `KeyError: 'tool_calls_made'`. It is fixed in the kit. If you hit that error, re-download `evaluation_harness.py`, or call `evaluate_scenario` once per test case as the Track C section shows. Track B is not affected.

### One note for everyone (Track A)

You do **not** need a SageMaker training job. Training locally with the `xgboost` library meets every Track A rubric item. Use the `sagemaker.xgboost` estimator only if you choose to run a job, and then on spot capacity, as the guide describes.

The due date (Sat Oct 17) is unchanged.

— Professor Toborg

---

## Lab 4 updated before you start: new starter kit files and one IAM change

_Posted: 2026-10-20T00:38:11Z_

Class,

Before Lab 4 opened for real work, we ran it end to end the way you will: a repository with the Lab 1 to 4 kits, the CodePipeline stack from the kit, and real pushes to GitHub. The first runs failed for reasons that were ours, not yours, so the lab and starter kit have been corrected. **If you haven't downloaded the Lab 4 kit yet, nothing below needs action;** just use the current kit.

### If you already downloaded the Lab 4 kit

Download it again from Canvas, or pull the files from the [lab4 template repo](https://github.com/byu-cs401r4-f26/cs401r-lab4-template), and replace your copies. What changed:

* **New: `requirements.txt` and `pytest.ini`.** Without the first, every CodeBuild run failed before a single test. Without the second, plain `pytest tests/` couldn't import your `data/feature_engineering.py`.
* **`tests/test_features.py`:** `avg_basket_size_6m` is now checked as *items per order* (5.0), matching your Lab 2 definition. The old assertion expected dollars.
* **`tests/test_model.py`:** the recency monotonicity test now allows ties. The old version failed a correctly behaving tree model.
* **`tests/test_data.py`:** the hint for the leakage TODO was wrong and is corrected.
* **`buildspec.yml` and `pipeline.yaml`:** your `test_fairness.py` now runs in the pipeline. A model registered by a build that later fails is automatically set to `Rejected`. `GitHubRepo` must be your repo, `cs401r-<your-netid>`.

### One change to your own Terraform

Your MLEngineer role has to be allowed to pass itself to SageMaker, or the training step fails with `not authorized to perform: iam:PassRole`. The exact statement is under **prerequisite 4** in the lab instructions. Add it to `modules/iam/main.tf` and `terraform apply`.

### How Task 2 is graded

The TA can't access your AWS account, so the pipeline items are graded from evidence files committed in `docs/`: your pipeline runs, and the deliberate-failure demonstration with the alarm history. The lab instructions list them, along with cost and teardown steps. Point values haven't changed.

Two practical notes. Re-run your Lab 2 feature job (about 90 seconds) at the start of any session in which you'll push, because a feature set older than 48 hours fails the build by design. And every push to `main` runs a short training job, so delete the CI stack before your final docs-only push.

Due date unchanged: Sat Oct 31.

---

## AI Product Management Bootcamp/Dinner/Career Fair: https://marriott.byu.edu/event/ai-pm-bootcamp2026 coupon code: BYUSTUDENT50

_Posted: 2026-10-20T22:40:35Z_

![image.png](https://byu.instructure.com/courses/38938/files/14122613/preview)

---

## Final Project: form your team by Nov 5, topics due Nov 12

_Posted: 2026-10-25T01:18:46Z_

Time to form final project teams. There are two parts, 5 points each, and both count toward the Final Project category (10 of its 100 points).

### Part 1: [Team Sign-Up](https://byu.instructure.com/courses/38938/assignments/1476016), due Thu Nov 5, 11:59 PM

* Teams must have **3 or 4 students**. I won't accept teams of 2 or of 5+.
* Every member joins the **same group** under [People → Groups → Final Project](https://byu.instructure.com/courses/38938/groups). Pick any empty group; the name doesn't matter.
* Once everyone has joined, **one member** submits the team name and roster (full names + NetIDs) using the template in the assignment. That submission counts for the whole team.
* After Nov 5, I'll rename each Canvas group to your team name.

### Part 2: [Team Project Topics](https://byu.instructure.com/courses/38938/assignments/1515794), due Thu Nov 12, 11:59 PM

* Submit 2 or 3 ranked candidate topics: a production AI system for a company and a use case of your choosing. Again, one submission per team.
* For each topic, describe the business problem, the AI approach, the data sources, and what makes it hard. The template is in the assignment.
* Pick something that exercises every layer of the course. A chatbot over one PDF won't cut it.
* I'll review your topics and give you feedback and approval before the end of the week.

Final project documents make up the other 90 points and are due Dec 17. I've updated the syllabus to match. There will be other preliminary milestone requirements to keep you on track. I'll post these assignments once the teams are formed.

Can't find a team? Use the class Discord to post your project ideas and solicit participation. I'll leave time at the end of class this week to talk with potential team members. If you are still struggling to find a team by Nov 5th, I will assign you to a team.

---

## Lab 5 updates: teardown script, CI security step, two IAM/S3 prerequisites, Lab 2 teardown fix (read before you deploy)

_Posted: 2026-11-10T19:40:29Z_

Class,

Lab 5 has five corrections. Some went into the handout on November 5 and the rest on November 7. I should have sent this when the first ones went in, and I'm sorry it's late. The due date is unchanged: **Saturday, November 14, midnight.**

The Lab 5 assignment page now opens with a **Submitting Lab 5** section that lists every file the TA grades, plus copy-paste commands that capture the evidence while your endpoint is live. Read that section before you deploy. Most Task 1 evidence cannot be recreated once the endpoint is deleted. Each rubric table also has a new **Evidence** column that names the exact file the TA grades for each item. No criteria or points changed.

**1. The teardown script is now in a Lab 5 starter kit.** The handout told you to run `scripts/teardown-lab5.sh`, but no starter kit included it. That was my mistake. Download **Lab5 Starter Kit** from the Week 10 module, or copy the file from <https://github.com/byu-cs401r4-f26/cs401r-lab5-template>, and put it at `scripts/teardown-lab5.sh` in your repo. It deletes everything Lab 5 bills for, checks the live API, and writes `docs/lab5-teardown-output.txt`, the file the teardown gate checks.

If you already deployed and tore down by hand, you do not need to redeploy. Instead, run these three commands and commit the output in `docs/lab5-deployment-output.txt`; the TA will accept it in place of the teardown file:

```
aws sagemaker list-endpoints --query 'length(Endpoints)' --output text
aws sagemaker list-endpoint-configs --query 'length(EndpointConfigs)' --output text
aws application-autoscaling describe-scalable-targets --service-namespace sagemaker --query 'length(ScalableTargets)' --output text
```

All three must print `0`. You can also just run the new script now; it is safe on a clean account.

**2. Do not uncomment the `bandit` block in your Lab 4 `buildspec.yml`.** The placeholder block breaks the YAML if you uncomment it (`if highs:` reads as a mapping key), and CodeBuild rejects the whole file. For the Task 5 security step, use these three lines in `pre_build` instead:

```
      - echo "Running security scan"
      - pip install --quiet bandit
      - bandit -r models data -lll
```

**3. Prerequisite 5: add one IAM statement before you enable data capture.** The endpoint writes captured data using its execution role, your MLEngineer role, and that role can only write to `artifacts/` and `features/`. Without the statement below, capture fails **silently**: the endpoint is healthy and nothing is ever written. Lab 6 then has no data to analyze. Add this to the MLEngineer policy, `terraform apply`, and wait 30 seconds:

```
      {
        Sid      = "S3DataCaptureWrite"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:AbortMultipartUpload"]
        Resource = "${local.bucket_arn}/datacapture/*"
      },
```

**4. Prerequisite 6 (new Nov 7): make the 7-day capture rule actually delete.** Your Lab 2 `expire-datacapture` lifecycle rule expires captured data after 7 days, but your bucket is versioned. On a versioned bucket, expiring an object only hides it behind a delete marker. The captured inputs and scores stay in the bucket as an old version indefinitely, which undercuts the retention claim in your Task 4 privacy assessment. Add this block **inside** the existing `expire-datacapture` rule in `modules/storage/main.tf` (not as a new rule, because `verify-lab2.sh` checks for exactly five), then `terraform apply`:

```
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
```

Prerequisite 6 in the handout has a one-line command that confirms it.

**For items 3 and 4:** if you already deployed without them, your Lab 5 grade is not affected. Neither is graded in Lab 5. Add both anyway before Lab 6, which redeploys the endpoint and analyzes the captured data.

**5. Replace `scripts/teardown-lab2.sh` before you run it again.** The old version deleted *every* SageMaker lineage record in your account, not just Lab 2's. Run after Lab 4, that wiped your Model Registry's lineage along with your deployed endpoint's lineage. It also counted the leftover records from other labs as a failure and printed "Resources may still be billing" when nothing was. Lineage is metadata that AWS doesn't bill for. The new version removes only the feature group's lineage and reports the rest without failing. Get it from the Lab 2 starter kit on Canvas or <https://github.com/byu-cs401r4-f26/cs401r-lab2-template>.

Also, **wait about 15 minutes after your last Glue job before running `teardown-lab2.sh`.** Glue's network interfaces stay attached for several minutes after a job finishes, and `terraform destroy` will sit on `Still destroying...` for the subnet. If that happens, the Lab 5 *Teardown* section has a loop that clears the interfaces, and `destroy` then finishes on its own.

Questions go to the TA or office hours. And delete your endpoint when you're done. It bills until you do.

---

## Final Project: Please review the PPT from week 9 entitled "Final_Project_F26." Project Charter due date moved to Nov. 21. 

_Posted: 2026-11-17T23:30:15Z_

Dear Students,

I've created an assignment for the Project Charter. The due date has been pushed to Nov. 21st. Other project milestones are suggested in the PPT. However, I will not be grading any other milestones until the presentations and final submissions. The remaining milestones are suggestive. You should determine your own and document them in the Charter.

All the best,

Dr. T.

---

## Lab 6 starter kit is now available (the scripts the handout references)

_Posted: 2026-11-18T21:40:23Z_

Class,

Several of you asked where to find the scripts Lab 6 tells you to
run. They weren’t anywhere you could get to. The handout referenced
them, but I never shipped a Lab 6 starter kit. That’s my mistake, and
I’m sorry it cost you time. The due date is unchanged: **Saturday,
November 28, midnight.**

**Where to get it.** Download **Lab6 Starter
Kit** from the Week 11 module, or copy the files from
https://github.com/byu-cs401r4-f26/cs401r-lab6-template. Unzip it at the
root of your `cs401r-<netid>` repo. Every file lands at
the path the handout uses:

* `scripts/preflight-lab6.sh`: run this first. It checks
  data capture, the execution role, and processing quota before you spend
  anything.
* `scripts/teardown-lab6.sh`: stops in-flight processing
  jobs before it deletes the endpoint, and writes
  `docs/lab6-teardown-output.txt`.
* `monitoring/run_evidently_job.py`: launches the Evidently
  drift analysis as a processing job.
* `monitoring/evidently_drift.py`: the analysis that runs
  inside the job.
* `deployment/configs/canary_deploy_realtime.py` (plus
  `sample.csv`): rolls a new endpoint config with data capture
  on. You only need it if your Lab 5 endpoint was deployed without
  capture.

**One function is yours to write.** In
`evidently_drift.py`, `drift_direction()` is a
stub. It decides whether a test result means drift. Read the “single
most dangerous defect” note in Task 1 before you write it. The launcher
refuses to start a job until the stub is replaced, so you won’t pay for
a run that was going to fail. `DRIFT_PLAN` in the same file
is a starting point; change it to match the tests and thresholds you
choose in Task 2.

**You write the metric publisher yourself.** The handout
used to say `publish_metrics.py` publishes your drift metric.
That file is not part of the kit. Publishing your drift and
business-layer metrics to CloudWatch is part of Task 1. Do it from your
laptop after the job returns, not from inside the processing job. The
handout explains why.

**If you already wrote your own versions** of any of
these, you can keep them. Still run
`scripts/teardown-lab6.sh` when you finish. It’s safe on a
clean account.

The Starter Kit section of the Lab 6 handout has been updated to
match. Questions go to the TA or office hours. And delete your endpoint
when you’re done. It bills until you do.

---

## Lab 6: two new prerequisites and an updated starter kit (read before you run the drift job)

_Posted: 2026-11-18T23:03:33Z_

Class,

After this afternoon’s announcement I ran Lab 6 end to end on AWS
with the new kit, the way you will. It turned up problems that would
have stopped every one of you. They’re fixed now, and the handout
explains each one. The due date is unchanged: **Saturday, November
28, midnight.**

**1. Create the `ModelMonitorExecution` role (new
Prerequisite 2).** The handout said this role came from Lab 2. It
never did, so the drift job had no role to run as. Prerequisite 2 now
has the Terraform: add it to `infrastructure/modules/iam/`,
run `terraform apply`, and wait 30 seconds.
`scripts/preflight-lab6.sh` checks the role and prints the
ARN to pass as `--role-arn`.

**2. Give two existing roles permission to publish metrics (new
Prerequisite 3).** Your endpoint publishes CPU and memory metrics
as MLEngineer, and your Glue jobs publish job metrics as DataEngineer.
Neither role is allowed to, so nothing errors and those two dashboard
layers stay empty. Prerequisite 3 has one statement for each policy.
After `terraform apply`, endpoint metrics appeared within
about three minutes on the reference account. You don’t need to
redeploy.

**3. Download the starter kit again.** Week 11 module,
or https://github.com/byu-cs401r4-f26/cs401r-lab6-template. **If
you’ve already written `drift_direction()`, don’t unzip over
`monitoring/evidently_drift.py`**; it would put the
stub back. Copy only the new `load_capture` function into
your file. Changes:

* `evidently_drift.py` drops duplicate payloads. The deploy
  script sends `sample.csv` 200 times to check the traffic
  split, and capture keeps every call. On clean traffic those copies alone
  made two features look drifted.
* `run_evidently_job.py` uploads the analysis script under
  `monitoring/`, which the new role can read.
* `teardown-lab6.sh` no longer reports a clean region as
  still running.
* The kit no longer includes
  `deployment/configs/sample.csv`. The earlier kit overwrote
  your Lab 5 file. If yours was replaced, restore it with
  `git checkout lab5-submit -- deployment/configs/sample.csv`.
  Your Lab 5 grade isn’t affected; it’s graded at your
  `lab5-submit` tag.

**If you already ran a drift job** and it failed, or it
reported drift on a KS feature, rerun it after these changes.

Questions go to the TA or office hours. And delete your endpoint when
you’re done. It bills until you do.

---

## Lab 6: add two IAM keys before you re-run a Glue job

_Posted: 2026-11-19T15:54:49Z_

Class,

One more Lab 6 fix, and it’s short. The due date is unchanged:
**Saturday, November 28, midnight.**

Prerequisite 3 asks you to re-run your Glue jobs so the pipeline
layer of your dashboard has metrics. On a stack that already has output
from an earlier run, **that re-run fails** with an error
like:

```
AccessDenied ... s3:PutObject on resource: "arn:aws:s3:::northstar-dev-data-<account>/processed_$folder$"
```

It isn’t your script. Both Glue jobs write with
`.mode("overwrite")`. On a re-run, Glue deletes the old
output and writes a small marker object at the bucket root, outside the
prefixes Lab 2 gave DataEngineer. The first run of each job works and
every re-run fails. I reproduced both failures on AWS last night and
verified the fix.

**The fix:** add these two lines to the
`S3DataPrefixesReadWrite` resource list in your DataEngineer
policy (`infrastructure/modules/iam/main.tf`), then
`terraform apply` and wait 30 seconds:

```
          "${local.bucket_arn}/processed_$folder$",
          "${local.bucket_arn}/features_$folder$"
```

Grant those two exact keys, not the whole bucket. If your stack is
freshly applied and you haven’t run the jobs yet, you don’t strictly
need them, but add them anyway. Prerequisite 3 in the handout and the
Lab 2 handout both show them now.

Your Lab 2 and Lab 4 grades aren’t affected.

Questions go to the TA or office hours.

---

## Lab 6: what to submit, and one evidence file to capture before you tear down

_Posted: 2026-11-20T03:38:18Z_

Class,

The Lab 6 handout now has a full **Submitting Lab 6**
section, near the top. Read it before you deploy anything. The due date
is unchanged: **Saturday, November 28, midnight.** No
criteria or points changed.

**What's in it:**

* A table of the five tasks: points, what you build, and where each
  piece goes in your repo.
* The complete list of files the TA grades, and what each one must
  show.
* A copy-and-paste capture block that writes
  **`docs/lab6-monitoring-output.txt`**.
* Checks to run before you tag `lab6-submit`.

**Why the new file matters.** The TA grades your
repository, never your AWS account. By the deadline your endpoint has to
be deleted, and the TA has no access to your account anyway. So the
evidence that your dashboard layers, drift jobs, custom metrics and
alarms actually worked has to be committed.
`docs/lab6-monitoring-output.txt` is that evidence. The
dashboard rubric line (15 points) is graded from your dashboard JSON
**plus** this file. A layer with no evidence in the file
doesn't count.

**The timing is the part to get right.** Most of the
file can only be captured **while your endpoint is
live**:

1. Do the AWS work: endpoint with data capture, baseline, drift job,
   publisher, alarms, dashboard.
2. Run **Window 1** of the capture block *before*
   you tear down.
3. Open the file and read it. If a section is empty or shows
   `AccessDenied`, fix it and re-run while the endpoint is still
   up. An empty infrastructure or pipeline section almost always means
   Prerequisite 3 (the two `PutMetricData` grants) is
   missing.
4. Run `scripts/teardown-lab6.sh`, then **Window
   2**.

**If you already tore down** without capturing, you'll
need to redeploy and re-run the capture. A focused hour with the
endpoint up costs well under a dollar. Your earlier drift reports and
dashboard JSON are still good; you're capturing the proof that they
ran.

Two reminders from the handout that cost people points:

* `ModelLatency` is in **microseconds**. A 200
  ms threshold is `200000`.
* Name your alarms with `northstar` in them. The capture
  block and the teardown script both find alarms that way.

Questions go to the TA or office hours.
