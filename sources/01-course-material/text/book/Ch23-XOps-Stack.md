# Ch23-XOps-Stack.pdf (extracted text, 30 pages)

<!-- page 1 -->
Chapter 23
The XOps Stack: Applying DevOps
Discipline to Data, Models, LLMs, and
Agents
23.1 Motivation
A ﬁnancial services ﬁrm has twelve data scientists who know how to build models. Their skill
isn’t the problem. What happens after a model is built is the issue. Each team has its own training
scripts. Each deployment is a custom process negotiated between data science and infrastructure,
with timelines that vary by weeks. When a model begins failing in production, nobody can deter-
mine which version is running, what training data it used, or who signed off on the deployment.
Reproducing a result takes days. Rolling back a degraded model takes hours of manual interven-
tion, assuming a rollback path exists at all.
This organization’s problem isn’t a lack of AI skill. It’s a lack of AI operations. The cost shows
up in production incidents, regulatory ﬁndings, and a deployment process so fragile that every
model update becomes a high-stakes, hand-crafted event. Adding more models does not make
things better. It makes the operational chaos proportionally larger and proportionally harder to
manage. A team that struggles to operate ﬁve models will not solve its problems by building ten.
XOps is the engineering discipline that transforms AI from an artisanal to an industrial practice.
It applies the core lessons of DevOps, automation, repeatability, observability, and continuous de-
livery to the distinct challenges of data pipelines, model training, foundation model systems, and
autonomous agents. Organizations that master XOps ship AI faster, fail less often, and recover
more quickly when they do. More importantly, they can scale the portfolio of AI systems without
the operational overhead that would scale in parallel.
23.2 Challenge
How do you operationalize AI development across data pipelines, model training, LLM systems,
and agents so that building, deploying, monitoring, and iterating on AI systems is automated,
repeatable, and governed rather than manual, ad hoc, and fragile?
1

<!-- page 2 -->
23.3 Objectives
By the end of this chapter, you will be able to:
1. Distinguish the four XOps disciplines and explain where each applies in the AI development
lifecycle
2. Design a DataOps practice that delivers reliable, tested, version-controlled data pipelines
3. Build an MLOps workﬂow covering training automation, model registry, and deployment
pipelines
4. Apply LLMOps practices to manage prompts, foundation model versions, and LLM-speciﬁc
evaluation
5. Implement AgentOps practices for observability, reliability, and governance of agent systems
6. Identify the maturity level of your organization’s XOps practice and the next steps to advance
it
23.4 Connection to Other Chapters
This chapter builds directly on the deployment infrastructure established in Chapter 24 and the
testing and evaluation practices from Chapter 22. The deployment chapter established the infras-
tructure patterns, including containerization, endpoint conﬁguration, scaling policies, and blue-
green deployment. The testing chapter established the evaluation criteria, accuracy thresholds,
bias checks, and performance benchmarks that XOps encodes as automated gates.
Where those chapters focused on what to deploy and how to test, this chapter focuses on the op-
erational discipline that makes deployment and testing repeatable, auditable, and governed. The
model registry workﬂows discussed here build on the deployment patterns; the evaluation gates
build on the test frameworks. Similarly, the data pipelines that XOps governs produce the training
and inference data discussed in Chapter 19.
The retail organization from previous chapters has crossed a new threshold: a churn model is in production,
an offer-generation LLM serves customers, and an escalation agent handles customer-service routing. The
question is no longer whether AI works in this organization; it is how to run it reliably, reproducibly, and at
scale without the operational burden outpacing the business value.
23.5 XOps: The Operational Foundation of Enterprise AI
DevOps transformed software delivery by demonstrating that the path from code to production
(build, test, integrate, deploy, monitor) could be automated, measured, and continuously im-
proved. Before DevOps, deploying software was a quarterly, high-risk event managed by release
committees and war rooms. After DevOps adoption, high-performing organizations deployed
hundreds of times per day, with lower failure rates and faster recovery when failures occurred
(Forsgren et al. 2018). The improvement came from operational discipline, not technology.
XOps applies the same logic to AI. The “X” represents a growing set of disciplines: DataOps,
MLOps, LLMOps, and AgentOps, each addressing a different layer of the AI stack.
2

<!-- page 3 -->
Table 23.1: XOps: The Operational Foundation of Enterprise AI — Discipline, Scope, Core Problem It
Solves.
Discipline Scope Core Problem It Solves
DataOps Data pipelines and data
quality
Unreliable, untested,
ungoverned data reaching
models
MLOps Model training, evaluation,
and deployment
Manual, inconsistent,
ungoverned model lifecycle
LLMOps Foundation model usage,
prompts, and evaluation
Unversioned prompts,
inconsistent behavior, cost
sprawl
AgentOps Agent systems, tool execution,
and oversight
Unobservable, ungoverned,
unpredictable agent behavior
The four disciplines form a stack with explicit dependencies rather than independent silos.
DataOps establishes the reliable data foundation that makes automated MLOps training trust-
worthy. MLOps governance patterns (evaluation gates, registry workﬂows, staged promotion)
translate directly into LLMOps practices for prompt management and foundation model gover-
nance. AgentOps extends LLMOps with the operational discipline required when systems not
only generate responses but also take actions with external consequences. A weakness at any
layer propagates upward: a model trained on unreliable data will fail regardless of how well the
MLOps pipeline is built around it.
The technical debt argument. The framing of XOps as good engineering practice understates the
urgency. The business case is that organizations that skip XOps accumulate AI technical debt that
compounds over time (Sculley et al. 2015). Untested pipelines fail silently, unmonitored models
degrade without feedback, and unversioned prompts drift without detection. The cost of remedia-
tion grows superlinearly with the number of systems and the time since discipline was established.
A company that builds ten models without MLOps doesn’t have a ten-model operational problem:
it has ten separate crises, each unfolding on a different timeline, each requiring custom forensics
and manual remediation when it surfaces.
The SRE connection. Site Reliability Engineering established that reliability is an engineering dis-
cipline, not an aspiration. Organizations should deﬁne explicit performance targets (Service Level
Objectives), budget for acceptable error rates, and eliminate operational toil through automation
(Betsy Beyer, Chris Jones, Jennifer Petoff, and Niall Richard Murphy 2016). XOps applies these
concepts directly to AI systems. Model performance SLOs set the maximum allowable degrada-
tion before retraining is initiated, while error budgets specify the acceptable level of deployment
risk within a given period. Engineers with SRE backgrounds ﬁnd XOps naturally understandable
because both rely on similar fundamental principles.
23.6 DataOps: Building the Data Foundation
The accuracy of each model relies heavily on the quality of the training and production data it
uses. Although this is a fundamental concept, it’s often overlooked in practice. Data engineering
for AI is different from data engineering for analytics. Analytics users are humans who can notice
3

<!-- page 4 -->
Figure 23.1: The four XOps disciplines form a dependency stack where reliability at each layer depends on
the discipline established in layers below.
4

