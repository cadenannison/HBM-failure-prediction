# Ch27-Monitoring-Observability.pdf (extracted text, 31 pages)

<!-- page 1 -->
Chapter 27
Monitoring, Observability & Lifecycle
Management
27.1 Motivation
Imagine a ﬁnancial services company that deployed a credit scoring model in Q1. By Q3, loan
default rates had climbed 12% above forecast. The model was still running and no alerts had ﬁred,
because nobody was watching the right things. The model’s accuracy on its original test set had
not changed. The applicant population had shifted after a regional economic event, and the model
was now conﬁdently wrong about a different kind of customer than the one it had been trained on.
Infrastructure dashboards were green, inference latency was stable, and only the credit team was
seeing the losses.
This is the central failure mode of production AI: the system keeps running after it has stopped
doing what it was built to do, and nobody notices. Deployment starts a harder engineering prob-
lem. Production AI systems operate in a world that keeps changing. Customer behavior shifts,
upstream data pipelines break, and models degrade silently as failure modes appear that never
showed up in ofﬂine testing. Without continuous observability, you have no idea whether your
system is still doing what you built it to do. The failures that matter most are usually quiet: slow
drift that erodes accuracy week over week until the business case behind the model is gone.
Sculley and colleagues at Google argued more than a decade ago that hidden technical debt domi-
nates the long-term maintenance burden of production machine learning systems, and that much
of it sits in monitoring gaps, conﬁguration sprawl, and undeclared data dependencies (Sculley et
al. 2015). Monitoring is how you tell a system that works in production from one that only appears
to, and it has to be designed in from the start. Added after launch, it arrives too late. A team that
ships a model without a monitoring plan has shipped a liability. A team that ships a monitoring
plan but never reviews its alerts has the same problem, just less visible.
For enterprise leaders, monitoring is also where strategy turns into daily operations. The metrics
framework deﬁned in Chapter 26 establishes what success looks like and which guardrails the sys-
tem must not breach. Monitoring enforces those deﬁnitions every day. The governance program
deﬁned in Chapter 25 establishes who is accountable for outcomes, and monitoring gives those peo-
ple the evidence they need to do their jobs. Without continuous observability, governance turns
into paperwork and metrics into aspirations. The organization then learns about model failures
1

<!-- page 2 -->
from customers, regulators, or the press instead of from its own engineering signals. This chapter
treats monitoring and lifecycle management as the operating foundation for every AI system the
enterprise puts into production.
27.2 Challenge
How do you instrument AI systems to detect drift, degradation, misuse, and operational failures
early, before they breach guardrails, harm customers, or require expensive incident recovery? And
how do you manage the model lifecycle so that operational signals drive timely, disciplined up-
dates instead of reactive scrambling or quiet neglect? The answer involves technical instrumen-
tation, organizational ownership, alert design, and the lifecycle practices that turn signals into
decisions.
27.3 Objectives
By the end of this chapter, you will be able to:
1. Design a monitoring architecture that covers infrastructure, pipelines, models, applications,
and user-facing business outcomes.
2. Distinguish between data drift, concept drift, and model degradation, and explain how to
detect each using both statistical and proxy methods.
3. Implement alerting thresholds, severity tiers, and escalation paths grounded in service-level
objectives (SLOs, the reliability targets a service commits to) and error budgets.
4. Apply observability principles to generative AI and agent-based systems, including LLM-as-
judge evaluation (using one language model to score another’s outputs), token economics,
and tool-call diagnostics.
5. Deﬁne retraining triggers, A/B testing protocols, multi-armed bandit promotion strategies,
and model versioning practices for production lifecycle management.
6. Connect monitoring signals to governance, incident response, and the strategic feedback
loops that determine when models get refreshed or retired.
27.4 Interface with Previous Chapters
This chapter takes the production AI system from Part 3 Build as its primary input: the deployed
model stack, the performance baselines established during testing and validation, and the opera-
tional handoff package that deﬁnes what the system is supposed to do and under what conditions.
Within Part 4 Operate, it uses the metrics framework from Chapter 26, which deﬁnes success and
the guardrails the system must not breach. Monitoring enforces those deﬁnitions continuously in-
stead of checking them in periodic reviews. It also draws on the governance accountability struc-
ture from Chapter 25, which determines who acts on the signals this chapter’s instrumentation
produces. The output is a monitoring architecture and a lifecycle management practice: continu-
ous observability across ﬁve instrumentation layers, alerting and escalation protocols grounded in
service-level objectives, retraining triggers, model versioning practices, and A/B promotion pro-
tocols. Those signals give the accountable parties in Chapter 25 their evidence, and they connect
to Chapter 31, which routes operational experience back into strategy.
2

<!-- page 3 -->
27.5 What Monitoring Covers in an AI System
Monitoring a production AI system differs from monitoring ordinary production software. The
failure modes differ, the signals are harder to read, and a missed signal compounds quietly. Tradi-
tional application monitoring assumes that a system responding within its latency budget without
throwing errors is working. An AI system can meet both conditions while producing outputs that
are systematically wrong.
27.5.1 Monitoring versus observability
First, the vocabulary. Monitoring tells you when something is wrong: a threshold was breached, a
metric crossed a limit, an SLO is burning through its error budget (the amount of failure the target
allows) faster than expected. Observability lets you understand why. The system is instrumented
well enough to answer arbitrary questions about its internal state without deploying new code. An
enterprise AI program needs both. Monitoring catches the known failure modes that have been
cataloged and bounded. Observability gives the on-call engineer and the data scientist the data to
diagnose failures nobody anticipated.
The distinction matters because AI failure modes skew toward the unknown. A new attack vector
against an LLM, a subtle shift in customer behavior, a tool-call cascade nobody predicted: the
dashboards built on launch day will catch none of these. Observability covers that gap. It also
costs more than monitoring (more telemetry, more storage, more sampling discipline), so teams
should decide deliberately where deep observability is worth paying for.
27.5.2 The ﬁve layers of AI monitoring
A defensible architecture instruments ﬁve distinct layers and correlates signals across them.
Infrastructure layer. CPU and GPU utilization, memory, disk I/O, network latency, cluster health,
and queue depths. Everything else runs on this layer. On AWS, Amazon CloudWatch provides the
baseline metrics for Amazon Elastic Compute Cloud (EC2) instances, Amazon Elastic Container
Service (ECS) and Amazon Elastic Kubernetes Service (EKS) clusters, and SageMaker endpoints.
Infrastructure monitoring is mature, and most enterprises already have it. AI workloads change
the scale and unevenness of GPU consumption, so capacity planning and cost monitoring become
part of health monitoring.
Pipeline layer. Data ingestion success rates, feature computation latency, missing values, schema
violations, upstream source failures, and feature freshness. Saltonstall and Virji at Google Cloud ar-
gue that ML-speciﬁc service-level indicators (SLIs, the measurements an SLO is set against) belong
at this layer, including data freshness windows, pipeline throughput, and feature-store hit rates
(Saltonstall and Virji 2025). When features arrive stale or missing, the model serves predictions
from degraded inputs, and the infrastructure layer raises no alert. On AWS, this layer monitors
SageMaker Feature Store freshness, AWS Glue job outcomes, Step Functions pipeline state, and
Amazon Simple Storage Service (S3) data arrival timestamps.
Model layer. Prediction distributions, conﬁdence scores, output drift, feature importance stability,
and, where ground truth is available, model accuracy. The AI-speciﬁc failure modes show up here.
This is also the layer most often missing from enterprise monitoring stacks, because the data science
team has to deﬁne what normal looks like and the engineering team has to instrument it. The Breck
et al. ML Test Score rubric devotes a full quarter of its 28 production-readiness tests to monitoring
3

