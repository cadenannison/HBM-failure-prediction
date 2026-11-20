# Ch17-AI-Systems-Development-Lifecycle.pdf (extracted text, 34 pages)

<!-- page 1 -->
Chapter 17
AI Systems Development Lifecycle: The
Framework for Building Production
Systems
17.1 Motivation
A software team that has never built AI before gets handed its ﬁrst AI project. They do what
they know: write a spec, assign tickets, sprint toward a demo. The demo works, stakeholders are
impressed, and the project gets the green light for production.
Then they deploy it. The model starts degrading in week three. The real transaction data has
different distributions than the sample they trained on, more missing values, different category
encodings, and seasonal patterns nobody accounted for. There is no monitoring, so nobody no-
tices until a business analyst ﬂags that the churn predictions look wrong. By the time the team
investigates, retunes, and revalidates, three months have passed, the VP of Marketing has moved
on, and the project gets quietly reclassiﬁed as a “learning initiative” and shelved.
This is a common and well-documented outcome for enterprise AI projects that enter development
without a purpose-built process (Davenport and Ronanki 2018). The team had the technology and
the talent. What they did not have was a process suited to the problem, so they used the software
development process they already had.
Now consider a different team. Before writing a line of code, they spend two weeks with business
stakeholders deﬁning what “churn prediction” means in terms of business decisions rather than
model accuracy. They discover that the marketing team can only act on predictions for customers
who purchased in the last 90 days, which immediately constrains the problem scope and the re-
quired data freshness. They assess their data and ﬁnd signiﬁcant gaps in mobile behavioral signals.
Rather than pressing forward, they ﬁrst build a simple rule-based baseline, which sets a concrete
benchmark the model must beat to justify the investment. When the model ships, it ships with a
monitoring dashboard, a documented retraining trigger, and a runbook for the three most likely
failure modes. Six months later, the model is still running.
Same business problem, same underlying technology, very different outcomes, because the second
team had a lifecycle designed for AI rather than borrowed from software. This chapter describes
1

<!-- page 2 -->
that lifecycle.
17.2 Challenge
How do you manage the end-to-end process of building an AI system, from validating the right
problem to running a production system that remains accurate over time, in a way that is repeat-
able, auditable, and designed to handle AI’s failure modes? And how do you adapt that process to
different project types, risk levels, team maturities, and organizational constraints without losing
its discipline?
17.3 Objectives
By the end of this chapter, you will be able to:
1. Explain how the AI development lifecycle differs from traditional software development and
why those differences require a different process.
2. Apply a structured eight-stage lifecycle framework to any AI project, from problem deﬁnition
through ongoing monitoring.
3. Identify the stage gates, artifacts, and decision criteria that prevent the most common and
costly AI project failures.
4. Distinguish between the lifecycle stages where experimentation is appropriate and where
discipline is non-negotiable.
5. Calibrate the lifecycle to the risk level of the system being built, from internal analytics tools
to regulated autonomous systems.
6. Connect lifecycle practices to the platform, data, security, and operational chapters that fol-
low.
7. Identify what inputs the Build stage requires from the Design stage and what it hands off to
Operations.
This chapter is the foundation for the Build section. It explains the process framework that guides all later
Build chapters. If you only read one chapter before starting an AI project, make it this one.
17.4 From Strategy to Build: What This Chapter Inherits
The Build stage does not start from a blank slate. Part 2 (Design) exists speciﬁcally to prevent that.
Three artifacts must be in place and accepted before engineering work begins. If they are not, the
project is not ready to build, regardless of timeline pressure.
The AI Strategy Portfolio Map (from AI Strategy, Chapter 9) establishes why this system is being
built: what business value it targets, what data readiness score it received, what AI approach was
selected (predictive ML, generative AI, agents, or hybrid), and what build/buy/partner decision
was made. Stage 1 of the AISDLC validates and operationalizes these decisions.
The Initial AI-PRD (from Design to Development, Chapter 16) is the primary authorization doc-
ument for Build. The AI Product Requirements Document contains input/output speciﬁcations,
performance thresholds, data requirements, evaluation criteria, failure modes, fallback behavior,
guardrails, and a traceability table linking every requirement to a test. Stage 1 translates the AI-
PRD into an executable engineering charter. If the PRD is vague or incomplete, that translation
2

<!-- page 3 -->
will fail, and the project will drift. This is not a waterfall artifact. Requirements start out general
and get reﬁned through rapid iteration.
The Reverse PRD Exercise output (from Design to Development, Chapter 16) is where engineer-
ing conﬁrms that they understand what they are being asked to build and what each gate requires.
Open questions, unresolved architecture decisions, and undocumented assumptions get surfaced
and resolved here. AI agents can accelerate these checks, but they cannot replace them.
When these artifacts are missing, the usual symptom is a team that begins development based on
a verbal description of what someone wants. They make assumptions that seem reasonable at the
time and are often wrong. The Stage 1 gate exists to catch exactly this.
17.5 Why AI Development Is Different
Understanding why AI needs a different lifecycle is what tells you which process elements are
essential and which are bureaucratic. It also explains why skipping them produces the failures
described above.
Figure 17.1: The four fundamental differences between traditional software development and AI systems
that make a purpose-built lifecycle necessary.
3

<!-- page 4 -->
17.5.1 Models Are Probabilistic, Not Deterministic
Traditional software behaves deterministically with respect to its code. If the speciﬁcation says
“return the highest-value customer segment,” the code returns exactly that, every time, setting
aside the complications of distributed systems and external dependencies. AI systems produce
probabilistically correct outputs. A churn model that predicts with 82% accuracy is wrong 18%
of the time by design. “It works” is not a binary state for AI. Accuracy, fairness, calibration, and
reliability all exist on a spectrum and have to be evaluated in context.
Testing and validation are therefore structurally different from software testing. You cannot write a
unit test to verify that a model is correct. You can only verify that it meets a performance threshold
on a deﬁned evaluation set, and that evaluation set has to be chosen with care, because a model
can perform well on the wrong distribution and fail on the actual production data.
17.5.2 Data Is a First-Class Engineering Dependency
In software, code is the product. In AI, data shapes the product as much as code does, because
the model is a function of what it was trained on. Data quality problems are production bugs:
a label-encoding error in the training pipeline, a distribution shift between training and serving
data, a missing-value strategy that worked in development and fails on live data. These require
engineering solutions, which means data pipelines, quality monitoring, schema validation, and
lineage tracking.
Data pipelines and data governance are not analytics concerns to be delegated to a data team. They
are engineering concerns and must be owned, versioned, tested, and monitored with the same rigor
as application code (Sculley et al. 2015).
17.5.3 Production Models Degrade Over Time
Software that runs correctly on Monday runs correctly on Friday, because changes in the world
do not touch the code. Many production AI models work differently. As the world changes, the
distribution of inputs shifts, and a model trained on last year’s data can become materially less
accurate this year without a single line of code changing. This is concept drift, or data drift (Scul-
ley et al. 2015). How much of it you face depends on how stable your domain is. A model in
a fast-moving consumer environment is under more drift pressure than one watching a slowly
changing industrial process. For most enterprise AI systems operating in dynamic environments,
treat model performance as perishable until you have evidence to the contrary.
Deployment, then, is not the ﬁnish line. It is the start of an operational loop that has to include
monitoring, drift detection, retraining triggers, and model lifecycle management.
17.5.4 Experimentation Is Inherent, Not Optional
AI development requires hypothesis testing, iteration, and frequent dead ends. An approach that
looks promising in theory may fail on the actual data. The path from problem statement to pro-
duction model is not linear. It is a search through a large, uncertain space.
Fixed scope, linear sprints, and committed delivery dates were not designed for that kind of search.
They create pressure to ship the model that exists rather than the model that performs. The AISDLC
handles this by separating the two: experimentation lives in Stage 5, where iteration is expected,
and discipline is required at the gates between stages, where commitment decisions get made.
4

<!-- page 5 -->
17.5.5 The Feedback Loop Is Part of the System
In software, the product is what ships. In AI, what ships is a system that improves over time
through data feedback, retraining, and iteration. A recommendation system that learns from user
behavior works differently from a feature that returns a static list. Designing the feedback loop at
the outset, rather than adding it later, allows an AI system to compound value rather than stagnate.
17.6 The AISDLC at a Glance
Figure 17.2: High-Level Overview of AI Systems Development Lifecycle Stages.
Here is the lifecycle structure in compact form, before the detailed stage descriptions.
Table 17.1: The AISDLC at a Glance — Stage, Core Question, Primary Owner, Main Artifact, Gate Deci-
sion.
Stage Core Question Primary Owner Main Artifact Gate Decision
1. Deﬁne
Problem
Is this the right
problem, deﬁned
well enough to
build?
Product owner +
exec sponsor
AI Project
Charter
Invest / pause /
reframe
2. Discover Data Does sufﬁcient
data exist to
support this
problem?
Data engineering
+ governance
Data Readiness
Assessment
Proceed / defer /
redesign scope
5

