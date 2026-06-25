# Build Phase — Move 1: Approve-by-Exception + Executable `done_when`

**Created:** 2026-06-25 **Implementation Plan:** [link to implementation plan]

---

## Overview

**What:** Rework the single-agent `/build` phase so it stops pausing for approval after
every task, verifies each task with an executable check where one is feasible, surfaces
the real work for one loaded-in review at the end, and lets `git` be the handoff to
`/document` instead of a hand-maintained Build Log table.

**Why:** Finishing a full design→plan→build→document cycle leaves the developer tired, and
during `/build` the per-task approvals have decayed into "auto-yeses." An auto-yes gate
has stopped evaluating and started pacing — it is _worse_ than no gate, because it feels
supervised (false confidence) while training the reflex that waves the one real error
through. `/build` is almost entirely procedural (execution of work already decided in
design and plan), which is exactly why it became almost entirely auto-yes. This change
relocates the one real review to the end, replaces the reflexive stamps with checks that
don't get tired, and stops hand-transcribing what git already holds. Guiding principle:
**gate decisions, not procedures; mechanize the floor so it doesn't need you; match
ceremony to stakes.**

**Type:** Process

---

## Scope

This spec is **Move 1** of the workflow upgrade path — the single-agent `/build` changes.

**Explicitly deferred to a later session (Move 1.5 — the orchestrator):** turning `/build`
into an orchestrator that dispatches build/verifier subagents and loops them. Where Move 1
makes a known compromise because it is single-agent, the spec says so and points at 1.5.

### Two verification layers (keep distinct — they are not the same thing)

| Layer         | What it is                                                                                                                                       | When it runs           | What Move 1 changes                                                                                                                                                   |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Task done** | A task's per-task `done_when` passed — its resolved command exits 0, or it is noted `(manual)`. The per-task floor.                              | During each task.      | `done_when` becomes intent (locked in plan) + command (resolved at build), with `(manual)` first-class.                                                               |
| **AC done**   | The plan's **active** acceptance-criteria ledger verified — the final check/review, the loaded-in human pass. The gate for completing the phase. | Once, at end of batch. | The interactive per-item loop is replaced by an automatic run of active executable items + one human review; the live AC carry-forward ledger is preserved untouched. |

A task being "done" never implies the feature's acceptance criteria are met. **AC done is
a separate, end-of-batch judgment.**

---

## Requirements

### Must Have

- [ ] **§0.1** `allowed-tools` in `build/SKILL.md` and `document/SKILL.md` declares
      `Read, Grep, Glob, Write, Edit, Bash`; `disable-model-invocation: true` is preserved
      in both.
- [ ] **§0.2** The no-git rule is narrowed **in place** in both skills: `/build` may read
      git and commit a completed task on the **current branch only**, staging the files
      that task **actually changed** by **explicit path** (never `git add -A`) — normally
      the declared set, plus any undeclared file a deviation legitimately touched, each
      added by path and noted (see §4); a surprising or out-of-scope touch escalates
      rather than being staged silently. `/document` may read git only (never commits).
      Both still forbid push, force-push, rebase, reset, branch deletion, and any remote
      op.
- [ ] **§1** `/build` no longer pauses per task. Default is **proceed**; the agent
      escalates to the user only on a check still failing after the three-round cap
      (Decision 7), a genuine plan ambiguity, or an irreversible/out-of-scope action. The
      Rules section reflects this (sequential execution ≠ per-task approval gate;
      approve-by-exception).
- [ ] **§1** The verify→fix→re-run cycle is bounded at **three attempts** per task's
      check; on the third consecutive failure, `/build` stops and escalates to the user
      with the failing output.
- [ ] **§2** Per-task `done_when` is split into **intent** (locked in the plan) and
      **command** (resolved at build against the real repo, never lifted verbatim from the
      plan). The plan template carries intent + an optional candidate command marked as a
      guess. At build, `/build` resolves each intent to a real command, runs it (exit 0 is
      the gate), and re-resolves if it deviated mid-task.
