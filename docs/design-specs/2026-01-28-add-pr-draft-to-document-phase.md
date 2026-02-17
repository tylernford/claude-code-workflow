# Add PR Draft to Document Phase

**Created:** 2026-01-28
**Status:** Complete

---

## Overview

**What:** Add a PR draft (title and description) to the `/document` Phase Complete section.

**Why:** PR creation is a natural part of wrapping up a feature, but it currently happens outside the workflow. This leads to inconsistent PR structure or extra manual steps after the workflow ends.

**Type:** Enhancement

---

## Requirements

### Must Have
- [ ] PR draft appears in Phase Complete section (after commit checkpoint, before "Feature complete!")
- [ ] PR title uses conventional commit format (`feat:`, `fix:`, etc.) based on feature type
- [ ] PR description includes: summary, key changes, documentation links
- [ ] Content generated from design doc, implementation plan, and build log
- [ ] Output displayed in CLI only (not written to file)

### Nice to Have
- [ ] Changes section groups files by area when many files changed

### Out of Scope
- Running `gh pr create` or any git commands
- Writing PR draft to a file
- Branch target recommendations
- Making this a separate Step 6

---

## Design Decisions

### Where to place PR draft
**Options considered:**
1. New Step 6 - Dedicated step with user interaction
2. Part of Phase Complete - Inline with completion message

**Decision:** Option 2 (Part of Phase Complete). The PR draft is generated output, not a decision point. It belongs alongside "commit your docs" as part of wrapping up, keeping the workflow streamlined.

### Content sources
**Decision:** Generate PR draft content from:
1. Design doc (primary source) - Overview, Type, Files to Create/Modify, Completion
2. Implementation plan - Technical details
3. Build log - What actually happened vs. planned

---

## Acceptance Criteria

- [ ] `/document` Phase Complete section includes a PR draft
- [ ] PR title uses conventional commit format based on feature type from design doc
- [ ] PR description includes summary (2-3 sentences from Overview)
- [ ] PR description includes key changes (from Files to Create/Modify)
- [ ] PR description includes documentation links (design doc and implementation plan)
- [ ] PR draft is displayed in CLI, not written to a file
- [ ] Existing Steps 1-5 remain unchanged

---

## Files to Create/Modify

```
.claude/commands/document.md  # Add PR draft generation instruction and update Phase Complete template
```

---

## Build Log

*Filled in during `/build` phase*

| Date | Task | Files | Notes |
|------|------|-------|-------|
| 2026-01-28 | Task 1 | .claude/commands/document.md | Added explicit PR Draft Generation section + updated Phase Complete template |

---

## Completion

**Completed:** 2026-01-28
**Final Status:** Complete

**Summary:** Added PR draft generation to the `/document` phase. The PR draft appears in Phase Complete output with a conventional commit-style title, summary from the design doc Overview, key changes from Files to Create/Modify, and links to documentation.

**Deviations from Plan:** None - implementation matched the design exactly.
