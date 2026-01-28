# Implementation Plan: Add Time to Filename Dates

**Design Doc:** `docs/design-plans/2026-01-28-1129-add-time-to-filename-dates.md`
**Created:** 2026-01-28

---

## Summary

Add HHMM time component to design doc and implementation plan filename formats, changing from `YYYY-MM-DD-feature-name.md` to `YYYY-MM-DD-HHMM-feature-name.md`.

---

## Codebase Verification

- [x] `design.md` line 73 contains `YYYY-MM-DD-feature-name.md` - Verified: yes
- [x] `design.md` line 94 contains `YYYY-MM-DD-feature-name.md` - Verified: yes
- [x] `plan.md` line 75 contains `YYYY-MM-DD-feature-name.md` - Verified: yes
- [x] `plan.md` line 89 contains `YYYY-MM-DD-feature-name.md` - Verified: yes

**Patterns to leverage:**
- None needed - simple string replacement

**Discrepancies found:**
- None - design doc accurately reflects codebase

---

## Tasks

### Task 1: Add HHMM time component to filename formats

**Description:** Update filename format patterns in both command files to include HHMM time between the date and feature name.

**Files:**
- `.claude/commands/design.md` - modify (lines 73, 94)
- `.claude/commands/plan.md` - modify (lines 75, 89)

**Changes:**

| File | Line | Before | After |
|------|------|--------|-------|
| `design.md` | 73 | `YYYY-MM-DD-feature-name.md` | `YYYY-MM-DD-HHMM-feature-name.md` |
| `design.md` | 94 | `YYYY-MM-DD-feature-name.md` | `YYYY-MM-DD-HHMM-feature-name.md` |
| `plan.md` | 75 | `YYYY-MM-DD-feature-name.md` | `YYYY-MM-DD-HHMM-feature-name.md` |
| `plan.md` | 89 | `YYYY-MM-DD-feature-name.md` | `YYYY-MM-DD-HHMM-feature-name.md` |

**Done when:**
- All 4 occurrences updated
- `grep -r "YYYY-MM-DD-feature-name.md" .claude/commands/` returns no results
- `grep -r "YYYY-MM-DD-HHMM-feature-name.md" .claude/commands/` returns 4 matches

**Commit:** "Add HHMM time to design and implementation plan filenames"

---

## Verification Checklist

- [ ] Grep confirms no instances of old format in `.claude/commands/`
- [ ] Grep confirms 4 instances of new format in `.claude/commands/`
- [ ] `build.md` and `document.md` remain unchanged (out of scope)

---

## Notes

- Existing docs in `docs/design-plans/` and `docs/implementation-plans/` are intentionally not renamed
- This is a documentation-only change; no code logic is affected
