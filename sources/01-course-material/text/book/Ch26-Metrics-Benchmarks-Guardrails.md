# Ch26-Metrics-Benchmarks-Guardrails.pdf (extracted text, 29 pages)

<!-- page 1 -->
Chapter 26
Metrics, Benchmarks, and Guardrails:
Deﬁning What Success Looks Like
26.1 Motivation
A retail AI team ships a recommendation engine. It scores 94% accuracy on a holdout test set,
using the classiﬁcation metric the engineering team picked. The VP of Product calls it a win. Six
weeks later, the Head of Revenue walks into the sprint review with a slide showing average order
value down 8% since launch. The model is technically excellent and commercially destructive, and
nobody connected the two until the damage was done.
This is the metrics gap, and it shows up by default whenever nobody designs the measurement
system on purpose. Most AI teams measure what is easy to measure, such as accuracy, F1, loss
curves, and latency. Executives watch revenue, retention, and cost. When those two systems never
meet, AI succeeds on paper and fails in practice. Worse, the team grows more conﬁdent the whole
time, because the numbers it watches look ﬁne while the numbers the company depends on erode.
Look at what sits inside that 94% ﬁgure. The test set was built from historical clicks, so it rewards
the model for predicting what users have already bought. In production, that pattern turns into rec-
ommending lower-priced repeat purchases over higher-margin new categories. The model wins
its benchmark and loses the basket. The metric itself is part of the problem. Recommendation
systems are typically evaluated with ranking and retrieval metrics such as precision@K, recall@K,
NDCG, and MRR, because these capture whether the right items appear at the top of the list, and a
classiﬁcation-style accuracy score hides that completely. Technical performance connects to busi-
ness outcomes only through a metrics framework that was designed before deployment and is
governed as a ﬁrst-class artifact. A framework assembled as documentation after the system ships
arrives too late to help.
This chapter shows how to build that framework. It is the engineering work behind a sentence
executives say often and rarely act on: we should be measuring the right things.
26.2 Challenge
How do you deﬁne a metrics framework that gives engineers the technical visibility they need
to operate AI systems reliably, gives product managers the signal to judge whether systems are
1

<!-- page 2 -->
delivering value, and gives executives what they need to make investment and risk decisions, all
from the same underlying system? And how do you keep those measurements tied to the actual
business goal as the system, the users, and the world around them change?
26.3 Objectives
By the end of this chapter, you will be able to:
1. Identify the four performance dimensions that every enterprise AI system must measure,
and explain why optimizing any one in isolation produces predictable failures.
2. Distinguish between leading indicators, lagging indicators, and guardrail metrics, and ex-
plain when to use each.
3. Apply Goodhart’s Law in its weak and strong forms to diagnose why a benchmark earns the
team’s trust and then loses its predictive power.
4. Deﬁne benchmarks that give meaningful signals instead of false conﬁdence, including slice-
based and human-anchored evaluations.
5. Establish service-level indicators (SLIs), service-level objectives (SLOs), error budgets, and
guardrail thresholds that translate enterprise risk tolerance into operational numbers.
6. Build views of performance suited to each stakeholder, from engineers to executives, and
translate technical metrics into business outcomes without losing ﬁdelity.
Governance, covered in Chapter 25, sets the rules and accountability structures. Metrics tell you
whether those structures work. This chapter builds the measurement framework, and the next
chapter, Chapter 27, covers how to observe those measurements continuously in production.
26.4 Interface with Previous Chapters
This chapter draws on the governance chapter and on the Build chapters. From Chapter 25 it inher-
its the risk tier classiﬁcation for each AI system (which determines guardrail density and approval
requirements), the AI Governance Board structure (which approves guardrail thresholds for Tier
2 and higher systems), the model card requirements (which specify where guardrail documenta-
tion lives), and the accountability model (which determines who owns each metric category). From
Chapter 22 it inherits the testing and evaluation patterns that produce the technical quality metrics
discussed here. The framework built in this chapter then feeds Chapter 27, which covers continu-
ous observation of these measurements, and Chapter 30, which covers how to attribute business
value to AI systems.
26.5 The Four Performance Dimensions
Measure every enterprise AI system on four dimensions at once. When a technically successful
AI project becomes a business failure, it is usually in one way: someone optimized one dimension
and ignored the rest. Breaking that habit is the main thing this chapter asks of you.
26.5.1 Technical Quality
The engineering question here is whether the model produces correct, reliable outputs on the task
it was built for. The metrics depend on the task family. Classiﬁcation systems use accuracy, preci-
2

<!-- page 3 -->
Figure 26.1: The four performance dimensions of enterprise AI systems, all of which must be measured
simultaneously.
3

<!-- page 4 -->
sion, recall, F1, and AUC-ROC. Retrieval and recommendation systems use mean reciprocal rank
(MRR), precision@K, recall@K, and normalized discounted cumulative gain (NDCG) (Järvelin and
Kekäläinen 2002). Users see the top of the list, and ranking metrics score whether the most relevant
items land there. Generative systems use BLEU, ROUGE (primarily for summarization compar-
ison tasks), perplexity (useful for comparing models but not a direct measure of output quality),
and, more and more, LLM-as-judge evaluations that score outputs against rubrics (Chang et al.
2024). RAG systems add retrieval recall@K, context precision, groundedness (whether outputs are
supported by retrieved context), faithfulness, and citation accuracy.
LLM-as-judge approaches have known biases. Judges show position bias (preferring responses in
certain positions), verbosity bias (preferring longer responses), and self-preference (models rating
their own outputs higher). To calibrate a judge, periodically compare its ratings to expert human
ratings on a held-out sample, and adjust or replace it when the correlation degrades.
Every probabilistic system needs calibration. A model whose 80% conﬁdence predictions are cor-
rect 80% of the time is more useful than a more accurate model whose conﬁdence scores mean
nothing. LLMs need it most, since their stated self-conﬁdence is unreliable without explicit cali-
bration.
Technical quality metrics are measured against a test set, and the test set may not look like produc-
tion. High ofﬂine scores paired with poor online performance are the most common mismatch in
enterprise AI, and much of the rest of this chapter is about closing that gap.
26.5.2 Operational Reliability
Operations wants to know whether the system is available, fast, and stable enough to rely on.
Site reliability engineering (SRE) teams have used the relevant vocabulary for two decades. A
service-level indicator (SLI) is a measured property of the system, such as request latency, error
rate, availability, or throughput. A service-level objective (SLO) is a target for an SLI over a time
window, such as 99.9% of requests succeeding over a rolling 30-day window. The error budget is
1 minus the SLO target: the amount of unreliability the team may spend before further changes
must pause (Thurgood et al. 2018).
The arithmetic is simple. A 99.9% availability SLO over a 30-day window leaves a 0.1% budget,
which is about 43 minutes of downtime, or one failed request in every thousand. If a bad deploy-
ment burns 30 of those minutes in the ﬁrst week, the team has 13 left for the next three weeks. The
error budget policy then decides what happens, typically a freeze on non-urgent releases until the
budget recovers (Thurgood et al. 2018).
A 100% SLO is usually the wrong target, because it leaves no room for the experiments and deploy-
ments that improve a system. Some safety and compliance constraints do belong as zero-tolerance
policies, though, and they run on different logic from a reliability target. A recommendation en-
gine’s latency SLO carries a budget for imperfection so the system can keep improving. A content
safety guardrail or a legal constraint treats any violation as unacceptable.
The operational SLIs that matter most for ML and AI systems go beyond classical web service
metrics. Google Cloud’s SRE guidance for ML pipelines singles out data freshness (how recently
the model received the data it uses for an inference) as a pipeline SLO, and points to throughput as
a companion signal (Saltonstall and Virji 2025). Add model serving latency at the tail, since p95 and
p99 are what users actually feel, and you have the three ML-speciﬁc SLIs this book recommends
tracking explicitly. For a full list of what to monitor before calling an ML system production-grade,
4

