/document docs/research/workflow-upgrade/2026-06-25-move-1-validation-plan.md

Phase 3: Document | Step 1: Load and Summarize

Let me start by locating the implementation plan and sourcing the build history from git.

Listed 1 directory, ran 1 shell command

The argument file exists. Let me read the full plan, the harvest doc, and the build
commits with their bodies and file stats.

Read 2 files, ran 1 shell command

Build history is clear. The validation run executed end-to-end: three sandbox commits
(d80af30, 71d3f2e, 317e061) over base e4d5f0c, plus a separate commit of the plan itself
(8da8737). All four Acceptance Criteria are already marked [x] by /build.

Summary of what was built and deviations:

- Built: A throwaway validation sandbox under move-1-sandbox/ — linecount.sh, README.md,
  sample.txt — across three per-task commits with explicit-path staging.
- done_when behavior (the real point): Task 1's candidate hardcoded an absent README.md;
  build re-resolved it against the real plan file, asserting integer output + exit 0. Task
  2's grep was correctly labeled a shallow proxy ("compiles, behavior unverified") and
  paired with the manual:true prose-clarity check. Task 3 was a true behavioral assertion
  (count == 3).
- Deviation: The plan file was committed after the sandbox build (8da8737), not before —
  minor ordering only.

One thing to flag: the harvest doc still reads "⛔ NOT YET RUN — scaffold only" and its
four observations are unfilled, even though the run clearly happened. I'll note that — but
filling it is your analytical call, not part of the doc flow.

Let me read the changelog before updating.

Read 1 file, ran 1 shell command

Now I'll complete the implementation plan's Completion section. All four Acceptance
Criteria are [x] (read-only — /build set them), so Final Status is Complete.

Phase 3: Document | Step 2: Complete Implementation Plan

⏺ Update(docs/research/workflow-upgrade/2026-06-25-move-1-validation-plan.md) Added 30
lines, removed 3 lines

## Completion

**Completed:** [Date] **Final Status:** [Complete | Partial | Abandoned] **Completed:**
2026-06-25 **Final Status:** Complete

