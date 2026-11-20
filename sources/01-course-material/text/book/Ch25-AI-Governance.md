# Ch25-AI-Governance.pdf (extracted text, 28 pages)

<!-- page 1 -->
Chapter 25
AI Governance: Establishing
Accountability, Policies, and Oversight
25.1 Motivation
A major ﬁnancial services ﬁrm deployed a generative AI tool that began recommending products
its own compliance team had ﬂagged as unsuitable for retail investors. No one had deﬁned who
was accountable for the model’s outputs, and no review board had approved the risk thresholds.
Because the system spanned four departments (product, engineering, legal, and customer success),
no single function owned the problem. By the time leadership intervened, the tool had been in
production for eleven weeks.
This story is not an outlier. Stanford’s 2025 AI Index documented 233 AI-related incidents in 2024,
a 56.4% year-over-year increase, alongside 59 new AI regulations issued by 42 distinct US federal
agencies in the same year, a 136% jump over 2023 (Stanford Institute for Human-Centered Artiﬁcial
Intelligence (HAI) 2025). The Foundation Model Transparency Index, which measures disclosure
practices among foundation model developers, moved from 37% in October 2023 to 58% in May
2024 (Bommasani et al. 2024). The improvement is encouraging, but enterprise consumers of
these models still lack the visibility they need to govern AI systems with conﬁdence. Governance
capacity is not keeping pace with capability.
McKinsey’s State of AI Trust in 2026 puts a similar number on it. Average responsible AI maturity
rose from 2.0 to 2.3 over the prior year, with only about one-third of surveyed organizations reach-
ing a score of 3 or higher (McKinsey & Company 2026). The governance question has shifted as
well. McKinsey frames it as a move from “Is the model accurate?” to “Who is accountable when
the system acts?” The reframing matters in practice: as agentic systems act in production, the ob-
ject of governance shifts from a prediction awaiting review to a decision already executed by the
time anyone reads the log.
And the failure mode is not always launch. Many AI initiatives die before they reach production
because the underlying data was never ready or the use case was never well deﬁned, and the
handoff from data engineering to model development to deployment breaks down along the way
(Gartner Research 2025). Governance failures often show up earlier than that, in projects that stall
in legal review, fall apart at the handoff between teams, or produce outputs nobody is willing to
put their name behind.
1

<!-- page 2 -->
AI systems make consequential decisions at scale, evolve continuously, and touch every function
of the organization. Yet most enterprises still lack a clear framework for who decides what, who re-
views it, and who is accountable when something goes wrong. Without governance infrastructure,
accountability is an afterthought. Afterthoughts do not survive production.
25.2 Challenge
How do you build governance structures that keep AI systems aligned with enterprise goals, risk
tolerance, and regulatory obligations, while enabling AI teams to move fast enough to deliver real
business value? The harder question is how to govern systems whose behavior is probabilistic,
whose data dependencies shift in production, and whose decision authority is increasingly dele-
gated to autonomous components that act before a human can review.
25.3 Objectives
By the end of this chapter, you will be able to:
1. Deﬁne AI governance and explain its scope across technical, operational, legal, and ethical
dimensions.
2. Trace the inheritance from ﬁnancial-services Model Risk Management to modern AI gover-
nance, and identify where the inheritance breaks down for generative and agentic systems.
3. Design a governance model appropriate to your organization’s scale and risk proﬁle, using
centralized, federated, or hub-and-spoke patterns.
4. Identify the roles, committees, and decision rights required for effective AI governance, in-
cluding the cross-functional composition that resists rubber-stamping.
5. Apply governance checkpoints across the AI development and deployment lifecycle, with
risk tiering that prevents governance from becoming a bottleneck.
6. Recognize the categorically new threats that agentic AI systems introduce, and the architec-
tural patterns that contain them.
7. Connect AI governance to enterprise risk management, regulatory compliance, and corpo-
rate accountability frameworks, and resource it in proportion to the asymmetric risk proﬁle
of AI.
Governance is the foundation of the Operate part. Every other chapter in Part 4 (metrics, mon-
itoring, reliability, cost, and value translation) operates within the framework established here.
Without it, those chapters describe activities with no one accountable for their outcomes.
25.4 Inputs from Prior Chapters
This chapter assumes the enterprise has already established several foundational capabilities cov-
ered in earlier parts of the book. From Chapter 9, the organization has an AI strategy that deﬁnes
where AI creates competitive advantage and what risk appetite the executive team has accepted.
From Chapter 8, a data governance model exists that addresses data quality, lineage, consent, and
permissible use. From Chapter 18, the architecture team has designed the AI platform with se-
curity controls, access management, and auditability in mind. From Chapter 23, the MLOps and
LLMOps pipelines provide the operational substrate for model versioning, deployment, and mon-
itoring. From Chapter 21, security controls for data handling, secrets management, and network
2

<!-- page 3 -->
isolation are already in place. This chapter builds governance on top of that substrate. Without
those inputs, governance becomes a policy exercise disconnected from operational reality.
25.5 What AI Governance Actually Is (And Isn’t)
The vocabulary matters because most organizations conﬂate three distinct concepts. Compliance
meets external requirements. Governance builds internal structures that make compliance achiev-
able and more effective. Ethics deﬁnes the values. Governance deﬁnes the mechanisms that oper-
ationalize those values. Governance is the operating infrastructure that connects compliance and
ethics to day-to-day engineering decisions, distinct from either a compliance function or an ethics
committee.
AI governance operates at three layers. The policy layer deﬁnes rules, standards, and guidelines
for acceptable AI use across the enterprise. The process layer embeds workﬂows, review gates, and
approval chains into the development lifecycle. The accountability layer assigns roles, ownership,
and escalation paths so that someone is responsible for each outcome.
Mature governance hits all three. Most early-stage programs only hit the ﬁrst.
What governance must cover in practice: model selection and approval criteria; training data
use, consent, and lineage; security, access control, and data handling; fairness, bias review, and
disparate impact assessment; transparency and explainability requirements; human oversight re-
quirements and override mechanisms; incident accountability and post-mortem obligations; and
model versioning, deprecation, and retirement.
25.5.1 Fairness Has a Deﬁnition (Several, Actually)
When the policy layer says “the model must be fair,” the engineering team needs a falsiﬁable
deﬁnition. Ganguly identiﬁes three operational deﬁnitions of fairness used in enterprise practice:
demographic parity (the model’s positive prediction rate is equal across protected groups), equal op-
portunity (true positive rates are equal across groups), and equalized odds (both true positive and
false positive rates are equal) (Ganguly 2025). These are not interchangeable. They satisfy differ-
ent ethical priors and produce different operational tradeoffs. A credit model optimizing for de-
mographic parity may sacriﬁce predictive accuracy on protected subpopulations. A hiring model
optimizing for equalized odds may require explicit calibration against historical base rates.
The three deﬁnitions can also conﬂict mathematically when base rates differ across groups. Achiev-
ing demographic parity often makes equal opportunity unattainable, and vice versa. Governance
cannot be agnostic about which deﬁnition applies. The Central AI Review Board (CARB) must
choose, document the choice, and tie it to a speciﬁc class of system. The choice should also be re-
viewed with legal counsel, because the use of protected-class data for fairness testing can be legally
and operationally sensitive, even when necessary to measure compliance.
Tools like IBM’s AI Fairness 360, Google’s What-If Tool, SageMaker Clarify, and the responsible
AI evaluation surfaces in Microsoft Azure AI Foundry let engineering teams measure against the
chosen deﬁnition during development and in production (Menshawy and Fahmy 2025). Choosing
the deﬁnition is governance. Measuring against it is engineering.
3

