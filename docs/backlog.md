# Backlog

Open ideas and improvements for the Claude Development Workflow.

---

## 2026-01-16: Design Spec Status Field

**Idea:** Add a status field to design spec template:

```markdown
**Status:** Draft | Ready | In Progress | Complete
```

**Why:** When multiple design specs exist, this helps identify which ones are ready to be
picked up for implementation vs. still being refined.

**Noted:** Noted 2026-01-16 in
docs/design-plans/2026-01-16-decouple-design-from-implementation.md

---

## 2026-01-27: Design Scope and Documentation Drift

**Source:** Craft CMS + Next.js Integration retrospective

### The Problem

A 10-task design spanning Craft CMS configuration and Next.js integration became difficult
to manage. Multiple architectural pivots (Draft Mode → query param preview) caused
documentation drift. By Task 9, original specs were stale and multiple docs were out of
sync.

### Root Cause

The `/document` phase wasn't run between Plan 1 (Craft setup) and Plan 2 (Next.js code).
This meant:

1. Plan 2's assumptions (e.g., `CRAFT_PREVIEW_TOKEN` env var) were based on Plan 1's
   _design_ rather than its _actual outcome_
2. Deviations compounded without a checkpoint to catch them
3. The Build Log grew unwieldy, mixing two distinct phases of work

### Lesson Learned

**The `/document` phase is a synchronization checkpoint, not just bookkeeping.**

It forces you to:

- Reconcile what was planned vs. what was built
- Update specs before dependent work begins
- Keep the Build Log focused on a single coherent scope
- Update onboarding paths (README) when implementation changes affect setup steps,
  commands, or dependencies

### Guidelines

1. **5 tasks max per design** — If it's bigger, it's probably two features
2. **Split by system boundary** — "CMS setup" and "frontend code" are separate designs
3. **One design = one `/document`** — Complete the cycle before starting dependent work
4. **Drift is inevitable; checkpoints catch it** — The longer between `/document` phases,
   the more drift accumulates

### See Also

- Design spec:
  [2026-01-25-craft-nextjs-integration.md](../design-plans/2026-01-25-craft-nextjs-integration.md)
  (Retrospective section)

---

## 2026-01-27: Document phase serves two distinct purposes

Context: The Document phase can feel like busywork — just filling in completion sections.
But it serves two non-obvious functions beyond record-keeping.

Purpose 1: Catches drift Comparing the original plan to what was actually built surfaces
deviations that should be recorded. Implementation often requires adapting to discovered
realities — different library versions, APIs that work differently than expected,
approaches that turned out to be unnecessary. These aren't failures; they're adaptations.
The Document phase ensures they're captured rather than lost.

Purpose 2: Updates the onboarding path Implementation changes often affect how new
developers set up or use the project. Without updating the README during documentation,
the next person to clone the repo won't know about new setup steps, changed commands, or
added dependencies.

Takeaway: Don't treat /document as just "fill in the completion section." It's the
checkpoint that ensures both the historical record and the living documentation (README)
stay accurate.

---

## 2026-02-18: Folder-as-Status System for Design Specs and Implementation Plans

**Idea:** Use folder structure to indicate document status instead of metadata fields:

```
docs/design-specs/active/
docs/design-specs/complete/
docs/implementation-plans/active/
docs/implementation-plans/complete/
```

**Why:** Moving a file between folders is a clear, visible status change. No need to open
the file to check its status. Makes it easy to see what's in progress vs. done at a
glance.

**Origin:** Noted as out of scope in the "Decouple /design from Other Phases" design spec
(2026-02-18).

---

## 2026-03-26: `/learn-by-doing` Stuck Escalation Pacing

**Problem:** The stuck escalation sequence (hint → pointed question → point to pattern →
show answer) doesn't reliably pause between steps. Observed behaviors:

1. **Steps combined into one response** — hint and pointed question delivered together
   instead of pausing for input between each step
2. **Steps skipped entirely** — for "small" questions (e.g., `chmod +x`), jumped straight
   to showing the answer without attempting earlier escalation steps

**Expected:** Each escalation step should be a separate response with a pause for user
input, matching the pause-for-input protocol used elsewhere in the skill. The sequence
should apply regardless of how "simple" the question seems.

**Root cause (suspected):** The skill instructions say "move to the next step only if the
current one doesn't unblock them" but don't explicitly state that each step requires a
pause-for-input. The LLM may also be inferring that trivial questions don't warrant the
full sequence.

**Possible fixes:**

- Add explicit "pause for input after each escalation step" instruction
- Add an example showing the full 4-step sequence with pauses
- Emphasize that escalation applies to all stuck moments, not just "hard" ones

**Origin:** Validation testing of `/learn-by-doing` (2026-03-26). Acceptance criterion 5
remains the only failing criterion.