**Summary:** [What actually happened during the validation run] **Summary:** The new Move
1 n end-to-end and exercised every behavior it was meant to. The sandbox was built across
three per-task commits with explicit-path staging (`d80a no `git add
-A`, no per-task pauses. Build-time `done_when` resolution behaved as designed on all
three tasks:

**Deviations from Plan:** [Any]

- **Task 1** — the candidate` (absent at that path). Build re-resolved it against the real
  plan file and asserted integer output + exit 0 instead of lifting the candidate v
- **Task 2** — the candidate `grep` was correctly labeled a shallow proxy ("compiles,
  behavior unverified"), andanual: true`) was surfaced separately rather than folded into
  the green.
- **Task 3** — a true behavi resolved cleanly against the real sandbox paths.

The end-of-batch review presented the batch over `e4d5f0c..HEAD`, kept the `(manual)` item
distinct, and made the tinction explicit. All four Acceptance Criteria (`(added)`) were
met and marked by `/build`.

**Deviations from Plan:** Minor only.

- The plan file itself was committed (`8da8737`) **after** the sandbox build rather than
  before — ordering only, no
- The Codebase Verification checkboxes were left `[ ]` in the plan. They are
  informational, not the AC available and used successfully throughout, so this is a
  bookkeeping gap, not an unmet criterion.
- \*\*Open follow-up (not a bu doc (`2026-06-25-move-1-validation-harvest.md`) still reads
  "⛔ NOT YET RUN" with its four observations unfilled, andelete `move-1-sandbox/` + this
  plan, feed findings into Move 1.5) is unchecked. The raw signal for the harvest now
  lives in the commit bodiesnalytical step.

---

## Notes

Now Step 3 (Changelog) — but there's your call on.

Phase 3: Document | Step 3: Update Ch

The changelog is the permanent featurres built using the Claude DevelopmentWorkflow").
This plan is explicitly throwaway — it says "delete move-1-sandbox/ and this plan; they
are scaffolding. Nothing depends on it." at a plan path that's slated fordeletion (a
dangling link), and the real feature it validates — Move 1 of the build phase — has its
own plan (docs/implementation-plans/2026-.md) that warrants its own changelogentry when it
is documented.

⏺ User answered Claude's questions: · Should this throwaway validationg entry? → Add an
entry

Adding the entry. I'll note its valid record stays honest even as thescaffolding gets
removed.

⏺ Update(docs/changelog.md) Added 27 lines

---

## 2026-06-25: Move 1 Validat

A throwaway validation run
th/build`against a deliberately tiny sandbox, to confirm the redesigned loop behaves before trusting it on real work. The sandbox (a`linecount.sh`, a was built across three per-task commits with explicit-path staging and no per-task pauses. The point was the workflow, not the artifact, and all four bee_when`
resolution re-resolved the intentionally-drifted candidate commands instead of lifting
them (Task 1's hardcoded absent `README.md` became a rting file); the shallow `grep` proxy
was labeled "compiles, behavior unverified" and its prose-clarity check surfaced as
`(manual)`; Task 3 was a true ==
3`); and the end-of-batch review presented the batch over `<base>..HEAD`with the manual item kept distinct from the green. The`move-1-sandbox/`
are scaffolding slated for deletion once the harvest is written.

**Design:** [docs/design-specs/2026-06-25design-specs/2026-06-25-1438-bui
ld-phase-move-1.md) **Plan:**
[docs/research/workflow-upgrade/2026-06-25-move-1-validation-plan.md](research/workflow-up
grade/2026-06-25-move-1-valid (throwaway — to be deleted after harvest) **Key files:**

- `docs/research/workflow-upgrade/move-1-sandbox/linecount.sh`
- `docs/research/workflow-upg`
- `docs/research/workflow-upgrade/move-1-sandbox/sample.txt`

---

## 2026-06-24: Acceptance-Criteria Carry-Forward

Acceptance criteria could silently disappear between phases. `/design` writes them and

Phase 3: Document | Step 4: Update README

Skipped — this is internal validation scaffolding with no user-facing functionality. The
README documents the workflow system for developers; along there.

Phase 3: Document | Step 5: Final Not

The commit bodies already captured ththings worth your input before I closeout:

Anything to note — discoveries, surprises, or context not captured in the commit history?
In particular, how did the four harvest observations (batch-review
genuineness,manual-rate, resolution behavior, round-cap pressure)? That's the signal the
harvest doc still needs, and you're the one who watched it run — I plan's Completion
section and/ordraft the harvest from them if you'd like.

If you have nothing to add, I'll finalize as-is.

✻ Sautéed for 1m 45s

❯ no notes

Phase 3: Document | Complete

Documentation updated:

- Implementation plan completed: docs26-06-25-move-1-validation-plan.md(Completion section
  filled, Final Status: Complete)
- Changelog updated: docs/changelog.mthrowaway)
- README: no changes needed (internal validation scaffolding)

Commit checkpoint: Commit the documentation updates before ending this session. (I don't
touch git — the changes are staged in your working tr

One open follow-up, not part of this still an empty "NOT YET RUN" scaffold,and its
disposition checklist (delete move-1-sandbox/ + this plan, feed findings into Move 1.5) is
unchecked. The raw signal now lives ifour-observation write-up is the nextanalytical step
whenever you're ready.

---

PR Draft (copy/paste when creating PR

Title: chore: Move 1 validation run (

Description: Summary

A deliberately tiny, throwaway run to exercise the new Move 1 /build end-to-end before
trusting it on real work: approve-by-exception, builper-task explicit-path commits, and
the end-of-batch review + AC gate. The sandbox was built across three per-task commits
with explicit-path staging and no per-task pauses; all fe move-1-sandbox/ directory
andvalidation plan are scaffolding to be deleted once the harvest is written.

Changes

- docs/research/workflow-upgrade/move-1-sandbox/linecount.sh — sandbox script (add)
- docs/research/workflow-upgrade/movex docs (add)
- docs/research/workflow-upgrade/move-1-sandbox/sample.txt — 3-line behavioral fixture
  (add)
- docs/research/workflow-upgrade/2026.md — plan + Completion section(add/update)
- docs/changelog.md — 2026-06-25 vali

Documentation

- Design: docs/design-specs/2026-06-2
- Plan: docs/research/workflow-upgrade/2026-06-25-move-1-validation-plan.md

---

Feature complete! The workflow cycle