<!-- page 6 -->
Stage Core Question Primary Owner Main Artifact Gate Decision
3. Prepare Data Is the data
prepared in a
format suitable
for
development?
Data engineering
+ data science
Prepared data
assets +
knowledge
artifacts
Proceed /
remediate
4. Design
Solution
Is the proposed
approach
technically
sound and
aligned to
constraints?
Engineering lead Solution Design
Document +
Evaluation
Framework
Approve / revise
/ escalate
5. Develop Does a candidate
system meet the
success criteria?
Data science lead
+ engineering
Trained model
artifacts +
Experiment Log
Ship to
evaluation /
return to design
6. Evaluate Is the system safe
to deploy across
all risk
dimensions?
Three parallel
tracks (technical,
behav-
ioral/fairness,
compliance)
Validation
Report +
Production
Readiness
Checklist
Deploy /
remediate / halt
7. Deploy Is the system
behaving as
expected in
production?
Operations lead
+ on-call team
Monitoring
dashboards +
Runbooks +
Handoff Package
Full rollout /
expand canary /
rollback
8. Monitor Is the system still
delivering value
at acceptable cost
and risk?
Exec sponsor +
product owner
Operational
Review Records
Continue /
retrain /
redesign / retire
17.6.1 The AISDLC Is Controlled Iteration, Not Waterfall
The eight stages do not ﬂow in one direction only. The lifecycle anticipates speciﬁc return loops:
• Stage 2 back to Stage 1, when data discovery reveals that the required data does not exist
or cannot support the deﬁned success criteria. The problem gets reframed before the build
proceeds.
• Stage 3 back to Stage 2, when data preparation surfaces quality issues, schema gaps, or corpus
inadequacies that discovery missed. Return to Stage 2 to address the root cause in the data
sources before attempting preparation again.
• Stage 5 back to Stage 4, when experimentation shows the selected approach is infeasible or
that a different architecture is required.
• Stage 6 back to Stage 5 or Stage 2. Evaluation failures send the team back to development
if the system underperforms, or all the way back to data discovery if the root cause is data
quality or coverage.
• Stage 8 back to Stage 4 or Stage 1, when monitoring ﬁndings call for a redesign (new archi-
tecture) or a reframing (the business problem has changed).
What separates the AISDLC from open-ended experimentation is that each return loop passes
6

<!-- page 7 -->
through a gate with explicit criteria. You do not drift backward. You formally return, document
why, and re-enter with updated artifacts. Gates catch both premature forward progress and un-
controlled backward loops.
Figure 17.3: The eight stages of the AISDLC with explicit return loops, every backward transition passes
through a gate decision, and progress is never implicit.
17.7 The AI Systems Development Lifecycle Framework
17.7.1 Stage 1: Deﬁne Problem
Scope: The engineering team formally accepts the prior strategy and design artifacts, translates
them into an executable engineering charter, conﬁrms that the assumptions made during design
still hold in the current reality, and sets the speciﬁc, measurable success criteria that will govern
every subsequent gate.
Key activities:
• Conﬁrm the business problem in terms of decisions, outcomes, and measurable value, and
verify that the framing in the AI-PRD still matches current business reality.
• Revalidate AI feasibility with the engineering team. Do they agree on the approach, the
constraints, and the data dependencies?
• Identify stakeholders, success criteria, and constraints, including the regulatory, ethical, and
operational constraints the PRD did not capture.
• Set measurable success metrics that will govern gate decisions throughout the lifecycle, fo-
cusing on business outcomes rather than just model accuracy.
• Identify the go/no-go thresholds. Under what conditions should this project be paused or
stopped?
• Write the AI Project Charter, a one- to two-page document capturing the problem statement,
value hypothesis, success criteria, go/no-go thresholds, team accountabilities, and gover-
nance gates.
7

<!-- page 8 -->
Gate question: Has the engineering team accepted the problem deﬁnition and constraints? Are
the success criteria speciﬁc enough to write test cases against? Is there a clear go/no-go threshold
that would stop the project if the data or performance bar cannot be met?
Why this gate fails: Schedule pressure from stakeholders who want to move fast. Teams skip the
framing work, start building, and discover six months later that they built the wrong thing. The
most expensive AI projects are the ones that successfully delivered the wrong outcome.
Critical success factor: The gate does not pass until success metrics are speciﬁc and measurable.
“Improve customer retention” is not a success metric. “Reduce 90-day churn rate among loyalty
program members from 28% to 23%, conﬁrmed via holdout group comparison after 90 days of
production, with incremental retained revenue exceeding system cost within 9 months” is a success
metric.
Key decisions at this gate: Invest, pause, or reframe. This is a business decision, not a technical
one, and it belongs to the product owner and executive sponsor.
Key output: AI Project Charter
17.7.2 Stage 2: Discover Data
Scope: Validate that the data required to support the problem actually exists, in sufﬁcient quality
and quantity, before committing to the build.
Key activities:
• Inventory all available data sources: structured (transaction databases, CRM systems), un-
structured (call center transcripts, support tickets), internal, and external.
• Assess data quality across ﬁve dimensions: accuracy, completeness, consistency, timeliness,
and accessibility. Can you actually access it in a compliant way?
• Assess label quality. For supervised learning, how is the target variable deﬁned? Is there
a label delay, where you will not know whether a customer churned until the observation
window closes? Is there label leakage risk from features that encode future information? Is
the ground truth reliable?
• Identify data gaps and assess the cost and timeline to close them.
• Validate data access rights and governance. Is this data legally and contractually available
for the intended use? Are there PII or regulatory constraints?
• Produce a Data Card (or equivalent) for each primary dataset, covering provenance, consent
status, known quality issues, restrictions on use, and known biases in the collection method-
ology.
• Prototype data pipelines to validate assumptions before committing to the build. Do not take
data availability on faith.
Gate question: Is the data sufﬁcient to support the problem as deﬁned? If not, what would it
take to make it sufﬁcient, and is that investment justiﬁed? Has label quality been assessed and
accepted?
Why this gate is critical: Insufﬁcient or mislabeled data is among the most common and most
avoidable causes of AI project failure MIT Project NANDA (2025). Teams that skip data valida-
tion build elaborate model training pipelines only to discover that the data cannot support the
required performance. A project with insufﬁcient data should not proceed, however enthusiastic
the business is.
8

<!-- page 9 -->
Figure 17.4: Every AISDLC stage gate has ﬁve components. However, gates without explicit pass criteria
and independent ownership become gate theater.
9

<!-- page 10 -->
Risk ﬂag: Data that exists in theory but is not accessible in practice is not available data. That
includes data siloed in legacy systems, owned by another business unit, or governed by contracts
that prohibit ML use. Prototype the pipeline before passing the gate.
Key output: Data Readiness Assessment, covering available data sources, quality scores by dimen-
sion, label quality assessment, identiﬁed gaps, access risks, and a clear go/no-go recommendation.
These scores can and should be automated and aligned with business requirements and standards.
17.7.3 Stage 3: Prepare Data
Scope: Turn the raw data validated in Stage 2 into the prepared data assets, feature sets, and
knowledge structures that the Stage 4 approach requires. This goes beyond conventional machine
learning data preparation to include context construction, vector embedding, and the knowledge
preparation techniques speciﬁc to generative AI and agentic systems.
Key activities:
• Clean and normalize raw data sources: handle missing values, correct encoding errors, re-
solve schema inconsistencies, and validate referential integrity across sources, meaning that
records in one dataset point to matching records in another.
• Engineer features and build feature pipelines as production-grade code, versioned, tested,
and reproducible, with outputs loaded to a feature store or an equivalent versioned data
layer.
• For traditional ML systems, construct train, validation, and holdout (test) splits using parti-
tioning strategies that respect temporal ordering where applicable, encode categorical vari-
ables, and normalize or standardize numeric features as the selected model class requires.
• For LLM systems, chunk documents for embedding, generate and store vectors, build and
validate the index, and prepare context schemas for inference.
• For agentic systems, prepare tool schemas, structured knowledge stores, and any domain-
speciﬁc knowledge bases the agent will access at runtime, and validate that those knowledge
sources are current, accurate, and appropriately scoped.
• Document all data transformation logic and version every prepared asset. Data lineage has
to trace from the raw source through every transformation to the ﬁnal prepared asset.
• Validate prepared data assets against the requirements deﬁned in Stage 4 before passing the
gate. A prepared feature set that does not match the architecture’s expectations is a gate
failure, not a development problem.
Gate question: Are the prepared data assets, feature sets, and knowledge structures complete, val-
idated, and aligned with the architecture deﬁned in Stage 4? Are all data transformation pipelines
versioned and reproducible?
Why this stage is separate: Conventional ML data preparation is well understood and often col-
lapsed into the development stage. The reason to make it explicit here is knowledge preparation
for generative AI and agentic systems, which has become considerably more involved. Embed-
ding quality, chunking strategy, retrieval corpus coverage, and context schema design all have
ﬁrst-order effects on generative AI system performance, and all of them are preparation decisions
rather than development decisions. Leaving them to be resolved during experimentation in Stage 5
creates the same failure mode that makes data discovery failures so expensive: the build is already
underway before anyone knows the foundational assets are correct.
Key outputs: Versioned feature store population, prepared training and evaluation datasets, em-
10

