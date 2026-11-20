# Ch23-Continuous-Delivery.pdf (extracted text, 35 pages)

<!-- page 1 -->
Chapter 23
XOps and Continuous Delivery:
Automating the Path From Commit to
Production
23.1 Motivation
A team builds a strong churn prediction model. The work takes three months of data engineering,
two weeks of feature selection, a dozen training runs, and careful evaluation against a holdout set.
The model reaches an AUC-ROC of 0.84, against a production baseline of 0.76. The data science
lead signs off, then the product owner. The model is ready to ship. Then it sits.
Deployment takes three weeks. Someone packages the model artifact by hand and opens a change
request ticket. The team waits for the infrastructure group to provision a serving endpoint, then
works out network access rules with security. Integration tests run by hand in a shared staging
environment, and the cutover lands in the next free 2 a.m. maintenance window. Every model
update repeats the whole sequence.
Meanwhile, the software engineering team ships code a dozen times a day. A developer ﬁxes a
bug, opens a pull request, gets an automated test report in eight minutes, and merges. The ﬁx is
in production before the next stand-up. Nobody on that team thinks about deployment.
The three-week delay is what people see. The higher cost arrives later. When a model starts failing
in production, nobody can say which version is running, what data trained it, or who approved
it. Rolling back takes hours of manual work, assuming a rollback path exists at all. Meanwhile
customer behavior shifts, the model drifts, and the business runs on stale intelligence for months.
The data scientists know how to build models. What the organization lacks is a way to operate
them. In interviews with 18 ML engineers, production ML came across as a continuous cycle of
data collection, experimentation, evaluation, and monitoring, not a one-time deployment (Shankar
et al. 2022). A team that struggles to operate ﬁve models will struggle more with ten.
XOps is the engineering discipline that moves AI from artisanal practice to industrial practice.
It applies the core lessons of DevOps (automation, repeatability, observability, and continuous
delivery) to data pipelines, model training, foundation model systems, and autonomous agents.
Continuous integration and delivery pipelines put that discipline into practice, carrying a commit,
1

<!-- page 2 -->
a new dataset, or a drift signal to production with safety gates at every transition. This chapter
treats the practices and the pipelines together because each is useless without the other. Practices
with no pipeline behind them are a policy document nobody enforces, and a pipeline without the
practices ships ungoverned artifacts very efﬁciently.
23.2 Challenge
How do you operationalize AI across data pipelines, model training, LLM systems, and agents,
and build the integration and delivery pipelines that run those practices, so that changes move
from commit to production safely, automatically, and as fast as the business needs?
23.3 Objectives
By the end of this chapter, you will be able to:
1. Distinguish the four XOps disciplines and explain how each depends on the layer beneath it
2. Explain how delivering AI differs from delivering traditional software and what that requires
of the pipeline
3. Apply DataOps, MLOps, LLMOps, and AgentOps practices to data, models, prompts, and
agents
4. Design a CI pipeline that validates code, data, models, prompts, infrastructure, and agents
before integration
5. Design a CD pipeline that promotes immutable artifacts through staging to production with
automated validation and rollback
6. Measure delivery performance with DORA metrics and assess XOps maturity to decide what
to build next
23.4 Interface with Previous Chapters
This chapter turns the work of the earlier Build chapters into an automated, repeatable path to
production. It deﬁnes a few quality criteria of its own. Mostly, it encodes the criteria the earlier
chapters deﬁned and enforces them on every change.
• From Chapter 18 (AI Platform & Cloud Architecture): the model registry, experiment track-
ing, serving infrastructure, and Terraform module structure. The pipeline deploys into this
platform and promotes artifacts through this registry.
• From Chapter 19 (Data & Feature Engineering): data pipelines, data contracts, the feature
store, versioning, and the lineage graph. DataOps automates and monitors what that chapter
designed.
• From Chapter 20 (Model Development): training code, the experiment log, ﬁne-tuned
model artifacts, versioned prompts, RAG pipelines, and agent designs. The pipeline builds,
validates, and promotes these artifacts.
• From Chapter 21 (Security, Privacy & Compliance): the scanning rules, policy-as-code
checks, secrets handling requirements, and the security sign-off. The pipeline is how those
controls get enforced.
• From Chapter 22 (Testing and Evaluation): the testing hierarchy, evaluation thresholds, be-
havioral and safety test libraries, and production readiness criteria. Those thresholds become
2

<!-- page 3 -->
the pipeline’s automated gates.
This chapter produces the automated delivery path that Chapter 24 uses to release the system to
users. Deployment and Scaling decides how a release reaches trafﬁc (canary, blue/green, shadow,
or A/B) and how the system scales. This chapter builds the pipeline that carries out those decisions
and reverses them when they go wrong.
The retail organization from previous chapters now has three AI systems ready for production: a churn
model, an offer-generation system built on a ﬁne-tuned foundation model with RAG, and a customer-service
escalation agent. Whether AI works in this organization is settled. The open problem is operating all three so
that every run is reproducible and the operational burden doesn’t outgrow the business value as the portfolio
grows.
23.5 XOps: The Operational Foundation of Enterprise AI
DevOps changed software delivery by showing that the path from code to production (build, test,
integrate, deploy, monitor) could be automated, measured, and steadily improved. Before DevOps,
a software release was a quarterly, high-risk event run by release committees and war rooms. After
adoption, high performers deployed on demand, often several times a day, with lower failure rates
and faster recovery when something did fail (Forsgren et al. 2018). That improvement came from
operational discipline rather than from new technology.
XOps applies the same logic to AI. The “X” stands for a growing set of disciplines (DataOps,
MLOps, LLMOps, and AgentOps), each aimed at a different layer of the AI stack.
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
DataOps, MLOps, LLMOps, and AgentOps are complementary disciplines with overlapping prac-
tices and responsibilities. DataOps supports reliable data wherever it is used, including training,
retrieval, evaluation, and operational workﬂows. MLOps governs the development and opera-
tion of predictive models; LLMOps adapts shared practices such as versioning, evaluation gates,
and staged promotion to foundation models, prompts, and retrieval systems. AgentOps addresses
the additional challenges of tool use, stateful execution, and autonomous decisions, including per-
missions and oversight when actions have external consequences. These disciplines need not be
3

<!-- page 4 -->
Figure 23.1: XOps Disciplines and Shared Operational Foundation. DataOps, MLOps, LLMOps, and
AgentOps are complementary disciplines with overlapping responsibilities rather than a rigid hierarchy.
Each addresses distinct operational challenges while sharing practices such as version control, automated
testing, evaluation, monitoring, and governance. A common CI/CD foundation supports reliable, repeatable,
and controlled deployment across all four disciplines.
implemented in a ﬁxed sequence: their relationships depend on the system’s architecture. How-
ever, weaknesses can propagate through those relationships—for example, unreliable data can
undermine model quality unless validation detects the problem and prevents its downstream use.
Across these complementary disciplines, CI/CD provides a shared mechanism for putting opera-
tional requirements into practice. Each discipline deﬁnes its tests and release criteria, and the rel-
evant pipelines automate those checks at appropriate stages, reducing reliance on manual follow-
through. Versioned artifacts and recorded evaluation results connect development to controlled
deployment. For trained models, a model registry tracks candidate versions, their evaluation evi-
dence, and approval status; delivery pipelines deploy approved versions through staged environ-
ments. Data transformations, prompts, retrieval conﬁgurations, and agent policies follow similar
versioning and promotion practices through repositories suited to those artifacts.
The technical debt argument. XOps is more urgent than the phrase “good engineering practice”
suggests. Organizations that skip it pile up AI technical debt that compounds over time (Sculley et
al. 2015). Untested pipelines fail silently, unmonitored models degrade with no feedback, and un-
versioned prompts drift without anyone noticing. The cost of repair grows faster than the number
of systems and the time since anyone last enforced discipline. A company that builds ten models
without MLOps ends up with ten separate crises on ten separate timelines, and each one needs its
own forensics and manual repair when it surfaces.
The SRE connection. Site Reliability Engineering treats reliability as something teams engineer.
They set explicit performance targets, budget for acceptable error rates, and automate away opera-
tional toil (Betsy Beyer, Chris Jones, Jennifer Petoff, and Niall Richard Murphy 2016). XOps applies
the same principles to AI. Model performance targets set how far a model can degrade before re-
4