- [ ] **§2** Intents with no feasible command stay `(manual)`, are listed first, and are
      never silently dropped. A command that proves only a shallow proxy is recorded as
      **"compiles, behavior unverified,"** not counted as done.
- [ ] **§2 (forward-compat)** If the plan template's `Done when:` is written as a
      structured block, its field names match the spine validator's schema so adopting the
      spine later is additive, not a rewrite: each item is an `intent` plus exactly one of
      `command:` (the candidate, re-resolved at build) or `manual: true`. Build-time
      outcomes — pass/fail, "compiles, behavior unverified" — are recorded by `/build` in
      git, never authored into the block. Whether the field is structured or looser prose
      is `/plan`'s call; only the names are fixed here. See
      `docs/research/workflow-upgrade/2026-06-25-spine-validator.md`.
- [ ] **§3** `<base>` is defined once near the top of `build/SKILL.md` as
      `git rev-parse HEAD` snapshotted at the start of the build session, and referenced
      by the end-of-batch review (§3 depends on it).
- [ ] **§3** After all tasks, `/build` presents the batch **once** for one loaded-in human
      review over `<base>..HEAD`, where `<base>` is `git rev-parse HEAD` snapshotted at
      the start of the build session. The handoff surfaces: deviations first, `(manual)`
      items separately, verified-vs-just-compiled per task, and test-file diffs
      explicitly.
- [ ] **§3** The acceptance-criteria gate runs the plan's **active (unstruck)**
      `(design)`/`(added)` items' executable checks automatically and presents `(manual)`
      ones to the user; struck `(deferred)`/`(dropped)` items are recorded, not verified.
      `/build` remains the sole authority for marking `[x]`. The live AC carry-forward
      ledger mechanism is preserved unchanged.
- [ ] **§4** The per-task Build Log table is removed from `build/SKILL.md`, the plan
      template, and `document/SKILL.md`. Deviation rationale lives in the **commit body**.
      "Handling Deviations" also covers the staging case: a deviation that touches an
      **undeclared** file stages that file by explicit path and records it (file + why) in
      the commit body, or escalates if the touch is out-of-scope — never silently dropped.
- [ ] **§4** `/document` is repointed at git: Step 1 reads `git log`/`git log --stat`
      `<base>..HEAD` and commit bodies for the narrative, files, and deviation rationale;
      the changelog "Key files" and the PR draft "Changes" source from `git log --stat`.

### Nice to Have

- None for this spec.

### Out of Scope

- **Move 1.5** — the orchestrator (dispatch + review loop), build/verifier subagents,
  model tiering, the honesty-gate ritual (`verification-before-completion` / Iron Law),
  the builder-write-lockout machinery (Guard 4). Deferred to a separate session.
- The **acceptance-criteria carry-forward mechanism** itself — already shipped (commit
  `3c3c0d8`); this spec integrates with it but does not modify it.
- **Move 2** (lightweight gear), **Move 3b** (lift the Rules footer/banners into
  `CLAUDE.md` — the no-git rule is edited in place per file here), **Move 4** (pre-commit
  link/exec-bit checks), **Move 5** (learn-by-doing).
- Any durable cross-session build state / crash recovery (the git backstop) — a Move 1.5
  concern.

---

## Design Decisions

### Decision 1 — Single-agent command resolution (accepting a known weakening)

**Options considered:**

1. **Defer executable `done_when` entirely to 1.5**, where a true not-the-builder resolves
   the command — preserves the full anti-gaming property but ships none of the floor now.
2. **`/build` resolves the command itself, from the locked intent, against the repo,
   before it implements** — gets the mechanized floor now, but the resolver and the doer
   are the same agent, so it could still tailor an easy command.

**Decision:** Option 2. The intent stays the anti-gaming anchor (it can't be tailored to
whatever got built and survives every deviation unchanged); the command is resolved from
that intent against reality, never lifted verbatim from the plan. The true author/doer
separation is a Move 1.5 property; Move 1 takes the floor and labels the compromise.