<!-- page 11 -->
bedding indexes, retrieval corpora (the knowledge base), structured context schemas, and data
lineage documentation.
17.7.4 Stage 4: Design Solution
Scope: Commit to a technical approach, deﬁne the architecture, and establish the evaluation frame-
work before any model development begins.
Key activities:
• Select the AI approach, whether traditional predictive ML, generative AI (RAG, ﬁne-tuned
LLM), autonomous agents, or a hybrid, and write down the rationale for the selection.
• Deﬁne the system architecture, including components, services, data ﬂows, integration
points, serving architecture, and latency and throughput requirements.
• Design the user interface and interaction model with Product: how users will interact with
system outputs, what level of transparency and explainability the interface must provide,
and how the UI will support human review workﬂows where required.
• Design the evaluation framework: what “good enough” means in quantitative terms, how it
will be measured, which datasets will be used, what slice-based evaluation is required, and,
for LLM systems, how hallucination, grounding, and policy compliance will be evaluated.
• Design the human-AI collaboration model: which decisions are fully automated, which re-
quire human review, what the fallback behavior is when the system is unavailable or conﬁ-
dence is low, and how to prevent automation bias (Daugherty and Wilson 2018).
• Identify dependencies on platform components (Ch Chapter 18) and data infrastructure (Ch
Chapter 19).
• For predictive systems that drive interventions, decide whether the model should predict
risk (probability of churn) or treatment responsiveness (likelihood of responding to an offer).
These are different modeling problems with different feature requirements and evaluation
criteria. When intervention capacity is limited and ROI on the offer budget matters, uplift
modeling or treatment effect estimation may be a better ﬁt than risk scoring.
• Where the system uses vendor APIs, foundation model endpoints, or SaaS AI tools, docu-
ment data-sharing terms, model-update risk, SLA alignment, audit rights, and an exit strat-
egy.
Gate question: Is the proposed approach technically sound, feasible with the available platform
and data, and aligned with the business constraints deﬁned in Stage 1?
Key outputs: Solution Design Document, Evaluation Framework, Human-AI Collaboration
Model
17.7.5 Stage 5: Develop
Scope: Build the data pipelines, develop and iterate on models, and produce a candidate system
that meets the Stage 1 success criteria and is evaluated against the Stage 4 framework.
Key activities:
• Build data pipelines and feature engineering logic as production code, versioned, tested, and
reproducible.
• Develop and iterate on models with mandatory experiment tracking. Every training run,
hyperparameter conﬁguration, dataset version, and evaluation result gets logged.
11

<!-- page 12 -->
• Evaluate every candidate model against the Stage 4 framework, not against benchmarks se-
lected after the fact to make the results look good.
• Validate with subject matter experts and representative end users during development, not
only at the end.
• For LLM-based systems, Stage 5 covers prompt engineering and version management (every
prompt version tracked and evaluated), retrieval pipeline design and corpus quality assess-
ment, orchestration architecture, hallucination and grounding evaluation against representa-
tive test cases, toxicity and policy compliance testing, prompt injection hardening, cost and
latency proﬁling, and human evaluation calibration. System conﬁguration, evaluation, and
integration replace model training and demand greater evaluation rigor, not less.
• For agentic systems, Stage 5 requires additional design discipline. Tool permissions have to
be explicitly deﬁned and minimized. Action approval policies have to specify which tool
calls require human approval before execution. Sandboxing has to isolate agentic actions
from production systems during testing. Audit logs for all tool calls have to be implemented.
Containment behavior, meaning what the agent does when it hits an unexpected state, has
to be tested and documented.
Gate question: Does the candidate system meet the success criteria deﬁned in Stage 1, evaluated
against the framework deﬁned in Stage 4, on a holdout dataset it has not seen during development?
Non-negotiable discipline: Keep detailed records of experiments. A development process that
lacks a written log of what was attempted, the outcomes, and the reasoning behind selecting spe-
ciﬁc approaches cannot be reliably reproduced. Tools like MLﬂow (Deliver High-Quality AI, Fast,
n.d.), Weights & Biases (Weights and Biases, n.d.), and similar platforms are available to support
this.
Common failure mode: Evaluating the model on the training distribution and shipping it with-
out checking performance on the deployment distribution. The development environment almost
never matches production exactly.
Key outputs: Trained model artifacts, evaluation results on holdout data, experiment log, selected
model with selection rationale
17.7.6 Stage 6: Evaluate
Scope: Provide independent, evidence-based assurance that the system is safe to deploy across
performance, fairness, security, compliance, and integration. This goes well beyond the model
testing done in Stage 5, which served development.
Key activities:
• Validate model performance across slices, edge cases, and adversarial inputs, not just aggre-
gate accuracy.
• Test for fairness and unintended bias with appropriate rigor. Does the model perform dif-
ferently across demographic groups, geographic regions, or customer segments in ways that
are harmful or legally problematic? Dropping protected attributes from the feature set does
not eliminate the risk of bias. Proxy effects from geography, purchase history, channel behav-
ior, income proxies, device type, or store location can reproduce correlations with protected
attributes. Fairness auditing may require controlled access to protected attributes under de-
ﬁned governance, even when the model never uses them. Document the methodology, the
thresholds applied, and any residual risk accepted (Angwin et al. 2016; O’Neil 2016).
12

<!-- page 13 -->
• Conduct integration testing. Does the system work correctly across all upstream data
pipelines, downstream consumers, and fallback paths?
• Complete a security review. For ML systems, assess model extraction risk, which is not
limited to external API exposure; internal APIs, batch output access, vendor access, and in-
sider access all create exposure. For LLM systems, test for prompt injection, data exﬁltration
through generated outputs, and jailbreak vectors (Ch Chapter 21).
• Verify compliance with GDPR, HIPAA, the EU AI Act, or sector-speciﬁc regulations, as ap-
plicable (National Institute of Standards and Technology 2023).
• Produce a Model Card for each production model covering intended use, known limita-
tions, training data summary, evaluation results, identiﬁed risks, and recommended use
constraints (Margaret Mitchell, Simone Wu, Andrew Zaldivar, Parker Barnes, Lucy Vasser-
man, Ben Hutchinson, Elena Spitzer, Inioluwa Deborah Raji, and Timnit Gebru, n.d.). Model
cards are what make future audits, model replacement decisions, and incident investigations
tractable, which is why they are not optional.
• Compile the Validation Report and the Production Readiness Checklist.
Figure 17.5: Excluding protected attributes from features does not prevent bias; proxy variables in the feature
set can reproduce the same correlations through geographic, behavioral, and channel signals.
Gate question: Have all identiﬁed risks been mitigated to an acceptable level or formally accepted
by the appropriate owner? Is the system safe to deploy to production?
Gate ownership: Three independent tracks, all required.
• Technical track (engineering and data science lead): model performance, integration, infras-
13

<!-- page 14 -->
tructure
• Behavioral and fairness track (responsible AI function and product): fairness testing, user-
facing behavior, edge cases
• Compliance track (legal, security, and compliance): regulatory, privacy, and security sign-off
Failure mode to avoid: Treating this as a single technical review at the end of development. Evalua-
tion should run continuously across Stages 4 and 5, with the Validation Report as the ﬁnal synthesis
rather than a gate-day scramble.
Key outputs: Validation Report, Production Readiness Checklist, Model Card, compliance sign-off
17.7.7 Stage 7: Deploy
Scope: Move the validated system into production in a controlled, observable, and recoverable
way.
Key activities:
• Deploy using established CI/CD practices, promoting the model artifact through staging
before production (Ch Chapter 23).
• Select and implement a deployment strategy: canary release (route 5 to 10% of trafﬁc to the
new model ﬁrst), blue-green deployment (keep the old model as a live fallback), shadow
mode (run the new model in parallel without affecting users), or A/B testing (split trafﬁc to
measure business impact).
• Activate monitoring, alerting, and observability from day one rather than as a follow-on task
(Part 4).
• Deﬁne explicit rollback triggers before launch, meaning conditions that automatically or im-
mediately prompt a rollback to the prior system. Examples: canary performance drops be-
low baseline; data pipeline SLA failure; off-brand or policy-violating content rate exceeds
the threshold; protected segment disparity exceeds the accepted level; inference cost exceeds
the ceiling for consecutive days. Write rollback criteria before deployment, not during an
incident. (Ch 4.4).
• Complete the Operational Handoff Package for the team that will operate the system after
deployment, and conﬁrm that the team has been trained and has accepted the handoff. The
handoff is itself a gate. Deployment does not pass until operations has formally accepted
ownership.
The Operational Handoff Package includes the Model Card, Data Cards for primary training
datasets, system architecture documentation, monitoring dashboard links and alert threshold doc-
umentation, the runbook library, escalation contacts, inference cost baseline and ceiling, and on-
call training materials.
Gate question: Is the system behaving as expected in production? Are all monitoring thresholds
active and calibrated? Has the operations team accepted the handoff?
Why deployment strategy matters: Silent failure, where the system keeps serving predictions
while performance degrades below any meaningful threshold, is a real and underappreciated risk
in AI systems. A canary deployment with monitoring catches that class of failure before it reaches
the full user population.
Key outputs: Deployed system, monitoring dashboards, runbooks, Operational Handoff Package
(including Model Card and rollback criteria)
14

