# Implementation Plan: Add Timestamp Verification Instructions

**Design Doc:** docs/design-plans/2026-02-03-2059-add-timestamp-verification-instructions.md
**Created:** 2026-02-03

---

## Summary

Add explicit instructions to the `/design` and `/plan` commands for obtaining the current timestamp before creating design or implementation plan documents.

---

## Codebase Verification

*Confirmed during planning phase*

- [x] `design.md` has Step 5 with file path template - Verified: yes
- [x] `plan.md` has Write Implementation Plan section with file path template - Verified: yes
- [x] Both files exist at `.claude/commands/` - Verified: yes

**Patterns to leverage:**
- None needed - simple text insertion

**Discrepancies found:**
- None - design doc accurately reflects codebase

---

## Tasks

### Task 1: Add timestamp verification instructions to command files

**Description:** Add the instruction "Before creating the file, run `date +%Y-%m-%d-%H%M` to get the current timestamp." to both `/design` and `/plan` command files, immediately before their file path templates.

**Files:**
- `.claude/commands/design.md` - modify (insert before line 71)
- `.claude/commands/plan.md` - modify (insert before line 74)

**Code example:**

For `design.md` (insert before "Create the design document at:"):
```markdown
Before creating the file, run `date +%Y-%m-%d-%H%M` to get the current timestamp.

Create the design document at:
```

For `plan.md` (insert before "Create the implementation plan at:"):
```markdown
Before creating the file, run `date +%Y-%m-%d-%H%M` to get the current timestamp.

Create the implementation plan at:
```

**Done when:**
- Both files contain the timestamp instruction
- Instruction appears immediately before the file path template in each file
- No other changes made to files
- Template files remain unchanged

**Commit:** "Add timestamp verification instructions to /design and /plan commands"

---

## Verification Checklist

- [ ] `.claude/commands/design.md` contains "Before creating the file, run `date +%Y-%m-%d-%H%M` to get the current timestamp."
- [ ] Instruction in `design.md` appears immediately before "Create the design document at:"
- [ ] `.claude/commands/plan.md` contains "Before creating the file, run `date +%Y-%m-%d-%H%M` to get the current timestamp."
- [ ] Instruction in `plan.md` appears immediately before "Create the implementation plan at:"
- [ ] `docs/templates/design-doc.md` is unchanged
- [ ] `docs/templates/implementation-plan.md` is unchanged

---

## Notes

- This is a minimal change with low risk
- Both edits follow the same pattern for consistency