<!-- page 5 -->
training starts, and error budgets set how much deployment risk the team can take on in a given
period. ML systems also need indicators that classic services don’t, such as data freshness and
pipeline throughput (Saltonstall and Virji 2025). Chapter 28 develops these ideas for production
operations.
23.6 What’s Different About Delivering AI
Traditional CI/CD was built for application code. A code change triggers an automated build,
tests run, and artifacts that pass go to production. The system is deterministic: the same input
always produces the same output, so testing means checking that the output is correct. AI systems
complicate this in three ways.
Additional artifact types. An AI system contains more than code. Its data pipelines need vali-
dation for schema conformance and contract compliance. Its trained model artifacts have to clear
quality thresholds, which is a higher bar than loading and running. Systems built on large lan-
guage models add prompts and versioned artifacts that can regress or produce unsafe output when
someone edits them. Agent systems add tool registries, instruction sets, and memory conﬁgura-
tions that change independently of the model.
Table 23.2: CI/CD for AI: What’s Different — Artifact, Traditional CI/CD, AI CI/CD Addition.
Artifact Traditional CI/CD AI CI/CD Addition
Application code Tested and deployed Same
Data pipelines Not typically included Must be validated against
contracts and versioned
Trained models Not applicable Must be evaluated, registered,
and promoted
Prompts Not applicable Must be versioned,
regression-tested, and
deployed
Agent conﬁgurations Not applicable Must be validated for tool
availability and interaction
safety
Infrastructure Sometimes (IaC) Always; platform changes
need automated provisioning
Non-determinism. This is the central challenge. A function that returns the wrong value returns it
every time, so a test catches it reliably. A language model given the same prompt may produce dif-
ferent outputs on different runs, and a multi-agent workﬂow may take a different path depending
on intermediate results. CI for AI therefore tests for acceptable behavior within deﬁned bounds, because
correctness in the traditional sense can’t be pinned down. Does accuracy fall in the expected range? Do
outputs meet the safety criteria across the test suite? Does the agent ﬁnish in an acceptable number
of steps? Shifting from correctness testing to bounds testing changes both the testing philosophy
and the tools.
The pipeline-within-a-pipeline problem. AI pipelines routinely trigger other pipelines. Chang-
ing a feature extraction function triggers a data validation run. If the features change signiﬁcantly,
5

<!-- page 6 -->
that run may trigger retraining, which triggers an evaluation run, which may trigger a staging de-
ployment. Every sub-pipeline needs clear success and failure signals. The parent pipeline needs a
deﬁned escalation path for a failure at each level so that nothing gets silently abandoned.
Figure 23.2: AI CI/CD pipelines orchestrate chains of dependent sub-pipelines, requiring clear suc-
cess/failure signals at each transition.
23.7 DataOps: Automating the Data Foundation
Every model depends on two kinds of data: the data it was trained on and the data it receives
in production. When data goes wrong, a person and a model react very differently. A person
reading a dashboard can notice an odd number and investigate. A model can’t. It keeps applying
what it learned even after production data has drifted or been corrupted upstream, so its errors
stay silent until they become costly. Chapter 19 designed the pipelines, data contracts, feature
store, and lineage tracking that guard against this. DataOps keeps those safeguards reliable over
time by applying the practices of software operations (automation, testing, version control, and
observability) to data pipelines.
23.7.1 Pipeline Automation and Orchestration
The basic rule of DataOps is that no production data pipeline depends on someone remembering
to run it. Production pipelines run under an orchestrator, on a schedule or an event trigger, and
the orchestrator resolves dependencies, retries automatically, and raises alerts on failure.
Apache Airﬂow is still the most widely used enterprise orchestrator for batch data and ML
pipelines, and Amazon Managed Workﬂows for Apache Airﬂow (MWAA) runs it as a managed
service on AWS. Prefect and Dagster offer simpler authoring for smaller teams. The platform mat-
ters less than what the orchestrator enforces: data contracts, quality gates, and alerting thresholds.
6

<!-- page 7 -->
A plain Airﬂow pipeline with quality gates is worth more than a sophisticated platform running
pipelines without them.
23.7.2 Inline Quality Gates and Contract Enforcement
dbt (data build tool) has become the de facto standard for testing SQL transformations. Its test
framework checks schema expectations, uniqueness constraints, null rates, and referential integrity
on every run. Because the tests live next to the transformation code, nobody can skip them the way
a separate QA step often gets skipped under time pressure. Great Expectations handles statistical
assertions that dbt doesn’t cover natively, and AWS Glue Data Quality offers comparable checks
inside Glue ETL jobs.
The important choice is whether tests run inside the pipeline or after it. Testing after the fact helps
with monitoring, but by then bad data has already spread. Inline quality gates stop the pipeline as
soon as they detect a violation, so a null-rate spike or a schema change never reaches the training
dataset.
Data contracts are where this pays off most. The contract designed in Chapter 19 is a versioned
agreement between the team that publishes a dataset and the teams whose pipelines and models
consume it, and DataOps is what actually enforces it. Without enforcement, an upstream schema
change spreads unnoticed until a model starts producing wrong predictions. With enforcement,
the pipeline fails at contract validation, and both the root cause and the owning team are visible
right away. Every training run is also tied to an immutable data snapshot, using DVC or the ver-
sioning approach from Chapter 19, so any model in the registry can be traced back to the exact
data it learned from.
Figure 23.3: DataOps pipelines enforce quality gates inline, halting data propagation when contracts are
violated rather than detecting problems after corruption reaches downstream systems.
23.7.3 Data Observability
Passing quality tests at runtime is necessary but not enough, because production data changes
between runs. Transaction volumes spike during promotions, upstream systems emit unexpected
formats after third-party updates, and reference tables change without warning. Data observability
brings the monitoring practices of production services to data pipelines.
7

<!-- page 8 -->
Commercial data observability platforms such as Monte Carlo and Anomalo learn normal patterns
in freshness, volume, schema, and value distributions, then alert when data departs from them.
They also use lineage to trace a problem back to its source. On AWS, Glue Data Quality offers sim-
ilar checks natively, combining rule-based validation with ML-based anomaly detection. Amazon
DataZone (presented as SageMaker Catalog in SageMaker Uniﬁed Studio) is a different kind of
tool: it handles cataloging, discovery, and governance, and displays the resulting quality scores
and lineage. CloudWatch metrics and alarms provide a minimal alternative, but only for metrics
your pipelines publish, and they require more engineering effort with little automated root-cause
analysis.
23.8 MLOps: Automating the Model Lifecycle
MLOps brings the same automation to model training, evaluation, and promotion. In the target
state, a data change or a scheduled trigger starts training, and the trained model goes through
automated evaluation gates. An approved model enters a governed registry and moves through a
deﬁned promotion workﬂow, with monitoring running from day one. Every step from data change
to production model is automated and auditable, and any of them can be reversed.
23.8.1 Training Automation
Training pipelines should be code. Notebooks are for exploration. Production training runs in
parameterized pipelines where dataset versions, hyperparameters, and evaluation thresholds are
explicit inputs, so nobody edits values by hand before pressing run. SageMaker Pipelines runs
preprocessing, training, evaluation, and registration as a reproducible DAG deﬁned in code and
stored in version control. Each step logs its parameters, metrics, and artifacts to SageMaker’s
managed MLﬂow, and models registered there sync to the SageMaker Model Registry. Together,
these produce a provenance record that links each deployed model to the data, conﬁguration, and
evaluation that produced it.
This follows the most durable principle in production ML: get reliable results through disciplined
engineering before you try for heroic results through clever modeling (Zinkevich 2017). Auto-
mated training pipelines are unglamorous, and everything downstream depends on them. They
read from the feature store designed in Chapter 19, which keeps training and serving consistent.
23.8.2 Evaluation Gates
A model enters the registry only after it passes automated evaluation criteria. Those criteria live in
code, where schedule pressure can’t move the bar the way it can in a committee review. Chapter
22 deﬁnes what the gate checks: accuracy or AUC above a threshold, no regression against the
current production model on the holdout set, performance ﬂoors for each slice, and fairness checks.
MLOps makes those checks run on every training run without exception. The ML Test Score rubric
(Breck et al. 2017) is an example of a useful audit of whether the gate is complete. Its 28 tests span
four areas: features and data, model development, ML infrastructure, and monitoring. A system’s
overall score is the lowest of its four area scores, so a strong deployment gate can’t make up for
weak data validation or missing monitoring.
Responsible AI checks belong inside the gate as a named, automated step that runs with the tech-
nical evaluation, instead of in a governance review afterward. A model that meets its accuracy
8

