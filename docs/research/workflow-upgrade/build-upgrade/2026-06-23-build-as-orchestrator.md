# Move 1.5 — `/build` as an orchestrator (dispatch + review loop)

**Date:** 2026-06-23

Move 1 keeps `/build` a single agent running tasks with approve-by-exception. This turns
it into an **orchestrator**: dispatch each task to a build subagent, loop it against a
verifier until verifiably done. Adopt Move 1 first — this depends on its executable
`done_when` to terminate honestly.

It's a real state machine:
`todo → building → built → reviewing → done | back-to-building`. The orchestrator thinks
in tasks so the human doesn't have to.

---

## The loop

Per task, the orchestrator:

0. **Settle the check first — not the builder writes it.** Decide what proves this task
   done before any code exists. Two paths (see "Who writes the check"):
   - **Existing signal** — the check runs something already there (`pnpm build`, the test
     suite, a `grep` over output). No test authored; the orchestrator resolves the real
     command against the repo, repairing the plan's provisional guess (Move 1 §2).
   - **New behavior** — nothing checks it yet. The orchestrator dispatches the
     **verifier** to write the test from the task's intent, **before the builder touches
     anything**. Writing it first targets the goal rather than whatever the builder
     produces, and starts red — so red→green falls out for free. State: `check-defined`.