<!-- page 5 -->
and investigate unusual ﬁgures on a dashboard. Conversely, model consumers are algorithms that
depend entirely on the learned distribution, even if the production data has subtly shifted or been
compromised at the source or during data processing. These failures remain hidden until they
cause costly issues.
DataOps incorporates software engineering practices—such as automation, testing, version con-
trol, and observability—into data pipelines. It doesn’t demand new infrastructure but calls for a
different approach to operational settings.
23.6.1 Pipeline Automation and Orchestration
The foundational principle of DataOps is that no data pipeline runs manually in production. A
pipeline that requires human initiation is just a script someone occasionally runs, not a production
pipeline. The operational standard is orchestration: pipelines execute on schedules or event trig-
gers, managed by an orchestrator that handles dependency resolution, automatic retry, and failure
alerting without human intervention.
Apache Airﬂow remains the dominant enterprise orchestrator for batch data and ML pipelines,
with broader production deployment than any competing platform. Amazon Managed Workﬂows
for Apache Airﬂow (MWAA) provides a fully managed Airﬂow deployment path within AWS,
eliminating the overhead of cluster provisioning and version management while maintaining full
DAG compatibility. Prefect and Dagster offer simpler authoring APIs and faster onboarding for
smaller teams, though their enterprise adoption footprint is substantially smaller.
The orchestrator’s job is to manage dependencies and handle failures. The operationally signiﬁ-
cant engineering decisions are what the orchestrator enforces: data contracts, quality gates, alerting
thresholds, not which platform hosts the DAGs. A well-conﬁgured Airﬂow pipeline that enforces
quality gates is more valuable than a sophisticated orchestration platform running pipelines with-
out them.
23.6.2 Data Quality Testing
dbt (data build tool) has become the de facto standard for testing SQL-based transformation
pipelines, adopted across enterprises of every scale. Its test framework validates schema expec-
tations, uniqueness constraints, null rates, and referential integrity on every pipeline execution.
These tests are deﬁned in YAML alongside the transformation code and run as part of the pipeline,
not as a separate QA step that can be skipped under time pressure.
For statistical quality assertions beyond what dbt handles natively- range checks, distribution com-
parisons, and custom business rules- Great Expectations provides a more expressive framework
for deﬁning and enforcing complex data quality contracts. AWS Glue Data Quality wraps compa-
rable capabilities natively within the AWS data ecosystem, enabling quality checks to be integrated
directly into Glue ETL jobs without additional infrastructure.
The key difference lies between quality testing conducted within the pipeline and that performed
afterward. Post hoc testing is helpful for monitoring purposes but does not stop faulty data from
spreading. Inline testing, which includes quality gates that halt the pipeline upon detecting viola-
tions, helps prevent issues such as null-rate spikes or schema changes from silently affecting the
training dataset.
5

<!-- page 6 -->
23.6.3 Data Contracts
Data contracts have emerged as the most operationally impactful DataOps practice for organi-
zations managing data pipelines at scale. A data contract is a formal, versioned agreement be-
tween a data producer, the team that owns and publishes a dataset, and the data consumers whose
pipelines or models depend on it. The contract speciﬁes schema, acceptable null rates, freshness
SLAs, and semantic guarantees, and it is enforced rather than aspirational.
The operational value of data contracts is failure localization. Without contracts, a schema change
in an upstream system propagates silently through the pipeline until a model produces wrong
predictions or a dashboard shows corrupted data. With contracts, the pipeline fails immediately
at the contract validation layer when the upstream change violates the agreed speciﬁcation, making
the root cause and the owning team visible immediately, before the corruption reaches downstream
consumers. For organizations managing dozens of interdependent data producers and consumers,
data contracts are the engineering primitive that makes the system governable.
23.6.4 Data Versioning and Lineage
Data versioning addresses a question that traditional data warehousing does not answer: what
exact dataset did this model train on? For reproducibility and auditability, every training run
must be linked to a speciﬁc, immutable snapshot of its training data.
DVC (Data Version Control) extends Git semantics to large data ﬁles and directories, storing the
actual data in S3 while tracking versions in the repository alongside model code. This lets git
checkout restore the exact training data and code from any historical commit. AWS Lake Formation
provides data lineage tracking at the catalog level, showing which S3 objects contributed to which
derived tables and, through integration with SageMaker, which training jobs consumed which
datasets.
For the retail system, this means that every churn model in the registry links to a speciﬁc DVC
commit hash that represents the transaction and customer data snapshot it was trained on. When
a model degrades in production and the team investigates, they can reconstruct the exact training
environment, code, hyperparameters, and data, without uncertainty about what changed between
versions.
23.6.5 Data Observability
Passing quality tests at pipeline execution time is necessary but not sufﬁcient. Production data
changes continuously between pipeline runs. Transaction volumes spike during promotions,
upstream systems emit unexpected formats after third-party updates, and reference tables are
modiﬁed without notiﬁcation. Data observability applies the same monitoring discipline to data
pipelines that application monitoring applies to production services.
Monte Carlo and Anomalo are examples of two leading commercial platforms for enterprise data
observability, providing automated monitoring and anomaly detection across dimensions such
as data freshness, volume, schema, distribution, and data quality. These platforms learn histori-
cal behavior and alert teams when data or pipelines deviate meaningfully from expected patterns.
Amazon DataZone, generally available since October 2023, addresses a complementary problem:
data cataloging, discovery, sharing, and governance across AWS and other data sources. Organiza-
tions that do not require a dedicated data-observability platform can implement basic monitoring
6

<!-- page 7 -->
Figure 23.2: DataOps pipelines enforce quality gates inline, halting data propagation when contracts are
violated rather than detecting problems after corruption reaches downstream systems.
using AWS CloudWatch metrics, alarms, and custom dashboards, although this requires more en-
gineering effort and lacks many of the automated data-proﬁling, lineage, anomaly-detection, and
root-cause-analysis capabilities of dedicated observability platforms.
The retail system’s DataOps conﬁguration illustrates the complete practice in operation. The
nightly batch sync from the CRM and transaction systems runs as an Amazon MWAA DAG with
automatic retry on transient failures and a Sev-2 alert after two consecutive failures. dbt tests
validate null rates, uniqueness constraints, and value-range expectations on every table before
data is promoted to the training-ready zone. CloudWatch alarms ﬁre if transaction volume is more
than two standard deviations below the seven-day moving average, ﬂagging potential upstream
problems before they affect training pipelines. All datasets are cataloged in Amazon DataZone
with owner metadata, SLA commitments, and quality-score history, providing the data science
team with authoritative provenance before selecting a dataset for training.
23.7 MLOps: Automating the Model Lifecycle
MLOps applies the automation discipline of DataOps to the model training, evaluation, and de-
ployment lifecycle. The target state is a pipeline in which a data change or a scheduled trigger
initiates training; the trained model passes automated evaluation gates; an approved model enters
a governed registry; and promotion to production follows a deﬁned workﬂow, with monitoring
active from day one. The path from data change to production model is automated, auditable, and
reversible.
The DORA metrics (Forsgren et al. 2018) translate directly to ML systems. Deployment frequency:
how often can a new model version safely be deployed to production? Lead time for changes: how
7

