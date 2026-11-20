# Ch20-Model-Development.pdf (extracted text, 25 pages)

<!-- page 1 -->
Chapter 20
Model Development: Training,
Fine-Tuning, RAG, and Orchestrating
Intelligence
20.1 Motivation
Only a few years ago, building an AI system meant training a model. You collected data, engi-
neered features, trained a classiﬁer or regressor, evaluated it, and deployed it. That was the job.
The skills were well-deﬁned, the toolchain was stable, and success was measured in AUC and
precision scores.
Today, there are many approaches for developing AI systems. In some cases, enterprise teams
never train a model at all. They orchestrate one. They connect a foundation model to a retrieval
system, wrap it in a prompt, run it through a validation layer, and ship it. Or they build an agent
that reasons across tools, memory, and APIs to complete multi-step tasks. The deﬁnition of “build-
ing AI” has expanded dramatically.
The expansion creates a navigation problem. A team assigned to “build an AI system” for customer
service automation now faces six fundamentally different approaches: training traditional ML,
prompting, ﬁne-tuning, training custom models, retrieving (RAG), and orchestrating. Each carries
different timelines, costs, skill requirements, and failure modes. The right answer depends not on
which technique is most sophisticated, but on what the problem actually requires.
Choosing wrong is expensive. Organizations spend months training models when well-designed
prompts would have worked. Teams ﬁne-tune foundation models to “teach” them proprietary
knowledge, which ﬁne-tuning cannot reliably do, when a RAG pipeline would have delivered
better results faster and cheaper. Agentic systems are deployed without reliability engineering
and silently degrade in production.
This chapter covers the full spectrum: when to use traditional ML, when to train custom models,
when to ﬁne-tune, when to use RAG, when to engineer prompts, and when to build agents. It also
covers how to execute each approach at production quality on AWS while keeping it reproducible,
versioned, and auditable regardless of the path taken. Getting this right is the difference between
an AI capability and an AI system.
1

<!-- page 2 -->
20.2 Challenge
How do you select the right AI development approach for your use case, and then execute it with
the discipline, tooling, and infrastructure that production systems require, across the full spectrum
from traditional ML to LLM orchestration to autonomous agents?
20.3 Objectives
By the end of this chapter, you will be able to:
1. Select the appropriate development approach based on use case requirements: traditional
ML, custom training, ﬁne-tuning, RAG, prompting, or agents
2. Apply a structured model training process, including experiment tracking and rigorous eval-
uation
3. Design a ﬁne-tuning pipeline for adapting foundation models to enterprise use cases using
parameter-efﬁcient methods
4. Construct effective RAG systems and decide when retrieval augmentation is the right solu-
tion versus ﬁne-tuning
5. Design agent architectures that are reliable, observable, and safe for enterprise deployment
6. Engineer and version prompts as ﬁrst-class production artifacts
7. Establish reproducibility and model versioning practices that satisfy both engineering and
regulatory requirements
20.4 Interface with Previous Chapters
This chapter opens the core technical sequence of Part 3, Build, and receives its mandate directly
from Part 2, Design. From Chapter 11, it inherits the AI product requirements document: the per-
formance thresholds, data dependencies, evaluation criteria, and failure mode speciﬁcations that
deﬁne what a working model actually means for the speciﬁc use case. From Chapter 13, it receives
the sequenced delivery plan that establishes which capabilities to build ﬁrst and the data readiness
gates each development phase depends on. The platform and infrastructure chapters that precede
this one in Part 3 supply the compute environment, feature store, and MLOps tooling that make
training, ﬁne-tuning, and RAG pipelines reproducible at production quality. The primary output
of this chapter is the production-ready model stack: trained models, ﬁne-tuned foundation mod-
els, RAG pipelines, agent architectures, and versioned prompt artifacts. These ﬂow downstream
to the testing chapter for formal evaluation against the thresholds deﬁned in the AI-PRD, then
to the deployment chapter for production delivery, and eventually reach Chapter 27 for ongoing
lifecycle management.
20.5 The Development Spectrum: Choosing Your Approach
The most consequential architectural decision in AI development is not which framework to use or
which cloud to deploy on. It is choosing where on the development spectrum to build: how much
to customize, how much to build from scratch, and how much to leverage what already exists.
The spectrum runs from maximum customization (training from scratch on proprietary data) to
maximum leverage (prompt engineering against a foundation model API). Each position on the
2

<!-- page 3 -->
spectrum represents a different tradeoff among time, cost, control, and ceiling. The rule that guides
the choice is one of the most consistently validated in production ML: start at the simpler end
and move toward greater complexity only when you have clear evidence that simpler approaches
cannot solve the problem (Zinkevich 2017). The corollary is equally important: do not stay at the
simple end when you have clear evidence that it is failing.
Five development approaches (select for each component of your system):
Table 20.1: The Development Spectrum: Choosing Your Approach — Approach, When to Use, Time to
Value, Cost, Control.
Approach When to Use
Time to
Value Cost Control
Train traditional ML Structured/tabular data, interpretability
requirements, latency constraints
Weeks Low–
Medium
High
Train a custom LLM Unstructured inputs, large proprietary
datasets, no suitable foundation model
Months Very
high
Maximum
Fine-tune a
foundation model
Adapt general capability to speciﬁc domain,
style, or task format
Weeks Medium–
High
High
RAG (Retrieval-
Augmented
Generation)
Ground LLM outputs in proprietary, current,
or conﬁdential knowledge
Days–
weeks
Medium Medium
Prompt engineering General tasks, standard capabilities, rapid
iteration
Hours–
days
Low Limited
Agent orchestration sits above the ﬁve approaches as a separate architectural layer, composing
them into systems capable of multi-step reasoning and dynamic action: a ReAct agent uses prompt-
ing internally; an agent with RAG tools uses retrieval; an agent built on a ﬁne-tuned model uses
ﬁne-tuning. Most enterprise AI systems combine multiple development approaches within one or
more agent orchestration layers. Agent architecture is covered in its own section.
The decision framework:
1. Is the data primarily structured and tabular? If yes, start with traditional ML before consid-
ering neural networks or foundation models.
2. Does a capable foundation model exist for this task? If no, return to Question 1 and train a
custom model using the appropriate approach for the data type.
3. Is the task domain-speciﬁc enough that general LLM knowledge is insufﬁcient? If yes, ﬁne-
tune or use RAG.
4. Does the task require proprietary, frequently updated, or conﬁdential knowledge? If yes, use
RAG.
5. Does the task require multi-step reasoning, tool use, or autonomous decision-making? If yes,
add an agent orchestration layer over whichever development approach you selected.
6. Is speed to production the primary constraint? If yes, start with prompting, validate, then
invest.
The most common and expensive mistake is jumping to ﬁne-tuning or training before validating
that prompting cannot solve the problem. Fine-tuning is expensive, slow, and hard to iterate on.
3

