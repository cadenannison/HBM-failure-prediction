# Ch19-Data-Feature-Engineering.pdf (extracted text, 18 pages)

<!-- page 1 -->
Chapter 19
Data & Feature Engineering: Turning
Raw Data into AI Fuel
19.1 Motivation
A major retailer spends eight months building a customer churn model. The data scientists are
talented. The architecture is sound. The model scores well in testing. They deploy it, and within
six weeks, the predictions degrade to the point of being useless.
The post-mortem is unglamorous. The production data pipeline was computing features differ-
ently from the training pipeline. The model was trained on one version of reality and deployed
into another. Nobody wrote bad code, and nobody made a single bad decision. Two teams, each
running two separate pipelines, handled null values in a behavioral ﬁeld differently. By the time
the gap was found, the marketing team had already given up on the predictions and reverted to
rules-based segmentation.
This is the training-serving skew problem, one of the most expensive failure modes in enterprise
AI (Sculley et al. 2015; Zinkevich 2017), and it is a data engineering failure rather than a modeling
one. It is also invisible: no exception is thrown, no alert ﬁres, no system logs an error, so the model
keeps running while its predictions get worse without anyone noticing.
Data engineering is the real work of building AI systems, not the unglamorous prelude data scien-
tists rush through to get to modeling.
The Anaconda State of Data Science 2022 survey reports that data scientists spend roughly 45%
of their time on data preparation tasks (Anaconda Inc. 2022). That is, nearly half the time of your
most expensive technical talent is consumed by data work. And the alternative produces the skew-
driven failures that quietly kill production systems.
This chapter covers everything from raw data sources to the features that models consume, and
how to keep the process consistent from training to production.
19.2 Challenge
How do you design and operate data pipelines and feature management systems that deliver reli-
able, consistent, high-quality data to AI systems, from initial training through years of production
1

<!-- page 2 -->
operation, without creating the skew, drift, and silent quality failures that destroy model perfor-
mance?
The real challenge is treating data as an engineered, operated, governed system rather than a series
of one-off transformations executed by whoever happened to need them; picking the right tools
is secondary. Data engineering for AI requires the same operational discipline that site reliability
engineering brought to infrastructure (Betsy Beyer, Chris Jones, Jennifer Petoff, and Niall Richard
Murphy 2016).
19.3 Objectives
By the end of this chapter, you will be able to:
1. Explain why data engineering for AI differs fundamentally from data engineering for ana-
lytics, and what those differences require operationally.
2. Choose between batch, streaming, and event-driven ingestion patterns using explicit archi-
tectural criteria, mapped to AWS-native services.
3. Operationalize data quality through data contracts, automated validation, and incident-
response practices, not periodic audits.
4. Design feature engineering practices that reduce training-serving skew through shared
pipelines, point-in-time-correct joins, and version-controlled transformation code.
5. Decide whether and when your enterprise needs a feature store, and which one, using a
ﬁve-dimensional architectural framework.
6. Implement data lineage that holds up under regulatory audit and accelerates debugging,
retraining, and impact analysis.
7. Apply data versioning, schema evolution, and governance controls that protect reproducibil-
ity, privacy, and compliance.
LLM-based and agent data engineering, document pipelines, embeddings, vector stores, tool logs, and mem-
ory stores are covered in the next chapter: Model Development.
19.4 From Strategy to Build: What This Chapter Inherits
By the time you reach data engineering, three artifacts from earlier chapters deﬁne the work:
The AI-PRD (from Chapter 16). The PRD speciﬁes the required features, in-scope data sources,
freshness SLAs, and quality thresholds. If the PRD says “real-time fraud signals within 200ms of
a transaction event,” your ingestion architecture is constrained to streaming. If it says “monthly
LTV scoring,” batch is ﬁne. The PRD should resolve this before a single pipeline is designed.
The AI Strategy Portfolio Map (from Chapter 9). Contains the data readiness score and an honest
assessment of whether the data you need exists, is accessible, and is usable. A low score means
this chapter begins with remediation rather than construction.
The Platform Architecture (from Chapter 18). The cloud platform, data lake/warehouse, and
orchestration layer were decided in the previous chapter. Data engineering operates within that
platform.
If any of these inputs are vague or missing, the project is not ready for serious data engineering
work, regardless of timeline pressure.
2