<!-- page 4 -->
Figure 25.1: AI governance operates at three interdependent layers: policy deﬁnes the rules, process embeds
them into workﬂows, and accountability assigns ownership for outcomes.4

<!-- page 5 -->
Figure 25.2: The three operational deﬁnitions of fairness optimize for different outcomes and may be mathe-
matically incompatible when applied simultaneously.
5

<!-- page 6 -->
25.5.2 Convergence on a Shared Vocabulary
For most of the last decade, every major technology ﬁrm has published its own responsible AI
principles. The principles have now largely converged. Microsoft frames responsible AI around
six principles: fairness, reliability and safety, privacy and security, transparency, accountability,
and inclusiveness (Microsoft Corporation 2025). Google articulates three operational practices: de-
sign for responsibility, conduct adversarial testing, and communicate simple, helpful explanations
(Croak and Gennai 2023). NIST organizes its AI Risk Management Framework around four func-
tions: Govern, Map, Measure, and Manage (National Institute of Standards and Technology 2023).
The vocabularies differ. The underlying commitments are nearly identical: fairness, transparency,
accountability, safety, and meaningful human oversight.
The convergence suggests the ﬁeld has moved past ﬁrst-principles debates about responsible AI
and is now down to arguing about implementation. For an executive audience, that means you
no longer need to invent your own governance vocabulary. Pick one of the three (Microsoft for
vendor-friendly framing, Google for product-team framing, NIST for regulator-friendly framing)
and adapt it to your context. The convergence also lowers the cost of vendor selection because pro-
curement can map vendor-responsible AI claims to a shared rubric rather than translating among
three competing taxonomies.
25.6 Governance Inheritance from Model Risk Management
AI governance is not new. It builds on 15 years of ﬁnancial-services Model Risk Management
(MRM) practice, codiﬁed for US banks in the Federal Reserve Supervisory Letter SR 11-7 in 2011
(Board of Governors of the Federal Reserve System and Ofﬁce of the Comptroller of the Currency
2011). SR 11-7 introduced the practices that mature AI governance now treats as table stakes: effec-
tive challenge (independent review by qualiﬁed parties), ongoing monitoring of model performance
against its intended use, validation before deployment, and documentation sufﬁcient for a suc-
cessor team to reconstruct the decision history. Banks have been doing this for credit scorecards,
market risk models, and capital-adequacy models for more than a decade. Most of the discipline
transfers cleanly to AI.
In April 2026, the Federal Reserve, OCC, and FDIC jointly issued SR 26-2, which provides revised
guidance on model risk management for banking organizations with more than $30 billion in total
assets (Board of Governors of the Federal Reserve System et al. 2026). SR 26-2 reﬂects ﬁfteen years
of supervisory experience and signiﬁcant advances in modeling. The principles look familiar to
anyone who has read SR 11-7, but with sharper expectations on validation evidence, monitoring
cadence, and the documentation of model dependencies.
SR 26-2 explicitly states that “generative AI and agentic AI models are novel and rapidly evolving
and are not within the scope of this guidance,” while still expecting banking organizations to ex-
tend risk-management and governance practices to any tools, processes, or systems not covered
(Aryan 2025). The principles apply. The speciﬁc guidance does not. The regulators acknowledge
the gap and decline to ﬁll it because they recognize that the operational realities of generative and
agentic systems differ sufﬁciently that the SR 11-7 principles require substantive extension, not a
simple retroﬁt.
The practical consequence for a regulated ﬁrm: SR 26-2 sets the ﬂoor for governance of classical
ML and statistical models. For GenAI and agentic systems, the ﬁrm must build the supplementary
6

<!-- page 7 -->
governance layer itself, with the SR 11-7 principles as the anchor and the OWASP and NIST GenAI
frameworks (covered later in this chapter) as the operational extensions. For an unregulated ﬁrm,
the same logic still applies. SR 11-7 has been the de facto reference for serious model governance
outside banking for years. The 2026 update gives the broader market a refreshed reference text.
25.6.1 Model Risk Management in Practice
Large banks typically run a centralized Model Risk Management function with federated model
owners across business units. All production models pass through a standardized validation life-
cycle before deployment approval. Several features make mature programs work.
First, mature MRM functions act as an internal consultancy: model teams engage them early, of-
ten during the design phase, rather than encountering them only at the approval gate. That early
engagement turns what would otherwise be a confrontational handoff into a collaborative one.
Second, documentation (the model-card equivalent) is non-negotiable for every production model.
The validation team explicitly cannot review what is not documented, which forces upstream rigor.
Third, MRM is staffed with quantitative practitioners who can read the math and the code. Gov-
ernance without technical depth produces either rubber-stamping or blanket blocking. Neither is
useful.
For mid-market enterprises, the lesson is not to copy large-bank headcount. A single skilled
Responsible AI Lead with clear decision rights, embedded engagement with model teams from
project intake, and a non-negotiable documentation requirement achieves most of the beneﬁt at a
fraction of the cost. The validation-early, document-everything, technically-credentialed pattern
is the load-bearing structure. The hierarchy and headcount are not.
The MRM precedent also frames the boundary that SR 26-2 now names explicitly. Traditional
MRM workﬂows were designed for models with stable training distributions, point predictions,
and well-deﬁned performance metrics. Generative and agentic models violate all three assump-
tions: the distribution shifts continuously with prompt and tool design, the outputs are open-
ended, and the failure modes (hallucination, tool misuse, cascading errors) are not captured by
traditional accuracy metrics. The principles still apply. The metrics, the validation methods, and
the monitoring cadence must be re-engineered. That re-engineering is the subject of the LLMOps
discipline, covered in Chapter 23 and Chapter 27.
25.7 Governance Structures: Models and Tradeoffs
Three structural patterns dominate enterprise AI governance. Choosing the right one for your
organization is the ﬁrst governance decision, and the one most often made by inertia rather than
design.
Centralized governance assigns a single AI governance board ownership of all decisions. The ad-
vantages are consistency, a uniﬁed risk view, and clear authority. The disadvantages are bottleneck
risk, slow throughput for fast-moving teams, and loss of domain context at scale.
Federated governance puts each business unit in charge of its own AI governance, subject to shared
enterprise standards. Agility and domain expertise are the wins. Inconsistent standards and com-
pliance gaps between units are the predictable losses.
7