<!-- page 4 -->
and data-quality coverage, including speciﬁc tests for training-serving skew, prediction drift, and
feature staleness (Breck et al. 2017). Open-source tools such as Evidently AI compute drift and
data-quality reports on a schedule and can publish the results to CloudWatch as custom metrics.
Teams already using Amazon SageMaker Model Monitor, with its SageMaker Clarify bias and
feature-attribution drift checks, can keep using them, but AWS has closed Model Monitor to new
customers and does not plan to add new features.
Application layer. Application programming interface (API) error rates, response latency,
throughput, timeout rates, downstream system health, and retry storms. Business stakeholders
feel problems at this layer ﬁrst. It is also where vendor-managed AI services give the least visibil-
ity, since inference happens inside a black box. On AWS, this layer uses CloudWatch metrics for
API Gateway and Lambda and application logs, supplemented by AWS X-Ray or OpenTelemetry
(OTel, an open standard for collecting traces, metrics, and logs) traces for request-level diagnostics.
Business and product layer. User-facing outcomes, engagement signals, conversion rates, com-
plaints, support ticket volume, and the strategic metrics deﬁned in the metrics framework. These
signals show whether the system is doing what the business needs. They lag, often by days or
weeks, but they are the ground truth.
27.5.3 AWS monitoring architecture reference
Table 27.1 maps the ﬁve monitoring layers to AWS services and typical alert examples. A few
abbreviations appear in it. PSI is the Population Stability Index, a drift score explained later in this
chapter. SRE stands for site reliability engineering. p99 latency is the response time that 99% of
requests beat (p95 is the same idea at 95%). 5xx errors are server-side failures. CTR is click-through
rate, and NPS is Net Promoter Score, a common customer-loyalty measure.
Table 27.1: Mapping the ﬁve monitoring layers to AWS services, ownership, and alert examples.
Layer Signals AWS Services Owner Alert Examples
Infrastructure GPU utilization,
memory, latency,
queue depth
CloudWatch,
CloudWatch
Container
Insights, EC2
Auto Scaling
metrics
Platform/SRE
team
GPU utilization
above 90% for 15
minutes;
endpoint
memory
exhaustion
Pipeline Feature
freshness,
ingestion success,
schema
violations
CloudWatch
(Glue, Step
Functions),
SageMaker
Feature Store
metrics, S3 event
notiﬁcations
Data engineering Feature store
staleness exceeds
2 hours; Glue job
failure; schema
violation rate
above 1%
4

<!-- page 5 -->
Layer Signals AWS Services Owner Alert Examples
Model Prediction drift,
conﬁdence shift,
accuracy decay,
bias drift
Evidently AI
(open source)
publishing
custom
CloudWatch
metrics;
SageMaker
Clarify for
existing Model
Monitor users
ML engineering PSI exceeds 0.2
on core feature;
bias metric
crosses threshold;
accuracy drops 3
points
Application API latency, error
rate, throughput,
timeout rate
CloudWatch
(API Gateway,
Lambda), X-Ray,
Application Load
Balancer metrics
Application team p99 latency
exceeds 400ms;
5xx error rate
above 2% for 10
minutes
Business Conversion rate,
CTR, churn, NPS,
support tickets
QuickSight
dashboards,
Athena queries
on business data
lake, custom
CloudWatch
metrics
Product/business Recommendation
CTR drops 15%
week-over-week;
churn segment
exceeds
threshold
27.5.4 Why all ﬁve layers matter
Each layer catches failure modes the others miss. Infrastructure failures cause model failures, but
infrastructure monitoring alone will not tell you the model is wrong. Drift and degradation at
the model layer often produce no infrastructure or application alerts, because the system answers
within its latency budget and throws no errors. Application-layer signals catch user-visible prob-
lems but rarely explain the cause. Business-layer signals catch what infrastructure misses, but
only as fast as the slowest reporting cycle in the organization. Complete observability means in-
strumenting all ﬁve layers and correlating them, because the root cause usually shows up in the
relationship between layers. Figure 27.1 shows the tradeoff: lower layers detect problems fastest,
while higher layers show business impact most clearly.
There is a second reason: aggregate metrics hide subgroup failures. Johnson and colleagues
showed that headline performance metrics routinely mask signiﬁcant degradation on speciﬁc
slices of the population, and that slice-discovery tooling now belongs in standard operations
rather than research (Johnson et al. 2023). A model can hit its expected aggregate accuracy while
failing badly in the segments the business cares about most. Model-layer monitoring needs
slice-level metrics alongside the aggregates. Without them, the system fails invisibly for the
customers most affected.
5

<!-- page 6 -->
Figure 27.1: The ﬁve layers of AI monitoring, showing the tradeoff between detection speed and business
impact visibility.
6

<!-- page 7 -->
27.5.5 Training-serving skew
Training-serving skew sits where the pipeline and model layers meet, and it deserves special at-
tention. It occurs when the features computed during training differ from those computed during
inference, even though the code appears identical. Common causes include differences in times-
tamp handling, mismatched aggregation windows, feature-store versioning errors, and prepro-
cessing code that behaves differently in batch and streaming contexts.
Skew is hard to spot because the model’s outputs stay within normal ranges and pass infrastruc-
ture and application health checks while the predictions rest on subtly corrupted inputs. Detecting
it means comparing the feature distributions seen in training with those seen at inference. Open-
source drift tools such as Evidently AI include this comparison as a standard report. Any signiﬁ-
cant divergence warrants immediate investigation.
27.5.6 Where this ﬁts in the broader stack
Monitoring and lifecycle management sit at the operational end of the AI Systems Development
Lifecycle, as covered in Chapter 17, and the XOps stack that extends it, as covered in Chapter 23.
Architectural decisions made during platform design (covered in Chapter 18) determine which
monitoring options exist. The CI/CD pipeline covered in Chapter 23 determines how quickly a
retrained model can ship. Monitoring depends on those earlier engineering practices and carries
them into production.
27.6 Drift Detection: The Core Monitoring Problem
Drift is the main reason AI systems degrade in production without anyone noticing, and much
of AI monitoring comes down to recognizing its three types and detecting each one. Gama and
colleagues provide the standard academic vocabulary in their survey of concept-drift adaptation,
separating changes in the input distribution, changes in the input-output relationship, and per-
formance decay (Gama et al. 2014). Practitioners often blur the three. This section treats them
separately because each calls for different detection methods and different responses (Figure 27.2).
27.6.1 Data drift (covariate shift)
The distribution of input features changes between training and production, while the relationship
between those inputs and the target stays stable. Examples include shifts in customer demograph-
ics after a marketing campaign, seasonal changes in purchasing behavior, changes in the mix of
products or transactions, and demographic change in a service area, as long as these alter the input
distribution without changing how the features relate to the target.
Detection applies statistical tests to feature distributions. The three most common in enterprise
practice are the Population Stability Index (PSI), the Kolmogorov-Smirnov test, and the Jensen-
Shannon divergence. PSI is the most widely used because it produces a single, interpretable score
per feature, with rough starting heuristics that engineering teams can wire into alerts: under 0.1
suggests stability, 0.1 to 0.25 suggests moderate drift, and over 0.25 suggests signiﬁcant drift (Yur-
dakul and Naranjo 2020). The examples in this book alert at 0.2, a common industry rule of thumb
inside the moderate band. These thresholds have no deﬁned statistical error rates. Use them
as starting points for calibration, since the right threshold depends on binning strategy, sample
7

<!-- page 8 -->
Figure 27.2: The three types of drift that cause AI systems to degrade in production, with distinct detection
methods and responses required for each.
8

