# PRR GUIDE (extracted from Production Readiness Review.docx)


## Production Readiness Reviews for AI Models

Nov 2, 2026 · @Scott T Toborg

## What a PRR is

A Production Readiness Review (PRR) is a formal gate a model has to pass before it serves real traffic. The team that owns the model brings evidence that the model is good enough, safe enough, and can be operated. Reviewers from outside the team then sign off, add conditions, or block the launch.

A PRR doesn't ask whether the model is accurate. It asks whether the organization can live with this model in production at 3 a.m., under load, after the data drifts, with a regulator asking questions.

The idea comes from Google's SRE practice, where a service needed a PRR before SRE would take over running it (SRE book, ch. 32). The second edition (October 2026) adds a chapter on how SRE supports AI systems, including monitoring non-deterministic outputs and their latency. For ML, the best-known rubric is Google's ML Test Score: 28 tests across data, model, infrastructure and monitoring. Organizations then add governance layers on top, now led by the EU AI Act, the NIST AI RMF, ISO/IEC 42001 and 42005, and, in US banking, SR 26-2.

## What a good PRR looks like

Evidence over assertion. Every item links to something: a dashboard, a load-test report, a red-team log. "Yes, we did that" doesn't count.

Thresholds are set before results come in. That way the bar can't quietly move to fit the numbers.

Depth scales with risk. A credit-decisioning model gets the full review. An internal analytics model gets a light one.

It ends in a recorded decision: Go, Go with conditions (with owners and dates), or No-go.

It's repeated. A new model version, a swapped foundation model, or a new user group triggers another review.

## What changed in 2025–2026

The PRR concept is stable, but the rules and threat lists it checks against moved a lot in the past year. Most important: SR 11-7 is gone, and EU high-risk deadlines slid to December 2027.

## Examples

The four cases below are illustrative scenarios. Models rarely fail a PRR on accuracy. They fail on operations (skew, rollback, alerting, ownership), security and privacy, and failure modes specific to LLMs.

## 1. Fraud detection model at a payments company (classical ML, Tier 1)

Offline AUC beat the current model. The review found two blockers:

Train/serve skew. One feature was computed in a nightly batch for training but in real time for serving, and the values didn't match.

No tested rollback. The new model needed a feature schema the old model couldn't read.

Outcome: Go with conditions.

Add a feature-parity test in CI.

Keep the old model's feature path alive for 30 days.

Ramp the canary 1% → 10% → 50%, with automatic abort if false declines rose more than 0.2 points.

## 2. LLM customer-support assistant (hosted LLM plus RAG, Tier 1)

Reviewers found:

The provider model ID wasn't pinned to a dated version, so the provider could change the model without notice.

Prompts and responses containing customer PII were being logged indefinitely.

Red-teaming showed a prompt injection hidden in a knowledge-base article could make the bot reveal internal refund policies.

There was no plan for a provider outage.

Outcome: No-go, with a re-review two weeks later, after:

pinning the model version

setting a 30-day log retention period with PII redaction

adding retrieval-content sanitization and an output filter

adding a fallback that hands the conversation to a human when the provider returns errors

## 3. Credit-limit model at a bank (regulated)

The PRR folded in independent validation with effective challenge under SR 26-2 (which replaced SR 11-7 in April 2026) and an adverse-action explainability check: under ECOA and Regulation B, 12 CFR 1002.9(b)(2), declined applicants must get specific, principal reasons, however complex the model.

A fairness slice analysis showed a larger approval gap for thin-file applicants than the documented tolerance allowed.

Outcome: the launch went ahead with a human-review queue for that segment and a 90-day re-review.

## 4. Internal demand-forecast model (Tier 3)

A light PRR covering only business context, evaluation, serving, and rollback.

Approved in one meeting. The main condition was naming an owner for the weekly data-freshness alert, which previously went to a shared inbox nobody watched.

## Template

The companion template, AI Model Production Readiness Review (PRR) Template, has a checklist and an evidence slot for every item across 13 sections (0–12). It runs from metadata and sign-offs through data, evaluation, Responsible AI, security, serving, monitoring, rollout, operations and compliance, and ends with a risk register and a decision record. It covers hosted-LLM and agent items alongside classical ML. Its tier rules are suggestions to adjust to your own policy.

## Sources

Primary sources, checked 2 Nov 2026.

Google SRE book, ch. 32: The Evolving SRE Engagement Model and the 2nd edition announcement

Breck et al., The ML Test Score (IEEE Big Data 2017)

Federal Reserve SR 26-2, Revised Guidance on Model Risk Management (supersedes SR 11-7)

EU AI Act, Regulation (EU) 2024/1689, consolidated text as of 27 Jul 2026

Regulation (EU) 2026/1744, Digital Omnibus on AI

NIST AI Risk Management Framework and NIST AI 600-1

NIST IR 8596 Cyber AI Profile, preliminary draft

ISO/IEC 42001:2023 AI management system and ISO/IEC 42005:2025 AI system impact assessment

Regulation B (ECOA), 12 CFR 1002.9 Notifications

OWASP Top 10 for LLM Applications 2025 and OWASP Top 10 for Agentic Applications 2026

| Review | Question it answers | When |

| Design review | Is this the right approach? | Before building |

| Model validation | Is the model statistically sound? | After training; feeds the PRR |

| Production Readiness Review | Is the whole system ready: model, data pipelines, serving, monitoring, rollback, on-call, compliance? | Last gate before launch |

| Date | Source | What changed | What it means for a PRR |

| Oct 2026 | Google SRE book, 2nd ed. | Rewritten; new chapter on how SRE supports AI | Monitor non-deterministic output quality and latency; verify on live canaries |

| Jul 2026 | EU Digital Omnibus on AI, Reg. 2026/1744 | Annex III high-risk duties move to 2 Dec 2027, Annex I to 2 Aug 2028; Article 50 transparency still from 2 Aug 2026 | AI disclosure and content marking are launch gates now; high-risk conformity work can be scheduled |

| Apr 2026 | Federal Reserve SR 26-2 | Replaces SR 11-7 and SR 21-8; risk- and materiality-based; excludes generative and agentic AI | Cite SR 26-2 for traditional and non-generative ML; GenAI needs its own governance path |

| Dec 2025 | OWASP Top 10 for Agentic Applications 2026 | First agent-specific risk list: goal hijack, tool misuse, identity and privilege abuse | Agent launches get their own security checklist |

| Dec 2025 | NIST IR 8596 Cyber AI Profile (draft) | Maps CSF 2.0 to securing AI systems | Threat models can map to CSF outcomes |

| 2025–2026 | NIST AI RMF | AI RMF 1.0 being revised under the White House AI Action Plan; AI 600-1 GenAI Profile remains the GenAI companion | Keep using 1.0 and AI 600-1; recheck mappings when the revision lands |

| May 2025 | ISO/IEC 42005:2025 | Standard for AI system impact assessment | Gives the PRR's impact assessment a recognized method |

| Nov 2024 | OWASP Top 10 for LLM Applications 2025 | Adds system prompt leakage and vector/embedding weaknesses; unbounded consumption covers cost attacks | RAG and cost controls become explicit PRR items |