<!-- page 8 -->
Hub-and-spoke governance, the pattern most enterprises eventually converge on, splits the re-
sponsibility. A central governance council sets policy and owns high-risk decisions. Business-unit-
level AI Champions handle day-to-day review within the guardrails the council establishes. The
McKinsey 2026 survey describes this as the “business-domain governance plus central-platform
governance” split, and it shows a correlation with higher responsible AI maturity scores (McK-
insey & Company 2026). The model balances speed and control, places domain expertise at the
edges, and keeps policy consistent at the center.
The cost is investment in shared tooling, training, and clearly written escalation criteria.
A useful four-level maturity model helps locate where you are and where you should aim. Level
1 (ad hoc): governance happens informally, if at all. Level 2 (deﬁned): policies exist but are incon-
sistently applied. Level 3 (managed): governance is embedded in the development process with
measurable outcomes. Level 4 (optimized): governance is automated where possible and contin-
8

<!-- page 9 -->
uously improved. Most enterprises starting AI at scale sit at Level 1 or 2. The goal of this chapter
is to move them to Level 3. Stanford HAI’s 2025 data show why this matters: organizations that
recognize responsible AI risks far outnumber those that have taken concrete action to mitigate
them, and closing that gap remains the ﬁeld’s largest unresolved problem (Stanford Institute for
Human-Centered Artiﬁcial Intelligence (HAI) 2025).
Figure 25.3: Most enterprises beginning AI at scale operate at Level 1 or 2; the goal of structured governance
is to reach Level 3 (Managed), where governance is embedded in the development process, and outcomes are
measurable.
25.8 Roles, Committees, and Decision Rights
Policy without ownership is decoration. Decision rights without role deﬁnition is chaos. The gov-
ernance role stack below is the minimum scaffolding for an enterprise serious about AI (Sharma
2024).
Table 25.1: AI governance role stack.
Role Responsibility
Chief AI Ofﬁcer (CAIO) Owns enterprise AI strategy and governance
policy
AI Governance Board / CARB Cross-functional body; approves high-stakes
models; resolves escalations
9

<!-- page 10 -->
Role Responsibility
AI Product Owner Accountable for a speciﬁc AI system’s
performance, fairness, and business alignment
Responsible AI Lead Evaluates systems for bias, fairness, and
societal impact
Data Steward Owns data quality, lineage, and permissible use
AI Governance Champion (per BU) Federated role; applies central governance
within a business unit
Legal / Compliance Counsel Translates regulatory requirements into
governance obligations
LLMOps Lead Operational governance of LLMs, RAG
systems, prompts, and agents (Aryan 2025)
The role stack inherits from data governance lineage. DAMA-DMBoK’s classical ﬁve-role split
(Owner, Steward, Creator, User, Consumer) is the ancestor of the AI Product Owner / Data Steward
/ model author / model consumer pattern that anchors AI governance today (Milhomem 2025).
The AI-speciﬁc roles (Responsible AI Lead, Governance Champion, LLMOps Lead) extend that
lineage to handle the failure modes that data governance alone never had to address.
The decision-rights matrix is the operational layer. The illustrative RACI below maps the most
common decisions to the role stack.
Table 25.2: Illustrative RACI matrix for AI governance decisions.
Decision Responsible Accountable Consulted Informed
Model approval
(Tier 1)
AI Engineer AI Product
Owner
Data Steward CARB
Model approval
(Tier 3)
AI Governance
Lead
CARB Legal, Risk Executive Team
Data use
approval
Data Steward CDO Legal AI Product
Owner
Production
deployment
DevOps /
MLOps
AI Product
Owner
Security CARB
Incident
escalation
On-call Engineer AI Product
Owner
Governance
Lead
CARB, Legal
Parametric
control change
(Tier 2/3)
AI Engineer AI Product
Owner
Governance
Lead
CARB
Model retirement AI Engineer AI Product
Owner
Governance
Lead
CDO
Two failure modes are common and both avoidable. Governance boards without engineering and
data science produce policies that do not work in practice. Governance boards without legal, risk,
and ethics produce liability. The cross-functional composition is what makes the board capable of
saying yes to the right things and no to the wrong things, in the same meeting.
10