<!-- page 5 -->
the 28-test production-readiness rubric from Breck and colleagues is still the most comprehensive
checklist (Breck et al. 2017).
A model with 95% accuracy that is down 20% of the time may be worse than a model with 90% ac-
curacy that is always available. Which one wins depends on the harm proﬁle, the fallback options,
and how critical the decision is. With the SLO vocabulary, the team can negotiate that trade-off
with stakeholders in explicit terms.
LLM and agent systems break some traditional MLOps monitoring assumptions, and the team has
to plan for that (Aryan 2025). Token-level latency, streaming ﬁrst-token time, and tool-call success
rates become ﬁrst-class SLIs alongside end-to-end response time. Agents add their own metrics:
average steps per task, runaway loop rate (tasks exceeding a step threshold), and human escalation
rate. Chapter 28 covers reliability engineering for these systems in depth.
26.5.3 Cost Efﬁciency
The economic question is whether the system delivers value at a sustainable cost. The metrics
include cost per inference, cost per user session, token spend for LLM systems, compute utilization
(are GPUs idle?), and the ratio executives watch most closely, cost per business outcome attributed.
That last ratio is harder to compute than it looks. “Cost per $1 of attributed revenue” sounds
precise, but attribution in recommendation systems rests on assumptions about incrementality,
holdout design, and what would have happened without the recommendation. Document your
attribution method and its limits rather than presenting the number as an accounting fact.
Cost also creeps. LLM and agent system costs scale with usage in ways that are easy to underes-
timate. A retrieval-augmented generation (RAG) system that costs $0.02 per query at pilot scale,
with 5,000 queries per day, costs $1,000 per month. Take the same system to production scale,
add retries, agent loops, and longer context windows, and serve a 50x larger user base, and it can
cost tens of thousands of dollars per month (Aryan 2025). Hidden technical debt adds to the bill:
every glue script, fallback path, and undocumented dependency carries operational cost that no
single dashboard shows (Sculley et al. 2015). AI economics gets its own chapter, Chapter 29. For
now, measure and optimize cost continuously like any other performance dimension, so nobody
discovers it for the ﬁrst time while reviewing the quarterly cloud bill.
26.5.4 Business Impact
Here the question is whether the system actually moves the outcomes it was built to move. The
business side of the house knows these metrics well: conversion rate, revenue per recommenda-
tion, churn reduction rate, cost savings, customer satisfaction (CSAT/NPS delta), and time saved
per user task.
Business impact metrics often trail technical events by days or weeks, which makes attribution
hard. A drop in retention this quarter could come from a model regression six weeks ago, a pricing
change three weeks ago, or a competitor’s product launch last week. Because those signals are so
hard to separate, you need leading indicators, covered next. Chapter 30 covers how to attribute
business value to AI systems. The point for this chapter is narrower: business impact is one of four
co-equal dimensions you are responsible for, alongside technical quality, reliability, and cost.
5

<!-- page 6 -->
26.5.5 The Metric Deﬁnition Template
Document the same ﬁelds for every metric in the framework. Then anyone operating the system
knows what each metric means and what to do when it moves:
Table 26.1: Metric deﬁnition template for enterprise AI systems.
Field Description
Name Clear, unambiguous identiﬁer
Purpose What question does this metric answer?
Metric type Leading, lagging, guardrail, or diagnostic
Formula Numerator, denominator, calculation method
Unit Percentage, milliseconds, dollars, count
Population Which requests, users, or events are included?
Slice dimensions How will this be broken down (segment,
geography, tenure)?
Time window Rolling 7 days, calendar month, real-time
Data source Pipeline, table, API, log stream
Owner Person or team accountable
Update frequency Real-time, hourly, daily, weekly
Threshold Target value or acceptable range
Alert severity P1 through P4, with escalation path
Response action What happens when threshold is breached?
Known failure mode How might optimizing this metric harm the
true goal?
Related business KPI Which lagging outcome does this predict or
protect?
26.6 Leading Indicators, Lagging Indicators, and Guardrails
These three metric types decide whether the team ﬂies on instruments or reads the black box after
the crash. Every metric on a dashboard should sit in one of these buckets, with its role declared.
Some metrics play a fourth role. Diagnostic metrics (queue depth, cache hit rate, feature null rate,
GPU utilization) support root-cause analysis without directly predicting or conﬁrming business
outcomes.
26.6.1 Lagging Indicators
Lagging indicators measure outcomes after the fact: revenue, churn rate, customer satisfaction,
quarter-over-quarter growth. Executives can read them without translation, which gives them
the highest business face validity of the three types. They are also the least useful operationally,
because by the time they move, the cause is weeks old. You need them to evaluate long-term value
and to show the business that an investment paid off. For real-time operational decisions they are
useless.
6