<!-- page 4 -->
Figure 20.1: The AI development spectrum trades speed, cost, and control; simpler approaches deliver faster
but constrain customization.
Prompting is cheap, fast, and frequently sufﬁcient. Organizations have been documented as spend-
ing $200K or more to ﬁne-tune foundation models on problems where a $20K RAG pipeline de-
livered better results. Always validate the simpler approach ﬁrst, with production-representative
data, before investing in the next level of complexity.
20.6 Prompt Engineering
Prompt engineering is the practice of designing, structuring, and iterating on inputs to founda-
tion models to elicit reliable, high-quality outputs. For most enterprise teams, it is the highest-ROI
development technique in this chapter: no training data, no GPU compute, no deployment infras-
tructure beyond the API call.
Four techniques form the core toolkit. System prompts deﬁne the model’s role, constraints, output
format, and behavioral guardrails. A well-constructed system prompt is the primary behavioral
contract of an LLM application; changes to it are changes to the application. Few-shot prompting
provides two to ﬁve labeled examples of the target pattern before presenting the actual query; the
quality of the examples matters more than their quantity. Chain-of-thought elicitation instructs
the model to reason step by step before answering; it improves accuracy on multi-step reasoning
tasks at the cost of added latency. Structured output enforcement constrains responses to a deﬁned
format (typically JSON with a schema), enabling reliable downstream processing.
Treat prompts as code. Every prompt belongs in a version-controlled repository, changes go
through review, and every production deployment references a speciﬁc commit. Run a ﬁxed
regression evaluation suite on every prompt change to detect behavioral drift before it reaches
production. Pin foundation model versions to a speciﬁc version string (e.g., claude-sonnet-4-5-
20250514) rather than a capability alias; provider updates change model behavior silently.
Prompt engineering is a deep discipline with its own body of practice. Anthropic, OpenAI, and the
4

<!-- page 5 -->
Figure 20.2: Use this decision framework to navigate from problem requirements to the appropriate develop-
ment approach.
open-source DAIR.AI Prompt Engineering Guide each publish comprehensive reference guides
on techniques; any team treating prompts as production artifacts should treat these as required
reading.[^pe]
Anthropic Prompt Engineering documentation: https://docs.anthropic.com/en/docs/build-
with-claude/prompt-engineering/overview. OpenAI Prompt Engineering Guide: https://platform.openai.com/docs/guides/prompt-
engineering. DAIR.AI Prompt Engineering Guide: https://www.promptingguide.ai
20.7 Training Custom Models
Most enterprise AI problems do not require training from scratch. When they do, it is almost al-
ways for one of a few speciﬁc reasons: the problem involves proprietary data with no foundation-
model analog, the latency or cost proﬁle rules out large-model inference, or the regulatory context
prohibits external data transmission. Anything outside these criteria should be treated as a candi-
date for the simpler end of the spectrum before a training project begins.
When training is justiﬁed:
• Proprietary data moat: A model trained on your transaction records, sensor data, or clinical
observations represents a competitive advantage that competitors cannot replicate with a
general foundation model. That advantage only materializes if a model is actually trained
on the data.
• No suitable foundation model: Specialized industrial domains, niche scientiﬁc ﬁelds, or highly
regulated data types where pre-training data for foundation models simply does not exist.
• Latency or cost requirements: Sub-10ms inference or very high query volumes (millions per
day) often make large foundation model inference economically or technically infeasible. A
purpose-trained smaller model can be more cost-effective by orders of magnitude.
• Data sovereignty: Healthcare, defense, and certain ﬁnancial contexts prohibit sending data to
external APIs. On-premises or VPC-isolated training and inference are mandatory.
5

<!-- page 6 -->
Traditional Machine Learning: The Right Tool for Structured Data
Not every custom training problem requires neural networks. For structured, tabular data, tra-
ditional ML algorithms frequently outperform deep learning and always outperform it on inter-
pretability, training speed, and data efﬁciency. Recognizing when to stay with traditional ML is
as important as knowing when to advance to neural networks or foundation models.
Traditional ML algorithms are the correct starting point when:
• Data is structured and tabular: Gradient boosting algorithms (XGBoost, LightGBM, CatBoost)
consistently rank among the top performers on tabular benchmarks, often matching or beat-
ing neural networks with far less data and compute. The majority of enterprise classiﬁcation,
regression, and ranking problems fall into this category: churn prediction, credit scoring,
fraud detection, and customer lifetime value estimation. Time series problems (demand fore-
casting, anomaly detection, capacity planning) are a related but distinct sub-category requir-
ing time-aware methods: classical approaches such as ARIMA, Holt-Winters, and Prophet
for interpretable forecasting with moderate data; neural approaches such as temporal fusion
transformers when pattern complexity and data volume justify the investment. Standard
cross-sectional ML algorithms applied directly to sequential data without accounting for au-
tocorrelation are a common and expensive mistake.
• Interpretability is required: Linear models and decision trees produce predictions that can be
explained to regulators, auditors, and business stakeholders without approximation. Gradi-
ent boosting models support feature importance analysis. Neural networks require separate
explainability tools (SHAP, LIME) whose outputs are approximations rather than explana-
tions. In regulated industries, this distinction matters.
• Training data is limited: Deep learning requires large labeled datasets to generalize. Traditional
ML algorithms perform well on hundreds to thousands of examples, where neural networks
overﬁt.
• Latency is critical: A gradient boosting model can infer in microseconds on a CPU. A neural
network requires milliseconds on a GPU, and a foundation model API call adds 100ms to
several seconds of network latency. For real-time decisioning at transaction speed, traditional
ML is often the only viable choice.
• Maintenance cost matters: Traditional ML models are simpler to retrain, debug, and version.
A logistic regression model that a new team member can inspect and understand has lower
operational risk than a neural network whose behavior is opaque.
The decision to move from traditional ML to neural networks should be driven by measured ev-
idence, not assumptions. Train a gradient boosting baseline ﬁrst. If it achieves acceptable perfor-
mance, stop there. If it does not, the baseline provides a performance ﬂoor that any more complex
model must exceed to justify the added cost and complexity (Zinkevich 2017).
Responsible Model Development
No training project is complete without asking: what biases does this training data carry, and what
discrimination might this model perpetuate?
Datasets encode historical patterns, including historical inequities. A model trained on historical
hiring decisions replicates past hiring discrimination (Dastin 2018). One trained on historical loan
approvals replicates past lending patterns. The model cannot distinguish between a statistically
useful signal and a legally or ethically problematic one.
Three practices are non-negotiable. First, audit training data for correlations between protected
6