<!-- page 8 -->
long from a training trigger to a model running in production? Mean time to restore: how quickly
can a degraded model be rolled back? Change failure rate: what percentage of model deployments
cause production incidents? These four metrics make MLOps maturity legible to organizational
leadership without requiring AI expertise to interpret them, and they benchmark directly against
published industry data.
23.7.1 Training Automation
Training pipelines should be coded rather than built in notebooks. Notebooks serve as tools for
exploration, whereas production training should occur in parameterized pipelines where dataset
versions, hyperparameters, and evaluation thresholds are clearly speciﬁed inputs instead of em-
bedded values that someone edits before execution. SageMaker Pipelines offers a DAG-based
framework for orchestrating preprocessing, training, evaluation, and registry registration, creat-
ing a versioned, reproducible artifact. Each training run logs its conﬁguration and results via the
SageMaker MLﬂow App, capturing exact dataset versions, hyperparameters, and evaluation met-
rics as linked provenance records.
This discipline echoes the most durable principle in production ML practice: do not attempt heroic
results through clever modeling before you have achieved reliable results through disciplined en-
gineering (Zinkevich 2017). Automated training pipelines are the boring engineering investment
that makes everything downstream trustworthy.
23.7.2 Feature Stores and Training-Serving Consistency
Training-serving skew occurs when features used during model training differ from those pre-
sented to the model at inference time. It is a common and particularly difﬁcult production ML
failure mode because the inference system can continue operating normally while model accu-
racy silently deteriorates. For example, if a feature is computed differently during training and
inference, the model may have learned relationships from one feature distribution while making
predictions against another.
Feature stores help reduce this risk by providing a centralized source for storing and serving consis-
tently generated features. Amazon SageMaker Feature Store supports an ofﬂine store containing
historical feature values for model training and batch inference and an online store containing
current feature values for low-latency real-time inference. When both are enabled, feature values
can be ingested and synchronized across the stores. SageMaker Feature Processing can further
centralize the transformation logic for computing and ingesting those features. Training pipelines
can retrieve historical, point-in-time feature values from the ofﬂine store, while inference applica-
tions retrieve current values from the online store. This architecture substantially reduces training-
serving skew by avoiding independent implementations of feature engineering in training and
serving pipelines.
For the retail system use case, customer-level features such as recency of the last purchase, transac-
tion frequency over the past 90 days, average order value, and category preferences are calculated
once, stored in the Feature Store, and used consistently by both the churn model training pipeline
and the real-time scoring endpoint. When feature deﬁnitions are updated, both stores are synchro-
nized, and the model is automatically retrained to integrate these new deﬁnitions.
8

<!-- page 9 -->
23.7.3 Evaluation Gates and Champion-Challenger
No model proceeds to the registry without passing automated evaluation criteria. The gate is
deﬁned in code, not in a committee review where the bar can shift under schedule pressure: accu-
racy or AUC above a speciﬁed threshold, no regression against the current production model on
the holdout set, and passing bias and fairness checks. ML Test Score (Breck et al. 2017) provides
a systematic rubric for production readiness, covering training data coverage, model staleness,
serving infrastructure validation, and monitoring completeness. Teams that implement the full
rubric have explicit, versioned evidence that a model is production-ready rather than an informal
consensus that it seems ready enough.
Champion-challenger testing is a common pattern for safe model replacement, as covered in Chap-
ter 24. The challenger model runs in shadow mode, receiving the same requests as the production
champion but not serving its predictions externally before full promotion. This validates that im-
provements on the ofﬂine evaluation set translate to improvements on live trafﬁc patterns, which
they do not always do. A model that outperforms the champion on the holdout set can underper-
form on the speciﬁc subpopulations or temporal patterns that dominate live trafﬁc.
Responsible AI checks belong inside the evaluation gate as a named, automated step, not in a
separate governance review that happens after the technical evaluation is complete. A model that
meets accuracy thresholds but fails a fairness evaluation through SageMaker Clarify should not
be promoted. Integrating bias evaluation as a pipeline gate, rather than as a policy review, creates
accountability at the engineering level rather than the organizational level, where it can be deferred
or waived under pressure. For detailed coverage of bias testing frameworks and fairness metrics,
see Chapter 22.
23.7.4 Model Registry and Continuous Training
The model registry is the governance layer between experimentation and production. A trained
model that passes all evaluation gates enters the registry in a staging state, where it awaits human
review and explicit approval. Approved models are promoted to the production state; the previ-
ous production model is archived rather than deleted, preserving the ability to restore it to active
service within minutes if the promoted model fails under live load.
Continuous training automatically retrains models when data drift exceeds a threshold or perfor-
mance degrades beyond a deﬁned tolerance, keeping models aligned with evolving production
data distributions rather than requiring manual monitoring and ad hoc retraining decisions. Evi-
dently Monitor detects data, concept, and bias drift relative to the training-time baseline and emits
alerts when metrics exceed conﬁgured thresholds. These monitoring capabilities are covered in
depth in Chapter 27.
Netﬂix demonstrated, at scale, the operational value of combining continuous training with sys-
tematic A/B testing: models retrained on fresh behavioral data and evaluated against holdout met-
rics before full rollout substantially outperformed models trained once and deployed indeﬁnitely
(Gomez-Uribe and Hunt 2015). The recommendation system improvements that drove measurable
subscriber retention came from operational discipline, keeping models up to date and rigorously
evaluating every change before promotion, rather than from architectural breakthroughs.
9

<!-- page 10 -->
Figure 23.3: The MLOps pipeline automates the path from training trigger to production deployment
through explicit evaluation gates and staged promotion with preserved rollback paths.
23.7.5 Real-World Case Study: Uber Michelangelo
The canonical enterprise MLOps deployment at scale is Uber’s Michelangelo platform (Jeremy
Hermann and Mike Del Balso 2017), built to serve hundreds of production models across dozens
of internal teams. Michelangelo addresses precisely the problem that XOps is designed to solve:
each team builds models differently, there is no shared infrastructure, no way to manage the model
portfolio at enterprise scale, and no mechanism to ensure that a model trained last month is still
performing acceptably this month.
The platform built a shared feature store, a Cassandra cluster for online serving, and a Hive cluster
for ofﬂine training to ensure point-in-time correctness. Features were computed identically at both
training and serving time, eliminating training-serving skew. A distributed training infrastructure
ran XGBoost and TensorFlow jobs on shared compute, so any team could train models without
managing its own hardware. An automated evaluation framework blocked registry promotion
for models that failed to meet deﬁned performance gates; the quality bar became an engineering
constraint rather than a team convention. A champion-challenger promotion workﬂow managed
production transitions and preserved the rollback path at every step. An online serving infras-
tructure monitored deployed models against their training-time evaluation baselines and alerted
when performance diverged from the expected range.
Michelangelo’s lesson for enterprise AI is not that every organization should build a custom ML
platform. Managed cloud services have substantially reduced the infrastructure burden since 2017.
The lesson is that treating the model lifecycle as a ﬁrst-class engineering concern, with shared in-
frastructure, standardized workﬂows, and automated governance, is what separates organizations
that scale AI from those that accumulate technical debt proportional to their portfolio size.
10

