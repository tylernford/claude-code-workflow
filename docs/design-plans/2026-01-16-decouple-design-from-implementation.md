# Decouple Design from Implementation Session

**Created:** 2026-01-16
**Status:** Design

---

## Overview

**What:** Reframe the workflow so Design is standalone and Plan/Build/Document form a tightly coupled "Implementation Session."

**Why:** Design often happens separately from implementation — sometimes days or weeks before. The current framing implies a sequential flow (Design → Plan → Build → Document) that doesn't match how work actually happens. By decoupling Design, we better model reality: a "planning day" of design work, followed later by an "implementation day" when you're ready to build.

**Type:** Process

---

## Requirements

### Must Have
- [ ] Update `/design` closing message to reflect standalone nature
- [ ] Update `/plan` to frame itself as the start of an "Implementation Session"
- [ ] Add time-gap awareness to `/plan` Step 2 (Codebase Verification)

### Nice to Have
- None for this iteration

### Out of Scope
- Design doc status field (Draft/Ready/In Progress/Complete) — tracked in `docs/workflow-ideas.md`
- Hierarchical design docs (project-level vs feature-level)
- Automated staleness detection

---

## Design Decisions

### Naming Convention
**Options considered:**
1. Rename phases (e.g., "Implementation Phase 1: Plan") — clearer but more churn
2. Keep names, update language — minimal change, communicates grouping through framing

**Decision:** Option 2. Keep `/design`, `/plan`, `/build`, `/document` as-is. Update the prompt language to communicate that Design is standalone and Plan/Build/Document form an Implementation Session.

### Time-Gap Awareness
**Options considered:**
1. Automated detection of codebase changes since design was written
2. Simple reminder note in the prompt

**Decision:** Option 2. Add a note to `/plan` Step 2 reminding that the design doc may be days/weeks old and the codebase may have changed. Keep it simple.

---

## Acceptance Criteria

- [ ] `/design` closing message no longer implies immediate progression to `/plan`
- [ ] `/plan` opening clearly states this is an "Implementation Session (Plan → Build → Document)"
- [ ] `/plan` Step 2 includes a note about potential time gap since design was written

---

## Files to Create/Modify

```
.claude/commands/design.md  # Update closing message
.claude/commands/plan.md    # Update opening framing + Step 2 note
```

---

## Specific Changes

### `.claude/commands/design.md` — Closing Message

Replace:
```
Next: End this session and start a new Claude Code session.
Run `/plan` to begin Phase 2: Planning.
```

With:
```
Design is complete.

When ready to implement, start a new Claude Code session and run `/plan` to begin
an Implementation Session (Plan → Build → Document).
```

### `.claude/commands/plan.md` — Opening Framing

Replace:
```
You are starting **Phase 2: Plan**
```

With:
```
You are starting an **Implementation Session** — Phase 1: Plan

This session will take you through Plan → Build → Document.
```

### `.claude/commands/plan.md` — Step 2 Note

Add after `### Step 2: Codebase Verification`:
```
Note: The design document may have been written days or weeks ago. The codebase may have changed since then.
```

---

## Build Log

*Filled in during `/build` phase*

| Date | Task | Files | Notes |
|------|------|-------|-------|
| | | | |

---

## Completion

**Completed:** [Date]
**Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]
