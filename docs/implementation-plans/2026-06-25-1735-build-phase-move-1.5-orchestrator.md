# Implementation Plan: Build Phase — Move 1.5: `/build` as Orchestrator

**Created:** 2026-06-25 **Type:** Process **Overview:** Turn `/build` from a single
self-grading agent into an orchestrator that, per task, dispatches a separate builder and
verifier/reviewer subagent and loops them against an executable check until the task is
verifiably done, then commits one clean commit per verified task. **Design Spec:**
docs/design-specs/2026-06-25-1654-build-phase-move-1.5-orchestrator.md

---

## Summary

Convert single-agent `/build` into a per-task **orchestrator** with two subagent roles —
**builder** (doer) and **verifier/reviewer** (judge, who authors the executable check up
front and renders the gate after). The orchestrator dispatches both, loops them against
the check until the task is verifiably done, then is the **sole committer** of one clean
commit per verified task.

The work splits into a **build session** (Tasks 1–7 — all the machinery) and a separate
**Validation Run** performed in another window, whose results are **fed back to this same
`/build` session** at its acceptance-criteria gate — because a `/build` cannot nest or run
itself, but it _can_ pause and ingest the results of a run done elsewhere. The build
session ships:

- **`.claude/skills/build/prompts/{builder,verifier}.md`** — the two subagent role prompts
  with honest-trust tool scopes (Task 1).
- **`.claude/skills/build/SKILL.md`** — reworked into the orchestrator: `+Task` in
  `allowed-tools`, the per-task state machine and dispatch+review loop (Task 2), the round
  cap + carried-issue list + Guard 4 tamper-diff (Task 3), the transparency mandate +
  commit discipline (Task 4), and the re-scoped end-of-batch review + Rules (Task 5).
- **The throwaway 6-task validation plan** (Task 6) and the **backlog deferrals** (Task
  7).

Then — **without ending the build session** — you sync, branch off the machinery commit,
and run the **new** orchestrator against the validation plan **in a separate window**; the
harvest is **fed back to the paused build session**, which records it, marks A1–A11, and
reaches one clean Phase Complete → `/document`. Scope is the **minimal provable cut**:
reviewer multiplicity, stakes routing, mechanical write-lockout, and model tiering are all
explicitly deferred (Task 7).

---

## Codebase Verification

_Confirmed against the actual files on 2026-06-25._

- [x] `build/SKILL.md` is single-agent with frontmatter
      `allowed-tools: Read, Grep, Glob, Write, Edit, Bash` +
      `disable-model-invocation: true`, the Move-1 loop, three-attempt cap, end-of-batch
      review, and sole-committer git rule (Rule 6) — Verified: yes (lines 1–191). Needs
      `+ Task`.
- [x] **No `.claude/agents/` directory exists** and there is no subagent/dispatch
      machinery anywhere in `.claude/skills/` — Verified: yes (grep returned nothing).
      Subagent dispatch is therefore **honest-trust prompt injection** via the `Task` tool
      (`subagent_type: general-purpose`), not enforced agent config — which is exactly
      what Design Decision 6 says ("zero enforcement, by design").
- [x] `scripts/sync-skills.sh` syncs `design/plan/build/document` via `cp -R` of the
      **whole** skill dir — Verified: yes. New files under `.claude/skills/build/prompts/`
      are markdown and sync **automatically**; there are no exec bits to set.
- [x] Validation/harvest artifacts live in `docs/research/workflow-upgrade/` (Move 1
      precedent: `2026-06-25-move-1-validation-harvest.md`, `…-validation-plan.md`) —
      Verified: yes.
- [x] `docs/backlog.md` is a flat list of dated `## YYYY-MM-DD:` sections (append a new
      one) — Verified: yes.

**Patterns to leverage:**

- **Move 1 plan** (`docs/implementation-plans/2026-06-25-1453-build-phase-move-1.md`) is
  the structural model: SKILL.md edits split across coherent section-tasks, plus a
  separate validation-run task executed on a side branch.