<!-- page 9 -->
thresholds but fails a SageMaker Clarify fairness evaluation does not get promoted. With the check
in the pipeline, engineering owns it, and nobody can postpone it as the deadline gets closer.
23.8.3 Model Registry and Continuous Training
The model registry is the governance layer between experimentation and production. It answers
the auditor’s question: which model made this decision, what data trained it, when it was de-
ployed, and who approved it. A model that passes every gate enters the registry in a pending
state and waits for human review and explicit approval. Approved models become eligible for re-
lease. The previous production model is archived rather than deleted, so it can be restored within
minutes if the new one fails under live load.
Google’s MLOps reference separates three automations that are easy to confuse. Continuous in-
tegration tests and validates code, data, and models. Continuous delivery deploys the trained
model and its serving pipeline. Continuous training retrains models automatically in production
(Kazmierczak et al. 2024). Traditional software has no equivalent of continuous training: it retrains
a model when drift crosses a threshold, or performance falls past a set tolerance, without waiting
for someone to notice. Drift detection tools such as Evidently supply the trigger; Chapter 27 covers
them in depth.
Netﬂix improved recommendation quality through exactly this routine discipline, retraining on
fresh behavioral data and A/B testing every change before full rollout (Gomez-Uribe and Hunt
2015). Uber’s Michelangelo showed the same effect across a portfolio: a shared feature store, stan-
dardized training, and automated evaluation gates let hundreds of production models run on com-
mon infrastructure (Jeremy Hermann and Mike Del Balso 2017).
Figure 23.4: The MLOps pipeline automates the path from training trigger to production deployment
through explicit evaluation gates and staged promotion with preserved rollback paths.
23.9 LLMOps: Operational Discipline for Foundation Model Systems
LLMOps extends MLOps to systems built on a model you didn’t train. Several MLOps assump-
tions break in that setting: deterministic outputs, evaluation by a single scalar metric, and full
9

<!-- page 10 -->
control over the model. Aryan puts it bluntly. Traditional MLOps falls apart when it is applied to
generative AI without changes (Aryan 2025).
Figure 23.5: LLMOps differs structurally from MLOps in artifact type, cost proﬁle, evaluation approach,
and version control, requiring distinct operational practices.
In MLOps, the main artifact is a large binary you trained on your own data and deployed under
your own control. In LLMOps, you usually call a foundation model through an API, ﬁne-tune
one, or deploy an open-weight model someone else trained, and the artifacts you manage most
are prompts and conﬁgurations: small in bytes, large in behavioral impact. Four differences shape
the discipline.
The artifact is often a prompt, not weights. In a 2025 study of production agents, 70% relied on
prompting existing models rather than ﬁne-tuning (Pan et al. 2025). An unversioned prompt is an
uncontrolled variable: anyone with repository access can change it, nobody can audit its effects,
and regressions stay hidden until users complain.
Cost is a ﬁrst-class engineering constraint. LLM inference is expensive at volume. A system
handling 10,000 interactions a day with a 2,000-token system prompt and 500-token responses
consumes 25 million tokens daily. Without per-request cost tracking, nobody can tell whether it
pays for itself. Chapter 29 covers LLM economics.
Evaluation is structurally harder. Natural-language output doesn’t reduce to one number; a
threshold won’t catch a response that is accurate but wrongly toned. Chapter 22 covers the meth-
ods (RAGAS, LLM-as-judge, human evaluation). LLMOps runs them automatically on every
change.
Foundation model versions are not under your control. Providers update models on their own
10

<!-- page 11 -->
schedule, and an update that raises average benchmark scores can still degrade the tasks your
application depends on.
23.9.1 Prompt Management: Prompts Are Code
Production prompts follow the software development lifecycle: author with evaluation tooling
at hand, commit with a message describing the intended change, peer review, run the regression
suite, validate in staging, promote on explicit approval, monitor with quality alerts, and roll back
by redeploying the previous commit.
Figure 23.6: Production prompts follow a software development lifecycle with version control, automated
evaluation, staged deployment, and documented rollback procedures.
Every production prompt should carry four operational properties:
• A version tag linked to a speciﬁc git commit, so that any production inference can be repro-
duced exactly from the prompt version, the foundation model version, and the input
• A regression evaluation suite covering expected outputs, behavioral edge cases, refusal cases,
and output format validation
• Production trace logging that records latency, token consumption, and output quality signals
on every inference
• A documented rollback procedure, in which redeploying the previous commit restores the
previous behavior with no model change
Versioning earns its keep when quality drops. Lining up prompt diffs against quality metrics
shows which change caused a regression, and the team can roll back to the last stable version
in minutes (Aryan 2025). LangSmith and Langfuse are leading platforms for prompt tracing and
11

<!-- page 12 -->
evaluation. On AWS, Amazon Bedrock model invocation logging records prompts, responses, and
metadata to CloudWatch Logs or S3 without code changes; application instrumentation adds what
the platform log leaves out, such as prompt version and business outcome.
23.9.2 Foundation Model Version Pinning
Many providers offer pinned version identiﬁers that point to a speciﬁc model snapshot instead
of the rolling latest. Pins differ in how long they stay available, so treat deprecation notices as
migrations to schedule. Pinning is the only reliable defense against silent behavior changes when
a provider updates its models.
Upgrading works like champion-challenger promotion. Run the full prompt regression suite
against the new version while the pinned version stays in production. If it matches or beats the
current version on every critical metric, schedule the cutover and update the pin; if it regresses,
hold the migration and decide whether prompt adjustments can close the gap. Every inference
trace should record model version, prompt version, input hash, output, latency, and token
counts: a compliance requirement in regulated industries and the basis of post-incident analysis
everywhere.
23.9.3 LLM Gateway Pattern
Figure 23.7: The LLM gateway pattern centralizes model routing, cost allocation, and logging across all
foundation model consumers in the organization.
12

<!-- page 13 -->
At scale, LLM infrastructure beneﬁts from a centralized gateway, a proxy layer between applica-
tions and foundation model APIs. It provides:
• Uniﬁed API surface: one endpoint that routes to Anthropic, OpenAI, Amazon Bedrock, or
Google Vertex AI by policy, so models can be swapped without touching application code.
• Rate limiting and cost allocation: per-team token budgets enforced centrally, with graceful
degradation instead of uncontrolled overage.
• Centralized logging: a complete audit record, even for applications not built with observ-
ability in mind.
• Routing by task complexity: cheap models for simple, high-volume tasks and capable mod-
els for complex reasoning, adjustable without redeployment.
LiteLLM is a widely used open-source gateway; Portkey and Helicone are hosted alternatives.
Amazon Bedrock provides multi-model access natively, and Bedrock Guardrails add content ﬁl-
tering, PII detection, topic denial, and grounding checks that stay in force whichever model version
is deployed.
23.9.4 Cost Controls
Three practices put cost control in place from the ﬁrst production deployment.
Per-request cost tracking estimates the cost of every inference from token pricing and the token
counts in the trace. Track cost per successful output, because refusals and retries make a system
more expensive than its per-request ﬁgures suggest.
Prompt compression shrinks system prompts. Cutting a 2,400-token prompt to 1,400 tokens low-
ers the cost of every inference by 42%. A shorter prompt can still shift safety or refusal behavior,
so it goes through the same regression suite as any other prompt change.
Semantic caching returns a stored response when a new query is close to one already answered. It
can cut cost substantially for workloads with many repeated questions, such as customer service
and internal knowledge bases, but hit rates vary widely by workload, so measure them on your
own trafﬁc before counting on the savings. A cache also needs expiry rules so it doesn’t serve stale
answers, and it must be scoped so that one user’s personalized response never reaches another.
23.10 AgentOps: Governance for Systems That Act
Agent systems add an operational concern that MLOps and LLMOps don’t cover: production
systems that carry out sequences of actions with effects outside the system. A model’s output is a
prediction. An agent’s output is an action, and an agent that sends the wrong email, edits the wrong
record, or starts an unauthorized transaction has caused a real-world consequence. Rolling back
a model deployment restores the previous behavior, while undoing an agent’s actions can mean
contacting customers, reversing transactions, or ﬁling a regulatory disclosure. The operational
discipline an agent needs grows with the consequences of what it can do.
23.10.1 Full Action Tracing
The minimum observability requirement for any production agent is a complete, structured trace
of every run. The trace must capture:
13

