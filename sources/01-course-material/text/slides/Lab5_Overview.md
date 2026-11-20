# Lab5_Overview.pptx (extracted slide text)


## Slide 1
- CS 401R · Lab 5 Overview
- Deployment & Scaling + Security
- Ship the churn model to production, and prove it is safe to run
- Engineering the AI Enterprise · Fall 2026
- Assigned
- Sat Oct 31
- Due
- Sat Nov 14, midnight
- Builds on
- Labs 1–4 · no starter kit
- Submit
- Tag lab5-submit, then repo URL in Canvas
> Notes: Question: What does Lab 5 ask you to do, and when is it due?  Lab 5 takes the churn model you trained in Lab 3 and registered in Lab 4, and puts it into production the way an enterprise would: behind a controlled rollout, with a rollback you can trigger, and with its security and privacy posture written down.  The logistics are on the right. Assigned Thursday October 29, due Saturday November 14 at midnight. There is no starter kit: everything you need is already in your repository from Labs 1 to 4. Keep working in the same cs401r repository, and submit by tagging lab5-submit.  Transition: Let's start with the shape of the work, from an unapproved model to a torn-down endpoint.

## Slide 2
- What You Build in Lab 5
- The path every submission follows
- 1
- Approve the model
- 2
- Deploy with a controlled rollout
- 3
- Observe for 60 minutes
- 4
- Promote or roll back
- 5
- Document security and privacy
- 6
- Tear down and verify
- Live after Lab 5
- The NorthStar churn model, serving behind a canary, blue/green or batch shadow run
- Still in staging
- Offer generation or the agent; promoted in Lab 6, once monitoring is in place
- Before Task 1: Lab 4 left your model as PendingManualApproval. Approve the version you deploy with update-model-package, and record who approved it and against which metrics. "It was already approved" is not an answer.
- 2
> Notes: Question: What is the path from a registered model to a live, governed release?  Six steps, in order. Approve the model. Deploy it behind a controlled rollout. Observe for 60 minutes. Promote it or roll it back. Document security and privacy. Then tear everything down and prove it.  Step one is easy to miss. Lab 4 registered the model as PendingManualApproval, and nothing in Labs 1 to 4 ever approves it. You approve it yourself with update-model-package, and your deployment plan records who approved it and against which metrics. "It was already approved" does not count: the point is that a human reviewed the numbers and signed off.  What is live afterward: only the churn model. The offer-generation system or the agent stays in staging and gets promoted in Lab 6, once monitoring exists to watch it.  Transition: Here is how those steps turn into points.

