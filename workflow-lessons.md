# Workflow Lessons

Process and workflow learnings from building Firestarter. These capture how we work, not what we built.

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