<!-- page 7 -->
attributes (race, gender, age) and the prediction target before any training begins. Removing the
protected attribute from features is insufﬁcient; proxy variables (zip code, surname, income tier)
carry the same information. Second, evaluate model performance disaggregated by subgroup,
not only in aggregate. A model with 92% overall accuracy may perform at 74% on a protected sub-
group while performing at 96% on the majority class; aggregate metrics hide this. SageMaker Clar-
ify automates sliced evaluation and bias detection across demographic and operational segments.
Third, document disaggregated performance in the Model Card (Margaret Mitchell, Simone Wu,
Andrew Zaldivar, Parker Barnes, Lucy Vasserman, Ben Hutchinson, Elena Spitzer, Inioluwa Deb-
orah Raji, and Timnit Gebru, n.d.) before any deployment decision is made; this converts “the
model achieves 92% accuracy” into the accurate statement “the model achieves 92% overall but
74% for this subgroup,” which is a different conversation with different decision implications.
Figure 20.3: For structured tabular data, traditional ML often outperforms more complex approaches across
critical operational dimensions.
The training process:
Problem formulation: Deﬁne the prediction target precisely. What is being predicted, and what con-
stitutes a correct answer? A poorly speciﬁed target is the most upstream source of model failure;
everything downstream is organized around it. Involve business stakeholders: the metric that mat-
ters for business value (precision at the top decile for a targeted intervention, not overall accuracy)
must drive the model’s objective.
Dataset preparation: Deﬁne splits before touching the data. Use temporal splits when data has a
time dimension to simulate real deployment conditions and prevent leakage. Stratify splits to
7

<!-- page 8 -->
preserve class distribution. Handle class imbalance explicitly: over-sampling, under-sampling, or
cost-sensitive training.
Experiment tracking: Every training run must log hyperparameters, dataset version, code commit
hash, evaluation metrics, and the model artifact. Without this, results cannot be reproduced, runs
cannot be compared, and model behavior cannot be explained. MLﬂow (30 million monthly down-
loads as of 2026) is the de facto standard; SageMaker MLﬂow App provides equivalent capability
natively on AWS (Breck et al. 2017).
Hyperparameter optimization: Grid search for small, well-understood spaces. Random search in
larger spaces outperforms grid search for the same budget. Bayesian optimization (Optuna, Ray
Tune, SageMaker Automatic Model Tuning) for expensive-to-evaluate models.
Evaluation: Deﬁne evaluation metrics before training. Evaluate on the holdout test set exactly once.
Deﬁne the promotion gate before the ﬁrst training run.
Distributed training at scale is required when data or model size exceeds the capacity of a sin-
gle GPU. The three patterns are data parallelism (split data across GPUs and aggregate gradients;
PyTorch DDP and Horovod), model parallelism (split parameters across devices), and pipeline
parallelism (split layers sequentially; required for transformer-scale models). SageMaker Training
Jobs provides native support for all three.
20.8 Fine-Tuning Foundation Models
Fine-tuning adapts a pre-trained foundation model to speciﬁc enterprise requirements: domain-
speciﬁc vocabulary and reasoning patterns, consistent output format and structure, brand voice,
or improved performance on a narrow, high-volume task. It is powerful, increasingly accessible,
and frequently misapplied.
The knowledge vs. behavior distinction is the most practically useful frame for the ﬁne-tuning
decision. Fine-tuning changes how a model behaves: its style, format, tone, instruction-following
patterns, and task-speciﬁc reasoning. RAG changes what a model knows: the factual content it
can reference. If the problem is that the model does not know what is in your product catalog, ﬁne-
tuning will not solve it. The model cannot reliably learn proprietary factual knowledge through
ﬁne-tuning, and any knowledge it absorbs becomes stale the moment training ends. If the problem
is that the model writes in the wrong format or fails to follow task instructions consistently, ﬁne-
tuning is the right tool.
Parameter-Efﬁcient Fine-Tuning (PEFT)
Full ﬁne-tuning updates every parameter in the model. For a 7-billion-parameter model, this re-
quires approximately 100-120 GB of GPU memory and roughly $50,000 in H100 compute for a
single training run, and each iteration requires the same investment. PEFT methods freeze the pre-
trained weights and introduce a small set of trainable parameters, achieving most of the quality
gain of full ﬁne-tuning at a fraction of the cost.
LoRA (Low-Rank Adaptation) is the dominant production PEFT technique (Hu et al. 2022). LoRA
injects trainable low-rank decomposition matrices into the Transformer’s attention layers while
keeping all original weights frozen. The original paper demonstrated 10,000× fewer trainable pa-
rameters and 3× less GPU memory than full ﬁne-tuning of GPT-3 175B, with performance match-
ing or exceeding full ﬁne-tuning on standard benchmarks. The main production advantage is that
8

<!-- page 9 -->
Figure 20.4: Parameter Efﬁcient Fine-Tuning (PEFT) freezes the pre-trained model weights and trains only
a small set of added parameters, delivering most of the quality gains of full ﬁne-tuning at a fraction of the
memory and compute cost.
9

<!-- page 10 -->
LoRA adds no additional inference latency, as the adapted matrices are merged back into the base
weights at deployment time.
QLoRA extends LoRA by quantizing the frozen base weights to 4 bits. This enables ﬁne-tuning
a 7B-parameter model on a consumer GPU (e.g., RTX 4090) while retaining 90-95% of the quality
of full ﬁne-tuning, a cost reduction of approximately 30× compared to full ﬁne-tuning. The trade-
off: QLoRA runs approximately 39% slower than standard LoRA due to quantization overhead.
For most enterprise use cases, the economics are decisive: LoRA and QLoRA have become the
dominant approaches for production ﬁne-tuning.
Instruction ﬁne-tuning trains on (instruction, response) pairs to improve instruction-following
consistency and output structure. It is the right technique when the base model follows instructions
unreliably or produces variable formatting. The training data format must match the inference-
time prompt format exactly; this mismatch is the most common cause of unexpected ﬁne-tune
behavior.
Fine-tuning data requirements:
Quality dominates quantity. A carefully curated set of 1,000 high-quality (instruction, response)
pairs typically outperforms a set of 100,000 noisy ones. Data curation is the hardest part of the
pipeline and is where most teams underinvest. Practical ranges for LoRA: 500 to 2,000 examples
for narrow task adaptation, 2,000 to 10,000 for broader behavioral adjustment.
Fine-tuning is not the answer when you have fewer than approximately 500 consistent examples,
when the task changes frequently (a prompt iteration is orders of magnitude cheaper than a re-
training cycle), when RAG can address the gap, or when a prompt with few-shot examples al-
ready achieves acceptable performance; always validate the simpler approach before investing in
training.
AWS-native ﬁne-tuning:
Amazon Bedrock serverless customization provides a fully managed pipeline: select a supported
model, supply a dataset in S3, choose a technique (supervised ﬁne-tuning, Direct Preference
Optimization, which trains directly from preference comparisons between output pairs rather
than requiring a separate reward model, or reinforcement ﬁne-tuning), and deploy without
managing infrastructure. AWS reports this reduces customization timelines from months to days.
Bedrock reinforcement ﬁne-tuning uses a small set of prompts with veriﬁable reward signals rather
than large labeled datasets. AWS benchmarks show an average 66% accuracy improvement over
base models, with customer results (Salesforce, Weni by VTEX) reaching 73% on targeted tasks.
This approach is particularly effective when the target behavior can be veriﬁed automatically: code
correctness, format compliance, factual accuracy against a reference.
SageMaker ﬁne-tuning provides full infrastructure control for teams with custom PEFT conﬁgura-
tions, proprietary model weights, or specialized hardware requirements. SageMaker Training Jobs
support LoRA and QLoRA via the Hugging Face libraries, and SageMaker MLﬂow App logs every
run automatically.
20.9 Retrieval-Augmented Generation (RAG)
RAG grounds LLM outputs in proprietary, current, and conﬁdential knowledge by retrieving rel-
evant context at inference time and injecting it into the prompt. It has become a standard pattern
10