<!-- page 7 -->
Figure 26.2: Temporal relationship between leading indicators (predictive), guardrails (protective), and lag-
ging indicators (conﬁrmatory).
26.6.2 Leading Indicators
Leading indicators predict outcomes before they arrive. For an AI system, useful ones include fea-
ture distribution shifts (input data starting to look different from training data), prediction conﬁ-
dence distributions (the model growing less certain), recommendation click-through rates, add-to-
cart rates after a recommendation, and downstream user engagement with AI-generated content.
Executives need them translated, but they matter more operationally because they signal trouble
before outcomes degrade.
The hard part is choosing leading indicators that actually predict the lagging outcomes you care
about. Click-through rate looks like a leading indicator of revenue, yet in a system meant to grow
basket size, raw click-through can rise while average order value falls. That is what happened in
the chapter’s opening story. To validate a leading indicator, check the history: did movement in
the leading metric come before, and correlate with, movement in the lagging metric? A leading
indicator is a hypothesis about causality, and it deserves the same rigorous testing you give models.
26.6.3 Guardrail Metrics
Guardrail metrics mark the boundaries of acceptable operation. When one is crossed, the team
intervenes immediately, however good the other signals look. Fairness parity thresholds, max-
imum latency SLA, minimum conﬁdence for high-stakes predictions, cost ceilings, and content
safety thresholds are all guardrails. Together they state the enterprise’s risk tolerance in measur-
able terms. A later section covers them in depth.
7

<!-- page 8 -->
26.6.4 The Metric Type Matrix
Any of the four performance dimensions can hold metrics of any type. The matrix below shows
one way to check coverage:
Table 26.2: Mapping metric types to performance dimensions.
Dimension Leading Lagging Guardrail Diagnostic
Technical quality Conﬁdence
distribution shift
Model accuracy
on production
labels
Slice-level recall
ﬂoor
Feature
importance drift
Operational
reliability
Error rate trend SLO compliance
over 30 days
p99 latency
ceiling
Queue depth,
GPU utilization
Cost efﬁciency Token spend
velocity
Monthly cost per
attributed
outcome
Daily cost ceiling Cache hit rate
Business impact CTR, add-to-cart
rate
Revenue lift,
retention
Conversion rate
ﬂoor
Session depth,
bounce rate
26.6.5 Extending the Framework to Agent Systems
The leading/lagging/guardrail split was developed for classical ML systems, where a model pro-
duces a single prediction. Agents complicate it. An agent’s behavior unfolds over many steps,
tools, and turns, and any one of them can go wrong while the aggregate score looks ﬁne. An-
thropic’s recent engineering guidance on agent evaluations describes layered methods, three of
which map cleanly onto the split (Grace et al. 2026). Automated evals run before launch and in
continuous integration, scoring the agent against curated scenarios, so they serve as leading indi-
cators of regression. Production monitoring records what the agent actually did with real users. It
is the post-launch backstop and ﬁlls the role of the operational SLI layer. A/B testing compares
behavior against a control to detect business impact, and that is where lagging indicators get vali-
dated. The fourth layer, periodic human review, calibrates the other three, much as human-rated
samples calibrate an LLM judge. Agent benchmarks such as AgentBench add a multi-task, multi-
dimensional ofﬂine scoring surface, though they replace neither evals nor production monitoring
(Liu et al. 2023).
The less obvious point in the Anthropic guidance is that evals need an owner after they are written.
A benchmark suite written six months ago loses predictive power as the model, the user popula-
tion, and the available tools change. Budget for maintaining evals as well as creating them. Agent
programs commonly underfund this line item.
26.7 Deﬁning Benchmarks That Mean Something
A benchmark is useful only if it was designed to predict the outcome you care about. Most were
not. The trouble usually lies in how benchmarks get built, so careful teams hit it as often as careless
ones.
8

<!-- page 9 -->
26.7.1 The Benchmark Validity Problem
Ofﬂine benchmarks (scores on a ﬁxed test set) stand in for online performance (how the system be-
haves in production with real users), and the stand-in can be weak for several reasons. The test set
may leak information from the training data, or it may have been sampled when the world looked
different from the one the model now serves. The metric being optimized may differ from the one
the business outcome depends on. The model may also have learned to game the metric until the
score no longer tracks the underlying goal. As AI systems scale and engineering investment shifts
from training to evaluation, benchmark design increasingly decides whether a team can tell good
models from bad (Chang et al. 2024).
26.7.2 Goodhart’s Law in Its Weak and Strong Forms
Goodhart’s Law gives the clearest account of benchmark failure: when a measure becomes a target,
it ceases to be a good measure. El-Mhamdi and Hoang’s formal treatment splits it into two failure
modes with different operational consequences (El-Mhamdi and Hoang 2024).
In the weak form, optimizing the proxy stops correlating with the true goal, and the proxy
stops telling you anything. The benchmark score keeps climbing while production performance
plateaus. That is annoying but recoverable. The team can refresh the benchmark, change the
metric, or study the gap and recalibrate.
In the strong form, optimizing the proxy actively harms the true goal. The proxy becomes anti-
correlated with what the business cares about, so the benchmark score keeps improving while
production outcomes get worse. The chapter’s opening scenario is this case, and it is dangerous
because the team’s instruments say it is winning while the company hemorrhages value.
Gao, Schulman, and Hilton measured the strong form directly in reward model overoptimization
during reinforcement learning from human feedback. As a policy is optimized against a learned
proxy reward, the true reward ﬁrst rises and then falls, and the gap widens as optimization pres-
sure grows (Gao et al. 2022). Their result shows how proxy optimization can turn harmful, though
not every case of enterprise metric degradation follows exactly this pattern. For enterprise AI, the
lesson is that any benchmark you optimize against will eventually drift away from the goal it was
meant to predict. What you don’t know is how fast it will drift and whether you will notice in
time.
26.7.3 How to Build Valid Benchmarks
Five practices push benchmarks toward the weak form, which is recoverable, and away from the
strong form, which is catastrophic.
Representative test sets with proper baselines. Sample from production data instead of develop-
ment data, and refresh the test set as often as the user population and its surroundings change. A
retail recommender usually needs a quarterly refresh, a fast-moving customer support system a
monthly one, and a ﬁnancial fraud model a weekly one. Compare against the right baselines: the
current production model, a simple heuristic (for example, popularity-based recommendations), a
random baseline to set the performance ﬂoor, and, where relevant, a human expert. A model that
beats random but loses to the incumbent is a regression.
Temporal validation and label integrity. The test set must respect point-in-time correctness, with
no features that could not have been known at prediction time and no labels that leak future in-
9