<!-- page 15 -->
Figure 17.6: The four primary AI deployment strategies and when to use each.
15

<!-- page 16 -->
17.7.8 Stage 8: Monitor
Scope: Keep the system working, accurate, and valuable over time, and feed operational learning
back into strategy and product.
Key activities:
• Monitor continuously for drift, degradation, and unexpected behavior across all ﬁve moni-
toring layers: infrastructure, pipeline, model, application, and business.
• Monitor cost as a ﬁrst-class operational metric, particularly for LLM-based systems where
inference costs can scale unexpectedly with usage. Cost monitoring belongs on the same
dashboard as performance monitoring, not in a separate ﬁnance report.
• Manage the model lifecycle. Deﬁne and enforce retraining triggers (schedule-based, drift-
triggered, or performance-triggered), manage version transitions, and plan for deprecation.
• Collect feedback from users, business stakeholders, and downstream consumers to build the
iteration backlog.
• Manage organizational adoption. Watch whether business users are acting on system out-
puts as intended, whether automation bias is developing (over-reliance without appropriate
skepticism), and whether the workﬂow integration is producing the intended decisions. Pro-
duction AI failure is frequently organizational rather than technical, so monitor the human
side of the system with the same rigor as the model side (Daugherty and Wilson 2018).
• Conduct regular operational reviews, monthly at the product level and quarterly at the port-
folio level, to assess whether the system is still delivering value and whether the original
success criteria are still the right ones.
• Feed operational ﬁndings back to strategy and product (Chapter 31).
Gate question (ongoing): Is the system still delivering value at an acceptable cost and risk level?
Does it need to be retrained, redesigned, or retired?
The exit decision is a gate too: Organizations are usually better at launching AI systems than
retiring them. A system that no longer delivers value but keeps running consumes compute, cre-
ates governance liability, and occupies engineering attention. Put the retirement question on the
operational review agenda explicitly.
Key outputs: Operational metrics dashboard, drift reports, retraining records, cost reports, techni-
cal debt backlog, operational review outputs, retirement decisions.
17.8 Lifecycle Phases: System Maturity and Scale
The AISDLC stages describe how to build an AI system. There is a second dimension practitioners
need: how mature and production-ready is the system at a given point in its evolution? That is what
lifecycle phases capture.
Phases are not stages. Stages describe the process steps, the activities you perform, and the order
you perform them in. Phases describe the maturity and scale of the deployed system. A single
project moves through multiple phases over its life, and the rigor, infrastructure, and governance
appropriate to each phase differ substantially. The AISDLC deﬁnes ﬁve.
16

<!-- page 17 -->
Figure 17.7: High-Level Overview of the AI Systems Development Lifecycle Phases.
17.8.1 Phase 1: Proof-of-Concept
A Proof-of-Concept (PoC) is an initial system built to test technical feasibility and validate the
overall concept. The goal is not something production-ready. The goal is to answer one technical
question: Can this approach work at all? PoC systems get built quickly, use sample or synthetic data,
and are not designed for scale, reliability, or production deployment.
Purpose: Show that the core technical approach, whether a particular model architecture, retrieval
strategy, or agent design, is feasible for the problem.
What it is not: A system designed to prove business value, a pilot, or a prototype. A PoC that
demonstrates technical feasibility still has to move through later phases before anyone can draw
business conclusions from it.
Typical scope: Days to weeks of effort, a small team, sample data, no production infrastructure
required.
Exit criterion: A clear answer to the technical feasibility question.
17.8.2 Phase 2: Proof-of-Value
A Proof-of-Value (PoV) is an initial system built to prove the potential business value of the pro-
posed system. The question shifts from “can we build it” to “does it produce meaningful business
outcomes?” A PoV typically uses real or representative data and measures against actual business
metrics.
Purpose: Validate whether the technical approach, applied to the real problem with real data, pro-
duces outcomes that justify continued investment. These results often become part of a business
case.
17

<!-- page 18 -->
What it is not: A production-ready system. A PoV is not built for scale, robustness, or broad
deployment. It exists to test the value hypothesis.
Typical scope: Days to a few weeks, a small team, real or representative data, limited infrastructure
investment.
Exit criterion: Evidence that the system produces enough business value to justify the investment
required to build the full system.
17.8.3 Phase 3: Prototype
A prototype is a small, end-to-end system built in the development environment that has all the
major functionality of the ﬁnal system but is not ready for production or scale. It is the ﬁrst time the
full system, including data pipelines, models, application layer, and user interface, gets assembled
and evaluated together.
Purpose: Show a complete but non-production version of the system. Every major component
is present and functional, the prototype can be demonstrated to stakeholders, and end users can
evaluate it in a controlled environment.
What it is not: A production system. Prototypes typically lack the performance optimization, relia-
bility hardening, security hardening, monitoring, and scale infrastructure that production requires.
Typical scope: Weeks to months, the full team, development environment, end-to-end functional-
ity.
Exit criterion: A system that demonstrates all key functionality and that stakeholders have con-
ﬁrmed meets the design intent.
17.8.4 Phase 4: Pilot
A pilot is the initial production deployment to a segment of customers or users. It validates the
system in a real production environment with real users at limited scale, which allows controlled
measurement of business impact, surfaces operational issues that development never shows, and
catches failure modes before full rollout.
Purpose: Validate the system in the real production environment with real users, at controlled
scope and risk.
What it is not: Full production. The pilot is a gate, not a destination. The question at the end of a
pilot is whether the system should go to full-scale production deployment.
Typical scope: Weeks to months, a subset of the full user population, full production infrastructure,
active monitoring.
Exit criterion: Conﬁrmed business value in production at limited scale, all critical failure modes
addressed, and an operations team conﬁdent in full rollout.
17.8.5 Phase 5: Production
Production is full-scale deployment to the complete intended user population. A production sys-
tem is fully operationalized: monitored, governed, with deﬁned retraining policies, and integrated
into business processes.
18

<!-- page 19 -->
Purpose: Deliver the system’s full value at scale, with all operational requirements in place.
What it is not: The end of the lifecycle. Production is where the Monitor stage begins, with its
ongoing evaluation, drift detection, retraining, and the organizational work of keeping a system
valuable.
Typical scope: Full user population, full production infrastructure, active monitoring and opera-
tions.
Exit criterion: There is no exit. Production is maintained until the system is retired, and the oper-
ational review cadence governs decisions about retraining, redesign, or retirement.
Figure 17.8: AISDLC rigor scales with risk tier; a low-stakes internal analytics tool and a regulated au-
tonomous decision system require fundamentally different gate structures.
The relationship between stages and phases matters in practice. The stages govern how you build
and operate the system at each point. The phases describe what you are building toward, meaning
the maturity level the system has to reach at each investment gate. An enterprise AI program
usually manages a portfolio of systems sitting in different phases at the same time, and governance,
investment, and operations requirements scale accordingly.
17.9 Stage Gates and Artifacts
Gates are the mechanism that prevents premature progression. They are the checkpoints that sep-
arate teams that ship reliable AI systems from teams that ship impressive demos.
19

<!-- page 20 -->
17.9.1 Why Gates Fail in Practice
The most common gate failure mode is gate theater. The gate review happens, the checklist gets
reviewed, and the project moves forward whether or not the criteria are met, because the schedule
says it must. Fixing gate theater takes three things:
1. Explicit, measurable pass/fail criteria deﬁned before the build begins. “Data quality is suf-
ﬁcient” is not a criterion. “Transaction history covers at least 24 months with fewer than 5%
missing values in the 12 ﬁelds required for feature computation” is.
2. Gate ownership independent of the team under review. The team that built the system cannot
also be the ﬁnal arbiter of whether it passes.
3. Organizational authority to enforce a pause. Gates without consequences are suggestions.
17.9.2 Essential Artifacts by Stage
Table 17.2: Essential Artifacts by Stage — Stage, Key Artifact, Lightweight Version, Full-Enterprise Version,
What It Prevents.
Stage Key Artifact
Lightweight
Version
Full-Enterprise
Version What It Prevents
Deﬁne Problem AI Project
Charter
1-page problem
statement + 3
success metrics
Full charter with
stakeholder
matrix and
governance gates
Building the
wrong thing
Discover Data Data Readiness
Assessment
Informal data
audit memo
Scored
assessment with
access risk
sign-off
Building on
insufﬁcient data
Prepare Data Prepared data
assets +
knowledge
artifacts
Annotated
notebook with
transformation
steps
Versioned
feature store +
embedding
indexes + lineage
documentation
Starting
development
with unprepared
or incompatible
data
Design Solution Solution Design
Doc + Evaluation
Framework
Architecture
sketch +
threshold table
Full design
review with
sign-off
Architecture
decisions made
under pressure
Develop Experiment Log Tagged notebook
with result
summary
MLﬂow/W&B
run history with
artifact registry
Irreproducible
results; post-hoc
metric selection
Evaluate Validation
Report +
Readiness
Checklist +
Model Card
1-page test
results summary
Full report with
three-track
sign-off
Deploying
systems with
unacknowledged
risks
Deploy Runbooks +
Operational
Handoff Package
3-item runbook +
dashboard link
Full runbook
library + Model
Card + on-call
training
Silent failures;
unmanaged
incidents
20

