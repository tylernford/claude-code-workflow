# Move 1.5 — `/build` as an orchestrator (dispatch + review loop)

**Date:** 2026-06-23 **Relationship:** the ambitious target architecture for the build
phase, one step beyond `2026-06-23-build-phase-changes.md` (Move 1). Move 1 keeps `/build`
a single agent doing tasks with approve-by-exception; this turns `/build` into an
**orchestrator** that dispatches each task to a build subagent and loops it against a
review subagent until the work is verifiably done. Adopt Move 1 first — this **depends**
on its executable `done_when` to terminate honestly.

**Convergence note:** this is the orchestrator-writes-status-at-the-dispatch-boundary
pattern plus a real state machine —
`todo → building → built → reviewing → done | back-to-building` — instantiated, not just
narrated. The dispatch boundary is where a serialized task earns its existence: the
orchestrator thinks in tasks so the human doesn't have to.

---

## The loop

Per task, the `/build` orchestrator:

0. **Settle the check first — authored by not-the-builder.** Before any code is written,
   decide what will prove this task done. Two paths (see "Who writes the check" below):
   - **Existing signal** — the check runs something that already exists (`pnpm build`, the
     existing test suite, a `grep` over generated output). No test is authored; the
     orchestrator _resolves the real command_ against the repo as it stands — this is
     where the plan's suggested command gets repaired against reality (Move 1 §2,
     intent/command split).
   - **New behavior** — the task introduces something with no existing check. The
     orchestrator dispatches the **verifier subagent** to _write the test from the task's
     intent_, **before the build subagent touches anything**. Writing it first means the
     test targets the goal (not whatever the builder happens to produce) and starts red
     (nothing's built yet), so red→green verification falls out for free. State:
     `check-defined`.
1. **Dispatch build.** Spawn a build subagent with _just this task_ — its spec, its
   settled `done_when`, and the minimum context it needs (the relevant files / the plan's
   codebase notes), not the whole repo. Its job is to **make the check pass**. It may
   _run_ the check; it may **not** author or edit it (Guard 4). State: `building`.
2. **Subagent reports done.** It implements and returns. State: `built`.
3. **Verify + review.** Run the executable `done_when` (must exit 0) and have the
   verifier/review subagent judge the diff against _this task's contract_ — does it
   satisfy the check and the plan. State: `reviewing`.
4. **Route findings.** If the review has findings or the executable check fails, pass them
   back to a build subagent (same or fresh — see forks). State: back to `building`. Go
   to 2.
5. **Exit.** When the review has no findings **and** the executable `done_when` passes,
   the task is `done`. The orchestrator commits the verified task (see commit discipline)
   and moves to the next.

The human is not in this loop. They are in it only by exception (below).

**Model tiering (lifted from `ed3d`).** The roles are not the same cost. `ed3d` runs the
**implementor and bug-fixer on haiku** and the **reviewer on opus** — cheap labor,
expensive judgment. The build subagent produces a diff against a spec (mechanical-ish);
the verifier/review subagent both _authors the check_ (writing a test that targets intent
is judgment) and _makes the gate call_ the whole loop's honesty rests on, so it gets the
better model. Adopt the split: dispatch build/fix at the cheap tier, verify/review at the
expensive tier. The orchestrator itself stays small and can run cheap — it routes, it
doesn't judge.

## Who writes the check, and when

The fork that matters once tasks start carrying executable checks: _who authors the
check?_ The hard rule is the one Guard 4 enforces — **never the build subagent.** An agent
that writes its own `done_when` writes an easy one; that's the open-book exam, the
"reviewer can be flattered" failure relocated one step earlier. So authorship is split off
from the doer. The two paths from step 0 differ in _who_ does the authoring:
existing-signal tasks need no test — the orchestrator (or verifier) _resolves_ the real
command against the repo as it stands, repairing the plan's provisional guess (the ~80%
mechanizable majority, empirical doc); new-behavior tasks get the **verifier** writing the
test from intent, _before_ the builder, so it targets the goal rather than whatever the
builder produces and gives red→green for free. Authoring only ever happens in
not-the-builder.

