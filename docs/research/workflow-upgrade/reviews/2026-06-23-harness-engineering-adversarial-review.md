# Harness-engineering adversarial review

**Date:** 2026-06-23 **Method:** Four parallel ADVERSARIAL agents, each given OpenAI's
"Harness engineering" doc, this workflow repo, AND the prior charitable review
(`2026-06-23-harness-engineering-extension-review.md`) as a target to dismantle. Each took
one attack lens — (1) the premise attack, (2) the process-theater attack, (3) the
throughput/leverage attack, (4) the coherence/dogfooding attack. Mandate: do NOT be
charitable; use the harness doc as a weapon; be willing to conclude parts of the workflow
should be shrunk or scrapped, not extended; then close with an honest "where the attack
overreaches." Several agents independently read the dev's own self-framing docs
(`2026-05-14-interface-developer-conversation.md`,
`2026-05-14-interface-engineer-self-framing.md`) and used them as ammunition.

**Companion to:** `2026-06-23-harness-engineering-extension-review.md`. That review took
the workflow as a sound base and mined the doc for extensions. This one inverts the frame:
it asks where the doc shows the workflow to be wrong, wasteful, or self-undermining. Read
them as a charitable/adversarial pair.

**Headline:** The workflow has welded a sound principle to a set of comfort rituals and
can no longer tell which is which. The sound principle — _small, explicit, human-evaluated
artifacts; stay in the loop on the decision_ — is real and defensible. The rituals fused
to it — _one-phase-per-session, no-git-operations, preserve-the-mess, prose-only
invariants_ — are not. The harness doc is the scalpel that separates them; the workflow
has refused to pick it up. The most important version of this charge is not the doc's: the
dev's _own_ earlier writing already contains the harder, correct thesis ("evaluation is
the constraint — keep artifacts small enough that evaluation stays possible"), and the
workflow implements only its comfortable half (small artifacts) while skipping the
expensive half the doc insists on (mechanical enforcement that makes evaluation reliable,
not merely small).

---

## The four blades

### 1. Premise attack — control is not the same as in-the-loop