<!-- page 11 -->
25.9 Threat Model for Agentic Governance
Agentic AI systems (those that plan, call tools, and act on the world with reduced or asynchronous
human review) introduce a categorically new threat surface that traditional ML governance was
not built to address. The OWASP Top 10 for Agentic Applications provides a useful taxonomy
of these threats and has become an inﬂuential reference for security-side governance of agentic
systems (OWASP Gen AI Security Project 2025).
The categories most consequential for governance are the following. Memory Poisoning targets
persistent memory used by agents across sessions, contaminating future decisions through prior-
session injection. Tool Misuse covers agents using legitimately granted tools to achieve unautho-
rized outcomes, often by chaining tool calls in ways the designers did not anticipate. Privilege
Compromise exploits over-broad permissions, where an agent granted access for one task uses it for
another. Cascading Hallucinations describes the case where one model’s hallucinated output is con-
sumed by another model as a trusted input, propagating errors at machine speed. Intent Breaking
manipulates an agent’s goal-seeking behavior so that its planning produces outputs aligned with
an attacker’s intent rather than the user’s. Overwhelming HITL is the failure mode where human-
in-the-loop review queues are ﬂooded faster than humans can meaningfully review, producing
rubber-stamp approvals that defeat the purpose of the control. Identity Spooﬁng covers agents im-
personating users or other systems to bypass authorization checks.
Three governance implications follow directly.
First, traditional model risk management cannot simply be retroﬁtted. SR 26-2 names this gap ex-
plicitly, and LLMOps practitioners have been making the same argument: traditional MLOps ap-
proaches struggle when applied to GenAI and agentic systems because the operational primitives
(prompts, tool grants, memory stores, retrieval indexes) are not what classical model governance
was designed to oversee (Aryan 2025). The governance layer must extend to those primitives, not
just to model weights.
Second, some governance must be architectural, not solely procedural. Proven security controls
include IAM permission boundaries, tool allowlists, audit logs, network egress controls, sandbox-
ing, and explicit approval workﬂows. These are enforceable invariants. In addition, emerging
patterns such as scoped agents (narrow purpose, explicit “what I do NOT do” boundaries, tightly
restricted tool grants), read-only agents for audit and review, and multi-critic reﬂection patterns (spe-
cialist critic models evaluate proposed actions before a synthesizer authorizes execution) provide
useful defense-in-depth. The enforceable controls are the load-bearing structures. The emerging
patterns complement them.
Third, evaluation is the operational enforcement layer for agentic governance. Menshawy and
Fahmy argue persuasively that responsible AI for LLMs must be “centered in evaluation,” with
regulatory text itself loaded as a retrieval source so that the system can answer regulatory queries
against the law’s actual text (Menshawy and Fahmy 2025). The pattern generalizes. Governance
policies become living artifacts when they are indexed, queryable by the systems they constrain,
and consulted at runtime rather than reviewed only at design time. One important caveat: retrieval
over regulatory documents is a productivity tool for governance teams, not a substitute for legal
counsel. Binding interpretations still require human legal review.
The threats compound at scale. Cascading Hallucinations and Overwhelming HITL are among the
most under-recognized failure modes in early agentic deployments, because both are emergent.
Neither shows up clearly in single-agent testing. Both surface when the system is in production
11

<!-- page 12 -->
Figure 25.4: The OWASP Top 10 for Agentic Applications identiﬁes categorically new threat categories that
traditional ML governance was not designed to address.
12

<!-- page 13 -->
at full trafﬁc. Governance design must include load-conditional review pathways, not just steady-
state review pathways.
25.10 Embedding Governance into the AI Lifecycle
Governance is not a ﬁnal checkpoint. The most expensive governance failures happen when review
gates are placed only at the end, after the money has been spent and the deadline is bearing down.
A gate placed only at the end often gets waived. Governance embedded throughout does not.
Figure 25.5: Governance checkpoints must be embedded throughout the AI lifecycle; a single review gate at
production is too late to catch most governance failures.
Table 25.3: Governance checkpoints by AI lifecycle phase.
Phase Governance Activity
Intake / Ideation AI use case intake form; risk classiﬁcation (Tier
1/2/3)
Design Fairness and transparency requirements
deﬁned before development begins
Build Model card authored; data lineage
documented; security review completed
Pre-production Governance review gate; sign-off from
appropriate Governance Lead; evaluation
harness in place
Production Monitoring thresholds approved; escalation
paths conﬁrmed; parametric control audit
surface live
Retirement Deprecation reviewed for downstream impact;
model archived with documentation
13

<!-- page 14 -->
25.10.1 Risk Tiering Criteria
Risk tiering is the mechanism that prevents governance from becoming a bottleneck. The criteria
for classiﬁcation should be explicit and measurable:
Table 25.4: Risk tiering criteria.
Criterion Tier 1 (Low) Tier 2 (Medium) Tier 3 (High)
Customer impact None or minimal Indirect or aggregated Direct,
individual-level
Regulatory exposure None Moderate High (credit, health,
employment, EU AI
Act high-risk
category)
Autonomy level Human review of all
outputs
Human review of
exceptions
Autonomous action
with async review
Financial materiality Low Moderate High potential for loss
Reversibility Easily reversed Reversible with effort Difﬁcult or impossible
to reverse
Sensitive data use None Aggregated or
anonymized
Individual-level
sensitive attributes
External visibility Internal only Limited external Broad public or
customer-facing
Tier 1 (low risk) is delegated to the team, documented in the model registry, and requires no com-
mittee review. Examples include internal dashboards, A/B test variants, and non-customer-facing
analytics. Tier 2 (medium risk) requires AI Governance Champion review and sign-off. Examples
include customer segmentation models, supply chain optimization, and employee productivity
tools. Tier 3 (high risk) requires full CARB review, legal clearance, and executive sign-off.
14

<!-- page 15 -->
Examples include credit scoring, health risk prediction, hiring and ﬁring tools, customer-facing
generative AI, and real-time pricing.
Model cards are the standard build-phase artifact for every production model: model purpose,
training data summary, performance metrics, known limitations, fairness assessment, intended
use, and explicitly out-of-scope uses (Mitchell et al. 2019; Hugging Face, n.d.). They are not op-
tional. The model registry is the durable home for them. Without a registry that ties model cards,
training data hashes, evaluation results, and approval records together, governance has nowhere
to look during an incident review.
25.10.2 When the Model Did Not Change But the System Failed
Public reporting on Zillow’s $304 million Offers shutdown in November 2021 indicates that the
failure was not a simple case of a model producing bad predictions (Gopal and Clark 2021). The
contributing factors included market volatility, forecasting challenges, operational capacity con-
straints, and business process pressures. What makes the case instructive for governance is the
role of operating parameters: acceptance thresholds, calibration settings, and human-review rates
that translate model outputs into business decisions.
The governance lesson is concrete. The model itself is often a relatively small surface for gover-
nance. The much larger surface is the conﬁguration controls that govern how the model’s output
is translated into decisions. Parametric controls (acceptance thresholds, human-review rates, cal-
ibration multipliers, coupling settings between automated and human decisions) need their own
audit surface, their own change-authorization rules, and their own oversight pathway. “Para-
metric controls” here refers to the runtime conﬁguration parameters that operators adjust to tune
system behavior: thresholds that determine when an automated decision is made versus escalated,
multipliers that calibrate model outputs to business constraints, and rates that govern how much
human review occurs. These controls sit outside the model weights themselves but profoundly
15

<!-- page 16 -->
affect system behavior.
The model registry and the evaluation harness do not see changes to these parameters. They look
like operations changes, not model changes. Governance that audits only the model misses signif-
icant failure modes.
Figure 25.6: Parametric controls sit between model outputs and business decisions; they require their own
audit surface, change authorization rules, and oversight pathway separate from model governance.
25.11 AI System Inventory and Third-Party Governance
Governance starts with knowing what AI systems exist. An enterprise AI inventory should cap-
ture:
Table 25.5: AI system inventory ﬁelds.
Field Description
System name Unique identiﬁer
Owner Accountable individual
Business process Where the system operates
Model type Classical ML, LLM, agentic, hybrid
Vendor/internal Build versus buy
Data sources Training and inference data
User population Internal, B2B, B2C
Autonomy level Fully human, human-in-loop, autonomous
Risk tier Tier 1, 2, or 3
Regulatory obligations Applicable frameworks
16

