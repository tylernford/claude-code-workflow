# Implementation Plan: Build Phase — Move 1: Approve-by-Exception + Executable `done_when`

**Created:** 2026-06-25 **Type:** Process **Overview:** Rework single-agent `/build` to
approve-by-exception with executable per-task checks, an end-of-batch review, and git as
the handoff — dropping the hand-maintained Build Log. **Design Spec:**
docs/design-specs/2026-06-25-1438-build-phase-move-1.md

---

## Summary

Rework the single-agent `/build` phase along four lines, with matching edits to
`/document` and the plan template:

- **§0** — Honest `allowed-tools` (`+Write, Edit, Bash`) and a narrowed git rule (`/build`
  commits on the current branch with explicit-path staging only; `/document` reads git
  only).
- **§1** — Stop pausing per task; default is **proceed**, escalate by exception; bound the
  verify→fix cycle at **three attempts**.
- **§2** — Per-task `done_when` becomes **intent** (locked in the plan) + **command**
  (resolved at build, never lifted verbatim); `(manual)` is first-class; shallow checks
  are labeled "compiles, behavior unverified."
- **§3** — `<base>` snapshot at session start; one loaded-in end-of-batch review over
  `<base>..HEAD`; the AC gate auto-runs active executable items and presents `(manual)`
  ones.
- **§4** — Delete the per-task Build Log table everywhere; deviation rationale moves to
  the commit body; `/document` Step 1 is repointed at `git log`.

Plus a **validation run** of the new `/build` against a small plan, harvesting four
specific observations as design input for Move 1.5.

Scope is **single-agent only** — the orchestrator, honesty-gate ritual, and write-lockout
are explicitly deferred to Move 1.5.

---

## Codebase Verification

_Confirmed against the actual files on 2026-06-25._

- [x] `build/SKILL.md` frontmatter = `Read, Grep, Glob` +
      `disable-model-invocation: true` - Verified: yes (lines 1-4).
- [x] `build/SKILL.md` has per-task **Pause** (step 7) and **Log** (step 5) steps, an
      "After All Tasks" prompt ("Run acceptance criteria?"), a Build Log table under
      "Handling Deviations", a "Build Log updated in:" line in Phase Complete, and Rules
      "One task at a time" / "User confirms" / "Update Build Log" / "No git operations" -
      Verified: yes, all present.
- [x] `document/SKILL.md` frontmatter matches build; Step 1 says "Review the Build Log
      entries", Step 2.3 is "Review Build Log", changelog uses "Key files", PR draft
      "Changes" sources from the Build Log, Rule 5 is "No git operations" - Verified: yes.
- [x] Plan template (`.claude/skills/plan/templates/implementation-plan.md`) has a Build
      Log table section and a prose `Done when:` field - Verified: yes.
- [x] Spine-validator schema for §2 forward-compat exists at
      `docs/research/workflow-upgrade/2026-06-25-spine-validator.md`: a `done_when` item
      is `intent` + **exactly one** of `command:` / `manual: true` - Verified: yes.

**Patterns to leverage:**

- `scripts/sync-skills.sh` copies `design/plan/build/document` from the repo's
  `.claude/skills/` into `~/.claude/skills/`. The repo files are the **source of truth**;
  edits land there. The new skills must be **synced before the validation run** (Task 7)
  or the run exercises the old code.
- The acceptance-criteria carry-forward ledger (commit `3c3c0d8`) is the live source of
  truth for AC. Move 1 layers auto-run + one-human-review on top of it; it does **not**
  modify the ledger mechanism.

**Discrepancies found:**

- None. Every design-spec assumption matches the codebase.

---

## Tasks

### Task 1: §0 foundation — honest frontmatter + narrowed git rule (both skills)

**Description:** Make `allowed-tools` honest and narrow the no-git rule in place, in both
skills. This is the foundation — nothing else is real until the skill can actually run
`Bash`/`git`/write files without re-prompting. **Files:**

