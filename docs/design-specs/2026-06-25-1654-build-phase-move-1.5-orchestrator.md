# Build Phase Move 1.5 — `/build` as Orchestrator (dispatch + review loop)

**Created:** 2026-06-25 **Implementation Plan:** _(pending — created by `/plan`)_

---

## Overview

**What:** Turn `/build` from a single agent executing tasks into an **orchestrator** that,
per task, dispatches a **builder** subagent and a separate **verifier/reviewer** subagent
and loops them against an executable check until the task is verifiably done — then
commits one clean commit per verified task.

**Why:** Move 1 (#39) shipped approve-by-exception, executable `done_when`, and an
end-of-batch review, but the validation harvest
(`2026-06-25-move-1-validation-harvest.md`) left two risks **unproven**: failure-path /
round-cap behavior, and whether a _lone_ self-grading agent reliably catches
_un-telegraphed_ `done_when` drift. Move 1.5 closes both by splitting the doer from the
judge: a not-the-builder verifier authors and renders the gate, a round cap turns
non-convergence into an escalation rather than a hang, and the human moves to viewer +
approve-by-exception + one end-of-batch review. This is the **minimal provable cut** of
`build-as-orchestrator.md` — enough to prove the loop on one substantive task, no more.

**Type:** Process

---

## Requirements

### Must Have

- [ ] `/build` runs a per-task state machine:
      `todo → building → built → reviewing → done |     back-to-building`.
- [ ] Two subagent roles only — **builder** and **verifier/reviewer** (collapsed: the
      verifier owns what "done" means, authors the check up front, renders the gate
      after).
- [ ] **Outcome gate:** a task exits only when its executable `done_when` exits 0 **and**
      the verifier reports no findings _scoped to the task contract_.
- [ ] **Verifier authors the check** — for new-behavior tasks the verifier writes the
      check from task intent _before_ the builder runs (red→green); for existing-signal
      tasks the command is re-resolved against the repo; un-checkable items are tagged
      `(manual)`. Authoring only ever happens in not-the-builder.
- [ ] **Round cap = 3 → escalate.** Carry the prior-issue list verbatim across rounds;
      silence ≠ fixed (an issue drops only on confirmed-resolved); on context overflow,
      chunk the review — never skip it.
- [ ] **Guard 4 (honest trust + tamper-diff):** the builder is instructed off the check
      and may run but not edit it; the verifier diffs the builder's change for weakened
      asserts / `exit(0)` stubs / edits to the check and treats any as a **hard fail**,
      not a fixable finding. Labeled as trust, not an OS-level wall.
- [ ] **Transparency mandate:** the orchestrator prints every subagent report in full and
      names the task it is dispatching before each round.
- [ ] **Commit discipline:** the orchestrator is the **sole committer** — one clean commit
      per verified task, staging only that task's declared files (including the
      verifier-authored check file); builder subagents never touch git.
- [ ] The skill's `allowed-tools` gains the **Task** (subagent) tool — the one new
      capability `/build` needs.
- [ ] The end-of-batch review (from Move 1) is retained but **re-scoped to the job a
      per-task verifier structurally cannot do**: cross-task / integration coherence —
      interactions between tasks that no single-task-contract verifier sees. It is _not_ a
      second per-task pass over all-green work (that would be the rubber-stamp the
      surrogation-recursion risk warns against). It still surfaces `(manual)` and
      "compiles, behavior unverified" items separately.

### Nice to Have

- [ ] **Model tiering** — builder dispatched at a cheap tier, verifier at an expensive
      one. The role split is load-bearing; the specific model assignment is a tunable, not
      an acceptance criterion.

### Out of Scope (deferred to backlog)

- Reviewer multiplicity / adversarial panel (correctness + security lenses).
- Scale-to-stakes routing (trivial tasks skipping the verifier round) — **this cut runs
  the full loop on every task.**
- Parallel-task worktree isolation (the loop stays sequential).
- OS-level / path-scoped write-lockout for Guard 4 (honest trust this cut).
- Crash / stale-state recovery beyond "re-derive `done` from git commit + `done_when`."
- The ed3d procedure gate (zero-Minor-or-bust) — see Design Decision 3.