<!-- page 10 -->
Figure 26.3: Goodhart’s Law in weak form (benchmark loses predictive power) versus strong form (bench-
mark optimization actively harms the goal).
formation. Label leakage often inﬂates ofﬂine scores that then collapse in production. To guard
against training-serving skew, conﬁrm that the feature pipelines used in evaluation match the ones
used in production serving.
Slice-based evaluation. Measure performance across subgroups (demographic segments, cus-
tomer tenure cohorts, product categories, geographies) and report the worst slice alongside the
aggregate, because aggregate metrics hide group-level failures. A model that scores 92% on av-
erage but 60% for a key segment is not a 92% model in any sense the business cares about. Slice
discovery now has empirical support. In a human evaluation of slice-discovery algorithms, practi-
tioners using the tools found underperforming subgroups more reliably than those without them,
although forming hypotheses (deciding which slices to look for) remained the limiting factor (John-
son et al. 2023). So slice-based evaluation needs both tooling and judgment, and adding a dash-
board column supplies neither.
Human evaluation baselines. For generative AI systems, human judgment is often the ground
truth for qualities like helpfulness, coherence, and appropriateness. For factual QA tasks, the
ground truth may be a database record, a source document, or a policy. Legal, medical, and com-
pliance tasks may require expert adjudication, and the team must measure how much annotators
disagree. Even when LLM-as-judge is used to scale evaluation, both the rubrics and the judge
model need regular calibration against human-rated samples (Chang et al. 2024).
Business-outcome-anchored thresholds. Set the ofﬂine threshold at the level that has historically
predicted acceptable business outcomes, rather than at a level that feels right. Recall@30d at least
70% is a defensible benchmark only if you can show that systems hitting it in the past delivered
the retention impact the business needs.
26.7.4 Benchmark Hygiene
The three hygiene rules below are countermeasures against the strong form of Goodhart’s Law.
10

<!-- page 11 -->
Figure 26.4: Five practices for building benchmarks that predict production performance rather than pro-
ducing false conﬁdence.
11

<!-- page 12 -->
1. Never report a single aggregate metric as the system’s performance. Report the distribution,
the worst-slice score, and the trend (Sculley et al. 2015).
2. Never set a benchmark threshold once and leave it. Revisit it when the business context,
the user base, or the model class changes. Evals need ongoing ownership (Grace et al. 2026).
3. Never use a benchmark as a deployment gate without also checking fairness metrics across
slices. A model that improves on aggregate while regressing on a protected group has gotten
worse.
26.7.5 Real-World Case Study: Netﬂix Measurement Framework
Netﬂix measures recommendation quality with ofﬂine metrics (precision and recall on held-out
user interactions) and refuses to act on them alone. Online A/B test metrics such as play rate,
completion rate, and retention carry the decision (Gomez-Uribe and Hunt 2015). Every signiﬁcant
model change is tested online against a control before full deployment. Ofﬂine benchmarks tell
you the model might work, and online tests tell you whether it does.
What Netﬂix does after the online test matters more. It ties online metrics back to lagging business
KPIs (long-run retention, hours streamed) on a controlled timeline that can run weeks or months,
and a win on play rate has to persist into retention before the team declares victory. With that
follow-through, the leading/lagging/guardrail framework works as an operating model instead
of hanging on a wall as a chart.
26.8 Guardrail Metrics: Encoding Risk Tolerance in Numbers
Guardrails turn governance into operational thresholds. They take the risk tolerance set by the AI
Governance Board (see Chapter 25) and convert it into speciﬁc, measurable conditions that trigger
intervention.
26.8.1 What Makes a Good Guardrail Metric
A guardrail metric worth the name has four properties.
It is speciﬁc: measurable in production, in near real time. “Performance should be acceptable” is
an aspiration, and no one can alert on it.
It is pre-agreed: governance, legal, product, and engineering set the thresholds together before
deployment. A guardrail set after a failure is a postmortem artifact.
It is actionable: the response to a breach is deﬁned in advance. Automatic rollback, escalation to
a named on-call rotation, human review, and system pause are all valid responses. Notifying the
team in Slack does not count on its own.
It is risk-proportionate: higher-risk systems need tighter guardrails and more coverage. A credit
decisioning model needs denser guardrails than a recommendation engine for streaming content,
and the risk tier assigned in governance says which guardrails are mandatory and which are op-
tional.
12

<!-- page 13 -->
26.8.2 Types of Guardrail Metrics
The table below lists the guardrail families that recur across enterprise AI deployments, with illus-
trative thresholds. The thresholds are there to make each category concrete, so do not copy them
as defaults. Set real thresholds from your system’s historical variation, its risk tier, the regulatory
requirements, and explicit governance approval. A KL-divergence threshold of 0.1, for example,
may suit one feature distribution and mean nothing for another, which is why thresholds should
come from backtesting against historical data and analyzing the alert budget.
Table 26.3: Guardrail metric families with illustrative thresholds and setting methodology.
Guardrail Type What It Protects Example Threshold Setting Methodology
Fairness / bias Demographic equity
in outcomes
Max 5 percentage
point disparity in
recall across
demographic groups
Based on regulatory
guidance, legal
review, historical
baseline
Safety / content Harmful outputs in
generative systems
Severity-1 content
ﬂags trigger
immediate human
review
Deﬁned by content
policy with
false-positive
tolerance speciﬁed
Latency SLA User experience and
downstream systems
p99 latency must not
exceed 500ms
Based on user
research, downstream
SLA dependencies
Conﬁdence ﬂoor High-stakes decisions Predictions below
threshold
(calibration-validated)
routed to human
review
Set via precision-recall
tradeoff analysis at
decision point
Cost ceiling Financial exposure Daily inference cost
alert at 80% of budget;
pause at 110%
Based on approved
budget with ﬁnance
sign-off
Drift threshold Data and model
stability
Distribution distance
exceeding baseline + 3
standard deviations
triggers review
Learned from
historical variation in
production data
Two of these deserve a closer look. The latency SLA is the canonical SRE SLO adapted to AI. It has
an SLI (p99 latency), a target (less than 500ms), and an error budget (the fraction of requests allowed
to exceed the target before further deployments pause) (Thurgood et al. 2018). The drift threshold
works less as a goal than as the mechanism that makes a guardrail operational. Feature drift detec-
tion (KL-divergence, population stability index, Jensen-Shannon divergence, or a domain-speciﬁc
distance) warns early and prompts a retraining decision before the lagging business metric moves.
KL-divergence can be unstable with sparse bins and depends on scale, so consider alternatives or
ensemble approaches, and always validate thresholds against historical production variation.
13