<!-- page 21 -->
Stage Key Artifact
Lightweight
Version
Full-Enterprise
Version What It Prevents
Monitor Operational
Review Records
Monthly metric
review notes
Quarterly
portfolio review
with retirement
tracking
Zombie systems;
cost overruns;
undetected drift
Use the lightweight version for low-risk internal tools and proof-of-concept systems. Customer-
facing systems, regulated applications, and autonomous decision systems require the full-
enterprise version.
17.9.3 Gate Ownership
• Stage 1: Product owner and executive sponsor. A business decision.
• Stage 2: Data engineering lead and data governance. A data reality decision.
• Stage 3: Data engineering lead and data science lead. Data preparation readiness.
• Stage 4: Engineering lead and architecture review board.
• Stage 5: Data science lead and product owner. Did it meet the criteria?
• Stage 6: Three parallel independent tracks: engineering lead (technical), responsible AI func-
tion (behavioral and fairness), legal and compliance (regulatory).
• Stage 7: Operations lead and on-call team. Is the system handed off and monitored?
• Stage 8 (ongoing): Operations, executive sponsor, and product owner. Is the value still there?
17.10 Adapting the Lifecycle to Context
The eight-stage framework is a template, not a rigid prescription. How you apply it varies materi-
ally by risk level and organizational maturity. The core logic does not vary.
17.10.1 Risk Tiering
Not all AI systems carry the same risk. Calibrate lifecycle rigor to consequence, not to project
ambition.
Table 17.3: Risk Tiering — Risk Tier, Example System, Minimum Lifecycle Requirements.
Risk Tier Example System
Minimum Lifecycle
Requirements
Low risk, internal
productivity tool, analyst
dashboard, low-stakes
recommendation
Internal document search
assistant; scheduling
optimizer
Stages 1 to 5 with lightweight
artifacts; Stage 6 technical
testing only; Stage 8 informal
monthly review
Medium risk, customer-facing
system, revenue-affecting
model, personalization engine
Churn prediction and
retention offer engine;
e-commerce recommendations
Full eight stages; Stage 6
includes fairness testing and
compliance check; Stage 8
with formal monthly review
21

<!-- page 22 -->
Risk Tier Example System
Minimum Lifecycle
Requirements
High risk, regulated decision
support, healthcare, credit,
insurance, hiring
Credit risk scoring; clinical
decision support; insurance
underwriting
Full eight stages plus
independent
ethics/compliance review;
Stage 6 requires all three
tracks; all artifacts at
full-enterprise level; audit trail
required
Critical risk, autonomous
systems taking external
actions, high-stakes
irreversible decisions
Autonomous trading agent;
automated contract execution;
agentic customer support with
payment authority
Full eight stages plus
adversarial testing; agentic
containment design required;
human approval gates for
high-consequence actions;
legal sign-off on action
authorization scope
When you are unsure which tier a system belongs in, ask what the worst possible harm would be
if the system made a wrong decision at scale. The answer places the tier.
17.10.2 By Project Type
Greenﬁeld AI: Follow all eight stages in order. Do not skip Discover Data or Prepare Data. The
temptation to start building immediately is strong and the consequences are predictable.
Model Replacement: Begin at Stage 4, but re-run Stage 2 ﬁrst. The data that supported the original
model may have changed in ways that affect the new model’s training. Never assume existing data
is still ﬁt for purpose without validating it.
LLM and generative AI systems: Stage 5 is mostly prompt engineering, retrieval pipeline design,
and orchestration. The Stage 4 evaluation framework becomes more important, not less. Stages 6
and 8 need expanded attention to prompt version management, retrieval corpus quality and em-
bedding drift, hallucination and grounding assessment, toxicity and policy compliance, prompt
injection and data exﬁltration hardening, LLM-as-judge calibration (LLM-based automated eval-
uators can be inconsistent and have to be validated against human evaluation before you trust
them as primary signals), human review thresholds for high-stakes outputs, and cost and latency
monitoring.
Agentic systems: Stages 3, 4, 5, and 6 all require additional rigor. Agent architectures introduce
emergent behaviors, multi-step failure modes, and tool-use risks that stateless models do not have.
The evaluation framework has to include task completion rate, step efﬁciency, tool call accuracy,
and containment behavior. Stage 6 has to test tool permission scoping, action approval policies,
sandboxing effectiveness, audit log completeness, and the prevention of irreversible actions. Stage
8 has to watch for capability drift as the agent’s operating environment changes.
Rapid prototypes and proof of concepts: Compress Stages 1 to 4 into a focused discovery sprint.
The gate at the end of that sprint is still non-negotiable: is this problem worth solving with a
production system? A prototype that answers “no” is a success, because it prevented a bad invest-
ment.
22

<!-- page 23 -->
17.10.3 By Organization Maturity
Early-stage (ﬁrst AI systems): Adopt the lifecycle as written. The overhead of gates and artifacts
will feel heavy at ﬁrst. It will feel essential the ﬁrst time a gate catches a problem that would have
been catastrophic to discover in production.
Mature (established AI practice): Map existing processes to the framework and ﬁnd the gaps.
Most mature teams already have something resembling Stages 5 and 6. The usual gaps are Stages
1 to 3, where teams rush to build without rigorous framing, data discovery, and data preparation,
and Stage 8, where they treat deployment as the end of the project.
Regulated industries: Gates become mandatory compliance checkpoints. The Validation Report
and Production Readiness Checklist are audit artifacts. Build the documentation requirements into
the gate process from the start.
17.11 Application Examples: Real-World Case Studies
17.11.1 Case Study 1: Google’s ML Test Score
Google published a rubric for assessing the production readiness of ML systems: 28 tests spanning
data quality, model integrity, infrastructure reliability, and monitoring coverage (Breck et al. 2017).
The paper, “ML Test Score,” presents a technical debt-reduction framework that grades teams on
a readiness scale from 0 to 4. It reports that most teams scored in the lowest tier, with few or no
automated tests, no data validation, and minimal monitoring, and argues that higher-tier scores
correlate with more maintainable, monitorable, and recoverable systems. This is a best-practice
guideline rather than a formal causal link.
The eight-stage AISDLC maps onto the ML Test Score framework directly: strong data validation
in Stage 2, data preparation rigor in Stage 3, rigorous experimentation in Stage 5, comprehensive
evaluation in Stage 6, and active monitoring in Stages 7 and 8 together cover what a high ML Test
Score requires.
Takeaway for practitioners: Use the ML Test Score as a Stage 6 production-readiness tool. Score
the system before deployment and treat any score below a deﬁned threshold as a gate failure.
17.11.2 Case Study 2: Amazon’s Recruiting Tool
Between 2014 and 2018, Amazon developed an experimental internal AI recruiting tool meant to
help screen resumes. The tool was never deployed as the operational decision-maker for hiring,
and Amazon’s recruiters were instructed not to rely on it. The company abandoned it after dis-
covering that the model systematically penalized resumes containing the word “women’s” and
downgraded graduates of all-women’s colleges. It had been trained on ten years of resume sub-
missions to Amazon, a dataset that reﬂected predominantly male historical hiring patterns, and it
learned to replicate those patterns (Dastin 2018).
The tool was caught before full deployment, which is worth noting. The process did not fail com-
pletely. The failure is still instructive, though: years of engineering effort, high cost, and reputa-
tional risk came from two speciﬁc gaps.
The ﬁrst was a framing failure in Stage 1. The success criteria never required the system to be-
have equitably across demographic groups. The second was an evaluation failure in Stage 6. The
23