### Decision 2 — Honest `allowed-tools` (not cosmetic)

**Options considered:**

1. **Leave `Read, Grep, Glob`** — accept that every `done_when` command, `git diff`, and
   `git commit` prompts the user.
2. **Add `Write, Edit, Bash`** — pre-approve what the skill already does plus what Move 1
   adds.

**Decision:** Option 2. `allowed-tools` is a pre-approval list; tools not on it prompt.
The current line is already inaccurate (the skill writes files and runs
`date`/`git branch` today). Under approve-by-exception, un-pre-approved Bash would rebuild
the per-task friction we are deleting — relocated from "Anything to note?" to "Allow this
Bash command?" Making it honest is what makes "stop pausing per task" actually feel like
not pausing.

### Decision 3 — `/build` commits, `/document` reads only (intentional asymmetry)

**Options considered:**

1. **User remains sole committer** — leaves the per-task commit a manual action and a lump
   working tree that's harder to commit cleanly.
2. **Agent commits on the feature branch with a leash** — `/build` commits each completed
   task on the current branch, staging only the files that task declares.

**Decision:** Option 2, scoped tightly. `/build` commits; `/document` only reads git (the
user still commits the doc updates at Phase Complete). The leash: current branch only,
**explicit-path staging only** (never `git add -A`), never
push/force/rebase/reset/branch-delete/remote. This removes the human from the per-task
loop and produces clean per-task commits, which is what makes deleting the Build Log safe
— git becomes the honest handoff. "User drives" governs decisions and phase transitions,
not who types `git commit`.

**The staging boundary cuts both ways.** Explicit-path staging prevents _over_-staging
(sweeping in a stray file or secret via `-A`). The mirror hazard is _under_-staging: a
task declares `[A, B]`, deviates, and also modifies `C` — staging only the declared set
silently drops `C`, leaving a dirty tree the next task's commit may wrongly swallow or
that is simply lost. So the rule is **stage the files the task actually changed**, by
explicit path: the declared set _plus_ any undeclared file the deviation legitimately
touched, each added by path and recorded in the commit body (file + why). A touched file
that is _surprising_ or out-of-scope is an escalation (§1), not a silent add. "Declared
files only" is the common case, not the literal rule — the literal rule is "explicit paths
for what this task changed, nothing more, nothing dropped."

### Decision 4 — `<base>` = session-start `HEAD` snapshot

**Options considered:**

1. **Session-start HEAD snapshot** (`git rev-parse HEAD` at skill start) — scopes the diff
   to exactly this session's commits, no dependency on the trunk's name; but it is
   in-session state that a multi-session/crash build must re-derive.
2. **Merge-base with trunk** (`git merge-base HEAD main`) — stateless and crash-proof, but
   folds the design-spec and plan commits (also on the feature branch) into a code review,
   and needs to know the trunk name.

**Decision:** Option 1. The end-of-batch review wants the build's code, cleanly scoped,
and the snapshot is one line. The multi-session/crash caveat is small
(one-phase-per-session by design; durable crash recovery is a Move 1.5 concern) and
forward-compatible — 1.5 will want the base SHA recorded durably anyway. Fallback for a
resumed build: re-snapshot and note in the review that the diff covers only this session's
commits.

### Decision 5 — End-of-batch review integrates with the live AC ledger (not the draft's loop)

**Options considered:**

1. **Replace the acceptance loop wholesale** with the 2026-06-23 draft's "one review" —
   but the draft predates the AC carry-forward ledger that has since landed.
2. **Integrate** — run the **active (unstruck)** items' executable checks automatically,
   present `(manual)` ones to the user, preserve active-vs-struck and `/build`-as-sole-
   checkbox-authority.

**Decision:** Option 2. The ledger (commit `3c3c0d8`) is the current source of truth for
acceptance criteria; Move 1's end-of-batch review layers the auto-run + one-human-review
on top of it. Under approve-by-exception, the old "Ask user: run acceptance criteria?"
prompt is dropped — the checks just run; the human review is the real gate.