<!-- page 17 -->
Field Description
Monitoring owner Who reviews production metrics
Retirement date Planned end-of-life or indeﬁnite
25.11.1 Third-Party and Vendor AI Governance
Enterprises increasingly use vendor models, APIs, SaaS copilots, and embedded AI features. Third-
party AI requires its own governance layer:
Vendor due diligence should include: Does the vendor train on customer data? Are prompts
and outputs logged, and can logging be disabled or region-bound? What model versions are used,
and how are updates communicated? How are safety ﬁlters conﬁgured and changed? Are outputs
explainable or auditable? What happens when the vendor deprecates a model?
Contractual controls should address: audit rights, data retention and training-use terms, indem-
niﬁcation for AI-related claims, SOC 2 or ISO certiﬁcations, security review requirements, and
fallback plans if vendor behavior changes unacceptably.
Procurement questions for SaaS AI and foundation model APIs should include: transparency
about training data, model versioning and update cadence, geographic restrictions on data pro-
cessing, ability to opt out of training data contribution, and terms governing customer data use.
25.12 AWS Governance Implementation
For AWS-based AI platforms, governance requirements map to speciﬁc services and controls:
Table 25.6: AWS governance implementation mapping.
Governance Need AWS Implementation
Model registry SageMaker Model Registry
Model documentation SageMaker Model Cards
Bias and explainability SageMaker Clarify
Production monitoring Evidently Monitoring
GenAI output guardrails Amazon Bedrock Guardrails
Agent permissions IAM roles, permission boundaries, Service
Control Policies
Audit trail CloudTrail, CloudWatch Logs
Data access governance Lake Formation, IAM, Macie
Compliance evidence AWS Audit Manager
Security posture AWS Security Hub, AWS Conﬁg
SageMaker Model Cards provide a structured format for documenting model purpose, training
data, performance metrics, fairness evaluations, and intended use. Model cards should be created
during the build phase and stored in SageMaker Model Registry alongside model artifacts.
SageMaker Clarify runs bias detection and explainability analysis during training and in produc-
tion. Conﬁgure Clarify to measure against the fairness deﬁnition the CARB has chosen for each
system class.
17

<!-- page 18 -->
Amazon Bedrock Guardrails attach to customer-facing generative AI applications and enforce
content ﬁltering, topic blocking, and sensitive information redaction. Guardrails are governance
artifacts that should be version-controlled and reviewed as part of Tier 2/3 approvals.
IAM permission boundaries and Service Control Policies enforce least-privilege for agentic sys-
tems. An agent that can issue refunds should not have permissions to modify customer records.
Permission boundaries are enforceable controls that translate scoped-agent design into runtime
enforcement.
AWS CloudTrail and CloudWatch Logs capture the audit trail for all API calls, including model
invocations, parameter changes, and conﬁguration updates. CloudTrail logs are the evidence base
for incident investigations and compliance audits.
AWS Audit Manager automates evidence collection against compliance frameworks. Conﬁgure
Audit Manager assessments for relevant frameworks (SOC 2, GDPR, HIPAA where applicable)
and include AI-speciﬁc controls in custom frameworks.
For infrastructure-as-code governance, Terraform state ﬁles and plan outputs provide change audit
trails for infrastructure that hosts AI systems. Require Terraform plan review for Tier 2/3 infras-
tructure changes that affect AI system behavior.
25.13 Regulatory and Legal Landscape
Table 25.7: Regulatory and industry frameworks an enterprise AI program must address.
Framework Jurisdiction Key Requirements
EU AI Act (European
Parliament and Council of the
European Union 2024)
European Union Risk-based classiﬁcation;
prohibited uses; mandatory
transparency and human
oversight for high-risk
systems (Annex III categories)
NIST AI RMF 1.0 (National
Institute of Standards and
Technology 2023)
United States (voluntary) Govern, Map, Measure,
Manage functions
NIST AI 600-1 GenAI Proﬁle
(Autio et al. 2024)
United States (voluntary) GenAI-speciﬁc risk categories
and suggested actions across
the four functions
GDPR (European Parliament
and Council of the European
Union 2016)
European Union Data privacy, consent, lawful
basis for training and
inference
CCPA / state laws US states Consumer privacy, opt-out,
data lineage
FTC Section 5 enforcement
(Gesser et al. 2023)
United States Guidance and enforcement
actions against deceptive AI
marketing claims
18

<!-- page 19 -->
Framework Jurisdiction Key Requirements
SR 26-2 Model Risk
Management (Board of
Governors of the Federal
Reserve System et al. 2026)
US banks > $30B assets Effective challenge, validation,
monitoring; explicitly
excludes GenAI and agentic
from scope
FINRA / SEC Financial services Model risk management;
explainability for automated
advice
HIPAA + HHS AI guidance Healthcare Patient data use in AI; clinical
AI oversight requirements
EEOC guidance Employment AI Anti-discrimination
requirements for hiring and
performance AI
India DPDPA 2023, UK Data
Protection Act, Singapore
PDPA (Ganguly 2025)
India, UK, Singapore Data protection regimes
extending GDPR-like
principles to Asia-Paciﬁc
OWASP Top 10 for Agentic
Applications (OWASP Gen AI
Security Project 2025)
Industry framework Threat taxonomy for
autonomous and agentic AI
NIST AI RMF is a practical and widely used voluntary anchor for US enterprises. Its four functions
(Govern, Map, Measure, Manage) map directly to the structure of this book. Part 4 operationalizes
all four. This chapter is the Govern function. The GenAI Proﬁle (NIST AI 600-1) extends the four
functions with GenAI-speciﬁc risk categories and suggested actions, developed through a large
public working group (Autio et al. 2024). For US enterprises that want a single anchor, RMF 1.0
plus AI 600-1 is a strong de facto reference set.
The US enforcement picture is often understated by executives who treat the US as “voluntary NIST
plus state privacy laws.” That framing misses the FTC. Since 2023, the FTC has issued guidance
and taken enforcement actions related to AI marketing claims, using Section 5 of the FTC Act to
address deceptive practices (Gesser et al. 2023). The enforcement focus areas include overstated ca-
pabilities, comparative claims that cannot be substantiated, and the failure to distinguish genuine
AI features from marketing labels. The distinction matters: FTC guidance represents agency inter-
pretation, while consent orders and enforcement actions represent actual regulatory consequence.
Companies do not need to wait for a US AI Act to face enforcement exposure.
Regulatory risk posture is an explicit choice. Compliance-minimum meets the letter of the law, which
may lower cost now but raises future exposure. Responsible AI leading exceeds requirements to build
trust, reduce regulatory risk, and create competitive differentiation. Neither is inherently wrong.
The choice must be explicit and board-approved, not made by default by engineering teams under
deadline pressure.
Human oversight requirements at scale mean clear escalation paths, override mechanisms,
documentation of human review, and audit trails. These must be engineered in from the start.
Retroﬁtting them is expensive and usually incomplete.
19

