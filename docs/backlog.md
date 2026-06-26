# Backlog

Open ideas and improvements for the Claude Development Workflow.

---

## 2026-01-16: Design Spec Status Field

**Idea:** Add a status field to design spec template:

```markdown
**Status:** Draft | Ready | In Progress | Complete
```

**Why:** When multiple design specs exist, this helps identify which ones are ready to be
picked up for implementation vs. still being refined.

**Noted:** Noted 2026-01-16 in
docs/design-specs/2026-01-16-decouple-design-from-implementation.md

---

## 2026-01-27: Design Scope and Documentation Drift

**Source:** Craft CMS + Next.js Integration retrospective

### The Problem

A 10-task design spanning Craft CMS configuration and Next.js integration became difficult
to manage. Multiple architectural pivots (Draft Mode → query param preview) caused
documentation drift. By Task 9, original specs were stale and multiple docs were out of
sync.

### Root Cause

The `/document` phase wasn't run between Plan 1 (Craft setup) and Plan 2 (Next.js code).
This meant:

1. Plan 2's assumptions (e.g., `CRAFT_PREVIEW_TOKEN` env var) were based on Plan 1's
   _design_ rather than its _actual outcome_
2. Deviations compounded without a checkpoint to catch them
3. The Build Log grew unwieldy, mixing two distinct phases of work

### Lesson Learned

**The `/document` phase is a synchronization checkpoint, not just bookkeeping.**

It forces you to:

- Reconcile what was planned vs. what was built
- Update specs before dependent work begins
- Keep the Build Log focused on a single coherent scope
- Update onboarding paths (README) when implementation changes affect setup steps,
  commands, or dependencies

### Guidelines

1. **5 tasks max per design** — If it's bigger, it's probably two features
2. **Split by system boundary** — "CMS setup" and "frontend code" are separate designs
3. **One design = one `/document`** — Complete the cycle before starting dependent work
4. **Drift is inevitable; checkpoints catch it** — The longer between `/document` phases,
   the more drift accumulates

---

## 2026-01-27: Document phase serves two distinct purposes

Context: The Document phase can feel like busywork — just filling in completion sections.
But it serves two non-obvious functions beyond record-keeping.

Purpose 1: Catches drift Comparing the original plan to what was actually built surfaces
deviations that should be recorded. Implementation often requires adapting to discovered
realities — different library versions, APIs that work differently than expected,
approaches that turned out to be unnecessary. These aren't failures; they're adaptations.
The Document phase ensures they're captured rather than lost.

Purpose 2: Updates the onboarding path Implementation changes often affect how new
developers set up or use the project. Without updating the README during documentation,
the next person to clone the repo won't know about new setup steps, changed commands, or
added dependencies.

Takeaway: Don't treat /document as just "fill in the completion section." It's the
checkpoint that ensures both the historical record and the living documentation (README)
stay accurate.

---

## 2026-02-18: Folder-as-Status System for Design Specs and Implementation Plans

**Idea:** Use folder structure to indicate document status instead of metadata fields:

```
docs/design-specs/active/
docs/design-specs/complete/
docs/implementation-plans/active/
docs/implementation-plans/complete/
```

**Why:** Moving a file between folders is a clear, visible status change. No need to open
the file to check its status. Makes it easy to see what's in progress vs. done at a
glance.

**Origin:** Noted as out of scope in the "Decouple /design from Other Phases" design spec
(2026-02-18).

---

## 2026-03-26: `/learn-by-doing` Stuck Escalation Pacing

**Problem:** The stuck escalation sequence (hint → pointed question → point to pattern →
show answer) doesn't reliably pause between steps. Observed behaviors:

1. **Steps combined into one response** — hint and pointed question delivered together
   instead of pausing for input between each step
2. **Steps skipped entirely** — for "small" questions (e.g., `chmod +x`), jumped straight
   to showing the answer without attempting earlier escalation steps

**Expected:** Each escalation step should be a separate response with a pause for user
input, matching the pause-for-input protocol used elsewhere in the skill. The sequence
should apply regardless of how "simple" the question seems.

**Root cause (suspected):** The skill instructions say "move to the next step only if the
current one doesn't unblock them" but don't explicitly state that each step requires a
pause-for-input. The LLM may also be inferring that trivial questions don't warrant the
full sequence.

**Possible fixes:**

- Add explicit "pause for input after each escalation step" instruction
- Add an example showing the full 4-step sequence with pauses
- Emphasize that escalation applies to all stuck moments, not just "hard" ones

**Origin:** Validation testing of `/learn-by-doing` (2026-03-26). Acceptance criterion 5
remains the only failing criterion.

---

## 2026-06-21: Guardrail Against Relative Support-File Links in Skills

