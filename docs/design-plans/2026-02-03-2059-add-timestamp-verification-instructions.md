# Add Timestamp Verification Instructions

**Created:** 2026-02-03
**Status:** Design
**Implementation Plan Doc:** docs/implementation-plans/2026-02-03-2104-add-timestamp-verification-instructions.md

---

## Overview

**What:** Add explicit instructions for obtaining the current timestamp when creating design and implementation plan documents.

**Why:** The `/design` and `/plan` commands specify filenames with `YYYY-MM-DD-HHMM` format but don't explain how to get the accurate timestamp, leaving Claude (or users) without clear guidance.

**Type:** Enhancement

---

## Requirements

### Must Have
- [ ] `/design` command includes instruction to run `date +%Y-%m-%d-%H%M` before creating the design doc
- [ ] `/plan` command includes instruction to run `date +%Y-%m-%d-%H%M` before creating the implementation plan

### Nice to Have
- None

### Out of Scope
- Modifying templates (`design-doc.md`, `implementation-plan.md`)
- Changing the `**Created:** YYYY-MM-DD` header format (stays date-only)
- Retroactively renaming existing docs
- Adding time to the `Created` field in document headers

---

## Design Decisions

### Instruction Placement
**Options considered:**
1. Add at the top of the command file as a general note - less discoverable, separate from where action happens
2. Add in Step 5 / Write Implementation Plan section, right before the file path template - explicit and contextual

**Decision:** Option 2. Place the instruction immediately before the "Create the [document] at:" line so it's seen exactly when needed.

### Instruction Wording
**Options considered:**
1. Brief: "Run `date +%Y-%m-%d-%H%M` to get the current timestamp"
2. Explicit: "Before creating the file, run `date +%Y-%m-%d-%H%M` to get the current timestamp."

**Decision:** Option 2. More explicit wording makes it clear this is a prerequisite step, not just a hint.

### Timestamp Method
**Options considered:**
1. Bash command `date +%Y-%m-%d-%H%M` - simple, reliable, available everywhere
2. Reference environment info - only provides date, not time

**Decision:** Bash command. It provides the complete timestamp in one command.

---

## Acceptance Criteria

- [ ] `.claude/commands/design.md` Step 5 includes: "Before creating the file, run `date +%Y-%m-%d-%H%M` to get the current timestamp."
- [ ] `.claude/commands/plan.md` Write Implementation Plan section includes the same instruction
- [ ] Instruction appears immediately before the file path template in both files
- [ ] No changes to template files

---

## Files to Create/Modify

```
.claude/commands/design.md  # Add timestamp instruction to Step 5
.claude/commands/plan.md    # Add timestamp instruction to Write Implementation Plan section
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
