# Implementation Plan: Acceptance Criteria Restructure

**Design Doc:** docs/design-plans/2026-02-04-0917-acceptance-criteria-restructure.md
**Created:** 2026-02-04

---

## Summary

Restructure the `/build` command so acceptance criteria are embedded in the Workflow section as a mandatory gate between task completion and Phase Complete. Rename "Verification Checklist" to "Acceptance Criteria" throughout.

---

## Codebase Verification

*Confirm assumptions from design doc match actual codebase*

- [x] `build.md` has standalone "## Verification Checklist" section - Verified: yes (lines 60-72)
- [x] 4-step ritual exists in current Verification Checklist - Verified: yes (lines 66-71)
- [x] Phase Complete says "Verification checklist passed" - Verified: yes (line 78)
- [x] Workflow has "### For Each Task:" structure - Verified: yes (lines 32-41)
- [x] `implementation-plan.md` has "## Verification Checklist" header - Verified: yes (line 56)

**Patterns to leverage:**
- Workflow already uses `### For Each Task:` — add parallel `### After All Tasks: Acceptance Criteria`

**Discrepancies found:**
- None. Codebase matches design assumptions exactly.

---

## Tasks

### Task 1: Restructure `/build` Workflow with Acceptance Criteria

**Description:** Move acceptance criteria into the Workflow section and clean up `build.md`

**Files:**
- `.claude/commands/build.md` - modify

**Changes:**
1. Add `### After All Tasks: Acceptance Criteria` subsection after "For Each Task" (inside Workflow)
2. Move the 4-step ritual content into this new subsection
3. Delete the standalone `## Verification Checklist` section (and its preceding `---`)
4. Update Phase Complete: "Verification checklist passed" → "Acceptance criteria passed"

**Done when:**
- Workflow section contains both "For Each Task" and "After All Tasks: Acceptance Criteria" subsections
- No standalone "## Verification Checklist" section exists
- Phase Complete references "Acceptance criteria passed"

**Commit:** "Restructure /build to embed acceptance criteria in Workflow"

---

### Task 2: Rename template section header

**Description:** Update the implementation plan template to use "Acceptance Criteria" naming

**Files:**
- `docs/templates/implementation-plan.md` - modify

**Changes:**
1. Rename `## Verification Checklist` to `## Acceptance Criteria`

**Done when:**
- Template has `## Acceptance Criteria` header instead of `## Verification Checklist`

**Commit:** "Rename Verification Checklist to Acceptance Criteria in template"

---

## Acceptance Criteria

- [x] `/build` Workflow section contains "After All Tasks: Acceptance Criteria" subsection
- [x] The 4-step ritual (present, verify, mark, fix-if-fail) is preserved in the new location
- [x] Standalone "Verification Checklist" section is removed from `/build`
- [x] Phase Complete says "Acceptance criteria passed" (not "Verification checklist passed")
- [x] Implementation plan template header renamed to "## Acceptance Criteria"

---

## Notes

- Tasks are independent but logical order is Task 1 → Task 2
- This implementation plan uses the new "Acceptance Criteria" naming (eating our own dogfood)