**Idea:** Add an automated check that fails when any `SKILL.md` references a supporting
file (`resources/`, `templates/`, etc.) with a relative markdown link instead of an
absolute `~/.claude/skills/<skill>/...` path.

**Why:** Relative links trigger the path-resolution bug documented in
[2026-03-05-skill-relative-path-resolution.md](issues/2026-03-05-skill-relative-path-resolution.md)
— when a skill runs globally, Claude resolves the link against the invoking project's
working directory, fails to find the file, and improvises. The fix has now been applied
inconsistently twice (caught in `design`/`plan`, missed in
`learn-by-doing`/`study-partner` until a later audit). A check would stop the pattern from
being reintroduced.

**Sketch:** A grep over `.claude/skills/**/SKILL.md` for `](resources/`, `](templates/`,
etc. (links that start with a bare support-dir name rather than `~`). Could run
standalone, be wired into `sync-skills.sh`, or fire from a pre-commit hook. Open question:
enforcement point and whether to also verify linked files exist.

**Origin:** Built and removed during the 2026-06-21 fix for the inconsistent path
workaround; demoted to backlog pending a decision on where enforcement should live.

---

## 2026-06-25: Move 1.5 orchestrator deferrals

The minimal-provable-cut boundary of Move 1.5 (`/build` as orchestrator — design spec
[`2026-06-25-1654-build-phase-move-1.5-orchestrator.md`](design-specs/2026-06-25-1654-build-phase-move-1.5-orchestrator.md)).
Each item below was deliberately left out of that cut; all are **additive** next moves,
recorded so the boundary is explicit rather than silent.

**1. Reviewer multiplicity / adversarial panel.** Move 1.5 runs a **single** verifier per
task that authors the check, judges it, and renders the gate — and nothing checks the
verifier. A confidently-wrong or vacuous check (passes while proving nothing) would not be
caught. The next move is a second lens — multiple verifiers (e.g. correctness + security)
or an adversarial refute-pass — so the verifier is no longer the single unchecked
authority. Named as a residual risk in the design spec.

**2. Scale-to-stakes routing.** This cut runs the **full** dispatch+review loop on
**every** task, including one-liners — ceremony-mismatch on trivial tasks is accepted for
now. The deferred move is routing: let trivial/low-stakes tasks skip the verifier round
(or run a lighter gate) while substantive tasks get the full loop. A tunable, not proven
here.

**3. Mechanical write-lockout for Guard 4.** Guard 4 (the check-authoring boundary) rests
**entirely on the verifier's tamper-diff** — honest trust, zero enforcement: a builder
holding Bash can touch any file regardless of its tool grants. The natural next move **if
the tamper-diff proves insufficient** is a real mechanical lock — path-scoping the
builder's writes or a pre-commit hook so the builder physically cannot touch the check.
Deferred (not rejected) because the lock adds harness machinery, and a PreToolUse hook is
itself shell-on-every-call risk.

**4. Model tiering.** The role split (doer vs. judge) is load-bearing; the specific model
assignment is **not**. Dispatching the builder at a cheap tier and the verifier at an
expensive one is a tunable left for after the loop is shown to converge — the role split,
not the model IDs, is what's proven.

**5. Parallel-task worktree isolation.** This cut keeps the loop **sequential** — one task
fully through `done` before the next starts. The deferred move is running independent
tasks concurrently, each builder/verifier pair in its own git worktree so parallel edits
can't collide. Out of scope here because sequential is simpler to spec and prove; worktree
isolation is the natural enabler once the single-task loop is trusted.

**6. Crash / stale-state recovery.** Move 1.5's only recovery story is "re-derive `done`
from the git commit + `done_when`" — a task's commit exists iff it passed, so a crashed
session re-reads state from git. Anything richer (resuming a half-built task mid-loop,
recovering an in-flight subagent, a durable state file) is deferred. Adequate for now
because the commit-as-proof model degrades gracefully; revisit if mid-loop crashes prove
costly.

**7. ed3d procedure gate (zero-Minor-or-bust).** Move 1.5 ships the **outcome gate** (exit
on `done_when` pass + review clean, scoped to the task contract), not the stricter
procedure gate that blocks on zero issues in every category including Minor. Per Design
Decision 3 this was a deliberate fork with a **revisit trigger**: if the first real
orchestrator runs ship Minor-grade rot that the end-of-batch review keeps catching,
escalate toward a _scoped_ procedure gate (still off the human). Recorded so the fork
stays revisitable rather than settling silently.

**Origin:** Recorded at the close of the Move 1.5 build (plan
[`2026-06-25-1735-build-phase-move-1.5-orchestrator.md`](implementation-plans/2026-06-25-1735-build-phase-move-1.5-orchestrator.md),
Task 7). See the design spec's "Out of Scope" and "Residual Risks" sections for the full
rationale.
