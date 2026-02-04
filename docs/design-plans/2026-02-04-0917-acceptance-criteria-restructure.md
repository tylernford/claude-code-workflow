# Acceptance Criteria Restructure

**Created:** 2026-02-04
**Status:** Design
**Implementation Plan Doc:** docs/implementation-plans/2026-02-04-0926-acceptance-criteria-restructure.md

---

## Overview

**What:** Restructure the `/build` command so acceptance criteria are part of the main Workflow section, not a separate section that gets skipped.

**Why:** Claude was observed skipping the verification checklist during `/build` because it's structurally isolated. When tasks complete, Claude gravitates to "Phase Complete" and misses the verification step. Moving acceptance criteria into the Workflow creates a mandatory gate.

**Type:** Process

---

## Requirements

### Must Have
- [ ] Acceptance criteria subsection inside Workflow (after "For Each Task")
- [ ] Clear sequencing: tasks → acceptance criteria → Phase Complete
- [ ] Rename "Verification Checklist" to "Acceptance Criteria" in both files
- [ ] Delete the standalone Verification Checklist section from `/build`

### Nice to Have
- (none identified)

### Out of Scope
- Existing implementation plans (historical records, not updated)
- Other commands (`/plan`, `/design`, `/document`)

---

## Design Decisions

### Where should acceptance criteria live in `/build`?

**Options considered:**
1. Keep as separate section after Workflow - current state, causes Claude to skip it
2. Add as subsection within Workflow - makes it part of the core build loop
3. Move to Phase Complete section - conflates completion announcement with verification

**Decision:** Option 2. Adding acceptance criteria as a Workflow subsection gives it structural parity with tasks. Both are "things you iterate through during build." Phase Complete becomes unreachable without passing through the acceptance criteria gate.

### What to call it?

**Options considered:**
1. Verification Checklist - current name, sounds like QA paperwork
2. Acceptance Criteria - standard term, ties to "done when" language
3. Completion Checks - simple but vague
4. Exit Criteria - clinical

**Decision:** "Acceptance Criteria" — has nice symmetry with per-task "Done when" criteria. Both prove work is complete.

---

## Acceptance Criteria

- [ ] `/build` Workflow section contains "After All Tasks: Acceptance Criteria" subsection
- [ ] The 4-step ritual (present, verify, mark, fix-if-fail) is preserved in the new location
- [ ] Standalone "Verification Checklist" section is removed from `/build`
- [ ] Phase Complete says "Acceptance criteria passed" (not "Verification checklist passed")
- [ ] Implementation plan template header renamed to "## Acceptance Criteria"

---

## Files to Create/Modify

```
.claude/commands/build.md              # Restructure Workflow, delete standalone section, update wording
docs/templates/implementation-plan.md  # Rename section header
```

---

## Build Log

*Filled in during `/build` phase*

| Date | Task | Files | Notes |
|------|------|-------|-------|

---

## Completion

**Completed:**
**Final Status:**

**Summary:**

**Deviations from Plan:**
