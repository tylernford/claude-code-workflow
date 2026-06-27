# Harness-engineering extension review

**Date:** 2026-06-23 **Method:** Four parallel agents, each given only two sources —
OpenAI's "Harness engineering" doc and this repo. One lens each: (1) mechanical
enforcement, (2) agent-legibility and structured docs, (3) plans as first-class artifacts,
(4) throughput/isolation/observability for a solo, in-the-loop dev. Each proposed
extensions tied to a quoted harness principle and a real file/line. Deduplicated below.

**Sequel to:** `2026-06-20-workflow-cross-purpose-review.md`, which graded the skills
against CLAUDE.md's Core Principles. This pass asks instead: where would the harness doc's
principles _extend_ the workflow? Several proposals draw on that earlier review.

**Headline:** The workflow nails the _restraint_ half of the harness model — CLAUDE.md is
a real table of contents, and `disable-model-invocation: true` plus "slash commands only"
keeps the human in the loop. Missing is the _enforcement and indexing_ half: `docs/` is
two flat, unindexed, partly broken-linked piles an agent can only navigate by asking for a
path, and nearly every invariant is prose convention, not a mechanical check — several
already failed by drift and sit in `docs/issues/` and the backlog.

---

## Proposals (where the four lenses converged)

### P1 — Generate an `index.md` for the doc piles; have skills read it instead of asking for a path

