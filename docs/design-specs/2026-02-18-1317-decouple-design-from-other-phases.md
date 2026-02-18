# Decouple /design from Other Phases

**Created:** 2026-02-18 **Implementation Plan:**
docs/implementation-plans/2026-02-18-1442-decouple-design-from-other-phases.md

---

## Overview

**What:** Move the Build Log and Completion section from the design spec to the
implementation plan, so that `/build` and `/document` never read or write the design spec.

**Why:** The design spec is the "what and why" — it should freeze after `/plan`. The
implementation plan is the "how" — it should own the full build story: tasks, acceptance
criteria, build log, deviations, and completion. This is a cleaner separation of concerns
and fixes a bug where acceptance criteria checkboxes weren't being marked complete during
`/document` (noted 2026-01-16).

**Type:** Refactor

---

## Requirements

### Must Have

- [ ] Design spec template has no Build Log or Completion section
- [ ] Implementation plan template has Build Log and Completion sections
- [ ] `/build` only requires the implementation plan path (no design spec)
- [ ] `/build` writes Build Log entries to the implementation plan
- [ ] `/document` entry point is the implementation plan (not the design spec)
- [ ] `/document` fills in Completion section in the implementation plan
- [ ] `/document` marks acceptance criteria checkboxes as complete in the implementation
      plan
- [ ] `/document` reads design spec path from the implementation plan for the changelog
      entry
- [ ] Changelog entries still reference both the design spec and implementation plan

### Nice to Have

- [ ] Remove Status field from design spec template (no phase updates it after `/plan`)

### Out of Scope

- Folder-as-status system for design specs and implementation plans (backlogged
  separately)
- Changes to `/design` command
- Changes to `/plan` command behavior (it already reads design spec → produces
  implementation plan)

---

## Design Decisions

### Design spec lifecycle

**Options considered:**

1. Design spec gets lightweight final update (Status → Complete) during `/document`
2. Design spec freezes entirely after `/plan`

**Decision:** Option 2. Freezing the design spec preserves it as a clean record of
original intent. This supports comparing design specs against implementation plans to see
how much planning and building diverged from the original design. If `/document` updated
the design spec with "what actually happened," that comparison becomes less interesting.

### Where the Completion section lives

**Options considered:**

1. Keep Completion in design spec, move only Build Log
2. Move both Build Log and Completion to implementation plan

**Decision:** Option 2. The implementation plan already has the build log and deviations —
the completion summary belongs with them. The changelog serves as the "this shipped"
record. The design spec doesn't need its own closure.

### Cross-references between documents

**Options considered:**

1. Switch to filename-only references (future-proofs against folder moves)
2. Keep full file paths

**Decision:** Option 2. No folder restructuring is happening in this change. Full paths
are more convenient (clickable in editors). If folder-as-status is implemented later,
references can be updated then.

---

## Acceptance Criteria

- [ ] `/build` can be run with only an implementation plan path — no design spec path
      requested
- [ ] Build Log entries are written to the implementation plan during `/build`
- [ ] `/document` can be run with only an implementation plan path as entry point
- [ ] `/document` marks acceptance criteria checkboxes `[x]` in the implementation plan
- [ ] `/document` fills in the Completion section in the implementation plan
- [ ] Changelog entry includes both design spec and implementation plan paths
- [ ] Design spec template contains no Build Log or Completion section
- [ ] Implementation plan template contains Build Log and Completion sections

---

## Files to Create/Modify

```
docs/templates/design-spec.md          # Remove Build Log, Completion, Status field
docs/templates/implementation-plan.md  # Add Build Log, Completion section (before Notes)
.claude/commands/build.md              # Remove design spec dependency, update Build Log refs
.claude/commands/document.md           # Entry point → implementation plan, fill Completion there
docs/backlog.md                        # Add folder-as-status idea, remove "Move Build Log" entry
```
