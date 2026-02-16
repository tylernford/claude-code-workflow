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

## /document: Mark checkboxes as complete

**Context:** During the 2026-01-16 documentation session for "Decouple Design from Implementation," the Requirements/Acceptance Criteria checkboxes in the design doc and the Verification Checklist in the implementation plan were left unchecked — even though the work was complete.

**Problem:** The `/document` prompt focuses on the Completion section and Build Log but doesn't instruct marking original requirements as verified/complete.

**Proposed fix:** Add to `/document` Step 2:
- Mark all Requirements and Acceptance Criteria checkboxes in the design doc
- Mark all Verification Checklist items in the implementation plan