<!-- page 3 -->
19.5 Why Data Engineering for AI Is Different
Data engineering for analytics and data engineering for AI share tools such as Spark, Kafka, and
dbt, but they differ in how they fail and in the disciplines they require.
Reproducibility is essential. Analytics tolerates minor discrepancies across runs. AI does not.
Debugging a model failure requires knowing exactly what data the model was trained on, which
transformations were applied, and which feature values produced each prediction. Without that,
you cannot reproduce the failure, retrain the ﬁx, or defend the system in a regulatory audit. Repro-
ducibility must be designed in from the start.
Training-serving consistency is structural. Analytics pipelines are consumed by humans who
read dashboards, and small differences can produce confusing reports. AI pipelines are consumed
by models that learned to expect speciﬁc feature distributions. Small differences between training
and serving pipelines produce predictions that look ﬁne, run fast, and are quietly wrong.
Data is a moving target. A pipeline that was correct at build time can become silently incorrect
in production without a single line of code changing. Customer behavior shifts; markets change;
upstream systems get redesigned. This demands explicit drift monitoring as a data engineering
responsibility, not a data science afterthought.
The blast radius is wider. A broken analytics pipeline produces a wrong dashboard. A broken
AI data pipeline produces wrong predictions at scale, denying credit, recommending the wrong
product, and ﬂagging the wrong transaction as fraud. The cost is measured in business decisions
made on bad inputs.
Figure 19.1: Data Analytics focuses on producing accurate, reliable aggregations that power dashboards and
business reports.
3

<!-- page 4 -->
Figure 19.2: AI Data Engineering focuses on creating features that preserve the same signal across training,
evaluation, and production inference. The quality bar is exact because even a small difference—such as label
encoding between training and production—can silently break model performance. Freshness depends on
the use case, ranging from nightly updates for a churn model to sub-second updates for fraud detection.
Schema changes are also high risk, because a model trained against an old schema may require retraining
when the underlying data structure changes.
4

<!-- page 5 -->
19.6 AWS Data Engineering Reference Architecture
Every enterprise AI data pipeline moves data through the same logical zones, shown in the ﬁgure
below. Translating this generic reference architecture into an AWS-native implementation for each
zone produces the following:
Figure 19.3: End-to-end AI data pipeline architecture illustrating how source data is ingested, validated,
enriched, transformed into features, used for model training and inference, and monitored for quality and
lineage.
Databricks on AWS, Apache Kafka on MSK, and open-source feature stores (Feast, Tecton) are all
valid alternatives within this architecture. The reference implementation uses AWS-native services
throughout; alternatives are noted where they offer material advantages.
19.7 Data Ingestion: Three Patterns, One Architecture
Most enterprise AI systems use all three ingestion patterns simultaneously, and the real question
is how they compose and which applies where.
19.7.1 The Three Patterns
Batch ingestion: scheduled extraction from source systems on a ﬁxed cadence. AWS-native stack:
AWS Glue (managed ETL), Amazon EMR (Spark for large volumes), AWS DMS (database migra-
tion/replication), Amazon S3 as the landing zone.
When batch is right: historical training data, large-volume periodic loads, sources that cannot emit
events, and latency tolerance measured in hours.
5

<!-- page 6 -->
Failure modes: pipeline failures discovered during business hours, not at 2 AM; schema changes in
source systems silently break pipelines; backﬁlls during incidents take hours.
Streaming ingestion, continuous data ﬂow for near-real-time feature computation. AWS-native
stack: Amazon Kinesis Data Streams or Amazon MSK for the stream; Apache Flink, Kinesis Data
Analytics, or Kafka Streams for computation.
When streaming is right: behavioral signals (clickstream, transactions), low-latency inference de-
pendencies (fraud detection, real-time recommendations), use cases where ﬁve-second-old data
changes outcomes.
Failure modes: out-of-order events; late-arriving data; consumer lag (your processor falls behind,
scoring on stale data without knowing it); exactly-once delivery is not truly guaranteed end-to-end.
Event-driven ingestion, triggered by actions in upstream systems. AWS-native stack: Amazon
EventBridge (rules-based event routing), Amazon SQS (durable queuing), AWS Lambda (event
processing), Debezium/DMS for change-data-capture.
When event-driven is right: operational system events (purchase completions, loyalty enrollments,
case closures), SaaS webhooks, human-in-the-loop feedback signals.
Failure modes: delivery is the producer’s responsibility. If a webhook fails without retries, the event
is lost; duplicate events require idempotent receivers; event ordering is not guaranteed across pro-
ducers. An idempotent receiver is smart enough to check if it has already processed that speciﬁc
event. If a duplicate arrives, the system ignores it or handles it safely so it does not, for example,
charge a customer twice or log a duplicate loyalty enrollment.
19.7.2 Ingestion Pattern Decision Table
Table 19.1: Ingestion Pattern Decision Table — Pattern, Latency, Volume, AWS Services, Best For, Avoid
When.
Pattern Latency Volume AWS Services Best For Avoid When
Batch Hours High periodic Glue, EMR,
DMS
Training data,
bulk loads,
ofﬂine
features
Model needs
sub-hour
freshness
Streaming Seconds–
minutes
Continuous Kinesis, MSK,
Flink
Behavioral
signals, fraud,
real-time
features
Source can
only be
polled;
exactly-once
critical
Event-driven Sub-second Sparse
triggered
EventBridge,
SQS, Lambda
Operational
events,
webhooks,
feedback
High-volume
continuous
data
Design principles that apply to all three: schema-ﬁrst validation (reject bad data at the boundary),
idempotent pipelines (running twice produces the same result), explicit backﬁll capability, and
observability on every run.
6

