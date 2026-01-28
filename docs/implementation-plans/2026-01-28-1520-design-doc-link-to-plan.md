# Implementation Plan: Design Doc Link to Implementation Plan

**Design Doc:** docs/design-plans/2026-01-28-1517-design-doc-link-to-plan.md
**Created:** 2026-01-28

---

## Summary

Add bidirectional linking between design docs and implementation plans. The design doc template gets an `Implementation Plan Doc` field, /plan writes the actual path back into the design doc, and /document reads the link instead of searching.

---

## Codebase Verification

- [x] Design doc template exists at `docs/templates/design-doc.md` — header has Created and Status, no Implementation Plan Doc field yet
- [x] `/plan` command at `.claude/commands/plan.md` — creates plan file but does not update the design doc
- [x] `/document` command at `.claude/commands/document.md` — Step 1 searches for the implementation plan with no direct link mechanism
- [x] Implementation plan template at `docs/templates/implementation-plan.md` — has `**Design Doc:** [link to design doc]` for reference on matching style

**Patterns to leverage:**
- The implementation plan template already uses `**Design Doc:** [link to design doc]` — mirror this style in the design doc template

**Discrepancies found:**
- None

---

## Tasks

### Task 1: Add Implementation Plan Doc field to design doc template
**Description:** Add `**Implementation Plan Doc:** [link to implementation plan doc]` as line 5 of the design doc template header, after the Status field.
**Files:**
- `docs/templates/design-doc.md` - modify

**Code example:**
```markdown
**Created:** YYYY-MM-DD
**Status:** Design | Planning | Building | Complete
**Implementation Plan Doc:** [link to implementation plan doc]
```

**Done when:** Template header contains all three fields: Created, Status, Implementation Plan Doc.
**Commit:** "Add Implementation Plan Doc field to design doc template"

---

### Task 2: Update /plan to write plan link back to design doc
**Description:** Add a step in `.claude/commands/plan.md` after the "Write Implementation Plan" section instructing Claude to update the design doc's `**Implementation Plan Doc:** [link to implementation plan doc]` placeholder with the actual implementation plan path.
**Files:**
- `.claude/commands/plan.md` - modify

**Code example:**
```markdown
## Update Design Doc

After creating the implementation plan, update the design doc's header:
- Replace `[link to implementation plan doc]` with the actual path to the implementation plan (e.g., `docs/implementation-plans/YYYY-MM-DD-HHMM-feature-name.md`)
```

**Done when:** The /plan command instructions include a step to replace the placeholder in the design doc with the actual plan path.
**Commit:** "Update /plan to write plan link back to design doc"

---

### Task 3: Update /document to read plan link from design doc
**Description:** Change `.claude/commands/document.md` Step 1 to read the `Implementation Plan Doc` field from the design doc header. If the field still contains the placeholder text `[link to implementation plan doc]`, ask the user for the path to the implementation plan.
**Files:**
- `.claude/commands/document.md` - modify

**Done when:** Step 1 instructions tell Claude to read the plan path from the design doc header, with fallback to asking the user if the placeholder is still present.
**Commit:** "Update /document to read plan link from design doc"

---

## Verification Checklist

- [x] Design doc template has `**Implementation Plan Doc:** [link to implementation plan doc]` on line 5
- [x] /plan command includes step to update design doc with actual plan path
- [x] /document command reads plan path from design doc header
- [x] /document command asks user for path if placeholder text is still present

---

## Notes

- Existing design docs will not be backfilled (out of scope per design doc)
- The implementation plan template is not changed
