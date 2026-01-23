# Workflow Ideas

Ideas and improvements for the Claude Development Workflow.

---

## /document: Mark checkboxes as complete

**Context:** During the 2026-01-16 documentation session for "Decouple Design from Implementation," the Requirements/Acceptance Criteria checkboxes in the design doc and the Verification Checklist in the implementation plan were left unchecked — even though the work was complete.

**Problem:** The `/document` prompt focuses on the Completion section and Build Log but doesn't instruct marking original requirements as verified/complete.

**Proposed fix:** Add to `/document` Step 2:
- Mark all Requirements and Acceptance Criteria checkboxes in the design doc
- Mark all Verification Checklist items in the implementation plan

---

## Design doc status field

**Idea:** Add a status field to design docs with states like Draft / Ready / In Progress / Complete.

**Why:** Would make it clearer which designs are ready for implementation vs. still being refined.

*Noted in: docs/design-plans/2026-01-16-decouple-design-from-implementation.md*