## Slide 3
- Five Tasks, 100 Points
- Task 1
- 30 pts
- Task 2
- 20 pts
- Task 3
- 25 pts
- Task 4
- 15 pts
- Task 5
- 10 pts
- Task 1 · 30
- Production deployment
- Controlled rollout, rollback alarm as code, scaling or quota diagnosis
- Task 2 · 20
- Deployment plan
- 600–900 words a teammate who has never seen it could run
- Task 3 · 25
- Security assessment
- STRIDE threat model and data classification
- Task 4 · 15
- Privacy & compliance
- Data inventory, one lawful basis, data minimization, and erasing one customer from four stores
- Task 5 · 10
- Repository quality
- No secrets, configs as code, a security check in CI
- Plus a teardown gate: no teardown evidence and Task 1 is capped at half credit; an endpoint still running after the deadline costs another 10 points.
- 3
> Notes: Question: Where do the 100 points come from?  Five tasks. Task 1, the production deployment, is the biggest at 30. Task 3, the security assessment, is next at 25. The deployment plan is 20, privacy and compliance 15, and repository quality 10. Privacy has four required parts: an inventory of the personal data, one justified lawful basis, what was left out of training, and erasing one customer from four data stores.  Notice that only Task 1 is mostly hands-on AWS work. The other 70 points are about writing things a stranger could act on: a plan, a threat model, a privacy assessment, and a clean repository. That balance is deliberate. Operating a model safely is as much documentation as deployment.  The red bar is not points but a gate. Without teardown evidence, Task 1 is capped at half credit. And if an endpoint is still running after the deadline, you lose another 10 points on top.  Transition: Task 1 starts with a choice between two deployment paths.  Notes: Task 4 is a privacy impact assessment for the churn model. It’s worth 15 points and goes in the same file as Task 3, docs/lab5-security-assessment.md. Task 3 asks how the system could be attacked; Task 4 asks whether NorthStar should be processing this personal data at all, and what it must do when a customer asks to be forgotten. It has four required sections: 1. Personal data inventory: what personal data is processed, and at which stage of the pipeline Students trace customer data through the platform they built: Ingestion (raw/): names, emails and transaction history arrive with direct identifiers. Processing (processed/): the ETL step strips the identifiers and the customer becomes a synthetic customer_id. Feature Store: behavioral features (RFM, category diversity, channel mix) keyed by customer_id. Training data: the snapshot the model learned from. Inference: data capture logs inputs and predictions, and the scores go to marketing. A good answer points out that the synthetic customer_id is still personal data under GDPR. It’s pseudonymized, not anonymized, because NorthStar can map it back to a person. 2. Lawful basis: why NorthStar may use purchase history to predict churn (5 points) GDPR requires one legal justification for each processing purpose. Students pick one of three and defend it for NorthStar’s retention use case. How each holds up: Legitimate interests: the usual argument for retention analytics. NorthStar has a real business interest, and customers can reasonably expect a retailer to analyze their purchases. It requires weighing that interest against the customer’s rights, and customers can object to this kind of profiling. Contractual necessity: weak here. Predicting churn isn’t necessary to fulfill the purchase contract; the sale goes through without it. Consent: possible, but it must be freely given and can be withdrawn at any time, which makes it fragile for a model trained on everyone’s history. The rubric doesn’t require a particular answer. It wants one basis, explained with NorthStar specifics. Answers that list all three without choosing, or justify one generically, lose points. 3. Data minimization: what was considered for training and left out as unnecessary Examples: names, emails and addresses (direct identifiers removed at the ETL step), payment details, raw clickstream detail (only aggregates kept), and demographics such as age or gender, which also raise fairness concerns. The point is to show that each piece of data used earned its place. 4. Right to erasure: delete customer C00123456 from four places (6 + 4 points) For each place, students give a concrete step: (a) Raw S3 data: remove the customer’s rows from the raw files. The catch: the Lab 1 bucket has versioning on, so deleting or rewriting a file leaves earlier versions behind. Every old version containing the customer must go too. (b) Feature Store: the rubric requires separating the two halves.  Online store: DeleteRecord removes the current record. Offline store: it’s an append-only history in S3. Deleting a record adds a “deleted” entry rather than removing the past rows, so true erasure means rewriting the historical files. (c) Model training data: remove the customer from training datasets and snapshots so future training runs exclude them. (d) Inference logs: find the customer’s entries in data-capture files and logs, rewrite or purge them, and keep retention periods short. Which step is hardest, and why (4 points): the trained model, or the offline Feature Store’s history. A model doesn’t store rows you can delete; the customer’s influence is spread through its weights. The only real removal is retraining without them and redeploying, often at the next scheduled retrain, with that timeline documented. The offline store is hard for a similar reason: deleting there means rewriting history, not running a delete command. How the points are scored: 5 for the lawful basis, 6 for covering all four places (online vs. offline must be distinguished), and 4 for naming and explaining the hardest step. The inventory and minimization sections carry no points of their own, but they’re required.