<!-- page 14 -->
26.8.3 Fairness Metrics Precision
The “5 percentage point disparity” example needs unpacking, because fairness metrics come in
several forms with different implications:
• Demographic parity: equal positive prediction rates across groups
• Equal opportunity: equal true positive rates across groups
• Predictive parity: equal precision across groups at a given prediction threshold
• Calibration by group: a given score means the same probability of the outcome in every
group
• Exposure parity (for recommendations): items or item providers receive exposure in propor-
tion to their relevance, instead of having it concentrated by position or popularity
The retail use case later in this chapter uses equal opportunity: recall must not differ by more than 8
percentage points across declared demographic segments. Its threshold is 8 points rather than the
table’s illustrative 5 because each system’s governance board sets its own number from historical
variation and risk tier, as described above. The harm the team most wants to prevent there is a
false negative, meaning a relevant recommendation that an underserved segment never sees.
Privacy and legal constraints make fairness harder to measure. In some jurisdictions, collecting
protected-class attributes is itself regulated or prohibited. Work with legal and privacy stakehold-
ers to decide what demographic data can be collected, how it must be handled, and whether proxy-
based fairness measurement is appropriate.
26.8.4 Content Safety Guardrails in Practice
“Zero tolerance for ﬂagged content” is aspirational language until someone makes it operational.
Content classiﬁers produce false positives and false negatives, so a production content safety
guardrail should specify:
• Severity categories (e.g., Severity-1: immediate harm, Severity-2: policy violation, Severity-3:
edge case)
• Detection threshold and conﬁdence requirements
• Review path for each severity level
• Acceptable false-positive rate and user experience impact
• Escalation policy and response SLA
• Sampling and audit process for ongoing calibration
Amazon Bedrock Guardrails is a managed implementation of content safety controls that can en-
force these policies for LLM applications.
26.8.5 Guardrail Response Playbook
Deﬁne the response to each guardrail breach before it happens. The table below shows one way to
structure the playbook:
14

<!-- page 15 -->
Table 26.4: Guardrail response playbook with severity, action, ownership, and escalation.
Breach Type Severity
Automated
Action
Human
Owner Triage SLA
Governance
Notiﬁcation
Latency SLA P2 Auto-scale;
alert on-call
Platform SRE 15 minutes Weekly
summary
Cost ceiling
(80%)
P3 Alert FinOps FinOps lead 4 hours None unless
persistent
Cost ceiling
(110%)
P1 Pause
inference;
alert
FinOps + ML
lead
15 minutes Immediate
Fairness
threshold
P2 Shadow
mode; alert
ML lead +
Governance
4 hours Same-day
notiﬁcation
Content
safety Sev-1
P1 Block
response;
human
review
Trust & Safety Immediate Immediate
Drift
threshold
P3 Alert; trigger
retraining
review
ML
Engineering
24 hours Weekly
summary
26.8.6 Guardrail Governance Process
For any Tier 2 or higher system, the AI Governance Board reviews and approves the thresholds.
They are documented in the model card with the rationale for each value (Mitchell et al. 2019), and
they change only through the same approval process that allowed the original deployment. Do
not assume the industry already does this well. Stanford’s Foundation Model Transparency Index
scores major model developers on documentation and disclosure and ﬁnds the practice uneven,
with wide gaps between developers (Bommasani et al. 2024). Requiring the model card to hold the
guardrail rationale closes that gap inside your own organization. Because a guardrail threshold
is a governance decision put into operation, no engineer can change one alone. When someone
wants to relax a guardrail to ship faster, the governance process should slow them down, and if it
doesn’t, the guardrail is decorative.
26.9 Experimentation and Online Validation
Even with benchmarks and guardrails in place, a gap remains between ofﬂine evaluation and busi-
ness impact. Controlled experimentation closes it.
26.9.1 A/B Testing Fundamentals
An A/B test compares a treatment (the new model) against a control (the current production model,
not “no model”) on randomly assigned users. The main design considerations:
• Power analysis: determine the sample size needed to detect the smallest effect that matters
to the business with acceptable conﬁdence (typically 80% power, 95% conﬁdence).
15

<!-- page 16 -->
Figure 26.5: Guardrail severity tiers with corresponding automated actions, ownership, and escalation time-
lines.
16

<!-- page 17 -->
• Minimum detectable effect: what is the smallest improvement worth detecting? That is a
business decision, and statistics cannot make it for you.
• Runtime: how long must the test run to capture the user behavior cycle that drives the lag-
ging KPI?
• Sequential testing and peeking: looking at results before the test completes raises the false-
positive rate. Use sequential testing methods if you need to stop early.
• Multiple comparisons: testing many metrics or slices at once requires a correction (e.g., Bon-
ferroni) or pre-registration of the primary metric.
26.9.2 Recommendation System Challenges
Recommendation systems make experiments harder in several ways:
• Interference effects: users inﬂuence item popularity and inventory levels, which creates
network effects between the treatment and control groups.
• Feedback loops: the recommendation system shapes its own future training data, which
confounds results over time.
• Novelty effects: users may engage more with any change at ﬁrst, so tests need to run longer.
• Cannibalization: the treatment may shift purchases around instead of creating incremental
value.
• Seasonality: a test that spans a major shopping period may mix the treatment effect with
seasonal variation.
When randomized tests are impractical or contaminated, teams sometimes need counterfactual
evaluation and causal inference techniques such as difference-in-differences and synthetic control.
26.9.3 Shadow Deployment and Canary Release
Shadow and canary releases usually come before a full A/B test. They validate latency, error
rate, and cost on real trafﬁc with little or no user exposure. Chapter 24 covers how to choose and
run them. For this chapter, what matters is that they report the same metrics the pyramid and
guardrails deﬁne.
26.10 Implementing the Metrics Framework on AWS
Each measurement need maps to speciﬁc AWS services:
Table 26.5: AWS services for implementing the AI metrics framework.
Measurement Need AWS Service Options
Service metrics and alarms Amazon CloudWatch Metrics, CloudWatch
Alarms
Logs and distributed tracing CloudWatch Logs, AWS X-Ray, OpenTelemetry
ML model monitoring Amazon SageMaker Model Monitor
Bias and explainability SageMaker Clarify
Model documentation SageMaker Model Cards
LLM safety guardrails Amazon Bedrock Guardrails
17

<!-- page 18 -->
Measurement Need AWS Service Options
LLM evaluation Amazon Bedrock model evaluation, custom
eval harnesses
Operational dashboards Amazon Managed Grafana
Business intelligence dashboards Amazon Quick Sight (formerly QuickSight)
Cost monitoring and controls AWS Budgets, Cost Explorer, Cost Anomaly
Detection
Event routing and alerting Amazon EventBridge, Amazon SNS, AWS
Lambda
Experiment tracking SageMaker MLﬂow App
Data quality monitoring AWS Glue Data Quality, Deequ (open source
on AWS)
A typical architecture for the three dashboard views described in Stakeholder Views below:
• Operations layer: Amazon Managed Grafana connected to CloudWatch Metrics, SageMaker
Model Monitor outputs, and custom metrics pushed through CloudWatch embedded metric
format. Shows real-time latency percentiles, error rates, and drift indicators.
• Product layer: Quick Sight connected to a data lake or warehouse that aggregates user behav-
ior metrics, A/B test results from SageMaker MLﬂow App, and leading indicator calculations.
Refreshes daily.
• Executive layer: Quick Sight with a curated dataset of business KPIs, cost trends from Cost
Explorer, and guardrail status aggregated from CloudWatch Alarms. Presented as a weekly
executive summary.
Infrastructure as code for this architecture uses Terraform (the book’s standard) or AWS
CDK. Typical Terraform resources include aws_cloudwatch_metric_alarm for SLO thresholds,
aws_budgets_budget for cost ceilings, and aws_sns_topic for alert routing.
26.11 The Metric Pyramid: Connecting Model Metrics to Business Out-
comes
Engineers talk about F1 scores, and executives talk about revenue impact. Most AI programs fail
to translate between the two, and at ﬁrst nobody notices. The technical team optimizes a number
that does not reliably predict the executive outcome, while the executive team decides on a number
whose technical foundation it does not trust. Translating business objectives into ML objectives
takes an ongoing conversation among product, business, and engineering stakeholders, one that
continues after the ﬁrst mapping is written down (Huyen 2022).
This book structures that conversation with a four-layer metric pyramid. Its rule is simple and
strict: a model improvement counts as a business improvement only when a continuous, instru-
mented chain of causation connects the two.
The pyramid has four layers.
Layer 1: Model and system metrics (base). Accuracy, F1, AUC, latency, throughput, error rate,
drift indicators, cost per inference. Engineering teams measure these natively. You cannot do
without them, and they are never enough on their own.
18