<!-- page 14 -->
• Task and session identiﬁers, so runs can be correlated across multi-agent systems and con-
versation turns
• Each step with a timestamp, recording the decision the agent made, the relevant state, and
any rationale summary the agent emits
• Each tool call, with the tool name, input arguments, output or error, and duration
• Policy and guardrail checks, with the result of each
• Human-in-the-loop events: what triggered the gate, who responded, when, what they de-
cided, and what context they were shown
• The ﬁnal outcome: success or failure, total steps, total tokens, and total cost
The trace records what the agent did and why it was allowed to do it. It doesn’t need the model’s
internal reasoning, which many providers don’t expose anyway. Without it, nobody can diag-
nose an agent failure, and in regulated industries it is the required audit record. OpenTeleme-
try’s GenAI semantic conventions deﬁne vendor-neutral spans for this: an invoke_agent span
contains a child chat span for each model call and an execute_tool span for each tool invoca-
tion (OpenTelemetry Authors 2026). The conventions are still at Development stability, so expect
instrumentation updates, but they make traces portable across CloudWatch, Grafana, Jaeger, and
other backends. Amazon Bedrock AgentCore Observability emits these traces to CloudWatch, and
AWS X-Ray links agent actions to the downstream service calls they trigger.
Traces contain prompts and responses, which puts them among the most sensitive data in the sys-
tem. The trace store needs its own PII scrubbing, retention limits, encryption, and access controls,
governed by the policies in Chapter 21.
23.10.2 Agent Regression Testing
Chapter 22 deﬁnes how to evaluate agents: task completion rate, step efﬁciency, tool call accuracy,
and safety behavior at authorization boundaries, all measured through simulation with mock tools.
AgentOps turns that evaluation into a regression gate. Before promotion, a representative scenario
suite runs against every change to agent code, prompts, or tool conﬁguration. The suite covers nor-
mal cases, edge cases, authorization boundaries, and adversarial inputs. A change does not ship
if it raises step counts without improving outcomes, or if it lets even one boundary case through.
Current practice still leans heavily on people. In one recent study, 74% of production agents relied
primarily on human evaluation (Pan et al. 2025). Automated scenario suites leave that review in
place and let reviewers spend their time on judgment calls, instead of rediscovering regressions a
script could have caught.
23.10.3 Reliability Patterns
Agent reliability engineering sets failure boundaries before deployment, before a production inci-
dent forces the issue. The arithmetic explains why. If each step succeeds 95% of the time, a ten-step
run succeeds only about 60% of the time (0.95^10 ≈ 0.60). Production teams keep runs short. In
the same study, 68% of production agents executed at most 10 steps before human intervention,
and teams handled reliability mainly through system design rather than model choice (Pan et al.
2025).
Timeout and step limits put hard caps on wall-clock time and step count for each run. An agent
that reaches its limit returns a structured failure along with its partial trace, and it stops consuming
14

<!-- page 15 -->
Figure 23.8: Complete action tracing captures every reasoning step, tool call, and human decision point,
providing the audit trail required for agent governance and post-incident analysis.
15

<!-- page 16 -->
Figure 23.9: AgentOps reliability patterns deﬁne failure boundaries enforced by the execution layer, ensuring
graceful degradation before resources are exhausted or unauthorized actions are taken.
16

<!-- page 17 -->
resources. With the wait-for-callback pattern in AWS Step Functions, a long-running workﬂow can
pause at a human approval gate without using compute while it waits.
Cost limits set a maximum token budget for each run, enforced at the execution layer. When
consumption nears the ceiling, the agent returns a partial result and a cost summary and stops
before it spends more than it was authorized to spend.
Circuit breakers stop an agent from calling a tool that keeps failing. A tool that has failed three
times in a row almost certainly has a structural problem that a human needs to diagnose, so the
agent escalates immediately instead of burning through the retry budget.
Tool permissions limit how much damage a mistake can do. Each tool runs with scoped, least-
privilege credentials. Read-only tools are kept apart from tools that write. Any action that can’t be
reversed requires approval before it executes. Chapter 21 deﬁnes these controls, and the pipeline
checks that every deployed agent conﬁguration complies with them.
23.10.4 Human-in-the-Loop Operations
Human oversight gates belong in the agent architecture from the ﬁrst production deployment. A
team that adds them after a consequential failure has added them too late. Each gate needs three
decisions made in advance: what triggers it, who gets the approval request and through what
channel, and what happens if nobody responds in time. These gates connect to the enterprise
accountability structures described in Chapter 25.
23.11 The Continuous Integration Pipeline
The four disciplines deﬁne what has to be checked; the integration and delivery pipelines run the
checks. DataOps contracts, MLOps evaluation gates, LLMOps regression suites, and AgentOps
scenario tests each become a stage every change must pass, so following the practices no longer
depends on anyone’s memory.
The CI pipeline keeps defective changes off the main branch by validating six categories of artifacts
against criteria deﬁned elsewhere in this book: code standards, the data contracts from Chapter 19,
the evaluation thresholds from Chapter 22, and the security policies from Chapter 21. Not every
check can run on every pull request, though. Full training runs and agent simulations take hours,
and running them on every commit would push developers to work around the pipeline. Place
each check where its speed and cost ﬁt:
• Pull request: fast checks and smoke tests that ﬁnish in minutes.
• Merge to main: larger integration tests and the full prompt regression suite.
• Nightly or on trigger: full training and evaluation.
• Promotion: the full agent scenario suite, load tests, and governance approvals.
• Production: health checks and business-metric validation.
23.11.1 Stage 1: Code Quality
Research code is often exploratory, undocumented, and untested. This stage enforces the move
to production quality. Linters and formatters such as Black and Ruff keep code readable under
debugging pressure. Static analysis (mypy, pyright) catches type errors, and security scanners
(bandit, Semgrep) ﬂag hardcoded credentials, unsafe deserialization, and injection risks under the
17

<!-- page 18 -->
Figure 23.10: The complete CI/CD pipeline for AI systems extends traditional software pipelines with spe-
cialized validation stages for data, models, prompts, and agents.
18