## Slide 4
- Task 1: Pick a Path and Justify It
- Real-time endpoint
- Low-latency, one customer at a time
- Canary: two variants, the new one at 10% of traffic
- Or blue/green: the old endpoint stays up until smoke tests pass
- Auto-scaling: target 1000 invocations per instance; cooldowns 60 s out, 600 s in
- Enable DataCaptureConfig now; Lab 6 needs it
- Batch Transform
- Nightly scoring of the whole customer base
- Shadow run: the new model scores the same input as the old one
- Compare score distributions and the disagreement rate
- No traffic weights; the comparison artifact earns the points
- Quota not approved by Sat Nov 7? Switch to real-time
- Both paths: justify the choice with NorthStar's scoring frequency; define a rollback trigger with a numeric threshold, as code in deployment/configs/; plan a 48-hour window and observe for 60 minutes, then say what the shorter window misses.
- 4
> Notes: Question: Real-time endpoint or Batch Transform, and how do you decide?  Choose one and justify it in your plan using NorthStar's scoring frequency, not generic latency and throughput trade-offs.  On the real-time path, the controlled rollout is a canary, two variants on one endpoint with the new one at 10 percent of traffic, or blue/green, where the old endpoint stays up until the new one passes its smoke tests. Auto-scaling uses target tracking on invocations per instance at 1000, with a 60-second scale-out cooldown and a 600-second scale-in cooldown. Turn on DataCaptureConfig now: endpoint configs cannot be changed later, and Lab 6's monitoring needs the captured data.  On the batch path there is no traffic to split, so the rollout is a shadow run. The new model scores the same input file as the old one, and you compare score distributions and the disagreement rate before its output feeds anything. The comparison is what earns the points. If your transform quota is not approved by Saturday, November 7, switch to the real-time path.  Both paths need a rollback trigger with a real number, written as code in deployment/configs/, not just described in the plan. And both plan a 48-hour production window but observe for only 60 minutes, so your plan must say what the shorter window cannot catch.  Transition: Whichever path you pick, the first obstacle is your account's quotas.

## Slide 5
- Lab 5, Task 1: Canary Rollout and Rollback
- # deployment/configs/: the trigger must be code
- cloudwatch.put_metric_alarm(
- AlarmName='northstar-churn-canary-latency',
- Namespace='AWS/SageMaker',
- MetricName='ModelLatency',  # MICROseconds
- Dimensions=[
- {'Name': 'EndpointName',
- 'Value': 'northstar-churn-prod'},
- {'Name': 'VariantName', 'Value': 'canary'}],
- ExtendedStatistic='p95',
- Period=60, EvaluationPeriods=3,
- Threshold=200000,  # 200 ms, NOT 200
- ComparisonOperator='GreaterThanThreshold')
- Example values: choose and justify your own in the plan.
- 1
- Deploy two variants
- Canary at 10% traffic weight
- 2
- Observe 60 minutes
- Plan says 48 h; state the gap
- 3
- Prove the split
- ≥ 100 calls; ref: 175 / 25 of 200
- 4
- Promote or roll back
- Canary → weight 0 in ~90 s
- 5
- Tear down, verify
- Run teardown-lab5.sh
- Units: ModelLatency is µs: 200 ms = 200000
- Billing: Weight 0 still bills; only deleting stops it
- Gate: No teardown evidence = Task 1 capped at half
- 5
> Notes: Question: How do you roll out a new model so you can take it back in 90 seconds?  Task 1 is a controlled rollout, not a direct swap of the endpoint config. On the real-time canary path: two production variants on one endpoint, the new one at 10 percent traffic weight, promoted to 100 percent after a clean monitoring window.  The rollback trigger must exist as code in deployment/configs/: a CloudWatch alarm definition, a Terraform resource, or a deployment config. A threshold nobody wired up is a paragraph, not a control. The example on the slide alarms on p95 ModelLatency for the canary variant.  The units trap: ModelLatency is emitted in microseconds. 200 ms is 200000. Writing 200 sets the alarm to 0.2 ms; a healthy endpoint runs about 4,100 microseconds on ml.m5.large, so the alarm fires immediately and stays in ALARM, and a rollback wired to it fires on a healthy deployment. The rubric fails that item outright.  The monitoring window: your plan documents a 48-hour canary; you observe for 60 minutes. Say what 48 hours would catch that 60 minutes cannot.  Evidence is CLI output, not screenshots; the console lags by hours. The strongest evidence is an observed split: invoke at least 100 times and count InvokedProductionVariant. The reference run saw 175 champion and 25 canary over 200 calls. Re-run the count after rollback and show zero canary calls.  Rollback is update-endpoint-weights-and-capacities with the canary at weight 0. It takes about 90 seconds and drops no requests, but it does not stop the canary billing. Only deleting the endpoint stops the charge. Teardown is a gate: without the teardown evidence file, Task 1 is capped at half credit, and an endpoint still running after the deadline costs another 10 points.  Transition: Once the canary is live, the endpoint has to scale, and that is where two walls are waiting.

