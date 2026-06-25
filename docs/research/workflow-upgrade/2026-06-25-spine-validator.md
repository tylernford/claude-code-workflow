# Spine validator — making the structured spec/plan data enforceable

**Date:** 2026-06-25 **Relationship:** the build-ready shape of the "markdown →
structured" thread. Pairs with `2026-06-25-workflow-gears.md` (this is _full-arc-gear_
tooling only) and the AC-carry-forward spec
(`docs/design-specs/2026-06-24-1235-acceptance-criteria-carry-forward.md`, whose prose
Step-4 completeness check this turns into a mechanical diff). Premise from the
structural-over-trust thread: _a prose-MANDATORY guard is a wish until its data is
machine-readable and something gates on it._ This is that substrate.

---

## What it is

A small CLI that extracts the structured `yaml` blocks embedded in design-spec /
implementation-plan `.md` files, validates them, and **exits non-zero on failure**. Wired
into lefthook it becomes a real commit gate; called from `/plan` it gives early feedback.
The doc stays prose-with-an- extractable-spine — the validator reads the spine; the human
reads the prose.

**Non-goal (the honesty line):** it validates that the spine is _well-formed and
complete_, NOT that the design is _good_ or the criteria _right_. Green means "no
structural holes," not "correct." It is a floor, not a ceiling — same as `done_when`.

## Conventions baked in

- **Format: YAML in fenced blocks tagged ` ```yaml spine `.** The parser reads only blocks
  whose info-string is `yaml spine`; plain ` ```yaml ` example blocks in prose are ignored
  (solves the "example yaml gets parsed" failure mode). Renderers highlight as YAML and
  ignore the `spine` word. Blocks self-identify by top-level key (`acceptance_criteria:`,
  `tasks:`); the parser collects all spine blocks per doc and merges by key (two blocks
  with the same top-level key = a validation error).
- **Slug IDs on acceptance criteria** (`ac-<slug>`). This re-opens the AC-ledger spec's
  no-IDs decision _on purpose_: a mechanical completeness diff needs a stable join key,
  and text can't be it (reworded criteria change their text). Light slugs are the price of
  turning the check from a judgment into `a == b`. If you keep no-IDs, skip cross-doc
  check C1 and the diff stays fuzzy.
- **Git carries outcomes; the spine carries authored-durable data only.** No
  `status: passed` fields — the commit existing _is_ the pass (Move 1), the `done_when`
  hook enforces it. The spine holds intent/criteria/files/tags, never build results (which
  would just drift).
- **Heavy-gear only; no-op when there's no spine.** Featherweight commits (a bugfix, a
  config tweak) have no spec/plan spine; the hook sees none and passes. The validator
  never taxes the light gear.

## The data spine (three records)

**Acceptance criterion — authored in the design spec (single source of the text):**

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

**Level 3 — cross-document (the payoff; needs the spec↔plan pairing, resolved from the
spec's "Implementation Plan:" link / shared slug):**

- **C1 Completeness:** every spec `id` appears as a ledger `ref`. A missing one is a
  **silent drop** → error. _(This is the AC-ledger Step-4 guarantee, mechanized.)_
- **C2 Ref resolution:** every ledger entry with `status ∈ {design, deferred, dropped}`
  has a `ref` that exists in the spec; every `status: added` ref does **not** collide with
  a spec id (it's new).
- **C3 Coverage:** every **active** criterion (`status ∈ {design, added}`) is named by at
  least one task's `satisfies`. An active AC no task advances → error (or warn — config).
- **C4 No struck targets:** no task `satisfies` a `ref` that is `deferred`/`dropped`
  (you're building toward a criterion you said you cut).
- **C5 File sanity:** task `files` are repo-relative, no absolute paths, no `..` escape.

**Output** (human-readable, exit non-zero on any error):

```
✗ C1  spec AC not in plan ledger: ac-exit-link        (silent drop)
✗ C4  task "Add formatPrice" satisfies ac-old-preview, which is (dropped)
✗ L2  ledger ac-token-config status=added but has no text
✓ 7 AC, all accounted for · 4 tasks · 6 done_when (1 manual)
```

## Architecture — one engine, three call sites

- **CLI engine** (`validate-spine <plan.md>` — resolves its spec via the plan/spec link,
  or takes both paths). Node/TS to match firestarter's stack: `js-yaml` (parse) + `ajv`
  (schema) + ~5 cross-doc checks. ~150 lines.
- **lefthook pre-commit** → the gate. Runs the CLI on staged spec/plan files; blocks the
  commit on failure; **no-op when no spine file is staged.** This is what makes it bite
  (Move 4 / the trust-vs-gate triage realized — a hook can't be rationalized past).
- **`/plan` Step 4** → early feedback. The agent runs the CLI as it finishes; emit →
  validate → repair (red-green for the spine), so a malformed ledger never reaches you.

## Caveats / scope discipline

- **Spine ≠ thinking.** Don't let a green run feel like "the plan is good." It means
  well-formed and complete; judgment still lives in the prose and your review.
- **Keep the schema tiny** — only fields with a consumer (every field above maps to a
  check or a build action). No `priority`/`owner`/`estimate`; that's the Jira tax.
- **The agent will sometimes emit bad YAML** — that's _why_ the validator exists; pair it
  with the `/plan` repair loop, don't expect one-shot.
- **If you find yourself building a "spec framework," you've overshot.** This is a day's
  script plus a lefthook line plus a ~40-line schema. Hold it there.

## Next action

Build order, when ready: (1) the JSON Schema file (level 2); (2) the CLI engine (extract
blocks → parse → schema → C1–C5); (3) the lefthook wiring (the gate, with the no-spine
no-op); (4) the `/plan` Step-4 call + repair loop. Adopt the `yaml spine` fence convention
in the plan template and design-spec template in the same pass so existing docs grow a
spine. Featherweight gear is untouched — it has no spine, so nothing to validate.