- `.claude/skills/build/SKILL.md` - modify (frontmatter + Rule 7)
- `.claude/skills/document/SKILL.md` - modify (frontmatter + Rule 5)

**Changes:**

- Both frontmatters: `allowed-tools: Read, Grep, Glob, Write, Edit, Bash`; keep
  `disable-model-invocation: true`.
- `build` Rule 7 → narrowed: may read git and commit a completed task on the **current
  branch only**, staging the files that task **actually changed** by **explicit path**
  (never `git add -A`); forbids push, force-push, rebase, reset, branch deletion, any
  remote op.
- `document` Rule 5 → narrowed: may read git only, **never commits**; same prohibitions on
  remote/history ops.

**Done when:**

- intent: both frontmatters list the six tools and retain `disable-model-invocation: true`
  command:
  `grep -A1 'allowed-tools' .claude/skills/build/SKILL.md .claude/skills/document/SKILL.md`
  _(candidate; /build re-resolves)_
- intent: build Rule 7 and document Rule 5 are the narrowed forms (read-only git
  everywhere; build commits current-branch/explicit-path-only; document never commits)
  manual: true

**Commit:** "Add §0: honest allowed-tools and narrowed git rule in build/document"

---

### Task 2: build §1+§2 — rework "For Each Task" loop and Rules

**Description:** Replace the per-task approval loop with approve-by-exception, fold in
build-time command resolution, and add the three-round cap. **Files:**

- `.claude/skills/build/SKILL.md` - modify ("For Each Task" + Rules sections)

**Changes:**

- New loop: Announce → **Resolve check** (resolve the locked `intent` to a real command
  against the repo; never lift the candidate verbatim from the plan) → **Implement** →
  **Run resolved command** (exit 0 = the gate; re-resolve if the task deviated mid-task;
  record "compiles, behavior unverified" when the command is only a shallow proxy;
  `(manual)` intents are noted, not counted as done) → **Commit** (explicit-path staging;
  deviation rationale in the commit body) → **proceed** (no pause).
- **Three-attempt cap:** bound verify→fix→re-run at 3 attempts per task's check; on the
  3rd consecutive failure, stop and **escalate** to the user with the failing output.
- **Approve-by-exception clause:** default is proceed; escalate only on (a) a check still
  failing after the cap, (b) a genuine plan ambiguity, or (c) an irreversible/out-of-scope
  action.
- Remove the per-task **Pause** (old step 7) and **Log** (old step 5) steps.
- Rules: "One task at a time" → **"Sequential execution"** (sequential ≠ per-task approval
  gate); "User confirms" → **"Approve by exception"**; **remove** the "Update Build Log"
  rule.

**Done when:**

- intent: the "For Each Task" loop has no per-task pause, resolves the check before
  implementing, runs the resolved command as the exit-0 gate, and commits then proceeds
  manual: true
- intent: the three-attempt cap and escalation-with-output are present command:
  `grep -niE 'three|3 attempt|escalat' .claude/skills/build/SKILL.md` _(candidate; /build
  re-resolves)_
- intent: Rules read "Sequential execution" and "Approve by exception"; "Update Build Log"
  rule is gone command:
  `grep -niE 'sequential execution|approve by exception|update build log' .claude/skills/build/SKILL.md`
  _(candidate; /build re-resolves)_

**Commit:** "Rework build loop: approve-by-exception, executable checks, 3-round cap"

---

### Task 3: build §3 — `<base>` definition + end-of-batch review and AC gate

**Description:** Add the `<base>` snapshot and replace the interactive "After All Tasks"
acceptance loop with one loaded-in review plus an auto-run AC gate. **Files:**

