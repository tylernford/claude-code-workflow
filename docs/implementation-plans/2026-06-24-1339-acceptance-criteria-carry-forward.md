# Implementation Plan: Acceptance-Criteria Carry-Forward

**Created:** 2026-06-24 **Type:** Bugfix **Overview:** Make `/plan` carry the design
spec's acceptance criteria forward into the implementation plan as a provenance-tagged
ledger, so the plan's criteria — which `/build` enforces as the completion gate — can
never silently diverge from what design specified. **Design Spec:**
[docs/design-specs/2026-06-24-1235-acceptance-criteria-carry-forward.md](../design-specs/2026-06-24-1235-acceptance-criteria-carry-forward.md)

---

## Summary

The acceptance-criteria chain has a broken middle link: `/design` authors testable
criteria and `/build` enforces the _plan's_ copy as the completion gate, but nothing tells
`/plan` to carry design's criteria forward. The plan template's Acceptance Criteria
section is a generic placeholder, so criteria can be silently dropped while `/build`
reports a green "acceptance criteria passed."

This plan fixes it by turning the plan's Acceptance Criteria section into a
**provenance-tagged ledger** — every design criterion appears, tagged with one of four
tags (`(design)`, `(added)`, `(deferred → …)`, `(dropped — reason)`). Deferred/dropped
items stay visible but struck through, so an omission reads as a struck line, never an
absence. `/plan` is instructed to carry forward and to assert coverage; `/build` enforces
only the active (unstruck) criteria.

---

## Codebase Verification

_Confirm assumptions from design spec match actual codebase_

- [x] Template AC section is a generic placeholder - Verified: yes, verbatim at
      `.claude/skills/plan/templates/implementation-plan.md:59-63`
- [x] `/plan` SKILL Step 4 is "Plan Validation" - Verified: yes, lines 67-72
- [x] `/build` enforces AC as the completion gate - Verified: yes, "After All Tasks:
      Acceptance Criteria" (lines 51-60), "All items must pass"
- [x] Skills live under `~/.claude/skills/` and sync from the repo - Verified,
      **refined**: `scripts/sync-skills.sh` copies repo `.claude/skills/{skill}` →
      `~/.claude/skills/{skill}`. The repo-tracked copy is the source of truth; global is
      a generated mirror.

**Patterns to leverage:**

- `scripts/sync-skills.sh` already exists to propagate repo skill edits to
  `~/.claude/skills/`. No new tooling needed.
- The four-tag scheme and struck-line convention come straight from the design spec's
  Decision 2 — implement verbatim, no reinterpretation.

**Discrepancies found:**

- The design spec's "Suggested Files" list points at `~/.claude/skills/...` paths. Edits
  must instead land in the **repo-tracked** `.claude/skills/...` copies (source of truth),
  satisfying `/plan` Rule 5 "stay local." Propagation to global is **automatic** via the
  committed `.githooks/post-merge` hook, which runs `scripts/sync-skills.sh` on merge/pull
  when `.claude/skills/` changed — no manual sync task required. Repo and global copies
  are currently in sync (only cosmetic line-wrap diff in `build/SKILL.md`).

Path remapping applied throughout this plan:

| Design spec path                                         | Actual edit target                                     |
| -------------------------------------------------------- | ------------------------------------------------------ |
| `~/.claude/skills/plan/templates/implementation-plan.md` | `.claude/skills/plan/templates/implementation-plan.md` |
| `~/.claude/skills/plan/SKILL.md`                         | `.claude/skills/plan/SKILL.md`                         |
| `~/.claude/skills/build/SKILL.md`                        | `.claude/skills/build/SKILL.md`                        |

---

## Tasks

### Task 1: Rewrite the plan template's Acceptance Criteria section into a tagged ledger

**Description:** Replace the generic placeholder (lines 59-63) with a provenance-tagged
ledger that defines the four-tag scheme inline, states that every design criterion must
appear (omissions rendered as struck lines, never deleted), names the active gate, and
shows one example line per tag. No generic placeholder remains.

**Files:**

- `.claude/skills/plan/templates/implementation-plan.md` - modify

**Code example:**

```markdown
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
```

**Done when:** The AC section defines all four tags, instructs full carry-forward with
struck-not-deleted omissions, names the active gate, and shows one example per tag. No
`[How to test the feature works]`-style placeholder remains. **Commit:** "Rewrite plan
template acceptance criteria as tagged ledger"

---

### Task 2: Add carry-forward step and coverage assertion to `/plan` SKILL

**Description:** Two coordinated edits to `.claude/skills/plan/SKILL.md`. (a) Insert a new
**Step 4: Build the Acceptance Criteria Ledger** instructing `/plan` to carry every
design-spec criterion into the ledger tagged `(design)`, add plan-specific criteria tagged
`(added)`, and strike deferred/dropped items with a reason rather than deleting them. (b)
Renumber the existing Step 4 (Plan Validation) → Step 5 and add an acceptance-criteria
coverage assertion to it; renumber Step 5 (Confirm Type and Overview) → Step 6. Update all
internal "Step 4/5" references accordingly.

**Files:**

- `.claude/skills/plan/SKILL.md` - modify

**Code example:**

