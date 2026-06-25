# Harness-engineering extension review

**Date:** 2026-06-23 **Method:** Four parallel review agents, each given OpenAI's "Harness
engineering: leveraging Codex in an agent-first world" doc and this workflow repo as their
_only_ two sources (no other context). Each took one lens — (1) mechanical enforcement,
(2) agent-legibility & structured docs, (3) plans as first-class artifacts & the phase
arc, (4) throughput / isolation / observability translated to a solo, in-the-loop dev.
Each was asked to propose concrete extensions grounded in a quoted harness principle and a
real file/line in this repo. Findings deduplicated and synthesized below.

**Sequel to:** `2026-06-20-workflow-cross-purpose-review.md` (which graded the skills
against CLAUDE.md's own Core Principles). This pass instead asks: where would the harness
doc's principles _extend_ the workflow? Several proposals here are reinforced by findings
in that earlier review.

**Headline:** The workflow already nails the half of the harness model that's about
_restraint_ — CLAUDE.md is a genuine table-of-contents (a map, not an encyclopedia), and
`disable-model-invocation: true` + "slash commands only" is the correct solo posture for
keeping the human in the loop. What's missing is the _enforcement_ and _indexing_ half:
the system-of-record (`docs/`) is a pair of flat, unindexed, partly broken-linked piles an
agent can only navigate by asking the user for a path, and almost every invariant is prose
convention rather than a mechanical check — including several that have already failed by
drift and are documented in `docs/issues/` and the backlog.

---

## Bugs found on disk (fix regardless of which proposals are adopted)

Cross-validated across agents, each citing specific files. These are current-state facts,
not proposals:

1. **`scripts/sync-skills.sh:4` is out of sync and breaks `learn-by-doing` globally.** The
   script syncs 4 skills (`design plan build document`); `README.md:76` promises 5.
   `learn-by-doing` is not synced — yet `learn-by-doing/SKILL.md:37` references an
   absolute `~/.claude/skills/learn-by-doing/resources/PRINCIPLES.md` that won't exist for
   anyone relying on the sync. This is the one workflow skill whose support file is
   load-bearing at runtime. Minimum fix: add `learn-by-doing` to the array (or
   auto-discover the dir).

2. **12 dead links** in `docs/changelog.md` (273, 291, 308, 326, 344, 362, …) and
   `docs/backlog.md` (19, 67) point at `design-plans/`. The directory is `design-specs/`.
   Dead links into the system-of-record. Fix: `sed` `design-plans/` -> `design-specs/`.

3. **`docs/learning/` is listed but absent.** `CLAUDE.md:14` and `README.md:51` show it;
   it's created lazily by `learn-by-doing/SKILL.md:63`. Meanwhile `docs/issues/` and
   `docs/research/` exist and are listed in neither structure block. The table-of-contents
   describes a layout the disk doesn't have. Fix: reconcile the structure blocks to disk.

4. **`allowed-tools: Read, Grep, Glob`** on every workflow skill's frontmatter (e.g.
   `build/SKILL.md:3`) is wrong — the skills write files (specs, plans, learning logs) and
   run Bash (`date`, `git branch --show-current`). Either it's unenforced (cosmetic and
   misleading to the next editor) or strict enforcement would block `/design` from writing
   its own spec. Decide whether `allowed-tools` should mean something, then make it
   honest.

5. **The relative-path convention has failed by drift twice.** Fixed in `design`/`plan`,
   silently reintroduced in `learn-by-doing`/`study-partner`
   (`docs/issues/2026-03-05-skill-relative-path-resolution.md`). A check was prototyped
   (`scripts/check-skill-paths.sh`, still whitelisted in `.claude/settings.local.json:9`)
   then demoted to backlog pending "where enforcement should live."

6. **Exec-bit history:** `sync-skills.sh` was once committed `100644`, breaking the
   `post-merge` hook with "Permission denied" on fresh pulls — "passed through all four
   workflow phases uncaught"
   (`docs/issues/2026-03-05-end-to-end-path-verification-gap.md`).

---

## Proposals (where the four lenses converged)

