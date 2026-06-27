# Harness-engineering adversarial review

**Date:** 2026-06-23 **Method:** Four parallel adversarial agents. Each got OpenAI's
"Harness engineering" doc, this repo, and the prior charitable review
(`2026-06-23-harness-engineering-extension-review.md`) to dismantle, taking one lens: (1)
premise, (2) process-theater, (3) throughput/leverage, (4) coherence/dogfooding. Mandate:
use the doc as a weapon, conclude the workflow should shrink or be scrapped rather than
extended, then close with where the attack overreaches. Some agents also mined the dev's
self-framing docs (`2026-05-14-interface-developer-conversation.md`,
`2026-05-14-interface-engineer-self-framing.md`) for ammunition.

**Companion to:** `2026-06-23-harness-engineering-extension-review.md`, which mined the
doc for extensions to a sound base. This one inverts the frame — where does the doc show
the workflow wrong, wasteful, or self-undermining? Read them as a pair.

**Headline:** The workflow welded a sound principle to comfort rituals and can no longer
tell them apart. The principle — _small, explicit, human-evaluated artifacts; stay in the
loop on the decision_ — is real. The rituals — _one-phase-per-session, no-git-operations,
preserve-the-mess, prose-only invariants_ — are not. The harness doc is the scalpel that
separates them, and the workflow won't pick it up. The sharper charge isn't the doc's: the
dev's own earlier writing states the harder thesis — "evaluation is the constraint; keep
artifacts small enough that evaluation stays possible" — and the workflow implements the
comfortable half (small artifacts) while skipping the expensive half: mechanical
enforcement that makes evaluation reliable, not just small.

---

## The four blades

### 1. Premise attack — control is not the same as in-the-loop

