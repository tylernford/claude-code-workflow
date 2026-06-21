# Stop /document Marking Acceptance Criteria

**Created:** 2026-06-21 **Implementation Plan:** [to be created by /plan]

---

## Overview

**What:** Remove `/document`'s instruction to mark acceptance criteria `[x]`, making
document read-only over the checkbox state that `/build` produces.

**Why:** `document/SKILL.md` Step 2.1 unconditionally re-marks every acceptance criterion
`[x]`. Since `/build` already marks `[x]` only on items that pass (`build/SKILL.md:56`)
and leaves failed/unverified items unchecked, document's blanket re-marking can only act
on the unchecked remainder a partial or abandoned build left behind — silently turning an
honest partial state into an all-green checklist. This directly contradicts document's own
Rule 1 ("Document what actually happened, not what was planned") and the repo's "preserve
the mess" principle, and it is internally inconsistent with `document/SKILL.md:58`, which
offers a Final status of `Partial | Abandoned` on the very next lines.

The instruction is vestigial: marking acceptance criteria belonged to document under an
earlier design, but a later refactor moved that responsibility into `/build`. The line was
never removed, so it went from redundant to actively harmful.

**Type:** Bugfix

---

## Requirements

### Must Have

- [ ] `document/SKILL.md` contains no instruction to set or mark acceptance criteria
      `[x]`.
- [ ] Document instead reviews the existing acceptance-criteria state (read-only) and uses
      it to inform the Completion section.
- [ ] The Completion-section instruction preserves honest partial state: if any criteria
      remain `[ ]`, Final status must be `Partial` or `Abandoned`, and the unmet items are
      recorded as deviations.

### Nice to Have

- [ ] A one-line note in document clarifying that `/build` is the sole authority for
      marking acceptance criteria (prevents the instruction from creeping back in).

### Out of Scope

- No changes to `/build` — it is already correct as the sole, pass-gated authority for
  marking `[x]` (`build/SKILL.md:48-58`).
- No changes to `/plan` or `/design`.
- No new validation, blocking, or re-verification logic in document. Document remains a
  documentation phase, not a validation phase.
- No "late pass" escape hatch in document. If a criterion genuinely passes during
  documentation, the user re-runs `/build`'s acceptance step or marks it manually; build
  stays the single authority.

---

## Design Decisions

### How document should handle acceptance criteria

**Options considered:**

1. **Make document mark conditionally** (only mark items that pass) — Rejected. Duplicates
   verification logic that already lives in `/build`, reintroduces document as a validator
   (contradicting "documentation shouldn't validate"), and keeps two authorities for the
   same checkbox.
2. **Remove document's marking entirely; document reads state and reconciles into
   Completion** — Chosen. Build is the single authority on `[x]`; document reports what
   build recorded. Cleanly honors Rule 1 and "preserve the mess," and resolves the
   internal inconsistency with the `Partial | Abandoned` status.

**Decision:** Option 2. Marking is build's job; document reflects, never sets.

### What document does with leftover unchecked items

**Options considered:**

1. Mark them (current behavior) — the laundering bug; rejected.
2. Block / hard-fail the phase — rejected; adds validation behavior document shouldn't
   own.
3. Require Final status `Partial`/`Abandoned` and list unmet items as deviations — Chosen.
   Preserves the mess and keeps the checkbox state and the written status consistent
   without document doing any verification.

**Decision:** Option 3.

---

## Acceptance Criteria

- [ ] `document/SKILL.md` no longer instructs marking acceptance criteria `[x]` (the "Mark
      acceptance criteria as `[x]`" instruction at current Step 2.1 is gone).
- [ ] `document/SKILL.md` instructs reviewing the existing acceptance-criteria state
      read-only and using unchecked items to inform the Completion section.
- [ ] `document/SKILL.md`'s Completion-section instruction states that any remaining `[ ]`
      criteria require Final status `Partial`/`Abandoned` with the unmet items listed as
      deviations.
- [ ] No edits to `build/SKILL.md`, `plan/SKILL.md`, or `design/SKILL.md`.

---

## Suggested Files to Create/Modify

```
.claude/skills/document/SKILL.md  # remove Step 2.1 marking; make criteria review read-only; tighten Completion-section consistency guard
```

> Note: this repo also syncs skills (see `scripts/sync-skills.sh`). The plan should
> confirm whether the canonical edit target is `.claude/skills/document/SKILL.md`, the
> `~/.claude/skills/document/SKILL.md` source, or both, and keep them consistent.