<!-- page 7 -->
19.8 Data Transformation and Operational Quality
Once ingested, data moves through a layered transformation stack, each layer with a distinct
owner, schema contract, and quality bar.
Raw zone, immutable record of what arrived. Stored in Amazon S3 with object versioning enabled.
Never transform in place. This is the auditable ground truth required when a model decision is
challenged and you must prove what the system saw.
Cleaned zone, nulls handled, encodings normalized, formats standardized, duplicates resolved.
Owned by the data engineering team.
Enriched zone, joined with reference data, derived ﬁelds added, business logic applied. Where
domain expertise begins entering the pipeline.
Feature zone, ML-speciﬁc computation: aggregations, time-windowed statistics, encoded categor-
icals, embeddings. Where data engineering meets data science.
19.8.1 Data Contracts
The pattern for managing quality at scale is data contracts: formal, machine-readable agreements
between data producers and consumers specifying schema, semantics, quality SLAs, and breaking-
change protocols. When a producer violates the contract, the pipeline fails at the boundary rather
than propagating bad data to every downstream model.
Data contracts convert quality from “tests we run” to “agreements we hold each other to.” When
a regulator asks how you know your training data was complete, the answer is a contract with an
SLA, automated tests that verify it, and a change-management process. That answer holds up.
19.8.2 Data Quality Tooling
Four tools dominate in 2026, each with distinct strengths:
• Great Expectations, Python-ﬁrst, programmatic. Best for development-time validation and
CI/CD checks. Auto-generated “Data Docs” function as living data contracts between teams.
• Soda Core, YAML/SQL-based, declarative. Best for continuous production monitoring with
native Slack/PagerDuty alerting.
• dbt tests, lightweight, inside the transformation layer. Best for SQL-native teams already
running dbt.
• AWS Glue Data Quality / Deequ, Spark-native, designed for large-scale validation on AWS-
resident datasets.
The enterprise pattern: Great Expectations in development and CI/CD; Soda for continuous pro-
duction monitoring.
Quality failures need an explicit policy per check: fail-fast (halt the pipeline, page on-call), quaran-
tine (route to dead-letter queue, continue), or alert-and-continue (notify, proceed). The discipline
is the policy, not the tooling (Breck et al. 2017).
7

<!-- page 8 -->
19.8.3 Data Versioning and Reproducibility
Reproducibility requires knowing exactly which data snapshot was used to train each model. The
technical mechanisms:
• Table formats with time travel, Apache Iceberg, Delta Lake (native to Databricks), and
Apache Hudi all support snapshot-based reads: you can query a table’s state at any past
timestamp. This is the foundation of reproducible training datasets.
• Immutable training snapshots: at the start of each training run, write the training dataset to
a versioned S3 preﬁx and log the snapshot ID in the model registry. Retraining starts from
the snapshot, not a live query.
• Dataset versioning tools, DVC (Data Version Control), provide Git-like semantics for large
ﬁles and datasets, storing data in S3/GCS and metadata in Git.
Without one of these mechanisms, “reproduce this model’s training run” becomes an archaeologi-
cal exercise that consumes days and often fails.
19.8.4 Schema Evolution
Source system schemas change. How your pipeline handles that change determines whether the
incident is a ﬁve-minute automated recovery or a two-day debugging session.
• For backward-compatible changes (such as adding a nullable column or widening a type),
your pipeline should handle them without stopping. Schema registries (AWS Glue Schema
Registry, Conﬂuent Schema Registry) enforce compatibility rules automatically.
• Breaking changes (renaming a column, changing a type incompatibly, removing a ﬁeld) re-
quire coordinated versioning. The data contract must be versioned; consumers must explic-
itly migrate before the old version is retired.
• Semantic changes without schema changes, the hardest case. The column still exists; the
business deﬁnition changed. This is why data contracts include semantic deﬁnitions, not
just schema.
Invest in a schema registry early. Debugging a schema evolution failure in production is orders of
magnitude more expensive than enforcing compatibility at the ingestion boundary.
19.9 Feature Engineering: Where Domain Expertise Becomes Signal
Features are the inputs models learn from. Feature quality sets the ceiling on what any model can
achieve. Good features make simple models work well. Bad features make complex models fail
in expensive ways. Feature engineering is also where domain expertise enters the AI system.
19.9.1 Point-in-Time Correctness
Point-in-time correctness is the requirement that every feature value used in training reﬂects only
information available at the historical prediction timestamp, not information from the future.
A concrete example: for a churn prediction made on March 1, the feature support_contacts_30d
must count only support contacts that occurred between February 1 and March 1. If your training
pipeline accidentally includes contacts from March 2 to 15, the model learns from information
8