## Slide 6
- Lab 5: Auto-Scaling Meets Default Quotas
- autoscaling.register_scalable_target(
- ServiceNamespace='sagemaker',
- ResourceId=RESOURCE_ID,
- ScalableDimension=DIMENSION,
- MinCapacity=1, MaxCapacity=2)  # quota of 2
- autoscaling.put_scaling_policy(
- PolicyName='northstar-churn-scaling',
- ServiceNamespace='sagemaker',
- ResourceId=RESOURCE_ID,
- ScalableDimension=DIMENSION,
- PolicyType='TargetTrackingScaling',
- TargetTrackingScalingPolicyConfiguration={
- 'TargetValue': 1000.0,
- 'PredefinedMetricSpecification': {
- 'PredefinedMetricType': METRIC},
- 'ScaleOutCooldown': 60,
- 'ScaleInCooldown': 600})
- METRIC = 'SageMakerVariantInvocationsPerInstance'
- Start
- ml.t2.medium deploys fine
- Quota 2 · $0.056/hr
- Wall 1
- Scalable target rejected
- Burstable types can't auto-scale
- Wall 2
- ml.m5.large quota is 0
- Request L-614B09FD, ask for 2
- File the quota request the day the lab opens.
- 6
> Notes: Question: Why will your auto-scaling policy fail the first time, and why is that the lesson?  The policy itself is simple: target tracking on SageMakerVariantInvocationsPerInstance at 1000, scale-out cooldown 60 seconds, scale-in cooldown 600 seconds.  Wall 1: you start on ml.t2.medium. It's the cheapest real-time instance at $0.056 an hour and one of only three endpoint types a new account has quota for. Everything works until register-scalable-target, which fails with a ValidationException. Burstable instances run on CPU credits, so Application Auto Scaling refuses to manage them. Note what that cost you: the endpoint deployed and served fine and billed for minutes before the last step failed.  Wall 2: you switch to ml.m5.large and get ResourceLimitExceeded. New accounts have a default quota of 0 for it. Request "ml.m5.large for endpoint usage", quota code L-614B09FD, in us-east-1, and ask for 2: enough for a two-variant canary. Small requests are approved faster. Turnaround has ranged from minutes to several business days, so file it the day the lab opens.  If the increase hasn't landed, you still earn full credit: capture the rejection, explain the burstable cause in one sentence, show the filed request, and write out the scaling config you would have applied. You are graded on diagnosing the constraint, not on winning a race with AWS Support.  One more thing for Lab 6: whatever instance you land on, enable DataCaptureConfig. Endpoint configs are immutable, so you can't add it later without a redeploy.  Transition: If your system scores customers in bulk rather than one at a time, Lab 5 offers a batch path, with its own quota wall.