<!-- page 24 -->
evaluation process did not include gender-based slice evaluation before recruiters used the tool.
The case shows the fairness ﬂaw Stage 6 exists to catch. Leaving fair performance out of the re-
quirements is itself a design choice, and it carries legal and reputational risk.
Takeaway for practitioners: Build fairness evaluation into the Stage 4 evaluation framework and
test it in Stage 6 before any system affecting human outcomes reaches production. Excluding pro-
tected attributes from features is necessary but not sufﬁcient.
17.12 Use Case: Retail Customer Acquisition and Retention — North-
Star Retail
This use-case thread spans all chapters of the book. Each chapter applies its topic to this scenario. Follow the
thread across chapters and you will have a blueprint for a production-ready retail AI application.
Company context: NorthStar Retail is a mid-market specialty retailer with 400 stores across North
America and an e-commerce platform that accounts for 35% of revenue. The company has 2.3 mil-
lion active loyalty members and processes roughly 18 million transactions a year. The marketing
analytics team found that their 12-month loyalty member churn rate is 28%, against an industry
benchmark for comparable retailers of about 22%. Closing that gap is worth an estimated $12
million in retained annual revenue.
The executive team approved an AI investment to build a customer acquisition and retention sys-
tem. The AI Strategy Portfolio Map (Part 1) scored this use case high on value potential, mod-
erate on data readiness, and low to moderate on operational risk. The approved approach is a
hybrid: a predictive ML model for churn-probability scoring, with an LLM component to person-
alize retention-offer messaging.
A note on the modeling objective: The NorthStar team made an early decision that Stage 4 is
designed to revisit. The v1 system predicts churn risk, not treatment responsiveness. A high churn
probability does not mean a customer will respond to an offer, and some high-risk customers have
already decided to leave and will not be persuaded by any intervention. Uplift modeling, which
predicts which customers will respond to a speciﬁc offer, would optimize intervention ROI more
directly, but it requires experimental data NorthStar does not yet have. The iteration backlog in-
cludes an uplift modeling workstream once enough historical offer-response data accumulates
from v1 operations.
17.12.1 Stage 1: Deﬁne Problem
What NorthStar validated (translating the AI-PRD into the engineering charter):
• Business problem: Which loyalty members are at risk of churning in the next 90 days, and
what retention offer would most likely prevent that churn for each individual?
• Decision the system must support: The marketing team reviews a prioritized list of at-risk
members weekly and selects from a menu of offers (discount, free shipping, exclusive access)
generated by the system. The team can act on a maximum of 50,000 members per week, and
that operational capacity constraint shapes what the model has to optimize for.
• Churn label deﬁnition: A loyalty member counts as churned if they make no qualifying pur-
chase in the 12 months following the observation date. For modeling, the team uses a 90-day
proxy churn label: a member is ﬂagged if they show no engagement (purchase, email open,
24

<!-- page 25 -->
or offer redemption) in the preceding 90 days and subsequently churns within 12 months in
historical data. Full 12-month churn outcomes will be measured over a complete observation
window after deployment; the 90-day proxy allows earlier model evaluation and operational
feedback.
• Success criteria: (1) Reduce the 12-month churn rate among loyalty members from 28% to
23% or lower, measured via holdout group comparison over a full 12-month observation
window; (2) the 90-day proxy churn rate in the AI-targeted cohort declines by at least 3 per-
centage points within 120 days of full rollout (leading indicator); (3) incremental revenue
attributed to retained customers exceeds system cost within 9 months of full rollout.
• Constraints: The marketing team can act on a maximum of 50,000 members per week; no
protected class attributes in offer targeting decisions (controlled access for fairness auditing
under legal governance is permitted); inference cost ceiling of $40,000/month.
• Go/no-go criteria: The Stage 2 gate cannot pass without 24 months of transaction history and
fewer than 5% missing values in the key feature ﬁelds. If the data does not exist, the project
returns to Stage 1 to revise the scope.
• Vendor governance: The LLM component will use an external API provider. Legal is re-
viewing data sharing terms, and the team will not pass Stage 4 without a signed DPA and a
documented model-update-risk policy.
AI Project Charter: Written, reviewed by the VP of Marketing and the engineering lead, and ac-
cepted.
17.12.2 Stage 2: Discover Data
What NorthStar found:
• Transaction database: 36 months of history, 97% completeness on key ﬁelds (transaction
date, amount, product category, store/online ﬂag, loyalty ID). Gate criterion met.
• Customer proﬁles: 89% completeness on demographics. Age and geographic region are
available. Income bracket is self-reported and only 61% complete, so it was excluded from
the initial feature set and ﬂagged for fairness proxy analysis.
• Loyalty program events: Email opens, offer redemptions, and point balances, at 100% com-
pleteness. High value.
• Digital behavioral signals: Web clickstream data available, but only for 40% of loyalty mem-
bers (authenticated e-commerce sessions only). A signiﬁcant gap, documented.
• Mobile app data: Available but stored in a third-party mobile analytics vendor’s system.
Data access agreement review required before use, legal dependency ﬂagged, excluded from
v1.
• Label quality assessment: The 90-day proxy churn label was constructed from historical
data. Label leakage review conﬁrmed that all features are computed from data available at
scoring time, with no future-period data included. Label delay is inherent in the 12-month
outcome deﬁnition; the 90-day proxy was accepted as a validated leading indicator based on
18-month historical correlation analysis.
Data gaps and decisions:
• Digital behavioral signal gap (60% of members): Stage 4 will design the model to operate
with or without digital behavioral features, with performance expectations set separately
for each segment. The store-primary member segment will likely underperform, which was
accepted as a documented, monitored risk.
25

<!-- page 26 -->
• Mobile app data: Excluded from v1 pending legal review, and the highest-priority integra-
tion item in the iteration backlog.
• External data enrichment: Assessed and deferred. The marginal value does not justify the
integration cost in v1.
Data Readiness Assessment: Completed. Overall grade: sufﬁcient to proceed, with documented
constraints and accepted risks.
17.12.3 Stage 3: Prepare Data
Churn prediction component:
• Cleaned and validated the transaction database export. Resolved 2.3% of records with du-
plicate loyalty IDs (de-duplication policy: retain the record with the most recent updated
timestamp) and addressed 1.1% of records with invalid transaction amounts (negative val-
ues from return transactions retained as negative features, zero-value records removed as
likely system artifacts).
• Built the feature computation pipeline as versioned code: a nightly batch job that reads from
the validated transaction store, computes all 47 candidate features across recency, frequency,
monetary, and category afﬁnity dimensions, and loads the output to the feature store parti-
tioned by computation date.
• Built train, validation, and holdout splits: a temporal split with a 24-month training win-
dow, a 2-month validation window, and a 4-month holdout window. Temporal ordering is
respected and no holdout data appears in the training or validation partitions. The split was
validated against the churn base rate (28% in training, 27% in validation, 29% in holdout,
acceptable variation).
• Constructed the 90-day proxy churn label for all labeled records and validated it against
the 12-month churn outcome on historical records with sufﬁcient observation windows (18-
month correlation conﬁrmed at 0.74 between the 90-day proxy and the 12-month churn out-
come).
Offer personalization component (LLM):
• Assembled the offer template library: 12 approved offer templates from the marketing team,
reviewed for brand voice consistency and compliance with offer terms policy, stored as struc-
tured JSON with metadata (offer type, discount tier, expiry terms, applicable segments).
• Designed the member context schema, which deﬁnes the 8 ﬁelds assembled at inference time
(churn score, top product categories, last interaction date, loyalty tier, offer redemption his-
tory, preferred channel, days since last email open, historical response to offer types), vali-
dated against a sample of 1,000 member records to conﬁrm completeness and correct ﬁeld
population.
• No vector embedding required for v1. The LLM receives structured context directly rather
than retrieving it from an unstructured corpus. Embedding-based retrieval sits in the itera-
tion backlog for a future version that incorporates unstructured product and behavior data.
Gate result: Feature store populated and validated, training/validation/holdout splits conﬁrmed,
churn label construction validated, offer template library and member context schema reviewed
and accepted by the engineering lead and the marketing team lead. Stage 3 gate passed.
26