<!-- page 19 -->
rules from Chapter 21. Dependency scanning checks packages for known CVEs. Infrastructure-
free unit tests on transformations, features, preprocessing, and metric calculations tell a developer
within two minutes whether a change broke something basic, and an enforced coverage gate (80%
is a reasonable ﬂoor for serving and pipeline code) keeps them honest.
23.11.2 Stage 2: Data Pipeline Validation
DataOps enforces contracts on every production run. This stage covers the other half of the prob-
lem by catching a code change that would break a contract before it merges (Sanderson et al. 2024).
Schema validation conﬁrms ﬁeld names, types, and nullability; a ﬁeld that quietly becomes nul-
lable won’t crash anything, but it will feed the model subtly wrong inputs. Contract tests conﬁrm
outputs still meet consumer needs: if the churn model expects days_since_last_purchase to be a
non-negative integer no greater than 365, a change that breaks that range fails here. A sample run
on 10,000 to 50,000 representative records catches logic errors in minutes. Lineage impact assess-
ment ﬂags changes to features other models consume, so downstream breakage surfaces in review
rather than after deployment (Sato et al. 2019).
23.11.3 Stage 3: Model Validation
This stage runs the MLOps evaluation gate on a proposed change rather than a scheduled retrain,
whenever a pull request touches training code, features, or model architecture. A training smoke
test on a small sample conﬁrms the code runs and produces an artifact; if training crashes on 1,000
records, it will crash on a million, and CI ﬁnds out in minutes instead of overnight.
When a full training run is feasible, usually at merge or overnight, the candidate is scored on
the holdout set against the registered production model using the thresholds from Chapter 22.
The regression tolerance must be explicit and revisited as the baseline improves: too tight blocks
real improvements, too loose lets degraded models through (Sato et al. 2019). Artifact validation
conﬁrms the model loads, stays within expected output ranges on ﬁxed edge-case inputs, and
meets latency requirements, catching failures such as NaN outputs that aggregate accuracy hides.
23.11.4 Stage 4: Prompt Validation
This stage runs the prompt regression suite whenever a pull request touches a prompt, system in-
struction, or template. Teams often under-invest here because they treat prompts as conﬁguration
rather than code. The suite scores outputs for correctness, completeness, and safety (Chang et al.
2024). Behavioral tests conﬁrm the prompt still refuses when it should, stays in scope, and handles
hostile input. Latency and cost tests catch a prompt that improves quality by producing longer,
more expensive responses, so the trade-off is decided before the merge rather than discovered in
the next bill.
Fixed thresholds aren’t enough on their own, because LLM quality often erodes in small steps that
never cross the ﬂoor. A gate at 0.80 won’t notice a drop from 0.91 to 0.86. Compare every candidate
against the last known-good release as well as the absolute threshold, and block on a meaningful
drop in either. That only works if the evaluation dataset is versioned with the prompt, and if the
judge model is pinned and spot-checked by humans, since a drifting judge moves scores even
when the prompt hasn’t changed. Set tolerances carefully: teams route around gates that block
routine improvements, and a bypassed gate protects nothing.
19

<!-- page 20 -->
23.11.5 Stage 5: Infrastructure Validation
Infrastructure changes go through the same CI process as application code. The Terraform plan
output introduced in Chapter 18 appears in the pull request, so a reviewer sees exactly what will
change and can catch a modiﬁed security group or a removed IAM permission before anyone
applies it. Policy checks with Open Policy Agent or Checkov enforce the controls speciﬁed in
Chapter 21, such as encryption at rest for training data and model artifacts, no public access to
serving endpoints, and least-privilege IAM. Automated cost estimation shows the monthly cost
impact of a change, such as moving to a new GPU instance type, before anyone approves it.
23.11.6 Stage 6: Agent Validation
Agents call external tools, keep state, and join multi-agent workﬂows, each of which brings failure
modes the earlier stages miss. This stage runs a fast subset of the AgentOps scenario suite on every
pull request; the full suite runs at promotion. Tool availability tests conﬁrm every registered tool
is reachable and returns correctly shaped responses. Interaction scenario tests check behavioral
properties rather than exact outputs (Liu et al. 2023): does the agent complete the task, use the
expected tools, stay in scope, and ﬁnish without looping? Multi-agent tests check handoffs, a
frequent failure point, and memory validation conﬁrms an updated memory index still returns
the expected content.
Figure 23.11: Agent validation requires a hierarchy of tests, from fast tool availability checks to comprehen-
sive multi-agent interaction scenarios.
CI tooling:
20

<!-- page 21 -->
• Pipeline orchestration: GitHub Actions, GitLab CI, Jenkins, AWS CodePipeline and Code-
Build
• AI-speciﬁc CI: DVC (data and model versioning in CI), CML (Continuous Machine Learning)
• LLM and prompt evaluation: LangSmith, Promptfoo, custom evaluation harnesses
• Agent evaluation: LangSmith tracing, AgentBench, custom scenario runners
• Container registry: every releasable CI run produces a versioned, immutable container image
23.12 The Continuous Delivery Pipeline
Once CI passes, the CD pipeline takes the validated artifact and automates its path to production.
Its gates let the team deploy often and at scale without taking on more risk, and they conﬁrm that
what passed CI still holds up in an environment closer to production.
23.12.1 Stage 1: Artifact Promotion
Validated artifacts are tagged and stored in registries. In the model registry, a model moves from
CI-validated to staging-eligible. A container image gets a semantic version tag plus the git commit
hash and goes to the container registry. The prompt registry records each prompt version’s hash
together with its test results.
Immutability is non-negotiable. Nobody modiﬁes a tagged artifact, and any change creates a new
version. That guarantees that production runs exactly what CI tested, not a copy someone edited
to ﬁx “just one small thing.” Artifact signing, through AWS Signer or Sigstore, gives cryptographic
proof that nothing was tampered with between CI and deployment, and build provenance records
and a software bill of materials show what went into each artifact. Signing matters most for model
artifacts, which someone can alter in ways functional tests won’t detect.
23.12.2 Stage 2: Staging Deployment
Staging answers one question: does this artifact behave correctly in a production-equivalent envi-
ronment under production-representative load?
The staging environment has to mirror production, with the same instance types, memory conﬁg-
uration, and feature pipeline version. Staging and production should be parameterized conﬁgura-
tions of the same Terraform modules. The only differences are parameters such as instance count,
replication, and trafﬁc routing, and the structure is identical. Integration tests run the full system
end to end with realistic data. Performance tests measure latency, throughput, and resource use
under expected load, and they catch the memory contention or connection-pool exhaustion that
appears at 1,000 requests per second and never at one.
23.12.3 Stage 3: Production Release
Once the staging gates and required approvals pass, the release itself is automated: people decide
whether to release, and the pipeline does the releasing. Manual steps add error and make deploy-
ments rarer and riskier than they need to be. Keep a documented break-glass path for emergencies,
and review every use of it.
The pipeline executes the release strategy chosen for the change (canary, blue/green, shadow, or
A/B, selected by risk as described in Chapter 24) and enforces its rollback thresholds. Every release
21

<!-- page 22 -->
is logged with what was deployed, when, from which pipeline run and commit, and who approved
it.
23.12.4 Stage 4: Post-Deployment Validation
A deployment counts as ﬁnished only once the running artifact is conﬁrmed healthy.
Automated health checks conﬁrm within minutes that the new version is serving within latency
bounds and returning well-formed outputs. Business metric monitoring watches downstream
KPIs for the ﬁrst hour, because a shifted prediction distribution can move conversion or reten-
tion before any technical metric degrades. Wherever metrics detect failure quickly and reliably,
automatic rollback should be the default. Manual rollback depends on someone being awake and
willing to make the call; automatic rollback depends only on thresholds set correctly in advance.
Rollback restores the artifact, not the world. Offers already sent, scores already consumed by a
campaign, and refunds an agent already issued remain after the model or prompt reverts. Plan
compensating actions in advance, make tools idempotent so retries don’t duplicate effects, and
use the trace to identify which customers a bad release touched.
Approval gates in CD. Not every deployment needs human approval, and requiring it for every
change defeats the purpose of automation. Set approval requirements in advance by artifact type
and risk tier. For example:
• Prompt changes that pass the full regression suite deploy automatically after staging.
• Model promotions that move the production baseline by more than ﬁve percentage points
need sign-off from the data science lead.
• Any deployment that affects a Tier 1 system needs governance board review.
• Every production release needs the security sign-off deﬁned in Chapter 21.
Approval gates should be asynchronous, so the pipeline waits for sign-off while the team keeps
working.
CD tooling:
• Deployment orchestration: ArgoCD, Spinnaker, Flux (GitOps), AWS CodeDeploy and Sage-
Maker deployment guardrails
• Artifact management: AWS ECR, SageMaker Model Registry, JFrog Artifactory
• Feature ﬂags: LaunchDarkly, Flagsmith, AWS AppConﬁg, to control which users see which
model or agent version without redeployment
23.12.5 Infrastructure and Conﬁguration as Code
The pipeline also has to keep the environment it deploys into consistent. Chapter 18 covers how
the platform is deﬁned in Terraform. Delivery adds four operational rules.
Every infrastructure change goes through the pipeline. A console-created endpoint isn’t version-
controlled, policy-checked, or reproducible during disaster recovery. CI runs terraform plan; CD
runs terraform apply through development, staging, and production with test gates between
them.
Drift detection runs on a schedule. A scheduled comparison against Terraform state catches direct
changes to production and raises an alert; mature pipelines remediate automatically.
22

