# Fix Document Path Asking in /plan and /build

**Created:** 2026-02-03
**Status:** Design
**Implementation Plan Doc:** [link to implementation plan doc]

---

## Overview

**What:** Update `/plan` and `/build` commands to reliably ask for document paths when not provided, matching `/document`'s behavior.

**Why:** Currently, `/plan` and `/build` search directories instead of asking for paths. This wastes tokens and doesn't match the intended behavior from the 2026-01-15 "Simplify Doc Path Input" feature.

**Type:** Bug Fix

---

## Requirements

### Must Have
- [ ] `/plan` asks for design doc path when not provided via arguments
- [ ] `/build` asks for implementation plan and design doc paths when not provided via arguments
- [ ] Both commands wait for user response before proceeding

### Nice to Have
- None

### Out of Scope
- Changes to `/design` command
- Changes to `/document` command (already works correctly)
- Adding `$ARGUMENTS` syntax (already works implicitly)

---

## Design Decisions

### Why Claude searches instead of asking
**Root cause:** The Prerequisite sections contain lines like:
- "A design document must exist in `docs/design-plans/`."
- "An implementation plan must exist in `docs/implementation-plans/`."

These directory references prompt Claude to search those locations rather than ask the user.

**Evidence:** `/document` works correctly because its Prerequisite says only "If the user does not provide a design doc path, ask them for the file path." — no directory mentioned.

### Fix approach
**Options considered:**
1. Add stronger "DO NOT search" language — Still relies on Claude following soft instructions
2. Add a dedicated "Step 0" for path acquisition — Adds complexity, changes step numbering
3. Remove directory references from Prerequisite — Matches `/document`'s working pattern, minimal change

**Decision:** Option 3. Remove directory path references and simplify Prerequisite to match `/document`'s minimal pattern. This eliminates the trigger that causes Claude to search.

---

## Acceptance Criteria

- [ ] Running `/plan` without arguments asks "Please provide the path to the design document:" (or similar)
- [ ] Running `/build` without arguments asks for both implementation plan and design doc paths
- [ ] Neither command searches `docs/design-plans/` or `docs/implementation-plans/` when no path is provided
- [ ] Providing paths via arguments (e.g., `/plan docs/design-plans/...`) still works

---

## Files to Create/Modify

```
.claude/commands/plan.md   # Simplify Prerequisite section
.claude/commands/build.md  # Simplify Prerequisite section
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
