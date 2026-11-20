# PRR TEMPLATE (extracted from AI Model Production Readiness Review (PRR) Template.docx)


## AI Model Production Readiness Review (PRR) Template

Nov 2, 2026 · @Scott T Toborg

## How to use this template

A PRR is the go/no-go gate a model must pass before it serves real users: the owning team presents evidence, and reviewers from SRE, security, data, and Responsible AI sign off or block. Fill every item with a link to evidence, not a yes/no.

When to run it: before first production launch, before a major version or model swap (including a foundation-model upgrade behind an LLM feature), and when the use case or user population changes materially.

Tiering: scale depth to risk. Tier 1 (customer-facing, regulated, or automated decisions about people) completes every section. Tier 2 (internal, human-in-the-loop) may mark sections 5 and 11 "lite". Tier 3 (offline analytics, no user impact) completes sections 1, 4, 7, 9 only.

Process:

Model owner drafts this doc 2 weeks before the target launch date.

Reviewers comment async; blocking items are tagged [BLOCKER].

Live review meeting (60 min): walk the risk register and open blockers.

Decision recorded in section 12: Go, Go with conditions (dated follow-ups), or No-go (re-review required).

Doc is archived with the model version in the registry; re-reviewed at the cadence set in section 11.

## 0. Review metadata and sign-off

## 1. Business context and success criteria

☐ Problem statement and the decision or action the model drives

☐ Users and affected parties (including people the model makes decisions about)

☐ Business KPI the launch must move, with baseline and target (e.g., handle time -15%)

☐ Non-ML fallback: what happens if the model is turned off

☐ Cost envelope: expected cost per 1,000 predictions or per conversation, and monthly budget cap

☐ Explicit out-of-scope uses

## 2. Model card summary

☐ Model card linked (intended use, architecture or base model, training data summary, limitations)

☐ For hosted LLMs: provider, model ID pinned to a dated version, system prompt version, tools/RAG sources

☐ Known failure modes and populations where performance is weaker

☐ Reproducibility: training code, config, data snapshot, and seed recorded in the registry

☐ Third-party model and dataset licenses reviewed

## 3. Data readiness

☐ Training/eval data lineage documented; owners and refresh cadence named

☐ Train/serve skew check: same feature code path or parity test passing

☐ Input schema and validation at the serving boundary (types, ranges, nulls, max prompt length)

☐ Data quality checks in the pipeline with alerting (freshness, volume, null rate)

☐ Leakage review: no target leakage, no eval data in training or fine-tuning sets

☐ PII inventory: what personal data enters training, prompts, logs, and vector stores

☐ Retention and deletion: how a user-deletion request propagates to features, logs, and embeddings

## 4. Evaluation and quality

Record launch thresholds before looking at final results, so the bar is not moved to fit.

☐ Comparison against the current production model or baseline on the same held-out set

☐ Slice analysis by segment, region, language, device, and protected attributes where lawful

☐ Robustness: out-of-distribution inputs, adversarial or malformed inputs, empty inputs

☐ LLM features: versioned eval suite (golden set plus LLM-as-judge rubric calibrated against human labels)

☐ Eval suite runs in CI and blocks promotion on regression; data, model, infrastructure and monitoring tests scored against the 28 tests of the ML Test Score rubric

## 5. Responsible AI and safety

☐ AI system impact assessment completed (who could be harmed, how, how badly, how reversibly), following ISO/IEC 42005:2025; re-run when intended use, users, environment, or applicable law changes

☐ Fairness metrics across groups, with the accepted disparity bound and rationale

☐ Human oversight: where a human reviews, overrides, or appeals a model decision

☐ Transparency (EU AI Act Article 50, applicable since 2 Aug 2026): users told they are interacting with AI; AI-generated content carries machine-readable marking (systems on the market before 2 Aug 2026 have until 2 Dec 2026)

☐ GenAI features: risks reviewed against the 12 categories in NIST AI 600-1 (e.g., confabulation, data privacy, information integrity, harmful content)

☐ Red-team results for prompt injection, jailbreaks, harmful output, and data exfiltration via tools

☐ Content filters and output guardrails configured and tested

☐ Agents: least-privilege tool permissions; irreversible actions require human confirmation

## 6. Security and privacy

☐ Threat model covering the model artifact, endpoint, training pipeline, and supply chain (base models, packages, MCP/tool servers), mapped to the NIST Cyber AI Profile, IR 8596 draft

☐ LLM features: controls checked against the OWASP Top 10 for LLM Applications 2025, including prompt injection, system prompt leakage, vector and embedding weaknesses (RAG), and unbounded consumption (token floods, runaway cost)

☐ Agents: controls checked against the OWASP Top 10 for Agentic Applications 2026, including goal hijack, tool misuse, identity and privilege abuse, and agentic supply chain

☐ Model artifacts signed or hash-verified; ML bill of materials (ML-BOM) recorded; registry access controlled

☐ Endpoint authN/authZ, rate limiting, and abuse detection

☐ Secrets (API keys, provider credentials) in a secrets manager, rotated; agents use scoped, per-task identities

☐ Privacy review: data minimization, consent basis, cross-border transfer, provider data-retention terms

☐ Logs redact PII and secrets; prompt/response logging has an approved retention period

## 7. Infrastructure and serving

☐ Serving pattern documented (real-time endpoint, batch, streaming, edge) with architecture diagram linked

☐ Load test at 2x expected peak QPS; results meet latency SLO

☐ Autoscaling policy, min/max capacity, and GPU/accelerator quota confirmed

☐ Dependency map: feature store, vector DB, external LLM provider, each with timeout and retry settings

☐ Provider outage plan: fallback model or degraded mode if the hosted LLM is down or rate-limited

