# Spine validator — making the structured spec/plan data enforceable

**Date:** 2026-06-25. Build-ready shape of the "markdown → structured" thread; full-arc
gear only (pairs with `2026-06-25-workflow-gears.md`). It mechanizes the prose Step-4
check from the AC-carry-forward spec
(`docs/design-specs/2026-06-24-1235-acceptance-criteria-carry-forward.md`). Premise: a
prose-MANDATORY guard is a wish until something machine-readable gates on it.

## What it is

A small CLI that extracts the ` ```yaml spine ` blocks from design-spec and
implementation-plan `.md` files, validates them, and exits non-zero on failure. In
lefthook it's a real commit gate; in `/plan` it gives early feedback. The validator reads
the spine; the human reads the prose.

**Non-goal (the honesty line):** it validates that the spine is well-formed AND complete,
NOT that the design is good or the criteria right. Green means "no structural holes," not
"correct." A floor, not a ceiling — same as `done_when`.

## Conventions

- **Format: ` ```yaml spine ` fenced blocks.** The parser reads only `yaml spine` blocks;
  plain ` ```yaml ` examples in prose are ignored. Renderers highlight as YAML and ignore
  the `spine` word. Blocks self-identify by top-level key (`acceptance_criteria:`,
  `tasks:`); the parser merges them per doc by key. Two blocks sharing a key is an error.
- **Slug IDs on acceptance criteria** (`ac-<slug>`). Reopens the AC-ledger spec's no-IDs
  decision on purpose: a mechanical completeness diff needs a stable join key, and text
  can't be it (reworded criteria change their text). Slugs turn the check from judgment
  into `a == b`. Keep no-IDs and you skip cross-doc check C1 — the diff stays fuzzy.
- **Git carries outcomes; the spine carries authored-durable data only.** No
  `status: passed` fields — the commit existing is the pass (Move 1), enforced by the
  `done_when` hook. The spine holds intent/criteria/files/tags, never build results, which
  would just drift.
- **Heavy-gear only; no-op when there's no spine.** A featherweight commit (bugfix, config
  tweak) has no spine; the hook sees none and passes. The light gear is never taxed.

## The data spine (three records)

**Acceptance criterion — in the design spec (single source of the text):**

```yaml spine
acceptance_criteria:
  - id: ac-card-border
    text: "Card renders the design-token border, not a flat color"
  - id: ac-price-format
    text: "Prices display with currency symbol and two decimals"
```

**Carry-forward ledger — in the plan, references the spec by `ref`:**

```yaml spine
acceptance_criteria:
  - ref: ac-card-border
    status: design # carried unchanged
  - ref: ac-token-config
    status: added # plan-coined; text required (spec has none)
    text: "Token count is config-driven, not hardcoded"
  - ref: ac-exit-link
    status: deferred
    target: "phase 2" # required when deferred
  - ref: ac-old-preview
    status: dropped
    reason: "superseded by ac-card-border" # required when dropped
```

**Task — in the plan:**

```yaml spine
tasks:
  - task: "Add formatPrice helper"
    files: [src/formatPrice.ts, src/formatPrice.test.ts]
    satisfies: [ac-price-format]
    done_when:
      - intent: "formatPrice unit tests pass"
        command: "npm test -- formatPrice" # candidate; /build re-resolves at build
      - intent: "Output uses the brand currency glyph"
        manual: true
```

## Schema (level 2 — per-record, JSON Schema)

- **spec `acceptance_criteria[]`**:
  `{ id: string ^ac-[a-z0-9-]+$ (unique in doc), text: string }`.
- **plan `acceptance_criteria[]`** (the ledger):
  `{ ref: string, status: design|added|deferred|dropped }` with conditionals —
  `added → text required`, `deferred → target required`, `dropped → reason required`.
- **plan `tasks[]`**:
  `{ task: string, files: string[], satisfies?: string[], done_when: done_when_item[] }`.
- **`done_when_item`**: `{ intent: string }` plus **exactly one** of `command: string`
  (non-empty) or `manual: true` (oneOf).

## Check list

**Level 1 — syntactic:** every `yaml spine` block parses as valid YAML; no duplicate
top-level keys across a doc's blocks.

**Level 2 — schema:** each record matches the schema above (fields, types, enums,
conditionals, the `command`-xor-`manual` rule, id-uniqueness).

**Level 3 — cross-document** (the payoff; needs the spec↔plan pairing, resolved from the
spec's "Implementation Plan:" link or shared slug):

- **C1 Completeness:** every spec `id` appears as a ledger `ref`. A missing one is a
  silent drop → error. (The AC-ledger Step-4 guarantee, mechanized.)
- **C2 Ref resolution:** every ledger entry with `status ∈ {design, deferred, dropped}`
  has a `ref` that exists in the spec; every `status: added` ref does NOT collide with a
  spec id (it's new).
- **C3 Coverage:** every active criterion (`status ∈ {design, added}`) is named by at
  least one task's `satisfies`. An active AC no task advances → error (or warn — config).
- **C4 No struck targets:** no task `satisfies` a `ref` that is `deferred`/`dropped`
  (building toward a criterion you said you cut).
- **C5 File sanity:** task `files` are repo-relative — no absolute paths, no `..` escape.

**Output** (human-readable, exit non-zero on any error):

```
✗ C1  spec AC not in plan ledger: ac-exit-link        (silent drop)
✗ C4  task "Add formatPrice" satisfies ac-old-preview, which is (dropped)
✗ L2  ledger ac-token-config status=added but has no text
✓ 7 AC, all accounted for · 4 tasks · 6 done_when (1 manual)
```

## Architecture — one engine, three call sites

- **CLI engine** (`validate-spine <plan.md>` — resolves its spec via the plan/spec link,
  or takes both paths). Node/TS to match firestarter's stack: `js-yaml` + `ajv` + ~5
  cross-doc checks. ~150 lines.
- **lefthook pre-commit** → the gate. Runs the CLI on staged spec/plan files; blocks on
  failure; no-op when no spine is staged. This is what makes it bite — a hook can't be
  rationalized past.
- **`/plan` Step 4** → early feedback. The agent runs the CLI as it finishes: emit →
  validate → repair (red-green for the spine), so a malformed ledger never reaches you.

## Caveats / scope discipline

- **Spine ≠ thinking.** A green run means well-formed and complete, not "the plan is
  good." Judgment still lives in the prose and your review.
- **Keep the schema tiny.** Only fields with a consumer — every field above maps to a
  check or a build action. No `priority`/`owner`/`estimate`; that's the Jira tax.
- **The agent will sometimes emit bad YAML.** That's why the validator exists; pair it
  with the `/plan` repair loop, don't expect one-shot.
- **If you're building a "spec framework," you've overshot.** This is a day's script plus
  a lefthook line plus a ~40-line schema. Hold it there.

## Next action

Build order: (1) JSON Schema file (level 2); (2) CLI engine (extract → parse → schema →
C1–C5); (3) lefthook wiring (the gate, with the no-spine no-op); (4) `/plan` Step-4 call +
repair loop. Adopt the `yaml spine` fence in the plan and design-spec templates in the
same pass so existing docs grow a spine. Featherweight gear has no spine, so there's
nothing to validate.
