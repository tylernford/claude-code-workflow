# Explicit Workflow Rules

**Created:** 2026-01-15
**Status:** Complete

---

## Overview

**What:** Add two explicit rules to all four workflow command files to enforce core principles.

**Why:** During validation of the Claude Development Workflow, we identified that two core principles from the original design ("Slash commands only" and "One phase per session") were not explicitly stated as rules in the command files. Making these explicit ensures Claude follows them consistently.

**Type:** Enhancement

---

## Requirements

### Must Have
- [x] "Slash commands only" rule added to all four command files
- [x] "One phase per session" rule added to all four command files
- [x] Wording appropriate to each phase (e.g., `/document` is the final phase)

### Nice to Have
- [x] Consistent rule numbering across files

### Out of Scope
- Changes to workflow structure
- Changes to other rules
- Updates to templates

---

## Design Decisions

### Rule Wording
**Options considered:**
1. Identical wording across all files
2. Phase-specific wording adjustments

**Decision:** Phase-specific adjustments. The `/document` phase is the final phase, so the wording should reflect that (e.g., "The workflow cycle is complete" instead of "Next phase starts fresh").

---

## Acceptance Criteria

- [x] `.claude/commands/design.md` has both new rules
- [x] `.claude/commands/plan.md` has both new rules
- [x] `.claude/commands/build.md` has both new rules
- [x] `.claude/commands/document.md` has both new rules
- [x] Rule wording is appropriate for each phase
- [x] Existing rule numbering is preserved (new rules added at end)

---

## Files to Modify

```
.claude/commands/design.md    # Add rules 7-8
.claude/commands/plan.md      # Add rules 7-8
.claude/commands/build.md     # Add rules 8-9 (already has 7 rules)
.claude/commands/document.md  # Add rules 6-7 (already has 5 rules)
```

---

## Proposed Changes

### Rules to Add

**For design.md, plan.md:**
```markdown
7. **Slash commands only** - Phase transitions happen ONLY via explicit `/command`. Never auto-advance based on natural language like "let's start building."
8. **One phase per session** - Complete this phase, then end the session. Next phase starts fresh with docs as the handoff.
```

**For build.md:**
```markdown
8. **Slash commands only** - Phase transitions happen ONLY via explicit `/command`. Never auto-advance based on natural language like "let's move to documentation."
9. **One phase per session** - Complete this phase, then end the session. Next phase starts fresh with docs as the handoff.
```

**For document.md:**
```markdown
6. **Slash commands only** - Phase transitions happen ONLY via explicit `/command`. This is the final phase, but the rule applies if restarting the workflow.
7. **One phase per session** - Complete this phase, then end the session. The workflow cycle is complete.
```

---

## Build Log

*Filled in during `/build` phase*

| Date | Task | Files | Notes |
|------|------|-------|-------|
| 2026-01-15 | Task 1 | design.md, plan.md, build.md, document.md | Added rules 7-8 (design/plan), 8-9 (build), 6-7 (document) |

---

## Completion

**Completed:** 2026-01-15
**Final Status:** Complete

**Summary:** Added "Slash commands only" and "One phase per session" rules to all four workflow command files (design.md, plan.md, build.md, document.md) with phase-appropriate wording.

**Deviations from Plan:** None. Implementation matched the design exactly.