<!-- page 23 -->
Conﬁguration and secrets are managed as code. Serving parameters, pipeline settings, and
prompt conﬁgurations are version-controlled and schema-validated. Secrets never appear in code,
conﬁguration, or logs; they are injected at runtime from AWS Secrets Manager or an equivalent
store, as Chapter 21 speciﬁes.
Git is the source of truth. In a GitOps workﬂow, an operator such as ArgoCD or Flux reconciles
production to the state declared in the repository, so the git history records every change and rolling
back is a git revert.
Figure 23.12: GitOps makes the git repository the authoritative source of truth, with automated operators
reconciling production state to declared state.
23.13 Measuring Delivery Performance and XOps Maturity
A pipeline is hard to manage without measurement, and the thing to measure is the delivery capa-
bility it provides. Those measurements create the feedback loop needed to improve it.
23.13.1 DORA Metrics Applied to AI
The DORA research program identiﬁed four metrics that predict software delivery performance
and organizational outcomes (Forsgren et al. 2018). They apply directly to models, prompts, and
agents (DORA (DevOps Research and Assessment) 2024), and leadership can read them without
any AI expertise.
23

<!-- page 24 -->
Deployment frequency measures how often a new model, prompt, or agent version reaches pro-
duction. For an AI system under active development, the target is at least once a week. Monthly
or quarterly deployment points to a manual bottleneck somewhere in the pipeline.
Lead time for changes measures the time from commit, or from a training trigger, to production.
Lead times measured in weeks usually come from approval queues, slow test suites, or environ-
ment provisioning. For routine changes, the target is hours.
Change failure rate measures the share of deployments that cause an incident or a rollback. A high
rate means the CI gates are missing defects or the release strategy lacks a safety margin. Below
15% is a reasonable target for most organizations; in DORA’s 2024 research, elite performers held
change failure rate to around 5% (DORA (DevOps Research and Assessment) 2024).
Mean time to restore (MTTR) measures how long recovery takes after a deployment causes an
incident, such as a degraded model, a prompt regression, or an agent failure. A fast MTTR depends
on preserved rollback paths and automatic rollback triggers. The target is under one hour.
Figure 23.13: The four DORA metrics provide a comprehensive view of pipeline health and delivery capabil-
ity.
Three AI-speciﬁc metrics add to DORA:
• Evaluation gate pass rate: the share of trained models that pass on the ﬁrst attempt. A
low rate points to unstable training, overly tight thresholds, or mismatched training and
evaluation data.
• Staging promotion rate: the share of staging deployments promoted to production. Fre-
24

<!-- page 25 -->
quent staging failures mean staging doesn’t mirror production, the tests are catching real
defects, or the tests are miscalibrated, and each needs a different ﬁx.
• Pipeline execution time: people skip a four-hour CI pipeline when a deadline is close, so
parallelizing the slowest stages pays off for every team.
All of these come from a log of every pipeline run (trigger, stage durations, results, artifacts, post-
deployment health). Without that log, judgments about pipeline health are anecdotal.
23.13.2 Building XOps Capability
The dependencies between the four disciplines give them a natural adoption order. Building them
in that order keeps operational debt from piling up between layers.
Figure 23.14: The XOps disciplines have a natural adoption sequence driven by dependencies; building out
of order creates operational debt that compounds as the portfolio scales.
Start with DataOps. Data quality problems corrupt everything downstream. Fixing bad data after
models have been trained, deployed, and built into business processes costs roughly ten times as
much as putting quality gates in place before the ﬁrst training run.
Add MLOps and the CI/CD backbone. Deﬁne evaluation gates before you train the ﬁrst produc-
tion model, and set up the registry workﬂow and the delivery pipeline before the ﬁrst deployment.
Google’s MLOps reference describes the same progression: automate the training pipeline ﬁrst,
then automate the CI/CD that builds, tests, and deploys the pipeline itself (Kazmierczak et al.
2024). Retroﬁtting MLOps onto a portfolio of ungoverned models, each with its own deployment
process and no rollback path, is a common and avoidable expense.
Layer in LLMOps. As foundation model applications reach production, put prompt versioning,
regression testing, and cost tracking in place right away. Don’t wait for the ﬁrst cost overrun or
behavior regression.
Implement AgentOps. No agent should reach production without action tracing and HITL gates.
A poorly governed model degrades over time. A poorly governed agent can take a visible, conse-
quential action on your organization’s behalf, possibly before any monitor ﬁres an alert.
Common adoption failures. The most frequent is tooling without process: buying an MLOps
platform and never deﬁning the gates and policies it was built to enforce. The second is process
25

<!-- page 26 -->
without automation: documented workﬂows run by hand that neither scale nor reproduce. The
third is XOps as a separate team, a platform group cut off from the data science and engineering
teams it serves.
23.13.3 XOps Maturity Model
Most enterprise AI organizations sit at Level 1 or 2, and their coverage varies by discipline. A team
with mature MLOps for traditional models may still be at Level 0 for LLMOps because its foun-
dation model applications are new. A single overall XOps level hides that. The useful diagnostic
asks which discipline is weakest and what level it has reached.
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
A team that deploys models monthly and needs hours to roll back works very differently from
one that deploys weekly and restores service in minutes. DORA metrics make that difference
measurable over time, and targeted investment in the weakest discipline is how a team closes it.
23.14 AWS Reference XOps Architecture
The consolidated AWS stack maps each discipline to speciﬁc services, grouped by the dependency
layer each one occupies. Terraform deﬁnes the whole stack, and AWS CDK is a workable alterna-
tive for teams that have standardized on it.
26

<!-- page 27 -->
Figure 23.15: Assessing maturity across all four XOps disciplines identiﬁes the weakest layer and guides
prioritization of operational investments.
Table 23.4: AWS Reference XOps Architecture — Capability, AWS Service, Common Alternatives.
Capability AWS Service Common Alternatives
Source control and CI GitHub Actions, or CodePipeline
with CodeBuild
GitLab CI, Jenkins
Infrastructure and policy
as code
Terraform with Checkov or OPA AWS CDK, Pulumi
Data orchestration and
quality
MWAA, Glue Data Quality,
DataZone
Airﬂow, Dagster, Great
Expectations
Dataset and artifact
storage
S3 with versioning and KMS
encryption, DVC
Azure Blob Storage, Google
Cloud Storage
Training pipelines and
tracking
SageMaker Pipelines, managed
MLﬂow
Kubeﬂow, Vertex AI Pipelines,
Azure ML
Model registry SageMaker Model Registry MLﬂow Model Registry, Vertex
AI Model Registry
Containers ECR with image scanning, AWS
Signer
Artifactory, Sigstore
Foundation models and
guardrails
Bedrock, Bedrock Guardrails Azure OpenAI, Vertex AI,
LiteLLM gateway
Prompt and
conﬁguration
deployment
Git prompt repository,
AppConﬁg
LangSmith, Langfuse
27