The doc keeps humans in the loop that matters (intent, acceptance criteria, validating
outcomes: _"Humans always remain in the loop, but work at a different layer of
abstraction"_) and removes them from the one that doesn't (sequencing, gating,
committing). "User drives" (`CLAUDE.md:41`) gates `git commit` — the most mechanical,
least-judgment act in the arc — and calls that taste. "One phase per session"
(`CLAUDE.md:42`) is the only Core Principle with no checkable substance; the prior review
conceded it _cannot be mechanized_. A rule that can't be enforced and only caps work
before the human resets is a comfort blanket. "No git operations" (`build/SKILL.md:107`)
spends the scarcest resource — attention — on clerical motion the doc proved delegable
(_"agents pull review feedback... push updates, and often squash and merge their own pull
requests"_).

### 2. Process-theater attack — the workflow is the manual that rots

The doc's scaffolding is a ~100-line `AGENTS.md` table-of-contents over a
mechanically-linted `docs/` tree. This workflow has a lean 55-line `CLAUDE.md` — then
hides ~1,200 lines of `.claude/skills/` and a 45-file unindexed document pile behind it.
_"Give Codex a map, not a 1,000-page instruction manual... It rots instantly. A monolithic
manual turns into a graveyard of stale rules."_ The workflow didn't avoid the manual; it
sharded it into five SKILL.md files and called the shards "phases." The tell: the ceremony
ran clean while the artifacts rotted (dead links, ghost dirs, broken sync).

The prior review's reflex — _add_ indexes, lints, gates, a `/review` skill — is wrong for
one person; the harness-aligned move is _subtractive_. Concrete cuts:

- **The 317-line `learn-by-doing` skill** — largest file in the repo, a tutoring product
  bolted onto a feature-building workflow, broken in the field: it `@`-references
  `~/.claude/skills/learn-by-doing/resources/PRINCIPLES.md`, but `sync-skills.sh:4` never
  syncs that skill, and it writes to a `docs/learning/` that doesn't exist.
- **The per-task Build Log table** (`build/SKILL.md:43,66-78`) — a drift-prone,
  hand-rolled reimplementation of `git log --stat`, maintained by hand in a workflow that
  forbids touching git. _"We prefer shared utility packages over hand-rolled helpers."_
- **~600 lines of duplicated phase boilerplate** — four near-identical "Announce Your
  Location" banners and an identical Rules footer across
  `design`/`plan`/`build`/`document`. _"Too much guidance becomes non-guidance."_ That
  copy-paste IS the drift vector — the relative-path bug failed by drift twice because it
  was hand-maintained in parallel.
- **The spec-AND-plan double-entry** — every feature, however small, gets a full design
  spec _and_ a separate plan, with acceptance criteria authored in the spec then
  re-authored in the plan, where they drift. The doc has an _ephemeral lightweight_ path;
  the workflow has none. Result: the flat pile of 45 dated, unindexed files. (One agent
  counted 56 dead `design-plans/` links, not 12.)

### 3. Throughput/leverage attack — pricing attention as if it were free

The prior review's load-bearing move — "a solo dev is the low-throughput environment by
definition," so skip worktree isolation, autonomy, observability — took ONE true asymmetry
(no second engineer to catch a bad merge) and smuggled FOUR mechanisms under it that don't
need one. The doc's _"irresponsible in a low-throughput environment"_ line covers
unattended _feature_ merges with no reviewer — not deterministic cleanup, executable
gates, or parallel isolation. Four places the leverage is real, past the prior review's
timid "read-only fan-out only":

- **Per-worktree isolation in the downstream code repos** (the MCP server, Craft sites,
  Terrazzo plugins) that actually boot apps — independent bugfixes fanned out, each in its
  own worktree, reviewed as they land. "Strictly sequential / no app to boot" is a
  self-imposed `CLAUDE.md` principle and a fact about _this_ meta-repo, not a law.
- **Autonomous contiguous build of mechanically-verifiable tasks** — when a task's "done
  when" is a passing command, the per-task human confirmation (`build/SKILL.md:47`) adds
  latency, not judgment. Let `/build` run a block unattended, pausing only on a failing
  check or a judgment-tagged task.
- **Scheduled automerging GC agents** — the repo has a documented _recurring_ drift
  problem (dead links, exec-bit, twice-reintroduced path bug). These are deterministic and
  reversible; a link-checker that can only ever change `design-plans/`→`design-specs/` is
  exactly where automerge IS safe. The prior review's flat "automerge — skip" is wrong
  here.
- **Agent-as-gate on the ~70% of sessions the dev's own data marks full-success** — there,
  human review is pure tax. Let a reviewer agent gate trivial green PRs and escalate only
  on findings. Stay the convergence point for what's flagged, not the clean majority.

The personal edge (from the dev's own transcripts, not invented): "taste is where the
human lives" was flagged _by Claude, in that transcript_, as smuggling preciousness.
Reading every clean diff at human pace is "throughput on already-decided work" — the
obsolescence risk the dev diagnosed. "I deliberately stay in the loop" caps output and
scales personal relevance in one stroke; that coincidence is the tell.

### 4. Coherence/dogfooding attack — the loop is open, and the git tree proves it

The workflow claims it's "built and improved using this same system." Its own record says
the loop mostly doesn't close:

- **The exec-bit bug has a full written post-mortem**
  (`docs/issues/2026-03-05-end-to-end-path-verification-gap.md`) — and `sync-skills.sh` is
  _still `100644` on disk today_, three months and two reviews later. The post-mortem was
  the deliverable; the patch never landed.
- **Two bugs "passed through all four workflow phases uncaught"** (the workflow's own
  phrase, in two issue files). The four phases are four prose checklists with no
  mechanical floor; the build "done when" was satisfied by `bash sync-skills.sh`, which
  never exercises the `+x` path the hook actually uses. The phase passed while the feature
  was broken.
- **"Promote the rule into code" run in reverse** — a `check-skill-paths.sh` was built,
  then _demoted back to backlog_, leaving a dangling permission grant in
  `settings.local.json:9` for a script that no longer exists. The twice-failed convention
  is again guarded by the prose that already failed twice.
- **Backlog lessons never reach the skills** — "5 tasks max per design," "split by system
  boundary" sit in `backlog.md`; `grep` confirms they appear nowhere in `.claude/skills/`.
  _"Human taste is... captured as documentation updates OR encoded directly into tooling"_
  — the workflow does the first clause and stops.
- **`/document` was caught marking acceptance criteria it never verified** (commit `#33`)
  — derive-from-real-state violated at the source; the phase whose job is faithful history
  was manufacturing it. (The 2026-06-20 review's "document sanitizes backward," confirmed
  at the commit level.)

---

## Where the attacks overreach (all four agents conceded this, consolidated)

- **Different objective function.** The doc's deliverable is a shipping product with
  pulling users; this workflow's is clearer thinking and a legible perspective the dev
  alone maintains. Against that yardstick throughput is the wrong metric, and the doc
  concedes its results _"should not be assumed to generalize."_ The doc relocates the
  human; it doesn't retire them.
- **Sole maintainer => understanding is load-bearing.** The harness team optimized for
  _Codex's_ legibility over human understanding because a team + agent fleet maintains it.
  The dev is the only one who'll debug and live with the result. Autonomy that routes
  around understanding degrades the evaluator every leverage gain depends on. For
  novel/high-stakes code, in-the-loop is sound engineering, not comfort.
- **"Corrections are cheap" assumes scaffolding the dev hasn't built.** Their corrections
  are cheap because of layered catching — type-checks, custom linters, structural tests,
  agent AND human reviewers. A solo dev has none of that redundancy. The leverage is only
  as safe as the gate behind it — autonomy without the machine is a wall of plausible
  output hitting a tired person, the failure the dev's own thesis names (volume → fatigue
  → giving in).
- **The work is mostly decision-bound, not throughput-bound.** Their 1,500 PRs were
  _demanded_ by real user load. The dev's binding constraint on most work is "what should
  this be," and for that in-the-loop IS the correct speed. Much of the leverage attack
  imports a throughput-bound world that doesn't describe the dev's problem shape.
- **The restraint half is real and correct.** `CLAUDE.md` is a genuine table-of-contents,
  not an encyclopedia. `disable-model-invocation: true` is the one real mechanical
  invariant and the right solo posture. Per-worktree isolation and minimal-merge-gate
  autonomy genuinely don't transfer to this single-stream Markdown meta-repo.
- **The dogfooding loop is not pure fiction.** It closes sometimes: the two review docs
  exist and are honestly self-critical; the `#34` "design-spec file-list hedge" fix is the
  loop working — a false premise checked against 16 real design→plan→build trios (94-96%
  accurate) and overridden by reality. The honest reframing of "built and improved using
  this same system": _examined_ using it, _occasionally improved_, with an open loop where
  the most-documented failures survive every retrospective.

---

## The honest synthesis

**Right about the seat, wrong to defend the whole chair.** Staying in the loop is correct
engineering for _the decision_ and for _novel/high-stakes code the dev will maintain_.
It's not obviously correct for the deterministic, already-decided, mechanically-verifiable
majority — GC, link-checks, type-checked builds, green PRs, doc reindexing — which is
exactly where the leverage (and the relevance) sits unclaimed. The workflow let "I
evaluate the decisions" quietly expand into "I gate every change's existence"; the
adversarial read is that the second clause is comfort, not principle.

The structural companion, from the process-theater lens: for one person the additive
instinct (extend, index, lint MORE — the charitable review's whole prescription) may be
backwards. The harness lesson at solo scale might be _delete_ — shrink the skills, drop
the double-entry, cut the broken tutoring skill — and keep one cheap mechanical floor (a
pre-commit link/exec-bit check) that was already one `grep` away, prototyped, and
abandoned.

What survives every attack: _small, explicit, human-evaluated artifacts on the decisions;
the map (`CLAUDE.md`); the one real gate (`disable-model-invocation`); one durable ledger
(`changelog`)._ What doesn't: everything fused to that core — one-phase-per-session,
no-git, prose-only invariants, preserve-the-mess-as-virtue, and the per-feature ceremony.
The doc's contribution isn't "remove the human." It's the scalpel that separates principle
from ritual — and the workflow hasn't picked it up.

---

## Method note / limits

Agents verified bug claims against the live working tree as of 2026-06-23 — the exec-bit
`100644`, the 14-56 dead links, the missing `check-skill-paths.sh`, and the un-folded
backlog lessons were re-confirmed on disk, not taken from the prior review. Line numbers
are agent-reported; the structural and self-contradiction claims held across independent
agents. This is an adversarial brief by construction — it argues the case in the body and
confines counter-evidence to the "overreach" section by design. Weigh it against its
charitable companion, not on its own.