<!-- page 11 -->
Figure 20.5: LoRA and QLoRA achieve most of the full ﬁne-tuning quality at a fraction of the cost, with no
inference latency penalty for LoRA.
11

<!-- page 12 -->
for knowledge-intensive LLM applications in the enterprise. The foundational paper by Lewis et
al. (2020) demonstrated that retrieval-augmented systems outperform parametric-only models on
open-domain question-answering tasks that require factual accuracy (Lewis et al. 2020).
The knowledge vs. behavior decision framework:
Before building a RAG pipeline, conﬁrm the problem is about knowledge, not behavior. RAG
changes what the model can reference at inference time; ﬁne-tuning changes how the model be-
haves. If the model needs to know what is in your product catalog, that is a knowledge problem:
use RAG. If the model needs to write in your brand’s voice and format, that is a behavior problem:
use ﬁne-tuning. The two are frequently combined, with a ﬁne-tuned model handling behavioral
consistency and a RAG pipeline handling knowledge grounding. Conﬂating them leads to expen-
sive, failed experiments.
RAG architecture, four stages:
1. Indexing pipeline (ofﬂine): Chunk source documents into segments, generate embedding vec-
tors for each chunk, and store vectors and source text in a vector database. This pipeline runs
ofﬂine and is rebuilt or updated incrementally as the knowledge base changes. Its quality de-
termines the ceiling for the entire RAG system.
2. Retrieval (inference time): Convert the user query into an embedding vector, compute similar-
ity against indexed chunks, and retrieve the top-k most relevant segments. Retrieval is the
most common failure point in production RAG systems.
3. Augmentation: Inject retrieved chunks into the prompt alongside the user query. The format
of injection (how retrieved content is labeled, ordered, and separated) affects faithfulness and
reasoning quality.
4. Generation: The LLM synthesizes a response from the retrieved context. With quality re-
trieval and appropriate context injection, hallucination rates drop substantially compared
to parametric-only generation.
Key design decisions:
Chunking strategy: Fixed-size chunking is simple but frequently breaks semantic coherence. Seman-
tic chunking splits on natural boundaries (paragraphs, sections). Chunk size trades retrieval pre-
cision against context coverage. For most enterprise document corpora, 256- to 512-token chunks
with 10% to 20% overlap are a practical starting point.
Embedding model: OpenAI text-embedding-3-small, Cohere Embed, and open-source alternatives
(BGE, E5) perform differently across domains. Evaluate on representative samples from your ac-
tual corpus, not on generic benchmarks.
Retrieval strategy: Dense retrieval (vector similarity) works for semantic queries. Sparse retrieval
(BM25/keyword matching) works for exact-term lookup. Hybrid retrieval, combining both with a
rank fusion step, outperforms either approach alone on most heterogeneous enterprise document
corpora and should be the default for production systems.
Re-ranking: A second-pass model scores retrieved chunks for relevance before injection, improv-
ing precision at the cost of added latency. For systems where retrieval quality is the bottleneck,
re-ranking is worth the investment. Amazon Bedrock Knowledge Bases includes managed re-
ranking.
12

<!-- page 13 -->
Figure 20.6: RAG grounds LLM outputs in proprietary knowledge by retrieving relevant context at inference
time and injecting it into the prompt.
Context window management: Retrieved chunks, plus the prompt, must ﬁt within the model’s con-
text window. With 128K+ token contexts now standard, the hard constraint has relaxed. Even so,
context stufﬁng (injecting more retrieved text than the model can effectively reason over) degrades
generation quality. Limit retrieved context to the top 3 to 5 re-ranked chunks for most tasks.
RAG failure modes:
Retrieval misses: The correct document exists but is not retrieved. Caused by chunking that splits
a relevant passage across chunk boundaries, an embedding model poorly suited to the domain,
or query phrasing that does not match document vocabulary. Fix: evaluate retrieval quality using
Context Recall (the fraction of relevant content that was actually retrieved).
Context stufﬁng: Too many retrieved chunks overwhelm the model’s reasoning capacity. Fix: limit
to the top 3-5 chunks with re-ranking.
Faithfulness failures: The model ignores retrieved context and answers from its parametric knowl-
edge, producing hallucinations even when the right document was retrieved. Fix: system prompt
instructions anchoring the response to the provided context help; monitor the Faithfulness metric
(the fraction of response claims grounded in retrieved content) as a production signal.
AWS-native RAG stack:
Amazon Bedrock Knowledge Bases provides a fully managed RAG pipeline: ingest documents from
S3, chunk and embed them using a conﬁgurable embedding model, store vectors in a managed
index (Amazon OpenSearch Serverless or Aurora PostgreSQL with pgvector), and query via API
at inference time.
13

<!-- page 14 -->
Amazon OpenSearch Service with vector engine is the default AWS vector store for custom RAG im-
plementations requiring control over index conﬁguration and hybrid search weighting. It natively
supports dense (k-NN) and sparse (BM25) retrieval.
Bedrock Model Evaluation includes managed RAG evaluation aligned with standard retrieval and
faithfulness metrics, enabling development-time measurement without building a custom evalua-
tion framework.
Figure 20.7: RAG failure modes cluster around retrieval quality, context overload, and model faithfulness;
each has a measurable detection signal.
20.10 Agent Design and Orchestration
Agents are AI systems that use a foundation model as a reasoning engine to select and execute
sequences of actions to achieve a goal. They differ from pipelines in a fundamental way: pipelines
execute a ﬁxed sequence of steps deﬁned at design time; agents decide what to do next based
on what they observe at runtime. This capability makes agents powerful for complex, multi-step
tasks and signiﬁcantly harder to engineer for production reliability than any other approach in this
chapter.
The ReAct loop:
The dominant production pattern for agent reasoning is ReAct (Reasoning + Acting) (Yao et al.
2023). In each cycle, the agent observes the current state and task context, reasons about what to
do next, selects and executes an action, and observes the result. The loop continues until the task
is complete or a stopping condition ﬁres. ReAct outperforms action-only and chain-of-thought-
14