<!-- page 9 -->
that did not exist when it was trained, inﬂating test-set accuracy and leaving production accuracy
worse than the test set predicted. Point-in-time correctness prevents this.
Feature stores enforce point-in-time correctness natively through historical point-in-time joins.
They are the architectural mechanism that makes this property reliable rather than dependent on
every data scientist getting the SQL join exactly right.
19.9.2 Feature Types
• Aggregation features: counts, sums, averages, ratios over time windows. The workhorse of
predictive ML.
• Behavioral features: session patterns, event counts, conversion-funnel transitions. Often
computed in streaming.
• Contextual features: time of day, device type, and location signals. Cheap to compute, often
surprisingly predictive.
• Embedding features: vector representations of text, behavior, or interactions. Require their
own freshness and versioning discipline.
19.9.3 Training-Serving Consistency
Every feature transformation must be versioned, reproducible, and deployable in both training and
serving. The anti-pattern is deﬁning features in a Jupyter notebook for training and rewriting them
in production Java or Python for serving. The two implementations will diverge within months.
By the time anyone notices, the model has been trained on one deﬁnition and served another.
The structural ﬁx: feature transformations live in shared, version-controlled code that is executed
by both the training and serving paths. Feature stores enforce this architecturally.
19.9.4 Feature Leakage
Leakage happens when a feature uses information unavailable at prediction time. Three common
patterns:
• Temporal leakage: training features include data from after the prediction timestamp.
• Target leakage: features encode the target variable’s downstream consequences. Example:
“received a retention offer” as a churn feature, where offers were sent because the legacy sys-
tem predicted churn.
• Group leakage: training, test, and validation sets share records from the same entity (split-
ting transactions randomly rather than by customer).
Prevention: strict temporal validation and point-in-time-correct feature retrieval. Build a habit of
asking, for every feature: “Would this value have existed at the moment the prediction would have
been made?”
19.10 Feature Stores: The Architectural Control for Skew
A feature store is a centralized system for deﬁning, storing, versioning, and serving features for
training (historical, point-in-time-correct) and production (low-latency, real-time). It is an archi-
tectural control that substantially reduces training-serving skew risk when feature deﬁnitions,
point-in-time joins, online/ofﬂine materialization, and monitoring are correctly implemented. It
9

<!-- page 10 -->
does not eliminate skew by magic; skew can still occur from stale online features, backﬁll bugs,
inconsistent entity keys, or online/ofﬂine synchronization lag. The architectural commitment re-
duces the probability; operational discipline eliminates the remaining risk.
The modern feature store concept emerged from Uber’s Michelangelo platform (Jeremy Hermann
and Mike Del Balso 2017). Airbnb’s Zipline (Simha and Hoh 2018) developed in parallel; both
arrived at the same insight: centralize feature deﬁnition, share computation, and serve training
and inference from a single source of truth.
19.10.1 Feature Store Architecture
Figure 19.4: A Feature Store centralizes feature deﬁnitions, transformations, metadata, and serving so ma-
chine learning teams can compute consistent features for both ofﬂine training and low-latency online infer-
ence.
• Feature registry: catalog of all deﬁned features: names, owners, computation logic, depen-
dencies, lineage.
• Feature Engineering Pipeline: code that computes features from source data, executing iden-
tically in ofﬂine and online paths.
• Ofﬂine store: historical feature values for training. On AWS: Amazon S3 with Athena or
Redshift for querying; the SageMaker Feature Store’s ofﬂine store natively uses S3 + Glue
Catalog.
• Online store: a low-latency feature serving for real-time inference. On AWS: Amazon Dy-
namoDB or ElastiCache (Redis); SageMaker Feature Store’s online store provides millisecond
reads.
19.10.2 The Five Architectural Dimensions
10

