# Build Log Single Definition

**Created:** 2026-06-21 **Implementation Plan:**
[docs/implementation-plans/2026-06-22-0746-build-log-single-definition.md](../implementation-plans/2026-06-22-0746-build-log-single-definition.md)

---

## Overview

**What:** Resolve the double definition of the Build Log in `/build` so it is
unambiguously a per-task record, satisfying `/document`'s dependency on it.

**Why:** `/build` teaches two incompatible models of the Build Log. Step 5 (`:43`) sits in
the per-task workflow loop and implies one entry per task. The "Handling Deviations"
section (`:62–75`) — whose only example is a deviation row — teaches a deviations-only
log. `/document` (`:46`, `:57`, `:114–115`) depends on the fuller per-task model, pulling
"Changes: Key files/areas" entirely from the Build Log. The result: a clean build with few
deviations, logged by a reader who absorbed the deviations-only framing, hands `/document`
a thin or empty Changes section.

The plan template (`plan/templates/implementation-plan.md:71`,
`| Date | Task | Files | Notes |`) already encodes the fuller model — one row per task,
`Files` for key files, `Notes` for deviations. The template and `/document` agree; only
`/build`'s prose and its single deviation-only example are out of step.

**Type:** Bugfix

---

## Requirements

### Must Have

- [ ] `/build` step 5 unambiguously specifies **one Build Log row per task**, with `Files`
      = key files created/modified and `Notes` = deviations/discoveries (or `—` when
      none).
- [ ] The "Handling Deviations" section reframes deviations as content of the **`Notes`
      column of that task's per-task row**, not a separate sparse log.
- [ ] The "Handling Deviations" section includes **two example rows** — one clean (no
      deviation) and one deviation — so the reader's mental model is not deviation-only.
- [ ] Example column headers match the plan template exactly:
      `Date | Task | Files | Notes`.
- [ ] No "deviations-only" framing remains anywhere in `/build`.

### Nice to Have

- [ ] A brief inline pointer from `/build` to the canonical Build Log schema in the plan
      template (kept as a reference, not a restatement, to avoid drift).

### Out of Scope

- `/document` (`document/SKILL.md`) — no change; its Build Log dependency is satisfied
  once `/build` guarantees per-task rows.
- `plan/templates/implementation-plan.md` — the four-column schema is already correct and
  remains the canonical home for the format.
- `/plan` and `/design` skills.
- The global `~/.claude/skills/` copies — these are generated from the repo via
  `scripts/sync-skills.sh`; editing the repo source is sufficient.

---

## Design Decisions

### Which definition the Build Log reconciles toward

**Options considered:**

1. **Per-task record (fuller)** — Every task gets a Build Log row; deviations live in the
   `Notes` column. `/document` stays as-is. Matches the existing template schema; fixes
   the empty-Changes failure with the smallest blast radius.
2. **Deviations-only log** — Keep the Build Log sparse and relax `/document` to derive
   Changes from each task's `Files` field in the plan. Larger change to `/document`;
   duplicates information the Build Log is meant to consolidate.
3. **Hybrid** — Per-task rows with optional `Notes`, plus a `/document` fallback to plan
   task `Files` when a row's `Files` is blank. More robust but more moving parts across
   two skills.

**Decision:** Option 1, per-task record. It aligns `/build` with the schema the template
and `/document` already assume, requires changes to a single file, and directly removes
the failure mode.

### Where the log format lives

**Options considered:**

1. **Point to template + clean example** — Keep the canonical column schema in the plan
   template; `/build` references it and adds a normal (non-deviation) example row.
2. **Restate full schema in `/build`** — Spell out the column structure directly in
   `build/SKILL.md`. More self-contained but duplicates the template, risking future drift
   between the two.

**Decision:** Option 1. The plan template stays the single source of the format; `/build`
references it and supplies a clean example so the mental model is not deviation-only.

---

## Acceptance Criteria

- [ ] `/build` step 5 states one row per task with `Files` + `Notes`, and `—` for a
      no-deviation `Notes` value.
- [ ] The "Handling Deviations" section frames deviations as the `Notes` column of the
      per-task row, and contains one clean example row plus one deviation example row.
- [ ] All Build Log example rows in `/build` use the headers
      `Date | Task | Files | Notes`, matching `implementation-plan.md:71`.
- [ ] A search of `build/SKILL.md` finds no language implying the Build Log is only
      written when a deviation occurs.
- [ ] `document/SKILL.md` is unchanged; its Changes section (`:114–115`) is now backed by
      guaranteed per-task rows.

---

## Suggested Files to Create/Modify

```
.claude/skills/build/SKILL.md   # Step 5 (:43): one row per task, Files + Notes, "—" when no deviation
                                #   Handling Deviations (:62–75): reframe as Notes column; add clean + deviation examples
```

After editing, run `scripts/sync-skills.sh` to propagate the change to
`~/.claude/skills/build/`.