<!-- page 27 -->
17.12.4 Stage 4: Design Solution
Architecture decisions:
• Churn prediction: Gradient boosting classiﬁer (XGBoost-class). Interpretable, proven on
tabular retail data, computationally efﬁcient at inference time. LLM-based prediction was
evaluated and rejected: higher cost, lower interpretability, and no meaningful accuracy ad-
vantage over structured tabular features.
• Offer personalization: LLM-based message generation with retrieval-augmented context.
The LLM receives the member’s proﬁle, predicted churn probability, historical offer redemp-
tion behavior, and a library of approved offer templates, then generates a personalized ver-
sion of the most relevant template. A marketing team member reviews all generated mes-
sages before sending during the canary stage; automated-only sending begins once the hu-
man review sample conﬁrms acceptable quality.
• Feature pipeline: Batch processing, refreshed nightly. Online inference is not required, since
the marketing team reviews a weekly prioritized list.
• Serving architecture: The batch prediction job runs Sunday night, results load into a read-
optimized database, and the marketing team accesses them through the existing CRM dash-
board.
• Uplift modeling: Deferred to the iteration backlog. v1 uses churn risk as an intervention
proxy, and the uplift workstream starts once 6 months of offer-response data from v1 are
available.
• Vendor governance (LLM): External API provider DPA in ﬁnal legal review. Model-update-
risk policy: if the provider updates the foundation model, the marketing team re-evaluates
200 generated messages against the pre-update quality baseline before automated generation
resumes. Exit strategy documented: the prompt library and evaluation harness are provider-
agnostic and can migrate to a different API within about 2 weeks of re-evaluation effort.
Evaluation framework:
• Churn model: AUC-ROC at or above 0.80 on the holdout set; precision in the top-scored
decile at or above 0.60 (the metric that matters most given the 50,000-member weekly opera-
tional capacity); lift at the top decile at or above 2.0x versus random; calibration score (Brier
score) below 0.15. Slice-based evaluation is required for age group (18-34, 35-54, 55+), region
(Northeast, Southeast, Midwest, West), and online versus store primary channel. No slice
may perform more than 10 percentage points below the aggregate on top-decile precision.
• Offer personalization: Human evaluation by the marketing team on 500 generated messages
before canary launch. LLM-as-judge used for automated ﬂuency and brand-voice scoring
on an ongoing basis, calibrated against the 500-message human evaluation set (LLM judge
agreement with human evaluators has to exceed 80% before the judge becomes a primary
signal). Offer redemption rate versus control group measured at 60 days post-full-rollout.
• Fallback behavior: If the churn model is unavailable, the CRM dashboard displays the ex-
isting RFM segment scores, so members are never left without a prioritization signal.
17.12.5 Stage 5: Develop
Feature engineering:
• 47 features engineered across four categories: recency (days since last transaction, days since
last email open), frequency (transaction count by period, offer redemption rate), monetary
27

<!-- page 28 -->
Figure 17.9: The NorthStar churn and offer personalization system architecture, the production output of
applying all eight AISDLC stages to a retail AI use case.
28

<!-- page 29 -->
(average transaction value, total spend trend), and category afﬁnity (product category pref-
erence shifts over time).
• Feature store populated by a weekly batch job, with features versioned by computation date
for reproducible training.
Experiment log summary (3 representative runs of 14 total):
Table 17.4: Stage 5: Develop — Run, Model, Features, AUC-ROC, Top-Decile Precision, Notes.
Run Model Features AUC-ROC
Top-Decile
Precision Notes
01 Logistic
regression
RFM only 0.71 0.48 Baseline
07 XGBoost RFM +
category
afﬁnity
0.83 0.63 Exceeds
threshold
11 XGBoost All 47
features
0.84 0.64 Marginal
gain; higher
maintenance
burden
Selected model: Run 07. The marginal improvement from adding all 47 features (1 point of AUC,
1 point of top-decile precision) does not justify the extra feature engineering and maintenance
burden. The team selected the simpler feature set and moved the remaining features to the iteration
backlog for future evaluation.
Offer personalization: The marketing team evaluated three prompt architectures on blind sam-
ples. Architecture 2 (member context, offer template, tone instruction, and an explicit brand-voice
guardrail) was preferred in 73% of blind evaluations. Selected.
17.12.6 Stage 6: Evaluate
Churn model validation results:
• Overall AUC-ROC: 0.83 (holdout dataset, 90-day proxy churn label)
• Top-decile precision: 0.63 | Lift at top decile: 2.2x | Brier score: 0.12. All thresholds met.
• Slice evaluation (top-decile precision): Age 18-34: 0.64 | Age 35-54: 0.65 | Age 55+: 0.58.
The 55+ segment underperforms by 5 points, within the 10-point threshold but ﬂagged for
monitoring with a lower alert threshold in Stage 8.
• Online versus store: Online-primary 0.67 | Store-primary 0.58. The store-primary segment
underperforms, partly explained by the digital behavioral signal gap. Documented in the
Validation Report with a recommendation to prioritize mobile app data access and close the
gap in v2.
Fairness review:
Gender and race are not used as training features or targeting attributes. The team documented
the following proxy risks and does not claim to have fully resolved them: zip code correlates with
race and income in some regions, product category afﬁnity may correlate with gender, and store
29

<!-- page 30 -->
channel correlates with demographic patterns in certain markets. A formal proxy analysis using
available age and region data identiﬁed no systematic performance disparities across those dimen-
sions at the 10-point threshold. The responsible AI function signed an acceptance risk statement
acknowledging that demographic coverage is insufﬁcient for a complete fairness audit and that a
more rigorous fairness evaluation is planned for v2 as coverage improves. Protected attribute data
will be used for fairness auditing under legal governance, never for offer targeting.
Integration testing: The full pipeline was tested end-to-end, from raw transaction data through
feature computation, model scoring, offer generation, and CRM dashboard display. Two bugs
were found and ﬁxed in the data pipeline. One edge case in the offer generator (empty redemption
history) was handled with an explicit fallback to the template default.
Security review: The LLM offer generator was tested for prompt injection (an attempt to override
brand-voice instructions through member proﬁle data) and mitigated with input sanitization and
output ﬁltering. The churn model is not externally exposed, which lowers model extraction risk,
but access controls on batch output ﬁles and on vendor access to the inference infrastructure were
reviewed and tightened. An output governance policy was implemented: batch prediction results
are access-controlled and not shared outside the CRM system without explicit approval.
LLM-as-judge calibration: Agreement with human evaluators on a 500-message evaluation set
was 83% on brand-voice scoring and 79% on relevance. Accepted as a supplementary signal. Hu-
man review of a 10% sample continues through the canary stage.
Validation Report: Complete. All gate criteria met or documented as accepted risk with stated
conditions. Production Readiness Checklist: 24 of 24 items passing. Model Card and Data Card
produced.
17.12.7 Stage 7: Deploy
Deployment strategy: Canary release. For the ﬁrst two weeks, 10% of marketing actions use AI-
generated scores and offers while 90% continue on the RFM baseline. The canary cohort is moni-
tored against explicit rollback triggers before full rollout.
Explicit rollback triggers (deﬁned pre-launch):
1. The offer redemption rate in the canary cohort falls below the RFM baseline for two consec-
utive weeks.
2. Data pipeline ingestion failure exceeds 2 consecutive nights.
3. Off-brand or policy-violating content ﬂag rate exceeds 1% of generated messages in any re-
view sample.
4. The 55+ or store-primary segment performance disparity exceeds 10 points versus aggregate
in canary monitoring.
5. Inference costs exceed $40,000/month for two consecutive weeks without prior approval.
Monitoring activated at launch:
• Pipeline monitoring: Daily ingestion success rate, feature freshness, schema violation alerts.
• Model monitoring: Weekly distribution comparison on key features using PSI (Population
Stability Index), with an alert if any core feature PSI exceeds 0.2 relative to the training dis-
tribution, a common industry rule of thumb (Yurdakul and Naranjo 2020).
• Business monitoring: Offer redemption rate (weekly), 90-day proxy churn rate in the AI-
targeted cohort versus holdout (weekly), incremental revenue attribution estimate (monthly),
30

<!-- page 31 -->
inference cost (weekly).
• LLM monitoring: Off-brand content ﬂag rate, LLM-judge scores on a random 5% sample,
token consumption versus baseline.
Runbooks written before launch:
1. Pipeline failure (data ingestion does not complete by Sunday midnight): fall back to RFM
scores, alert on-call, investigate pipeline logs.
2. PSI drift alert triggered: escalate to the data science lead within 4 hours, assess retraining
need versus false positive, document the decision.
3. LLM offer generator producing off-brand content: revert to template defaults, alert the mar-
keting team, investigate prompt conﬁguration and input ﬁltering.
4. Rollback trigger activated: execute rollback to the RFM baseline within 2 hours; post-mortem
required within 48 hours.
5. Vendor LLM API outage: switch to template-default offer generation, alert the marketing
team, no prediction pipeline impact.
Operational Handoff Package: Delivered to the marketing analytics team and the engineering on-
call rotation. Includes the Model Card, Data Cards, architecture diagram, runbooks, monitoring
dashboard links, alert threshold documentation, rollback trigger list, escalation contacts, inference
cost baseline, and vendor governance notes.
17.12.8 Stage 8: Monitor
Steady-state operations:
• Retraining policy: Quarterly retraining on 18 months of data, chosen to cover 1.5 seasonal
cycles while excluding data older than 18 months that may reﬂect materially different con-
sumer patterns. Earlier retraining triggers if a PSI alert ﬁres on a core feature, if the 90-day
proxy churn rate in the AI-targeted cohort diverges from the model prediction by more than 3
percentage points for two consecutive weeks, or if the 55+ segment performance gap exceeds
10 points.
• Seasonal risk windows: The post-holiday return period (January) and the back-to-school
season (August) are documented as high-drift windows. The monitoring team adds weekly
reviews during these periods and pre-schedules a post-holiday model evaluation.
90-day results (after full rollout):
• 90-day proxy churn rate in the AI-targeted cohort: 18.4% versus 21.7% in the RFM baseline
cohort (down 3.3 points, meeting the 120-day leading indicator threshold)
• Offer redemption rate: 14.2% in the AI-targeted cohort versus 9.7% in the RFM baseline
• Incremental retained revenue estimate: $4.1M annualized (tracking correctly at the 4-month
mark toward the $12M annual target)
• Inference cost: $28,000/month, within the $40,000 ceiling
• 55+ segment performance gap: 5 points, within threshold, monitoring continues
Iteration backlog (top 3 items):
1. Mobile app behavioral data integration, pending legal access approval, expected to close the
store-primary member performance gap.
2. Uplift modeling workstream. 6 months of offer-response data are now accumulating, and
the workstream begins in the next planning cycle.
31