<!-- page 11 -->
Table 19.2: The Five Architectural Dimensions — Dimension, What to Assess.
Dimension What to Assess
Feature freshness model Batch sync? Streaming? In-system compute?
Does your latency requirement match the
store’s capability?
Consistency guarantees Per-key eventual consistency, or cross-entity
transactional? Online store may hold only
latest values.
Semantic operations Native vector similarity search (for embedding
features), or external vector DB required?
Compute locality External pipelines write to the store, or does
the store run its own declarative transforms?
Operational surface area How many systems must your team operate
end-to-end? Open-source ﬂexibility costs
operational time.
19.10.3 Feature Store Capability Comparison
Table 19.3: Feature Store Comparison — Platform, Best For, Freshness, AWS Integration, Notes.
Platform Best For Freshness
AWS In-
tegration Notes
SageMaker
Feature Store
AWS-native
enterprises
Batch +
stream-
ing
Native Ofﬂine (S3/Glue), online (low-latency),
tight SageMaker Pipelines integration
Databricks
Feature
Engineering
Databricks
Lakehouse
shops
Batch +
stream-
ing
Databricks
on AWS
Unity Catalog integration; strong
MLﬂow lineage
Tecton Multi-cloud,
high
real-time
Streaming,
continu-
ous
Cloud-
agnostic
Declarative feature pipelines;
enterprise pricing; founded by
Michelangelo creators
Feast Teams
wanting full
control
Batch +
stream-
ing
Pluggable
connec-
tors
Open-source; ﬂexible but operationally
demanding
Vertex AI
Feature Store
GCP-native
teams
Batch +
stream-
ing
GCP Primary reference for GCP shops
19.10.4 When to Adopt
• Fewer than three models in production, probably no feature store yet. Well-organized
shared pipeline code sufﬁces.
• Three to ten models, single team, lightweight feature store. SageMaker Feature Store if
AWS-native; Databricks if on Lakehouse.
11

<!-- page 12 -->
• Multiple teams sharing features, enterprise feature store (SageMaker, Databricks, or Tecton).
The investment pays back the ﬁrst time three teams stop independently rewriting the same
aggregation feature.
• Real-time + cross-team + regulated industry, SageMaker Feature Store or Tecton. Auditabil-
ity and point-in-time correctness are hard requirements.
19.11 Data Lineage and Provenance
Lineage answers the question every regulator, debugger, and auditor eventually asks: where did
this come from? Four dimensions matter for AI:
• Data lineage: which sources, which transformations, which owners.
• Feature lineage: which raw ﬁelds and business logic produced this feature value.
• Model lineage: which dataset and feature versions trained this model version.
• Prediction lineage: which model version, feature values, and inputs produced this predic-
tion on this date for this entity.
Prediction lineage is the gold standard for regulated industries and the bar for defending an auto-
mated decision under examination.
19.11.1 OpenLineage
Between 2025 and 2026, the shift underway is OpenLineage, an emerging cross-vendor standard
for emitting and collecting lineage metadata. Rather than every platform maintaining a propri-
etary lineage format, OpenLineage provides a common speciﬁcation. Airﬂow, dbt, Apache Spark,
Debezium, and IBM watsonx increasingly support OpenLineage natively or through integrations.
For enterprises building AI on multi-vendor stacks, OpenLineage avoids lineage visibility gaps at
platform boundaries.
Adoption is still uneven: OpenLineage requires integration work and careful implementation
across your speciﬁc stack. But it is the right direction for any enterprise that does not want to
rebuild its lineage strategy in three years.
19.11.2 AWS Lineage Implementation
On AWS: AWS CloudTrail logs every API call (data movement, access, modiﬁcation). Amazon
SageMaker Lineage Tracking captures model, dataset, and artifact relationships automatically
within SageMaker Pipelines. AWS Glue provides table-level lineage within the Glue Catalog. For
end-to-end lineage spanning Glue, SageMaker, and S3, OpenLineage connectors bridge the gaps.
19.11.3 Implementation Order
1. Model lineage ﬁrst, required for retraining, immediately auditable. SageMaker Lineage
Tracking covers this.
2. Feature lineage second, tied to feature store adoption; once features are centrally deﬁned,
lineage is tractable.
3. Full prediction lineage third, point-in-time feature values logged with every prediction. Re-
quired for regulated industries and uses substantial storage and observability.
12

