# Implementation Plan: Decouple /design from Other Phases

**Design Spec:** docs/design-specs/2026-02-18-1317-decouple-design-from-other-phases.md
**Created:** 2026-02-18

---

## Summary

Move Build Log and Completion sections from the design spec template to the implementation
plan template, then update `/build` and `/document` commands so they never read or write
the design spec. The design spec freezes after `/plan`; the implementation plan owns the
full build story.

---

## Codebase Verification

_Confirm assumptions from design spec match actual codebase_

- [x] Design spec template has Build Log section (line 65) - Verified: yes
- [x] Design spec template has Completion section (line 75) - Verified: yes
- [x] Design spec template has Status field (line 2) - Verified: yes
- [x] Implementation plan template has neither Build Log nor Completion - Verified: yes
- [x] `/build` asks for design spec path (line 18) - Verified: yes
- [x] `/build` writes Build Log to design spec (lines 40, 63) - Verified: yes
- [x] `/document` entry point is design spec (line 18) - Verified: yes
- [x] `/document` reads impl plan path from design spec header (line 20) - Verified: yes
- [x] `/document` fills Completion in design spec (Step 2) - Verified: yes
- [x] Backlog has "Move Build Log" entry (line 94) - Verified: yes

**Patterns to leverage:**

- None — this is a refactor of existing templates and command prompts

**Discrepancies found:**

- None — all assumptions match

---

## Tasks

### Task 1: Update Templates

**Description:** Remove Build Log, Completion section, and Status field from the design
spec template. Add Build Log and Completion sections to the implementation plan template
(before Notes). Add a `**Design Spec:**` field to the implementation plan header so
`/document` can locate the design spec for changelog entries.

**Files:**

- `docs/templates/design-spec.md` - modify
- `docs/templates/implementation-plan.md` - modify

**Done when:**

- Design spec template has no Build Log, Completion, or Status field
- Implementation plan template has Build Log and Completion sections (before Notes)
- Implementation plan template header includes `**Design Spec:**` field

**Commit:** "Move Build Log and Completion from design spec to implementation plan
template"

---

### Task 2: Update /build Command

**Description:** Remove the design spec dependency — `/build` no longer asks for or
requires a design spec path. Update all references so Build Log entries are written to the
implementation plan instead of the design spec. Update the "Phase Complete" announcement
to reference the implementation plan for the Build Log location.

**Files:**

- `.claude/commands/build.md` - modify

**Done when:**

- `/build` only requires an implementation plan path (no design spec mention in
  Prerequisite)
- All Build Log references point to the implementation plan
- "Phase Complete" announcement references implementation plan for Build Log
- No remaining references to design spec

**Commit:** "Update /build to use implementation plan only"

---

### Task 3: Update /document Command

**Description:** Change the entry point from design spec to implementation plan.
`/document` now asks for the implementation plan path (not design spec). It reads the
design spec path from the implementation plan's `**Design Spec:**` header field. Move
Completion fill-in from design spec to implementation plan. Mark acceptance criteria
checkboxes in the implementation plan. Remove "Complete Design Spec" step entirely —
design spec freezes after `/plan`. Update changelog step to read both paths from the
implementation plan. Update PR draft generation and Phase Complete announcement
accordingly.

**Files:**

- `.claude/commands/document.md` - modify

**Done when:**

- `/document` asks for implementation plan path (not design spec)
- Design spec path is read from implementation plan's `**Design Spec:**` header
- Completion section is filled in the implementation plan
- Acceptance criteria are marked `[x]` in the implementation plan
- Changelog entry still references both design spec and implementation plan
- Design spec is never written to
- PR draft sources Overview from design spec (read-only)

**Commit:** "Update /document to use implementation plan as entry point"

---

### Task 4: Update Backlog

**Description:** Remove the "Move Build Log to Implementation Plan" entry (lines 94-119)
since this feature implements it. Add a new backlog entry for "Folder-as-status system for
design specs and implementation plans" (referenced as out of scope in the design spec).

**Files:**

- `docs/backlog.md` - modify

**Done when:**

- "Move Build Log to Implementation Plan" entry is removed
- New "Folder-as-status system" entry is added
- Existing backlog entries are unchanged

**Commit:** "Update backlog: remove completed item, add folder-as-status idea"

---

## Acceptance Criteria

- [x] `/build` can be run with only an implementation plan path — no design spec path
      requested
- [x] Build Log entries are written to the implementation plan during `/build`
- [x] `/document` can be run with only an implementation plan path as entry point
- [x] `/document` marks acceptance criteria checkboxes `[x]` in the implementation plan
- [x] `/document` fills in the Completion section in the implementation plan
- [x] Changelog entry includes both design spec and implementation plan paths
- [x] Design spec template contains no Build Log or Completion section
- [x] Implementation plan template contains Build Log and Completion sections

---

## Build Log

_Filled in during `/build` phase_

| Date       | Task   | Files                                                                | Notes                                                                                                                                                                                                                                                                                                                                                                                        |
| ---------- | ------ | -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-02-18 | Task 1 | docs/templates/design-spec.md, docs/templates/implementation-plan.md | Design Spec field already existed in impl plan template header                                                                                                                                                                                                                                                                                                                               |
| 2026-02-18 | Task 2 | .claude/commands/build.md                                            | Removed design spec prerequisite, updated 4 references to point to implementation plan                                                                                                                                                                                                                                                                                                       |
| 2026-02-18 | Task 3 | .claude/commands/document.md                                         | Reversed entry point, moved Completion/acceptance to impl plan, design spec now read-only. Deviation: design/plan phases missed that /document still reads the design spec for PR draft content (Overview, Type, Files to Create/Modify). This was not addressed — needs a future iteration to decide whether to move that info to the implementation plan or keep the read-only dependency. |
| 2026-02-18 | Task 4 | docs/backlog.md                                                      | Removed completed "Move Build Log" entry, added "Folder-as-status system" entry                                                                                                                                                                                                                                                                                                              |

---

## Completion

**Completed:** [Date] **Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]

---

## Notes

- The design spec template's `**Implementation Plan:**` field is unchanged — `/plan` still
  populates it. This is the only write to the design spec after `/design`.
- The implementation plan template now has a `**Design Spec:**` field that `/plan` should
  populate. Since `/plan` is out of scope for changes, this field will need to be filled
  manually (or `/plan` can be updated in a future iteration).