---

## Design Decisions

### 1. Orchestrator pattern over single agent

**Options considered:**

1. Keep `/build` a single agent (Move 1) — simplest, but the agent self-grades, which the
   harvest flagged as the unclosed drift-detection risk.
2. Full orchestrator from `build-as-orchestrator.md` — all four guards, model tiering,
   stakes routing, panel reviews. Maximal; more than is needed to prove the loop.
3. **Minimal provable cut** — orchestrator + two roles + outcome gate + cap + transparency
   - commit discipline; defer the rest.

**Decision:** Option 3. Splits doer from judge (the harvest's core ask) at the smallest
surface that proves the loop on one substantive task. Everything deferred is additive and
can follow once the loop is shown to converge — matching the research's "prove it on one
task, tune from that, not from this doc."

### 2. Two roles (builder + verifier), not three

**Decision:** Collapse verifier and reviewer into one not-the-builder role. It authors the
check up front (when one is needed) and renders the gate call after — same authority, one
agent. Keeps the loop to two subagent roles.

### 3. Outcome gate + baked-in revisit trigger

**Options considered:**

1. **Outcome gate** — exit on `done_when` pass + review clean, scoped to the task
   contract. Quality beyond the contract is a backlog item. Fits "gate outcomes, match
   ceremony to stakes"; risks letting Minor-grade rot through.
2. **Procedure gate (ed3d)** — exit only at zero issues every category, Minor included.
   Stricter and runs off the human, but it is the maximal-ceremony posture the adversarial
   review warned against and lets an unscoped reviewer block forever.

**Decision:** Outcome gate, with an **explicit revisit trigger written into the spec**: if
the first real orchestrator run ships Minor-grade rot that the end-of-batch review keeps
catching, escalate toward a _scoped_ procedure gate (still off the human). Neither posture
wins by silence — this is the fork `workflow-upgrade-path.md` flagged "don't let it settle
silently," resolved deliberately and left revisitable.

### 4. Guard 4 as honest trust + verifier tamper-diff

**Options considered:**

1. **Honest trust + tamper-diff** — instruct the builder off the check; the verifier diffs
   for tampering and hard-fails. No OS enforcement; labeled as trust.
2. **Real mechanical lock** — path-scope the builder's writes or add a pre-commit hook so
   the builder physically cannot touch the check. Stronger, but adds harness machinery the
   adversarial review cautioned against, and a PreToolUse hook is itself
   shell-on-every-call risk.

**Decision:** Option 1 for this cut. The tamper-diff is the load-bearing half and it _is_
testable (see Validation, A7 by injection). The mechanical lock is the natural next move
if the tamper-diff proves insufficient — recorded as a deferral, not a rejection.

### 5. Sole committer = orchestrator

**Decision:** The orchestrator commits after the loop goes clean — one commit per verified
task, staging only that task's files. The builder never touches git. A task's commit thus
exists **iff** it passed its checks and review, strengthening git-as-handoff for
`/document` (the SHA is proof the task happened _and_ passed).

**Undeclared-file deviation (carried from Move 1).** When the builder touches a file the
task did not declare, the **verifier surfaces it** in its diff pass (it is reviewing the
diff anyway) and the **orchestrator judges scope** at commit, because the orchestrator is
the sole committer: stage-by-path if the file is in-scope for the task, **escalate as an
approve-by-exception event** if it is out-of-scope. Verifier reports, orchestrator decides
— no silent staging of undeclared files.

### 6. Subagent tool scopes (role hygiene — NOT a wall)

The subagent tool grants set sane defaults and keep commit authority in one place. They do
**not** enforce Guard 4, and the spec says so plainly to avoid a false sense of a wall
that Decision 4 already disclaims:

- **Builder:** Read / Grep / Glob / **Write** / Edit / Bash. **No Task tool, no git.** It
  needs **Write** to create new source files — most feature tasks add a file, and Edit
  only modifies existing ones (this matches Move 1's single-agent `/build`). It dispatches
  nothing and commits nothing.
- **Verifier:** Read / Grep / Glob / Bash **plus Write** to author the check file. **No
  Task tool, no git.**
- **Orchestrator:** the existing `allowed-tools` **plus Task**, and it alone runs git.

**These scopes give zero enforcement of the check-authoring boundary, by design.** A
builder with **Bash** can create or weaken any file — including the check — through the
shell, regardless of Write/Edit grants. So withholding a tool would buy a false wall, not
a real one. Guard 4 therefore rests **entirely on the verifier's tamper-diff** (Decision
4, A7), not on tool scoping. The convention "the builder does not author the check" is
honest trust; the tamper-diff is what makes it checkable. A genuine wall is the deferred
_mechanical lock_ (out of scope) — and note it is **unreachable via `allowed-tools` while
the builder holds Bash**; it would need path-scoping or a hook.

### 7. Full loop every task; model tiering optional

**Decision:** This cut runs the full dispatch+review loop on every task (no stakes
routing) to keep the thing simple to spec and to prove; ceremony-mismatch on one-liners is
accepted for now and routing is deferred. Model tiering is noted as a tunable, not proven
— the role split, not the model IDs, is what's load-bearing.

---

## Acceptance Criteria

- [ ] **A1.** On a substantive task, `/build` dispatches a builder subagent and a
      _separate_ verifier subagent — observably not one agent self-grading.
- [ ] **A2.** The loop exits a task only when `done_when` exits 0 **and** the verifier
      reports no in-contract findings; both conditions are visible in the transcript.
      _(Positive/happy-path case must be demonstrated, not only the failure case.)_
- [ ] **A3.** Every subagent report is printed in full before the orchestrator acts on it,
      the task being dispatched is named before each round, and **any escalation names its
      trigger** (cap / ambiguity / out-of-scope file) so the human is never left to guess
      which path fired.
- [ ] **A4.** On a task whose check keeps failing, the loop re-dispatches with the carried
      finding list; after 3 failed rounds it **stops and escalates to the human** rather
      than hanging or committing.
- [ ] **A5.** For a new-behavior task, the verifier authors the check **before** the
      builder runs, and the check starts **red**.
- [ ] **A6.** The builder never authors/edits the check and never commits; the
      orchestrator commits exactly once per verified task, staging only that task's
      declared files — **including the verifier-authored check file**.
- [ ] **A7.** When check-tampering is present in the builder's diff (weakened assert,
      `exit(0)` stub, edited check), the task **hard-fails** — it is _not_ routed as a
      fixable finding. **Validated by injection** (see Validation), not by waiting for a
      builder to misbehave.