<!-- page 13 -->
19.12 Governance, Privacy, and Security
Data engineering for AI falls squarely under enterprise data governance, and several concerns here
are non-negotiable:
PII handling: training data must be minimized to what is necessary for the intended use. PII ﬁelds
not needed for the model should be excluded at ingestion rather than collected and left unused.
AWS Lake Formation provides column-level and row-level security on S3-backed datasets; IAM
policies and KMS encryption govern access at rest and in transit.
Retention and right-to-delete: GDPR and CCPA grant individuals the right to delete. For AI
systems, this is operationally complex: if a customer’s data was in the training set, deletion may
require retraining or, at a minimum, removal from feature stores and prediction logs. Document
which datasets contain PII and build explicit deletion workﬂows before regulators ask.
Access controls on training data: not every model team should have unrestricted access to raw
production data. Lake Formation enables ﬁne-grained access policies (row ﬁlters, column masks),
allowing data scientists to work with de-identiﬁed or aggregated data while raw PII remains re-
stricted to systems with the appropriate access tier.
Consent and purpose limitation: data collected for one purpose (transaction processing) may not
be permissible for another (behavioral modeling) without consent, depending on jurisdiction and
your privacy policy. Purpose limitation must be a design constraint in the data contract, not a legal
review that happens after the pipeline is built.
Audit trails: CloudTrail, combined with S3 access logs and Glue job history, provides an auditable
record of who accessed what data and when. For regulated industries, this record is a compliance
requirement. For everyone else, it is what makes the post-mortem of a data incident tractable.
19.13 Use Case: Retail Customer Acquisition and Retention
The retail system is AWS-anchored, and by this chapter the platform is already provisioned, so this
section moves data through it.
Sources, volumes, and ingestion patterns
Table 19.4: Use Case: Retail Customer Acquisition and Retention — Source, Volume, Pattern, AWS Ser-
vices.
Source Volume Pattern AWS Services
POS transactions ~50K events/min
peak
Streaming Amazon Kinesis Data Streams -> Flink
(Kinesis Data Analytics)
Customer proﬁles
(CRM)
~2 TB Batch
nightly
AWS DMS -> S3 raw zone -> Glue ETL
Loyalty program
activity
~1 GB/day Batch
nightly
Glue Python Shell job from loyalty API
Web/mobile
clickstream
~200K events/sec
peak
Streaming Amazon Kinesis Firehose -> S3, Flink
for session aggregation
Purchase
completion events
Sparse triggered Event-
driven
Amazon EventBridge -> SQS ->
Lambda (triggers churn score refresh)
13

<!-- page 14 -->
Source Volume Pattern AWS Services
External
demographics
~50 GB/week Batch
weekly
S3 SFTP landing -> Glue ETL
The event-driven source (purchase completion) exercises the third pattern: when a customer com-
pletes a purchase, an EventBridge rule ﬁres, a Lambda function reads the updated features from
SageMaker Feature Store online tier, and the churn model re-scores that customer within seconds.
Data quality framework (three tiers, all implemented in Soda Core for production monitoring):
• Fail-fast (halt pipeline, page on-call): transaction amount null rate > 0.1%; customer ID format
violation; primary-key duplicates in CRM sync.
• Quarantine (dead-letter queue, continue): transaction amount outside USD 0.01 to 10,000; cus-
tomer tenure outside 0 to 30 years; clickstream events with invalid session IDs.
• Alert-and-continue (Sev-2/3 Slack alert): clickstream freshness > 5 minutes; feature distribution
drift > 2𝜎 from rolling 30-day baseline; loyalty null rate trending up week-over-week.
Feature deﬁnitions (top ten for churn model)
Table 19.5: Use Case: Retail Customer Acquisition and Retention — #, Feature, Source, Computation,
Leakage Risk.
# Feature Source Computation Leakage Risk
1 days_since_last_purchase POS today - max(txn_date) Low
2 txn_count_30d POS count(txns, date >=
today-30d)
Low
3 avg_order_value_90d POS mean(amount, date >=
today-90d)
Low
4 category_diversity_90d POS distinct(category, date
>= today-90d)
Low
5 loyalty_tier Loyalty Direct lookup Low
6 support_contacts_30d CRM count(cases, date >=
today-30d)
Medium,
verify cutoff
7 session_count_7d Clickstream distinct sessions, date
>= today-7d
Low
8 cart_abandonment_rate_30d Clickstream cart_abandons /
cart_starts, date >=
today-30d
Low
9 received_retention_offer_30d CRM count(offers, date >=
today-30d)
High, DROP.
Target
leakage.
Feature #9 is the lesson: it looks predictive in development but the causal direction is reversed.
The offer was sent because the legacy system predicted churn. Including this feature in the new
model lets it peek at the old model’s predictions. Drop it.
Feature store: SageMaker Feature Store. Six planned models across three teams (marketing, loy-
alty, fraud) warrant a managed, shared feature platform. SageMaker Feature Store’s ofﬂine tier
14

