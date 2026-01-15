# Implementation Plan: Simplify Doc Path Input

**Design Doc:** docs/design-plans/2026-01-15-simplify-doc-path-input.md
**Created:** 2026-01-15

---

## Summary

Update `/plan` and `/build` commands to ask for document paths instead of searching directories and listing files. Matches the existing `/document` pattern.

---

## Codebase Verification

- [x] `/plan` currently lists available design docs - Verified
- [x] `/build` currently lists available implementation plans - Verified
- [x] `/build` has "locate" logic for design docs - Verified
- [x] `/document` has target wording pattern - Verified

**Patterns to leverage:**
- `/document` prerequisite section wording: "If the user does not provide a [doc] path, ask them for the file path."

**Discrepancies found:**
- None

---

## Tasks

### Task 1: Update Prerequisite sections in /plan and /build

**Description:** Replace directory-listing instructions with ask-for-path instructions in both command files, matching `/document`'s wording style.

**Files:**
- `.claude/commands/plan.md` - modify
- `.claude/commands/build.md` - modify

**Changes:**

For `/plan` (lines 14-17), replace:
```
## Prerequisite

A design document must exist in `docs/design-plans/`.

First, list available design docs and ask which one to plan for (or confirm if there's only one recent one).
```

With:
```
## Prerequisite

A design document must exist in `docs/design-plans/`.

If the user does not provide a design doc path, ask them for the file path.
```

For `/build` (lines 14-19), replace:
```
## Prerequisite

An implementation plan must exist in `docs/implementation-plans/`.

First, list available implementation plans and ask which one to build (or confirm if there's only one recent one).

Also locate the corresponding design document in `docs/design-plans/` for the Build Log.
```

With:
```
## Prerequisite

An implementation plan must exist in `docs/implementation-plans/`.

If the user does not provide an implementation plan path, ask them for the file path.

A design document must also exist in `docs/design-plans/` for the Build Log. If the user does not provide a design doc path, ask them for the file path.
```

**Done when:**
- `/plan` without args prompts for design doc path (no directory listing)
- `/build` without args prompts for both paths (no directory listing)
- Both still reference expected directories as guidance

**Commit:** "Simplify doc path input for /plan and /build"

---

## Verification Checklist

- [ ] Run `/plan` with no arguments - should ask for design doc path
- [ ] Run `/build` with no arguments - should ask for implementation plan and design doc paths
- [ ] Verify directory paths (`docs/design-plans/`, `docs/implementation-plans/`) are still mentioned
- [ ] Compare wording to `/document` - style should match

---

## Notes

Single-task implementation due to small scope. Both files are modified together since they represent a cohesive change to the workflow's path-input behavior.