☐ Infrastructure as code; environments (dev/staging/prod) promoted through the same pipeline

☐ Cost alarms on spend and token usage

## 8. Observability and monitoring

☐ SLOs defined: availability, latency, error rate, with error budget

☐ Operational dashboards: traffic, latency, errors, saturation

☐ Model-quality monitoring: input drift, prediction drift, and delayed-label performance where labels arrive later

☐ LLM features: tracing of prompts, retrievals, tool calls, and token counts; sampled online evals that track non-deterministic output quality and its latency profile, not just uptime

☐ Alerts route to the on-call rotation, each with a runbook link

☐ Feedback loop: how user feedback and corrections are captured for retraining or eval sets

## 9. Rollout and rollback

☐ Rollout plan: shadow → canary (e.g., 1% → 10% → 50% → 100%) with hold time per stage

☐ Automated promotion/abort criteria tied to section 4 thresholds, verified on live canary traffic rather than only synthetic load tests

☐ Feature flag or traffic switch to disable the model in under 5 minutes

☐ Rollback tested in staging: previous model version restorable, and compatible with current features/schema

☐ A/B test design if the KPI needs causal measurement (sample size, duration)

☐ Communication plan for support teams and affected users

## 10. Operations and ownership

☐ On-call rotation named, with escalation path to the ML team (not only platform SRE)

☐ Runbook: common alerts, triage steps, rollback, how to page the LLM provider

☐ Incident severity definitions include model-specific harms (biased output, harmful content, data leak)

☐ Retraining or re-evaluation cadence and trigger (scheduled, drift-based, or on provider model change)

☐ Decommission plan: how the model and its data are retired

## 11. Compliance and governance

☐ Applicable regulations and frameworks identified, using current versions (see Sources):

EU AI Act as amended by the Digital Omnibus on AI, Regulation (EU) 2026/1744: Article 50 transparency duties apply from 2 Aug 2026; Annex III high-risk obligations now apply from 2 Dec 2027; Annex I (AI in regulated products) from 2 Aug 2028

US banking: SR 26-2 (17 Apr 2026) supersedes SR 11-7; generative and agentic AI are outside its scope, so govern them under your own AI policy

NIST AI RMF 1.0 (under revision) plus the Generative AI Profile, NIST AI 600-1 for GenAI systems

ISO/IEC 42001 (AI management system) and sector rules (e.g., HIPAA; for credit decisions, ECOA and Regulation B, 12 CFR 1002.9 adverse-action reasons)

☐ Model entered in the organization's AI/model inventory with its risk tier and materiality

☐ Independent validation with effective challenge where required (Tier 1); vendor and third-party models validated too, per SR 26-2

☐ EU high-risk systems: note that systems placed on the market before the new dates are covered only if substantially modified afterward; record the placing-on-market date

☐ Audit trail: decisions, versions, and approvals retrievable for a given prediction date

☐ Re-review cadence set (e.g., Tier 1 every 6 months, Tier 2 annually) and triggered on any change in intended use, users, data, or applicable law

## 12. Risk register, open items, and decision

Decision: Go / Go with conditions / No-go

Conditions and deadlines:

Re-review date:

## Sources

Template checked against these primary sources on 2 Nov 2026.

Google SRE book, ch. 32: The Evolving SRE Engagement Model (origin of the PRR); 2nd edition announcement (12 Oct 2026; adds SRE for AI systems)

Breck et al., The ML Test Score (IEEE Big Data 2017)

Federal Reserve SR 26-2, Revised Guidance on Model Risk Management (17 Apr 2026; supersedes SR 11-7 and SR 21-8)

EU AI Act, Regulation (EU) 2024/1689, consolidated text as of 27 Jul 2026 and the amending Regulation (EU) 2026/1744, Digital Omnibus on AI (in force 27 Jul 2026)

NIST AI Risk Management Framework (1.0, under revision) and NIST AI 600-1 Generative AI Profile

NIST IR 8596 Cyber AI Profile, preliminary draft (Dec 2025)

ISO/IEC 42001:2023 AI management system and ISO/IEC 42005:2025 AI system impact assessment

Regulation B (ECOA), 12 CFR 1002.9 Notifications

OWASP Top 10 for LLM Applications 2025 and OWASP Top 10 for Agentic Applications 2026

| Field | Value |

| Model / system name |  |

| Version (registry ID, commit SHA) |  |

| Model type (classical ML, fine-tuned, hosted LLM + RAG, agent) |  |

| Risk tier (1 / 2 / 3) |  |

| Model owner |  |

| Target launch date |  |

| Review meeting date |  |

| Links: repo, model registry, design doc, dashboards, runbook |  |

| Role | Reviewer | Decision (Approve / Block / Conditional) | Date | Notes |

| Model owner / ML lead |  |  |  |  |

| Product owner |  |  |  |  |

| SRE / platform |  |  |  |  |

| Security |  |  |  |  |

| Privacy / legal |  |  |  |  |

| Data owner / steward |  |  |  |  |

| Responsible AI / risk |  |  |  |  |

| Metric | Launch threshold | Offline result | Shadow / canary result | Pass? |

| Primary quality metric (e.g., F1, task success rate, groundedness) |  |  |  |  |

| Guardrail metric (e.g., false positive rate, hallucination rate) |  |  |  |  |

| Latency p50 / p95 / p99 (ms) |  |  |  |  |

| Cost per request |  |  |  |  |

| Worst-performing slice |  |  |  |  |

| Risk | Likelihood (L/M/H) | Impact (L/M/H) | Mitigation | Owner | Due |

|  |  |  |  |  |  |

|  |  |  |  |  |  |

|  |  |  |  |  |  |

| Open item | Blocker? | Owner | Due |

|  |  |  |  |

|  |  |  |  |