<!-- page 9 -->
size, feature type, and business context. The Kolmogorov-Smirnov test suits univariate continu-
ous distributions and catches changes in distributional shape that PSI can miss. Jensen-Shannon
divergence works well for categorical features. For high-dimensional embeddings, teams moni-
tor centroid distances across time windows, track shifts in nearest-neighbor distributions, or use
Maximum Mean Discrepancy (MMD) for multivariate comparison.
In practice, a scheduled monitoring job captures a baseline distribution from the training data
and compares recent inference-time distributions against it. With an open-source library such as
Evidently AI, the job usually runs as a scheduled container or AWS Lambda function, writes its
reports to S3, and publishes drift scores to CloudWatch as custom metrics. CloudWatch alarms on
those metrics then route to the alerting workﬂows described later in this chapter.
Response patterns: investigate the source of the shift, decide whether it is permanent or transient,
and retrain on data from the new regime if the shift is signiﬁcant and persistent. Data drift alone
does not always require retraining. If the model’s predictions stay accurate on the shifted distribu-
tion, the system is still working.
27.6.2 Concept drift
The relationship between inputs and outputs changes. The model itself may be untouched; the
environment it learned to represent has moved. Examples include changes in customer behavior
after an economic event, a competitor entering the market, a product mix change that alters what
“intent to purchase” looks like, or a regulatory change that shifts the meaning of a label.
Concept drift cannot be detected from inputs alone. The input distribution may look identical
while the meaning of those inputs has changed. Detection requires ground truth, which often
arrives weeks or months late. Three workable strategies ﬁll the gap:
1. Track proxy metrics that correlate with eventual outcomes. If you cannot measure 90-day
churn until 90 days have passed, monitor 30-day engagement signals that have historically
predicted churn.
2. Run shadow models that score against a held-out evaluation slice with known labels, and
compare predictions. Disagreement between the production and shadow versions can indi-
cate drift, though without conﬁrmed labels it is not proof.
3. Segment performance by cohort. Concept drift often hits speciﬁc customer segments ﬁrst,
and cohort-level monitoring can surface the problem weeks before it shows in the aggregate.
Response patterns: retrain on recent data weighted toward the new regime, consider changing the
model architecture if the shift is structural, and check whether the original problem framing still
holds.
27.6.3 Model degradation (performance decay)
Accuracy, precision, recall, or other quality metrics decline over time. Data drift or concept drift
is the usual cause, but upstream data quality issues, feature pipeline bugs, or unnoticed training-
serving skew can produce the same decline. Huyen describes model degradation as the inevitable
consequence of operating in a non-stationary world, and treats measuring and responding to it as
a core production responsibility (Huyen 2022).
Detection requires labels. When labels arrive quickly (next-day transaction outcomes, immediate
user feedback), detection is fast. When they lag (six-month churn prediction, long-cycle sales con-
9

<!-- page 10 -->
version), degradation can go unnoticed for months unless proxy metrics are in place. Operational
teams ﬁll the gap with delayed labels, weak labels inferred from behavior, human feedback, or
implicit signals. The response depends on the cause: retrain if the data has shifted, recalibrate if
the score distribution has drifted while accuracy on labeled data holds, and redesign if the failure
is structural.
27.6.4 Handling delayed ground truth
Delayed labels are among the hardest operational problems in production ML. When the true out-
come takes 30, 60, or 180 days to arrive, the team has to decide how to monitor in the meantime
and how to use the labels once they come in.
The recommended approach runs three mechanisms in parallel. First, deﬁne proxy metrics that
correlate with eventual outcomes and monitor them continuously. For a 90-day churn model, the
proxy might be a 14-day decline in session frequency, support ticket volume, or feature engage-
ment scores. Second, build a label-join pipeline that maps delayed outcomes back to the original
predictions and computes accuracy on a rolling basis as labels arrive. This means storing the pre-
diction timestamp, request ID, and a join key with every inference. Third, backtest periodically:
once a month’s worth of labels is in, re-score the historical predictions and compare them to actuals.
Backtesting catches degradation that was invisible in real time. Figure 27.3 shows how the three
mechanisms work together.
Figure 27.3: Three parallel mechanisms for monitoring model quality when ground truth labels are delayed
by weeks or months.
10

<!-- page 11 -->
27.6.5 Detecting drift in generative AI and agent systems
Traditional drift detection does not carry over directly. The outputs are text, and the qualities you
care about, such as truthfulness, tone, and safety, have no natural distributional test. Monitor these
signals instead:
• Output length and structure distributions. A sudden shift in average response length or re-
fusal patterns often means something changed upstream: the prompt template, the retrieval
corpus, or the model version.
• Sentiment and tone shifts. Track sentiment scores over time on a sampled basis.
• Refusal rates. A spike in refusals may come from a guardrail tuning change, a shift in user
inputs, or a model update.
• Hallucination proxy metrics. Citation accuracy for RAG systems, claim-checking against a
known source corpus, or LLM-as-judge scoring on a sample.
• Tool-call success rates. For agents, drift shows up ﬁrst in the cascade of tool calls.
• User correction and edit rates. Users editing or correcting outputs more often is a reliable
sign that output quality has dropped.
• Embedding drift. Track the distribution of output embeddings (or input embeddings) over
time. A signiﬁcant shift means the character of the inputs or outputs has changed in ways
surface-level metrics may miss.
27.6.6 Real-world case study: Uber Michelangelo
Uber built prediction monitoring into Michelangelo, its internal ML platform, as a standard step
of the model lifecycle (Jeremy Hermann and Mike Del Balso 2017). The platform automatically
logs a percentage of each model’s predictions and later joins them to the observed outcomes that
Uber’s data pipelines produce. From those joined records it computes ongoing accuracy measures
and publishes them to Uber’s time-series monitoring systems, where teams chart them and set
threshold alerts. The stated goal was to conﬁrm that data pipelines were still sending accurate data
and that the production environment had not changed in ways that made the model inaccurate.
The broader lesson: Uber made monitoring a platform feature that every model got by default, so
no team had to build its own. The label-join approach does depend on outcomes arriving, so it
works best alongside the proxy metrics and input-drift checks described earlier.
27.7 Alerting Architecture and Escalation Paths
Without well-designed alerting, a monitoring system is a dashboard, not a safeguard. Alert de-
sign is an engineering discipline of its own. Thurgood and colleagues at Google describe the SRE
vocabulary used in the rest of this section: service-level indicators, service-level objectives, and
error budgets. In their framing, 100% reliability is the wrong goal, error budgets deﬁne “reliable
enough,” and alerts should ﬁre when the error budget is burning faster than the system can sustain
(Thurgood et al. 2018).
27.7.1 Alert design principles
• Actionable. Every alert must have a deﬁned response. An alert with no action attached is
noise. The test is simple: can the on-call engineer describe what they will do when it ﬁres? If
not, move it to a dashboard or delete it.
11

