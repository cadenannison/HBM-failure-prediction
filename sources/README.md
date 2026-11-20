# CS 401R sources

Everything for BYU CS 401R (Engineering the AI Enterprise, Fall 2026, Dr. Scott Toborg) and the PANIC final project, in one place. Organized Nov 20, 2026.

**Start here:** `02-final-project/charter-review.md` (charter due **Sat Nov 21, 11:59 PM**), then `02-final-project/project-overview.md`.

## 01-course-material: the full Canvas course

Scraped from Canvas Nov 20 (quizzes and exams were not opened). See its own `README.md`.

- `syllabus.md`, `schedule.md`, `modules.md`, `announcements.md` (28 posts)
- `final-project-slides.md` (requirements, rubric elements), `prr-template.md`, `prr-guide.md`
- `assignments/` (labs, final project, errata, other)
- `pages/`
- `files/`: book chapters 17 to 31 plus the full manuscript, split into 7 parts under 45 MB in `files/book/EAIE_Manuscript_parts/` (pre-publication, **do not share outside the course**), lecture slides L01 to L23, lab handouts and starter kits, final project files
- `text/`: searchable markdown of every slide deck and book chapter
- `files-index.md`: what each downloaded file is

## 02-final-project: PANIC

| File | What |
|---|---|
| `Group Project Charter.docx` | The team's charter (original, moved here) |
| `Group Project Charter.pdf` | Rendered copy |
| `group-project-charter.md` + `charter-media/` | Charter text and its two images |
| `charter-review.md` | Gaps vs. the assignment, fixes, and a ready-to-paste architecture description |
| `project-overview.md` | Name, pitch, two-sentence description, action tiers, rollout, topic submission |
| `team-and-roles.md` | Teammate 1 to 4 → names, responsibilities, handoffs, working agreement |
| `professor-feedback.md` | Dr. T's feedback (verbatim) and our answers |
| `decisions-log.md` | What we decided and why |
| `docs/proposal.md` | Export of the Proposal doc |
| `docs/build-plan.md` | Export of the Build Plan doc |
| `docs/team-plan.md` | Export of the Team Plan doc |

Live versions of the docs: [Proposal](https://claude.ai/artifact/GgGmF9MPvpHVt8BfD95xmz) · [Build Plan](https://claude.ai/artifact/1bCGiiwsvCKxcr49jcviTC) · [Team Plan](https://claude.ai/artifact/KDFMDKHxjEhqixLtfGbZ5k). Earlier pages: [timeline](https://claude.ai/artifact/2s1PrcpJrLftT4mDpAexpR) · [recipe](https://claude.ai/artifact/MBo3ef6dnFqg94CyXSQ1mK).

## 03-dataset: Calchas

- `Calchas/`: link to the original repo, https://github.com/wrl297/Calchas (git submodule at commit 9d3955c; clone with `--recurse-submodules` to get it)
- `calchas-data/`: the dataset itself, copied exactly from that commit: `raw_data/dataset(opensource).csv` (20,391 events) and `processed_data/` (row, column, bank, server tables)
- `calchas-data-notes.md`: columns, counts, labels, catches, benchmarks
- `baseline.py`: quick random-forest baseline (`python baseline.py "calchas-data/processed_data"`)

## 04-research

- `prior-work-and-datasets.md`: who has done this, which other datasets exist and why we didn't use them
- `economics-and-scale.md`: crash-cost math, $2.91M savings case, HBM stack counts per fleet

## 05-diagrams

- `hbm-early-warning-architecture.png`: PANIC architecture (charter image)
- `hbm-early-warning-gantt.png`: Gantt chart, Nov 20 to Dec 17 (fixed "Fleet simulator" typo)
- `hbm-early-warning-recipe.png`, `hbm-recipe-simple.png`, `hbm-recipe-rubric.png`, `hbm-build-recipe.png`: earlier recipe pictures
- `html-sources/`: the HTML each picture was rendered from, plus the earlier plan and recipe pages

## 06-explainers

- `panic-story.md`: the whole system as a story, plain words, with who builds what
- `aws-tools-cheat-sheet.md`: every AWS tool, what it does, who owns it, and which are new beyond the labs

## Kept outside this folder on purpose

- `CS 401R\HBM-failure-prediction`: the team's GitHub repo (github.com/cadenannison/HBM-failure-prediction)
- `CS 401R\cs401r-rgammoh`: your lab repo (Labs 6 and 7 in progress)
- `CS 401R\Credintials for cs401r-lab`: untouched
- `CS 401R\presentation`: AI Infinite Zoom project, not Canvas material
- `CS 401R\originals\EAIE_Manuscript.pdf`: the single 207 MB manuscript (too big for GitHub; the split parts are in `sources`)
- `CS 401R\_to_delete`: duplicates and temp files to delete by hand