### Decision 6 — Honesty gate (Iron Law) deferred to 1.5

**Decision:** Move 1 runs the executable check but does **not** add the
`verification-before-completion` ritual (the "if you haven't run the check in this message
you can't claim it passes" gate). It is most valuable paired with the orchestrator's
subagent boundary and is folded in with 1.5.

### Decision 7 — A three-round cap on verify→fix, now (not deferred)

**Options considered:**

1. **No formal cap in Move 1** — the agent self-bounds by judgment, escalates when stuck.
   Leaves "a failed check it can't resolve" undefined and a single agent free to grind or
   loop with no hard bound.
2. **Adopt a bare three-round cap now** — bound the verify→fix→re-run cycle at 3 attempts
   per task's check; on the 3rd consecutive failure, stop and escalate to the user with
   the failing output.

**Decision:** Option 2. The bare round cap is simple enough to stand alone single-agent —
it needs none of the orchestrator's structure. It makes "a failed check it can't resolve"
(§1) concrete: **still failing after 3 attempts**, _or_ the earlier judgment cases (no
plausible next fix, ambiguous failure, the agent repeating itself). On exceeding the cap,
escalate — an approve-by-exception event, not a hang. This adopts only the **count and the
escalate**, not the orchestrator's richer loop mechanics; **deferred to 1.5:** the carried
prior-issue list, silence-≠-fixed re-review tracking, verbatim durable findings store, and
context-limit chunking — those belong with the multi-subagent review loop.

### The surrogation risk (recorded, watch on first run)

Gating on a check does not _kill_ the auto-yes; it _moves_ it. The single biggest risk
(surrogation: "the check passed" silently replacing "the work is actually done") is the
same disease this upgrade started from, relocated and wearing a green checkmark. Two
consequences to hold: (1) the end-of-batch human review must stay a _real_ evaluation, not
a rubber stamp on "all green"; (2) a shallow `done_when` trusted as full proof is
surrogation in miniature — the "compiles, behavior unverified" label must stay honest. The
tell to watch for on the first real run: the moment "did it pass?" replaces "is it right?"
in your own head.

---

## Acceptance Criteria

- [ ] `build/SKILL.md` and `document/SKILL.md` frontmatter list
      `Read, Grep, Glob, Write, Edit, Bash` and retain `disable-model-invocation: true`.
- [ ] `build/SKILL.md` Rule 7 and `document/SKILL.md` Rule 5 are the narrowed forms
      (read-only git everywhere; `/build` commits current-branch/declared-files-only; no
      remote/history ops; `/document` never commits).
- [ ] `build/SKILL.md` "For Each Task" has no per-task pause; it resolves the check before
      implementing, runs the resolved command (exit 0 = gate), commits declared files with
      a deviation note in the body, and proceeds — with an explicit escalate-by-exception
      clause.
- [ ] `build/SKILL.md` Rules read "Sequential execution" (not "One task at a time") and
      "Approve by exception" (not "User confirms"); the "Update Build Log" rule is
      removed.
- [ ] `build/SKILL.md` bounds the verify→fix cycle at three attempts and escalates on the
      third failure (Decision 7).
- [ ] The plan template's per-task `Done when:` is the intent + optional candidate-command
      form, with `(manual)` representable and, if structured, field names matching the
      spine schema (`intent` + exactly one of `command:`/`manual: true`); the Build Log
      table section is removed.
- [ ] `build/SKILL.md` "After All Tasks" presents the batch once over `<base>..HEAD`
      (diff + commit list, deviations first, `(manual)` separately, verified-vs-compiled,
      test-file diffs surfaced), then runs active executable AC and presents `(manual)`
      AC; `<base>` is defined once near the top of the skill.
- [ ] `build/SKILL.md` "Handling Deviations" routes the why to the commit body, not a
      Build Log row; Phase Complete drops the "Build Log updated in:" line.
- [ ] A deviation that touches an undeclared file results in that file being staged (by
      explicit path) and noted in the commit body, or escalated — never left as a silent
      dirty-tree drop. No path is ever staged via `git add -A`.
- [ ] `document/SKILL.md` Step 1 sources from `git log`/`git log --stat` `<base>..HEAD`
      and commit bodies; the "Review Build Log" step is gone; changelog "Key files" and
      PR-draft "Changes" source from `git log --stat`.
- [ ] **Validation run:** one real `/build` against a small plan completes end-to-end —
      proceeds without per-task pauses, runs at least one executable `done_when`, commits
      per task with explicit-path staging, and presents a coherent end-of-batch review.
      The escalation triggers are tuned from what it actually interrupts on. **This run is
      also the design input for Move 1.5 and the evidence for the two deferred questions**
      — so capture, not just "it worked":
  - **How the batch review actually felt** — a real evaluation or a rubber-stamp on "all
    green"? This is the surrogation tell, and the central design input for 1.5's batch
    handoff (what to surface so the review stays real).
  - **The manual-rate** — what fraction of checks landed `(manual)` vs executable, and
    whether the `(manual)`-first / verified-vs-just-compiled surfacing actually kept those
    items out of the green.
  - **`done_when` resolution behavior** — did build-time command resolution catch real
    drift (the empirical doc's KIND 1), or did the single agent tailor itself an easy
    command (the Decision 1 compromise biting)?
  - **Where the absent round cap / loop bounds were felt** — grinding, looping, or fine.
  - These feed: the **outcome-vs-procedure gate** question (did outcome-gating let
    Minor-grade rot through?) and the **trust-vs-gate** question (which prose "MUSTs" held
    vs. got violated and want mechanizing) — both explicitly waiting on this first run.

---

## Suggested Files to Create/Modify

> Non-binding starting point. `/plan` re-verifies these against the codebase in its Step 2
> and owns the final paths.

```
.claude/skills/build/SKILL.md                      # §0 frontmatter+rule; §1 loop+rules;
                                                   #   §2 verify step; §3 end-of-batch;
                                                   #   §4 deviations, drop Log/table refs
.claude/skills/document/SKILL.md                   # §0 frontmatter+rule; §4 git-sourced
                                                   #   Step 1, changelog, PR draft
.claude/skills/plan/templates/implementation-plan.md  # §2 intent/candidate done_when;
                                                   #   §4 remove Build Log table
```

### Order of operations (for `/plan`)

1. §0 first (frontmatter + narrowed git rule in both skills) — nothing else is real until
   this.
2. `build/SKILL.md` — §1 (loop + rules), §3 (end-of-batch review), §4 (deviations, drop
   Log step + table refs, Phase Complete line).
3. `plan/templates/implementation-plan.md` — §2 (intent/candidate `done_when`), §4 (remove
   table).
4. `document/SKILL.md` — §4 (git-sourced Step 1, changelog, PR draft) — §0 already covered
   Rule 5.
5. Run one real `/build` against a small plan. Two purposes: (a) tune the §1 escalation
   triggers from what it interrupts on; (b) **harvest the run as design input for Move 1.5
   and as the first-real-run evidence the two deferred questions are waiting on** — record
   how the batch review felt (real vs. rubber-stamp), the manual-rate, `done_when`
   resolution behavior, and where the absent round cap was felt (see the Validation-run
   acceptance criterion). Doing 1.0 before 1.5 is partly _for_ this harvest; don't let it
   stay implicit.

### Source material

- `2026-06-23-build-phase-changes.md` — primary draft (before/after text for all four §).
- `2026-06-23-done-when-empirical.md` — evidence for §2 (build-time drift in 7/13 plans;
  intent/command split).
- `2026-06-23-done-when-is-it-sound.md` — soundness of the executable gate (good as a
  floor under judgment; the surrogation risk).
- `2026-06-23-workflow-upgrade-path.md` — the principle, the ordering, and the resolved
  direction (human reviews end-of-batch).
- `2026-06-23-build-as-orchestrator.md` — Move 1.5, out of scope; kept only as a
  forward-compatibility check.