## Slide 7
- Lab 5, Batch Path: The Shadow Run
- for name, model in [('incumbent', OLD_MODEL),
- ('candidate', NEW_MODEL)]:
- Transformer(
- model_name=model,
- instance_count=1,
- instance_type='ml.m5.large',
- output_path=f'{OUT}/{name}/',
- strategy='MultiRecord',
- assemble_with='Line',
- accept='text/csv',
- ).transform(
- data=SAME_MANIFEST,
- content_type='text/csv',
- split_type='Line',
- input_filter='$[1:]',      # drop id
- join_source='Input',       # rejoin
- output_filter='$[0,-1]',   # id + prob
- wait=True)  # one at a time (quota 1)
- Same input manifest for both jobs; no traffic weights in batch
- 1
- Request transform quota on day one
- ml.m5.large · L-236AE59F · ask for 1
- 2
- Run the incumbent job
- Billing stops when the job ends
- 3
- Run the candidate on the same input
- Shadow run: output feeds nothing yet
- 4
- Compare the two outputs
- Score distributions + disagreement rate
- 5
- Only then promote
- The comparison artifact earns the points
- Not approved by Sat Nov 7? Switch to the real-time canary on ml.t2.medium.
- 7
> Notes: Question: How do you roll out a new batch model when there is no traffic to split?  On the Batch Transform path, the controlled rollout is a shadow run. The candidate model scores the same input manifest as the incumbent, you compare the two outputs (score distributions and disagreement rate), and only then does the new model's output feed anything downstream. The comparison artifact is what earns the points.  Quota first. Transform quotas are separate from endpoint quotas, and on a new account every transform instance type defaults to 0, including ml.t2.medium. Request "ml.m5.large for transform job usage", quota code L-236AE59F, and ask for 1. One instance runs the two jobs one after the other. Do not ask for ml.m5.xlarge or ten instances. A transform job stops billing when it ends, at $0.115 an hour.  The code detail: by default Batch Transform outputs only predictions, so customer_id would be lost. input_filter drops customer_id before the model sees it, join_source='Input' joins predictions back to the input row, and output_filter keeps the ID and the probability.  The deadline: if the quota request isn't approved by Saturday, November 7, switch to the real-time canary on ml.t2.medium, say so in your plan, and include the pending request as evidence. That is the last point where switching still leaves time to finish Task 1.  Transition: Everything so far has been technical. But the reading argues most deployments fail for reasons that are not technical at all.

## Slide 8
- Day One: The Quota Walls
- Start
- ml.t2.medium deploys fine
- Quota 2 · $0.056 per hour
- Wall 1
- Scalable target rejected
- Burstable types can't auto-scale
- Wall 2
- ml.m5.large quota is 0
- Request it; approval takes time
- Default quotas on a new account, us-east-1
- aws service-quotas request-service-quota-increase \
- --service-code sagemaker --quota-code L-614B09FD \
- --desired-value 2 --region us-east-1
- Ask for 2, not 20: small requests are approved faster.
- 8
> Notes: Question: Why will your first deployment attempts fail, and what do you do on day one?  New AWS accounts start with a quota of zero for almost every SageMaker instance type. You will hit two walls in a row.  You start on ml.t2.medium, which you do have quota for, and the canary, the traffic split and the alarm all work. Then attaching auto-scaling fails: burstable instances run on CPU credits, so Application Auto Scaling refuses to manage them. Move to ml.m5.large, and the deployment fails again, because its default quota is zero.  The fix is the command at the bottom: request the ml.m5.large endpoint quota, code L-614B09FD, and ask for 2, enough for a two-variant canary. Small requests are approved faster. Approval has taken anywhere from minutes to several business days, so file it the day the lab opens. That is the most likely way to lose points for reasons that have nothing to do with your engineering.  If approval does not arrive in time, you still earn full credit: capture the rejection, explain the burstable cause, show the filed request, and write out the scaling config you would have applied. On the batch path the quota is separate: request L-236AE59F and ask for 1.  Transition: Once things are running, you have to prove what happened, and screenshots are not enough.

