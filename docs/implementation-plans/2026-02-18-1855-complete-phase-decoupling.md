# Implementation Plan: Complete Phase Decoupling

**Design Spec:** docs/design-specs/2026-02-18-1724-complete-phase-decoupling.md
**Created:** 2026-02-18

---

## Summary

Fully decouple `/document` from the design spec by having `/plan` carry Type and Overview
into the implementation plan header, so downstream phases never need to read the design
spec. Update `/document` to source PR draft content entirely from the implementation plan.

---

## Codebase Verification

_Confirm assumptions from design spec match actual codebase_

- [x] `/plan` has Steps 1-4, no Type/Overview confirmation step — Verified: yes
- [x] `/plan` has a separate "Update Design Spec" section (line 87) — Verified: yes
- [x] `/document` reads the design spec in Prerequisite and Step 1 — Verified: yes
- [x] `/document` PR draft sources from design spec Overview and "Files to Create/Modify"
      — Verified: yes
- [x] Design spec template has "Files to Create/Modify" section heading — Verified: yes
- [x] Implementation plan template header order is `Design Spec, Created` — Verified: yes,
      needs reorder + new fields

**Patterns to leverage:**

- Existing header field format in templates (`**Field:** value`)
- `/plan` already reads the design spec in Step 1

**Discrepancies found:**

- None

---

## Tasks

### Task 1: Update implementation plan template

**Description:** Add Type and Overview fields to the implementation plan template header,
and reorder fields to: Created, Type, Overview, Design Spec.

**Files:**

- `docs/templates/implementation-plan.md` — modify

**Code example:**

Current header (line 3):

```
**Design Spec:** [link to design spec] **Created:** YYYY-MM-DD
```

New header:

```
**Created:** YYYY-MM-DD **Type:** [type] **Overview:** [overview] **Design Spec:** [link to design spec]
```

**Done when:** Template header has four fields in order: Created, Type, Overview, Design
Spec. **Commit:** "Update implementation plan template with Type and Overview fields"

---

### Task 2: Update `/plan` — add Type/Overview confirmation step, write design spec path at creation time

**Description:** Two changes to `.claude/commands/plan.md`:

1. Add a new **Step 5: Confirm Type and Overview** after Step 4 (Plan Validation). This
   step reads Type and Overview from the design spec, presents them to the user for
   confirmation, and carries them into the implementation plan.
2. Update the "Write Implementation Plan" section to include writing all four header
   fields (Created, Type, Overview, Design Spec) at creation time.

**Files:**

- `.claude/commands/plan.md` — modify

**Done when:**

- Step 5 exists with instructions to confirm Type and Overview with the user
- "Write Implementation Plan" section instructs writing all four header fields

**Commit:** "Add Type/Overview confirmation to /plan"

---

### Task 3: Update `/document` — remove design spec dependency, source PR draft from implementation plan

**Description:** Four changes to `.claude/commands/document.md`:

1. **Prerequisite:** Remove references to reading the design spec. The implementation plan
   is the only input.
2. **Step 1:** Remove reading the design spec. Summarize from implementation plan only.
   Read Type and Overview from the implementation plan header.
3. **Step 3 (Changelog):** Changelog entry still includes the design spec path, but read
   from the implementation plan's `**Design Spec:**` header field.
4. **PR Draft Generation:** Type prefix from implementation plan's Type field, Summary
   from implementation plan's Overview field, Changes from Build Log.

**Files:**

- `.claude/commands/document.md` — modify

**Done when:**

- No mention of reading the design spec file anywhere in the command
- PR draft sources Type, Overview, and Changes from the implementation plan
- Changelog entry gets design spec path from implementation plan header

**Commit:** "Decouple /document from design spec, source PR draft from implementation
plan"

---

### Task 4: Rename design spec template section

**Description:** Rename "Files to Create/Modify" to "Suggested Files to Create/Modify" in
the design spec template.

**Files:**

- `docs/templates/design-spec.md` — modify

**Done when:** Section heading reads "Suggested Files to Create/Modify". **Commit:**
"Rename design spec template section to Suggested Files to Create/Modify"

---

## Acceptance Criteria

- [x] `/plan` has a Step 5 that confirms Type and Overview with the user
- [x] Implementation plan template header includes Type and Overview fields in order:
      Created, Type, Overview, Design Spec
- [x] `/plan` writes the design spec path into the implementation plan when writing the
      file
- [x] `/document` prerequisite does not read or reference the design spec file
- [x] `/document` PR draft title prefix comes from implementation plan's Type field
- [x] `/document` PR draft summary comes from implementation plan's Overview field
- [x] `/document` PR draft changes come from implementation plan's Build Log
- [x] Changelog entry includes design spec path (read from implementation plan header, not
      from the design spec file itself)
- [x] Design spec template section reads "Suggested Files to Create/Modify"

---

## Build Log

_Filled in during `/build` phase_

| Date       | Task   | Files                                 | Notes                                                                                                                                                                                                        |
| ---------- | ------ | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 2026-02-18 | Task 1 | docs/templates/implementation-plan.md | Reordered header fields, added Type and Overview                                                                                                                                                             |
| 2026-02-18 | Task 2 | .claude/commands/plan.md              | Added Step 5, updated Write Implementation Plan section                                                                                                                                                      |
| 2026-02-18 | Task 3 | .claude/commands/document.md          | Removed design spec dependency, sourced PR draft from implementation plan. Deviated: PR summary sources from Overview + Build Log (not just Overview). Also updated Phase Complete template for consistency. |
| 2026-02-18 | Task 4 | docs/templates/design-spec.md         | Renamed section to Suggested Files to Create/Modify                                                                                                                                                          |

---

## Completion

**Completed:** [Date] **Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]

---

## Notes

- The design spec uses "Overview" as the field name; the implementation plan carries it
  forward as "Overview" (not renamed).
- `/plan` still updates the design spec header with the implementation plan path (existing
  "Update Design Spec" section stays).