<!-- page 11 -->
23.8 LLMOps: Operational Discipline for Foundation Model Systems
LLMOps extends MLOps in important ways that change how production AI systems must be de-
signed and operated. Understanding which MLOps principles carry over—and which new prac-
tices LLM-based systems require—is an important foundation for designing effective LLMOps.
Figure 23.4: LLMOps differs structurally from MLOps in artifact type, cost proﬁle, evaluation approach,
and version control, requiring distinct operational practices.
In MLOps, the primary artifacts are hyperparameters and model weights. This consists of a large
binary artifact trained on your data, evaluated against your metrics, versioned in your registry,
and deployed under your control. The training process is slow and expensive, but once trained,
a model’s behavior is deterministic for a given input. In LLMOps, you typically don’t train the
primary model; you consume a foundation model via an API or deploy an open-source model
you didn’t train. The artifacts you manage are prompts and conﬁgurations: small in bytes, large
in behavioral impact, and non-deterministic in output. Four structural differences deﬁne how
LLMOps must be designed.
The artifact is a prompt, not weights. Prompt engineering accounts for most of the behavioral
variation in foundation model applications. A poorly engineered or unversioned prompt is an
uncontrolled variable in a production system: it can be changed by anyone with repository access,
its effects are not auditable after the fact without version history, and behavioral regressions may
not surface until users complain. Every prompt in production must be version-controlled, peer-
reviewed, and deployed through a pipeline with the same rigor applied to application code.
Cost is a ﬁrst-class engineering constraint. Traditional ML training is expensive; inference is cheap
relative to training. LLM inference is expensive at volume, and the cost scales directly with usage
11

<!-- page 12 -->
in ways that can compound unexpectedly. A system processing 10,000 customer interactions per
day, with a 2,000-token system prompt and a 500-token average response, is consuming 25 million
tokens daily. At standard API pricing, the monthly cost is signiﬁcant before the ﬁrst dollar of
revenue, which makes its economic viability dependent on revenue. An LLM system deployed
without per-request cost tracking has no feedback on its economic viability. Cost management is
an engineering constraint from deployment day one, not a quarterly ﬁnance review. The economics
of LLM-based systems are covered comprehensively in Chapter 29.
Evaluation is structurally harder. Traditional ML evaluation computes scalar metrics against a
labeled test set: accuracy, AUC, precision, and recall. LLM outputs are natural language sequences
that resist reduction to scalar metrics. A response that is factually accurate but inappropriately
toned, or helpfully structured but subtly wrong on a key detail, cannot be correctly classiﬁed by
a threshold on a numeric metric. LLM evaluation requires techniques that assess output quality
across multiple dimensions simultaneously, which, in practice, means either human evaluation or
automated evaluation with another model as the evaluator.
Foundation model versions are not under your control. When you train a custom model, you own
the artifact and control when it changes. When you consume a foundation model API, the provider
updates it on their timeline. A model update that improves average benchmark performance can
degrade performance on the speciﬁc tasks your application relies on; without version pinning and
systematic evaluation, you may not detect the regression until users report degraded quality.
23.8.1 Prompt Management: Prompts Are Code
The operational framework for prompt management follows the software development lifecycle
applied to a different type of artifact. The prompt lifecycle for production systems is: author in a
development environment with access to evaluation tooling; commit to version control with a mes-
sage that describes what the prompt change is intended to accomplish; submit for peer review via
pull request; run the automated regression evaluation suite against the candidate prompt; deploy
to a staging environment and validate on representative trafﬁc; promote to production on explicit
approval; monitor in production with alerting on quality degradation; rollback by reverting to the
previous commit and redeploying.
Every prompt in production should carry four operational properties:
• A version tag linked to a speciﬁc git commit, enabling exact reproduction of any production
inference by combining the prompt version, the foundation model version, and the input
• A regression evaluation suite of at least 50 test cases covering expected outputs, behavioral
edge cases, refusal cases, and output format validation
• Production trace logging captures latency, token consumption, and output quality signals on
every inference
• A documented rollback procedure: redeploying the previous commit restores the previous
behavior without requiring any model changes
The retail offer generation system illustrates this model in operation. Each prompt component,
the system prompt governing offer scope and tone, the customer context injection template, and
the personalization instruction set live in a versioned repository. Every pull request triggers an
80-case regression evaluation: offers for high-value customers, offers for customers with recent
returns, edge cases where no qualifying offer exists, and adversarial inputs designed to elicit policy-
violating outputs. The evaluation score must not regress by more than two percentage points from
12

<!-- page 13 -->
Figure 23.5: Production prompts follow a software development lifecycle with version control, automated
evaluation, staged deployment, and documented rollback procedures.
the current production baseline for the pull request to be eligible for merge.
LangSmith and LangFuse are the leading commercial platforms for prompt observability, tracing,
and evaluation. For AWS-native deployments, Amazon Bedrock model invocation logging cap-
tures every API call, the exact prompt, response, latency, and token counts, in CloudWatch with-
out requiring application code instrumentation. This creates a complete production trace record
that satisﬁes both operational debugging and regulatory audit requirements.
23.8.2 Foundation Model Version Pinning
Every foundation model provider that supports it offers pinned version identiﬁers: a model string
that references a speciﬁc snapshot rather than the rolling latest. Version pinning is the only reliable
defense against silent behavioral drift when providers update their models.
The operational workﬂow for a model version update parallels the champion-challenger pattern
from MLOps. Run the full prompt regression suite against the new model version while the pre-
vious pinned version remains in production. If the new version matches or exceeds performance
on all critical metrics, plan the cutover for a low-trafﬁc period and update the version pin in the
prompt registry. If the new version regresses on any critical metric, delay the migration, document
the speciﬁc failure cases, and determine whether prompt adjustments can compensate or whether
the migration requires waiting for a subsequent provider release.
Model version, prompt version, input hash, output, latency, and token counts should all be cap-
tured in the production trace for every inference. In regulated industries, this record is a com-
13

<!-- page 14 -->
pliance requirement; in all industries, it is the forensic record that makes post-incident analysis
tractable.
23.8.3 LLM Gateway Pattern
Figure 23.6: The LLM gateway pattern centralizes model routing, cost allocation, and logging across all
foundation model consumers in the organization.
At scale, LLM infrastructure beneﬁts from a centralized gateway: a proxy layer that sits between
application services and foundation model provider APIs. The gateway provides:
• Uniﬁed API surface: a single endpoint that routes to Anthropic, OpenAI, Amazon Bedrock,
or Google Vertex AI based on task type or routing policy, enabling model substitution without
changes to application code.
• Rate limiting and cost allocation: per-team or per-use-case token budgets enforced cen-
trally rather than by individual application teams, with budget exhaustion triggering grace-
ful degradation rather than uncontrolled overage.
• Centralized logging: every inference logged at the gateway layer without requiring
application-level instrumentation, providing a complete audit record even for applications
that were not built with observability in mind.
• Model routing by task complexity: simple, high-volume tasks routed to cheaper, faster mod-
els; complex multi-step reasoning routed to higher-capability models; routing rules updated
without redeploying application code.
LiteLLM is an example of an open-source gateway implementation that provides a uniﬁed API
14