<!-- page 28 -->
Capability AWS Service Common Alternatives
Agent runtime and HITL
workﬂows
Bedrock AgentCore, Step
Functions, SQS, SNS
LangGraph, custom orchestration
Observability and
tracing
CloudWatch, X-Ray, AgentCore
Observability
Datadog, Grafana, Langfuse
Secrets, keys, and access Secrets Manager, KMS, IAM HashiCorp Vault
A change moves through the stack like this. A commit triggers CI in GitHub Actions or CodeBuild.
Validated containers go to ECR, and datasets and model artifacts go to versioned, KMS-encrypted
S3. SageMaker Pipelines trains and evaluates, then writes candidates to the Model Registry, where
approval changes their status. CD deploys approved artifacts through Terraform-managed staging
and production and pushes prompt and conﬁguration versions through AppConﬁg. CloudWatch
alarms on quality, cost, and latency drive automatic rollback. As a rule of thumb, MWAA runs
data DAGs, SageMaker Pipelines runs training because it integrates with the registry, and Step
Functions runs event-driven and human-approval workﬂows.
23.15 Real-World Case Study: Spotify’s Machine Learning Platform
(Hendrix)
Spotify runs one of the highest-trafﬁc recommendation systems in consumer technology. It built
its internal ML platform, Hendrix, to solve a problem any enterprise AI team will recognize: de-
ploying a new model took weeks instead of hours. Every team rebuilt its own deployment infras-
tructure, with custom pipelines, inconsistent evaluation standards, and manual deployment steps
repeated from project to project (Vohra and Seid 2023).
Hendrix standardized three things:
• Pipeline templates. Teams inherit a shared template that already includes code quality
checks, evaluation gates, and canary deployment logic, so they no longer rebuild common
stages.
• Evaluation standards. Every model is evaluated against the same metrics with the same
harness, and nobody negotiates the gate.
• Deployment automation. Canary deployment with automatic rollback is the default for ev-
ery model on the platform. Teams don’t have to conﬁgure it.
Deployment frequency for ML models went from monthly to several times a week, and lead time
for a new model went from weeks to hours (Vohra and Seid 2023). Teams that had spent engineer-
ing time maintaining deployment infrastructure moved that capacity to model quality.
People kept every decision they had before. Data scientists still set evaluation thresholds, and data
engineers still deﬁne pipeline contracts. Automation removed the change requests, maintenance
windows, and handoffs between those decisions and production. That is where XOps delivers its
value: the people who make decisions keep making them, with far less paperwork in the way.
28

<!-- page 29 -->
Figure 23.16: Layered AWS operating model for AI systems (2026), showing how DataOps produces gov-
erned data, MLOps manages model development and deployment, LLMOps governs foundation model usage,
and AgentOps monitors agent behavior and human-in-the-loop workﬂows
29

<!-- page 30 -->
23.16 Use Case: Retail Customer Acquisition and Retention
The retail system now has three AI components ready for production, each built and evaluated as
described in the previous chapters:
• The churn prediction model: XGBoost, scored nightly.
• The personalized offer-generation system: a LoRA ﬁne-tuned foundation model with RAG
over the product catalog.
• The customer-service escalation agent: a ReAct agent on Amazon Bedrock AgentCore.
This section shows how XOps practices and the delivery pipeline run all three.
DataOps. The nightly batch pipeline runs as an Amazon MWAA DAG that extracts data from
the CRM, the transaction system, and customer service logs. It retries automatically on transient
failures and raises a Sev-2 alert after two consecutive failures. Each source has an enforced data
contract:
• CRM: customer_id uniqueness enforced; email null rate ≤ 2%; loyalty_tier values con-
strained to {‘Bronze’, ‘Silver’, ‘Gold’, ‘Platinum’}; freshness SLA of 24 hours
• Transactions: transaction_id uniqueness; amount > 0; category values from a controlled vo-
cabulary; daily record count within 3 standard deviations of the 90-day average
• Service logs: case_id uniqueness; resolution_status from a controlled vocabulary; times-
tamps monotonically increasing within each customer session
A contract violation stops the pipeline and alerts the team that owns the source. Last quarter,
the product catalog team changed a category enumeration without notice. Contract validation
caught the change within minutes, before corrupted category data reached the recommendation
features. Training-ready datasets are versioned with DVC, and the version hashes are stored with
each model in the SageMaker Model Registry. When the churn model’s performance dropped
in early March, the team compared the data versions behind the January and March models and
traced the problem to drift in loyalty program data that lined up with the launch of a marketing
campaign.
MLOps. A SageMaker Pipeline retrains the churn model every week. It also retrains on demand
when drift monitoring ﬁnds PSI above 0.15 on any core feature. That is tighter than the common
0.2 rule of thumb (Yurdakul and Naranjo 2020), a threshold the team chose for this domain’s sea-
sonality and later revisited. A model must pass three gates before it enters the registry:
• AUC-ROC ≥ 0.82 on the temporal holdout, the threshold set in Chapter 20.
• No regression of more than 0.01 AUC-ROC against the production champion.
• A SageMaker Clarify evaluation with a demographic parity ratio ≥ 0.8 across customer
tenure segments.
Because tenure is a business segment and not a protected class, the Clarify check serves a business
purpose: it guards against the model writing off newer customers. It supplements the legally
relevant fairness review deﬁned in Chapter 21 and does not replace it. Models that pass all three
gates enter the registry as PendingApproval. The model owner reviews the evaluation artifacts,
including the Clarify report and the champion-challenger comparison, and either approves the
model or asks for changes.
LLMOps. The offer system’s system prompt, customer context template, and personalization in-
structions live as separate versioned ﬁles in the prompt repository. Every prompt pull request runs
30

<!-- page 31 -->
the 200-case regression suite deﬁned in Chapter 20, scored by a pinned LLM judge calibrated as de-
scribed in Chapter 22. If the composite score falls by more than two percentage points against the
last approved prompt version, the merge is blocked. The base foundation model under the LoRA
ﬁne-tune is pinned and re-evaluated every quarter. The latest evaluation found that a newer base
version raised relevance scores by 8% and token consumption by 15%. The team upgraded any-
way and offset the extra cost through prompt compression, which they re-ran against the full suite.
Each offer costs $0.017 against a $0.02 budget ceiling. CloudWatch alarms ﬁre at $0.018 as a warn-
ing and at $0.022 as critical, and the critical alarm triggers an automatic rollback to the previous
prompt version.
AgentOps. Every escalation agent invocation writes a structured trace to CloudWatch. The trace
records session and task identiﬁers, each step’s action and rationale summary, each tool call with
its inputs, outputs, and latency, human escalation events with the approver’s identity, and the ﬁnal
outcome and cost. Customer identiﬁers are masked before the trace is written. The execution layer
enforces four reliability constraints:
• A maximum of 8 tool calls per task.
• A 60-second timeout with graceful degradation.
• A $0.10 cost ceiling per escalation.
• A circuit breaker that hands the case to a human after 3 consecutive failures on any tool.
The agent’s tools are split into read-only and write-capable credentials. Refunds over $50 go into a
supervisor queue via SQS with a 4-hour response window. Account modiﬁcations need approval
within 2 hours, and fraud-ﬂagged accounts need human review before the agent does anything. If
nobody responds in time, the request escalates to a senior supervisor and raises a Sev-2 alert.
CI pipeline. Every pull request runs the six stages described earlier with retail-speciﬁc settings: an
80% coverage gate for serving code; schema checks and a 10,000-record ETL sample run for data; a
1,000-record training smoke test, with full holdout evaluation on merge; the 200-case offer regres-
sion suite plus a check that p95 latency stays under 800ms; terraform plan and Checkov scans;
and tool availability tests plus a 12-scenario agent smoke suite. The full 60-scenario simulation
suite from Chapter 22 runs at the promotion gate.
CD pipeline. Artifacts move through a staging environment built from the same Terraform mod-
ules as production. Integration tests send 1,000 real customer records from feature pipeline to
churn score to offer generation, and performance tests replay a full-size nightly batch and load-test
the offer endpoint at peak trafﬁc. The pipeline then runs the release plan from Chapter 24 for each
component and enforces its rollback triggers. For offers already sent under a rolled-back prompt,
the runbook uses the trace log to ﬁnd affected customers, and marketing decides whether to honor
or correct each offer. Infrastructure changes soak 24 hours in staging before the production apply,
and nightly drift detection pages the platform team about any diverged resource.
Operations dashboard and delivery targets. A single dashboard tracks the portfolio:
Table 23.5: Retail Operations Dashboard — System, Pipeline Health, Model/Prompt Version, Quality Met-
ric, Cost Metric.
System Pipeline Health Model/Prompt Version Quality Metric Cost Metric
Churn
Model
Weekly training v14 AUC: 0.84 $0.002/prediction
31

