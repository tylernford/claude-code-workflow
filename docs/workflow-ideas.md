# Workflow Ideas

Ideas and improvements for the Claude Development Workflow.

---

## 2026-01-16: Design Doc Status Field

**Idea:** Add a status field to design doc template:

```markdown
**Status:** Draft | Ready | In Progress | Complete
```

**Why:** When multiple design docs exist, this helps identify which ones are ready to be picked up for implementation vs. still being refined.

**Noted:** Noted 2026-01-16 in docs/design-plans/2026-01-16-decouple-design-from-implementation.md

---

## 2026-01-27: Design Scope and Documentation Drift

**Source:** Craft CMS + Next.js Integration retrospective

### The Problem

A 10-task design spanning Craft CMS configuration and Next.js integration became difficult to manage. Multiple architectural pivots (Draft Mode → query param preview) caused documentation drift. By Task 9, original specs were stale and multiple docs were out of sync.

### Root Cause

The `/document` phase wasn't run between Plan 1 (Craft setup) and Plan 2 (Next.js code). This meant:

1. Plan 2's assumptions (e.g., `CRAFT_PREVIEW_TOKEN` env var) were based on Plan 1's *design* rather than its *actual outcome*
2. Deviations compounded without a checkpoint to catch them
3. The Build Log grew unwieldy, mixing two distinct phases of work

### Lesson Learned

**The `/document` phase is a synchronization checkpoint, not just bookkeeping.**

It forces you to:
- Reconcile what was planned vs. what was built
- Update specs before dependent work begins
- Keep the Build Log focused on a single coherent scope

### Guidelines

1. **5 tasks max per design** — If it's bigger, it's probably two features
2. **Split by system boundary** — "CMS setup" and "frontend code" are separate designs
3. **One design = one `/document`** — Complete the cycle before starting dependent work
4. **Drift is inevitable; checkpoints catch it** — The longer between `/document` phases, the more drift accumulates

### See Also

- Design doc: [2026-01-25-craft-nextjs-integration.md](../design-plans/2026-01-25-craft-nextjs-integration.md) (Retrospective section)

---

## 2026-02-14: Move Build Log to Implementation Plan

**Idea:** The Build Log currently lives in the design doc, which forces `/build` to require both the implementation plan and the design doc. Move the Build Log to the implementation plan so that `/build` only needs one document.

**Why:** The design doc is the "what and why" — it should be a `/design` → `/plan` artifact. The implementation plan is the "how" — it should own the full build story: tasks, acceptance criteria, build log, and deviations. This is a cleaner separation of concerns.

**Impact on other phases:**
- `/build` no longer needs the design doc path. It reads and writes only the implementation plan.
- `/document` is simplified — acceptance criteria, verification checklist, and build log are all in one place. Marking checkboxes as complete (currently missed — see below) becomes straightforward.
- `/plan` is unchanged — it still reads the design doc to produce the implementation plan.

**Also fixes:** During `/document`, acceptance criteria checkboxes in the design doc and verification checklist items in the implementation plan were not being marked as complete (noted 2026-01-16). With everything in the implementation plan, `/document` Step 2 can mark all checkboxes in a single document.