<!-- page 12 -->
• Tiered. Not every anomaly justiﬁes waking someone at 2 am. Severity tiers set who gets no-
tiﬁed, how fast, and through what channel. Assign tiers before launch so nobody relitigates
them during an incident.
• Threshold-grounded. Alert thresholds come from the metrics framework and the SLO tar-
gets deﬁned for the service, never from whoever happened to conﬁgure the dashboard.
• Deduplicated. Alert storms during incidents are a reliability problem in their own right.
Design for noise suppression, parent-child alert relationships, and intelligent grouping so
the on-call engineer sees the underlying failure instead of 200 symptoms of it. CloudWatch
Composite Alarms support parent-child relationships for this purpose.
• Owned. Every alert has a named owner who tunes it, retires it, and answers for it when it
misﬁres.
27.7.2 Alert severity tiers
Alerts are ranked on a four-level priority scale, from P1 (most urgent) to P4 (least urgent), the same
scale used in Chapter 26. Table 27.2 summarizes each tier. Two terms in the table need a brief note.
A service-level agreement (SLA) is a commitment made to customers or business owners, usually
with consequences if it is missed. An SLO is the internal engineering target, typically set tighter
than the SLA so the team gets warning before the agreement is at risk. Amazon Simple Notiﬁcation
Service (SNS) is the AWS messaging service that delivers alerts to people and systems.
Table 27.2: Alert severity tiers, conditions, responses, and channels for an enterprise AI monitoring program.
Tier Condition Response Channel
P1, Critical Guardrail breached;
system producing
harmful outputs;
complete pipeline
failure
Immediate human
intervention; potential
system pause
PagerDuty / on-call
via SNS
P2, High Performance metric
below SLA threshold;
signiﬁcant drift
detected; cost ceiling
at 90%
Engineering response
within 1 hour
Slack via Amazon Q
Developer in chat
applications + ticket
P3, Medium Leading indicator
anomaly; moderate
drift; latency
approaching
threshold
Investigation within
24 hours
Ticket via
EventBridge
P4, Low Informational trend;
minor threshold
approach
Weekly review Dashboard
27.7.3 Alert examples: good versus bad
A well-designed alert gives context and points to an action:
• Bad: “PSI changed.”
12

<!-- page 13 -->
• Good: “P2: PSI for income_band exceeded 0.20 for two consecutive daily windows. Feature
freshness normal, no schema changes detected. Route to ML on-call for drift investigation
per runbook DR-003.”
The good alert tells the engineer what changed, what has been ruled out, and what to do next.
27.7.4 Escalation paths
P1 and P2 alerts go to the on-call engineer ﬁrst. If they are not resolved within the deﬁned SLA,
they escalate to the AI Product Owner and the AI Governance Lead. Guardrail breach alerts go
straight to the AI Governance Lead and, for higher-risk systems, to the cross-functional AI Gov-
ernance Board described in Chapter 25. Every P1 incident generates an automatic post-mortem
ticket, without exception. Writing the post-mortem within a ﬁxed window after the incident is
how the organization learns. Figure 27.4 traces these paths by tier.
Figure 27.4: Alert escalation paths by severity tier, showing routing to appropriate response channels and
automatic post-mortem triggers.
On AWS, the escalation architecture typically uses one SNS topic per severity tier, with PagerDuty
or Opsgenie integration for P1/P2, Amazon Q Developer in chat applications (formerly AWS Chat-
bot) posting to Slack for P2/P3, and EventBridge rules routing P3/P4 to ticketing systems like Jira
or ServiceNow.
13

<!-- page 14 -->
27.7.5 Avoiding alert fatigue
Alert fatigue is real and dangerous. Teams that get too many low-value alerts learn to ignore them,
including the ones that matter. Two habits prevent it:
1. Review alert volume weekly during the ﬁrst quarter of production. Prune P4 alerts aggres-
sively. Move P3 alerts that have never led to action onto informational dashboards. Demote
P1 alerts that ﬁre repeatedly without harm to P2, with adjusted thresholds.
2. Track an “alert quality” metric: the ratio of alerts that led to an engineering action to total
alerts ﬁred. Aim for above 70%.
27.7.6 Mapping AI risk categories to alerts
AI failure modes also include guardrail breaches that never appear in the operational SLO catalog,
and the alerting architecture has to account for them. The NIST AI 600-1 GenAI Proﬁle (Autio et
al. 2024) categorizes the risks of generative AI that an enterprise monitoring program should map
alerts against, including confabulation, harmful content generation, and data integrity concerns.
These categories sit alongside the traditional SRE metrics, and they often need their own escalation
paths into compliance and governance.
27.7.7 Connecting Michelangelo to alerting
The Uber Michelangelo approach applies here too (Jeremy Hermann and Mike Del Balso 2017).
Because the platform published every model’s accuracy metrics to the same company-wide time-
series monitoring and alerting systems, teams could set threshold alerts without building their
own monitoring stack. Standardizing where model metrics land, and how alerts on them are de-
ﬁned, lets alerting scale once the number of production models grows past what any single on-call
engineer can track.
27.8 Observability for Generative AI and Agent Systems
Traditional ML monitoring compares numeric outputs against numeric thresholds. Generative AI
and agent systems need a different approach, because their outputs are harder to measure and they
fail in different ways. Aryan, in LLMOps, states it directly: traditional MLOps practice falls apart
when applied unchanged to generative AI (Aryan 2025). The reasons are structural. Outputs are
unbounded text instead of scored predictions, token economics drive the cost model more than
compute time does, and failure modes such as prompt injection, hallucination, and refusal appear
nowhere in the classic ML test catalog.
27.8.1 What to observe in LLM-based systems
• Input and output sampling. Log a statistical sample of prompts and completions for ongoing
quality review. Logging every call is expensive and creates privacy exposure, so sample
enough to detect shifts in character. A 1% to 5% sample is typical, stratiﬁed across user
segments to catch slice-level failures.
• Latency and token economics. Token counts per request, cost per call, and latency by request
type. Generative AI cost scales with output length in ways that surprise teams new to the
work. A single misbehaving prompt template can blow through a monthly budget in a day.
14

<!-- page 15 -->
• Refusal and error rates. How often does the model decline to answer, produce an error, or
return a malformed response? Sudden shifts here are often the ﬁrst sign of a vendor model
update or a prompt template change.
• Groundedness and hallucination proxies. For RAG systems, measure citation accuracy and
response-to-source consistency. For open-ended generation, use LLM-as-judge scoring on
a sample (covered below). Chang and colleagues survey the wider set of LLM evaluation
methods, including behavioral testing and regression testing approaches that carry over to
production monitoring (Chang et al. 2024).
• Prompt injection and misuse detection. The Open Worldwide Application Security Project
(OWASP) Gen AI Security Project’s Top 10 for LLM Applications is the authoritative catalog
of failure modes production monitoring must cover, including prompt injection, sensitive
information disclosure, excessive agency, data and model poisoning, and improper output
handling (OWASP GenAI Security Project 2026). Treat the OWASP Top 10 as the LLM coun-
terpart of the OWASP web Top 10: a checklist every production LLM system must demon-
strably address.
27.8.2 Privacy and security controls for LLM observability
Logging prompts and completions creates signiﬁcant privacy and security exposure. Production
systems need the following controls:
• PII redaction. Apply entity recognition to detect and redact personal identiﬁers before log-
ging. Amazon Comprehend, or custom named entity recognition (NER) models, can ﬂag
sensitive content for redaction or exclusion.
• Encryption. Encrypt all telemetry at rest (S3) and in transit. Use customer-managed keys in
AWS Key Management Service (KMS) for audit-sensitive data.
• Access control. Store prompt/completion logs in a restricted S3 bucket, with AWS Identity
and Access Management (IAM) policies that limit access to authorized reviewers. Log that
access to CloudTrail.
• Retention limits. Deﬁne and enforce retention periods based on legal, regulatory, and busi-
ness requirements. Use S3 lifecycle policies to expire data automatically.
• Data minimization. Log only what quality review needs. Consider logging ﬂagged or sam-
pled requests instead of all trafﬁc.
• Third-party restrictions. When using Amazon Bedrock or other managed services, under-
stand what data the provider may retain and make sure it complies with customer data use
restrictions.
• Secret detection. For agent systems, scan tool-call traces for accidentally logged credentials
or API keys before storing them.
27.8.3 What to observe in agent systems
Agent observability is harder because agents take multi-step actions and their failures cascade.
• Tool-call success rates. What percentage of tool invocations succeed? Tool failures cascade
in multi-step agents. They often show up as an agent giving up or, worse, making up an
answer after the underlying tool call failed.
• Task completion rates. Does the agent complete the task it was given? Success has to be
deﬁned at the task level, not the step level.
15