- [ ] **A8.** `(manual)` items and "compiles, behavior unverified" shallow proxies surface
      _separately_ at end-of-batch — not folded into the green.
- [ ] **A9.** A task with genuine plan ambiguity **trips approve-by-exception
      escalation**, and a non-ambiguous task does **not** — the human-by-exception path
      fires when it should and stays silent when it shouldn't. This asserts the half of
      the harvest's worry (does the escalation path actually fire?) that A1–A8 leave
      untested.
- [ ] **A10.** The end-of-batch review **catches a defect that is invisible at single-task
      scope** — a fault that lives in the _interaction_ between two tasks, each of which
      passed its own per-task verifier. This is the proof obligation for the review's
      re-scoped cross-task / integration job; without it that Must-Have is unexercised
      ceremony.
- [ ] **A11.** When the builder touches a file the task did **not** declare and the file
      is **out-of-scope**, the orchestrator **escalates as approve-by-exception** rather
      than silently staging it; when the touched file is in-scope, it stages by path
      without escalating. This is the third escalation trigger (Decision 5) and the
      deviation case the research flags as "where the bodies are buried."

---

## Validation Plan (bundled — the spec calls for it)

The Move 1 harvest's central failure was _validation by absence_: the round cap went
unobserved because no task forced it. Two criteria here are at the same risk — **A7**
(tamper-diff) and **A8** (separate surfacing) — and **A1/A2/A5/A6** (the happy path) are
thinly covered if every validation task is an edge case. So the bundle is **six tasks, not
two**, deliberately covering all eleven criteria:

- **Task 0 — clean new-behavior task** carrying one `(manual)` check and one shallow
  grep-proxy, and **establishing an interface** that Task 4 will consume. Proves the
  normal exit end to end: builder + separate verifier, verifier authors a red check that
  goes green, `done_when` exits 0 with no findings, orchestrator commits once. → exercises
  **A1, A2 (positive), A3, A5, A6, A8**; also the non-ambiguous control for **A9**.
- **Task 1 — check fails ≥3×.** A task whose check cannot pass, to drive the loop into the
  round cap and confirm escalate-on-3rd rather than hang/commit. → **A4**.
- **Task 2 — genuine plan ambiguity.** An under-specified task that should trip
  approve-by-exception (a real fork the plan doesn't resolve), confirming the human-in-by-
  exception path fires when it should and not otherwise. → **A9**. (Pair it against a
  non-ambiguous task — Task 0 serves — to confirm the path stays silent when it should.)
- **Task 3 — injected tamper.** A harness step: after the builder runs, **hand-weaken an
  assert or stub `exit(0)`** in the check file, then let the verifier's diff pass run and
  confirm it **hard-fails**. This is the only reliable way to fire the tamper-diff — "add
  a hard task and watch the builder cheat" just reproduces validation-by-absence. →
  **A7**.
- **Task 4 — cross-task interaction.** Consumes the interface Task 0 established, in a way
  that is **individually green** (its own per-task verifier passes — its task contract is
  satisfied in isolation) but **breaks the pair** (the Task 0 ↔ Task 4 interaction is
  wrong). Each task's verifier, scoped to one task contract, structurally cannot see it;
  the end-of-batch review must. This is the only task that creates a genuine cross-task
  fault. → **A10**.
- **Task 5 — out-of-scope undeclared file.** The builder touches a file the task did not
  declare and that is out-of-scope for it. Confirms the orchestrator **escalates with the
  trigger named** instead of silently staging the file — and (paired against Task 0's
  in-scope-only commit) that an in-scope undeclared touch stages without escalating.
  Proves the scope-classification judgment, not just the escalation plumbing. → **A11**.

The validation plan is a throwaway artifact (sandbox + plan committed on a harvest branch,
discarded after harvest), the same disposition the Move 1 harvest used.

---

## Residual Risks (named deferrals, not fixed here)

- **The verifier is the single unchecked authority.** In a two-role cut the verifier
  authors the check, judges it, and renders the gate call — and nothing checks the
  verifier. A confidently-wrong or vacuous verifier check (passes while proving nothing)
  would not be caught, because reviewer-multiplicity is deferred. Task 2 (ambiguity) is a
  _partial_ probe but will not catch a confidently-wrong verifier. **Mitigation deferred
  to backlog:** reviewer multiplicity / a second lens. Named here so the gap is on the
  record, the way the harvest named its own.
- **Surrogation recursion.** Moving the human to end-of-batch over a pile already wearing
  green checkmarks is itself the auto-yes relocated one level up. The end-of-batch review
  must stay a _real_ evaluation (deviations-first, `(manual)` pulled out of the green,
  verified-vs-just-compiled per task, test-file diffs surfaced). The tell to watch on the
  first real run: the moment "did it pass?" replaces "is it right?" in your own head.
- **Outcome-gate leakage.** See Design Decision 3 — the revisit trigger is the planned
  response if Minor-grade rot leaks through in practice.

---

## Suggested Files to Create/Modify

> Non-binding starting point. `/plan` re-verifies these against the codebase in its Step 2
> and owns the final paths.

```
.claude/skills/build/SKILL.md          # orchestrator loop, state machine, guards, transparency,
                                        #   commit discipline; add Task to allowed-tools
.claude/skills/build/ (agents/prompts)  # builder + verifier subagent role definitions / dispatch
                                        #   prompts with pinned tool scopes (Decision 6)
docs/research/workflow-upgrade/...      # throwaway validation plan (4 tasks) — harvest branch only
scripts/sync-skills.sh                  # re-sync if new skill files are added (verify exec bits)
docs/changelog.md                       # entry on completion (via /document)
docs/backlog.md                         # record the deferrals: reviewer multiplicity, stakes
                                        #   routing, mechanical write-lockout, model tiering
```
