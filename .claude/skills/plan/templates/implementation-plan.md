# Implementation Plan: [Feature Name]

**Created:** YYYY-MM-DD **Type:** [type] **Overview:** [overview] **Design Spec:** [link
to design spec]

---

## Summary

[Brief description of what will be implemented]

---

## Codebase Verification

_Confirm assumptions from design spec match actual codebase_

- [ ] [Assumption 1] - Verified: [yes/no/notes]
- [ ] [Assumption 2] - Verified: [yes/no/notes]

**Patterns to leverage:**

- [Existing pattern/utility to reuse]

**Discrepancies found:**

- [Any differences from design assumptions]

---

## Tasks

### Task 1: [Task Title]

**Description:** [What to do] **Files:**

- `path/to/file.ext` - [create/modify]

**Code example:** (if helpful)

```
[sample code]
```

**Done when:**

- intent: [what proves this task done — the locked, durable claim] command:
  `[candidate — a guess; /build re-resolves against the real repo]`
- intent: [intent with no feasible command] manual: true

**Commit:** "[commit message]"

> Each `done_when` item is an **intent** (locked) plus **exactly one** of a candidate
> `command:` (marked as a guess — `/build` re-resolves it against the real repo, never
> lifts it verbatim) or `manual: true`. Field names match the spine schema. Never author
> build-time outcomes (pass/fail, "compiles") into this block.

---

### Task 2: [Task Title]

**Description:** [What to do] **Files:**

- `path/to/file.ext` - [create/modify]

**Done when:**

- intent: [what proves this task done] command:
  `[candidate — a guess; /build re-resolves against the real repo]`
- intent: [intent with no feasible command] manual: true

**Commit:** "[commit message]"

---

## Acceptance Criteria

> Provenance-tagged ledger. **Every** criterion from the design spec appears below, tagged
> with what happened to it — plus any criteria this plan adds. A criterion that won't be
> met here is struck through, never deleted: an omission must read as a struck line, never
> an absence.
>
> | Tag                   | Meaning                                               |
> | --------------------- | ----------------------------------------------------- |
> | `(design)`            | Carried from the design spec (verbatim or reworded)   |
> | `(added)`             | New criterion this plan introduces                    |
> | `(deferred → target)` | Belongs to a later plan/phase — strike the line       |
> | `(dropped — reason)`  | Intentionally not done, with reason — strike the line |
>
> The **active gate** is the unstruck items — `(design)` + `(added)`. `/build` verifies
> those and records, but does not verify, the struck (deferred/dropped) items.

- [ ] [Carried design criterion] `(design)`
- [ ] [Plan-specific criterion] `(added)`
- [ ] ~~[Deferred design criterion]~~ `(deferred → Phase 2)`
- [ ] ~~[Dropped design criterion]~~ `(dropped — superseded by X)`

---

## Completion

**Completed:** [Date] **Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]

---

## Notes

[Any additional context, risks, or considerations]