<!-- page 15 -->
compatible with many major foundation model providers. Portkey and Helicone offer SaaS alter-
natives with additional observability dashboards. For AWS-native deployments, Amazon Bedrock
provides multi-model access without a third-party gateway, though LiteLLM is common even in
AWS environments for organizations that need cloud portability.
23.8.4 LLM-Speciﬁc Evaluation
Automated evaluation for LLM systems combines metric-based approaches with model-based
evaluation to address the structural limitations of scalar metrics for language outputs. The evalu-
ation frameworks introduced in Chapter 22 apply here with LLM-speciﬁc extensions.
LLM-as-judge evaluation uses a separate, high-capability foundation model to score production
outputs against precisely deﬁned criteria: factual accuracy relative to the retrieved context, format
compliance with the speciﬁed output structure, relevance to the actual question asked, and policy
compliance with deﬁned behavioral constraints. LLM-as-judge scores correlate well with human
judgment when the evaluation criteria are speciﬁc, the judge model is sufﬁciently capable, and
they scale to volumes where human eval
Retrieval-Augmented Generation Assessment (RAGAS) is an open-source evaluation frame-
work for systematically measuring the quality of RAG, LLM, and agentic applications (Es et al.
2024). It provides automated, often LLM-as-a-judge metrics that evaluate different components
of an AI system—including retrieval quality, response relevance, factual grounding, and task
performance—allowing teams to identify whether failures originate in retrieval, generation, or
other parts of the application.
For RAG-based systems, RAGAS provides a suite of automated evaluation metrics designed to
isolate failures in both retrieval and generation. Four foundational metrics provide a useful starting
point:
• Faithfulness: Are the claims in the generated response supported by the retrieved context?
Unsupported claims indicate that the generation step has introduced information that is not
grounded in the retrieved evidence.
• Response Relevancy (Answer Relevancy): Does the generated response directly and appro-
priately address the user’s question? This evaluates relevance rather than factual correctness.
• Context Precision: Does the retrieval system rank relevant chunks ahead of irrelevant ones?
Low precision indicates that irrelevant or less-useful context is being retrieved or ranked too
highly, potentially consuming context-window capacity and distracting the model.
• Context Recall: Did retrieval provide the information necessary to construct the expected
answer? Low recall indicates that relevant information needed to answer the question was
omitted from the retrieved context.
Together, these metrics help distinguish retrieval failures from generation failures: Context Preci-
sion and Context Recall evaluate the retrieval stage, while Faithfulness and Response Relevancy
evaluate the generated response.
These four metrics run automatically on a test set on every pipeline change, providing visibility
into which component of the RAG system, retrieval or generation, is responsible for any observed
quality degradation.
Amazon Bedrock Model Evaluation provides managed evaluation pipelines for foundation model
applications running on Bedrock, supporting automated metrics and human evaluation workﬂows
15

<!-- page 16 -->
Figure 23.7: RAGAS metrics evaluate both retrieval and generation components of RAG systems, diagnos-
ing whether quality issues originate in chunk selection or response synthesis.
16

<!-- page 17 -->
without custom evaluation infrastructure. Amazon Bedrock Guardrails provides conﬁgurable
safety controls, content ﬁltering, PII detection, topic denial, and grounding checks that enforce be-
havioral boundaries at inference time rather than relying solely on prompt engineering. Guardrails
apply regardless of which model version is deployed, providing a stable behavioral constraint
layer across model updates.
23.8.5 Cost Management
Token consumption is the primary cost driver for LLM systems in production, and it scales with us-
age in ways that can compound faster than engineering teams anticipate. Three practices establish
cost control from the ﬁrst production deployment.
Per-request cost tracking instruments every inference with a cost estimate computed from the
model’s token pricing and the actual input and output token counts captured in the production
trace. The operational metric is cost per successful output, not cost per request. A system with a
high refusal rate or a high retry rate has a worse cost-per-output proﬁle than a system with lower
latency and high task completion, even if the per-request token costs are identical. Tracking the
cost per successful output makes the system’s true economics visible.
Prompt compression reduces the token footprint of system prompts through iterative reﬁnement,
preserving semantic content while eliminating verbosity. For high-volume applications, the dif-
ference between a 2,400-token system prompt and a 1,400-token equivalent is a 42% cost reduction
per inference, a material improvement at scale that requires no infrastructure or model changes.
Semantic caching identiﬁes semantically similar queries and serves cached responses rather than
issuing redundant inference calls. For applications where users repeatedly ask variations of the
same questions, customer service, internal knowledge base queries, and documentation assistants,
caching rates of 30–40% are achievable with well-conﬁgured similarity thresholds, with propor-
tional cost reduction.
23.9 AgentOps: Governance for Systems That Act
Agent systems introduce an operational dimension that neither MLOps nor LLMOps addresses:
production systems that take sequences of actions with external effects. A model predicts; an agent
acts. This distinction matters operationally because the cost of a wrong action can be immediate, ir-
reversible, and visible to customers, counterparties, or regulators before anyone in the engineering
organization is aware of it.
An agent that sends an incorrect email, modiﬁes the wrong database record, or initiates an unautho-
rized transaction has caused a real-world consequence. Rolling back a model deployment restores
previous behavior; rolling back an agent’s actions may require contacting customers, reversing
transactions, or managing a regulatory disclosure. The operational discipline required for agent
systems scales with the consequences of agent actions.
23.9.1 Full Action Tracing
The minimum viable observability requirement for any production agent is a complete, structured
trace for every run. This is the basic condition for operating an autonomous system responsibly.
The trace must capture: - Task identiﬁer and session identiﬁer that enable correlation across multi-
agent systems and conversational turns. - Each reasoning step has a timestamp, capturing the
17

