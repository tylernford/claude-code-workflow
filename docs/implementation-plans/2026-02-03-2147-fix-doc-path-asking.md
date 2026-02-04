# Implementation Plan: Fix Doc Path Asking

**Design Doc:** docs/design-plans/2026-02-03-2142-fix-doc-path-asking.md
**Created:** 2026-02-03

---

## Summary

Remove directory references from `/plan` and `/build` command Prerequisite sections so they ask for document paths instead of searching directories.

---

## Codebase Verification

- [x] `/plan` has directory reference in Prerequisite - Verified: yes, line 17
- [x] `/build` has directory references in Prerequisite - Verified: yes, lines 15 and 19
- [x] `/document` works correctly without directory references - Verified: yes, serves as pattern to follow

**Patterns to leverage:**
- `/document`'s Prerequisite pattern: simple "ask for path" instruction without directory mention

**Discrepancies found:**
- None. Design assumptions match codebase.

---

## Tasks

### Task 1: Update Prerequisite sections in /plan and /build commands
**Description:** Remove directory references from both command files' Prerequisite sections. Simplify to match `/document`'s minimal pattern that correctly triggers asking behavior.

**Files:**
- `.claude/commands/plan.md` - modify
- `.claude/commands/build.md` - modify

**Code example:**

`plan.md` Prerequisite becomes:
```markdown
## Prerequisite

If the user does not provide a design doc path, ask them for the file path.
```

`build.md` Prerequisite becomes:
```markdown
## Prerequisite

If the user does not provide an implementation plan path, ask them for the file path.

Also ask for the design doc path (needed for the Build Log).
```

**Done when:**
- `/plan` without arguments asks for design doc path
- `/build` without arguments asks for both paths
- Neither command searches `docs/design-plans/` or `docs/implementation-plans/`

**Commit:** "Fix /plan and /build to ask for doc paths instead of searching"

---

## Verification Checklist

- [ ] Run `/plan` without arguments — should ask for design doc path
- [ ] Run `/build` without arguments — should ask for implementation plan and design doc paths
- [ ] Run `/plan docs/design-plans/...` with argument — should work as before
- [ ] Run `/build docs/implementation-plans/...` with argument — should work as before

---

## Notes

This is a minimal text change. The fix works by removing the trigger (directory paths) that causes Claude to search instead of ask.