## Slide 9
- Evidence: Prove It, Don't Screenshot It
- Real-time path: six pieces of evidence
- All saved in docs/lab5-deployment-output.txt
- 1
- describe-endpoint while live: both variants and their weights
- 2
- describe-scaling-policies while live (or the rejection)
- 3
- The rollback alarm definition and describe-alarms state
- 4
- An observed traffic split from at least 100 calls
- 5
- The same count after rollback: 0 canary calls
- 6
- Post-teardown proof that no endpoint is running
- Reference run, 9:1 weights
- 175 / 25
- champion / canary over 200 calls, counted from InvokedProductionVariant
- Why not screenshots? The console lags by hours and has shown deleted resources as present. CLI output is authoritative.
- 9
> Notes: Question: What counts as proof that your deployment worked?  CLI output, saved to docs/lab5-deployment-output.txt. The six items on the left are the real-time evidence: the endpoint with both variants and their weights, the scaling policy or its rejection, the alarm and its state, an observed traffic split, the same count after rollback, and proof that nothing is left running.  Items 4 and 5 are the strongest. Invoke the endpoint at least 100 times and count which variant answered, from the InvokedProductionVariant field. At 9-to-1 weights the reference run saw 175 calls to the champion and 25 to the canary out of 200. That proves traffic really split, not just that a config field was set. After rollback, the same count should show zero canary calls.  Why not screenshots? The AWS console lags by hours and has shown deleted resources as still present in this course. The API is the source of truth.  Transition: That covers Task 1. The other four tasks are mostly writing, so here they are on one slide.

## Slide 10
- Tasks 2–5 at a Glance
- Task 2 · Deployment plan · 20
- Seven sections: strategy, pre-deployment checklist, rollback criteria, monitoring window, notifications, post-deployment review, cleanup. Rollback numbers must match the alarm.
- Task 3 · Security assessment · 25
- STRIDE: 5+ threats across 3+ categories; one names the Lab 2 role that contains it, one names a gap. Classify 7 data assets, SSE-KMS vs. SSE-S3 with reasons.
- Task 4 · Privacy & compliance · 15
- Personal data inventory; one GDPR lawful basis, justified; minimization; erase customer C00123456 from four stores. The hardest is the trained model.
- Task 5 · Repository quality · 10
- check-secrets.sh exits clean; endpoint config, scaling policy and alarm live in deployment/configs/; a security step in CI (a buildspec.yml phase counts).
- 10
> Notes: Question: What do Tasks 2 through 5 ask for?  Task 2 is the deployment plan, 600 to 900 words, written so a teammate who has never seen the project could run it. It has seven required sections, and the rollback numbers must match the alarm you wrote as code.  Task 3 is the security assessment. The STRIDE threat model needs at least five threats across at least three categories. One must name the Lab 2 role that contains the damage, and one must name a gap those roles do not close. Then classify the seven NorthStar data assets, choosing SSE-KMS or SSE-S3 for each and saying why.  Task 4 is privacy. Inventory the personal data, choose and justify one GDPR lawful basis, describe what you left out of training, and walk a deletion request for customer C00123456 through four data stores. The hardest store is the trained model, because you cannot delete one customer from a model; you have to retrain it.  Task 5 is repository quality: the secret scan exits clean, the endpoint config, scaling policy and alarm live as code, and your CI has at least one security step. A phase in buildspec.yml counts.  Transition: Now the part of this lab that matters most outside the classroom: what it costs, and how to stop paying.

## Slide 11
- Cost and Teardown: The Lesson of This Lab
- $0.056/hr
- ml.t2.medium, where you start
- $0.115/hr
- ml.m5.large, about $83 a month
- × 2
- during a canary: two variants bill
- Weight 0 stops serving, not billing. Only deleting the endpoint stops the charge.
- bash scripts/teardown-lab5.sh
- # writes docs/lab5-teardown-output.txt
- Use the Lab 5 script, not the Lab 3 one: it also removes models, alarms and scaling targets, and writes the right evidence file.
- Fit these into your 60-minute window
- 11
> Notes: Question: Why is cost the main lesson of Lab 5?  It is the first lab with a resource that bills by the hour with nothing to stop it. A real-time endpoint bills from the moment it is in service until you delete it. ml.t2.medium is about 5.6 cents an hour, ml.m5.large about 11.5 cents, roughly 83 dollars a month, and a canary runs two variants, so double that.  The red bar is the trap. Rolling back to weight 0 stops the canary from serving traffic, but the instance is still provisioned and still billing. Only deleting the endpoint stops the charge.  Run the Lab 5 teardown script, not the Lab 3 one. It removes scaling policies, alarms, endpoints, endpoint configs and models, checks against the live API, and writes the evidence file this lab is graded on.  The timings on the right help you plan the 60-minute window: about 7 minutes to create an endpoint, about 4 to update its config, and about 90 seconds to shift traffic weights.  Transition: Lab 5 also comes with a list of problems we have already hit, so you do not have to find them again.