### P1 — Generate an `index.md` for the doc piles; have skills read it instead of asking for a path

**Highest leverage.** `docs/design-specs/` (~23) and `docs/implementation-plans/` (~22)
are unindexed piles of dated filenames. An agent handed `/build` with no path must glob
and open files, or ask the user to be the index. A `scripts/build-doc-index.sh` walks each
dir, parses header fields (`Type`, design<->plan cross-link, the plan's `Final Status`)
and emits a sorted table: date · title · type · status · linked counterpart — pure
generation, no authoring. Then change the Prerequisite blocks (`plan/SKILL.md:20-22`,
`build/SKILL.md:20-24`, `document/SKILL.md:20-26`) from "ask the user for the file path"
to "read the index, propose the most likely match, user confirms." Harness principle:
_"Design documentation is catalogued and indexed, including verification status"_ and
progressive disclosure — _"agents start with a small, stable entry point and are taught
where to look next."_ Wire the generator into `.githooks/pre-commit` so the index can't go
stale. Cost: ~1-2h for the parser; risk is header-format brittleness (mitigated by the
templates). Worth it for solo.

### P2 — Cheap pre-commit lints, each backed by a failure that already happened

`.githooks/pre-commit` currently runs only Prettier. Add: a markdown link-check (catches
bug #2's class), a skill support-path lint (bug #5 — the script is already prototyped),
and an exec-bit/shebang check (bug #6). Harness principle: _"We enforce this mechanically.
Dedicated linters... validate that the knowledge base is up to date, cross-linked, and
structured correctly"_ and _"we write the error messages to inject remediation
instructions into agent context."_ These live in the gate the human already passes on
every commit, so they need no CI. Highest cost/benefit ratio in the set — each one stops a
recurring, documented failure rather than a hypothetical. Keep them warn-or-fast-fail,
deterministic (markdown-structural, not type-checking — the insights evaluation already
ruled type-checks out of this repo).

### P3 — Make acceptance criteria executable-where-cheap, attested-where-not

`plan/templates/implementation-plan.md` Acceptance Criteria + `build/SKILL.md`'s
after-all- tasks loop. The criteria are already grep-shaped (one real plan reads "a search
of `build/SKILL.md` finds no language implying the Build Log is only written when a
deviation occurs" — that is a grep, run by hand). Give each criterion an optional
`verify:` shell one-liner that `/build` _runs_ and pastes pass/fail into the plan, instead
of only asking the user. Criteria with no feasible command stay user-attested but are
tagged `(manual)` and listed first, so machine-proven and human-asserted are visibly
distinct. Harness principle: _"By enforcing invariants, not micromanaging implementations,
we let agents ship fast."_ Real risk (heed it): Goodhart — don't let "what's checkable"
silently become "what you check." Keep `(manual)` criteria first-class so executability is
never the selection filter.

### P4 — Hard-but-overridable precondition gates on phase transitions

The Prerequisite block of each phase skill. Today they say "ask for the path"; upgrade to
a checkable precondition the skill verifies with its existing Read/Grep tools and, on
failure, prints a remediation line: `/plan` only if the design spec exists and isn't
already planned; `/build` only if the plan's Codebase Verification boxes are checked;
`/document` only if a Build Log row exists for every task. This directly addresses the
_headline_ of the 2026-06-20 review (the "no auto-advancing / one phase per session"
principle is the one most undercut by the skills). Harness principle: _"Agents are most
effective in environments with strict boundaries and predictable structure."_ Make gates
loud-but-overridable (state the violation, accept an explicit "proceed anyway"), never
hard blocks — a hard block fights "user drives" and trains reflexive overriding.

### P5 — Close the meta-loop: promote backlog lessons into checks or skill text

`docs/backlog.md` holds hard-won dogfooding rules ("5 tasks max per design," "split by
system boundary") that `/design` and `/plan` never surface mid-run — finding #12 of the
prior review, verbatim. Rule: a retro lesson isn't "done" until it's promoted into a
SKILL.md line or encoded as a check; backlog is a staging area, not a graveyard. Harness
principle: _"When documentation falls short, we promote the rule into code."_ Also wire
the orphaned `docs/learning/` log into `/document` (finding #6) so the learn-by-doing
reasoning is linked from the changelog instead of stranded.

### P6 — Codify the read-only parallel fan-out already done by hand

The 2026-06-20 cross-purpose review _was_ five parallel agents against the Core Principles
— this very document is four. Make it a repeatable `/review` skill: fan out N read-only
agents (Read/Grep/Glob, matching existing `allowed-tools`), each returning findings to the
human, who remains the sole convergence point. Harness principle: _"request additional
specific agent reviews... iterate in a loop until all agent reviewers are satisfied"_ —
translated so parallelism is confined to _observation_ and the human keeps the _decision_.
This is where a solo + in-the-loop dev gets real throughput without surrendering control.
Natural fits: `/design` Step 3 option-generation, `/plan` Step 2 codebase verification.

---

## Explicitly do NOT adopt (the solo realism check)

The harness doc's two throughput mechanisms don't transfer, and importing them would
dismantle what the workflow is built to protect:

- **Per-worktree isolation — skip for this repo.** It buys (a) concurrent branches not
  contending for one tree and (b) a per-change ephemeral app+observability stack. This
  workflow is strictly sequential, single-stream, and has no app to boot — both payoffs
  are zero. Conditional-low for downstream code repos (firestarter) only if you ever run a
  long `/build` concurrently with other work, which "user drives" discourages.

- **Minimal merge gates / unattended autonomy / automerge — skip.** The doc itself names
  the boundary: these are _"irresponsible in a low-throughput environment."_ A solo dev is
  the low-throughput environment by definition. The team's bottleneck is human QA against
  24 PRs/day; this workflow treats human judgment as the _point_, not the bottleneck.
  Adopting auto-advance / six-hour unattended runs / agent-only review would dismantle the
  one thing the workflow protects. The existing `disable-model-invocation: true` is the
  correct posture.

- **Observability — re-point at the human, don't instrument the agent.** This repo is
  almost all Markdown; there's no running app to expose via LogQL/PromQL. The real-state
  signal that matters is the Claude Code _usage_ data in `claude-code-insights/`, and its
  consumer is the human, on a cadence — run the existing evaluation rubric on each new
  export as a standing ritual, feeding P5. Agent-facing telemetry pays nothing here.

---

## What must stay convention (can't be mechanized)

- **"One phase per session"** — a session is not a git/filesystem-observable artifact; no
  hook can see session boundaries. The cross-phase half of "user drives" (_no
  auto-advance_) is _already_ mechanically enforced by `disable-model-invocation: true`;
  the per-session half can't be.
- **Intra-phase pacing** ("propose, then approve; one step at a time") — conversational
  turn-taking, no artifact to lint.
- **Staleness checks on the implementation-plan _archive_** — those are frozen records;
  linting their `file:line` citations for drift would fight "preserve the mess." Drift
  checks belong only on _living_ cross-references (CLAUDE.md, README, SKILL -> support
  files), never on the plan archive.

---

## Suggested sequence

1. **Fix the disk bugs** (an afternoon; #1 and #2 are actively broken).
2. **Pre-commit lints** (P2) — cheap, each stops a recurring documented failure.
3. **Index + skills-read-index** (P1) — the daily-driver legibility win.
4. **Criteria + gates** (P3, P4) — template/skill changes that benefit from indexing
   first.
5. **Meta-loop + `/review` skill** (P5, P6) — make the self-improvement durable.

---

## Method note / limits

The four agents read only the harness doc and this repo — no other session context — and
cited specific files/lines, which indicates first-hand reading rather than summary. Line
numbers are agent-reported and worth spot-checking before acting, but the structural
claims (the sync mismatch, the dead links, the missing/unlisted dirs, the
prose-not-mechanical gates) were consistent across independent agents. An earlier run that
also fed the agents an unrelated research spike was discarded because it anchored every
proposal toward that spike's preoccupations; this clean run surfaced the repo's _own_
documented failures instead.