<!-- page 18 -->
agent’s internal state at each decision point. - Each tool call includes the tool name, input argu-
ments, output or error response, and duration. - Human-in-the-loop events: what triggered the
gate, who responded, when, what decision they made, and what context they were shown. - The
ﬁnal outcome: success or failure status, total steps taken, total token consumption, and total cost.
Without this trace, diagnosing agent failures is impossible. Post-incident analysis requires knowing
what the agent attempted, in what sequence, and where it diverged from expected behavior, not
just that it failed. The trace is also the audit record. In regulated industries, a complete action log
for every autonomous decision is a compliance requirement, not just a best practice.
The CNCF’s OpenTelemetry project published Semantic Conventions for GenAI in 2024 (https:
//opentelemetry.io/docs/specs/semconv/gen-ai/), deﬁning standard attribute names for LLM
spans, tool calls, and agent reasoning traces. This standard enables observability instrumentation
that is agnostic to the backend platform; instrumented once, it exports to CloudWatch, Grafana,
Jaeger, or any OpenTelemetry-compatible receiver without re-instrumentation. It is the founda-
tion for vendor-neutral agent observability in production environments that may evolve across
providers and platforms.
Amazon Bedrock AgentCore Observability emits OpenTelemetry traces to CloudWatch that cap-
ture the full ReAct trace for every agent invocation. For multi-service, multi-step workﬂows span-
ning multiple AWS services, AWS X-Ray provides distributed tracing across the complete call
graph, enabling correlation of agent actions with downstream service calls, latency proﬁles, and
failure points.
23.9.2 AgentOps Evaluation
Agents are structurally harder to evaluate than models because they take paths rather than produc-
ing ﬁxed outputs for ﬁxed inputs. Evaluation must assess path quality as well as terminal output
quality, because the path taken affects cost, latency, reliability, and risk.
Task completion rate measures whether the agent successfully completed the assigned task end-to-
end. This is the primary outcome metric, but it is insufﬁcient on its own. An agent that completes
tasks through excessive tool calls, unnecessary escalations, or risky intermediate actions is not
performing well, even if its completion rate is high.
Step efﬁciency measures the number of tool calls per successful task completion. More steps mean
higher cost, greater latency, and more opportunities for failure. A benchmark of representative
tasks establishes baseline step counts; regression testing ﬂags changes in code or prompts that
increase step counts without corresponding quality improvements. The optimization target is the
minimum number of steps for successful completion, not maximum thoroughness.
Tool call accuracy measures whether the agent selected the correct tool with valid arguments on
the ﬁrst attempt for each required action. Tool call failures, wrong tool selected, invalid argu-
ment format, authorization error, consume steps, and incur costs without progressing toward task
completion. High ﬁrst-attempt accuracy indicates that the agent’s planning capability and tool
understanding are well calibrated to the task distribution it handles.
Safety evaluation assesses whether the agent correctly identiﬁed and escalated requests that ex-
ceeded its authorization scope or conﬂicted with deﬁned operational policies. An agent that pro-
cesses unauthorized requests when it should escalate is a production risk regardless of its task com-
pletion rate on authorized requests. Safety evaluation requires test scenarios that explicitly probe
18

<!-- page 19 -->
Figure 23.8: Complete action tracing captures every reasoning step, tool call, and human decision point,
providing the audit trail required for agent governance and post-incident analysis.19

<!-- page 20 -->
boundary conditions, requests that are slightly outside scope, requests that resemble authorized
actions but require elevated privileges, and adversarial inputs designed to elicit unauthorized be-
havior.
Regression testing for agent systems requires a representative set of task scenarios, typically 50 to
100 scenarios covering normal cases, edge cases, authorization boundaries, and adversarial inputs,
run against every agent code or prompt change before promotion to production.
Figure 23.9: AgentOps reliability patterns deﬁne failure boundaries enforced by the execution layer, ensuring
graceful degradation before resources are exhausted or unauthorized actions are taken.
23.9.3 Reliability Patterns
Agent reliability engineering deﬁnes failure boundaries before deployment, not in response to pro-
duction incidents.
Timeout and step limits enforce maximum wall-clock time and step counts per run, which the
execution engine treats as hard constraints rather than soft guidelines. An agent that reaches its
step limit without completing a task should return a structured failure status with its partial trace
rather than continuing to consume resources. AWS Step Functions’ wait-for-callback pattern en-
ables long-running workﬂows to pause at human approval gates and resume on callback without
consuming compute between steps.
Cost limits deﬁne the maximum token budget per run and are enforced at the execution layer.
When an agent’s consumption approaches the budget ceiling, it should return a partial result and
20

<!-- page 21 -->
cost summary rather than continuing past the authorized expenditure. Deﬁning cost limits be-
fore deployment is the operational practice that prevents runaway agent costs from compounding
before any human is aware of the problem.
Circuit breakers prevent agents from repeatedly calling tools that are consistently failing. A tool
that has failed three consecutive times is unlikely to succeed on the fourth attempt due to transient
conditions; it is failing for a structural reason that requires human diagnosis. Escalating immedi-
ately, rather than consuming the retry budget on non-recoverable failures, is the correct operational
behavior.
23.9.4 Human-in-the-Loop Operations
Human oversight gates must be designed into the agent architecture before the ﬁrst production
deployment, not added as afterthoughts when a consequential failure occurs. Every HITL gate
requires three design decisions made in advance: what triggers the gate, who receives the approval
request, and through what channel, and what happens if no human responds within the deﬁned
SLA.
The retail customer service escalation agent deﬁnes its gates precisely: refund requests over $50
require supervisor approval within 4 hours; account modiﬁcations require supervisor approval
within 2 hours; any request involving an account ﬂagged for potential fraud requires immediate
human review before any action is initiated. Approval requests route through Amazon SQS to a
Lambda function that notiﬁes the appropriate supervisor queue; if no response is received within
the SLA, the agent automatically escalates to the senior supervisor queue and generates a Sev-2
alert. Every HITL event is logged with the complete context presented to the approver, the decision
made, and the timestamp: an auditable record of every human decision in the agent’s operational
history.
These governance patterns align directly with the broader organizational accountability frame-
works discussed in Chapter 25, where human-in-the-loop operations are embedded within enter-
prise AI governance policies.
23.10 Use Case: Retail Customer Acquisition and Retention
The retail organization has now deployed three AI systems: the churn prediction model, the per-
sonalized offer-generation LLM, and the customer-service escalation agent. Each system has been
built and tested according to the principles in previous chapters. Now the question is operational:
how do these systems run reliably, reproducibly, and governably in production?
23.10.1 DataOps Implementation
The data foundation for all three systems is governed by a uniﬁed DataOps practice. The nightly
batch pipeline runs as an Amazon MWAA DAG orchestrating data extraction from the CRM, trans-
action system, and customer service logs. Each data source has an explicit data contract:
• CRM data contract: customer_id uniqueness enforced; email null rate ≤ 2%; loyalty_tier
values constrained to {‘Bronze’, ‘Silver’, ‘Gold’, ‘Platinum’}; freshness SLA of 24 hours
• Transaction data contract: transaction_id uniqueness; amount > 0; category values from con-
trolled vocabulary; daily record count within 3 standard deviations of 90-day average
21

<!-- page 22 -->
• Service log contract: case_id uniqueness; resolution_status from controlled vocabulary;
timestamp monotonically increasing within each customer session
Contract violations halt the pipeline and alert the responsible data engineering team. When the
product catalog system team changed a category enumeration without notice last quarter, the con-
tract validation caught it within minutes, rather than allowing corrupted category data to propa-
gate to the recommendation features.
All training-ready datasets are versioned with DVC, and their version hashes are stored alongside
model artifacts in the SageMaker Model Registry. When investigating why the churn model’s
performance degraded in early March, the team could compare the exact data versions of the high-
performing January model and the degraded March model, identifying feature drift in the loyalty
program data coinciding with the launch of a marketing campaign.
23.10.2 MLOps Implementation
The churn model operates under a complete MLOps pipeline:
Training automation: A SageMaker Pipeline triggers weekly on schedule and on demand when
Evidnetly Monitor detects data drift exceeding the threshold (PSI > 0.15 on any core feature). The
pipeline executes preprocessing, feature engineering, XGBoost training, and evaluation as a single
versioned artifact.
Evaluation gates: The pipeline enforces four gates before any model can enter the registry: 1. AUC-
ROC ≥ 0.78 on the holdout test set 2. No regression versus the current production champion (AUC
difference ≤ 0.01) 3. Fairness evaluation via SageMaker Clarify: demographic parity ratio ≥ 0.8
across customer tenure segments 4. Latency evaluation: p99 inference latency ≤ 50ms on the test
batch
Registry workﬂow: Models passing all gates enter the registry in the PendingApproval state. The
model owner reviews the evaluation artifacts, including the Clarify fairness report and the A/B
comparison dashboard, and either approves for staging promotion or requests changes. Approved
models deploy to a shadow endpoint serving 10% of trafﬁc for 72 hours before full promotion.
Continuous monitoring: Evidently Monitor tracks prediction distribution, feature drift, and label
drift (using delayed ground truth labels from actual churn events). A drift alert above threshold
triggers automatic retraining initiation.
23.10.3 LLMOps Implementation
The offer generation system applies LLMOps discipline to every component:
Prompt versioning: The system prompt, customer context template, and personalization instruc-
tions each have their own ﬁles in the prompt repository, versioned alongside application code.
The current production versions are: - system_prompt_v2.3.md: Core offer generation instruc-
tions - context_template_v1.7.md: Customer data injection format - personalization_v3.1.md:
Segment-speciﬁc tone and offer constraints
Evaluation pipeline: Every prompt PR triggers an 80-case automated evaluation: - 30 cases: High-
value customers expecting premium offers - 20 cases: Recent return customers requiring careful
tone - 15 cases: Edge cases (no qualifying offers available, conﬂicting preferences) - 15 cases: Ad-
versarial inputs (attempts to generate unauthorized discounts, competitor mentions)
22

<!-- page 23 -->
The evaluation uses Claude 3.5 Sonnet as the judge model, scoring each output on relevance (0-
5), policy compliance (pass/fail), tone appropriateness (0-5), and format correctness (pass/fail).
Regression beyond 2 percentage points on the composite score blocks the PR.
Model version management: The system pins to claude-3-sonnet-20240229 with quarterly eval-
uation of newer versions. The Q1 2025 evaluation found that claude-3-5-sonnet-20241022 im-
proved relevance scores by 8% but increased token consumption by 15%; the team chose to upgrade
and offset costs through prompt compression.
Cost governance: Per-offer cost tracks at $0.017 against the $0.02 budget ceiling. CloudWatch
dashboards show daily cost trends segmented by customer tier, with alarms at $0.018 (warning)
and $0.022 (critical), triggering an automatic rollback to the previous prompt version.
23.10.4 AgentOps Implementation
The escalation agent operates under the strictest operational governance:
Action tracing: Every agent invocation produces a structured trace logged to CloudWatch with: -
Session and task identiﬁers - Full reasoning chain (ReAct format) - Each tool call has inputs, out-
puts, and latency - Human escalation events with approver identity and decision - Final outcome
and total resource consumption
Evaluation suite: The 75-case regression suite covers: - 25 routine escalations (should route cor-
rectly without human intervention) - 20 refund requests near the $50 threshold (should correctly
classify above/below) - 15 fraud-ﬂagged accounts (should always escalate, never auto-process) -
15 adversarial cases (attempts to bypass authorization, social engineering patterns)
Reliability constraints: - Maximum 8 tool calls per task (95th percentile of successful completions
is 5) - 60-second timeout with graceful degradation - $0.10 maximum cost per escalation - Circuit
breaker: 3 consecutive failures to any tool trigger immediate human escalation
HITL operations: Refunds > $50 queue to supervisor via SQS with 4-hour SLA. No response trig-
gers escalation to a senior supervisor and a Sev-2 alert. All decisions are logged with approver,
timestamp, and decision rationale for audit compliance.
23.10.5 Integrated Operations Dashboard
The uniﬁed XOps dashboard for the retail AI portfolio tracks:
Table 23.2: Integrated Operations Dashboard — System, Pipeline Health, Model/Prompt Version, Quality
Metric, Cost Metric.
System Pipeline Health Model/Prompt Version Quality Metric Cost Metric
Churn
Model
Weekly training v14 (2024-12-15) AUC: 0.81 $0.002/prediction
Offer
Genera-
tor
Prompt
v2.3/1.7/3.1
Claude 3.5 Sonnet Relevance: 4.2/5 $0.017/offer
Escalation
Agent
Agent v2.1 Bedrock Claude Completion: 94% $0.07/escalation
23

<!-- page 24 -->
This consolidated view enables the AI platform team to identify which systems need attention and
the operations team to understand the aggregate cost and reliability proﬁle of the AI portfolio.
23.11 Building XOps Capability
The four XOps disciplines have a natural adoption sequence driven by their dependency struc-
ture. Building them in order minimizes the operational debt that accumulates between disciplines;
building them out of order means remediating earlier gaps while trying to establish later ones.
Figure 23.10: The XOps disciplines have a natural adoption sequence driven by dependencies; building out
of order creates operational debt that compounds as the portfolio scales.
Start with DataOps. Data quality problems corrupt everything downstream. A model trained
on unreliable data will fail in production regardless of how sophisticated the MLOps pipeline
surrounding it is. Establishing automated pipelines, quality gates, and data contracts before ex-
panding the model portfolio is the most efﬁcient path to a reliable AI system portfolio, not merely
a cautious one. Remediating bad data after models have been trained, deployed, and integrated
into business processes is an order of magnitude more expensive than establishing the quality gates
before the ﬁrst training run.
Add MLOps. Once data pipelines are reliable and tested, automate the training and deployment
lifecycle. Deﬁne evaluation gates before training the ﬁrst model that will go to production. Estab-
lish the model registry workﬂow before deploying the ﬁrst model. Retroﬁtting MLOps onto an
existing portfolio of ungoverned models, each with its own custom deployment process, no con-
sistent evaluation criteria, and no rollback path, is a common and avoidable enterprise AI expense.
Layer in LLMOps. As foundation model applications reach production, apply prompt versioning
and cost tracking immediately, not after the ﬁrst cost overrun or behavioral regression incident.
The operational cost of running LLM applications without observability compounds quickly. A
24

<!-- page 25 -->
prompt that was working acceptably six weeks ago may have been updated by someone who
didn’t have access to the evaluation suite; without version history, there is no path back.
Implement AgentOps. No agent should reach production without action tracing and HITL gates
fully in place. The failure mode of a poorly governed model is silent degradation that surfaces
gradually in performance metrics. The failure mode of a poorly governed agent is a visible, con-
sequential action taken on behalf of your organization, potentially before any monitoring system
has generated an alert.
Common adoption failures. Tooling without process is the most frequent: an organization ac-
quires an MLOps platform and deﬁnes none of the evaluation gates, registry workﬂows, or de-
ployment policies the platform is designed to enforce. Process without automation is the second:
documented workﬂows executed manually don’t scale or reproduce. XOps, as a separate team, is
the third: an “MLOps platform team” that is organizationally disconnected from the data science
and engineering teams it serves and cannot iterate at the pace of development.
23.11.1 XOps Maturity Model
Assessing where your organization sits on the XOps maturity curve provides the foundation for
prioritizing what to build next. Most enterprise AI organizations operate at Level 1 to Level 2
across the four disciplines, with uneven coverage between disciplines: a team that has mature
MLOps practices for traditional ML may have LLMOps at Level 0 because its foundation model
applications are new. The diagnostic question is not “what is our overall XOps level?” but “where
is the weakest discipline, and what is its current level?”
Table 23.3: XOps Maturity Model — Level, Name, Characteristics.
Level Name Characteristics
0 Manual Ad-hoc scripts, no automation,
no versioning; deployments
by hand
1 Repeatable Pipelines exist but are
manually triggered; some
versioning; basic monitoring
2 Automated Pipelines trigger
automatically; CI/CD for
models and prompts;
systematic monitoring
3 Governed Full audit trails; policy
enforcement; automated
retraining on drift signals
4 Optimizing Platform self-monitors and
proposes improvements;
feedback loops close
automatically
Measuring XOps maturity uses the same metrics that DevOps uses (Forsgren et al. 2018):
25

<!-- page 26 -->
Figure 23.11: Assessing maturity across all four XOps disciplines identiﬁes the weakest layer and guides
prioritization of operational investments.
26

<!-- page 27 -->
• Deployment frequency: how often can you safely release model updates, prompt changes,
or agent revisions?
• Lead time: how long from a model being trained or a prompt being authored to it running
in production?
• Mean time to restore (MTTR): how long to recover from a production AI failure, a degraded
model, a prompt regression, an agent incident?
• Change failure rate: what percentage of model, prompt, or agent deployments cause pro-
duction incidents requiring remediation?
These metrics are interpretable without AI expertise and directly comparable to industry bench-
marks. A team that deploys models monthly and takes hours to roll back failures is operating
differently from a team that deploys weekly and restores in minutes; the difference is measurable,
trackable over time, and improvable with targeted investment in speciﬁc XOps disciplines.
23.12 AWS Reference XOps Architecture
The consolidated AWS XOps stack maps each discipline to speciﬁc services, organized by the de-
pendency layer each discipline occupies:
23.13 Key Takeaways
• XOps transforms AI from artisanal to industrial; without it, scaling the model portfolio pro-
duces compounding operational debt rather than compounding capability.
• DataOps, MLOps, LLMOps, and AgentOps are a stack, not a menu: each layer depends
on the discipline established by the layer below it, and a weakness at any layer propagates
upward.
• Start with DataOps: data quality problems corrupt everything downstream and represent
the highest-return ﬁrst XOps investment.
• Prompts are code: they require version control, regression testing, and deployment pipelines
with the same rigor as application software.
• LLMOps introduces three structural challenges that MLOps does not address: non-
deterministic evaluation, cost as a ﬁrst-class engineering constraint, and foundation model
versions outside your control.
• No agent should reach production without full action tracing and HITL gates in place; the
failure mode of a poorly governed agent is a consequential action taken on behalf of your
organization, not a silent degradation of metrics.
• XOps maturity can be measured using the same DORA metrics as DevOps: deployment
frequency, lead time, mean time to restore, and change failure rate.
23.14 Apply It
1. XOps Maturity Assessment. Assess the retail system against the Level 0–4 maturity model
for each of the four disciplines. Where does it sit today for DataOps, MLOps, LLMOps, and
AgentOps? Identify the lowest-maturity discipline and deﬁne the three highest-priority in-
vestments to advance it to Level 2.
2. DataOps Pipeline Design. Deﬁne the automated DataOps workﬂow for the retail batch data
27

<!-- page 28 -->
Figure 23.12: Layered AWS operating model for AI systems, showing how DataOps produces governed
data, MLOps manages model development and deployment, LLMOps governs foundation model usage, and
AgentOps monitors agent behavior and human-in-the-loop workﬂows
28

<!-- page 29 -->
pipeline, including the scheduling trigger, at least three speciﬁc quality gates with deﬁned
thresholds, failure handling and alerting logic, and the data contract for the transaction feed.
Specify which AWS services handle each function.
3. MLOps Evaluation Gates. Deﬁne the evaluation gates for the retail churn model pipeline:
the speciﬁc thresholds required for registry promotion (accuracy/AUC, regression vs. cham-
pion, fairness check via SageMaker Clarify), the champion-challenger trafﬁc allocation strat-
egy, and the rollback trigger criteria.
4. LLMOps Setup. Deﬁne the LLMOps conﬁguration for the retail offer generation system:
prompt repository structure, ﬁve representative test cases for the regression evaluation suite,
the cost-per-offer threshold and monitoring approach, the model pinning strategy, and the
mechanism for detecting a prompt regression before full production trafﬁc exposure.
5. AgentOps Design. Deﬁne the AgentOps conﬁguration for the retail customer service escala-
tion agent: action-tracing requirements; ﬁve representative evaluation scenarios (including
at least one safety boundary test); per-run cost and step limits; HITL gate deﬁnitions with trig-
ger conditions and SLAs; and CloudWatch anomaly-detection thresholds for agent behavior
monitoring.
6. AI Prompt. “You are an XOps architect reviewing the following LLM application setup for a retail of-
fer generation system. The system uses an unversioned system prompt updated by direct conﬁguration
ﬁle edit, with no automated evaluation, cost monitoring only through monthly cloud billing reports,
and no production trace logging. Identify the three highest-priority operational risks this creates and
recommend speciﬁc practices and AWS services to address each: [describe your current setup].”
23.15 What’s Next
XOps deﬁnes the operational practices for AI systems, the engineering discipline that makes AI
reproducible, governable, and continuously improvable rather than a one-time achievement that
silently degrades. The next chapter examines the infrastructure that automates these practices
at delivery speed: continuous integration and delivery pipelines for AI. CI/CD for AI systems
extends traditional pipelines in signiﬁcant ways: data changes are ﬁrst-class triggers alongside
code commits; model artifacts and prompt registries are deployment targets alongside application
binaries; and the non-deterministic nature of AI outputs creates testing challenges not shared by
deterministic software. The operational discipline established in this chapter is the foundation that
makes continuous delivery for AI tractable.
23.16 References
Betsy Beyer, Chris Jones, Jennifer Petoff, and Niall Richard Murphy. 2016. Site Reliability Engineer-
ing: How Google Runs Production Systems. O’Reilly Media.
Breck, Eric, Shanqing Cai, Eric Nielsen, Michael Salib, and D. Sculley. 2017. “The ML Test Score:
A Rubric for ML Production Readiness and Technical Debt Reduction.” 2017 IEEE International
Conference on Big Data (Big Data), 1123–32.
29

<!-- page 30 -->
Es, Shahul, Jithin James, Luis Espinosa Anke, and Steven Schockaert. 2024. “RAGAs: Automated
Evaluation of Retrieval Augmented Generation.” In Proceedings of the 18th Conference of the
European Chapter of the Association for Computational Linguistics: System Demonstrations, edited
by Nikolaos Aletras and Orphee De Clercq. Association for Computational Linguistics. https:
//doi.org/10.18653/v1/2024.eacl-demo.16.
Forsgren, Nicole, Jez Humble, and Gene Kim. 2018. Accelerate: The Science of Lean Software and
DevOps: Building and Scaling High Performing Technology Organizations. IT Revolution Press.
Gomez-Uribe, Carlos A., and Neil Hunt. 2015. “The Netﬂix Recommender System: Algorithms,
Business Value, and Innovation.” ACM Transactions on Management Information Systems 6 (4):
1–19. https://doi.org/10.1145/2843948.
Jeremy Hermann and Mike Del Balso. 2017. “Meet Michelangelo: Uber’s Machine Learning Plat-
form.” In Uber Engineering Blog.
Sculley, D., Gary Holt, Daniel Golovin, et al. 2015. “Hidden Technical Debt in Machine Learning
Systems.” Advances in Neural Information Processing Systems (NeurIPS) 28: 2503–11.
Zinkevich, Martin. 2017. Rules of Machine Learning: Best Practices for ML Engineering.
Https://developers.google.com/machine-learning/guides/rules-of-ml; Google Develop-
ers.
30