<!-- page 19 -->
Figure 26.6: AWS architecture implementing the three-layer dashboard pattern with services for monitoring,
alerting, and business intelligence.
Layer 2: Model output metrics. What the model produces in production, measured where the
output leaves the model. For a recommender, this means which items it recommends and how
their predicted relevance is distributed. For a fraud model, it means which scores it assigns and
how that distribution compares to a historical reference. These metrics show whether the model
does what it was designed to do on live trafﬁc.
Layer 3: User experience metrics. What users, or workﬂows, do in response to the model’s outputs.
For a recommender: click-through rate, add-to-cart rate, dwell time on recommended items. For
a fraud model: human-reviewer override rate and dispute rate on auto-blocked transactions. This
is the layer where the model’s outputs meet the decision the system is supposed to inﬂuence.
Layer 4: Business outcome metrics (apex). What the business measures: revenue, cost, risk expo-
sure, customer satisfaction. It is also the only layer the CFO asks about.
Table 26.6: The metric pyramid with four layers, ownership, and common failure modes.
Layer Question Example Metrics Owner Failure Mode
Business
outcomes (apex)
What value did
we create?
Revenue lift, cost
savings, loss
prevented, CSAT
delta
Finance, business
unit
Claiming credit
without causal
evidence
19

<!-- page 20 -->
Layer Question Example Metrics Owner Failure Mode
User experience Did behavior
change?
Click-through
rate, conversion
rate, resolution
time
Product
management
Confounding
behavior change
with external
factors
Model output Did the model
do what we
expected?
Recommendation
distribution,
score
distribution
vs. reference
Data science Assuming
output change
equals outcome
change
Model and
system (base)
Did the model
and
infrastructure
perform?
AUC, latency,
drift, error rate,
cost per inference
Engineering Optimizing
metrics that do
not propagate
upward
You can traverse the pyramid in two directions.
Top-down decomposition. Start from a business objective (“reduce customer churn by 15 percent”)
and break it down through UX (“increase engagement of at-risk customers in the 30 days before
renewal”) to model output (“identify the top decile of at-risk renewals with enough lead time to
intervene”) to model and system metrics (“recall at top-decile threshold of 0.65 or better, prediction
latency under 200 ms”). This direction tells engineering teams what to optimize.
Bottom-up veriﬁcation. When the model improves at the base, check that the improvement carries
upward. If a two-point accuracy gain leaves the output distribution, user response, and business
outcomes unchanged, a number went up and the business stayed where it was.
Teams that run both traversals can show how a model gain becomes business value. Teams that
skip them have plenty of numbers and no argument connecting them.
Attribution stays difﬁcult even with the pyramid (Chapter 30 addresses it in detail). The pyramid
earns its credibility by making the chain of reasoning visible, so others can audit it. Huyen’s eval-
uation framework for production ML reaches a compatible conclusion: production systems have
to be evaluated end-to-end against business objectives, rather than piece by piece against technical
proxies (Huyen 2022).
Drawing the pyramid is easy. Making it hold takes three habits:
1. Validate historically. When this engineering metric moved in the past, did the business
outcome move in the predicted direction?
2. Test the causal link with controlled experiments (see Experimentation and Online Validation
above), in addition to checking the correlation.
3. Review with governance so the translation logic is documented and agreed upon.
When a metric fails to predict the outcome the business cares about, throw it out, however clean it
looks technically.
The pyramid organizes the rest of Part 4. Chapter 27 instruments its bottom two layers, Chapter 29
uses it to test whether a cost optimization actually holds, Chapter 30 uses bottom-up traversal as
20

<!-- page 21 -->
Figure 26.7: The metric pyramid establishes a traversal discipline connecting model-level metrics to business
outcomes through veriﬁable causation chains.
21

<!-- page 22 -->
its attribution discipline, and Chapter 31 uses it to route operational signals to the right decision-
makers.
26.12 Stakeholder Views: One System, Multiple Dashboards
The same underlying metrics have to serve very different audiences, and each audience reads a
different part of the pyramid. Engineering works in the bottom two layers in real time, product
owns the user-experience layer on a daily cadence, and executives read the apex weekly. Each
view needs its own vocabulary, update frequency, and decision context. Teams often build one
dashboard for everyone instead. It ends up too aggregated for engineers and too technical for
executives, and neither audience trusts it. Build three views of one source of truth.
26.12.1 Engineering View
On-call engineers watch the engineering dashboard continuously, so it updates in real time and
packs in detail. It shows model conﬁdence distributions broken down by request type, feature-
drift indicators for the top features, inference-latency percentiles (p50, p95, p99), error rates by
error class, pipeline success rates by stage, GPU utilization, and queue depths. Its job is to surface
anomalies and failures quickly enough to intervene before the impact spreads.
26.12.2 Product View
The product dashboard refreshes daily, breaks results down by segment, and ties them to product
KPIs. It shows user-facing quality signals like CTR, engagement, and satisfaction scores, A/B test
status with effect sizes and conﬁdence intervals, the leading indicators that map to the product
strategy, and guardrail status colored by severity. Product managers should own this view and its
user behavior metrics, while ML Engineering owns the model quality metrics that feed it.
26.12.3 Executive View
The executive dashboard is a weekly summary, stated in money wherever possible. It shows busi-
ness impact against baseline (revenue lift, retention lift, cost savings), cost-efﬁciency trends (cost
per attributed outcome and its trajectory), risk status (are any guardrails close to breach, and how
much error budget remains?), and a comparison with the original investment thesis. Leaders use
it to make resource, prioritization, and risk decisions without false precision. A leader who has
not been close to the system that week should be able to read it in ﬁve minutes.
26.12.4 Metric Ownership Model
Give every metric category a named owner. Metrics without one end up orphaned or disputed:
Table 26.7: Metric ownership by category.
Metric Category Primary Owner Stakeholders
Model quality (technical
accuracy, calibration)
ML Engineering Product, Governance
Operational SLIs/SLOs Platform/SRE ML Engineering, Product
22

