# Add Time to Filename Dates

**Created:** 2026-01-28
**Status:** Complete

---

## Overview

**What:** Add HHMM time component to design doc and implementation plan filenames.

**Why:** Multiple documents created on the same date currently sort alphabetically by feature name rather than chronologically by creation time.

**Type:** Enhancement

---

## Requirements

### Must Have
- [ ] Update design doc filename format to include HHMM time
- [ ] Update implementation plan filename format to include HHMM time

### Nice to Have
- None

### Out of Scope
- Renaming existing docs in `docs/design-plans/` and `docs/implementation-plans/`
- Changes to `build.md` or `document.md` commands
- Any other files that reference the naming convention

---

## Design Decisions

### Time Format
**Options considered:**
1. `HHMM` (e.g., `1430`) - Compact, clean, no extra separators
2. `HH-MM` (e.g., `14-30`) - More readable but adds hyphens
3. `HHhMM` (e.g., `14h30`) - Clear time indicator but unconventional
4. `HHMMSS` (e.g., `143022`) - Precise but overkill

**Decision:** `HHMM` - Compact format that maintains consistent hyphen-separated pattern without adding extra separators.

### Time Placement
**Decision:** Between date and feature name: `YYYY-MM-DD-HHMM-feature-name.md`

### Time Zone
**Decision:** Local time (not UTC) for simplicity and user expectations.

---

## Acceptance Criteria

- [ ] Design docs are created with `YYYY-MM-DD-HHMM-feature-name.md` format
- [ ] Implementation plans are created with `YYYY-MM-DD-HHMM-feature-name.md` format
- [ ] Multiple docs created on the same day sort chronologically by creation time

---

## Files to Create/Modify

```
.claude/commands/design.md  # Update filename format (2 locations: lines 73, 94)
.claude/commands/plan.md    # Update filename format (2 locations: lines 75, 89)
```

---

## Build Log

*Filled in during `/build` phase*

| Date | Task | Files | Notes |
|------|------|-------|-------|
| 2026-01-28 | Task 1 | `.claude/commands/design.md`, `.claude/commands/plan.md` | Updated 4 occurrences as planned |

---

## Completion

**Completed:** 2026-01-28
**Final Status:** Complete

**Summary:** Updated filename format patterns in `.claude/commands/design.md` and `.claude/commands/plan.md` to include HHMM time between the date and feature name. All 4 occurrences updated as planned.

**Deviations from Plan:** None