**Collapse the roles to fit the scale.** The verifier and the reviewer are the _same role_
— the not-the-builder judge that owns what "done" means: it writes the check up front
(when one's needed) and renders the gate call after. So the loop is really **two subagent
roles, builder + verifier**, not three. And **trivial tasks skip the dance entirely** —
the orchestrator runs the obvious existing command (`pnpm build`) and moves on; the
verifier-writes-a-test path is only worth spinning up when the task introduces behavior
worth pinning down (scale to stakes, below).

**Why not the orchestrator itself?** Authoring a test from intent is real work (judgment),
not routing — loading it onto the orchestrator muddies its thin dispatch role and costs it
context. For existing-signal _command resolution_ (cheap, mechanical) the orchestrator can
do it inline; for _writing a test_ (judgment) it dispatches the verifier. The orchestrator
decides **which path** and dispatches; it doesn't author.

---

## The one thing that makes or breaks it: what "clean" bottoms out in

A review subagent saying "looks good" is an output pattern, the same way a build subagent
saying "tests passing" is — two agents can converge on a shared vibe instead of on
reality. That is the `proofOf()` honesty bug (outcome- vs transcript-based verification)
relocated to the dispatch layer.

**So the loop's exit condition is outcome-based, not transcript-based:** it terminates
only when the executable `done_when` exits 0 **and** the review subagent has no findings.
The review catches the qualitative; the executable check is the outcome floor under it —
harder to game than "looks good," though not unfakeable (see
`2026-06-23-done-when-is-it-sound.md`). This is why Move 1's §2 (executable `done_when`)
is a hard prerequisite — without a real check, "review clean" is just the two agents
agreeing, and the loop converges on agreement rather than correctness.

**The gate has a name worth lifting:** `ed3d-plan-and-execute`'s
`verification-before-completion` skill is exactly this floor, generalized into a reusable
rule each subagent runs before it may claim done — the Iron Law ("if you haven't run the
verification command _in this message_, you cannot claim it passes") plus a 5-step gate
(identify the proving command → run it fresh → read full output and exit code → confirm it
matches the claim → only then claim) and a rationalization table ("should work" → run it;
"agent said success" → verify independently; "I'm tired" → exhaustion isn't evidence).
Lift it nearly verbatim and bind it onto both the build and review subagents: it is what
stops `done_when` from being gamed by either side, the missing teeth under §39's
principle.

---

## Four guards (or it misbehaves)

1. **Round cap + escalate.** Build fixes finding 1, breaks finding 2, review re-raises —
   ping-pong forever. Cap at N rounds (start N=3); on exceeding, **stop and escalate to
   the human** with the open findings. Non-termination is the default failure mode of
   fix-until-clean loops; the cap turns it into an approve-by-exception event, not a hang.
   `ed3d` ships this as a literal **three-strike rule** ("if the same issues persist after
   three review cycles, stop and ask the human") — adopt the count and the framing. Two
   mechanics from their loop make the cap actually converge rather than just bound:
   - **Carry the prior-issue list across rounds, and treat silence as unfixed.** The
     re-review is handed the explicit list of outstanding findings; an issue drops _only_
     when the reviewer confirms it resolved, never because the next review failed to
     mention it. Silence ≠ fixed. Without this the loop "converges" by forgetting.
   - **Findings are durable memory, not chat.** Each finding is written to the work store
     **verbatim** (one record per issue, full text — `ed3d` uses one task per issue)
     because after a compaction the record is all that survives; a paraphrased finding the
     next fixer can't act on is a finding silently dropped. Same single-source-the-truth
     discipline the rest of the exploration keeps hitting.
   - **Context-limit is a chunk, not a skip.** If a review round overflows context, split
     it (halve the diff, or one logical group at a time) and retry focused on the changed
     files — never skip the round. A skipped review is an unverified `done`.
2. **Reviewer scoped to the task contract**, not open-ended "is this good code." Review
   against _this task's_ `done_when` + the plan. An unscoped reviewer gold-plates and the
   loop never converges — the Goodhart/legibility caution. Quality beyond the contract is
   a backlog item, not a loop blocker.
3. **Context discipline.** Each subagent gets the task + its `done_when` + the relevant
   files — not the whole repo and not the full conversation. The orchestrator stays small
   and cheap; the subagents stay focused. Findings pass as a structured list (file:line +
   what's wrong), so the build agent fixes rather than thrashes.
4. **The build subagent cannot write the verifier.** The agentic restatement of the whole
   trust-vs-gate point: _a gate the doer can edit is not a gate._ The soundness research
   (`2026-06-23-done-when-is-it-sound.md`) measured the exposure — capable agents game a
   reachable check at material rates, and tampering spikes ~30× when the verifier sits in
   their write scope. So: the `done_when` command and the test/check files live **outside
   the build subagent's write scope**; the gate re-runs from a clean/locked copy the
   builder can't touch; and the review subagent **diffs the task's change for
   verifier-tampering** (modified or deleted assertions, weakened tests, `exit(0)` stubs,
   edits to the check itself) and treats any as a hard fail, not a finding to fix. The
   builder satisfies the gate; it never authors or edits it.

---

## Commit discipline (an upgrade this unlocks)

The **orchestrator** commits _after_ the loop goes clean — not the build subagent
mid-loop. Consequences:

- A task's commit exists **iff** it passed its checks and review. The commit means "passed
  its checks" — as strong as that task's `done_when`, no stronger; a shallow check commits
  as "compiles, behavior unverified" (`2026-06-23-build-phase-changes.md` §2), not strong
  proof.
- The loop's churn (wip / fix-review-finding noise) collapses into **one clean commit per
  verified task** — no thrash in history.
- Git-as-handoff (Move 1 §4) gets _stronger_: `/document` reading `git log` is now reading
  a log of verified states. This is the SHA-at-commit-time idea with teeth — the recorded
  SHA is the proof the task happened _and_ passed.

This relies on the no-git decision in Move 1 §0 (the agent commits on the feature branch,
staging only the task's declared files, never pushing). The orchestrator is the committer;
the build subagents never touch git.

## Where the human lands

Verification moves off the human for the mechanizable part — the fatigue win. The human
role collapses to:

- **Viewer of the work** — see the transparency mandate below; this is not optional, it is
  what keeps the loop from becoming a black box.
- **Approve-by-exception escalations** — a genuine fork the plan doesn't resolve, or a
  loop that hit the round cap.
- **One end-of-batch review** of the _converged_ work (Move 1 §3) — the real, loaded-in
  pass, now over pre-verified tasks rather than raw output.

You review the verified result, not every round. That is the whole point.

**The transparency mandate (the load-bearing piece, lifted from `ed3d`).** Pulling the
human out of the inner approval loop is only safe if they can still _see_ it. `ed3d`'s
rule: "the human cannot see what subagents return — you are their window into the work,"
so the orchestrator **prints every subagent report in full** (build, review, fix) before
acting on it, no summarizing or paraphrasing, and states which task it's dispatching
before each round. This is the exact counterweight to our founding diagnosis:
approve-by-exception removes the _approval_ friction that decayed into auto-yes, and
transparency replaces it with _visibility_ that doesn't require a decision. The human
reads the stream and intervenes when something looks wrong; they don't gate every step.
Without this clause, Move 1's whole fatigue win just trades an approval black box for an
execution black box.

## Scale it to stakes

Don't run the full dispatch+review loop on every task — a one-line change doesn't need a
review subagent round; that's ceremony mismatched to stakes (Move 2's lighter gear). The
orchestrator decides per task: trivial/mechanical → build subagent only (or inline), no
review round; substantive → full loop; security-/migration-grade → full loop with a higher
round cap and maybe a second reviewer lens. Weight is a property of the task, set in the
plan.

---

## Open design forks (decide deliberately, not by default)

- **Same vs. fresh build subagent for the fix.** Same preserves context but the agent that
  wrote the bug is worse at seeing it; fresh gets clean eyes but re-pays context. Lean
  fresh for review-driven fixes, same for trivial nits — but pick on purpose.
- **Reviewer multiplicity.** One reviewer is cheapest; for high-stakes tasks, an
  adversarial pair (e.g. correctness lens + security lens) catches what a single lens
  misses. Don't default to a panel — it's a stakes call.
- **Parallel tasks → isolation.** This design is sequential (one task's loop at a time),
  matching the DAG and "sequential execution." If you ever parallelize _independent_
  tasks, build subagents editing files concurrently need worktree isolation. Sequential
  needs none — keep it sequential unless a real bottleneck appears.
- **Crash/stale state.** A session dying mid-loop leaves a task at `building`/`reviewing`.
  The git backstop corrects it: a task is really `done` only if its commit exists _and_
  its `done_when` passes — re-derive on restart, don't trust the last written state.

## Lifted from `ed3d-plan-and-execute` (provenance + the fork)

**Source files referenced** (all under
`~/Downloads/ed3d-plugins-main/plugins/ed3d-plan-and-execute/`, read-only):

- `skills/executing-an-implementation-plan/SKILL.md` — **the orchestrator itself**;
  primary source. Transparency mandate, just-in-time phase loading, per-phase review loop,
  three-strike rule, tasks-as-durable-memory (verbatim issue text), context-limit
  chunking.
- `commands/execute-implementation-plan.md` — the `/build`-analog entry point (thin;
  validates paths, hands off to the skill).
- `agents/task-implementor-fast.md` — build subagent, `model: haiku`. TDD + verify +
  commit + structured report.
- `agents/code-reviewer.md` — review subagent, `model: opus`. Source of the model-tiering
  observation and the severity/issue-gate structure.
- `agents/task-bug-fixer.md` — fix subagent, `model: haiku`. Root-cause-before-fix,
  re-review handoff.
- `skills/verification-before-completion/SKILL.md` — the honesty gate lifted nearly
  verbatim (Iron Law, 5-step gate function, rationalization table).
- `skills/requesting-code-review/SKILL.md` — the review→fix→re-review loop mechanics,
  incl. "silence ≠ fixed" prior-issue tracking and focused-retry-on-timeout.
- `skills/finishing-a-development-branch/SKILL.md` — the 4-option merge/PR/keep/discard
  end-of-batch decision gate (lighter relevance; maps to our end-of-batch review + git
  finish).
- Top-level context, not leaned on: `~/Downloads/ed3d-plugins-main/README.md` (RPI-loop
  overview) and `.../CLAUDE.md` (their XML-Task-invocation convention).

The first item plus the three agents are where ~80% of what we folded in came from.

`ed3d-plan-and-execute` (the `executing-an-implementation-plan` skill and its
`task-implementor-fast` / `code-reviewer` / `task-bug-fixer` agents) is an independent,
more-mature implementation of this exact orchestrator pattern — it validates the
architecture and supplies four mechanics this draft had left as TODOs, now folded in
above:

- the **honesty gate** as a named reusable skill (§"what clean bottoms out in");
- the **transparency mandate** (§"Where the human lands") — the piece we were missing;
- **loop-termination mechanics**: three-strike cap, carried prior-issue list, silence ≠
  fixed, verbatim durable findings, context-limit chunking (Guard 1);
- **model tiering** by role (after §"The loop").

**The one real philosophical fork — name it, don't absorb it.** `ed3d`'s exit condition is
_zero issues in every category, Minor included, "not optional."_ That is a **procedure
gate** (no open findings). Ours is an **outcome gate** (`done_when` passes + review clean,
scoped to the task contract — Guard 2). We deliberately do **not** adopt
zero-Minor-or-bust: it's the maximal-ceremony posture our adversarial review warned
against, and it would let a reviewer gold-plate the loop into non-convergence. But note
_why_ their strictness doesn't contradict our fatigue thesis: they moved the
high-frequency enforcement **off the human and onto cheap subagents** (reviewer ↔ fixer),
exactly our cure arrived at from the other direction. The lesson we take is the
_relocation of ceremony_, not the _amount_ of it.

**Deliberate non-adoptions** (recorded so the decision is durable, not re-litigated):

- **Mandatory TDD red-green for all new code.** `ed3d` makes "no production code without a
  failing test first" a universal floor. That's a sound principle welded to a comfort
  ritual — keep TDD as a _stakes-matched_ option the plan can require per task, not a
  global gate. (Same call as Move 2's match-ceremony-to-stakes.)
- **Their per-phase + final + test-analyst + librarian review stack.** Good for their plan
  format; more stages than our flow wants. We take the loop and the gate, not the
  pipeline.
- **`phase_NN.md` + `START_TASK_N` markers and the `/tmp` scratchpad mechanics** — coupled
  to their plan artifact; our task/`done_when` representation already covers the need.

## How this changes the Move 1 draft

If adopted, it supersedes the single-agent loop in Move 1 §1 (For Each Task) and §3 (the
human per-task touch is replaced by the agent review loop; the human end-of-batch review
stays). Everything else in Move 1 holds unchanged and is in fact _required_: executable
`done_when` (§2) is the honesty floor, the git-as-handoff repointing (§4) is what the
verified commits feed, and the §0 decisions (honest `allowed-tools` — now the orchestrator
also needs the Task/ subagent tool — and the no-git scope) still gate everything.

## Order relative to Move 1

Ship Move 1 first (most of the fatigue relief, a fraction of the complexity, and the
prerequisite). Adopt this once the executable-`done_when` floor exists and you want
verification fully off your plate. Prove it on one substantive task and watch where the
loop fails to converge — tune the round cap and the reviewer scope from that, not from
this doc.