**Highest leverage.** `docs/design-specs/` (~23) and `docs/implementation-plans/` (~22)
are unindexed piles of dated filenames. An agent handed `/build` with no path must glob
and open files, or make the user the index. A `scripts/build-doc-index.sh` walks each dir,
parses header fields (`Type`, design↔plan cross-link, the plan's `Final Status`), and
emits a sorted table: date · title · type · status · linked counterpart — pure generation,
no authoring. Then flip the Prerequisite blocks (`plan/SKILL.md:20-22`,
`build/SKILL.md:20-24`, `document/SKILL.md:20-26`) from "ask for the path" to "read the
index, propose the likeliest match, user confirms." Harness principle: design docs are
catalogued and indexed with verification status, and agents start from a small stable
entry point. Wire the generator into `.githooks/pre-commit` so the index can't go stale.
Cost ~1-2h; one risk is header-format brittleness, mitigated by the templates.

### P2 — Cheap pre-commit lints, each backed by a failure that already happened

`.githooks/pre-commit` runs only Prettier today. Add a markdown link-check and a skill
support-path lint (already prototyped). Harness principle: enforce mechanically with
linters that keep the knowledge base current and cross-linked, and write error messages
that inject remediation into agent context. These ride the gate the human already passes
on every commit, so no CI. Best cost/benefit in the set — each stops a recurring,
documented failure, not a hypothetical. Keep them deterministic and warn-or-fast-fail
(markdown-structural, not type-checking — the insights evaluation already ruled
type-checks out of this repo).

### P3 — Make acceptance criteria executable-where-cheap, attested-where-not

`plan/templates/implementation-plan.md` Acceptance Criteria plus `build/SKILL.md`'s
after-all-tasks loop. The criteria are already grep-shaped — one real plan reads "a search
of `build/SKILL.md` finds no language implying the Build Log is only written when a
deviation occurs," a grep run by hand. Give each criterion an optional `verify:` shell
one-liner that `/build` runs, pasting pass/fail into the plan. Criteria with no feasible
command stay user-attested, tagged `(manual)` and listed first, so machine-proven and
human-asserted stay distinct. Harness principle: enforce invariants, don't micromanage
implementations. Real risk: Goodhart — don't let "what's checkable" quietly become "what
you check." First-class `(manual)` criteria keep executability from being the selection
filter.

### P4 — Hard-but-overridable precondition gates on phase transitions

The Prerequisite block of each phase skill. Today it says "ask for the path"; upgrade to a
precondition the skill verifies with its existing Read/Grep tools, printing a remediation
line on failure: `/plan` only if the design spec exists and isn't already planned;
`/build` only if the plan's Codebase Verification boxes are checked; `/document` only if a
Build Log row exists for every task. This addresses the headline of the 2026-06-20 review
— "no auto-advance / one phase per session" is the principle the skills most undercut.
Harness principle: agents are most effective with strict boundaries and predictable
structure. Make gates loud-but-overridable — state the violation, accept an explicit
"proceed anyway" — never hard blocks, which fight "user drives" and train reflexive
overriding.

### P5 — Close the meta-loop: promote backlog lessons into checks or skill text

`docs/backlog.md` holds hard-won dogfooding rules ("5 tasks max per design," "split by
system boundary") that `/design` and `/plan` never surface mid-run — finding #12 of the
prior review. Rule: a retro lesson isn't done until it's promoted into a SKILL.md line or
encoded as a check. The backlog is a staging area, not a graveyard. Harness principle:
when documentation falls short, promote the rule into code. Also wire the orphaned
`docs/learning/` log into `/document` (finding #6) so learn-by-doing reasoning links from
the changelog instead of stranding.

### P6 — Codify the read-only parallel fan-out already done by hand

The 2026-06-20 review was five parallel agents; this document is four. Make it a
repeatable `/review` skill: fan out N read-only agents (Read/Grep/Glob, matching existing
`allowed-tools`), each returning findings to the human, who stays the sole convergence
point. Harness principle: request additional agent reviews and iterate until reviewers are
satisfied — translated so parallelism stays confined to _observation_ and the human keeps
the _decision_. This is where a solo, in-the-loop dev gets throughput without surrendering
control. Natural fits: `/design` Step 3 option-generation, `/plan` Step 2 codebase
verification.

---

## Explicitly do NOT adopt (the solo realism check)

The harness doc's two throughput mechanisms don't transfer; importing them would dismantle
what the workflow protects.

- **Per-worktree isolation — skip.** It buys concurrent branches not contending for one
  tree, plus a per-change ephemeral app and observability stack. This workflow is
  sequential, single-stream, with no app to boot — both payoffs are zero. Conditional-low
  for downstream code repos (firestarter) only if you ever run a long `/build`
  concurrently with other work, which "user drives" discourages.

- **Minimal merge gates / automerge / unattended autonomy — skip.** The doc names the
  boundary itself: these are "irresponsible in a low-throughput environment," and a solo
  dev _is_ that environment. The team's bottleneck is human QA against 24 PRs/day; this
  workflow treats human judgment as the point, not the bottleneck. Auto-advance,
  unattended runs, or agent-only review would dismantle the one thing it protects.
  `disable-model-invocation: true` is the correct posture.

- **Observability — re-point at the human, don't instrument the agent.** This repo is
  almost all Markdown; no running app to expose via LogQL/PromQL. The signal that matters
  is the Claude Code _usage_ data in `claude-code-insights/`, consumed by the human on a
  cadence — run the existing evaluation rubric on each new export as a standing ritual,
  feeding P5. Agent-facing telemetry pays nothing here.

---

## What must stay convention (can't be mechanized)

- **"One phase per session"** — a session isn't a git/filesystem artifact; no hook sees
  session boundaries. The cross-phase half of "user drives" (no auto-advance) is already
  enforced by `disable-model-invocation: true`; the per-session half can't be.
- **Intra-phase pacing** ("propose, then approve; one step at a time") — conversational
  turn-taking, no artifact to lint.
- **Staleness checks on the implementation-plan archive** — frozen records; linting their
  `file:line` citations for drift would fight "preserve the mess." Drift checks belong
  only on _living_ cross-references (CLAUDE.md, README, SKILL → support files), never the
  archive.

---

## Suggested sequence

1. **Pre-commit lints** (P2) — cheap, each stops a recurring documented failure.
2. **Index + skills-read-index** (P1) — the daily-driver legibility win.
3. **Criteria + gates** (P3, P4) — template/skill changes that benefit from indexing
   first.
4. **Meta-loop + `/review` skill** (P5, P6) — make the self-improvement durable.

---

## Method note / limits

The four agents read only the harness doc and this repo, and cited specific files/lines —
a sign of first-hand reading, not summary. Line numbers are agent-reported, so spot-check
before acting; but the structural claims (sync mismatch, dead links, missing dirs,
prose-not-mechanical gates) held across independent agents. An earlier run that also fed
the agents an unrelated research spike was discarded — it anchored every proposal toward
that spike. This clean run surfaced the repo's own documented failures instead.
