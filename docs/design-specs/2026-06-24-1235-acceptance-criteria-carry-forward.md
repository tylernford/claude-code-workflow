# Acceptance-Criteria Carry-Forward

**Created:** 2026-06-24 **Implementation Plan:** [link to implementation plan]

---

## Overview

**What:** Make `/plan` carry the design spec's acceptance criteria forward into the
implementation plan as a provenance-tagged ledger, so the plan's criteria — which `/build`
enforces as the completion gate — can never silently diverge from what design specified.

**Why:** The acceptance-criteria chain has a broken middle link. `/design` authors
testable criteria; `/build` enforces the _plan's_ copy of them as the mandatory completion
gate; but nothing tells `/plan` to carry design's criteria forward. The plan template's
Acceptance Criteria section (`implementation-plan.md:59-63`) is a generic empty
placeholder, so `/plan` re-derives criteria from scratch. Criteria can be dropped or
narrowed with no trace, and `/build` then passes an incomplete gate while reporting
"acceptance criteria passed" — a green checkmark over a hole.

**Type:** Bugfix

---

## Evidence

Before designing, three real projects were diagnosed — 30 matched design↔plan pairs — to
measure how often the plan's criteria diverge from design's in practice.

| Project      | Pairs | Identical | Meaningful divergence       | Worst case                                                            |
| ------------ | ----- | --------- | --------------------------- | --------------------------------------------------------------------- |
| obsidian-mcp | 16    | 86%       | 2 (structural, benign)      | Criteria faithful; drift was at detail level, not criteria            |
| firestarter  | 13    | 46%       | ~31% (subset/diverged/miss) | Plan **silently dropped** "preview bar appears / Exit link works"     |
| wic          | 1     | 0%        | 100% (subset + diverged)    | Two "after cutover" criteria **vanished** from the plan with no trace |

**Conclusions that shaped this design:**

1. The gap is real, and the dangerous failure mode is **silent drops** (firestarter, wic)
   — criteria a builder reading only the plan would never know existed.
2. A naive "mirror design exactly, freeze it" fix would be **wrong**. Plans legitimately
   _add_ criteria (wic added idempotency + test-coverage; firestarter added config-driven
   tokens) and legitimately _narrow scope_ for phased work (wic Phase 1). The sin was
   never adding or narrowing — it was doing so _silently_.
3. The chain _can_ hold (obsidian-mcp, 86% identical) — but only by hand discipline. It is
   currently a matter of habit, not structure. That is what this fixes.

---

## Requirements

### Must Have

- [ ] The plan's Acceptance Criteria section is a provenance-tagged ledger in which
      **every** design-spec criterion appears, tagged with what happened to it.
- [ ] `/plan` is instructed to carry every design criterion forward, tag it, and add its
      own.
- [ ] `/plan` validation asserts every design criterion is accounted for (carried,
      deferred, or dropped) with **no silent omissions**.
- [ ] `/build` enforces the **active** (unstruck) criteria as the gate and does not
      silently pass over deferred/dropped items.
- [ ] Healthy divergence is preserved: plans can still add criteria and defer/drop them,
      as long as it is explicit.

### Nice to Have

- [ ] Tag vocabulary is small and self-documenting enough to need no separate legend
      lookup.

### Out of Scope

- Stable IDs on design-spec criteria (e.g. `AC1`, `AC2`). Decided against — wording + tags
  give enough traceability without adding ceremony to `/design`.
- Any change to the `/design` skill or design-spec template. Design is the _source_ of the
  criteria and already produces them; it is correct as-is.
- Automated/tooling enforcement of the coverage check. The check is a `/plan` behavior,
  not a script.
- Retroactively fixing existing plans in firestarter/wic/obsidian-mcp.

---

## Design Decisions

### Decision 1: Traceability mechanism — ledger vs. coverage-check

**Options considered:**

1. **Explicit reconciliation block (ledger)** — Plan's Acceptance Criteria section lists
   every design criterion, each tagged carried/added/deferred/dropped. Safety lives in the
   _artifact_; the document itself is evidence nothing was lost. More ceremony per plan.
2. **Carry-forward + coverage check** — Plan copies criteria forward; a `/plan` step
   asserts coverage. Safety lives in the _process_; document stays lean but the guarantee
   is only as strong as the step firing, and a deferral leaves no written reason.

**Decision:** Option 1 (ledger). The diagnosed failures were _silent_, and the chain only
held when carried by hand. A ledger makes silence impossible at the artifact level rather
than trusting a step to fire. The extra ceremony is acceptable; tamper-evidence is the
point.

### Decision 2: Tag vocabulary

**Options considered:**

1. Rich status taxonomy (carried / reworded / split / merged / deferred / dropped /
   added…)
2. Four tags only: `(design)`, `(added)`, `(deferred → target)`, `(dropped — reason)`.

**Decision:** Four tags. Minimal vocabulary that still distinguishes the two healthy moves
(carry, add) from the two dangerous-if-silent moves (defer, drop). Rewording is just a
carried `(design)` criterion phrased differently — no separate tag needed.
Deferred/dropped items stay visible but struck through, so an omission reads as a struck
line, never an absence.

### Decision 3: What `/build` enforces

**Options considered:**

1. Build enforces the entire ledger including deferred/dropped items.
2. Build enforces only the **active** (unstruck) criteria — `(design)` + `(added)` — and
   records but does not verify deferred/dropped items.

**Decision:** Option 2. Deferred/dropped items belong to a different gate (a later plan)
or are explicitly out. Build cannot pass over them silently because the deferral is
written down in the ledger; it simply does not verify them here.

---

## Acceptance Criteria

- [ ] The plan template's Acceptance Criteria section instructs carry-forward using the
      four-tag scheme `(design)` / `(added)` / `(deferred → …)` / `(dropped — reason)`,
      with no generic placeholder remaining.
- [ ] `/plan` SKILL has an explicit instruction to carry every design-spec criterion into
      the plan's Acceptance Criteria, tagged, and to add plan-specific criteria tagged
      `(added)`.
- [ ] `/plan` Step 4 (Plan Validation) asserts every design-spec criterion is accounted
      for (carried, deferred, or dropped with reason) — silent omission is called out as a
      defect.
- [ ] `/build` SKILL's acceptance-criteria step states the gate is the active (unstruck)
      criteria, and that deferred/dropped items are recorded but not verified there.
- [ ] Walking the wic or firestarter divergence cases through the new templates would
      render a dropped criterion as a visible struck `(deferred)`/`(dropped)` line, not an
      absence.
- [ ] The `/design` skill and design-spec template are unchanged.

---

## Suggested Files to Create/Modify

> Non-binding starting point. `/plan` re-verifies these against the codebase in its Step 2
> and owns the final paths.

```
~/.claude/skills/plan/templates/implementation-plan.md  # rewrite Acceptance Criteria section into the tagged ledger
~/.claude/skills/plan/SKILL.md                          # carry-forward instruction + Step 4 coverage assertion
~/.claude/skills/build/SKILL.md                         # clarify gate = active (unstruck) criteria only
```

Note: the skills live under `~/.claude/skills/`. This repo syncs them via
`scripts/sync-skills.sh` — `/plan` should confirm whether edits land in
`~/.claude/skills/` directly, in a repo-tracked copy, or both, and sequence tasks
accordingly.