<!-- page 15 -->
only approaches on standard agent benchmarks, but production deployments require signiﬁcant
engineering beyond the reasoning loop to achieve acceptable reliability.
The production reliability data is unambiguous: without explicit reliability engineering, ReAct
agent success rates drop from approximately 60% on ﬁrst execution to approximately 25% across
eight consecutive runs, a 58% degradation. In a controlled production benchmark, 90.8% of re-
tried agent actions were wasted on errors that could never be recovered: tools that did not exist,
already-failed API calls, and schema mismatches that the agent repeatedly attempted to resolve
with wrong arguments. Missing input validation, missing failure classiﬁcation, and missing retry
budgets cause these failures, not poor model quality.
Agent architecture components:
Planner / Reasoning Engine: The foundation model decides what to do next. For production, the
planner should use structured output enforcement (JSON tool calls rather than free-text reason-
ing) to make decisions parseable by the execution layer. Chain-of-thought elicitation improves
planning quality on complex tasks at the cost of increased latency.
Tool Registry: The set of capabilities the agent can invoke: API calls, database queries, code execu-
tion, ﬁle operations, and other agents. Each tool requires a name, a precise description, an input
schema, and an output schema. Tool descriptions are among the most important pieces of docu-
mentation in an agent system; the model’s tool-selection quality depends entirely on how clearly
the descriptions communicate when each tool is appropriate and when it is not. Ambiguous de-
scriptions produce ambiguous selection.
Memory Systems: Short-term memory (context window) holds the current task state and the ac-
tive reasoning trace throughout the task. Long-term memory (external store) persists facts across
sessions and requires explicit read/write to a database. Episodic memory (vector store) enables
semantic recall of past interactions via similarity search.
Execution Engine: Manages tool invocations, handles errors, implements retry logic, enforces time
and cost limits per task, and captures the full action trace for observability. This is where the ma-
jority of production agent failures originate, and where the most important reliability engineering
happens.
Human-in-the-Loop (HITL): Deﬁne which decisions require human approval before execution, and
deﬁne this before writing code. Irreversible actions (sending external communications, modifying
customer records, processing ﬁnancial transactions) require a conﬁrmation gate. Escalation paths
must be explicit: what happens when the agent is uncertain, exceeds its retry budget, or encounters
an unauthorized action?
Production reliability engineering
Agent reliability is an engineering discipline. The gap between a working demonstration and a
production-reliable agent lies almost entirely in the following controls (Breck et al. 2017):
Structured outputs: Enforce JSON tool calls rather than free-text at every decision boundary. Un-
structured output is the primary source of downstream parsing failures.
Input validation at tool boundaries: Every tool validates its input schema before execution. Return
structured error messages (not null, not a raw exception) that the LLM can reason about, correct,
and retry. Silent failures, where a function returns null and the agent proceeds as if it succeeded,
are the single most common agent-engineering antipattern.
15

<!-- page 16 -->
Figure 20.8: Agent architecture integrates reasoning, tool access, memory, execution, and human oversight
into a closed-loop decision system.
Retry budgets with failure classiﬁcation: Classify failures before retrying. Recoverable failures (tran-
sient network errors, rate limits) warrant retries with exponential backoff. Non-recoverable fail-
ures (tool does not exist, authorization denied, malformed input, or the model keeps regenerating)
should be escalated immediately rather than consuming the retry budget. In the production bench-
mark above, 90.8% of retries were non-recoverable, meaning 90.8% of retry compute was wasted
for want of this classiﬁcation.
Reﬂection gates: Before executing irreversible actions, have the agent verify that the proposed action
is consistent with its task objective and within its authorization scope. This catches a signiﬁcant
fraction of hallucination-driven errors before they execute.
Timeouts and circuit breakers: Enforce maximum execution time and per-task API cost limits. Prevent
agents from entering stuck loops that exhaust retry budgets or accumulate costs without progress.
Full action trace logging: Log every tool call, its arguments, its result (including errors), the agent’s
reasoning step, and a timestamp, for every execution. Without this, agent debugging is impossible.
The trace is also the audit record required by governance frameworks.
The hallucination cascade is the most dangerous agent failure mode. An agent generates a false
entity (a nonexistent customer ID, a phantom SKU, or an incorrect policy reference) and then in-
vokes multiple downstream tools using it. Each subsequent tool either fails or operates on the
hallucinated input, amplifying the error across the system. An inventory agent might fabricate
a nonexistent product and then trigger pricing, stocking, and shipping workﬂows before any hu-
man observes the failure. Prevention: Validate all entities against authoritative data sources before
beginning any multi-step action sequence. Never pass an unvalidated entity from one tool call to
the next.
Multi-agent systems
Orchestrator-and-specialist architectures decompose complex tasks across agents with differenti-
16

<!-- page 17 -->
ated capabilities. An orchestrator receives a high-level goal, decomposes it into subtasks, and del-
egates to specialists: a retrieval agent, a code execution agent, and a compliance-checking agent.
Each specialist completes its subtask and returns a structured result; the orchestrator synthesizes
and determines next actions.
Use multi-agent when tasks are too complex for a single agent’s context window, require genuinely
different capabilities, or beneﬁt from parallelism. Avoid it when the coordination overhead exceeds
the beneﬁt; error propagation between agents is harder to trace than errors within a single agent.
Keep multi-agent systems as simple as the task requires.
MCP and A2A: the interoperability layer
Two standards now govern how enterprise agents communicate, both under the Linux Founda-
tion’s Agentic AI Foundation (AAIF). MCP (Model Context Protocol), originally developed by
Anthropic, standardizes how agents connect to tools, APIs, and data sources. As of early 2026,
MCP has been deployed on over 10,000 enterprise servers, with 97 million SDK downloads, and
is adopted by Anthropic, OpenAI, Google, Microsoft, and AWS. A2A (Agent-to-Agent Protocol),
donated by Google to the Linux Foundation in June 2025, standardizes structured task delegation
and communication between agents. A2A has over 150 participating organizations and provides
OAuth-based authentication, Server-Sent Events streaming, and JSON-RPC versioning.
The recommended architecture pairs MCP for tool and context integration with A2A for agent-
to-agent orchestration. Both are now industry standards, not experimental protocols. Enterprise
agent architectures should be designed for them from the start rather than retroﬁtting interoper-
ability later.
AWS-native agents
Amazon Bedrock AgentCore is AWS’s platform for building, deploying, and operating agents. It is
modular: teams adopt the components they need rather than accepting a monolithic runtime. Two
deployment paths share the same managed infrastructure. The AgentCore harness is conﬁguration-
based: declare the model, system prompt, tools, skills, memory, and execution limits (maximum
iterations, tokens, and timeout), and AgentCore runs the ReAct loop, manages the context window,
and isolates each session in its own microVM (Amazon Web Services 2026a). AgentCore Runtime
hosts agents written in code with any framework (Strands Agents, LangGraph, CrewAI, the Ope-
nAI Agents SDK, the Claude Agent SDK, or custom) for teams that need control the harness does
not offer: custom orchestration, supervisor-style multi-agent patterns, or graph workﬂows. Start
with the harness and move to Runtime only when conﬁguration stops being enough.
The surrounding services map directly onto the architecture components described earlier. Agent-
Core Gateway is the tool registry: it exposes Lambda functions, REST APIs, existing MCP servers,
and Bedrock Knowledge Bases to the agent as MCP tools, which makes agentic RAG a conﬁgura-
tion step rather than custom plumbing. AgentCore Memory provides short-term memory within a
session and long-term memory across sessions, scoped per user. AgentCore Identity authenticates
against enterprise identity providers and lets agents act on behalf of a user. AgentCore Observability
emits OpenTelemetry traces of every reasoning step and tool call to CloudWatch, producing the
action trace that both debugging and audit require.
AgentCore Policy deserves particular attention because it changes where HITL enforcement lives.
Policies written in Cedar, or authored in natural language and compiled to Cedar, are evaluated
at the Gateway, outside the agent’s code. They can permit or forbid a tool call based on the caller’s
17