<!-- page 16 -->
• Step counts and loop detection. An agent that takes an unexpectedly large number of steps,
or loops, is failing in a way that is easy to miss because the system is technically still “re-
sponding.”
• Human escalation rate. How often does the agent hand off to a human? An unexpectedly
low rate may mean the agent is overconﬁdently handling edge cases it should have escalated.
• Outcome quality. Requires human evaluation on a sample or an automated judge. This
is the hardest part of agent observability, because the “correct” outcome is not always well
deﬁned.
Figure 27.5 shows where in an LLM or agent system each of these signals is captured.
Figure 27.5: Key instrumentation points for observability in LLM and agent systems, showing where to
capture telemetry for quality monitoring.
27.8.4 LLM-as-judge: evaluation in production
LLM-as-judge is widely used to evaluate generative systems in production, though it needs careful
calibration and should not fully replace human evaluation. Li and colleagues survey LLM-as-
judge methods across single-LLM, multi-LLM, and human-AI hybrid conﬁgurations, covering the
calibration work effective use requires and the known biases (position bias, verbosity bias, self-
preference bias) production deployments must control for (Li et al. 2024). The pattern itself is
simple: a separate language model scores a sample of your primary system’s production outputs
against criteria such as groundedness, helpfulness, safety, or task completion. Calibration is where
the work lies.
16

<!-- page 17 -->
Arize AI’s operational primer documents the templates engineering teams use in production, with
pre-built evaluators for hallucination detection, RAG relevance, toxicity, Q&A correctness, and
agent behavior (Arize AI 2025). Vendor-reported precision against human annotations falls in the
70% to 90% range for well-calibrated use cases. That is good enough for operational monitoring
and too low to retire human evaluation. The recommended pattern is layered: LLM-as-judge runs
continuously on a high-volume sample to catch shifts, while humans review a smaller sample on
a slower cadence to calibrate the judge and catch what it misses.
Grace and colleagues at Anthropic describe evaluation as a continuum. Ofﬂine evals are the pre-
launch line of defense, production monitoring is the post-launch backstop, and A/B testing is the
comparison when a new version is up for promotion (Grace et al. 2026). Each covers what the
others cannot, and a production LLM program needs all three. They also note that evals drift. The
criteria you used at launch may not be the ones that matter at month six, so the eval set needs
versioning, an owner, and periodic review.
27.8.5 Amazon Bedrock observability
Observability on Amazon Bedrock works differently from self-hosted model monitoring. Bedrock
provides invocation logging to CloudWatch Logs and S3, capturing request metadata, token
counts, and latency. Amazon Bedrock Guardrails provides conﬁgurable content ﬁlters, denied
topics, sensitive information ﬁlters, and contextual grounding checks that log violations. Detailed
model internals, such as attention patterns and embedding layers, are not exposed.
In practice, Bedrock observability centers on the application layer: logging prompts and com-
pletions at your application boundary, tracking guardrail trigger rates, monitoring cost through
CloudWatch metrics, and running your own evaluation sampling pipeline. The model is a black
box, and your observability strategy has to work around that.
AWS now offers much of this application-layer instrumentation as a managed capability. Cloud-
Watch generative AI observability includes pre-built dashboards for Bedrock model invocations,
covering usage, token consumption, latency, and errors, along with end-to-end tracing of a prompt
through knowledge bases, tools, and models. For agents, Amazon Bedrock AgentCore Observ-
ability records metrics, traces, and logs for each agent session, including tool calls, memory, and
gateway activity, and sends them to CloudWatch. It is built on OpenTelemetry and its generative
AI conventions (a shared naming scheme for model and agent trace data), so it also works with
agents built in other frameworks and hosted outside AgentCore. Teams can use these services to
capture the agent signals described above (tool-call success, step counts, and token spend) without
building the collection pipeline themselves. They still have to deﬁne what good looks like and set
up their own quality evaluations (Amazon Web Services 2026b, 2026a).
27.8.6 Online evaluation patterns
For generative systems, ofﬂine benchmarks are necessary but leave gaps. Online evaluation pat-
terns include:
• Shadow deployment. Route a small percentage of trafﬁc to a candidate model or an alterna-
tive prompt, capture both responses, and compare them. The user sees only the production
response; the shadow response is logged for evaluation.
• A/B testing. Route trafﬁc between two production candidates and compare outcomes on the
metrics deﬁned in the metrics framework. Covered further under lifecycle management.
17

<!-- page 18 -->
• Continuous evals. Run a ﬁxed evaluation set against production trafﬁc patterns daily or
weekly to catch drift early.
27.9 Model Lifecycle Management: From Signal to Action
Monitoring produces signals. The model lifecycle process turns those signals into decisions about
retraining, updating, versioning, promoting, and retiring models. Without a deﬁned lifecycle, ev-
ery signal becomes a debate, and every debate consumes engineering time the program does not
have.
27.9.1 MLOps maturity as the prerequisite
The lifecycle practices in this section assume a certain level of MLOps maturity. Kazmierczak,
Salama, and Huerta’s Google Cloud reference deﬁnes three levels: Level 0 (manual and script-
driven, with ML and operations separate), Level 1 (automated ML pipelines that enable continuous
training), and Level 2 (full CI/CD automation with automated experiment tracking, model registry,
and production rollout) (Kazmierczak et al. 2024). What follows assumes at least a full Level
1: automated training pipelines, automated data and model validation, and a centralized model
registry. Level 0 organizations cannot reliably carry out these practices. Reach Level 1 before
attempting drift-triggered retraining or multi-armed bandit promotion; otherwise the effort will
cost a lot and deliver little. Figure 27.6 summarizes what each level makes possible.
27.9.2 Retraining triggers
Not every drift signal should trigger an immediate retrain. Retraining costs compute, engineering
time, and validation time, and it adds deployment risk. Deﬁne the retraining policy in advance so
nobody is making it up when an alert ﬁres at 11 pm. Four trigger patterns cover most cases, and
most production systems combine several.
• Scheduled retraining. Retrain on a ﬁxed cadence (daily, weekly, monthly, quarterly) regard-
less of drift signals. Suits systems with known seasonal patterns, fast-moving domains, or
regulations that mandate periodic refresh. Predictable, but potentially wasteful when the
data has not changed.
• Drift-triggered retraining. Retrain when drift metrics exceed deﬁned thresholds. More efﬁ-
cient than a schedule, but it requires robust drift detection and a clear policy on which drift
signals trigger which actions.
• Performance-triggered retraining. Retrain when ground-truth accuracy drops below a
benchmark threshold. The cleanest trigger, because it rests on actual model quality, but it
depends on ground truth, which often lags.
• Business-event-triggered retraining. Retrain in response to known distribution-shifting
events: market changes, product launches, regulatory changes, seasonal resets, mergers and
acquisitions, or major external events. Automated triggers often miss these, which is why
the retraining policy should include a human-initiated path.
Figure 27.7 offers a decision path for choosing among these triggers.
Keep automatic retraining separate from automatic deployment. Monitoring signals can start au-
tomated retraining pipelines through EventBridge rules that invoke SageMaker Pipelines or Step
18

