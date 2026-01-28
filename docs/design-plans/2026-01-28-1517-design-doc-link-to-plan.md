# Design Doc Link to Implementation Plan

**Created:** 2026-01-28
**Status:** Design
**Implementation Plan Doc:** [link to implementation plan doc]

---

## Overview

**What:** Add a bidirectional link between design docs and implementation plans by adding an "Implementation Plan Doc" field to the design doc template and updating the /plan and /document phase commands.

**Why:** The design doc and implementation plan are companion documents, but currently only the plan links to the design doc. The /document phase has to search for the plan instead of following a direct link.

**Type:** Enhancement

---

## Requirements

### Must Have
- [ ] Design doc template includes `**Implementation Plan Doc:** [link to implementation plan doc]` placeholder
- [ ] /plan phase updates the design doc's placeholder with the actual implementation plan path after creating the plan
- [ ] /document phase reads the link from the design doc header instead of searching `docs/implementation-plans/`

### Nice to Have
- None

### Out of Scope
- Backfilling existing design docs with plan links
- Changing the implementation plan template

---

## Design Decisions

### Where to place the link in the design doc
**Options considered:**
1. In the header block (lines 3-4), next to Created/Status — consistent with plan template's header
2. In a new "Related Documents" section — more structured but heavier

**Decision:** Header block. Mirrors the plan template's `**Design Doc:**` placement and keeps it visible at the top.

### Placeholder text style
**Options considered:**
1. `_TBD - created during /plan phase_` — descriptive but inconsistent with plan template
2. `[link to implementation plan doc]` — matches plan template's `[link to design doc]` style

**Decision:** `[link to implementation plan doc]` to match the existing convention in the plan template.

---

## Acceptance Criteria

- [ ] Design doc template has `**Implementation Plan Doc:** [link to implementation plan doc]` on line 5
- [ ] /plan command instructions include a step to update the design doc with the actual plan path
- [ ] /document command reads the plan path from the design doc header instead of searching

---

## Files to Create/Modify

```
docs/templates/design-doc.md          # Add Implementation Plan Doc field to header
.claude/commands/plan.md              # Add step to update design doc with plan link
.claude/commands/document.md          # Read plan link from design doc instead of searching
```

---

## Build Log

*Filled in during `/build` phase*

| Date | Task | Files | Notes |
|------|------|-------|-------|
| 2026-01-28 | Task 1 | docs/templates/design-doc.md | Added Implementation Plan Doc field to header |
| 2026-01-28 | Task 2 | .claude/commands/plan.md | Added Update Design Doc section after Write Implementation Plan |

---

## Completion

**Completed:** [Date]
**Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]