<!-- page 32 -->
System Pipeline Health Model/Prompt Version Quality Metric Cost Metric
Offer
Genera-
tor
Prompt
v2.3/1.7/3.1
LoRA ﬁne-tune on
pinned base
Relevance: 4.2/5 $0.017/offer
Escalation
Agent
Agent v2.1 AgentCore ReAct agent Completion: 94% $0.07/escalation
The team reviews DORA metrics every week against explicit targets:
Metric Target
Deployment frequency At least one churn model update per week;
prompt updates on demand (typically two to
three per week during active development)
Lead time Under 4 hours from merge to production for
code changes; under 24 hours for model
updates
Change failure rate Below 10% for model deployments; below 5%
for prompt deployments
MTTR Under 30 minutes when automatic rollback
handles the incident
With all of this in place, the team can update any component of the retail system on demand, with
safety gates matched to its risk, and nobody waits for a maintenance window.
23.17 Key Takeaways
• XOps moves AI from artisanal to industrial practice. Without it, growing the model portfolio
mostly grows operational debt.
• DataOps, MLOps, LLMOps, and AgentOps form a stack: each layer depends on the one
below, and weakness anywhere spreads upward. Start with DataOps.
• The disciplines deﬁne what to check; the CI/CD pipeline runs the checks on every change,
enforcing criteria deﬁned in earlier chapters. The model registry links training to delivery.
• CI for AI tests for acceptable behavior within bounds, not exact correctness. Place each check
by its speed and cost, and compare candidates against the last known-good release as well
as ﬁxed thresholds, because quality often erodes in small steps.
• Prompts, conﬁguration, and infrastructure are code, and every production artifact is im-
mutable. Automate rollback wherever failures are reliably detectable, and plan compensat-
ing actions for effects a rollback can’t undo.
• No agent reaches production without action tracing, step and cost limits, least-privilege tools,
and HITL gates. A poorly governed agent fails by acting, not by degrading quietly.
• Measure delivery with DORA metrics and judge maturity by the weakest discipline, since
an average hides it.
32

<!-- page 33 -->
23.18 Apply It
1. XOps Maturity and Delivery Baseline. Rate the retail system on the Level 0 to 4 matu-
rity model for each discipline and name the three highest-priority investments to bring the
weakest one to Level 2. Then deﬁne baseline DORA metrics for a team that deploys monthly
through a three-week manual process, the six-month target after implementing this chapter’s
pipeline, and the two bottlenecks you would remove ﬁrst.
2. CI Pipeline Design. Design the full CI pipeline for the retail churn model as a stage table.
For each stage, list what it tests, what counts as a pass or a fail, the tools it uses, and where it
runs (pull request, merge, nightly, or promotion).
3. LLMOps and CD Design. For the offer generation system, deﬁne:
• The prompt repository structure
• Five representative regression test cases
• The baseline the regression gate compares against, and how the evaluation dataset and
judge are versioned
• The model pinning and upgrade procedure
• The approach for monitoring cost per offer
• The CD path from a merged prompt change through staging, release, post-deployment
validation, and automatic rollback
4. AgentOps Design. For the escalation agent, deﬁne:
• Action-tracing requirements, including how sensitive data in traces is protected
• A tool permission matrix that separates read and write tools
• Five evaluation scenarios, including at least one authorization boundary test
• Per-run cost and step limits
• HITL gate deﬁnitions with triggers and response windows
5. AI Prompt. “You are an XOps architect reviewing the following AI delivery setup for a retail offer
generation system: the system prompt is edited directly in a conﬁguration ﬁle, there is no automated
evaluation, cost is monitored only through monthly billing reports, there is no production trace log-
ging, and deployments are manual. Identify the three highest-priority operational risks and recom-
mend speciﬁc practices, pipeline stages, and AWS services to address each: [describe your current
setup].”
23.19 What’s Next
The system now has an automated path to production. Every change is validated, every artifact
is immutable and traceable, and every release can be rolled back automatically. Three questions
remain open: how a release reaches users, how the system behaves at ten or a hundred times pilot
load, and how the organization takes ownership of it. Chapter 24 answers them. It covers choosing
a release strategy based on risk, building serving infrastructure that scales from pilot to enterprise,
designing for failure, preparing the organization to adopt the system, and handing it over cleanly
to the teams that will run it.
33

<!-- page 34 -->
23.20 References
Aryan, Abi. 2025. LLMOps: Managing Large Language Models in Production. O’Reilly Media.
Betsy Beyer, Chris Jones, Jennifer Petoff, and Niall Richard Murphy. 2016. Site Reliability Engineer-
ing: How Google Runs Production Systems. O’Reilly Media.
Breck, Eric, Shanqing Cai, Eric Nielsen, Michael Salib, and D. Sculley. 2017. “The ML Test Score:
A Rubric for ML Production Readiness and Technical Debt Reduction.” 2017 IEEE International
Conference on Big Data (Big Data), 1123–32.
Chang, Yupeng, Qiang, Yang, Xu Wang, et al. 2024. “A Survey on Evaluation of Large Language
Models.” ACM Transactions on Intelligent Systems and Technology, ahead of print. https://doi.or
g/10.1145/3641289.
DORA (DevOps Research and Assessment). 2024. DORA Accelerate State of DevOps Report 2024.
Google Cloud.
Forsgren, Nicole, Jez Humble, and Gene Kim. 2018. Accelerate: The Science of Lean Software and
DevOps: Building and Scaling High Performing Technology Organizations. IT Revolution Press.
Gomez-Uribe, Carlos A., and Neil Hunt. 2015. “The Netﬂix Recommender System: Algorithms,
Business Value, and Innovation.” ACM Transactions on Management Information Systems 6 (4):
1–19. https://doi.org/10.1145/2843948.
Jeremy Hermann and Mike Del Balso. 2017. “Meet Michelangelo: Uber’s Machine Learning Plat-
form.” In Uber Engineering Blog.
Kazmierczak, Jarek, Khalid Salama, and Valentin Huerta. 2024. MLOps: Continuous Delivery
and Automation Pipelines in Machine Learning. Https://cloud.google.com/architecture/mlops-
continuous-delivery-and-automation-pipelines-in-machine-learning; Google Cloud Architec-
ture Center.
Liu, Xiao, Hao Yu, Hanchen Zhang, et al. 2023. AgentBench: Evaluating LLMs as Agents. https:
//doi.org/10.48550/arXiv.2308.03688.
OpenTelemetry Authors. 2026. Semantic Conventions for Generative AI Agent Spans. Https://github.com/open-
telemetry/semantic-conventions-genai/blob/main/docs/gen-ai/gen-ai-agent-spans.md.
Pan, Melissa Z., Negar Arabzadeh, Riccardo Cogo, et al. 2025. Measuring Agents in Production.
https://doi.org/10.48550/arXiv.2512.04123.
Saltonstall, Max, and Salim Virji. 2025. An SRE’s Guide to Optimizing ML Systems with MLOps
Pipelines. Https://cloud.google.com/blog/products/devops-sre/applying-sre-principles-to-
your-mlops-pipelines; Google Cloud Blog.
Sanderson, Chad, Mark Freeman, and B. E. Schmidt. 2024. Data Contracts: Developing Production-
Grade Pipelines at Scale. O’Reilly Media.
34

<!-- page 35 -->
Sato, Danilo, Arif Wider, and Christoph Windheuser. 2019. Continuous Delivery for Machine Learn-
ing. Https://martinfowler.com/articles/cd4ml.html.
Sculley, D., Gary Holt, Daniel Golovin, et al. 2015. “Hidden Technical Debt in Machine Learning
Systems.” Advances in Neural Information Processing Systems (NeurIPS) 28: 2503–11.
Shankar, Shreya, Rolando Garcia, Joseph M. Hellerstein, and Aditya G. Parameswaran. 2022. Op-
erationalizing Machine Learning: An Interview Study.
Vohra, Divita, and Mike Seid. 2023. Empowering Traceable and Auditable ML in Production at Spo-
tify with Hendrix. Https://mlconf.com/sessions/empowering-traceable-and-auditable-ml-in-
production-at-spotify-with-hendrix/.
Yurdakul, Bilal, and Joshua Naranjo. 2020. “Statistical Properties of the Population Stability Index.”
Journal of Risk Model Validation 14 (4): 89–100. https://doi.org/10.21314/JRMV.2020.227.
Zinkevich, Martin. 2017. Rules of Machine Learning: Best Practices for ML Engineering.
Https://developers.google.com/machine-learning/guides/rules-of-ml; Google Develop-
ers.
35