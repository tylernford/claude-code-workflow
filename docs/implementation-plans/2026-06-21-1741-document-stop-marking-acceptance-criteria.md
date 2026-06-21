# Implementation Plan: Stop /document Marking Acceptance Criteria

**Created:** 2026-06-21 **Type:** Bugfix **Overview:** Remove `/document`'s instruction to
mark acceptance criteria `[x]`, making document read-only over the checkbox state that
`/build` produces — so an honest partial/abandoned build state is reported, not silently
laundered into all-green. **Design Spec:**
docs/design-specs/2026-06-21-1730-document-stop-marking-acceptance-criteria.md

---

## Summary

`document/SKILL.md` Step 2 (item 1) unconditionally re-marks every acceptance criterion
`[x]`. Because `/build` is already the sole, pass-gated authority for marking `[x]`,
document's blanket re-marking can only act on the unchecked remainder a partial or
abandoned build left behind — silently turning an honest partial state into an all-green
checklist. This single-file edit removes the marking instruction, makes the criteria
review read-only, and tightens the Completion section so any remaining `[ ]` forces a
`Partial`/`Abandoned` status with the unmet items recorded as deviations.

---

## Codebase Verification

_Confirm assumptions from design spec match actual codebase_

- [x] The marking instruction exists - Verified: yes. `document/SKILL.md:52` reads "**Mark
      acceptance criteria** as `[x]` in the Acceptance Criteria section" (the spec's "Step
      2.1" = Step 2, item 1).
- [x] Completion section offers Partial/Abandoned - Verified: yes. `document/SKILL.md:56`
      offers `Final status (Complete | Partial | Abandoned)` (spec said line 58 — minor
      drift, content matches).
- [x] `/build` is the sole pass-gated marking authority - Verified: yes.
      `build/SKILL.md:56` reads "If pass: Mark `[x]` in implementation plan". Out-of-scope
      claim (no build changes needed) holds.

**Patterns to leverage:**

- The existing Step 2 structure (numbered items + Completion sub-bullets) is kept; only
  the wording of items 1–2 changes.

**Discrepancies found:**

- **Edit target resolved (the spec's open question):** the repo file
  `.claude/skills/document/SKILL.md` is the canonical source.
  `~/.claude/skills/document/SKILL.md` is a generated copy that `scripts/sync-skills.sh`
  produces by copying _from_ the repo; the two are currently byte-identical. This plan
  edits **only the repo file**. Running the sync (which writes to `~/.claude`, outside the
  project) is the user's separate step and is out of scope.

---

## Tasks

### Task 1: Make /document read-only over acceptance criteria

**Description:** In `.claude/skills/document/SKILL.md`, replace Step 2 items 1–2 so
document (a) no longer instructs marking `[x]`, (b) reviews the existing criteria state
read-only and names `/build` as the sole marking authority, and (c) ties any remaining
`[ ]` to a `Partial`/`Abandoned` Final status with unmet items recorded as deviations.
Leave Step 2 item 3 (Review Build Log) unchanged.

**Files:**

- `.claude/skills/document/SKILL.md` - modify (Step 2, lines ~50–58)

**Code example:**

Replace items 1 and 2 of Step 2 with:

```markdown
1. **Review acceptance criteria (read-only)** - Read the existing state in the Acceptance
   Criteria section. `/build` is the sole authority for marking `[x]`; document never sets
   or changes checkbox state. Use any items still `[ ]` to inform the Completion section
   below.

2. **Fill in Completion section:**
   - Completed date
   - Final status (Complete | Partial | Abandoned) — if any acceptance criteria remain
     `[ ]`, Final status must be `Partial` or `Abandoned`, and each unmet item is recorded
     as a deviation.
   - Summary of what was actually built
   - Deviations from original plan
```

**Done when:**

- No "Mark acceptance criteria as `[x]`" instruction remains anywhere in
  `document/SKILL.md`.
- Step 2 item 1 is read-only and explicitly names `/build` as the sole marking authority.
- The Completion section instruction states that remaining `[ ]` criteria force
  `Partial`/`Abandoned` with unmet items as deviations.
- `build/SKILL.md`, `plan/SKILL.md`, and `design/SKILL.md` are untouched.

**Commit:** "fix: stop /document marking acceptance criteria"

---

## Acceptance Criteria

- [ ] `document/SKILL.md` no longer instructs marking acceptance criteria `[x]` (the "Mark
      acceptance criteria as `[x]`" instruction at the current Step 2 item 1 is gone).
- [ ] `document/SKILL.md` instructs reviewing the existing acceptance-criteria state
      read-only and using unchecked items to inform the Completion section.
- [ ] `document/SKILL.md`'s Completion-section instruction states that any remaining `[ ]`
      criteria require Final status `Partial`/`Abandoned` with the unmet items listed as
      deviations.
- [ ] A one-line note clarifies that `/build` is the sole authority for marking acceptance
      criteria (Nice-to-Have, folded into Step 2 item 1).
- [ ] No edits to `build/SKILL.md`, `plan/SKILL.md`, or `design/SKILL.md`.

---

## Build Log

_Filled in during `/build` phase_

| Date | Task | Files | Notes |
| ---- | ---- | ----- | ----- |

---

## Completion

**Completed:** [Date] **Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]

---

## Notes

- The global copy at `~/.claude/skills/document/SKILL.md` will be stale until the user
  runs `scripts/sync-skills.sh`. That sync is intentionally out of scope (it writes
  outside the project directory). </content> </invoke>