<!-- page 20 -->
25.13.1 Resourcing Governance Asymmetrically
The risk proﬁle of AI is structurally asymmetric. Productivity gains accumulate slowly through
coordinated organizational redesign. Catastrophic risks can cascade through a single broken link.
The data shows the pattern is in motion. Stanford HAI documented 233 AI incidents in 2024, a
56.4% year-over-year increase (Stanford Institute for Human-Centered Artiﬁcial Intelligence (HAI)
2025), while McKinsey’s 2026 maturity benchmark places only about one-third of organizations at
meaningful AI governance maturity (McKinsey & Company 2026). Governance resourcing must
reﬂect the same asymmetry, not the productivity narrative.
Three principles for asymmetric governance allocation:
1. Pre-deployment governance over post-incident response. The ﬁrst systemic failure of a high-blast-
radius AI system may be difﬁcult to recover from, whether reputationally, ﬁnancially, or
legally. Architectural governance (enforceable access controls, scoped permissions, paramet-
ric control audit surfaces) should be funded as engineering investment before launch, not as
compliance overhead after.
2. Architectural governance over policy governance. Policies that depend on human enforcement at
autonomous speed are unreliable in production. Engineering review gates, IAM permission
boundaries, tool allowlists, approval workﬂows, and structured human-in-the-loop queues
that resist Overwhelming HITL (OWASP Gen AI Security Project 2025) are the durable en-
forcement mechanisms.
3. Audit the operating controls, not just the model outputs. Parametric controls (acceptance thresh-
olds, human-review rates, calibration multipliers, coupling settings) need their own audit
surface, change-authorization rules, and oversight pathways separate from model perfor-
mance monitoring.
The temptation, given the slow productivity payoff, is to defer governance investment. Asymmet-
ric risk says: do the opposite. The window between AI capability and AI governance capacity is
precisely where failures are most likely to occur.
25.14 Governance Metrics and Board Reporting
The CARB and executive committee need operating metrics to assess governance effectiveness:
Table 25.8: Governance operating metrics.
Metric Description
AI systems inventoried Percentage of AI systems in the enterprise
inventory
Named accountable owner Percentage of systems with documented
ownership
Current model card Percentage of production models with
up-to-date documentation
Tier 3 system count Number of high-risk systems requiring full
CARB review
Approval cycle time Average time from submission to approval by
tier
20

<!-- page 21 -->
Metric Description
Policy exceptions Number of active exceptions and
compensating controls
High-risk ﬁndings unresolved Count and age of open high-risk audit ﬁndings
Incidents by severity Production incidents classiﬁed by impact
Monitoring coverage Percentage of production systems with active
monitoring
Vendor AI systems reviewed Percentage of third-party AI with completed
due diligence
25.14.1 Exception Management
Governance needs a controlled way to approve exceptions when business need justiﬁes deviation
from standard policy:
• Exception authority: Deﬁne who can approve exceptions by tier. Tier 1 exceptions may be
approved by the AI Governance Champion. Tier 2/3 exceptions require CARB approval.
• Expiration: Exceptions should have a deﬁned expiration date and renewal process.
• Compensating controls: Document what additional controls are in place while the exception
is active.
• Board visibility: High-risk exceptions should be reported to the board audit committee.
25.14.2 Incident Response Integration
When AI systems fail in production, governance provides the escalation structure:
• Severity levels: Deﬁne severity based on customer impact, ﬁnancial exposure, regulatory
consequence, and reputational risk.
• Incident commander: Designate who leads the response for each severity level.
• Legal and communications involvement: Deﬁne triggers for legal and PR engagement.
• Customer notiﬁcation criteria: Specify when and how customers are notiﬁed of AI-related
incidents.
• Rollback authority: Document who can authorize rollback or shutdown of a production AI
system.
• Evidence preservation: Preserve logs, model artifacts, and conﬁguration state for post-
incident review.
• Post-incident review: Require blameless post-mortems for Tier 2/3 incidents with docu-
mented ﬁndings.
25.15 Use Case: Retail Customer Acquisition and Retention
The retail enterprise that has anchored the use case across this book now reaches the point in its
build where governance becomes load-bearing. Five AI systems are at or near production: a recom-
mendation engine, a customer lifetime value (CLV) model, a churn prediction model, a credit-offer
model, and a customer service generative AI assistant. Three of those systems serve customers in
real time, one touches credit decisions, and one generates natural language to customers at scale.
21

<!-- page 22 -->
Figure 25.7: AI risk is structurally asymmetric; governance resourcing should be weighted toward prevent-
ing fast-moving, high-magnitude failures rather than proportional to expected productivity gains.
22

<!-- page 23 -->
The team adopts a hub-and-spoke structure. A Central AI Review Board (CARB) chaired by the
VP of AI includes the Chief Data Ofﬁcer, General Counsel, VP of Product, Head of Risk, and the
Responsible AI Lead. Each line of business (marketing, supply chain, customer service) has an
embedded AI Governance Champion. The Marketing Governance Champion handles Tier 1 deci-
sions (low-risk model updates, A/B variants, parameter tuning within preapproved bounds) and
escalates Tier 2 decisions to CARB within 48 hours.
Figure 25.8: The retail use case implements hub-and-spoke governance with Tier 3 systems requiring full
CARB review, while Tier 2 systems are approved by business unit champions.
Risk classiﬁcation breaks out as follows. The recommendation engine serving EU customers trig-
gers transparency and consumer-protection obligations under EU law and is classiﬁed internally
as Tier 3 for CARB review due to its scale and customer impact. (Note: general retail recommen-
dation engines are not automatically classiﬁed as “high-risk” under EU AI Act Annex III; internal
Tier 3 classiﬁcation reﬂects the enterprise’s own risk assessment, not legal high-risk status.) Hu-
man override mechanisms are engineered into the runtime path as a governance requirement. The
CLV model is Tier 2: customer-impacting but not directly decision-making. The Marketing Gover-
nance Champion signs off on the model card and approves deployment. The churn model is Tier 2
as well. The credit-offer model is Tier 3: it falls into the EU AI Act high-risk category for creditwor-
thiness assessment and triggers FCRA and ECOA obligations, requiring explainability for adverse
action notices, disparate impact testing, and full CARB review with Legal clearance. The customer
service generative AI assistant is Tier 3 because of its agentic capabilities (it can read account state
and initiate actions such as issuing refunds below a dollar threshold) and via Evidently Monitor,
and requires the Responsible AI Lead’s sign-off for the FTC’s guidance on AI marketing claims.
23