<!-- page 23 -->
Metric Category Primary Owner Stakeholders
User behavior (CTR,
engagement, leading
indicators)
Product Management ML Engineering, Business
Cost efﬁciency FinOps ML Engineering, Finance
Fairness and safety guardrails Governance/Legal/Risk ML Engineering, Product
Business outcomes (lagging
KPIs)
Business Sponsor Product, Finance
26.13 Use Case: Retail Customer Acquisition and Retention
The retail AI portfolio from earlier in the book now gets its full metrics framework. The portfolio
has two related systems. A recommendation engine personalizes product recommendations on the
home page, category browse pages, and cart upsell slot, and a churn prediction model identiﬁes
customers at risk of lapsing. This section concentrates on the recommendation engine. The churn
model appears in the exercises.
The business goal is to grow average order value (AOV) and the 90-day repeat purchase rate with-
out hurting conversion or breaking the company’s fairness commitments to underserved customer
segments.
26.13.1 Decomposing the Pyramid
The framework starts with a top-down pass through the pyramid, from business goal to opera-
tional measurement:
The table below lists each metric in the tree with its target and pyramid layer.
Table 26.8: Metric pyramid decomposition for the retail recommendation engine.
Branch Level Metric Target
Pyramid
Layer
Goal Enterprise goal Increase proﬁtable customer
retention
Strategic goal 4: Business
outcome
Retention Product KPI 90-day repeat purchase rate +5% 4: Business
outcome
Retention Leading
indicator
Add-to-cart rate from
recommendations
Tracked
vs. control
3: User
experience
Retention Model metric NDCG@10 on next-purchase
candidates
No regression
vs. production
model
1: Model and
system
Basket
size
Product KPI Average order value +3% 4: Business
outcome
Basket
size
Leading
indicator
Higher-margin category
exposure
Tracked
vs. control
3: User
experience
23

<!-- page 24 -->
Branch Level Metric Target
Pyramid
Layer
Basket
size
Model output
metric
Category diversity in top-10
recommendations
Tracked
vs. reference
period
2: Model
output
Shared Operational SLI
and guardrail
p99 serving latency < 200 ms 1: Model and
system
Guardrail Business
guardrail
Conversion rate No decrease
vs. control
3: User
experience
Guardrail Fairness
guardrail
Recall disparity across
demographic segments
< 8 percentage
points
1: Model and
system
Guardrail Cost guardrail Daily inference cost < 110% of
budget
1: Model and
system
The retention branch has no Layer 2 output metric yet. The team should close that gap ﬁrst, because
without it no one can trace an NDCG gain to a change in what customers are actually shown.
Read top-down, the decomposition tells engineering what to optimize. Read bottom-up, it is the
veriﬁcation chain: an NDCG gain that does not move add-to-cart rate, and then repeat purchases,
has created no value. The same artifact serves both audiences.
26.13.2 Wiring the Pyramid into Operations
The recommendation engine’s pyramid reaches operations through the three stakeholder views:
• Engineering dashboard (real-time, Grafana over CloudWatch + SageMaker Model Monitor):
NDCG@10 by hour, p50/p95/p99 latency, error rate by class, feature drift indicators for the
top 20 features, fairness disparity tracked daily.
• Product dashboard (daily, Quick Sight on Athena): add-to-cart rate from recommendations,
A/B test status with effect sizes and conﬁdence intervals, leading indicators against the 90-
day repeat-purchase target, guardrail status in red/yellow/green.
• Executive AI Performance Scorecard (weekly): revenue lift vs. control, cost per dollar of at-
tributed revenue, error budget remaining, guardrail status summary, and a plain-language
note on what the operational team is working on.
Every threshold in the tree is documented in the recommendation engine’s model card with its ra-
tionale, its owner, and the approval record from the AI Governance Board (Chapter 25). Changing
a threshold requires the same approval level as the original deployment.
26.14 Key Takeaways
• Measure across all four dimensions simultaneously. Technical quality, operational reliabil-
ity, cost efﬁciency, and business impact depend on one another. AI that succeeds on paper
and fails in production usually got there by optimizing one of them in isolation.
• Goodhart’s Law is the central failure mode this chapter returns to. Once a proxy metric
becomes a deployment gate or compensation target, optimization pressure widens the gap
between the proxy and the underlying business goal. The weak/strong distinction tells you
24

<!-- page 25 -->
Figure 26.8: The three-layer dashboard pattern: operations (real-time, granular), product (daily, segmented),
and executive (weekly, summarized).
25

<!-- page 26 -->
Figure 26.9: Top-down decomposition of the metric pyramid from enterprise goal through product KPIs,
leading indicators, and model metrics to operational SLIs and guardrails.
26

<!-- page 27 -->
whether over-optimization is merely wasteful or actively harmful, and in the strong case
guardrails are mandatory (El-Mhamdi and Hoang 2024; Gao et al. 2022).
• Leading indicators warn you early; lagging indicators tell you whether the bet worked.
Find out which upstream signals actually predict the downstream outcomes you care about,
and validate that link with data instead of asserting it.
• Guardrail metrics encode risk tolerance in numbers. Set thresholds with governance before
deployment, document them and their rationale in the model card, and change them only
through the approval channel used for the original deployment (Mitchell et al. 2019).
• Ofﬂine benchmarks only approximate online performance. Refresh test sets from produc-
tion data on a schedule, evaluate across slices as well as in aggregate, and validate against
business outcomes. Test every signiﬁcant change online before full rollout (Gomez-Uribe
and Hunt 2015; Johnson et al. 2023).
• SLIs, SLOs, and error budgets give engineering a precise deﬁnition of “reliable enough.”
Adopt the SRE discipline explicitly, including the principle that 100% uptime is the wrong
goal, and add the ML-speciﬁc SLIs: data freshness and pipeline throughput, which Google
Cloud’s SRE guidance emphasizes, plus tail serving latency (Thurgood et al. 2018; Saltonstall
and Virji 2025).
• The metric pyramid connects model metrics to business outcomes. Decompose top-down
to tell engineering what to optimize, and verify bottom-up that improvements actually carry
through. Validate each link historically and with controlled experiments, and drop metrics
that do not predict the outcome (Huyen 2022).
• One source of truth, three views. Engineering, product, and executive dashboards read
different layers of the pyramid on different cadences, so design each one for its audience
rather than asking a single dashboard to serve everyone.
26.15 Apply It
1. Four-dimensional metrics framework. For the retail recommendation engine, deﬁne at least
two speciﬁc metrics for each of the four performance dimensions (technical quality, opera-
tional reliability, cost efﬁciency, business impact). For each metric, specify what it measures,
how it is calculated, who owns it, how often it updates, and the immediate downstream
decision it informs.
2. Three-layer dashboard sketch. Design the engineering, product, and executive dashboard
views for the retail churn prediction model. For each view, list the ﬁve most important met-
rics, the update cadence, and the main decision the view supports. If a metric appears on
more than one dashboard, explain why or remove it.
3. Guardrail speciﬁcation with governance record. Deﬁne the full guardrail set for the churn
prediction model. For each guardrail, specify the metric, the threshold, the response protocol
when the threshold is breached, the approver, and where it is documented in the model card.
Identify which guardrails you would tighten or loosen if the model moved from internal
pilot to customer-facing production.
4. Benchmark audit. Evaluate the churn model’s benchmark design against the three hygiene
rules and ﬁve benchmark practices from this chapter. Is the test set sampled from produc-
tion and refreshed periodically? Is performance evaluated across customer tenure and de-
mographic slices? Does the threshold connect to a stated business outcome? Has the team
27

