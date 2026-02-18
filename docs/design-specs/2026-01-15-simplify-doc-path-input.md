# Simplify Doc Path Input for /plan and /build

**Created:** 2026-01-15 **Status:** Complete

---

## Overview

**What:** Change `/plan` and `/build` commands to ask for document paths instead of
searching directories and listing files.

**Why:** Reduces token waste. Users typically know which document they want to work with,
so searching directories and presenting a list is unnecessary overhead.

**Type:** Enhancement

---

## Requirements

### Must Have

- [ ] `/plan` asks for design doc path if not provided (no directory search)
- [ ] `/build` asks for implementation plan path if not provided (no directory search)
- [ ] `/build` asks for design doc path if not provided (no "locate" logic)
- [ ] Directory paths remain mentioned as guidance for users

### Nice to Have

- None

### Out of Scope

- Adding explicit `$ARGUMENTS` syntax (already works implicitly)
- Changes to `/design` or `/document` commands
- Any other logic changes in `/plan` or `/build`

---

## Design Decisions

### How to acquire document paths

**Options considered:**

1. Search directory, list files, ask user to pick - Current approach, wastes tokens
2. Ask user for path if not provided - Matches `/document`, simple and efficient

**Decision:** Option 2. Match `/document`'s approach: _"If the user does not provide a
[doc] path, ask them for the file path."_ This is simpler, saves tokens, and users already
know what documents they're working with.

---

## Acceptance Criteria

- [ ] `/plan` invoked without a path prompts: ask for design doc path (no directory
      listing)
- [ ] `/build` invoked without paths prompts: ask for implementation plan and design doc
      paths (no directory listing)
- [ ] Both commands still reference expected directories as guidance
- [ ] Wording style matches `/document`

---

## Files to Create/Modify

```
.claude/commands/plan.md   # Update Prerequisite section
.claude/commands/build.md  # Update Prerequisite section
```

---

## Build Log

_Filled in during `/build` phase_

| Date       | Task   | Files                                               | Notes                                                  |
| ---------- | ------ | --------------------------------------------------- | ------------------------------------------------------ |
| 2026-01-15 | Task 1 | .claude/commands/plan.md, .claude/commands/build.md | Updated Prerequisite sections to ask-for-path approach |

---

## Completion

**Completed:** 2026-01-15 **Final Status:** Complete

**Summary:** Updated `/plan` and `/build` commands to ask users for document paths instead
of searching directories and listing files. Both commands now match the existing
`/document` pattern, reducing token usage when users already know which document they want
to work with.

**Deviations from Plan:** None. Implementation matched the original design exactly.
