# How PANIC works: the story version

Written for someone who has never used AWS. Tags show who builds each part: **[RJ]** Lead and ML, **[Tom]** Data and platform, **[Caden]** MLOps and reliability, **[Joe]** App and business.

## The setting

Picture a giant data center full of GPUs training an AI model. Each GPU has stacks of super-fast memory glued next to it called HBM. Every so often a tiny bit of memory flips the wrong way. Usually the memory's built-in spell-checker (ECC) fixes it: that's a **correctable error**. But sometimes the damage is too big to fix: an **uncorrectable error**. That crashes the whole training job, and thousands of GPUs lose an hour of work. At $4 per GPU per hour, that's about $65,000 gone.

The good news: before a spot of memory dies, it usually "coughs" first with a pile of correctable errors in the same place. PANIC listens for the coughing.

## Chapter 1: Building the house [Tom]

Before anything runs, Tom builds the house everything lives in. He writes **Terraform** files, which are like a blueprint AWS follows to build the same setup every time. That creates a private network (**VPC**), a big file cabinet (**S3**), a login for each teammate (**IAM**), and a **Budgets** alarm that emails everyone if spending gets too high. At the end of each work session, a teardown script knocks it all down so nobody gets a surprise bill.

## Chapter 2: The errors arrive [Tom]

We only have about 20,000 real errors from the Calchas dataset, which is small for a "real" data center. So Tom builds a **fleet simulator**: a pretend data center that replays the real Calchas errors and makes up extra realistic ones, up to about 630,000 errors a day. The errors flow in through **Kinesis Data Streams**, a conveyor belt for live data. A small program called a **Lambda** (code that runs only when something shows up) drops each error into S3.

## Chapter 3: Cleaning and counting [Tom, with RJ]

Raw errors are messy. An **AWS Glue** job is the cleaning crew: it checks every error against a **data contract** (right columns, real error types, real memory addresses, no duplicates) and rejects bad data loudly. Then it counts things like "how many correctable errors did this row have in the last day?" Those counts are **features**. RJ decides which counts matter; Tom builds the job. The features go into **SageMaker Feature Store**, a library with two copies: an archive for training (offline) and a quick-grab shelf for live scoring (online).

## Chapter 4: Teaching the models [RJ, Caden]

RJ trains four models, one for each level of memory: row, column, bank and server. Each one learns "these error patterns come right before a crash." He trains on older months and tests on newer months, so the test is fair, and compares the scores to the Calchas paper. **MLflow** keeps a notebook of every experiment.

Caden turns RJ's training code into an assembly line with **SageMaker Pipelines**: prepare data, train, test, and if the model is good enough, put it in the **Model Registry**, which is like a trophy case where a human must approve a model before it's used. **GitHub Actions** runs automatic tests every time someone changes code.

## Chapter 5: Every hour, a check-up [Tom, Caden, Joe]

Every hour, **EventBridge** (an alarm clock for the cloud) wakes up a scoring Lambda **[Joe]**. It grabs the latest features from the online shelf and sends them to a **SageMaker serverless endpoint** **[Caden]**, which runs the approved models and returns a risk score for every row, column, bank and server.

## Chapter 6: Deciding what to do [Joe]

A risky score triggers **Step Functions**, a flowchart that runs itself:

- Risky **row**: retire it automatically. Costs a few KB of memory, no downtime.
- Risky **bank**: wait for an operator to click approve.
- Risky **server**: save the job (checkpoint), then drain the server, but only after a human signs off.

Every decision is written to **DynamoDB**, a logbook nobody can quietly erase. **Amazon SNS** texts the on-call engineer when something needs them.

## Chapter 7: The control room [Joe]

Operators watch a **Streamlit** dashboard: a fleet map, risk scores, and an Approve button. The dashboard talks to the system only through **API Gateway**, the front desk that takes requests and routes them to the right place.

## Chapter 8: Watching the watchers [Caden]

Models get worse over time if the world changes (new firmware, hotter summers). **CloudWatch** shows dashboards and fires alarms if something breaks; **Evidently** checks whether today's data still looks like the training data (drift). If it doesn't, the models get retrained.

## Chapter 9: Going live for real [RJ, everyone]

You don't flip a switch on day one. The rollout goes: **shadow** (score but do nothing, check if we were right) → **advisory** (alert humans, they decide) → **canary** (automatic actions on 1%, then 10%, then all servers) → **scheduler integration**. A Production Readiness Review (PRR) has to pass before each step.

## The ending

Joe turns the results into money: about $2.9M saved per Llama-sized training run. Tom assembles the design doc, Caden builds the slides, Joe records the video, RJ writes the executive summary, and on Dec 16 the team shows a live demo where a server drain waits for someone to press Approve.