The doc keeps humans in the loop that matters (intent, acceptance criteria, validating
outcomes: _"Humans always remain in the loop, but work at a different layer of
abstraction"_) while removing them from the loop that doesn't (sequencing, gating,
committing). "User drives" (`CLAUDE.md:41`) gates `git commit` — the most mechanical,
least-judgment act in the arc — and calls that taste. "One phase per session"
(`CLAUDE.md:42`) is the only Core Principle with no checkable substance; the prior review
conceded it _cannot be mechanized_. A rule that can't be enforced and exists only to cap
how much happens before the human resets is a comfort blanket, not a design choice. "No
git operations" (`build/SKILL.md:107`) burns the scarcest resource — attention — on the
clerical motion the doc proved is fully delegable (_"agents pull review feedback... push
updates, and often squash and merge their own pull requests"_).

### 2. Process-theater attack — the workflow is the manual that rots

The doc's scaffolding is a ~100-line `AGENTS.md` table-of-contents over a
mechanically-linted `docs/` tree. This workflow has a genuinely lean 55-line `CLAUDE.md` —
and then hides ~1,200 lines of `.claude/skills/` and a 45-file unindexed document pile
behind it. _"Give Codex a map, not a 1,000-page instruction manual... It rots instantly. A
monolithic manual turns into a graveyard of stale rules."_ The workflow didn't avoid the
manual; it sharded it into five SKILL.md files and called the shards "phases." Proof it's
theater, not function: the ceremony ran clean while the artifacts rotted (dead links,
ghost dirs, broken sync).

The prior review's reflex — _add_ indexes, lints, gates, a `/review` skill — is the wrong
reflex for one person; the harness-aligned move is _subtractive_. Concrete cuts proposed:

- **The 317-line `learn-by-doing` skill** — largest file in the repo, a tutoring product
  bolted onto a feature-building workflow, and broken in the field: it `@`-references
  `~/.claude/skills/learn-by-doing/resources/PRINCIPLES.md` but `sync-skills.sh:4` never
  syncs that skill, and it writes to a `docs/learning/` that doesn't exist.
- **The per-task Build Log table** (`build/SKILL.md:43,66-78`) — a hand-rolled,
  drift-prone reimplementation of `git log --stat`, maintained by hand in a workflow that
  forbids touching git. _"We prefer shared utility packages over hand-rolled helpers."_
- **~600 lines of duplicated phase boilerplate** — four near-identical "Announce Your
  Location" banners and an identical copy-pasted Rules footer across
  `design`/`plan`/`build`/ `document`. _"Too much guidance becomes non-guidance."_ That
  copy-paste IS the drift vector (the relative-path bug failed by drift twice because it
  was hand-maintained in parallel).
- **The spec-AND-plan double-entry** — every feature, however small, gets a full design
  spec _and_ a separate implementation plan, with acceptance criteria authored in the spec
  then re-authored in the plan, where they drift. The doc has an _ephemeral lightweight_
  path for small changes; the workflow has no lightweight path. Result: the flat pile of
  45 dated, unindexed files. (One agent counted 56 dead `design-plans/` links, not 12.)

### 3. Throughput/leverage attack — pricing attention as if it were free

The prior review's load-bearing move — "a solo dev is the low-throughput environment by
definition," therefore skip worktree isolation, autonomy, and observability — took ONE
true asymmetry (no second engineer to catch a bad merge) and smuggled FOUR mechanisms
under it that don't depend on a second engineer. The doc's _"irresponsible in a
low-throughput environment"_ line covers unattended _feature_ merges with no reviewer; it
does not cover deterministic cleanup, executable gates, or parallel isolation. Four places
the leverage is real, past the prior review's timid "read-only fan-out only":

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
- **Agent-as-gate on the ~70% of sessions the dev's own data marks full-success** — for
  those, human review is pure tax; let a reviewer agent gate trivial green PRs and
  escalate only on findings. Stay the convergence point for what's flagged, not for the
  clean majority.

The personal edge (the agents drew it from the dev's own transcripts, not invented):
"taste is where the human lives" was flagged _by Claude, in that transcript_, as smuggling
preciousness. Reading every clean diff at human pace is "throughput on already-decided
work" — the exact thing the dev diagnosed as the obsolescence risk. "I deliberately stay
in the loop" caps output and scales personal relevance in the same stroke; that
coincidence is the tell.

### 4. Coherence/dogfooding attack — the loop is open, and the git tree proves it

The workflow claims it is "built and improved using this same system." Its own record says
the loop mostly doesn't close:

- **The exec-bit bug has a full written post-mortem**
  (`docs/issues/2026-03-05-end-to-end- path-verification-gap.md`) — and `sync-skills.sh`
  is _still `100644` on disk today_, three months and two reviews later. The post-mortem
  was the deliverable; the patch never landed.
- **Two bugs "passed through all four workflow phases uncaught"** (the workflow's own
  phrase, in two separate issue files). The four phases are four prose checklists with no
  mechanical floor; the build "done when" was satisfied by `bash sync-skills.sh`, which
  never exercises the `+x` path the hook actually uses. The phase passed while the feature
  was broken.
- **"Promote the rule into code" run in reverse** — a `check-skill-paths.sh` was built,
  then _demoted back to backlog_, leaving a dangling permission grant in
  `settings.local.json:9` for a script that no longer exists. The twice-failed convention
  is again guarded by nothing but the same prose that already failed twice.
- **Backlog lessons never reach the skills** — "5 tasks max per design," "split by system
  boundary" sit in `backlog.md`; `grep` confirms they appear nowhere in `.claude/skills/`.
  _"Human taste is... captured as documentation updates OR encoded directly into tooling"_
  — the workflow does the first clause and stops.
- **`/document` was caught marking acceptance criteria it never verified** (commit `#33`)
  — the derive-from-real-state discipline violated at the source; the phase whose job is
  faithful history was manufacturing it. (The 2026-06-20 review's "document sanitizes
  backward," confirmed at the commit level.)

---

## Where the attacks overreach (all four agents conceded this, consolidated)

- **Different objective function.** The doc's deliverable is a shipping product with
  pulling users; this workflow's is clearer thinking and a legible perspective the dev
  alone maintains. Against that yardstick throughput is the wrong metric, and the doc
  concedes its results _"should not be assumed to generalize."_ The doc relocates the
  human; it does not retire them.
- **Sole maintainer => understanding is load-bearing, not optional.** The harness team
  explicitly optimized for _Codex's_ legibility over human understanding because a team +
  agent fleet maintains it. The dev is the only person who will debug and live with the
  result. Autonomy that routes around understanding degrades the evaluator every leverage
  gain depends on. For novel/high-stakes code, in-the-loop is sound engineering, not
  comfort.
- **"Corrections are cheap" is a conclusion of scaffolding the dev hasn't built.** Their
  corrections are cheap because of layered catching (type-checks, custom linters,
  structural tests, agent reviewers AND human reviewers). A solo dev has none of that
  redundancy. The leverage is only as safe as the gate behind it, and not an inch further
  — autonomy without the machine is an unsupervised wall of plausible output hitting a
  tired person, the precise failure the dev's own thesis names (volume -> fatigue ->
  giving in).
- **The work is mostly decision-bound, not throughput-bound.** Their 1,500 PRs were
  _demanded_ by real user load. The dev's binding constraint on most work is "what should
  this be," and for that, in-the-loop IS the correct speed. Much of the leverage attack
  imports a throughput-bound world that doesn't describe the dev's actual problem shape.
- **The restraint half is real and correct.** `CLAUDE.md` is a genuine table-of-contents,
  not an encyclopedia. `disable-model-invocation: true` is the one real mechanical
  invariant and the right solo posture. Per-worktree isolation and minimal-merge-gate
  autonomy genuinely don't transfer to this single-stream Markdown meta-repo.
- **The dogfooding loop is not pure fiction.** It closes sometimes: the two review docs
  exist and are honestly self-critical; the `#34` "design-spec file-list hedge" fix is a
  real instance of the loop working — a false premise checked against 16 real
  design->plan->build trios (94-96% accurate) and overridden by reality. The system
  self-examines and occasionally self-corrects. The honest reframing of "built and
  improved using this same system" is: _examined_ using it, _occasionally improved_, with
  an open loop where the most-documented failures survive every retrospective.

---

## The honest synthesis

**Right about the seat, wrong to defend the whole chair.** Staying in the loop is correct
engineering for _the decision_ and for _novel/high-stakes code the dev will maintain_. It
is not obviously correct for the deterministic, already-decided, mechanically-verifiable
majority — GC, link-checks, type-checked builds, green PRs, doc reindexing — which is
exactly where the leverage (and the relevance) sits unclaimed. The workflow let "I
evaluate the decisions" quietly expand into "I gate every change's existence," and the
adversarial read is that the second clause is the comfort, not the principle.

The structural companion to that, from the process-theater lens: for one person the
additive instinct (extend, index, lint MORE — the charitable review's whole prescription)
may be backwards. The harness lesson at solo scale might be _delete_ — shrink the skills,
drop the double-entry, cut the broken tutoring skill — and keep exactly one cheap
mechanical floor (a pre-commit link/exec-bit check) that was already one `grep` away,
prototyped, and abandoned.

What survives every attack: _small, explicit, human-evaluated artifacts on the decisions;
the map (`CLAUDE.md`); the one real gate (`disable-model-invocation`); one durable ledger
(`changelog`)._ What does not survive: everything the workflow has fused to that core —
one-phase-per-session, no-git, prose-only invariants, preserve-the-mess-as-virtue, and the
per-feature ceremony. The doc's contribution isn't "remove the human." It's the scalpel
that separates the principle from the ritual — and the workflow has not yet picked it up.

---

## Method note / limits

The four agents read the doc, the repo, the prior review, and (unprompted) the dev's own
self-framing transcripts, verifying bug claims against the live working tree as of
2026-06-23 (the exec-bit `100644`, the 14-56 dead links, the missing
`check-skill-paths.sh`, the un-folded backlog lessons were all re-confirmed on disk, not
taken from the prior review). Line numbers are agent-reported; the structural and
self-contradiction claims were consistent across independent agents. This is an
adversarial brief by construction — it argues the case in the body and confines the
counter-evidence to the "overreach" section by design; weigh it against its charitable
companion, not on its own.