<!-- page 18 -->
identity and the call’s input parameters, and session-aware policies can require that a human ap-
proval occurred earlier in the conversation (Amazon Web Services 2026c). A model can be talked
out of a system-prompt instruction. It cannot talk its way past a policy it never evaluates.
AWS’s earlier managed agent service, Amazon Bedrock Agents, entered maintenance mode in
July 2026 and is closed to accounts without prior usage (Amazon Web Services 2026b). The lesson
outlasts either product: managed agent platforms are young and their surface area moves quickly.
Keep tool contracts, prompts, and evaluation suites portable (MCP for tools, version-controlled
prompts, framework-neutral test sets) so a platform change is a migration rather than a rewrite.
AWS Step Functions provides state machine orchestration for complex multi-step workﬂows re-
quiring strict auditability, branching, and durable state. This is the compliance-grade choice for
regulated environments.
Amazon EventBridge provides event-driven triggers for agent workﬂows that respond to business
events such as order creation, support ticket ﬁling, and document upload.
20.11 Reproducibility and Model Versioning
Every model that reaches production must be reproducible: the same code, the same data, and the
same environment must be able to reconstruct the same model. That sounds obvious, but it is the
discipline most AI teams implement too late, often after a production incident reveals they cannot
explain why a model behaved differently from its predecessor, or after a regulatory audit reveals
they cannot reconstruct a prediction made six months ago (Sculley et al. 2015).
Why reproducibility is harder in AI than in software
Four factors compound the difﬁculty. Non-determinism from stochastic training and hardware vari-
ance makes bit-for-bit reproducibility infeasible; target statistical reproducibility instead (same ar-
chitecture, data, and seed producing performance within a deﬁned tolerance band). Data depen-
dency means the same code applied to different data produces a different model; data versioning is
as important as code versioning, but is implemented far less consistently. Environment dependency
means library versions, CUDA versions, and hardware generation all affect training outcomes;
a Docker container with fully pinned dependencies is the minimum viable solution. Foundation
model drift means a provider update can silently change prompt behavior; pinning to a speciﬁc
model version string and running prompt regression tests on every provider update are the only
reliable detection mechanisms.
The reproducibility stack:
Table 20.2: Reproducibility and Model Versioning — Layer, What to Version, Tool (AWS).
Layer What to Version Tool (AWS)
Code Training scripts, pipeline deﬁnitions Git; link every run to a commit
hash
Data Dataset snapshots with immutable
references
S3 with versioning; DVC for large
datasets
Environment Container with all pinned dependencies Docker; Amazon ECR
Experiments All hyperparameters, metrics, artifacts per
run
SageMaker MLﬂow App
18

<!-- page 19 -->
Layer What to Version Tool (AWS)
Models Registered artifacts with full training
provenance
SageMaker Model Registry
Prompts All prompt versions with change history Git; eval regression suite on each
PR
Foundation
models
Provider and speciﬁc model version
identiﬁer
Conﬁg/code; pin to version string
Model registry as the production gate
Every model that reaches production is registered with its full provenance: training run ID, dataset
version tag, git commit hash, evaluation metrics, and deployment history. The promotion work-
ﬂow enforces a minimum performance threshold before the model can move from staging to pro-
duction, with the previous production version always preserved for rollback.
Model Cards (Margaret Mitchell, Simone Wu, Andrew Zaldivar, Parker Barnes, Lucy Vasserman,
Ben Hutchinson, Elena Spitzer, Inioluwa Deborah Raji, and Timnit Gebru, n.d.) document reg-
istered models for stakeholders who were not present during training: what the model predicts,
what data it was trained on, how it performs across demographic and operational segments, and
where it should not be used. Model Cards are increasingly required by governance frameworks
including the NIST AI RMF, and connect directly to the bias and sliced evaluation work covered
in the Responsible Model Development section above.
Versioning LLM-based systems
Prompt versioning requires treating prompts as code: every prompt in a version-controlled repos-
itory, changes through review, every deployment linked to a speciﬁc commit hash. Evaluation
regression testing detects silent behavioral drift before it reaches production. Without it, prompt
changes degrade performance with no feedback loop until users report failures.
Foundation model pinning locks inference to a speciﬁc version string (e.g., claude-sonnet-4-5-
20250514) rather than a capability alias. Provider model updates are functionally equivalent to
dependency upgrades: they change behavior and require the same validation process before adop-
tion in production.
20.12 AWS Model Development Reference Architecture
The AWS-native model development stack provides managed services for each development ap-
proach, minimizing operational overhead while preserving production-grade auditability and scal-
ability.
Stack by development approach
19

<!-- page 20 -->
Figure 20.9: AWS model development reference architecture showing two complementary paths—custom
model training with SageMaker and foundation model customization with Bedrock—ﬂowing through model
registry, deployment, agent orchestration, and production monitoring.
Table 20.3: AWS Reference Architecture — Approach, Compute, Tracking, Serving.
Approach Compute Tracking Serving
Train traditional
ML
SageMaker Training Jobs SageMaker MLﬂow
+ Model Registry
SageMaker
Inference
Endpoints
Train custom
neural network
SageMaker Training Jobs
(distributed)
SageMaker MLﬂow
+ Model Registry
SageMaker
Inference
Endpoints
Fine-tune
foundation
model
Bedrock Serverless Customization
or SageMaker + HF
SageMaker Model
Registry
Bedrock
Inference
RAG Bedrock Knowledge Bases
(managed) or OpenSearch
(custom)
— Bedrock API
Prompt
engineering
— Git + eval
regression tests
Bedrock /
SageMaker
Endpoint
Agent
orchestration
AgentCore harness (conﬁguration)
or AgentCore Runtime (code);
Step Functions for deterministic
workﬂows
AgentCore
Observability
(OpenTelemetry
traces to
CloudWatch)
AgentCore
20