1. **Dispatch build.** Spawn a build subagent with just this task: spec, settled
   `done_when`, and minimum context (relevant files, the plan's codebase notes) — not the
   whole repo. Its job is to make the check pass. It may run the check; it may not author
   or edit it (Guard 4). State: `building`.
2. **Subagent reports done.** It implements and returns. State: `built`.
3. **Verify + review.** Run the executable `done_when` (must exit 0) and have the verifier
   judge the diff against this task's contract. State: `reviewing`.
4. **Route findings.** Review findings or a failed check go back to a build subagent (same
   or fresh — see forks). Back to `building`. Go to 2.
5. **Exit.** No findings **and** `done_when` passes → `done`. The orchestrator commits the
   verified task and moves on.

The human is in this loop only by exception (below).

**Model tiering (from `ed3d`).** `ed3d` runs implementor and bug-fixer on **haiku**,
reviewer on **opus** — cheap labor, expensive judgment. The builder produces a diff
against a spec (mechanical); the verifier authors the check and makes the gate call the
loop's honesty rests on (judgment), so it gets the better model. The orchestrator just
routes; it can run cheap.

## Who writes the check

The hard rule Guard 4 enforces: **never the builder.** An agent that writes its own
`done_when` writes an easy one — the open-book exam. So authorship splits off from the
doer (the two paths in step 0).

**Collapse to two roles.** Verifier and reviewer are the same role: the not-the-builder
judge that owns "done." It writes the check up front (when needed) and renders the gate
call after. So the loop is **two subagent roles, builder + verifier** — not three. Trivial
tasks skip the dance: the orchestrator runs the obvious command (`pnpm build`) and moves
on; spin up the write-a-test path only for behavior worth pinning down (scale to stakes,
below).

Not the orchestrator itself: authoring a test from intent is judgment, not routing — it
muddies the thin dispatch role and burns context. Cheap command resolution it does inline;
a test it dispatches out.

---

## What "clean" bottoms out in

A reviewer saying "looks good" is an output pattern, same as a builder saying "tests
passing" — two agents converging on a shared vibe instead of reality. The `proofOf()`
honesty bug at the dispatch layer.

So the exit condition is **outcome-based**: terminate only when `done_when` exits 0
**and** the reviewer has no findings. The review catches the qualitative; the executable
check is the outcome floor under it — harder to game than "looks good," though not
unfakeable (`2026-06-23-done-when-is-it-sound.md`). This is why Move 1 §2's executable
`done_when` is a hard prerequisite: without a real check, "review clean" is just two
agents agreeing.

**The gate has a name worth lifting.** `ed3d-plan-and-execute`'s
`verification-before-completion` skill is this floor as a reusable rule each subagent runs
before claiming done: the Iron Law ("if you haven't run the verification command in this
message, you cannot claim it passes"), a 5-step gate (identify proving command → run fresh
→ read full output and exit code → confirm it matches the claim → only then claim), and a
rationalization table ("should work" → run it; "agent said success" → verify
independently; "I'm tired" → exhaustion isn't evidence). Lift it nearly verbatim onto both
subagents — it's what stops `done_when` from being gamed.

---

## Four guards

1. **Round cap + escalate.** Build fixes finding 1, breaks finding 2, review re-raises —
   ping-pong forever. Cap at N rounds (start N=3); on exceeding, **stop and escalate to
   the human** with the open findings. Non-termination is the default failure of
   fix-until-clean loops; the cap turns a hang into an approve-by-exception event. `ed3d`
   ships this as a literal **three-strike rule** — adopt it. Three mechanics make the cap
   converge rather than just bound:
   - **Carry the prior-issue list across rounds; treat silence as unfixed.** The re-review
     gets the explicit list of outstanding findings. An issue drops only when the reviewer
     confirms it resolved, never because the next review failed to mention it. Silence ≠
     fixed. Without this the loop "converges" by forgetting.
   - **Findings are durable memory, not chat.** Each finding goes to the work store
     **verbatim** (one record per issue, full text — `ed3d` uses one task per issue):
     after a compaction the record is all that survives, so a paraphrased finding the next
     fixer can't act on is silently dropped.
   - **Context-limit is a chunk, not a skip.** If a review round overflows context, split
     it (halve the diff, one logical group at a time) and retry on the changed files —
     never skip. A skipped review is an unverified `done`.
2. **Reviewer scoped to the task contract**, not open-ended "is this good code." Review
   against this task's `done_when` + the plan. An unscoped reviewer gold-plates and the
   loop never converges. Quality beyond the contract is a backlog item, not a blocker.
3. **Context discipline.** Each subagent gets the task + its `done_when` + the relevant
   files — not the whole repo, not the full conversation. Findings pass as a structured
   list (file:line + what's wrong) so the builder fixes rather than thrashes.
4. **The build subagent cannot write the verifier.** A gate the doer can edit is not a
   gate. The soundness research (`2026-06-23-done-when-is-it-sound.md`) measured it:
   capable agents game a reachable check at material rates, and tampering spikes ~30× when
   the verifier sits in their write scope. So: the `done_when` command and check files
   live **outside the builder's write scope**; the gate re-runs from a clean/locked copy
   the builder can't touch; and the reviewer **diffs the task's change for
   verifier-tampering** (modified or deleted assertions, weakened tests, `exit(0)` stubs,
   edits to the check itself) and treats any as a hard fail, not a finding to fix.

---

## Commit discipline

The **orchestrator** commits after the loop goes clean — not the build subagent mid-loop.
Consequences:

- A task's commit exists **iff** it passed its checks and review, and is as strong as that
  task's `done_when` — a shallow check commits as "compiles, behavior unverified."
- The loop's wip/fix-review churn collapses into **one clean commit per verified task** —
  no thrash in history.
- Git-as-handoff (Move 1 §4) gets stronger: `/document` reading `git log` now reads
  verified states. The recorded SHA is proof the task happened and passed.

This relies on Move 1 §0's no-git scope: commit on the feature branch, staging only the
task's declared files, never pushing. The orchestrator is the sole committer; build
subagents never touch git.

## Where the human lands

Verification moves off the human for the mechanizable part — the fatigue win. The role
collapses to:

- **Viewer of the work** — see the transparency mandate; not optional.
- **Approve-by-exception escalations** — a genuine fork the plan doesn't resolve, or a
  loop that hit the round cap.
- **One end-of-batch review** of the converged work (Move 1 §3), now over pre-verified
  tasks.

You review the verified result, not every round. That's the point.

**The transparency mandate (load-bearing, from `ed3d`).** Pulling the human out of the
inner loop is only safe if they can still see it. `ed3d`'s rule: "the human cannot see
what subagents return — you are their window into the work." So the orchestrator **prints
every subagent report in full** (build, review, fix) before acting on it — no summarizing,
no paraphrasing — and names the task it's dispatching before each round. This is the
counterweight to the founding diagnosis: approve-by-exception removes the approval
friction that decayed into auto-yes; transparency replaces it with visibility that needs
no decision. Without it, Move 1's fatigue win just trades an approval black box for an
execution black box.

## Scale it to stakes

Don't run the full loop on every task — a one-line change doesn't need a review round;
that's ceremony mismatched to stakes. The orchestrator decides per task:
trivial/mechanical → builder only (or inline), no review; substantive → full loop;
security-/migration-grade → full loop with a higher round cap and maybe a second reviewer
lens. Weight is a property of the task, set in the plan.

---

## Open design forks (decide deliberately, not by default)

- **Same vs. fresh build subagent for the fix.** Same preserves context but the agent that
  wrote the bug is worse at seeing it; fresh gets clean eyes but re-pays context. Lean
  fresh for review-driven fixes, same for trivial nits — but pick on purpose.
- **Reviewer multiplicity.** One reviewer is cheapest; high-stakes tasks may want an
  adversarial pair (correctness lens + security lens). Don't default to a panel — it's a
  stakes call.
- **Parallel tasks → isolation.** This design is sequential (one task's loop at a time),
  matching the DAG. If you ever parallelize independent tasks, build subagents editing
  files concurrently need worktree isolation. Sequential needs none — keep it sequential
  unless a real bottleneck appears.
- **Crash/stale state.** A session dying mid-loop leaves a task at `building`/`reviewing`.
  The git backstop corrects it: a task is really `done` only if its commit exists and its
  `done_when` passes — re-derive on restart, don't trust the last written state.

## Lifted from `ed3d-plan-and-execute` (provenance + the fork)

`ed3d-plan-and-execute` (read-only, under
`~/Downloads/ed3d-plugins-main/plugins/ed3d-plan-and-execute/`) is an independent,
more-mature implementation of this exact pattern. It validates the architecture and
supplied four mechanics this draft had left as TODOs: the named honesty gate, the
transparency mandate, the loop-termination mechanics, and model tiering. Primary source:
the `executing-an-implementation-plan` skill plus three agents — `task-implementor-fast`
(build, haiku), `code-reviewer` (review, opus), `task-bug-fixer` (fix, haiku) — ~80% of
what's folded in; the honesty gate from `verification-before-completion`, the
silence-≠-fixed mechanics from `requesting-code-review`, the end-of-batch decision gate
from `finishing-a-development-branch`.

**The one real philosophical fork — name it, don't absorb it.** `ed3d`'s exit condition is
zero issues in every category, Minor included, "not optional" — a **procedure gate**. Ours
is an **outcome gate** (`done_when` passes + review clean, scoped to the task contract —
Guard 2). We deliberately do **not** adopt zero-Minor-or-bust: it's the maximal-ceremony
posture our adversarial review warned against, and would let a reviewer gold-plate the
loop into non-convergence. But their strictness doesn't contradict our fatigue thesis:
they moved high-frequency enforcement off the human and onto cheap subagents (reviewer ↔
fixer) — our cure, reached from the other direction. The lesson is the relocation of
ceremony, not the amount.

**Deliberate non-adoptions** (recorded so they aren't re-litigated):

- **Mandatory TDD red-green for all new code.** `ed3d` makes "no production code without a
  failing test first" a universal floor — a sound principle welded to a comfort ritual.
  Keep TDD as a stakes-matched option the plan can require per task, not a global gate.
- **Their per-phase + final + test-analyst + librarian review stack.** Good for their plan
  format; more stages than our flow wants. We take the loop and the gate, not the
  pipeline.
- **`phase_NN.md` + `START_TASK_N` markers and the `/tmp` scratchpad mechanics** — coupled
  to their plan artifact; our task/`done_when` representation already covers the need.

## Order relative to Move 1

If adopted, this supersedes Move 1 §1's single-agent loop and replaces the per-task human
touch in §3 with the agent review loop (end-of-batch human review stays). Everything else
in Move 1 holds and is required: executable `done_when` (§2) is the honesty floor,
git-as-handoff (§4) is what the verified commits feed, and the §0 decisions still gate
everything — including `allowed-tools`, which now must add the Task/subagent tool.

Ship Move 1 first: most of the fatigue relief, a fraction of the complexity, and the
prerequisite. Adopt this once the `done_when` floor exists and you want verification fully
off your plate. Prove it on one substantive task, watch where the loop fails to converge,
and tune the round cap and reviewer scope from that — not from this doc.