<!-- page 15 -->
(S3 + Glue Catalog) serves training; the online tier (low-latency reads) serves the real-time scoring
endpoint.
Lineage trace (sample): Customer X received churn intervention on 2026-05-15. Trace: Sage-
Maker Endpoint v4.2 –> Feature Set v7.1 (SageMaker Feature Store) –> Source datasets: POS snap-
shot s3://…/2026-05-14, CRM snapshot s3://…/2026-05-14, Clickstream window ending 2026-
05-15T14:30Z → Glue Job v3.2 –> Raw S3 objects (hash-veriﬁed). Held under audit, that trace
answers exactly what happened.
19.14 Real-World Case Study: Airbnb’s Zipline Feature Platform
By 2017, Airbnb had over 100 ML models in production across search ranking, pricing, fraud, and
customer experience. Each team owned its own feature pipelines (Simha and Hoh 2018). The
same logical feature, “host response rate over 30 days”, was implemented separately by multiple
teams, often inconsistently. Data scientists were spending approximately 60% of their time on
feature engineering work, a substantial portion of which was duplicated effort and skew-driven
debugging. Training-serving skew bugs were a recurring production incident category.
Airbnb built Zipline around three principles: features are deﬁned once in a declarative conﬁgu-
ration language from which the framework derives both batch and streaming implementations;
point-in-time correctness is enforced by construction so backﬁlls are generated correctly; and the
same code path executes for training and serving.
The reported outcomes: feature generation time dropped from months to approximately one day;
the class of training-serving skew bugs declined substantially; features became shareable across
teams rather than siloed per model. The executive lesson is about leverage: infrastructure invest-
ment in feature management compounds, and every future model the organization builds beneﬁts
from it.
Tecton, founded by the original Michelangelo creators (Jeremy Hermann and Mike Del Balso 2017),
productizes the same architectural insight. Airbnb’s Minerva platform (Amit Pahwa et al. 2021)
solved the adjacent problem of metric consistency across analytics using similar principles. Both
trace the same root cause: deﬁnitions that exist in multiple places diverge.
19.15 What Happens When Distribution Shifts: Zillow Offers
In November 2021, Zillow Group shut down its iBuying business after a $304 million inventory
write-down and a 25% workforce reduction (Gopal and Clark 2021). The business purchased
homes algorithmically, planning to resell at a proﬁt. By late 2021, it had purchased nearly 10,000
homes it could not proﬁtably resell.
Public reporting points to multiple causes: market volatility, pricing model limitations, operational
constraints, and inventory exposure. The data lesson is narrower and more actionable than a single
root cause: the valuation models were trained on data that did not reﬂect the rapidly shifting 2021
housing market. Whether better drift monitoring would have prevented or materially reduced the
losses is not established. What is established is the pattern: models deployed into changing data
distributions fail in proportion to how far the distribution has drifted, and the faster the market
moves, the faster the drift accumulates.
15