<!-- page 19 -->
Figure 27.6: MLOps maturity levels and the lifecycle management capabilities each level enables; Level 1 is
the minimum for reliable production operations.
19

<!-- page 20 -->
Figure 27.7: Decision framework for selecting the appropriate retraining trigger based on available signals
and business context.
20

<!-- page 21 -->
Functions. Promoting the retrained model to production is a different step. It should require vali-
dation against a holdout set, guardrail veriﬁcation, and approval (automated or human, depending
on risk tier) before any trafﬁc reaches the new version. The SageMaker Model Registry supports
approval workﬂows that enforce this separation.
27.9.3 A/B testing for model promotion
Before giving a retrained model full trafﬁc, validate it against the current model with real users:
• Trafﬁc split design. Start by sending 5% to 10% of trafﬁc to the challenger. Expand if it
shows statistically signiﬁcant improvement on the primary success metric with no guardrail
degradation. Hold the test long enough to capture the relevant cycles: a week for daily-cycle
systems, longer for weekly or monthly patterns.
• Pre-deﬁned success criteria. Decide the metrics, thresholds, and duration before the test
starts. Setting criteria after you’ve seen the results undermines the test.
• Rollback triggers. If the challenger violates any guardrail during the test, roll back auto-
matically without waiting for human approval. Manual rollback is the fallback for when the
automated trigger fails.
• Statistical discipline. Apply the experiment design rules from Chapter 26 (power analysis,
minimum detectable effect, protection against peeking). Promotion adds one requirement:
fairness guardrail metrics need enough observations per segment to avoid false alarms from
small samples.
27.9.4 Multi-armed bandits and Thompson sampling
Multi-armed bandit algorithms generalize A/B testing for cases where you want to minimize re-
gret while still learning which variant is best. A bandit adjusts the trafﬁc split as results come
in, sending more trafﬁc to the variants that perform better, instead of holding a ﬁxed split for the
whole test. Thompson sampling is a practical implementation: it samples from posterior distribu-
tions over each variant’s performance and routes trafﬁc in proportion to the probability that each
variant is best.
McClendon, Venkatesh, and Morinelli evaluate multi-armed bandits in MLOps environments.
They ﬁnd that bandit-based deployment can match or exceed traditional A/B testing on decision
speed and total regret under certain conditions, and that it can roll back underperforming variants
automatically without an explicit decision step (McClendon et al. 2025). For enterprise lifecycle
management, that means:
• Use bandits for continuous candidate evaluation. With several model variants in ﬂight (a
tuned prompt, a ﬁne-tuned variant, a different base model), a bandit can lower the cost of
running them in parallel.
• Use A/B tests for high-stakes promotion decisions. When the decision must be auditable
and the test has a deﬁned endpoint, traditional A/B testing remains the cleaner pattern.
• Account for the operational complexity. Bandits need richer telemetry, more careful
guardrail design, and more sophisticated rollback logic than A/B tests. Because the trafﬁc
allocation changes continuously, they also make auditing harder. Adopt them only when
the regret reduction justiﬁes the complexity and audit requirements allow it.
Figure 27.8 compares the two approaches side by side.
21

<!-- page 22 -->
Figure 27.8: Comparison of A/B testing and multi-armed bandit approaches for model promotion, with
guidance on when to use each.
22

<!-- page 23 -->
27.9.5 Model registry, model cards, and versioning
Every production model lives in a model registry with a complete record: a version identiﬁer, a
training data snapshot, evaluation results, a model card, a deployment date, an approval record,
and lineage back to the training pipeline. SageMaker Model Registry provides artifact storage,
versioning, and an approval workﬂow for this purpose. The registry is what makes governance
auditable and rollback possible.
Mitchell and colleagues deﬁned the model card format, which has since become the de facto doc-
umentation standard for production AI models (Mitchell et al. 2019). Every production version
should have a model card covering intended use, evaluation data, performance metrics by slice,
ethical considerations, and known limitations. It is the document the on-call engineer reads at 2
am to ﬁnd out what a misbehaving model was built for.
Promoting a new version requires the same governance sign-off as the initial deployment. Keep
parallel versions as well: be able to roll back to N-1 immediately and, for higher-risk systems, to
N-2. Keeping a previous version warm costs different amounts in different settings. For large
GPU-hosted models or provisioned-throughput LLM deployments, the infrastructure cost is real
and has to be budgeted.
27.9.6 Model deprecation and retirement
Models do not retire themselves. Without an explicit retirement process, organizations accumulate
zombie models that keep running, consuming resources, and serving trafﬁc after anyone stops
owning them. The deprecation playbook:
• Trigger a deprecation review when a replacement model is promoted.
• Inventory downstream dependencies. Who calls this model? What happens to them when
it is retired?
• Deﬁne a sunset window: deprecated but still available, with notiﬁcations to consumers.
• Retire when: replacement is validated, downstream systems have migrated, documentation
is archived, and stakeholders are notiﬁed.
• Retain model artifacts and training data for the period required by legal, regulatory, contrac-
tual, and audit requirements. The speciﬁc retention period depends on jurisdiction, industry,
and use case; work with legal counsel to determine it.
Figure 27.9 shows the full set of lifecycle states, from development through retirement.
27.10 Telemetry Schema Design
Observability depends on consistent telemetry across all AI systems. Table 27.3 lists the minimum
ﬁelds for model inference logging. All timestamps use Coordinated Universal Time (UTC).
Table 27.3: Minimum telemetry schema for model inference logging.
Field Type Description
request_id string Unique identiﬁer for
correlation
timestamp datetime Inference time (UTC)
23

<!-- page 24 -->
Field Type Description
model_id string Model identiﬁer
model_version string Deployed model version
trace_id string Distributed trace ID for
X-Ray/OTel
feature_hash string Hash of input feature vector
for drift comparison
prediction varies Model output (score, class,
text)
conﬁdence ﬂoat Conﬁdence score if applicable
latency_ms int Inference latency
token_count_in int Input tokens (LLM)
token_count_out int Output tokens (LLM)
cost_usd ﬂoat Computed inference cost
guardrail_result string Pass/fail/ﬂag
segment_id string Customer segment for slice
analysis
label_join_key string Key for joining delayed
ground truth
For LLM systems, add prompt_template_id, retrieval_source_ids (for RAG), judge_scores (from
LLM-as-judge), and redacted_content_ﬂag.
27.11 Model Monitoring Incident Runbook
When a monitoring alert ﬁres, the on-call engineer should follow a structured triage process:
1. Conﬁrm the alert. Rule out a false positive. Check that data pipelines are running normally,
that the monitoring system itself is healthy, and that nobody recently changed the threshold.
2. Check data freshness. Verify that features are arriving on time. Stale features are a common
root cause that looks like model drift.
3. Compare feature distributions. Pull the baseline and current distributions for the ﬂagged
features. Determine whether the shift is limited to speciﬁc features or widespread.
4. Review recent deployments. Check deployment history. Did a new model version, prompt
template, or dependency deploy in the alert window?
5. Evaluate segment impact. Determine whether the issue affects all users or speciﬁc segments.
Slice-level analysis often reveals the root cause.
6. Decide response. Options include: investigate further (no immediate action), roll back to
previous version, disable the feature or model, trigger emergency retraining, or escalate to
governance if a guardrail was breached.
7. Document the incident. Log ﬁndings in the incident record. If P1 or P2, trigger the post-
mortem workﬂow.
24

<!-- page 25 -->
Figure 27.9: Model lifecycle states from development through retirement, showing the governance check-
points and artifact retention requirements at each stage.
25