<!-- page 21 -->
20.13 The Retail AI Platform Use Case
The retail AI platform running through this chapter shows the development spectrum as a portfolio
of decisions rather than a single choice, each one made on its own terms based on what the speciﬁc
problem requires.
Churn prediction uses a trained traditional ML model. XGBoost runs on the RFM features and be-
havioral signals produced by the feature engineering pipeline in the previous chapter. The data is
structured and tabular, the competitive advantage comes from proprietary transaction history, and
a gradient boosting model consistently outperforms foundation models on this class of problem
while remaining interpretable to the marketing and ﬁnance teams who act on its predictions.
Training runs on SageMaker Training Jobs with a temporal split: 24 months of history for training,
the most recent 3 months as a holdout. Every run is logged in SageMaker MLﬂow App with the git
commit hash and S3 dataset version tag. The promotion gate is AUC-ROC ≥ 0.82 on the holdout
set, which corresponds to the precision-at-top-decile performance the retention team requires for
campaign targeting.
Personalized offer generation combines three approaches, each addressing a different dimension
of the problem.
A LoRA ﬁne-tune on 2,000 historical high-converting offer descriptions handles behavioral con-
sistency. Each training example pairs a customer context (RFM segment, recent purchase cate-
gory, active promotions) with a human-reviewed offer. The ﬁne-tuned model produces outputs
in the correct format and brand voice without requiring lengthy prompt engineering on every call.
Training runs through Bedrock serverless customization. The ﬁne-tuned model is registered in
SageMaker Model Registry with a link back to its Bedrock Training Job ID and the ﬁne-tuning
dataset S3 path.
A RAG pipeline over the product catalog handles the knowledge dimension. Fifty thousand SKUs
with structured attributes, descriptions, and category hierarchy are ingested into Bedrock Knowl-
edge Bases backed by Amazon OpenSearch Serverless. Hybrid retrieval (dense similarity on prod-
uct descriptions, sparse keyword matching on SKU and category identiﬁers) retrieves the top-5
most relevant products for a customer’s behavioral proﬁle. The ﬁne-tuned model handles behav-
ior; the RAG pipeline handles knowledge; a system prompt enforces JSON output schema.
Offer generation prompts are version-controlled in Git with a 200-example regression evaluation
suite run on every PR. The foundation model version is pinned in the application conﬁg.
Customer service escalation uses a ReAct agent built on the Amazon Bedrock AgentCore harness.
Tools are exposed through AgentCore Gateway: CRM lookup (retrieve account and order history),
policy knowledge base (RAG over return and refund policies via Bedrock Knowledge Bases, at-
tached as a Gateway target), order management API (initiate return or exchange), and escalation
routing API (route to human specialist with full context). AgentCore Memory carries the conversa-
tion within a session and the customer’s prior interactions across sessions. The HITL gate for any
refund exceeding $50 is enforced in two layers. An AgentCore Policy on the Gateway forbids any
order management call above $50 unless a human approval was recorded earlier in the session,
so the limit holds even if a customer manipulates the model. The approval itself is an inline func-
tion tool: the harness pauses, returns control to the application, and resumes only after a human
specialist conﬁrms. Transient API errors retry up to 3 times with exponential backoff. Authoriza-
tion failures, including policy denials, escalate immediately. The full action trace (task ID, tool
21

<!-- page 22 -->
calls, arguments, results, policy decisions, and outcome) is recorded by AgentCore Observability
in Amazon CloudWatch for debugging and audit.
Reproducibility across all three systems follows the same stack: git commit hash plus S3 dataset
version tag in SageMaker MLﬂow App for the churn model, prompt version in Git with regression
evaluation for offer generation, and versioned harness conﬁguration plus AgentCore Observability
traces for the agent. The previous production churn model is always preserved in SageMaker
Model Registry for rollback.
20.14 Case Study: Morgan Stanley AI at Scale
Morgan Stanley’s AI deployment across its wealth management division illustrates the full devel-
opment spectrum as a sequence of production decisions made under regulatory constraint and at
enterprise scale, with real accountability for client trust and regulatory compliance.
Background. Morgan Stanley manages over $4 trillion in client assets, served by approximately
16,000 ﬁnancial advisors. Its internal knowledge base (research reports, investment strategy doc-
uments, product documentation, regulatory guidance) comprises more than 100,000 documents
and continues to grow. Before AI, advisors searched this corpus manually: slow, inconsistent, and
dependent on individual expertise to know where to look.
Custom model training for the risk and compliance layer. Morgan Stanley’s credit risk, fraud
detection, and regulatory compliance screening systems are trained on proprietary ﬁnancial data:
years of transaction patterns, counterparty relationship networks, and exposure proﬁles across
clients and instruments. No foundation model has been exposed to this data. The ﬁrm’s historical
records are the competitive advantage, and the model is only valuable because the data is pro-
prietary. These systems are managed under strict reproducibility requirements because a wrong
prediction in a regulated context is a compliance event, not a product bug. Every model version,
every training run, and every evaluation is audited.
RAG for the knowledge layer. In 2023, Morgan Stanley partnered with OpenAI to build an AI
Assistant for ﬁnancial advisors, powered by GPT-4 over a RAG pipeline indexing the ﬁrm’s full
document corpus. An advisor submits a query; the system retrieves the most relevant research
reports and strategy documents; the model synthesizes an answer grounded in ﬁrm-approved
content and then deploys it across the full advisor base. This is an archetypal RAG deployment: the
problem is access to knowledge (current, proprietary, regulated documents), not model behavior.
The knowledge base changes continuously as new research is published, making ﬁne-tuning the
wrong solution because any factual knowledge encoded in a ﬁne-tune is stale before the training
run completes.
Fine-tuning for behavioral consistency. Morgan Stanley’s AI Debrief feature generates structured
summaries of advisor-client meetings. The input is a meeting transcript; the output is a standard-
ized record in a format deﬁned by ﬁrm policy. The task is narrowly deﬁned, consistently struc-
tured, and well-represented by thousands of historical meeting notes. A ﬁne-tuned model trained
on those historical summaries produces outputs in the correct format with consistent terminology,
without requiring lengthy prompt engineering or few-shot examples for every call.
Agent orchestration for complex advisor workﬂows. The next layer orchestrates across the CRM,
the RAG knowledge base, the product catalog, and compliance-checking APIs to support multi-
step advisory workﬂows: retrieving client context, identifying suitable investment products, veri-
22

