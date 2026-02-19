# Complete Phase Decoupling

**Created:** 2026-02-18 **Implementation Plan:**
docs/implementation-plans/2026-02-18-1855-complete-phase-decoupling.md

---

## Overview

**What:** Fully decouple `/document` from the design spec and update `/plan` to carry Type
and Overview into the implementation plan, so downstream phases never need to read the
design spec.

**Why:** The previous decoupling iteration (2026-02-18-1317) achieved the core goal — the
design spec is never written to after `/plan` — but `/document` still reads the design
spec for PR draft generation. This creates an implicit dependency that contradicts the
"design spec freezes after /plan" principle. Completing the decoupling makes the
implementation plan the single source of truth for all post-design phases.

**Type:** Refactor

---

## Requirements

### Must Have

- [ ] `/plan` confirms Type and Overview with the user (sourced from design spec) and
      writes them into the implementation plan header
- [ ] `/plan` writes the design spec path into the implementation plan at write time (no
      separate update step)
- [ ] `/document` generates the PR draft entirely from the implementation plan
- [ ] `/document` never reads the design spec file
- [ ] PR draft "Changes" section uses Build Log (actual files) instead of the design
      spec's file list
- [ ] Changelog entry still includes both design spec and implementation plan paths (read
      from implementation plan header fields)
- [ ] Design spec template renames "Files to Create/Modify" to "Suggested Files to
      Create/Modify"

### Nice to Have

- [ ] Implementation plan header field order: Created, Design Spec, Type, Overview

### Out of Scope

- Changes to `/design` command
- Changes to `/build` command
- Moving "Suggested Files to Create/Modify" content into the implementation plan
- Folder-as-status system for design specs and implementation plans

---

## Design Decisions

### Source PR draft content from implementation plan instead of design spec

**Options considered:**

1. Keep read-only dependency on design spec — simpler, no template changes, but
   `/document` still opens the design spec file
2. Move Type and Overview into the implementation plan — `/plan` confirms values with user
   and writes them to the impl plan header, `/document` never touches the design spec

**Decision:** Option 2. The whole point of the previous iteration was to make the design
spec freeze after `/plan`. A read-only dependency is still a dependency — if the design
spec is missing or moved, `/document` breaks. Having `/plan` carry the relevant values
forward makes the implementation plan fully self-contained for downstream phases.

### Drop "Files to Create/Modify" from PR draft

**Options considered:**

1. Copy the file list into the implementation plan for the PR draft
2. Use the Build Log's actual file list instead
3. Drop the file list from the PR draft entirely

**Decision:** Option 2. The design spec's file list is speculative — written before any
code. The Build Log captures what actually changed. The PR draft should reflect reality,
not predictions. The Build Log is already in the implementation plan, so no new data
needed.

### Rename design spec section to "Suggested Files to Create/Modify"

**Options considered:**

1. Keep "Files to Create/Modify" — it's understood as a proposal in context
2. Rename to "Suggested Files to Create/Modify" — signals intent more clearly to `/plan`

**Decision:** Option 2. The rename reinforces that the list is a starting point for
`/plan` to verify against the codebase, not a mandate. Low-cost change with clarity
benefits.

---

## Acceptance Criteria

- [ ] `/plan` has a Step 5 that confirms Type and Overview with the user
- [ ] Implementation plan template header includes Type and Overview fields in order:
      Created, Design Spec, Type, Overview
- [ ] `/plan` writes the design spec path into the implementation plan when writing the
      file (no separate "Update Implementation Plan" step)
- [ ] `/document` prerequisite does not read or reference the design spec file
- [ ] `/document` PR draft title prefix comes from implementation plan's Type field
- [ ] `/document` PR draft summary comes from implementation plan's Overview field
- [ ] `/document` PR draft changes come from implementation plan's Build Log
- [ ] Changelog entry includes design spec path (read from implementation plan header, not
      from the design spec file itself)
- [ ] Design spec template section reads "Suggested Files to Create/Modify"

---

## Suggested Files to Create/Modify

```
docs/templates/implementation-plan.md   # add Type and Overview to header, reorder fields
docs/templates/design-spec.md           # rename Files to Create/Modify section
.claude/commands/plan.md                # add Step 5, remove redundant update step
.claude/commands/document.md            # remove design spec dependency, update PR draft
```
