# Lab 7 — Metrics, Economics & Business Value

- Due (UTC): 2026-12-02T06:59:00Z
- Points: 100
- Submission: online_url

**Assigned:** Thu Nov 19 | **Due:** Tue Dec 1, midnight *(Tuesday exception — see syllabus)*  
**Chapters:** *Metrics, Benchmarks & Guardrails*, *AI Economics*, *Measuring Business Value*  
**Builds on:** Labs 1–6 — measures the value and cost of the platform you built

## Objective

The NorthStar platform is live. Now answer the question every CFO and CDO will ask: *is it worth it?*

This lab builds the measurement infrastructure to answer that question rigorously — a metric pyramid, unit economics computed from your own measured usage, and an executive scorecard that traces from model outputs to business outcomes. Every number you produce must be derived from something you or the reference implementation actually observed. **Invented figures score zero even when they are plausible.**

Governance and closing-the-loop content is addressed in the team project. This lab is economics and value measurement.

## Starter Kit

**None.** Labs 5–7 have no starter kit. Lab 7 consumes what Labs 1–6 produced.

## Getting Your Repository

Keep working in the repository you created for Lab 1, `cs401r-<your-netid>`.
This lab extends the platform you already built; **do not start a new repository.**

### Submitting Lab 7

When you are ready to submit, tag the commit you want graded and push the tag:

```
git tag lab7-submit
git push origin lab7-submit
```

Then submit **your repository URL** in Canvas. You do not submit the tag name —
it is always `lab7-submit` for this lab, and the TA looks for it.

The TA grades `git checkout lab7-submit`, so anything you push afterwards while
starting the next lab does not change this lab's grade. **If you forget the tag, you
are graded at your last commit before the Canvas deadline** — which, if you have already
started the next lab, may not be the work you meant to submit. Tag it.

> **Public repositories, deliberately.** You may read how other students approached
> the problem. Copying their work is plagiarism and is handled under the BYU Honor
> Code — commit your own. And because these are public: never commit credentials.
> No `.env`, no `terraform.tfvars`, no AWS keys. Committed secrets are an automatic
> zero. The provided `.gitignore` already excludes them; do not remove those lines.

---

## Tasks & Point Breakdown

| Task | Points |
| --- | --- |
| Task 1 — Metric Pyramid 1. | 25 |
| Task 2 — Unit Economics All four parts. | 25 |
| Task 3 — Executive Value Scorecard Produce a one-page scorecard in Section 3. | 25 |
| Task 4 — Value Methodology Note Write a complete value methodology note for **one** NorthStar AI system, in Section 4. | 15 |
| Task 5 — Measurement Reflection Roughly 300 words in Section 5. | 10 |
| **Total** | **100** |

**Full lab guide, rubrics and worked detail:** [Open the full lab guide](https://byu.instructure.com/courses/38938/files/14340094?wrap=1)

## Submission

Submit your repository URL and the tag `lab7-submit`, including your cost model and business case.

## Submission

Submit a GitHub repository link before the deadline.
A repo that does not clone cleanly loses 20 points automatically.
Never commit AWS credentials — committed secrets = automatic 0.

**Late policy:** 10% per calendar day. Contact instructor before the deadline, not after.
