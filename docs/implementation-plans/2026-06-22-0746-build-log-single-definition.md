# Implementation Plan: Build Log Single Definition

**Created:** 2026-06-22 **Type:** Docs **Overview:** Reconcile `/build`'s two descriptions
of the Build Log toward one unambiguous per-task model, removing the latent
"deviations-only" framing so the per-task record `/document` depends on is unmistakable.
**Design Spec:**
[docs/design-specs/2026-06-21-2126-build-log-single-definition.md](../design-specs/2026-06-21-2126-build-log-single-definition.md)

---

## Summary

`build/SKILL.md` teaches two incompatible models of the Build Log: Step 5 (`:43`) sits in
the per-task loop and implies one row per task, while "Handling Deviations" (`:62–75`) —
whose only example is a deviation row — implies a sparse, deviations-only log. The plan
template (`plan/templates/implementation-plan.md:71`) and `/document` (Changes section,
`document/SKILL.md:121`) already assume the fuller per-task model. This change aligns
`/build`'s prose and examples with that model, in a single file.

**Note (empirical finding, plan phase):** This was originally scoped as a Bugfix on the
theory that the deviations-only framing produces thin/empty `/document` Changes sections.
Reviewing real implementation plans in `~/sites/firestarter/docs/implementation-plans`
during planning, the only two populated Build Logs (both 2026-03-05) fill the `Notes`
column on **every** row — deviation or not — with substantive per-task descriptions, and
populate `Files` on every row. The predicted failure mode did **not** reproduce (n=2, same
day, small sample). The remaining justification is that the ambiguous prose is a genuine
latent inconsistency worth removing for clarity — hence Type `Docs`, not `Bugfix`.

---

## Codebase Verification

_Confirm assumptions from design spec match actual codebase_

- [x] `build/SKILL.md:43` — Step 5 "Log" lives in the per-task Workflow loop - Verified:
      yes, line 43.
- [x] `build/SKILL.md:62–75` — "Handling Deviations" has a single deviation-only example
      with no header row - Verified: yes, lines 62–75; example is one data row.
- [x] `plan/templates/implementation-plan.md:71` — canonical schema
      `| Date | Task | Files | Notes |` - Verified: yes, line 71.
- [x] `/document` pulls Changes from the Build Log - Verified: yes, now at
      `document/SKILL.md:121` (spec cited `:114–115`; file has since drifted, dependency
      intact).

**Patterns to leverage:**

- The plan template's four-column Build Log (`Date | Task | Files | Notes`) is the
  canonical schema. `/build` references it rather than restating it (Design Decision 2),
  avoiding future drift.

**Discrepancies found:**

- `/document` line numbers in the spec (`:46, :57, :114–115`) have drifted; current
  references are `:43`, `:65`, `:121`. The dependency itself is intact. `/document` stays
  out of scope and unchanged.
- `build/SKILL.md:57` ("If fail: Fix the issue, log deviation in Build Log, re-verify")
  references logging a deviation during acceptance-criteria fixes. This is a genuine
  deviation scenario (Notes content), **not** deviations-only framing — leave as-is.

---

## Tasks

### Task 1: Tighten Step 5 to specify one Build Log row per task

**Description:** Replace the terse Step 5 line in the Workflow loop with explicit per-task
semantics: one row per task, `Files` = key files created/modified, `Notes` =
deviations/discoveries or `—` when none. Add an inline pointer to the canonical schema in
the plan template (nice-to-have — a reference, not a restatement).

**Files:**

- `.claude/skills/build/SKILL.md` - modify (line 43)

**Code example:**

```markdown
5. **Log** - Add **one Build Log row for this task** to the implementation plan. `Files` =
   key files created/modified; `Notes` = deviations or discoveries, or `—` if none.
   (Canonical column schema lives in the plan template's Build Log.)
```

**Done when:** Step 5 states one row per task with `Files` + `Notes` and `—` for a
no-deviation `Notes` value, and references the plan template schema rather than restating
it. **Commit:** "docs: specify one Build Log row per task in /build step 5"

---

### Task 2: Reframe "Handling Deviations" with clean + deviation example rows

**Description:** Reframe the section so a deviation is content of the `Notes` column of
that task's per-task row, not a separate sparse log. Replace the single deviation-only
example with a table showing the header row plus two rows — one clean (`Notes` = `—`) and
one deviation.