<!-- page 24 -->
The team chooses an operational fairness deﬁnition for the credit-offer model. After review with
Legal and the Responsible AI Lead, they adopt equal opportunity (equal true positive rates across
protected groups) as one metric in their fairness evaluation. They document that fairness measure-
ment is one component of compliance, since regulators generally weigh discrimination, disparate
impact, explainability, and adverse action disclosure together rather than relying on a single met-
ric. They measure against the deﬁnition using SageMaker Clarify in the evaluation harness, surface
drift in production through the Evidently Monitor, and require the Responsible AI Lead’s sign-off
on any quarterly recalibration. The deﬁnition and rationale are documented in the model card
stored in SageMaker Model Registry.
The parametric audit surface is built into the recommendation engine and the credit-offer system.
Acceptance thresholds, human-review rates, calibration multipliers, and the coupling between au-
tomated decision and human review are versioned, change-authorized, and logged with the same
rigor as model artifacts. Changes to Tier 2 and Tier 3 parametric controls require the same review
path as model deployments. CloudTrail logs capture all conﬁguration changes.
The customer service agent is governed using scoped-agent patterns and IAM permission bound-
aries. The agent has explicit capabilities and limitations: it can issue refunds below a deﬁned
threshold, cannot change passwords, cannot access employee records, and cannot generate mar-
keting content. IAM permission boundaries enforce these restrictions at runtime. Tool allowlists
restrict which APIs the agent can call. For high-risk interactions, the team implements anomaly-
triggered review batching: only ﬂagged interactions enter the human review queue, and the queue
is rate-limited to a volume the on-call reviewer can meaningfully process.
Amazon Bedrock Guardrails are attached to the customer service agent to ﬁlter harmful con-
tent, block off-topic requests, and redact sensitive information. Guardrail conﬁguration is
version-controlled and requires approval from the Governance Champion for changes.
The EU AI Act, NIST AI 600-1 GenAI Proﬁle, and OWASP Agentic guidance are loaded into the
team’s compliance retrieval system following the pattern described by Menshawy and Fahmy
(Menshawy and Fahmy 2025). Legal and the Governance Champions can query the actual text
in natural language, with responses grounded by retrieval rather than by the model’s training
data. The team documents that retrieval-grounded answers are a productivity tool, not legal ad-
vice. Binding interpretations still require human legal review.
AWS Audit Manager is conﬁgured with a custom assessment framework that includes AI gover-
nance controls. Evidence collection is automated for CloudTrail logs, SageMaker Model Registry
artifacts, and IAM policy conﬁgurations.
A reader who follows this use case across Part 4 ends the part with a production AI system that
is monitored, reliably engineered, ﬁnancially measured, business-value-translated, and governed
by a structure that does not depend on heroics to function.
25.16 Key Takeaways
• Governance is infrastructure. It is the operating system that makes responsible, scalable AI
possible, applied throughout the lifecycle rather than as a compliance checkbox at the end.
• AI governance inherits from Model Risk Management. SR 11-7 and its successor, SR 26-2, provide
the ﬁeld with ﬁfteen years of validated practice in effective challenge, validation, monitoring,
24

<!-- page 25 -->
and documentation. SR 26-2 also names the boundary by excluding GenAI and agentic AI
from scope, signaling that the inheritance has limits.
• Responsible AI principles have converged. Microsoft, Google, and NIST publish overlapping
vocabularies. Pick one and adapt rather than inventing a new one.
• Fairness has multiple operational deﬁnitions. The CARB must choose between demographic
parity, equal opportunity, and equalized odds for each class of system, recognizing these
deﬁnitions can conﬂict mathematically. The choice is governance. Measuring against it is
engineering.
• Hub-and-spoke ﬁts most enterprises. Fully centralized governance bottlenecks. Fully federated
governance fragments. Hub-and-spoke balances both.
• Embed governance in every lifecycle phase. A review gate at production sign-off is too late. Gov-
ernance starts at the intake form and ends at retirement.
• Risk tiering with explicit criteria prevents bottlenecks. Tier 1 is delegated, Tier 3 gets the full
committee. Measurable criteria drive classiﬁcation.
• Role clarity and decision rights are the mechanics. Policy documents without deﬁned ownership
are inert. RACI is not optional.
• Agentic AI requires its own threat model. Memory Poisoning, Tool Misuse, Cascading Hallu-
cinations, and Overwhelming HITL are categorically new failure modes. Enforceable con-
trols (IAM, tool allowlists, audit logs) are the foundation. Defense-in-depth patterns (scoped
agents, multi-critic review) complement them.
• Audit the parametric controls, not just the model. Conﬁguration parameters that translate model
outputs into business decisions need their own audit surface.
• Resource governance asymmetrically. Catastrophic-risk prevention deserves disproportionate
investment relative to the slow productivity payoff. The window between AI capability and
AI governance capacity is where failures are most likely.
• Third-party AI needs its own governance layer. Vendor due diligence, contractual controls, and
procurement checklists are essential for SaaS AI and foundation model APIs.
• AWS provides native governance tooling. SageMaker Model Cards, Model Registry, Clarify,
Evidently, Bedrock Guardrails, IAM, CloudTrail, and Audit Manager map governance re-
quirements to enforceable controls.
25.17 Apply It
1. Risk Classiﬁcation Audit. Take ﬁve AI systems currently in production at your organization
(or use the retail use case). Classify each as Tier 1, 2, or 3 using the criteria table in this chapter.
For each, document what governance processes are currently applied versus what should be
applied. Identify the largest gap and write a one-page proposal to close it within the next 90
days.
2. Governance Structure Design. Design a hub-and-spoke governance model for the retail
use case. Deﬁne the CARB composition and charter, the AI Governance Champion role de-
scription, the RACI decision rights matrix for model approval and incident escalation, and a
one-page escalation protocol that names the trigger conditions for each tier.
3. Model Card Draft. Using the retail churn prediction model as your example, draft a complete
model card that includes: model purpose; training data summary and lineage; performance
metrics; fairness deﬁnition chosen and measured; known limitations; intended use; and ex-
plicitly out-of-scope uses. Use the SageMaker Model Cards structure or the Hugging Face
25