<!-- page 26 -->
27.12 Terraform Example: CloudWatch Alarm for Model Drift
Terraform is an infrastructure-as-code tool: it deﬁnes cloud resources in conﬁguration ﬁles so they
can be reviewed, versioned, and deployed like software. The following listing creates a Cloud-
Watch alarm that ﬁres when a scheduled drift job reports a PSI above 0.2 on a core feature. It
assumes the drift job (for example, an Evidently AI report running on a schedule) publishes its PSI
score for each feature to a custom CloudWatch namespace.
resource "aws_cloudwatch_metric_alarm" "model_drift_alarm" {
alarm_name = "churn-model-income-band-drift"
comparison_operator = "GreaterThanThreshold"
evaluation_periods = 2
datapoints_to_alarm = 2
metric_name = "FeatureDriftPSI"
namespace = "EAIE/ModelMonitoring"
period = 86400
statistic = "Maximum"
threshold = 0.2
treat_missing_data = "breaching"
alarm_description = "PSI for income_band above 0.2 for two daily windows"
dimensions = {
ModelName = "churn-model"
Feature = "income_band"
}
alarm_actions = [aws_sns_topic.ml_alerts_p2.arn]
ok_actions = [aws_sns_topic.ml_alerts_resolved.arn]
tags = {
Environment = "production"
Team = "ml-platform"
AlertTier = "P2"
}
}
resource "aws_sns_topic" "ml_alerts_p2" {
name = "ml-alerts-p2"
}
resource "aws_sns_topic" "ml_alerts_resolved" {
name = "ml-alerts-resolved"
}
Setting treat_missing_data to "breaching" means the alarm also ﬁres if the drift job stops report-
ing, so a broken monitor does not look like a healthy model.
The same pattern works for LLM observability: a CloudWatch alarm on Bedrock invocation latency,
a custom metric for groundedness scores from an LLM-as-judge sidecar, and an SNS topic that
26

<!-- page 27 -->
routes to the on-call channel. The infrastructure stays the same; only the metric deﬁnitions and
thresholds change.
27.13 Use Case: Retail Customer Acquisition and Retention
The retail AI portfolio’s monitoring framework instruments all ﬁve layers for both the recommen-
dation engine and the churn prediction model.
27.13.1 Recommendation engine monitoring
• Infrastructure layer: SageMaker endpoint health, GPU utilization, request queue depth;
alerted on standard platform SLOs.
• Pipeline layer: Real-time feature service availability, feature freshness (alert if any feature is
more than 5 minutes stale), and embedding pipeline success rate.
• Model layer: Output embedding drift tracked daily (alert if the distance between the current
embedding centroid and the rolling 30-day baseline centroid exceeds a calibrated threshold,
with Maximum Mean Discrepancy as a weekly multivariate check), recommendation conﬁ-
dence distribution shift, and NDCG@10 (normalized discounted cumulative gain, a score of
how well the top 10 recommendations are ranked) on the labeled sample stream.
• Application layer: p99 latency on the recommendation API (SLO: under 200ms), error rate,
and timeout rate by client segment.
• Business layer: Click-through rate on recommendations versus control, add-to-cart rate,
and return rate on recommended products (the recommendation engine’s primary lagging
guardrail).
27.13.2 Churn prediction model monitoring
• Drift detection: Weekly PSI on the top 10 features (alert if PSI exceeds 0.2); monthly ground-
truth comparison once 30-day churn outcomes are available; quarterly slice-based audit
across customer tenure segments and demographic groups.
• Retraining triggers: Scheduled quarterly retrain, plus a drift-triggered retrain if PSI exceeds
0.2 on core features. New versions go through a ﬁxed A/B test, because the decision affects
how customers are treated and must be auditable: 10% of customers go to the challenger for
two weeks. The primary success metric is 30-day recall, the share of customers who actually
churned within 30 days that the model ﬂagged in advance. A breach of the fairness-disparity
guardrail triggers rollback.
• Governance integration: Every retrained version is logged in the model registry with a full
audit trail, including its model card (Mitchell et al. 2019), so the team can answer questions
from legal, compliance, or regulators about how the model changed and why. Threshold
changes require approval from the AI Governance Board at the same level as the original
deployment.
27.13.3 LLM-based offer generation monitoring
• Token economics: Per-offer token spend, daily aggregate cost (alert at 80% of budget, hard stop
at 110%), latency p95 by offer category.
27

<!-- page 28 -->
• Quality: Groundedness score from LLM-as-judge on a 5% sample of generated offers, re-
fusal rate (offers that could not be generated), and prompt injection detection rate from the
OWASP-LLM-Top-10-aligned guardrails (OWASP GenAI Security Project 2026).
• Weekly human review: The marketing operations team reviews ﬁfty randomly sampled of-
fer/customer pairs, and disagreements feed back into LLM-as-judge calibration.
The monitoring outputs feed three dashboards (engineering real-time, product daily, executive
weekly) that mirror the metrics chapter’s three-layer pattern. Every guardrail alert routes through
the severity-tiered escalation paths deﬁned earlier in this chapter.
27.14 Key Takeaways
• Deployment is the beginning of a much harder engineering problem. Production AI
systems operate in a changing world. Without continuous monitoring, you have no idea
whether the system is still doing what you built it to do, and the failures that matter most
are the silent ones (Sculley et al. 2015).
• Monitor all ﬁve layers: infrastructure, pipeline, model, application, business. Each catches
failure modes the others miss, and the root cause usually shows up in correlations across
layers. A model that clears its infrastructure SLOs while producing bad outputs nobody
catches is the default failure this chapter is meant to prevent (Breck et al. 2017; Saltonstall
and Virji 2025).
• Know your drift types and their detection methods. Data drift (input distribution shift,
detectable without labels), concept drift (a change in the input-output relationship, hard to
detect without labels), and model degradation (performance decay, which requires ground
truth) call for different responses. Treating them as one leads to the wrong intervention
(Gama et al. 2014).
• Alert design is an engineering discipline in its own right. Tiered, actionable, threshold-
grounded alerts with deﬁned escalation paths prevent undetected failures and the alert fa-
tigue that gets real failures ignored. SRE vocabulary (SLIs, SLOs, and error budgets) makes
“reliable enough” precise (Thurgood et al. 2018).
• Generative AI and agents require different observability. Token economics, groundedness,
refusal rates, tool-call success, and LLM-as-judge sampling replace the numeric thresholds of
traditional ML monitoring. The OWASP LLM Top 10 deﬁnes the failure modes monitoring
must cover (Aryan 2025; Li et al. 2024; Arize AI 2025; OWASP GenAI Security Project 2026).
• MLOps maturity gates this discipline. Google’s MLOps levels (0: manual, 1: ML pipeline
automation with continuous training, 2: full CI/CD) describe what an organization can ac-
tually execute. The practices in this chapter assume at least a full Level 1 (Kazmierczak et al.
2024).
• Lifecycle decisions must be pre-deﬁned. Retraining triggers, A/B test success criteria, and
rollback conditions set in advance lead to disciplined responses; decisions made under pres-
sure lead to chaos. Bandit methods such as Thompson sampling can match or beat A/B
testing on speed under the right conditions, while A/B tests remain the better choice for
auditable, high-stakes promotions (McClendon et al. 2025).
• Every production model lives in the registry with its full provenance. That means the
model card, training data snapshot, evaluation results, deployment date, and approval
record. A model outside the registry is an unmanaged risk (Mitchell et al. 2019).
28

