# Course schedule (CS 401R-4 F26 Schedule.xlsx)


## CS 401R F26

| CS 401R-4 Engineering Large-Scale Production AI Systems — F26 Schedule |  |  |  |  |  | *Unless noted, all readings come from "Engineering the AI Enterprise." Reading assignment due on day of class. There will be a short quiz based on the readings, each class. |  |  |  |
| Class # | Week # | Month | Date | Topic | In class activity / lecture | Reading* | Assignments | Due date | Notes |
| 1 | 1 | Sep | 3 | Course Introduction | Course intro, Semester Outline, What is AI enterprise engineering?, Employment Prospects, AWS, NorthStar Retail case introduced. |  | AWS Academy: Cloud Foundations                                          Lab 1: Platform Foundation | Sep 19, 2026 | First day of class. |
| 2 | 2 | Sep | 8 | AI Systems Development Lifecycle (AISDLC) | Why AI development is different. Lifecycle stages and phases, stage gates, and artifacts. How the AISDLC maps to real enterprise practice. | AI Systems Development Lifecycle — Why AI Development Is Different; The AISDLC at a Glance; Lifecycle Phases; Stage Gates and Artifacts |  |  |  |
| 3 | 2 | Sep | 10 | AI Platform & Cloud Architecture I | What is an AI platform? Reference architectures for enterprise AI. Core platform components. The compound-returns argument for platform investment. | AI Platform & Cloud Architecture — Motivation through Core Platform Components |  |  |  |
| 4 | 3 | Sep | 15 | AI Platform & Cloud Architecture II | AWS infrastructure for AI. SageMaker domain and ecosystem. Infrastructure as Code with Terraform. Modularity, vendor strategy, and cost governance during build. NorthStar platform architecture. | AI Platform & Cloud Architecture — AWS Infrastructure through Key Takeaways |  |  |  |
| 5 | 3 | Sep | 17 | Data & Feature Engineering I | Why data engineering for AI is different. Three ingestion patterns. Data transformation and operational quality. The Zillow Offers cautionary tale. AWS reference architecture. | Data & Feature Engineering — Motivation through Feature Engineering | AWS Academy: GenAI                   Lab 2: Data & Feature Engineering | Oct 3, 2026 |  |
| 6 | 4 | Sep | 22 | Data & Feature Engineering II | Feature stores and training/serving skew. Data lineage and provenance. Governance, privacy, and security. Airbnb Zipline case study. | Data & Feature Engineering — Feature Stores through Key Takeaways |  |  |  |
| 7 | 4 | Sep | 24 | Model Development I | The development spectrum: choosing your approach. Prompt engineering as an engineering discipline. Training custom models. Fine-tuning foundation models. Reproducibility and model versioning. | Model Development — Motivation through Fine-Tuning Foundation Models; Reproducibility and Model Versioning |  |  |  |
| 8 | 5 | Sep | 29 | Model Development II — RAG | Retrieval-Augmented Generation architecture. Chunking strategies, embedding, reranking. Evaluation of RAG pipelines. When RAG beats fine-tuning and when it doesn't. | Model Development — Retrieval-Augmented Generation section |  |  |  |
| 9 | 5 | Oct | 1 | Model Development III — Agents | Agent design and orchestration. Tool use, memory, planning loops. Failure modes unique to agentic systems. When to use agents vs. simpler approaches. Morgan Stanley AI at Scale case study. | Model Development — Agent Design and Orchestration; AWS Architecture; Key Takeaways | Lab 3: Model Development | Oct 17, 2026 |  |
| 10 | 6 | Oct | 6 | XOps I — DataOps & MLOps | XOps as the operational foundation of enterprise AI. DataOps: building the data foundation. MLOps: automating the model lifecycle. Where most teams fall short. | The XOps Stack — Motivation through MLOps |  |  |  |
| 11 | 6 | Oct | 8 | XOps II — LLMOps & AgentOps | Operational discipline for foundation model systems. Governance for systems that act. AWS reference XOps architecture. Building XOps capability in your organization. | The XOps Stack — LLMOps through Key Takeaways |  |  |  |
| 12 | 7 | Oct | 13 | Testing & Evaluation I | The testing hierarchy for AI systems. Evaluating predictive models: metrics, baselines, holdout strategy. Production readiness criteria. Google Model Cards case study. | Testing and Evaluation — Motivation through Evaluating Predictive Models; Production Readiness Criteria |  |  |  |
| 13 | 7 | Oct | 15 | Testing & Evaluation II | Evaluating generative AI systems. Evaluating agent systems. Fairness, robustness, and safety evaluation. What “passing” a test actually means at enterprise scale. | Testing and Evaluation — Evaluating Generative AI through Key Takeaways | Lab 4: CI/CD Pipeline.  | Oct 31, 2026 | Think about forming project teams and potential topics.  |
| 14 | 8 | Oct | 20 | Continuous Delivery I | CI/CD for AI: what is genuinely different. Continuous integration for AI: testing data, models, and infrastructure in the pipeline. Spotify Hendrix case study. | Continuous Delivery — Motivation through Continuous Integration | Form Final Project Teams | 2026-10-23 00:00:00 | Record team members and project topic on "Project Groups" tab. |
| 15 | 8 | Oct | 22 | Continuous Delivery II | Continuous delivery for AI. Deployment strategies. Infrastructure automation. Pipeline health and measurement. | Continuous Delivery — Continuous Delivery through Key Takeaways |  |  |  |
| 16 | 9 | Oct | 27 | Deployment & Scaling I | Deployment strategies: canary, blue/green, shadow, feature flags. Serving infrastructure at scale. Lyft ML Platform case study. | Deployment and Scaling — Motivation through Serving Infrastructure |  |  |  |
| 17 | 9 | Oct | 29 | Deployment & Scaling II | Scaling AI workloads from pilot to full production. Resilience and reliability at scale. Organizational readiness and the operational handoff. | Deployment and Scaling — Scaling AI Workloads through Key Takeaways | Lab 5: Deployment & Scaling | Nov 14, 2026 |  |
| 18 | 10 | Nov | 3 | Security, Privacy & Compliance I | The AI security surface. Data security. AI-specific threats: prompt injection, model inversion, adversarial inputs. Security gates in the development lifecycle. AWS infrastructure security. | Security, Privacy & Compliance — Motivation through AI-Specific Threats; Infrastructure Security |  |  |  |
| 19 | 10 | Nov | 5 | Security, Privacy & Compliance II | Privacy engineering. Regulatory compliance frameworks (GDPR, CCPA, EU AI Act). Bridge: what Build hands to Operate. The mindset shift from construction to stewardship. | Security, Privacy & Compliance — Privacy Engineering through Key Takeaways |  |  |  |
| 20 | 11 | Nov | 10 | Metrics, Benchmarks & Guardrails | The four performance dimensions. Leading vs. lagging indicators. Guardrail metrics: encoding risk tolerance as numbers. Experimentation and online validation. Stakeholder views. | Metrics, Benchmarks & Guardrails — full chapter |  |  |  |
| 21 | 11 | Nov | 12 | Monitoring, Observability & Model Lifecycle Management | What monitoring covers in an AI system. Drift detection: the core monitoring problem. Alerting architecture and escalation paths. Observability for generative AI and agent systems. Model lifecycle management. | Monitoring, Observability & Model Lifecycle Management — full chapter | Lab 6: Monitoring & Reliability | Nov 28, 2026 |  |
| 22 | 12 | Nov | 17 | Reliability Engineering | SRE principles applied to AI systems. AI-specific failure modes. AWS reliability architecture. Incident response process. Runbook design and rollback procedures. | Reliability Engineering — full chapter |  |  |  |
| 23 | 12 | Nov | 19 | AI Economics | The full cost structure of enterprise AI. Cost estimation as a design discipline. FinOps for AI. Build vs. buy vs. subscribe. Cost-performance tradeoffs and governance. | AI Economics — full chapter | Lab 7: Metrics, Economics & Business Value | Dec 1, 2026 | Exception to Saturday due-date convention (Dec 10 end-of-semester constraint). |
| 24 | 13 | Nov | 24 | Measuring Business Value | The Metric Pyramid: the central discipline of value translation. The four value dimensions. Attribution: the hard problem. Measuring value for LLM and agentic systems. Shared scorecards. Communicating AI value to non-technical stakeholders. | Measuring Business Value — full chapter |  |  | Team project introduced — teams finalized this week. |
| - | 13 | Nov | 26 | No Class. Thanksgiving Holiday. |  |  |  |  |  |
| 25 | 14 | Dec | 1 | Project Workshop | Team check-ins. Architecture and design review. Q&A on AI Governance content. | AI Governance — full chapter (read before class) |  |  | Lab 7 due today, midnight. |
| 26 | 14 | Dec | 3 | Project Workshop | Team working session. Instructor and TA available for consults. Q&A on Closing the Loop content. | Closing the Loop — full chapter (read before class) |  |  |  |
| 27 | 15 | Dec | 8 | Project Workshop | Final working session. Team presentations dry run (optional). Open Q&A. |  |  |  |  |
| 28 | 15 | Dec | 10 | Final Thoughts | Where AI engineering goes next. What separates the engineers who shape this from those who follow it. How to keep learning after this course ends. |  |  |  | Last day of class. |
| 29 | 16 | Dec | 16 | Final Presentations During Final Exam Time, Wed Dec 16, 3:00–6:00 pm | Team presentations: 15 min + 5 min Q&A each. Room TBD — see Canvas. |  | Final Project: Design Document, Presentation, Code | Dec 17, 2026 (11:59 PM) | Team size 3–4; presentation schedule posted on Canvas by Dec 1. |

