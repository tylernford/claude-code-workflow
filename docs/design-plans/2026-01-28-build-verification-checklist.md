# Build Phase Verification Checklist

**Created:** 2026-01-28
**Status:** Design

---

## Overview

**What:** Add a verification checklist step to the end of the `/build` phase that runs before Phase Complete.

**Why:** Currently, the Verification Checklist in implementation plans gets checked retroactively during the Document phase. This means "verification" is actually "assumption" — potential issues can slip through unnoticed. By running verification during Build, we ensure the feature actually works before handoff.

**Type:** Process

---

## Requirements

### Must Have
- [ ] `/build` prompts to run verification checklist after all tasks complete
- [ ] Each checklist item is verified with user before marking complete
- [ ] Checklist items are marked `[x]` in the implementation plan
- [ ] Failed items block Phase Complete until fixed
- [ ] Phase Complete announcement confirms verification passed

### Nice to Have
- (none identified)

### Out of Scope
- Marking individual tasks as complete in plan doc
- Changes to implementation plan template
- Automatic (non-interactive) verification

---

## Design Decisions

### When to run verification
**Options considered:**
1. Run checklist items as tasks complete (parallel to tasks) — Complex mapping, items don't match 1:1 with tasks
2. Run all checklist items at the end, before Phase Complete — Simple, matches how checklists are structured

**Decision:** Option 2. The Verification Checklist contains acceptance tests for the whole feature, not per-task verification. Running them after all tasks complete makes sense.

### Prompt vs automatic
**Options considered:**
1. Automatically run checklist (no prompt) — Faster, but less control
2. Prompt first: "Run verification checklist before completing?" — User stays in control

**Decision:** Option 2. Keeps user in control and makes the workflow step explicit.

### Handling failures
**Options considered:**
1. Log failure and continue to Phase Complete — Defeats the purpose of verification
2. Block Phase Complete until all items pass — Ensures verification is meaningful

**Decision:** Option 2. If verification fails, fix the issue, log the deviation, re-verify, then proceed.

---

## Acceptance Criteria

- [ ] After all tasks complete, `/build` prompts: "Run verification checklist before completing?"
- [ ] User confirms before checklist runs
- [ ] Each checklist item is presented and verified with user
- [ ] Verified items are marked `[x]` in the implementation plan doc
- [ ] If an item fails: issue is fixed, deviation logged, item re-verified
- [ ] Phase Complete only announced after all items pass
- [ ] Phase Complete message includes "Verification checklist passed."

---

## Files to Create/Modify

```
.claude/commands/build.md  # Add Verification Checklist section, update Phase Complete
```

---

## Build Log

*Filled in during `/build` phase*

| Date | Task | Files | Notes |
|------|------|-------|-------|
| 2026-01-28 | Task 1 | .claude/commands/build.md | Added Verification Checklist section between Handling Deviations and Phase Complete |

---

## Completion

**Completed:** [Date]
**Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]