- **AC carry-forward ledger** (commit `3c3c0d8`) is preserved unchanged. The orchestrator
  remains the sole authority for marking `[x]`.
- **`<base>` snapshot + end-of-batch review + AC gate** (Move 1) stay; Move 1.5 re-scopes
  the review to cross-task coherence and adds the per-task dispatch loop beneath it.

**Discrepancies found:**

- **`sync-skills.sh` needs no edit.** The design listed it as a "suggested" file ("re-sync
  if new skill files are added (verify exec bits)"), but the script already recursively
  copies the dir, and the new prompt files have no exec bits. No task touches it.
- **`docs/changelog.md` is out of scope** here — it is written by `/document` in Phase 3,
  not this plan.
- **Relative-link bug (backlog 2026-06-21):** `SKILL.md`'s references to the new prompt
  files **must** use absolute `~/.claude/skills/build/…` paths, never relative markdown
  links, or the path-resolution bug fires when the skill runs globally. Baked into Task 2.

---

## Tasks

### Task 1: Builder & verifier subagent role-prompt files

**Description:** Author the two not-yet-existing subagent role prompts the orchestrator
will read and inject into `Task` dispatches. These encode the role split and the
honest-trust tool scopes (Design Decision 6) — the scopes are **instructions, not enforced
walls**.

**Files:**

- `.claude/skills/build/prompts/builder.md` - create
- `.claude/skills/build/prompts/verifier.md` - create

**Content:**

- **builder.md** — doer role. Tool scope: Read / Grep / Glob / **Write** / Edit / Bash
  (Write because most tasks add a new file). **Instructed off the check:** may _run_ the
  check but must not author or edit it. **No `Task` tool, no git** — dispatches nothing,
  commits nothing. Returns its diff/summary to the orchestrator.
- **verifier.md** — not-the-builder role. Tool scope: Read / Grep / Glob / Bash **plus
  Write** (to author the check file). Responsibilities: for a new-behavior task, **author
  the executable check from task intent _before_ the builder runs** (red→green); for an
  existing-signal task, **re-resolve** the command against the repo; tag un-checkable
  items `(manual)`. After the builder runs: **diff the builder's change** for weakened
  asserts / `exit(0)` stubs / edits to the check, and **render the gate** (no in-contract
  findings). **No `Task` tool, no git.**
- Both prompts state plainly that the tool scopes are **honest trust, not enforcement** (a
  builder with Bash could touch any file) — Guard 4 rests on the verifier's tamper-diff.

**Done when:**

- intent: both prompt files exist at the declared paths command:
  `ls .claude/skills/build/prompts/builder.md .claude/skills/build/prompts/verifier.md`
  _(candidate; /build re-resolves)_
- intent: builder is instructed off the check and declares no git / no Task; verifier
  declares Write-to-author-the-check, the red→green authoring boundary, the tamper-diff,
  and no git / no Task; both label the scopes as honest trust, not a wall manual: true

**Commit:** "Add builder + verifier subagent role prompts for orchestrator"

---

### Task 2: Orchestrator framing, state machine & dispatch+review loop

**Description:** Rework the heart of `build/SKILL.md`: add the `Task` tool, reframe the
role as orchestrator, and replace the single-agent "For Each Task" loop with the per-task
dispatch+review state machine. This is the core of Move 1.5.

**Files:**

- `.claude/skills/build/SKILL.md` - modify (frontmatter, "Your Role", "For Each Task"
  loop)

**Changes:**

- Frontmatter: `allowed-tools: Read, Grep, Glob, Write, Edit, Bash, Task`; keep
  `disable-model-invocation: true`.
- "Your Role" → **orchestrator**: it dispatches a builder and a separate verifier per
  task; it does **not** build or judge directly. State the two-role model.
- Add the per-task **state machine**:
  `todo → building → built → reviewing → done | back-to-building`.
- Replace the loop body with the dispatch+review loop:
  1. **Name the task** being dispatched (transparency — see Task 4).
  2. **Verifier authors/resolves the check** — for a new-behavior task the verifier writes
     the check from intent **before** the builder runs and confirms it starts **red**; for
     an existing-signal task it re-resolves the command; `(manual)` items are tagged, not
     run. Authoring only ever happens in not-the-builder.
  3. **Dispatch the builder** (reads `~/.claude/skills/build/prompts/builder.md`) with the
     task contract.
  4. **Run the resolved `done_when`** — exit 0 is half the gate.
  5. **Verifier diff + review** (reads `~/.claude/skills/build/prompts/verifier.md`) —
     reports in-contract findings and runs the tamper-diff (Task 3).
  6. **Outcome gate:** exit the task **only when `done_when` exits 0 AND the verifier
     reports no in-contract findings** — both visible in the transcript. Otherwise loop
     back to building with the carried-issue list (Task 3).
- Reference both prompt files by **absolute `~/.claude/skills/build/…` path** (relative
  links are the known path-resolution bug — backlog 2026-06-21).

**Done when:**

- intent: frontmatter adds `Task` while retaining `disable-model-invocation: true` and the
  six prior tools command: `grep -A1 'allowed-tools' .claude/skills/build/SKILL.md`
  _(candidate; /build re-resolves)_
- intent: SKILL.md states the orchestrator role and the
  `todo → building → built → reviewing → done` state machine command:
  `grep -niE 'orchestrat|todo.*building.*built.*reviewing.*done' .claude/skills/build/SKILL.md`
  _(candidate; /build re-resolves)_
- intent: the loop dispatches a builder and a _separate_ verifier, the verifier
  authors/resolves the check (red→green for new behavior) before the builder runs, and the
  outcome gate requires `done_when` exit 0 **and** no in-contract findings; prompt files
  are referenced by absolute `~/.claude/skills/build/…` path manual: true

**Commit:** "Rework build into orchestrator: state machine + dispatch/review loop"

---

### Task 3: Round cap, carried-issue list & Guard 4 tamper-diff

**Description:** Make non-convergence an escalation, not a hang, and make the
check-authoring boundary checkable. Both attach to the loop from Task 2.

**Files:**

- `.claude/skills/build/SKILL.md` - modify (loop continuation + a Guard 4 subsection)

**Changes:**

- **Round cap = 3 → escalate.** After 3 failed dispatch→review rounds the orchestrator
  **stops and escalates to the human** with the failing output rather than committing or
  looping forever.
- **Carried-issue list:** carry the prior round's finding list **verbatim** into the next
  dispatch; **silence ≠ fixed** — an issue drops only on confirmed-resolved. On context
  overflow, **chunk the review, never skip it.**
- **Guard 4 (tamper-diff):** the verifier diffs the builder's change for weakened asserts
  / `exit(0)` stubs / edits to the check file; **any of these is a hard fail**, not a
  fixable finding routed back into the loop. Label it as honest trust, not an OS-level
  wall.

**Done when:**

- intent: the round cap is 3 with escalation-on-cap, the prior finding list is carried
  verbatim, silence ≠ fixed, and context overflow chunks rather than skips command:
  `grep -niE 'three|3 round|round cap|verbatim|silence|chunk' .claude/skills/build/SKILL.md`
  _(candidate; /build re-resolves)_
- intent: Guard 4 tamper-diff (weakened assert / `exit(0)` stub / edited check) is a
  **hard fail**, explicitly not a fixable finding, and is labeled honest-trust-not-a-wall
  manual: true

**Commit:** "Add round cap, carried-issue list, and Guard 4 tamper-diff to orchestrator"

---

### Task 4: Transparency mandate & commit discipline

**Description:** Make the orchestrator's actions auditable and pin commit authority in one
place.

**Files:**

- `.claude/skills/build/SKILL.md` - modify (transparency subsection + "Handling
  Deviations"/commit rules)

**Changes:**

- **Transparency:** the orchestrator **prints every subagent report in full** before
  acting on it, **names the task** it is dispatching before each round, and **every
  escalation names its trigger** (cap / ambiguity / out-of-scope file) so the human never
  guesses which path fired.
- **Commit discipline — sole committer:** the orchestrator commits **once per verified
  task**, staging only that task's **declared files by explicit path** (never
  `git add -A`), **including the verifier-authored check file**. Builder subagents never
  touch git.
- **Undeclared-file judgment:** the verifier surfaces any file the builder touched that
  the task did not declare; the orchestrator judges scope at commit — **in-scope → stage
  by path**; **out-of-scope → escalate as an approve-by-exception event** (trigger named).
  No silent staging.

**Done when:**

- intent: the orchestrator prints every subagent report in full, names the task before
  each round, and names the trigger on every escalation manual: true
- intent: sole-committer discipline (one commit per verified task, explicit-path staging
  incl. the check file, builder never commits) and the in-scope-stage / out-of-scope-
  escalate rule for undeclared files are present command:
  `grep -niE 'sole committer|explicit path|git add -A|undeclared|out-of-scope' .claude/skills/build/SKILL.md`
  _(candidate; /build re-resolves)_

**Commit:** "Add transparency mandate and sole-committer discipline to orchestrator"

---

### Task 5: End-of-batch review re-scope & Rules update

**Description:** Re-scope the retained end-of-batch review to the job a per-task verifier
structurally cannot do, and align the Rules section with the orchestrator model.

**Files:**

- `.claude/skills/build/SKILL.md` - modify ("End-of-Batch Review" + "Rules")

**Changes:**

- **Re-scope the end-of-batch review** to **cross-task / integration coherence** —
  interactions between tasks that no single-task-contract verifier sees. It is explicitly
  **not** a second per-task pass over all-green work (that would be the rubber-stamp the
  surrogation-recursion risk warns against). It still surfaces `(manual)` items and
  "compiles, behavior unverified" shallow proxies **separately** — not folded into the
  green. Keep the `<base>..HEAD` framing, deviations-first, and test-file-diff surfacing.
- **Rules:** update for the orchestrator role, the `Task` tool, and the sole-committer
  discipline (builder/verifier never touch git; the orchestrator alone commits). Preserve
  the Move-1 rules that still hold (sequential, approve-by-exception, stay local, slash
  commands only, one phase per session).

**Done when:**

- intent: the end-of-batch review is re-scoped to cross-task / integration coherence (not
  a second per-task pass) and still surfaces `(manual)` and "compiles, behavior
  unverified" separately manual: true
- intent: the Rules section reflects the orchestrator role, the `Task` tool, and
  sole-committer discipline command:
  `grep -niE 'orchestrat|sole committer|Task|cross-task|integration' .claude/skills/build/SKILL.md`
  _(candidate; /build re-resolves)_

**Commit:** "Re-scope end-of-batch review to cross-task coherence; update Rules"

---

### Task 6: Throwaway validation plan artifact (Tasks 0–5, covering A1–A11)

**Description:** Author the throwaway validation plan the Validation Run will exercise. It
is a sandbox artifact, discarded after harvest — the same disposition Move 1 used.

**Files:**

- `docs/research/workflow-upgrade/2026-06-25-move-1.5-validation-plan.md` - create

**Content:** the six validation tasks from the design spec's Validation Plan, each mapped
to the criteria it exercises:

- **Task 0** — clean new-behavior task (one `(manual)` check, one shallow grep-proxy,
  **establishes an interface** Task 4 consumes) → A1, A2 (positive), A3, A5, A6, A8; the
  non-ambiguous control for A9.
- **Task 1** — check fails ≥3× → drives the round cap → A4.
- **Task 2** — genuine plan ambiguity → trips approve-by-exception → A9.
- **Task 3** — injected tamper (hand-weaken an assert / stub `exit(0)` after the builder
  runs) → verifier hard-fails → A7.
- **Task 4** — cross-task interaction: individually green but breaks the Task 0 ↔ Task 4
  pair → end-of-batch must catch it → A10.
- **Task 5** — out-of-scope undeclared file → orchestrator escalates with trigger named;
  paired against Task 0's in-scope-only commit → A11.
- Header marks it **throwaway** (sandbox + plan on a harvest branch, discarded after
  harvest).

> **⚠️ Authoring trap — A10 is the easiest task in the bundle to fake.** For the
> end-of-batch review to _prove_ anything, Task 4 must be **honestly green under its own
> verifier** while the **Task 0 ↔ Task 4 interaction** is broken. Two ways it collapses:
> (a) Task 4's per-task verifier catches the fault → it was a single-task bug, not
> cross-task, and A10 proves nothing; (b) nothing catches it → A10 fails for the wrong
> reason. Author for these properties:
>
> 1. **Put the mismatch between the two intents, owned by neither.** You write the task
>    _intents_, not the checks — the verifier authors each check from intent at run time.
>    So the fault must live in a **shared assumption about Task 0's interface that neither
>    Task 0's nor Task 4's intent names**: Task 0 emits under assumption X, Task 4
>    consumes under X′. Each intent is internally truthful; the disagreement sits in the
>    gap.
> 2. **Each side must be legitimately verifiable in isolation** (Task 4's verifier may
>    stand in a stub/fixture for Task 0's half). The greenness must be _real_: if you
>    deleted the cross-task bug, Task 4's verifier should **still** be a meaningful check
>    of Task 4's intent. A check that passes only because it's blinded/under-specified is
>    faking, not testing.
> 3. **Make the integration concretely observable** over `<base>..HEAD` — an actual path
>    where Task 0's real output meets Task 4's real consumer and visibly breaks, so the
>    review has something to catch (not just a notional mismatch).
>
> **Falsification test before shipping Task 6:** with the mismatch present, both per-task
> verifiers are **green** and the integration is **red**; remove the mismatch and the
> integration goes **green** while the per-task verifiers **stay green either way**.
> Red→green at _integration_ scope, with the unit checks unmoved in both directions, is
> the signature of an honest cross-task fault. If you can't make it swing that way, A10
> isn't real yet.

**Done when:**

- intent: the validation plan exists with six tasks (0–5) and is marked throwaway command:
  `ls docs/research/workflow-upgrade/2026-06-25-move-1.5-validation-plan.md` _(candidate;
  /build re-resolves)_
- intent: every criterion A1–A11 is referenced by at least one of the six tasks command:
  `grep -oE 'A1?[0-9]' docs/research/workflow-upgrade/2026-06-25-move-1.5-validation-plan.md | sort -uV`
  _(candidate; /build re-resolves; expect A1–A11 all present)_

**Commit:** "Add throwaway Move 1.5 validation plan (6 tasks, A1–A11)"

---

### Task 7: Record deferrals in backlog

**Description:** Put the named deferrals on the record so the minimal-cut boundary is
explicit and the additive next moves are tracked.

**Files:**

- `docs/backlog.md` - modify (append a dated section)

**Changes:** append a `## 2026-06-25: Move 1.5 orchestrator deferrals` section recording:
**reviewer multiplicity / adversarial panel** (the single-unchecked-verifier residual
risk), **stakes-to-scale routing** (trivial tasks skipping the verifier round),
**mechanical write-lockout** for Guard 4 (path-scoping / pre-commit hook — the natural
next move if the tamper-diff proves insufficient), and **model tiering** (cheap builder /
expensive verifier — a tunable, not proven). Cross-reference the design spec.

**Done when:**

- intent: backlog records all four deferrals with a dated section command:
  `grep -niE 'reviewer multiplicity|stakes|write-lockout|model tier' docs/backlog.md`
  _(candidate; /build re-resolves)_

**Commit:** "Record Move 1.5 deferrals in backlog"

---

## Validation Run (separate window — fed back to this `/build` session)

> **Not a build-session task.** The `/build` session executes **Tasks 1–7 only**, then
> proceeds to its End-of-Batch Review and AC gate. This run happens **after** Task 7, in a
> **separate window**, and its results are **fed back to the same paused `/build` agent**
> at the AC gate — that feedback verifies A1–A11 and flips the plan to Complete. A
> `/build` cannot run another `/build`, but it can pause and ingest a run performed
> elsewhere.

**Purpose:** run the new orchestrator against the Task 6 validation plan and harvest the
result — the only way the behavioral criteria A1–A11 become observable.

**Procedure:**

1. **(window B)** Run `scripts/sync-skills.sh` so the new orchestrator `build` skill +
   prompt files are active in `~/.claude/skills/` (else the run exercises the old
   single-agent skill).
2. **(window B)** Branch a **throwaway** off the machinery commit (Tasks 1–7), so the run
   has the orchestrator to exercise.
3. **(window B)** Run the new `/build` against the 6-task validation plan end-to-end,
   observing each criterion: builder + separate verifier (A1), happy-path exit (A2/A5/A6),
   round-cap escalation (A4), tamper hard-fail by injection (A7), ambiguity fires /
   non-ambiguous stays silent (A9), cross-task catch at end-of-batch (A10),
   undeclared-file stage-vs-escalate judgment (A11), `(manual)`/compiles-unverified
   surfaced separately (A8), transparency (A3). Watch the surrogation tell ("did it pass?"
   replacing "is it right?"). Discard the throwaway branch after capturing observations.
4. **(window A — feed back)** Return to the **paused build session** and report the A1–A11
   observations. That session — the **sole committer and sole `[x]` authority** — writes
   the harvest doc, **commits it on `feat/build-phase-move-1.5`**, marks A1–A11 from the
   fed-back results, and announces Phase Complete.

**Closure conditions (verified back in window A):**

- intent: the new orchestrator `/build` ran the 6-task validation plan end-to-end on a
  throwaway branch and all eleven criteria A1–A11 were observed (not inferred), and the
  observations were fed back to the paused build session manual: true
- intent: the build session committed a harvest doc capturing the run and the A1–A11
  outcomes command:
  `ls docs/research/workflow-upgrade/2026-06-25-move-1.5-validation-harvest.md`
  _(candidate; /build re-resolves)_

**Commit (by the build session, on feed-back):** "Add Move 1.5 validation harvest notes"

---

## Acceptance Criteria

> Provenance-tagged ledger. **Every** criterion from the design spec appears below, tagged
> with what happened to it — plus any criteria this plan adds. A criterion that won't be
> met here is struck through, never deleted: an omission must read as a struck line, never
> an absence.
>
> | Tag                   | Meaning                                               |
> | --------------------- | ----------------------------------------------------- |
> | `(design)`            | Carried from the design spec (verbatim or reworded)   |
> | `(added)`             | New criterion this plan introduces                    |
> | `(deferred → target)` | Belongs to a later plan/phase — strike the line       |
> | `(dropped — reason)`  | Intentionally not done, with reason — strike the line |
>
> The **active gate** is the unstruck items — `(design)` + `(added)`. `/build` verifies
> those and records, but does not verify, the struck (deferred/dropped) items.
>
> **Note on A1–A11:** these are **behavioral** — provable only by running the
> orchestrator, which a `/build` cannot do to itself. They stay **active**. At this AC
> gate, present them as manual criteria and **pause**: the user performs the **Validation
> Run** (above) in a separate window and feeds the harvest back to _this same session_.
> Then record the harvest, commit it, mark A1–A11 from the fed-back results, and announce
> Phase Complete. Do **not** fail them for being unconfirmed before the run, and do
> **not** reach Phase Complete until they are fed back and marked. The build session's own
> active gate is **A12–A16** (machine/inspection-verifiable in-session).

- [x] **A1.** On a substantive task, `/build` dispatches a builder subagent and a
      _separate_ verifier subagent — observably not one agent self-grading. `(design)`
- [x] **A2.** The loop exits a task only when `done_when` exits 0 **and** the verifier
      reports no in-contract findings; both conditions are visible in the transcript, and
      the positive/happy-path case is demonstrated (not only the failure case). `(design)`
- [x] **A3.** Every subagent report is printed in full before the orchestrator acts on it,
      the task is named before each round, and any escalation names its trigger (cap /
      ambiguity / out-of-scope file). `(design)`
- [x] **A4.** On a task whose check keeps failing, the loop re-dispatches with the carried
      finding list; after 3 failed rounds it stops and escalates to the human rather than
      hanging or committing. `(design)`
- [x] **A5.** For a new-behavior task, the verifier authors the check **before** the
      builder runs, and the check starts **red**. `(design)`
- [x] **A6.** The builder never authors/edits the check and never commits; the
      orchestrator commits exactly once per verified task, staging only that task's
      declared files — including the verifier-authored check file. `(design)`
- [x] **A7.** When check-tampering is present in the builder's diff (weakened assert,
      `exit(0)` stub, edited check), the task **hard-fails** — not routed as a fixable
      finding. Validated by injection. `(design)`
- [x] **A8.** `(manual)` items and "compiles, behavior unverified" shallow proxies surface
      _separately_ at end-of-batch — not folded into the green. `(design)`
- [x] **A9.** A task with genuine plan ambiguity trips approve-by-exception escalation,
      and a non-ambiguous task does **not** — the human-by-exception path fires when it
      should and stays silent when it shouldn't. `(design)`
- [x] **A10.** The end-of-batch review catches a defect invisible at single-task scope — a
      fault in the _interaction_ between two tasks, each of which passed its own per-task
      verifier. `(design)`
- [x] **A11.** When the builder touches an undeclared **out-of-scope** file, the
      orchestrator escalates as approve-by-exception rather than silently staging it; an
      undeclared **in-scope** touch stages by path without escalating. `(design)`
- [x] **A12.** `build/SKILL.md` frontmatter lists
      `Read, Grep, Glob, Write, Edit, Bash,     Task` and retains
      `disable-model-invocation: true`. `(added)`
- [x] **A13.** `.claude/skills/build/prompts/builder.md` and `verifier.md` exist with the
      pinned tool scopes, both declaring **no git / no Task**; the builder is instructed
      off the check; the verifier has Write to author it; the scopes are labeled
      honest-trust, not a wall. `(added)`
- [x] **A14.** `build/SKILL.md` references the prompt files by absolute
      `~/.claude/skills/build/…` path (not a relative link). `(added)`
- [x] **A15.** The throwaway validation plan exists with six tasks (0–5) collectively
      referencing all of A1–A11, marked throwaway. `(added)`
- [x] **A16.** `docs/backlog.md` records the four deferrals (reviewer multiplicity, stakes
      routing, mechanical write-lockout, model tiering). `(added)`

---

## Completion

**Completed:** 2026-06-25 **Final Status:** Complete

**Summary:** `/build` was converted from a single self-grading agent into a per-task
orchestrator. Two subagent role prompts were authored (`prompts/builder.md`,
`prompts/verifier.md`) with honest-trust tool scopes — neither touches git or `Task`. The
SKILL.md heart was reworked: `Task` added to frontmatter (keeping
`disable-model-invocation: true`), the role reframed to orchestrator, and the single-agent
loop replaced with a `todo → building → built → reviewing → done` state machine whose
dispatch+review loop has the verifier author/resolve the check (red→green for new
behavior) **before** the builder runs, then diff the builder's change and render the gate
— exit only on `done_when` exit 0 **and** no in-contract findings. A round cap of 3 (then
escalate), a verbatim carried-issue list (silence ≠ fixed, chunk-don't-skip on overflow),
and a Guard 4 tamper-diff hard-fail were added. Transparency (print every report, name the
task, name the escalation trigger) and sole-committer discipline (one commit per verified
task, explicit-path staging incl. the check file, builder/verifier never touch git) were
pinned. The retained end-of-batch review was re-scoped to cross-task/integration coherence
(not a second per-task pass), still surfacing `(manual)` and "compiles, behavior
unverified" separately. A throwaway 6-task validation plan and the backlog deferrals were
recorded.

The Validation Run was executed in a separate window (throwaway branch
`feat/build-phase-move-1.5-harvest`, `sandbox/move-1.5/`) and **fed back to this paused
build session**: all eleven behavioral criteria A1–A11 were observed (not inferred) —
including the A10 falsification (per-task green both ways; integration red→green only when
the Celsius/Fahrenheit unit mismatch is removed) — and A1–A16 are all marked `[x]`.

**Deviations from Plan:** None — all seven build tasks and the fed-back Validation Run
executed as planned. (`sync-skills.sh` staying untouched was predicted in the plan's
Discrepancies; the orchestrator's run-commits living off-branch is the plan's named
"Inherent trade." Neither is a departure.)

**Additions beyond plan (not deviations):** One extra backlog commit (`cbcd974`) beyond
Task 7. Task 7 / A16 named four deferrals; a post-build spec-vs-backlog completeness check
found the design spec's "Out of Scope" section had deferred three more that went
unrecorded — parallel-task worktree isolation, crash/stale-state recovery, and the ed3d
zero-Minor procedure gate. Added so the backlog carries the spec's full deferral list.

---

## Notes

- **Build session vs. Validation Run.** Tasks 1–7 are the build session (machinery,
  self-verified by inspection — A12–A16). The **Validation Run** is performed in a
  separate window and **fed back to the same paused `/build` session** at the AC gate,
  which marks A1–A11 and gives one clean Phase Complete → `/document`. The plan is
  "Complete" only after that feedback lands. (Move 1 split its final task into an
  in-session scaffold + a separate run; here the run is pure side-window, fed back, so it
  sits outside the task list.)
- **Inherent trade.** The orchestrator is exercised on a throwaway branch, so
  `feat/build-phase-move-1.5` carries the **harvest doc** but not the run's own commits —
  the proof lives in the harvest capture, fed back into the session that marks A1–A11.
  Unavoidable while a `/build` can't nest itself.
- **Guard 4 is honest trust, not a wall.** The tool scopes give zero enforcement (a
  builder with Bash can touch any file); Guard 4 rests entirely on the verifier's
  tamper-diff. The mechanical write-lockout is the deferred next move (backlog), not part
  of this cut.
- **Surrogation recursion** (residual risk): moving the human to end-of-batch over green
  checkmarks is the auto-yes relocated up a level. The end-of-batch review must stay a
  real evaluation. The first-run tell to watch: "did it pass?" replacing "is it right?".
- **`sync-skills.sh` unchanged** — it already `cp -R`s the whole `build/` dir, so the new
  `prompts/` files sync for free; markdown has no exec bits. The Validation Run must still
  run it before exercising the new skill.
- **`/document` + changelog** are Phase 3, out of scope here.
- **Source material:** design spec `2026-06-25-1654-build-phase-move-1.5-orchestrator.md`;
  Move 1 harvest `docs/research/workflow-upgrade/2026-06-25-move-1-validation-harvest.md`;
  `build-as-orchestrator.md` and `workflow-upgrade-path.md` (same dir).
