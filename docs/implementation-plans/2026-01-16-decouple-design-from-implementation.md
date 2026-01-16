# Implementation Plan: Decouple Design from Implementation Session

**Design Doc:** docs/design-plans/2026-01-16-decouple-design-from-implementation.md
**Created:** 2026-01-16

---

## Summary

Update `/design` and `/plan` prompt language to communicate that Design is standalone while Plan/Build/Document form a tightly coupled "Implementation Session."

---

## Codebase Verification

- [x] `/design` closing message text matches design doc assumption - Verified
- [x] `/plan` opening text matches design doc assumption - Verified
- [x] `/plan` Step 2 section exists for adding note - Verified

**Patterns to leverage:**
- Consistent markdown heading structure in both files
- Existing "Phase Complete" section formatting

**Discrepancies found:**
- None

---

## Tasks

### Task 1: Update `/design` closing message

**Description:** Update the Phase Complete section to reflect that Design is standalone and doesn't imply immediate progression to `/plan`.

**Files:**
- `.claude/commands/design.md` - modify

**Code example:**
```markdown
**Phase 1: Design** | Complete

Design document created at: docs/design-plans/YYYY-MM-DD-feature-name.md

**Commit checkpoint:** Commit the design document before ending this session.

Design is complete.

When ready to implement, start a new Claude Code session and run `/plan` to begin
an Implementation Session (Plan → Build → Document).
```

**Done when:** The closing message no longer says "Next: ... Run `/plan` to begin Phase 2" — instead communicates design is complete and implementation can happen whenever ready.

**Commit:** "Update /design closing to reflect standalone nature"

---

### Task 2: Update `/plan` framing and add time-gap note

**Description:** Update `/plan` opening to frame it as the start of an Implementation Session, and add a note to Step 2 about potential time gap since design was written.

**Files:**
- `.claude/commands/plan.md` - modify

**Code example (opening - line 3):**
```markdown
You are starting an **Implementation Session** — Phase 1: Plan

This session will take you through Plan → Build → Document.
```

**Code example (after Step 2 header - line 38):**
```markdown
### Step 2: Codebase Verification

**Note:** The design document may have been written days or weeks ago. The codebase may have changed since then.
```

**Done when:**
- Opening clearly states "Implementation Session"
- Step 2 includes time-gap awareness note

**Commit:** "Update /plan to frame as Implementation Session start"

---

## Verification Checklist

- [ ] `/design` closing message no longer implies immediate progression to `/plan`
- [ ] `/plan` opening clearly states "Implementation Session (Plan → Build → Document)"
- [ ] `/plan` Step 2 includes note about potential time gap since design was written
- [ ] Both files still render correctly as markdown

---

## Notes

- Tasks are independent and can be completed in either order
- Changes are text-only; no structural changes to the prompts