<!-- page 32 -->
3. Offer timing optimization: test sending at different times of day and week rather than a
uniform Tuesday morning send.
This use case continues in later chapters. Chapter 18 (Platform Architecture) will design the infrastructure
that supports this pipeline at scale. Chapter 19 (Data Engineering) will detail the feature store and data
pipeline architecture. Follow the NorthStar thread across Part 3 and Part 4 to see how the pieces connect.
17.13 Key Takeaways
1. AI development is not software development with a model bolted on. Probabilistic outputs,
data-shaped behavior, temporal degradation, and inherent experimentation call for a lifecy-
cle designed around those properties rather than adapted from the SDLC.
2. Stage 1 (Deﬁne Problem) of the Build lifecycle validates and translates. It is not the original
business framing. Strategy and Design create the problem statement; Stage 1 conﬁrms it is
speciﬁc enough to build against.
3. Stage gates prevent premature progression. Gate theater, where gates pass regardless of cri-
teria because the schedule requires it, is the most common failure mode in enterprise AI
development.
4. Excluding protected attributes from features is not a fairness evaluation. Fairness requires
proxy analysis, slice-based testing, and documented methodology, and it belongs in the Stage
4 evaluation framework rather than bolted on in Stage 6.
5. Deployment is where the operational loop starts, not where the work ends. A system de-
ployed without monitoring, retraining triggers, and rollback criteria is incomplete by design.
6. Lifecycle rigor should scale with risk. A low-stakes internal analytics tool does not need the
same gate overhead as a regulated decision system. Calibrate to consequence, not ambition.
7. The lifecycle has to account for the human side of the system. Organizational adoption, au-
tomation bias, workﬂow integration, and frontline user behavior are operational risks as real
as model drift.
17.14 Apply It
1. AI Project Charter Using the NorthStar Retail scenario as your model, write a complete AI
Project Charter for a different retail AI use case: a product recommendation system for the e-
commerce platform. The charter has to include (a) the business problem in decision terms, not
technology terms; (b) three speciﬁc, measurable success metrics; (c) the data dependencies and
their availability status; (d) the go/no-go criteria for the Stage 1 gate; and (e) the stakeholder ac-
countabilities for each gate. Use the template structure in the EAIE Templates folder. <–FIX–>
2. Data Readiness Assessment For the NorthStar churn use case, extend the Data Readiness As-
sessment. Add two potential external data sources, choosing from weather data by store location,
local unemployment rate by zip code, social media sentiment from a third-party vendor, or com-
petitor promotional calendar from a market intelligence provider. For each, assess the potential
value to the model, the likely data quality, the access and governance complexity, and the impli-
cations for label quality. Make a recommendation (include or defer) and justify it.
3. Gate Criteria Design For each of the eight AISDLC stages, write one explicit, measurable, binary
pass/fail criterion. Not a question, but a statement that is either true or false. Then assign an
owner for each gate who is independent of the team doing the work. Example: Stage 2 is met when
32

<!-- page 33 -->
the transaction history covers at least 24 months and has fewer than 5% missing values across the 12 ﬁelds
required for feature computation, as conﬁrmed by an automated data quality scan and signed off by the data
engineering lead. Design all eight. Then assign risk tiers to three hypothetical systems and describe
how the gate criteria would differ across tiers.
4. Fairness by Design Using the NorthStar Stage 6 fairness review as a starting point, design a
complete fairness evaluation methodology for the churn model. Deﬁne (a) the demographic di-
mensions you would analyze, including potential proxy attributes even when protected attributes
are excluded; (b) the speciﬁc metrics and thresholds that deﬁne acceptable parity; (c) the gover-
nance process for accessing protected attribute data under controlled conditions; (d) the escalation
path if a disparity is found but cannot be resolved before the launch deadline. Compare your
methodology to the “exclude protected attributes, and there is no bias” approach that this chapter
rejects.
5. AI Prompt Exercise Use this prompt with a capable LLM of your choice:
“You are an AI project manager conducting a Stage 6 gate review for the NorthStar Retail churn prediction
system. The team is requesting approval to deploy to production. Review the evaluation ﬁndings below and
identify: (1) the three most signiﬁcant risks that warrant a conditional pass or a hold; (2) the speciﬁc condi-
tions that must be met before each risk is acceptable; (3) any risks the team appears to have underweighted,
including organizational or human-side risks not in the technical validation. [Paste the NorthStar Stage 6
ﬁndings from this chapter].”
Compare the model’s risk identiﬁcation to your own assessment. Note where the model caught
something you missed and where your judgment differed. Pay particular attention to whether the
model identiﬁed the fairness gaps and the rollback-criteria issues.
17.15 What’s Next
The AISDLC deﬁnes what needs to happen and in what order. The next chapter addresses where
it happens: the AI platform and cloud infrastructure that provides the compute, storage, orches-
tration, and tooling every stage of the lifecycle depends on.
Platform decisions made early have long-term consequences. The choice of serving infrastructure
determines which deployment strategies are available to you. The choice of experiment tracking
tooling determines what can be reproduced and audited. The choice of monitoring stack deter-
mines how much visibility you have into production. None of these can be delegated to an ops
team. They are product decisions that the team building the AI system has to make deliberately
and early, with a clear view of their downstream implications.
Chapter 18 provides the reference architecture options and the decision framework for choosing
among them. The NorthStar Retail system will be the concrete example that makes those architec-
tural choices tangible.
17.16 References
Angwin, Julia, Jeff Larson, Surya Mattu, and Lauren Kirchner. 2016. Machine Bias. Https://www.propublica.org/article/machine-
bias-risk-assessments-in-criminal-sentencing; ProPublica.
33

<!-- page 34 -->
Breck, Eric, Shanqing Cai, Eric Nielsen, Michael Salib, and D. Sculley. 2017. “The ML Test Score:
A Rubric for ML Production Readiness and Technical Debt Reduction.” 2017 IEEE International
Conference on Big Data (Big Data), 1123–32.
Dastin, Jeffrey. 2018. Amazon Scraps Secret AI Recruiting Tool That Showed Bias Against Women.
Https://www.reuters.com/article/us-amazon-com-jobs-automation-insight/amazon-scraps-
secret-ai-recruiting-tool-that-showed-bias-against-women-idUSKCN1MK08G.
Daugherty, Paul R., and H. James Wilson. 2018. Human + Machine: Reimagining Work in the Age of
AI. Harvard Business Review Press.
Davenport, Thomas H., and Rajeev Ronanki. 2018. “Artiﬁcial Intelligence for the Real World.”
Harvard Business Review, January.
Deliver High-Quality AI, Fast. n.d. Standard.
Gartner Research. 2025. “Gartner Predicts Organizations Will Abandon 60\% of AI Projects Due
to Lack of AI-Ready Data.” Gartner Advisory & Predictive Frameworks.
Kennedy, Brandon and Welburn, Jonathan W. and O’Mahony, Angela and Schwindt, Robert and
Marler. 2024. The Root Causes of Failure for Artiﬁcial Intelligence Projects. Research {{Report}} Nos.
RRA2680-1. RAND Corporation.
Margaret Mitchell, Simone Wu, Andrew Zaldivar, Parker Barnes, Lucy Vasserman, Ben Hutchin-
son, Elena Spitzer, Inioluwa Deborah Raji, and Timnit Gebru. n.d. “Model Cards for Model Re-
porting.” Proceedings of the 2019 Conference on Fairness, Accountability, and Transparency (FAccT),
220–29. https://doi.org/10.1145/3287560.3287596.
MIT Project NANDA. 2025. The GenAI Divide: State of AI in Business 2025. Massachusetts Institute
of Technology.
National Institute of Standards and Technology. 2023. Artiﬁcial Intelligence Risk Management Frame-
work (AI RMF 1.0). National Institute of Standards and Technology (NIST). https://doi.org/10
.6028/NIST.AI.100-1.
O’Neil, Cathy. 2016. Weapons of Math Destruction: How Big Data Increases Inequality and Threatens
Democracy. Crown.
Sculley, D., Gary Holt, Daniel Golovin, et al. 2015. “Hidden Technical Debt in Machine Learning
Systems.” Advances in Neural Information Processing Systems (NeurIPS) 28: 2503–11.
Weights and Biases. n.d. CoreWeave.
Yurdakul, Bilal, and Joshua Naranjo. 2020. “Statistical Properties of the Population Stability Index.”
Journal of Risk Model Validation 14 (4): 89–100. https://doi.org/10.21314/JRMV.2020.227.
34