<!-- page 23 -->
fying compliance constraints, and drafting a proposal for advisor review. This is a ReAct-pattern
agent with explicit HITL gates: every client-facing communication requires advisor review before
it goes out, and the action trace is logged with full ﬁdelity for regulatory examination.
Reproducibility as a hard requirement. SEC and FINRA regulations require Morgan Stanley to
reconstruct exactly what model produced a speciﬁc output at a speciﬁc point in time, for any au-
dited interaction. This makes reproducibility non-optional, whereas most enterprises treat it as
aspirational. Every model version is registered with full provenance. Every prompt change is
version-controlled. Foundation models are pinned to speciﬁc versions in production. The regula-
tory constraint functions as a forcing function that surfaces the business value of reproducibility:
the ﬁrm cannot explain a model output to a regulator if it cannot reproduce the model that pro-
duced it.
The lesson. Morgan Stanley applied each approach where it ﬁt: training where proprietary data is
the moat, RAG where knowledge is dynamic and regulated, ﬁne-tuning where behavioral consis-
tency is the requirement, agents where multi-step orchestration is necessary, and reproducibility
everywhere because the regulatory context makes it non-optional. The architecture follows the
problem, and that is the discipline this chapter is designed to build.
20.15 Key Takeaways
• The most consequential decision in AI development is choosing the right approach before
writing any code; always validate the simpler approach before investing in the next level of
complexity.
• Traditional ML (gradient boosting, logistic regression) is the right ﬁrst choice for structured
tabular data; it frequently outperforms neural networks on these problems while offering
interpretability advantages that matter in regulated contexts.
• Fine-tuning changes how a model behaves; RAG changes what a model knows; conﬂating
these purposes produces expensive, failed projects.
• LoRA and QLoRA make ﬁne-tuning accessible at a fraction of the cost of full ﬁne-tuning: a 7B
model that costs roughly $50K to fully ﬁne-tune can be adapted with QLoRA on a consumer
GPU at 90 to 95% quality retention.
• Prompt engineering is the highest-ROI development technique for most enterprise teams;
treat prompts as production code, version-control them, and test every change.
• Agent reliability is an engineering discipline: success rates degrade 58% without explicit
controls, and production deployments require structured outputs, failure classiﬁcation, HITL
gates, and action trace logging.
• Reproducibility requires versioning code, data, environments, experiments, models, and
prompts as a complete chain; any gap in the chain makes an incident unauditable and a
regulatory examination unpassable.
20.16 Apply It
1. Approach Selection. For each of the following, select the appropriate development approach
and justify: (a) detecting fraudulent transactions in structured ﬁnancial log data; (b) answer-
ing employee HR policy questions from a 500-page internal handbook; (c) generating per-
sonalized marketing emails in a speciﬁc brand voice; (d) autonomously triaging and routing
incoming customer support tickets.
23

<!-- page 24 -->
2. Traditional ML vs. Foundation Models. Your team is building a demand forecasting model
for 10,000 retail SKUs with 5 years of weekly sales history. What approach do you select?
Justify your choice against the alternatives. What would need to change for you to move to
a foundation model approach?
3. PEFT Economics. Your team needs to ﬁne-tune a 13B parameter model for a compliance
document classiﬁcation task. You have 1,200 labeled examples and a $5,000 compute budget.
Which PEFT approach do you select? Estimate memory and compute requirements. What
quality trade-offs are you accepting compared to full ﬁne-tuning, and how would you mea-
sure them?
4. RAG Pipeline Design. Design the full RAG architecture for the retail offer generation system.
Deﬁne chunking strategy, embedding model, retrieval approach (dense/sparse/hybrid), re-
ranking decision, and context injection format. Justify each decision. Identify the top two
failure modes and specify how you would measure each.
5. Agent Reliability Audit. Review the customer service escalation agent design in this chapter.
Identify the three most signiﬁcant production reliability risks. For each: (a) describe the
failure mode, (b) specify the engineering mitigation, (c) deﬁne what you would log to detect
it in production.
6. AI Prompt. “You are a senior ML engineer reviewing an agent design for a retail customer ser-
vice system that handles order inquiries, return requests, and escalations. The agent uses a ReAct
loop with tools for CRM lookup, policy RAG, and order management API. Identify the three most
signiﬁcant production reliability risks in this design, and for each recommend a speciﬁc engineering
mitigation with an observable metric for detecting the failure in production: [paste your agent design
from Exercise 5].”
20.17 What’s Next
With models trained, ﬁne-tuned, and orchestrated, the system has a much larger attack surface
than the one it started with: training data that can be poisoned, prompts that can be injected, RAG
indexes that can leak sensitive content, and agents with permission to act. Chapter 21 addresses
that surface before anything ships. It covers threat modeling for AI systems, privacy engineering,
regulatory compliance, and the security gates and sign-off that the delivery pipeline will later en-
force. Testing and evaluation follow, and only then does the book turn to automating the path to
production in Chapter 23.
20.18 References
Amazon Web Services. 2026a. AgentCore Harness Is Now Generally Available. Https://aws.amazon.com/about-
aws/whats-new/2026/06/amazon-bedrock-agentcore-harness-generally-available/; Ama-
zon Web Services.
Amazon Web Services. 2026b. Amazon Bedrock Agents Classic Maintenance Mode. Https://docs.aws.amazon.com/bedrock/latest/userguide/agents-
classic-maintenance-mode.html; Amazon Web Services.
Amazon Web Services. 2026c. Policy in Amazon Bedrock AgentCore: Control Agent Interactions.
Https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy.html; Amazon
24

<!-- page 25 -->
Web Services.
Breck, Eric, Shanqing Cai, Eric Nielsen, Michael Salib, and D. Sculley. 2017. “The ML Test Score:
A Rubric for ML Production Readiness and Technical Debt Reduction.” 2017 IEEE International
Conference on Big Data (Big Data), 1123–32.
Dastin, Jeffrey. 2018. Amazon Scraps Secret AI Recruiting Tool That Showed Bias Against Women.
Https://www.reuters.com/article/us-amazon-com-jobs-automation-insight/amazon-scraps-
secret-ai-recruiting-tool-that-showed-bias-against-women-idUSKCN1MK08G.
Hu, Edward J., Yelong Shen, Phillip Wallis, et al. 2022. “LoRA: Low-Rank Adaptation of Large
Language Models.” International Conference on Learning Representations (ICLR). https://doi.or
g/10.48550/arXiv.2106.09685.
Lewis, Patrick, Ethan Perez, Aleksandra Piktus, et al. 2020. “Retrieval-Augmented Generation for
Knowledge-Intensive NLP Tasks.” Advances in Neural Information Processing Systems (NeurIPS).
https://doi.org/10.48550/arXiv.2005.11401.
Margaret Mitchell, Simone Wu, Andrew Zaldivar, Parker Barnes, Lucy Vasserman, Ben Hutchin-
son, Elena Spitzer, Inioluwa Deborah Raji, and Timnit Gebru. n.d. “Model Cards for Model Re-
porting.” Proceedings of the 2019 Conference on Fairness, Accountability, and Transparency (FAccT),
220–29. https://doi.org/10.1145/3287560.3287596.
Sculley, D., Gary Holt, Daniel Golovin, et al. 2015. “Hidden Technical Debt in Machine Learning
Systems.” Advances in Neural Information Processing Systems (NeurIPS) 28: 2503–11.
Yao, Shunyu, Jeffrey Zhao, Dian Yu, et al. 2023. “ReAct: Synergizing Reasoning and Acting in
Language Models.” International Conference on Learning Representations (ICLR). https://doi.or
g/10.48550/arXiv.2210.03629.
Zinkevich, Martin. 2017. Rules of Machine Learning: Best Practices for ML Engineering.
Https://developers.google.com/machine-learning/guides/rules-of-ml; Google Develop-
ers.
25