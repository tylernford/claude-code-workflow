# Implementation Plan: Add PR Draft to Document Phase

**Design Doc:** docs/design-plans/2026-01-28-add-pr-draft-to-document-phase.md
**Created:** 2026-01-28

---

## Summary

Add a PR draft (title and description) to the `/document` Phase Complete section. The
draft will be generated from the design doc, implementation plan, and build log, giving
users copy/paste-ready content for PR creation.

---

## Codebase Verification

- [x] Phase Complete section exists in document.md - Verified: yes (lines 87-102)
- [x] Clear insertion point (after commit checkpoint, before "Feature complete!") -
      Verified: yes
- [x] Design doc has Type field for commit prefix mapping - Verified: yes
- [x] Implementation plan template has Summary section - Verified: yes

**Patterns to leverage:**

- Phase Complete uses markdown code block for output template
- Conditional output patterns exist (e.g., "README: [updated | no changes needed]")

**Discrepancies found:**

- None

---

## Tasks

### Task 1: Add PR Draft to Phase Complete Section

**Description:** Add PR draft generation instructions and output template to the
`/document` command. The PR draft appears after the commit checkpoint, before "Feature
complete!"

**Files:**

- `.claude/commands/document.md` - modify

**Changes:**

1. Add a new subsection (before Phase Complete or inline) with PR draft generation
   instructions:
   - Map design doc `Type` to conventional commit prefix:
     - `Enhancement` → `feat:`
     - `Bug Fix` → `fix:`
     - `Refactor` → `refactor:`
     - `Documentation` → `docs:`
     - `Chore` → `chore:`
   - Extract feature name from design doc title
   - Extract summary from design doc Overview (2-3 sentences)
   - List key changes from design doc's Files to Create/Modify section
   - Include documentation links (design doc and implementation plan paths)

2. Update Phase Complete template to include PR draft output block:

```
**Commit checkpoint:** Commit the documentation updates before ending this session.

---

**PR Draft** (copy/paste when creating PR):

**Title:** [type-prefix]: [feature name]

**Description:**
## Summary
[2-3 sentences from design doc Overview]

## Changes
- [key files/areas changed from Files to Create/Modify]

## Documentation
- Design: [path to design doc]
- Plan: [path to implementation plan]

---

Feature complete! The workflow cycle is finished.
```

**Done when:**

- Running `/document` on a completed feature displays a PR draft in Phase Complete
- PR title uses correct conventional commit prefix based on design doc Type
- PR description includes summary, changes, and documentation links
- Existing Steps 1-5 remain unchanged

**Commit:** "feat: add PR draft to document phase"

---

## Verification Checklist

- [x] PR draft appears in Phase Complete output (after commit checkpoint, before "Feature
      complete!")
- [x] PR title prefix correctly maps from design doc Type field
- [x] PR description Summary section contains 2-3 sentences from Overview
- [x] PR description Changes section lists files/areas from Files to Create/Modify
- [x] PR description Documentation section links to design doc and implementation plan
- [x] Steps 1-5 of document.md are unchanged
- [x] PR draft is displayed only, not written to a file

---

## Notes

- The Type → prefix mapping covers common cases. If a design doc has an unlisted Type,
  Claude should use best judgment or default to `feat:`.
- The PR draft is intentionally minimal — users can expand it when creating the actual PR.