<!-- page 26 -->
model card template as your structural reference.
4. Regulatory Mapping. Map each of the ﬁve retail AI systems (recommendation engine, CLV
model, churn prediction, credit-offer model, customer service generative AI) to its applicable
regulatory requirements: EU AI Act applicability and internal risk tier, GDPR data lineage
and lawful basis, US FTC marketing-claim exposure, FCRA/ECOA obligations where rele-
vant, and HIPAA where applicable. Distinguish internal governance tiers from legal classiﬁ-
cation categories. Identify which system requires the most governance investment to achieve
compliance, and explain why.
5. Agentic Threat Model. For the customer service generative AI assistant in the retail use
case, walk through the OWASP Top 10 for Agentic Applications. For each of the ten threats,
write one paragraph identifying whether it applies, the architectural control that mitigates it
(IAM permission boundaries, tool allowlists, audit logs, anomaly-triggered HITL, Bedrock
Guardrails, etc.), and the residual risk after mitigation.
6. AI Prompt. “You are a Chief AI Ofﬁcer reviewing the following governance structure for a retail AI
team. Identify the three most signiﬁcant accountability gaps (places where an AI failure would have no
clear owner), and recommend the minimum governance changes that would close them: [paste your
governance structure from Exercise 2].”
25.18 What’s Next
Governance sets the rules; the next chapter, Chapter 26, deﬁnes how you measure whether those
rules are working. It turns risk tiers into guardrail thresholds, connects model metrics to business
outcomes through the metric pyramid, and gives each stakeholder a view of the same evidence.
Without clear metrics, governance reviews run on opinion. With them, they run on evidence. Chap-
ter 27 then takes those metrics into the runtime as the operational telemetry that keeps production
AI systems honest from one release to the next.
25.19 References
Aryan, Abi. 2025. LLMOps: Managing Large Language Models in Production. O’Reilly Media.
Autio, Chloe, Reva Schwartz, Jesse Dunietz, et al. 2024. Artiﬁcial Intelligence Risk Management
Framework: Generative Artiﬁcial Intelligence Proﬁle. National Institute of Standards and Technol-
ogy (NIST). https://doi.org/10.6028/NIST.AI.600-1.
Board of Governors of the Federal Reserve System, and Ofﬁce of the Comptroller of the Currency.
2011. SR 11-7: Guidance on Model Risk Management. Board of Governors of the Federal Reserve
System.
Board of Governors of the Federal Reserve System, Ofﬁce of the Comptroller of the Currency, and
Federal Deposit Insurance Corporation. 2026. SR 26-2: Revised Guidance on Model Risk Manage-
ment. Board of Governors of the Federal Reserve System.
Bommasani, Rishi, Kevin Klyman, Shayne Longpre, et al. 2024. The Foundation Model Transparency
Index. https://doi.org/10.48550/arXiv.2310.12941.
26

<!-- page 27 -->
Croak, Marian, and Jen Gennai. 2023. Responsible Generative AI: Google’s 3 Emerging Best Prac-
tices. Https://blog.google/technology/ai/google-responsible-generative-ai-best-practices/;
Google.
European Parliament and Council of the European Union. 2016. Regulation (EU) 2016/679 of the
European Parliament and of the Council of 27 April 2016 on the Protection of Natural Persons with
Regard to the Processing of Personal Data and on the Free Movement of Such Data (General Data
Protection Regulation). European Union.
European Parliament and Council of the European Union. 2024. Regulation (EU) 2024/1689 of the
European Parliament and of the Council — Artiﬁcial Intelligence Act.
Ganguly, Arindam. 2025. Scaling Enterprise Solutions with Large Language Models. Apress.
Gartner Research. 2025. “Gartner Predicts Organizations Will Abandon 60\% of AI Projects Due
to Lack of AI-Ready Data.” Gartner Advisory & Predictive Frameworks.
Gesser, Avi, Erez Liebermann, Jim Pastore, et al. 2023. Risks of Overselling Your AI: The FTC Is
Watching. Https://www.debevoisedatablog.com/2023/03/06/risks-of-overselling-your-ai-
the-ftc-is-watching/; Debevoise &amp; Plimpton LLP.
Gopal, Prashant, and Patrick Clark. 2021. Zillow Loses $304 Million in Home-Flipping Business;
Cuts 25% of Workers. Https://www.bloomberg.com/news/articles/2021-11-02/zillow-loses-
304-million-in-home-ﬂipping-business.
Hugging Face. n.d. “Model Cards.” Hugging Face Hub.
McKinsey & Company. 2026. State of AI Trust in 2026: Shifting to the Agentic Era. Https://www.mckinsey.com/capabilities/tech-
and-ai/our-insights/tech-forward/state-of-ai-trust-in-2026-shifting-to-the-agentic-era; McK-
insey & Company.
Menshawy, Ahmed, and Mahmoud Fahmy. 2025. LLMs in Enterprise: Design Strategies for Strategic
Adoption of LLMs in Enterprise Settings. Packt Publishing.
Microsoft Corporation. 2025. Microsoft Responsible AI Principles and Approach. Https://www.microsoft.com/en-
us/ai/responsible-ai; Microsoft.
Milhomem, Jessika. 2025. Data Product Management in the Age of AI. Apress (Springer Nature).
Mitchell, Margaret, Simone Wu, Andrew Zaldivar, et al. 2019. “Model Cards for Model Reporting.”
Proceedings of the Conference on Fairness, Accountability, and Transparency (FAccT), 220–29. https:
//doi.org/10.1145/3287560.3287596.
National Institute of Standards and Technology. 2023. Artiﬁcial Intelligence Risk Management Frame-
work (AI RMF 1.0). National Institute of Standards and Technology (NIST). https://doi.org/10
.6028/NIST.AI.100-1.
OWASP Gen AI Security Project. 2025. OWASP Top 10 for Agentic Applications for 2026.
27

<!-- page 28 -->
Https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/;
OWASP Foundation.
Sharma, Rohan. 2024. AI and the Boardroom: Insights into Governance, Strategy, and the Responsible
Adoption of AI. Apress.
Stanford Institute for Human-Centered Artiﬁcial Intelligence (HAI). 2025. The 2025 AI Index Report
— Chapter 3: Responsible AI. Stanford Institute for Human-Centered Artiﬁcial Intelligence (HAI).
28