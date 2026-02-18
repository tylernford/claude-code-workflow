# Implementation Plan: Build Verification Checklist

**Design Doc:** docs/design-plans/2026-01-28-build-verification-checklist.md **Created:**
2026-01-28

---

## Summary

Add a verification checklist step to the `/build` phase that runs after all tasks complete
but before Phase Complete. This ensures features are verified during Build rather than
retroactively during Document.

---

## Codebase Verification

_Confirm assumptions from design doc match actual codebase_

- [x] `.claude/commands/build.md` exists - Verified: yes, 91 lines
- [x] Implementation plan template has Verification Checklist section - Verified: yes,
      lines 56-60
- [x] Build phase has Phase Complete section to update - Verified: yes, lines 62-76

**Patterns to leverage:**

- Announcement format: `**Phase 3: Build** | Task [N]/[Total]: [Task Name]`
- Pause pattern: asks user for confirmation before proceeding
- Deviation handling section structure

**Discrepancies found:**

- None

---

## Tasks

### Task 1: Add Verification Checklist Section

**Description:** Add a new "Verification Checklist" section to `build.md` between
"Handling Deviations" and "Phase Complete". This section defines the workflow for running
verification after all tasks complete.

**Files:**

- `.claude/commands/build.md` - modify (insert after line 59, before Phase Complete)

**Content to add:**

```markdown
## Verification Checklist

After all tasks are complete, run the verification checklist from the implementation plan:

1. **Prompt** - Ask user: "All tasks complete. Run verification checklist before
   completing phase?"
2. **Wait for confirmation** - User must confirm to proceed
3. **For each checklist item:**
   - Present the item
   - Verify with user (pass/fail)
   - If pass: Mark `[x]` in implementation plan
   - If fail: Fix the issue, log deviation in Build Log, re-verify
4. **All items must pass** before proceeding to Phase Complete

---
```

**Done when:** New section exists between "Handling Deviations" and "Phase Complete" with
the 4-step workflow

**Commit:** "Add verification checklist section to build phase"

---

### Task 2: Update Phase Complete for Verification

**Description:** Update the Phase Complete section to require verification and include
confirmation message in the announcement.

**Files:**

- `.claude/commands/build.md` - modify

**Changes:**

1. Update intro text: "When all tasks are done" → "When all tasks are done and
   verification checklist passes"
2. Add "Verification checklist passed." line to announcement block

**Done when:**

- Phase Complete intro references verification requirement
- Announcement includes "Verification checklist passed." line

**Commit:** "Update build phase complete to require verification"

---

## Verification Checklist

- [x] After completing all tasks, `/build` prompts to run verification
- [x] Verification workflow requires user confirmation before starting
- [x] Each checklist item can be verified pass/fail with user
- [x] Failed items require fix → log → re-verify before continuing
- [x] Phase Complete only announces after verification passes
- [x] Phase Complete message includes "Verification checklist passed."

---

## Notes

- The verification section is intentionally placed after "Handling Deviations" since
  deviations discovered during verification should follow the same logging pattern.
- No changes to the implementation plan template are needed (out of scope per design doc).