<!-- page 16 -->
For any executive running capital-intensive AI applications, the question that matters is how
quickly the team would detect this kind of failure, not whether the model could fail this way.
Feature distribution monitoring, data drift alerts, and model performance dashboards on produc-
tion data are the engineering answers. The Zillow case makes the business risk of skipping them
concrete.
19.16 Key Takeaways
• Data engineering quality is the ceiling on model quality. No algorithmic sophistication
compensates for unreliable pipelines.
• Training-serving skew is the #1 silent killer. Feature stores are an architectural control that
substantially reduces the risk of skew when implemented correctly.
• Data quality is operational, not periodic. Automated checks, deﬁned SLAs, dead-letter
queues, on-call rotations for data incidents, and postmortems when something breaks.
• Data contracts make the producer-consumer agreement explicit and versioned. They con-
vert quality SLAs into enforceable commitments.
• Point-in-time correctness prevents feature leakage. If information did not exist at the time
of prediction, it cannot be a training feature.
• Versioning is the technical foundation of reproducibility. Iceberg/Delta/Hudi time travel,
immutable S3 snapshots, and dataset versioning tools make “reproduce this training run” a
routine operation.
• Schema evolution requires governance. Schema registries and data contracts version both
structure and semantics; breaking changes require explicit consumer migration.
• Lineage is velocity, not just compliance. OpenLineage is the emerging standard. Implement
model lineage ﬁrst, feature lineage second, prediction lineage third.
• Governance is an engineering constraint, not a legal review. PII minimization, access con-
trols, retention policies, and right-to-delete workﬂows must be designed in, not retroﬁtted.
19.17 Apply It
1. Architecture decision. For each of the six data sources in the retail use case, justify the cho-
sen ingestion pattern using the decision table. For one source, argue the case for switching
patterns and identify the business condition that would make that switch worthwhile.
2. Data contract draft. Write a data contract for the POS transaction Kinesis stream. Specify:
schema, semantic deﬁnitions for amount and customer_id, completeness SLA, freshness SLA,
breaking-change protocol, and the on-call escalation procedure for contract violation.
3. Feature store decision. Using the ﬁve-dimensional framework (freshness model, consistency
guarantees, semantic operations, compute locality, operational surface), assess whether your
own organization needs a feature store today. If yes, recommend a speciﬁc platform and
justify it against the framework. If no, state the threshold that would change your answer.
4. Governance readiness review. Map your organization’s primary AI training dataset against
these questions: Where is PII? What is the retention policy? What is the deletion workﬂow if
a data subject exercises their right to erasure? Who has access and under what controls? The
gaps in your answers are your governance risk surface.
16

<!-- page 17 -->
5. AI prompt for executive review. “You are a senior data engineering executive reviewing a new
AI initiative for production readiness. Identify the data engineering risks that would prevent success
in production, the infrastructure investments that should precede modeling work, and the governance
and quality practices that must be in place before launch. Propose a 90-day data readiness plan with
speciﬁc milestones.”
19.18 What’s Next
With data ﬂowing reliably through well-governed pipelines, features deﬁned consistently, lineage
captured, quality enforced, and versioning in place, the next question is what to do with it. The next
chapter, Model Development: Training, Fine-Tuning, RAG, and Orchestrating Intelligence, cov-
ers how models are built in 2026: supervised ML training, ﬁne-tuning foundation models, retrieval-
augmented generation pipelines that depend directly on the data engineering practices established
in this chapter, and agentic systems that compose models, tools, and memory at runtime. The data
engineering foundation built here determines what model architectures are even possible. RAG
without reliable document pipelines, embedding refresh, and vector store governance is not pro-
duction AI, regardless of how impressive the model looks in a demo.
19.19 References
Amit Pahwa et al. 2021. “How Airbnb Achieved Metric Consistency at Scale.” In Airbnb Engineer-
ing & Data Science.
Anaconda Inc. 2022. State of Data Science 2022. Anaconda Inc.
Betsy Beyer, Chris Jones, Jennifer Petoff, and Niall Richard Murphy. 2016. Site Reliability Engineer-
ing: How Google Runs Production Systems. O’Reilly Media.
Breck, Eric, Shanqing Cai, Eric Nielsen, Michael Salib, and D. Sculley. 2017. “The ML Test Score:
A Rubric for ML Production Readiness and Technical Debt Reduction.” 2017 IEEE International
Conference on Big Data (Big Data), 1123–32.
Gopal, Prashant, and Patrick Clark. 2021. Zillow Loses $304 Million in Home-Flipping Business;
Cuts 25% of Workers. Https://www.bloomberg.com/news/articles/2021-11-02/zillow-loses-
304-million-in-home-ﬂipping-business.
Jeremy Hermann and Mike Del Balso. 2017. “Meet Michelangelo: Uber’s Machine Learning Plat-
form.” In Uber Engineering Blog.
Sculley, D., Gary Holt, Daniel Golovin, et al. 2015. “Hidden Technical Debt in Machine Learning
Systems.” Advances in Neural Information Processing Systems (NeurIPS) 28: 2503–11.
Simha, Nikhil, and Andrew Hoh. 2018. “Zipline: Airbnb’s Machine Learning Data Management
Platform.” Strata Data Conference NY (New York, NY).
Zinkevich, Martin. 2017. Rules of Machine Learning: Best Practices for ML Engineering.
Https://developers.google.com/machine-learning/guides/rules-of-ml; Google Develop-
17

<!-- page 18 -->
ers.
18