**Files:**

- `.claude/skills/build/SKILL.md` - modify (lines 62–75)

**Code example:**

```markdown
When reality doesn't match the plan, the deviation goes in the **`Notes` column of that
task's Build Log row** — every task still gets a row whether or not it deviated.

1. **Don't update the implementation plan** - It's a record of original thinking
2. **Record it in Notes** - What changed and why, in that task's row
3. **Continue** - Proceed with adjusted approach

Example Build Log rows (a clean task, then a deviation):

| Date       | Task   | Files                  | Notes                                         |
| ---------- | ------ | ---------------------- | --------------------------------------------- |
| 2024-01-15 | Task 2 | src/components/Card.ts | —                                             |
| 2024-01-15 | Task 3 | src/utils/helper.ts    | Used existing utility instead of creating new |
```

**Done when:** Section frames deviations as the `Notes` column of the per-task row;
example shows headers `Date | Task | Files | Notes` plus one clean row and one deviation
row; no deviations-only framing remains in the file. **Commit:** "docs: reframe /build
deviations as Notes column with clean + deviation examples"

---

### Task 3: Propagate change to global skills via sync script

**Description:** Run `scripts/sync-skills.sh` so the edited `build/SKILL.md` propagates to
`~/.claude/skills/build/`, per the design spec's closing instruction.

**Note:** This task writes to `~/.claude/skills/`, outside the project directory. The
design spec explicitly directs this propagation and it is the established repo workflow,
but it is a global change — run it manually if preferred.

**Files:**

- none modified in-repo (executes existing `scripts/sync-skills.sh`)

**Done when:** Script outputs `Synced: build` and `~/.claude/skills/build/SKILL.md`
matches the repo source. **Commit:** (no commit — sync only touches the generated global
copy)

---

## Acceptance Criteria

- [x] `/build` step 5 states one row per task with `Files` + `Notes`, and `—` for a
      no-deviation `Notes` value.
- [x] The "Handling Deviations" section frames deviations as the `Notes` column of the
      per-task row, and contains one clean example row plus one deviation example row.
- [x] All Build Log example rows in `build/SKILL.md` use the headers
      `Date | Task | Files | Notes`, matching `implementation-plan.md:71`.
- [x] A search of `build/SKILL.md` finds no language implying the Build Log is only
      written when a deviation occurs.
- [x] `document/SKILL.md` is unchanged; its Changes section (`:121`) is now backed by a
      guaranteed per-task model.

---

## Build Log

_Filled in during `/build` phase_

| Date       | Task   | Files                         | Notes                                                                                                                                               |
| ---------- | ------ | ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-06-22 | Task 1 | .claude/skills/build/SKILL.md | —                                                                                                                                                   |
| 2026-06-22 | Task 2 | .claude/skills/build/SKILL.md | —                                                                                                                                                   |
| 2026-06-24 | Task 3 | (none — synced global copies) | Ran sync-skills.sh; synced all four workflow skills (design/plan/build/document), not just build. Global build/SKILL.md verified identical to repo. |

---

## Completion

**Completed:** 2026-06-24 **Final Status:** Complete

**Summary:** `/build` described the Build Log two different ways — one implying a row per
task, the other implying you only log when something deviates. This change settles on the
per-task model, all within `.claude/skills/build/SKILL.md`.

Step 5 ("Log") now says: add one row per task. `Files` lists the key files you touched;
`Notes` holds any deviation or discovery, or `—` if there's nothing to note. It points to
the plan template for the column schema instead of repeating it.

"Handling Deviations" now treats a deviation as just the `Notes` text on that task's row,
not a separate log. Its example is a small table — a header, one clean row (`Notes` =
`—`), and one deviation row.

`document/SKILL.md` didn't change, but its Changes section can now count on every task
having a row. Synced to `~/.claude/skills/` via `sync-skills.sh`.

**Deviations from Plan:** Note the plan-phase re-typing from Bugfix → Docs (recorded in
the Summary and Notes sections): the predicted "deviations-only" failure mode did not
reproduce in real Build Logs (n=2), so the change stands as a clarity fix for latent
ambiguous prose rather than a behavioral bugfix.

---

## Notes

Re-typed from Bugfix to Docs during planning after real Build Logs showed the
deviations-only failure mode does not reproduce in practice (see Summary note). The edits
are unchanged in substance; only the framing and stakes are lower.
