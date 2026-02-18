# Implementation Plan: Explicit Workflow Rules

**Design Doc:** docs/design-plans/2026-01-15-explicit-workflow-rules.md **Created:**
2026-01-15

---

## Summary

Add two explicit rules ("Slash commands only" and "One phase per session") to all four
workflow command files to enforce core workflow principles.

---

## Codebase Verification

_Confirmed assumptions from design doc match actual codebase_

- [x] `design.md` has 6 rules - Verified: yes
- [x] `plan.md` has 6 rules - Verified: yes
- [x] `build.md` has 7 rules - Verified: yes
- [x] `document.md` has 5 rules - Verified: yes

**Patterns to leverage:**

- Existing rule format: numbered list with bold headers (e.g.,
  `1. **Rule name** - Description`)

**Discrepancies found:**

- None

---

## Tasks

### Task 1: Add Explicit Workflow Rules to All Command Files

**Description:** Add the "Slash commands only" and "One phase per session" rules to all
four workflow command files with phase-appropriate wording.

**Files:**

- `.claude/commands/design.md` - modify (add rules 7-8)
- `.claude/commands/plan.md` - modify (add rules 7-8)
- `.claude/commands/build.md` - modify (add rules 8-9)
- `.claude/commands/document.md` - modify (add rules 6-7)

**Code to add:**

For `design.md` and `plan.md` (append after existing rules):

```markdown
7. **Slash commands only** - Phase transitions happen ONLY via explicit `/command`. Never
   auto-advance based on natural language like "let's start building."
8. **One phase per session** - Complete this phase, then end the session. Next phase
   starts fresh with docs as the handoff.
```

For `build.md` (append after existing rules):

```markdown
8. **Slash commands only** - Phase transitions happen ONLY via explicit `/command`. Never
   auto-advance based on natural language like "let's move to documentation."
9. **One phase per session** - Complete this phase, then end the session. Next phase
   starts fresh with docs as the handoff.
```

For `document.md` (append after existing rules):

```markdown
6. **Slash commands only** - Phase transitions happen ONLY via explicit `/command`. This
   is the final phase, but the rule applies if restarting the workflow.
7. **One phase per session** - Complete this phase, then end the session. The workflow
   cycle is complete.
```

**Done when:**

- Each of the 4 command files contains both new rules
- Rule numbering is sequential (no gaps, no duplicates)
- Wording matches the phase context (document.md has unique final-phase wording)

**Commit:** "Add explicit workflow rules to command files"

---

## Verification Checklist

- [x] `design.md` has rules 1-8, with rules 7-8 being the new rules
- [x] `plan.md` has rules 1-8, with rules 7-8 being the new rules
- [x] `build.md` has rules 1-9, with rules 8-9 being the new rules
- [x] `document.md` has rules 1-7, with rules 6-7 being the new rules
- [x] All "Slash commands only" rules mention `/command` syntax
- [x] All "One phase per session" rules mention ending the session
- [x] `document.md` wording reflects it's the final phase

---

## Notes

This is a small, focused change. Single task is appropriate because all edits are part of
one coherent change and make sense as one commit.