<!-- page 29 -->
27.15 Apply It
1. Five-layer monitoring architecture. For the retail churn prediction model, deﬁne the mon-
itoring plan for all ﬁve layers (infrastructure, pipeline, model, application, business). For
each layer, specify the key metrics, collection method, alert threshold, severity tier, response
protocol, and response owner.
2. Drift detection plan. Design the drift detection approach for the retail recommendation
engine. Specify: which drift types are most likely given the domain (data drift, concept drift,
or model degradation), which statistical tests you would apply (PSI, Kolmogorov-Smirnov,
or Jensen-Shannon divergence), and at what cadence; what the alert thresholds are, and how
you would detect concept drift given that recommendation outcomes lag by thirty or more
days.
3. Alert architecture. Design the full alert set for the retail AI platform across the churn model,
recommendation engine, and LLM-based offer generation system. Assign each alert a sever-
ity tier (P1 through P4), deﬁne the escalation path, identify which alerts route to the AI Gov-
ernance Lead versus the on-call engineer, and write the suppression rules for the top three
alert-storm scenarios you expect.
4. Retraining policy. Write the retraining policy for the retail churn model. Deﬁne all trigger
conditions (scheduled, drift, performance, business event), the minimum retraining dataset
window, the A/B-versus-bandit promotion protocol for new versions, the rollback criteria,
and the governance approval requirement for each threshold.
5. LLM observability plan. For the LLM-based offer generation system, design the observabil-
ity stack. Specify: which signals are monitored (groundedness, refusal rate, token spend,
prompt injection detection, output drift), how LLM-as-judge is calibrated against human re-
view, the sample rate for human evaluation, and how OWASP LLM Top 10 risks map onto
guardrail alerts.
6. AI prompt. “You are an AI operations engineer reviewing the following monitoring plan for an en-
terprise recommendation engine. Identify: (1) which failure modes are not covered by the current plan,
(2) whether the alert thresholds are likely to produce alert fatigue or missed detections, (3) whether the
drift detection method matches the actual drift type most likely in this domain, and (4) what additional
observability would be required to diagnose a sudden ten percent drop in conversion rate. Provide con-
crete remediation recommendations ordered by expected impact: [paste your monitoring plan from
Exercise 1].”
27.16 What’s Next
Monitoring tells you when things go wrong. The next chapter, Reliability Engineering: Building
AI Systems That Hold Under Pressure and Recover Fast, covers what you do about it, because an
early warning helps only if the team has practiced its response. Reliability engineering deﬁnes the
architecture patterns, runbooks, chaos engineering practices, and incident protocols that determine
how fast you can contain, diagnose, and recover from production failures, and how systematically
your organization learns from each one.
29

<!-- page 30 -->
27.17 References
Amazon Web Services. 2026a. Amazon Bedrock AgentCore Generated Observability Data. Amazon
Bedrock AgentCore Developer Guide. https://docs.aws.amazon.com/bedrock-agentcore/la
test/devguide/observability-service-provided.html.
Amazon Web Services. 2026b. Generative AI Observability. Amazon CloudWatch User Guide. https:
//docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/GenAI-observability.ht
ml.
Arize AI. 2025. LLM as a Judge: Primer and Pre-Built Evaluators. Arize AI. https://arize.com/llm-
as-a-judge/.
Aryan, Abi. 2025. LLMOps: Managing Large Language Models in Production. O’Reilly Media.
Autio, Chloe, Reva Schwartz, Jesse Dunietz, et al. 2024. Artiﬁcial Intelligence Risk Management
Framework: Generative Artiﬁcial Intelligence Proﬁle. National Institute of Standards and Technol-
ogy (NIST). https://doi.org/10.6028/NIST.AI.600-1.
Breck, Eric, Shanqing Cai, Eric Nielsen, Michael Salib, and D. Sculley. 2017. “The ML Test Score:
A Rubric for ML Production Readiness and Technical Debt Reduction.” 2017 IEEE International
Conference on Big Data (Big Data), 1123–32.
Chang, Yupeng, Qiang, Yang, Xu Wang, et al. 2024. “A Survey on Evaluation of Large Language
Models.” ACM Transactions on Intelligent Systems and Technology, ahead of print. https://doi.or
g/10.1145/3641289.
Gama, João, Indrė Žliobaitė, Albert Bifet, Mykola Pechenizkiy, and Abdelhamid Bouchachia. 2014.
“A Survey on Concept Drift Adaptation.” ACM Computing Surveys 46 (4): 1–37. https://doi.or
g/10.1145/2523813.
Grace, Mikaela, Jeremy Hadﬁeld, Rodrigo Olivares, and Jiri De Jonghe. 2026. Demystifying Evals
for AI Agents. Anthropic Engineering Blog. https://www.anthropic.com/engineering/demy
stifying-evals-for-ai-agents.
Huyen, Chip. 2022. Designing Machine Learning Systems: An Iterative Process for Production-Ready
Applications. O’Reilly Media. https://www.oreilly.com/library/view/designing-machine-
learning/9781098107956/.
Jeremy Hermann and Mike Del Balso. 2017. “Meet Michelangelo: Uber’s Machine Learning Plat-
form.” In Uber Engineering Blog. https://www.uber.com/us/en/blog/michelangelo-machine-
learning-platform/.
Johnson, Nari, Ángel Alexander Cabrera, Gregory Plumb, and Ameet Talwalkar. 2023. “Where
Does My Model Underperform? A Human Evaluation of Slice Discovery Algorithms.” AAAI
Conference on Human Computation and Crowdsourcing (HCOMP) 11: 65–76. https://doi.org/10
.48550/arXiv.2306.08167.
30

<!-- page 31 -->
Kazmierczak, Jarek, Khalid Salama, and Valentin Huerta. 2024. MLOps: Continuous Delivery and
Automation Pipelines in Machine Learning. Google Cloud Architecture Center. https://cloud.go
ogle.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-
learning.
Li, Haitao, Qian Dong, Junjie Chen, et al. 2024. LLMs-as-Judges: A Comprehensive Survey on LLM-
Based Evaluation Methods. https://doi.org/10.48550/arXiv.2412.05579.
McClendon, S. Aaron, Vishaal Venkatesh, and Juan Morinelli. 2025. Reinforcement Learning for
Machine Learning Model Deployment: Evaluating Multi-Armed Bandits in ML Ops Environments.
https://doi.org/10.48550/arXiv.2503.22595.
Mitchell, Margaret, Simone Wu, Andrew Zaldivar, et al. 2019. “Model Cards for Model Reporting.”
Proceedings of the Conference on Fairness, Accountability, and Transparency (FAccT), 220–29. https:
//doi.org/10.1145/3287560.3287596.
OWASP GenAI Security Project. 2026. OWASP Top 10 for LLM Applications 2026. https://genai.ow
asp.org/resource/owasp-genai-llm-top-10-2026/.
Saltonstall, Max, and Salim Virji. 2025. An SRE’s Guide to Optimizing ML Systems with MLOps
Pipelines. Google Cloud Blog. https://cloud.google.com/blog/products/devops-sre/applyi
ng-sre-principles-to-your-mlops-pipelines.
Sculley, D., Gary Holt, Daniel Golovin, et al. 2015. “Hidden Technical Debt in Machine Learning
Systems.” Advances in Neural Information Processing Systems (NeurIPS) 28: 2503–11.
Thurgood, Steven, David Ferguson, Alex Hidalgo, and Betsy Beyer. 2018. “Implementing SLOs.”
In The Site Reliability Workbook: Practical Ways to Implement SRE. O’Reilly Media. https://sre.go
ogle/workbook/implementing-slos/.
Yurdakul, Bilal, and Joshua Naranjo. 2020. “Statistical Properties of the Population Stability Index.”
Journal of Risk Model Validation 14 (4): 89–100. https://doi.org/10.21314/JRMV.2020.227.
31