- `.claude/skills/build/SKILL.md` - modify (new `<base>` definition near top + "After All
  Tasks" section)

**Changes:**

- Define `<base>` **once near the top** of the skill: `git rev-parse HEAD` snapshotted at
  the start of the build session. Add the resumed-build fallback note (re-snapshot; review
  covers only this session's commits).
- Replace "After All Tasks": present the batch **once** for one human review over
  `<base>..HEAD` — diff + commit list, **deviations first**, `(manual)` items separately,
  **verified-vs-just-compiled** per task, and **test-file diffs surfaced explicitly**.
- AC gate: run the plan's **active (unstruck)** `(design)`/`(added)` executable checks
  **automatically**; present `(manual)` ones to the user; struck `(deferred)`/`(dropped)`
  items are recorded, not verified. Drop the old "Run acceptance criteria?" prompt.
  `/build` remains the sole authority for marking `[x]`; the AC carry-forward ledger is
  preserved unchanged.

**Done when:**

- intent: `<base>` is defined exactly once near the top as a session-start
  `git rev-parse HEAD` snapshot command:
  `grep -nB1 -A2 'rev-parse HEAD' .claude/skills/build/SKILL.md` _(candidate; /build
  re-resolves)_
- intent: "After All Tasks" presents one review over `<base>..HEAD` with all four
  surfacings (deviations first, manual separately, verified-vs-compiled, test-file diffs)
  and auto-runs active executable AC while presenting manual AC; the old prompt is gone
  manual: true

**Commit:** "Add end-of-batch review and auto-run AC gate to build"

---

### Task 4: build §4 — deviations to commit body + Phase Complete cleanup

**Description:** Remove the Build Log table from `/build` and route deviation rationale to
git, including the undeclared-file staging case. **Files:**

- `.claude/skills/build/SKILL.md` - modify ("Handling Deviations" + Phase Complete)

**Changes:**

- "Handling Deviations": remove the Build Log table and example rows; route the why to the
  **commit body**. Add the staging case: a deviation that touches an **undeclared** file
  stages that file by explicit path and records it (file + why) in the commit body, **or
  escalates** if the touch is out-of-scope — never a silent dirty-tree drop, never
  `git add -A`.
- Phase Complete: remove the "Build Log updated in:" line.

**Done when:**

- intent: no Build Log table remains in build/SKILL.md and the Phase Complete "Build Log
  updated in:" line is gone command:
  `grep -niE 'build log|\| date \|' .claude/skills/build/SKILL.md` _(candidate; /build
  re-resolves; expect no matches)_
- intent: "Handling Deviations" routes the why to the commit body and covers the
  undeclared-file stage-by-path-or-escalate rule (no `git add -A`) manual: true

**Commit:** "Drop Build Log from build: deviations to commit body, fix Phase Complete"

---

### Task 5: plan template §2+§4 — intent/command `done_when` + remove Build Log table

**Description:** Update the plan template so `Done when:` carries the intent + optional
candidate command form, and remove the Build Log table section. **Files:**

- `.claude/skills/plan/templates/implementation-plan.md` - modify

**Changes:**

- `Done when:` → a list where each item is an **intent** (locked) plus **exactly one** of
  a candidate `command` (marked as a guess; `/build` re-resolves) or `manual: true`. Field
  names (`intent` / `command` / `manual`) match the spine schema for forward-compat;
  build-time outcomes are never authored into the block.
- Remove the **Build Log** table section.

**Code example:**

```
**Done when:**

- intent: <what proves this task done>
  command: `<candidate — a guess; /build re-resolves against the real repo>`
- intent: <intent with no feasible command>
  manual: true
```

**Done when:**

- intent: the template `Done when:` shows the intent + optional-candidate-command +
  `(manual)` form with the fixed field names command:
  `grep -niE 'intent:|manual: true|command:' .claude/skills/plan/templates/implementation-plan.md`
  _(candidate; /build re-resolves)_
- intent: the Build Log table section is removed from the template command:
  `grep -niE 'build log|\| date \|' .claude/skills/plan/templates/implementation-plan.md`
  _(candidate; /build re-resolves; expect no matches)_

**Commit:** "Update plan template: intent/command done_when, remove Build Log table"

---

### Task 6: document §4 — repoint at git (Step 1, changelog, PR draft)

**Description:** Source `/document`'s narrative, files, and deviation rationale from git
instead of the Build Log. **Files:**

- `.claude/skills/document/SKILL.md` - modify (Step 1, Step 2.3, Step 3 changelog, PR
  draft)

**Changes:**

- Step 1: read `git log` / `git log --stat` `<base>..HEAD` and commit bodies for the
  narrative, files, and deviation rationale; remove "Review the Build Log entries."
- Remove Step 2.3 "Review Build Log."
- Changelog "Key files" sources from `git log --stat`.
- PR draft "Changes" sources from `git log --stat`.

**Done when:**

- intent: Step 1 is git-sourced (`git log` / `git log --stat` `<base>..HEAD` + commit
  bodies) and both Build Log references (Step 1 and Step 2.3) are gone command:
  `grep -niE 'build log|git log' .claude/skills/document/SKILL.md` _(candidate; /build
  re-resolves)_
- intent: changelog "Key files" and PR-draft "Changes" both cite `git log --stat` manual:
  true

**Commit:** "Repoint document at git: log-sourced Step 1, changelog, PR draft"

---

### Task 7: Validation run + harvest

**Description:** Run the new `/build` against a small plan end-to-end, tune the escalation
triggers from what it actually interrupts on, and capture the harvest. **This is a
separate exercise** — it requires syncing the updated skills first and produces a harvest
doc, not a normal code commit. **Files:**

- `docs/research/workflow-upgrade/2026-06-25-move-1-validation-harvest.md` - create (or
  similar path)

**Steps:**

1. Run `scripts/sync-skills.sh` so the updated `build`/`document` skills are active in
   `~/.claude/skills/`.
2. Run the new `/build` against a small throwaway plan end-to-end: proceeds without
   per-task pauses, runs at least one executable `done_when`, commits per task with
   explicit-path staging, presents a coherent end-of-batch review.
3. Capture the harvest (capture, not just "it worked"):
   - **Batch-review feel** — real evaluation or rubber-stamp on "all green"? (the
     surrogation tell)
   - **Manual-rate** — fraction of checks that landed `(manual)` vs executable, and
     whether `(manual)`-first / verified-vs-just-compiled surfacing kept those out of the
     green.
   - **`done_when` resolution behavior** — did build-time resolution catch real drift, or
     did the single agent tailor itself an easy command (the Decision 1 compromise
     biting)?
   - **Round-cap pressure** — where the cap/loop bounds were felt (grinding, looping, or
     fine).
4. Tune the §1 escalation triggers from what the run actually interrupted on.

**Done when:**

- intent: the new `/build` completed a small plan end-to-end (no per-task pauses, ≥1
  executable check, per-task explicit-path commits, a coherent end-of-batch review)
  manual: true
- intent: a harvest doc exists covering all four observations, and the escalation triggers
  were tuned from the run command:
  `ls docs/research/workflow-upgrade/2026-06-25-move-1-validation-harvest.md` _(candidate;
  /build re-resolves)_

**Commit:** "Add Move 1 validation harvest notes"

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

- [ ] `build/SKILL.md` and `document/SKILL.md` frontmatter list
      `Read, Grep, Glob, Write, Edit, Bash` and retain `disable-model-invocation: true`.
      `(design)`
- [ ] `build/SKILL.md` Rule 7 and `document/SKILL.md` Rule 5 are the narrowed forms
      (read-only git everywhere; `/build` commits current-branch/explicit-paths-only; no
      remote/history ops; `/document` never commits). `(design)`
- [ ] `build/SKILL.md` "For Each Task" has no per-task pause; it resolves the check before
      implementing, runs the resolved command (exit 0 = gate), commits declared files with
      a deviation note in the body, and proceeds — with an explicit escalate-by-exception
      clause. `(design)`
- [ ] `build/SKILL.md` Rules read "Sequential execution" (not "One task at a time") and
      "Approve by exception" (not "User confirms"); the "Update Build Log" rule is
      removed. `(design)`
- [ ] `build/SKILL.md` bounds the verify→fix cycle at three attempts and escalates on the
      third failure (Decision 7). `(design)`
- [ ] The plan template's per-task `Done when:` is the intent + optional candidate-command
      form, with `(manual)` representable and, if structured, field names matching the
      spine schema (`intent` + exactly one of `command:` / `manual: true`); the Build Log
      table section is removed. `(design)`
- [ ] `build/SKILL.md` "After All Tasks" presents the batch once over `<base>..HEAD`
      (diff + commit list, deviations first, `(manual)` separately, verified-vs-compiled,
      test-file diffs surfaced), then runs active executable AC and presents `(manual)`
      AC; `<base>` is defined once near the top of the skill. `(design)`
- [ ] `build/SKILL.md` "Handling Deviations" routes the why to the commit body, not a
      Build Log row; Phase Complete drops the "Build Log updated in:" line. `(design)`
- [ ] A deviation that touches an undeclared file results in that file being staged (by
      explicit path) and noted in the commit body, or escalated — never left as a silent
      dirty-tree drop. No path is ever staged via `git add -A`. `(design)`
- [ ] `document/SKILL.md` Step 1 sources from `git log` / `git log --stat` `<base>..HEAD`
      and commit bodies; the "Review Build Log" step is gone; changelog "Key files" and
      PR-draft "Changes" source from `git log --stat`. `(design)`
- [ ] **Validation run:** one real `/build` against a small plan completes end-to-end —
      proceeds without per-task pauses, runs at least one executable `done_when`, commits
      per task with explicit-path staging, and presents a coherent end-of-batch review;
      the escalation triggers are tuned from what it interrupts on; and the harvest is
      captured (batch-review feel, manual-rate, `done_when` resolution behavior, round-cap
      pressure). `(design)`
- [ ] The updated `build`/`document` skills are synced to the global skills dir (via
      `scripts/sync-skills.sh`) before the validation run, so the validation exercises the
      new skill, not the old one. `(added)`

---

## Build Log

_Filled in during `/build` phase_

| Date       | Task   | Files                                                           | Notes                                                                                                                                |
| ---------- | ------ | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| 2026-06-25 | Task 1 | .claude/skills/build/SKILL.md, .claude/skills/document/SKILL.md | —                                                                                                                                    |
| 2026-06-25 | Task 2 | .claude/skills/build/SKILL.md                                   | Renumbered Rules 6–8 after removing "Update Build Log"                                                                               |
| 2026-06-25 | Task 3 | .claude/skills/build/SKILL.md                                   | Added `<base>` section after Prerequisite; renamed "After All Tasks" to "End-of-Batch Review"                                        |
| 2026-06-25 | Task 4 | .claude/skills/build/SKILL.md                                   | Re-resolved done_when grep: candidate over-matched explanatory "Build Log" prose; checked table header + Phase Complete line instead |

---

## Completion

**Completed:** [Date] **Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]

---

## Notes

- **Two verification layers stay distinct** (per the spec): _Task done_ = a task's
  per-task `done_when` passed (the per-task floor, checked during each task); _AC done_ =
  the plan's active acceptance-criteria ledger verified (the end-of-batch gate). A task
  being "done" never implies the feature's AC are met.
- **Surrogation risk to watch on first run:** gating on a check moves the auto-yes rather
  than killing it. Keep the end-of-batch human review a real evaluation, and keep the
  "compiles, behavior unverified" label honest. The tell: "did it pass?" replacing "is it
  right?" in your own head.
- **`done_when` format decision:** lightweight structured markdown (intent + optional
  candidate command / `manual: true`) was chosen over full `yaml spine` to satisfy §2
  forward-compat without pulling the spine-validator's full task record into Move 1 scope.
- **Source material:** `docs/research/workflow-upgrade/2026-06-23-*` (primary draft,
  done_when empirical/soundness, upgrade path, build-as-orchestrator) and
  `2026-06-25-spine-validator.md` (forward-compat schema).
