# Design Doc Link to Implementation Plan

**Created:** 2026-01-28 **Status:** Complete **Implementation Plan Doc:**
docs/implementation-plans/2026-01-28-1520-design-doc-link-to-plan.md

---

## Overview

**What:** Add a bidirectional link between design docs and implementation plans by adding
an "Implementation Plan Doc" field to the design doc template and updating the /plan and
/document phase commands.

**Why:** The design doc and implementation plan are companion documents, but currently
only the plan links to the design doc. The /document phase has to search for the plan
instead of following a direct link.

**Type:** Enhancement

---

## Requirements

### Must Have

- [x] Design doc template includes
      `**Implementation Plan Doc:** [link to implementation plan doc]` placeholder
- [x] /plan phase updates the design doc's placeholder with the actual implementation plan
      path after creating the plan
- [x] /document phase reads the link from the design doc header instead of searching
      `docs/implementation-plans/`

### Nice to Have

- None

### Out of Scope

- Backfilling existing design docs with plan links
- Changing the implementation plan template

---

## Design Decisions

### Where to place the link in the design doc

**Options considered:**

1. In the header block (lines 3-4), next to Created/Status — consistent with plan
   template's header
2. In a new "Related Documents" section — more structured but heavier

**Decision:** Header block. Mirrors the plan template's `**Design Doc:**` placement and
keeps it visible at the top.

### Placeholder text style

**Options considered:**

1. `_TBD - created during /plan phase_` — descriptive but inconsistent with plan template
2. `[link to implementation plan doc]` — matches plan template's `[link to design doc]`
   style

**Decision:** `[link to implementation plan doc]` to match the existing convention in the
plan template.

---

## Acceptance Criteria

- [x] Design doc template has
      `**Implementation Plan Doc:** [link to implementation plan doc]` on line 5
- [x] /plan command instructions include a step to update the design doc with the actual
      plan path
- [x] /document command reads the plan path from the design doc header instead of
      searching

---

## Files to Create/Modify

```
docs/templates/design-doc.md          # Add Implementation Plan Doc field to header
.claude/commands/plan.md              # Add step to update design doc with plan link
.claude/commands/document.md          # Read plan link from design doc instead of searching
```

---

## Build Log

_Filled in during `/build` phase_

| Date       | Task   | Files                        | Notes                                                                    |
| ---------- | ------ | ---------------------------- | ------------------------------------------------------------------------ |
| 2026-01-28 | Task 1 | docs/templates/design-doc.md | Added Implementation Plan Doc field to header                            |
| 2026-01-28 | Task 2 | .claude/commands/plan.md     | Added Update Design Doc section after Write Implementation Plan          |
| 2026-01-28 | Task 3 | .claude/commands/document.md | Updated Prerequisite and Step 1 to read plan link from design doc header |

---

## Completion

**Completed:** 2026-01-28 **Final Status:** Complete

**Summary:** Added bidirectional linking between design docs and implementation plans. The
design doc template now includes an `Implementation Plan Doc` field, `/plan` writes the
actual path back into the design doc after creating the plan, and `/document` reads the
link from the design doc header instead of searching.

**Deviations from Plan:** None. All three tasks implemented as designed.