## Project Groups

|  | CS 401R-4 F26 MLOps Project Groups |  |  |
|  | Group 1 | Group Member Names | Topic 1 |
|  | 1 |  |  |
|  | 2 |  |  |
|  | 3 |  |  |
|  | 4 |  |  |
|  | Group 2 | Group Member Names | Topic 2 |
|  | 1 |  |  |
|  | 2 |  |  |
|  | 3 |  |  |
|  | 4 |  |  |
|  | Group 3 | Group Member Names | Topic 3 |
|  | 1 |  |  |
|  | 2 |  |  |
|  | 3 |  |  |
|  | 4 |  |  |
|  | Group 4 | Group Member Names | Topic 4 |
|  | 1 |  |  |
|  | 2 |  |  |
|  | 3 |  |  |
|  | 4 |  |  |
|  | Group 5 | Group Member Names | Topic 5 |
|  | 1 |  |  |
|  | 2 |  |  |
|  | 3 |  |  |
|  | 4 |  |  |
|  | Group 6 | Group Member Names | Topic 6 |
|  | 1 |  |  |
|  | 2 |  |  |
|  | 3 |  |  |
|  | 4 |  |  |
|  | Group 7 | Group Member Names | Topic 7 |
|  | 1 |  |  |
|  | 2 |  |  |
|  | 3 |  |  |
|  | 4 |  |  |