## Slide 12
- Traps Already Mapped: Don't Rediscover Them
- ModelLatency is in µs
- 200 ms = 200000; normal is about 4,100 µs
- Rollback is not off
- Weight 0 keeps billing until you delete
- Burstable can't scale
- t2 and t3 are rejected as scaling targets
- m5.large quota is 0
- Request L-614B09FD on day one
- IAM lag ~30 s
- Wait before retrying a policy fix
- Re-run terraform apply
- The first apply after a teardown fails
- ASCII-only descriptions
- Em dashes break EC2 description fields
- The console lags hours
- Verify with the CLI, never the console
- 12
> Notes: Question: Which known problems can you skip rediscovering?  Eight traps that cost previous runs hours. Two are worth saying out loud. ModelLatency is reported in microseconds, so a 200-millisecond threshold is 200000. Write 200 and your alarm fires on a perfectly healthy endpoint, and the rubric fails that item. And rolling back is not turning off: weight 0 keeps billing.  The rest: burstable instances cannot auto-scale, and the ml.m5.large quota starts at zero. After any IAM change, wait about 30 seconds before retrying, or you will see the old error and think your fix failed. The first terraform apply after a teardown fails once; just run it again. Keep AWS description fields ASCII-only, because em dashes break EC2. And trust the CLI, not the console.  Two more are in the lab doc. The XGBoost "Saving model in the UBJSON format" warning is harmless. And a colon inside an echo string breaks buildspec YAML, which matters if you add the Task 5 security step there.  Transition: Last, the calendar, and how to submit.

## Slide 13
- Timeline and Submission
- Thu Oct 29
- Lab 5 assigned
- Day one
- File your quota request
- Tue Nov 3
- L17: Deployment & Scaling II
- Thu Nov 5
- L18: Security & Privacy I
- Sat Nov 7
- Batch path: switch if no quota
- Tue Nov 10
- L19: Security & Privacy II
- Sat Nov 14
- Due at midnight
- Submit
- git tag lab5-submit
- git push origin lab5-submit
- Then submit your repository URL in Canvas. No tag means you are graded at your last commit before the deadline.
- Before you tag
- Teardown evidence committed
- check-secrets.sh exits clean
- No endpoint still running
- Data capture was on, for Lab 6
- 13
> Notes: Question: When does each piece happen, and how do you submit?  The two gold dates are the ones students miss. File the quota request on day one. And if you are on the batch path, Saturday, November 7 is the last day to switch to real-time if your transform quota has not been approved.  The lectures line up with the tasks. L17 on November 3 covers deployment hardening, resilience and readiness. L18 and L19 on November 5 and 10 cover security and privacy, including STRIDE, in time for Tasks 3 and 4. Lab 5 is due Saturday, November 14 at midnight, and Lab 6 opens on November 12.  To submit, tag the commit you want graded as lab5-submit, push the tag, and submit your repository URL in Canvas. The TA grades that tag. Forget it and you are graded at your last commit before the deadline, which may already include Lab 6 work.  Before you tag, check the four items on the right: teardown evidence committed, the secret scan clean, no endpoint running, and data capture turned on for Lab 6.  Transition: Questions on Lab 5? Start with the quota request today.