```markdown
### Step 4: Build the Acceptance Criteria Ledger

Populate the plan's Acceptance Criteria section (see template) as a provenance-tagged
ledger:

- Carry **every** criterion from the design spec into the ledger, tagged `(design)`.
  Reword freely — a reworded criterion is still `(design)`.
- Add any plan-specific criteria, tagged `(added)`.
- If a design criterion won't be met here, keep its line but strike it through and tag
  `(deferred → target)` or `(dropped — reason)`. Never delete it.

### Step 5: Plan Validation

- Review task list against design spec requirements
- Confirm all requirements are covered by tasks
- **Acceptance-criteria coverage:** confirm every design-spec criterion appears in the
  ledger (carried, deferred, or dropped-with-reason). A design criterion that appears
  nowhere is a defect — call it out and fix before finalizing.
- Confirm all active (unstruck) criteria are testable
- Check task ordering makes sense (dependencies)

### Step 6: Confirm Type and Overview

...(unchanged content)...
```

**Done when:** `/plan` SKILL has a dedicated carry-forward + tagging step (new Step 4),
its validation step (now Step 5) asserts full design-criterion coverage with silent
omission named as a defect, Confirm Type and Overview is Step 6, and all internal step
references are consistent. **Commit:** "Add acceptance-criteria carry-forward and coverage
check to /plan"

---

### Task 3: Clarify in `/build` SKILL that the gate is the active (unstruck) criteria

**Description:** In the "After All Tasks: Acceptance Criteria" section of
`.claude/skills/build/SKILL.md`, state that the gate is the **active (unstruck)** criteria
— `(design)` + `(added)` — and that deferred/dropped (struck) items are recorded but not
verified here. Scope "for each checklist item" and "all items must pass" to active items.

**Files:**

- `.claude/skills/build/SKILL.md` - modify

**Code example:**

```markdown
### After All Tasks: Acceptance Criteria

The gate is the plan's **active (unstruck) criteria** — the `(design)` and `(added)`
items. Struck items (`(deferred)` / `(dropped)`) are recorded in the ledger but **not
verified here**; they belong to a later plan or are intentionally out of scope. Do not
skip silently over them — the strike is the record.

1. **Prompt** - Ask user: "All tasks complete. Run acceptance criteria before completing
   phase?"
2. **Wait for confirmation** - User must confirm to proceed
3. **For each active (unstruck) checklist item:**
   - Present the item
   - Verify with user (pass/fail)
   - If pass: Mark `[x]` in implementation plan
   - If fail: Fix the issue, log deviation in Build Log, re-verify
4. **All active items must pass** before proceeding to Phase Complete
```

**Done when:** `/build` SKILL's acceptance-criteria step names the gate as active/unstruck
criteria and states deferred/dropped items are recorded but not verified there.
**Commit:** "Scope /build acceptance gate to active criteria"

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
> those and records, but does not verify, the struck items.

- [ ] The plan template's Acceptance Criteria section instructs carry-forward using the
      four-tag scheme `(design)` / `(added)` / `(deferred → …)` / `(dropped — reason)`,
      with no generic placeholder remaining. `(design)`
- [ ] `/plan` SKILL has an explicit instruction (new Step 4) to carry every design-spec
      criterion into the plan's Acceptance Criteria, tagged, and to add plan-specific
      criteria tagged `(added)`. `(design)`
- [ ] `/plan` Plan Validation (now Step 5) asserts every design-spec criterion is
      accounted for (carried, deferred, or dropped with reason) — silent omission is
      called out as a defect. `(design)`
- [ ] `/build` SKILL's acceptance-criteria step states the gate is the active (unstruck)
      criteria, and that deferred/dropped items are recorded but not verified there.
      `(design)`
- [ ] Running the updated `/plan` against
      `docs/design-specs/2026-02-19-1151-study-partner.md` scoped to "Phase 1: must-haves
      only" produces an Acceptance Criteria ledger that carries all 9 must-haves as
      `(design)` **and** renders the deferred Nice-to-Have criteria (e.g. "dynamic
      difficulty adjustment") as struck `~~…~~ (deferred → …)` lines — not as absences.
      Discard the test plan afterward. (Verified post-merge, or after a manual
      `sync-skills.sh` so the edited skill is active.) `(design)`
- [ ] The `/design` skill and design-spec template are unchanged. `(design)`

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

- **Edit targets are the repo-tracked `.claude/skills/...` copies**, not the
  `~/.claude/skills/...` paths named in the design spec. The repo is the source of truth;
  the sync script generates the global mirror.
- **Propagation to global is automatic.** The committed `.githooks/post-merge` hook
  (`core.hooksPath = .githooks`) runs `scripts/sync-skills.sh` when `.claude/skills/`
  changed between `ORIG_HEAD` and `HEAD`, so merging + pulling this branch syncs the edits
  to `~/.claude/skills/`. No manual sync task is needed. (For local pre-merge testing
  only, the user may run `bash scripts/sync-skills.sh` by hand.)
- The end-to-end acceptance criterion is an **empirical integration test**, not a code
  task: run the updated `/plan` against `2026-02-19-1151-study-partner.md` scoped to
  "Phase 1: must-haves only" and confirm the ledger renders the deferred Nice-to-Have
  criteria as struck `(deferred → …)` lines. study-partner was chosen because it has
  **real, genuinely deferrable Nice-to-Have criteria** (graceful ambiguous-invocation
  handling, mid-session pivot, dynamic difficulty) — so the deferral is natural, not a
  manufactured phasing pretext. The test needs the edited skill **active in
  `~/.claude/skills/`**, so run it post-merge (post-merge hook syncs automatically) or
  after a manual `bash scripts/sync-skills.sh`. Discard the test plan afterward — it's a
  probe, not work.