<!-- page 28 -->
checked for strong Goodhart effects? Identify the top two benchmark validity problems and
write the remediation plan.
5. Pyramid decomposition for your own system. For an AI system you are currently responsi-
ble for (or a hypothetical one), decompose the metric pyramid from enterprise goal → prod-
uct KPI → user behavior leading indicator → model metric → operational SLI, tagging each
line with its pyramid layer. Mark which links in the chain are validated with data and which
are assumed. For each assumed link, write the experiment you would run to validate it.
6. AI prompt. “You are an AI measurement specialist reviewing the following metrics framework for
an enterprise recommendation system. Identify: (1) which leading indicators are most likely to predict
degradation in lagging business KPIs, (2) any guardrail gaps that leave material risk unmonitored, (3)
any Goodhart’s Law exposure where the proxy could be over-optimized in ways that harm the under-
lying goal, and (4) whether the benchmark design will produce a valid signal in production. Provide
concrete remediation recommendations ordered by expected impact: [paste your metrics framework
from Exercise 1].”
26.16 What’s Next
A metrics framework deﬁnes what you will measure to know whether the system is working. The
next job is watching those measurements continuously in production. You need to catch drift,
degradation, and anomalies before they breach guardrails or reach customers, and you need to
manage the model lifecycle so degraded systems are retired, retrained, or replaced on a disciplined
schedule rather than in a panic. The next chapter, Monitoring, Observability & Model Lifecycle Man-
agement, covers the instrumentation, alerting, retraining triggers, and rollback machinery that keep
your measurement framework tied to operational reality.
26.17 References
Aryan, Abi. 2025. LLMOps: Managing Large Language Models in Production. O’Reilly Media.
Bommasani, Rishi, Kevin Klyman, Shayne Longpre, et al. 2024. The Foundation Model Transparency
Index. https://doi.org/10.48550/arXiv.2310.12941.
Breck, Eric, Shanqing Cai, Eric Nielsen, Michael Salib, and D. Sculley. 2017. “The ML Test Score:
A Rubric for ML Production Readiness and Technical Debt Reduction.” 2017 IEEE International
Conference on Big Data (Big Data), 1123–32.
Chang, Yupeng, Qiang, Yang, Xu Wang, et al. 2024. “A Survey on Evaluation of Large Language
Models.” ACM Transactions on Intelligent Systems and Technology, ahead of print. https://doi.or
g/10.1145/3641289.
El-Mhamdi, El-Mahdi, and Lê-Nguyên Hoang. 2024. On Goodhart’s Law, with an Application to Value
Alignment. https://doi.org/10.48550/arXiv.2410.09638.
Gao, Leo, John Schulman, and Jacob Hilton. 2022. Scaling Laws for Reward Model Overoptimization.
https://doi.org/10.48550/arXiv.2210.10760.
28

<!-- page 29 -->
Gomez-Uribe, Carlos A., and Neil Hunt. 2015. “The Netﬂix Recommender System: Algorithms,
Business Value, and Innovation.” ACM Transactions on Management Information Systems 6 (4):
1–19. https://doi.org/10.1145/2843948.
Grace, Mikaela, Jeremy Hadﬁeld, Rodrigo Olivares, and Jiri De Jonghe. 2026. Demystifying Evals for
AI Agents. Https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents; An-
thropic Engineering Blog.
Huyen, Chip. 2022. Designing Machine Learning Systems: An Iterative Process for Production-Ready
Applications. O’Reilly Media.
Järvelin, Kalervo, and Jaana Kekäläinen. 2002. “Cumulated Gain-Based Evaluation of IR Tech-
niques.” ACM Transactions on Information Systems 20 (4): 422–46. https://doi.org/10.1145/58
2415.582418.
Johnson, Nari, Ángel Alexander Cabrera, Gregory Plumb, and Ameet Talwalkar. 2023. “Where
Does My Model Underperform? A Human Evaluation of Slice Discovery Algorithms.” AAAI
Conference on Human Computation and Crowdsourcing (HCOMP) 11: 65–76. https://doi.org/10
.48550/arXiv.2306.08167.
Liu, Xiao, Hao Yu, Hanchen Zhang, et al. 2023. AgentBench: Evaluating LLMs as Agents. https:
//doi.org/10.48550/arXiv.2308.03688.
Mitchell, Margaret, Simone Wu, Andrew Zaldivar, et al. 2019. “Model Cards for Model Reporting.”
Proceedings of the Conference on Fairness, Accountability, and Transparency (FAccT), 220–29. https:
//doi.org/10.1145/3287560.3287596.
Saltonstall, Max, and Salim Virji. 2025. An SRE’s Guide to Optimizing ML Systems with MLOps
Pipelines. Https://cloud.google.com/blog/products/devops-sre/applying-sre-principles-to-
your-mlops-pipelines; Google Cloud Blog.
Sculley, D., Gary Holt, Daniel Golovin, et al. 2015. “Hidden Technical Debt in Machine Learning
Systems.” Advances in Neural Information Processing Systems (NeurIPS) 28: 2503–11.
Thurgood, Steven, David Ferguson, Alex Hidalgo, and Betsy Beyer. 2018. “Implementing SLOs.”
In The Site Reliability Workbook: Practical Ways to Implement SRE. O’Reilly Media.
29