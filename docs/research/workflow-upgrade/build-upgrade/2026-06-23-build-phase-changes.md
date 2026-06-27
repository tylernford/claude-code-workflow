# Move 1 — concrete `/build` phase changes

**Date:** 2026-06-23 **Implements:** Move 1 of `2026-06-23-workflow-upgrade-path.md`.
Draft spec — before/after text, not applied. Touches `build/SKILL.md`,
`document/SKILL.md`, and `plan/templates/implementation-plan.md`.

**Status (2026-06-25):** the build phase is going **full orchestrator** (Move 1.5,
`2026-06-23-build-as-orchestrator.md`). **§1 (per-task loop) and §3 (single-agent end
review) are superseded** by the orchestrator's dispatch→review loop; the **end-of-batch
human review in §3 survives**, now reading pre-verified tasks. **§0, §2, and §4 still
hold** and are prerequisites the orchestrator depends on.

**The principle (unchanged):** gate decisions, not procedures. `/build` is almost entirely
procedural — executing what design and plan already decided — so its per-task approvals
became auto-yeses. Move the one real review to the end, swap reflexive stamps for tireless
checks, stop hand-transcribing what git already holds.

Four changes follow; two are blocked by the §0 decisions.

---

## §0 — Two enabling decisions (settle these first)

### Decision 1 — `allowed-tools` must become honest

Both skills declare `allowed-tools: Read, Grep, Glob`, yet already write plan/spec files
and run `date`/`git branch` — so the line is unenforced, or it blocks the skills from
working (bug #4 in the extension review). Move 1 makes the gap load-bearing: you can't
**run** a `done_when` check or **read** `git log` with Read/Grep/Glob.

**Change (both `build` and `document`):**

```
- allowed-tools: Read, Grep, Glob
+ allowed-tools: Read, Grep, Glob, Write, Edit, Bash
```

### Decision 2 — "No git operations" needs a scope (the crux)

Today's rule is absolute: _"Never run git commands (commit, add, push, etc.). User handles
all version control manually."_ But Move 1 needs `/document` to **read** `git log`, and
the per-task **commit** has to come from somewhere. Read-only `git log` isn't a mutation;
the rule's real intent is "don't move shared history behind my back."

**Decided: the agent commits, with a leash.** Keeping the user as sole committer was
dropped — it left the commit a manual step and a lump working tree harder to commit
cleanly than letting the agent do it as it goes.

Allow read-only git everywhere (`log`, `show`, `diff`, `status`), and let `/build` commit
a completed task **on the current branch only**, staging **only the files that task
declares** (its `action:path` records) — never a blanket `git add -A` that could sweep in
a stray file or secret. Still forbidden: `push`, `--force`, `rebase`, `reset --hard`,
`branch -D`, `merge`, remote ops; the user owns branch creation, push, and the PR. This
drops the human from the per-task loop and yields the clean commits that make the Build
Log deletion safe. "User drives" stays intact: it governs decisions and phase transitions,
not who types `git commit`.

```
- 7. **No git operations** - Never run git commands (commit, add, push, etc.). User
-    handles all version control manually.
+ 7. **No history rewrites, no remote ops** - You may read git (log/show/diff/status) and
+    commit a completed task on the CURRENT branch, staging ONLY the files that task
+    declares (never `git add -A`). Never push, force-push, rebase, reset, delete branches,
+    or touch remotes — the user owns branch creation, push, and the PR.
```

`/document` needs the same read-only `git log` — narrow its Rule 5 the same way.

---

## §1 — Stop pausing per task (approve-by-exception) — SUPERSEDED by the orchestrator loop

> Kept for provenance. The per-task loop here is replaced by Move 1.5's dispatch→review
> loop; the approve-by-exception _principle_ carries forward intact.

The reflexive gate is `build/SKILL.md:47` — _"Pause - Ask user: 'Anything to note?' Then
wait for confirmation before next task."_ That's the auto-yes. Default becomes
**proceed**; interrupt only on a real decision.

**Replace the `For Each Task` list (`build/SKILL.md:37-48`):**

```
### For Each Task:

1. **Announce** - State which task you're starting
2. **Implement** - Write the code / create the files
3. **Verify** - Run the task's `done_when` (see §2). On pass, proceed. On fail, fix and
   re-run. A `(manual)` check is noted for the end-of-build review, not run here.
4. **Commit** - Commit the completed task with the plan's commit message, staging only the
   files that task declares (never `git add -A`). Put any deviation rationale in the commit
   body (see §4).
5. **Proceed** - Move to the next task without pausing.

**Escalate to the user only when** a check fails in a way you can't resolve, the plan is
genuinely ambiguous (two defensible paths and the plan doesn't choose), or something
irreversible or out-of-scope is about to happen. Otherwise the default is proceed — silence
is not a missed approval, it's the design.
```

**Rules section (`build/SKILL.md:103-107`):**

```
- 1. **One task at a time** - Complete fully before moving to next
+ 1. **Sequential execution** - Finish each task before starting the next (ordering, not a
+    per-task approval gate).
- 4. **User confirms** - Wait for approval between tasks
+ 4. **Approve by exception** - Proceed by default; interrupt only for a failed check, a
+    genuine fork, or an irreversible/out-of-scope action.
- 5. **Update Build Log** - Keep implementation plan current as you go
+ (deleted — see §4)
```

## §2 — Make `done_when` executable where it can be (intent in the plan, command at build)

`done_when` is verified by the agent asserting it (`build/SKILL.md:42` "Confirm done when
criteria are met") — exactly what becomes an auto-yes. Where the criterion is a command,
**run it**; the exit code is the gate that doesn't get tired.

**But the command isn't authored in the plan.** `done_when` splits into a fixed **intent**
(in the plan — the anti-gaming anchor; can't be tailored to whatever got built, survives
every deviation) and a volatile **command** (resolved against the real repo at build,
re-resolved if the builder deviates mid-task). Folding them into one frozen line is the
mistake the empirical test caught: build-time drift hit 7 of 13 firestarter plans, and a
copied command goes stale with the right answer in the same file. Mechanism:
`2026-06-23-done-when-empirical.md`.

So the command is derived by **not-the-builder** — the orchestrator/reviewer per Move 1.5,
or in single-agent Move 1 the `/build` agent before it implements the task — from the
intent against the repo as it stands, not lifted from the plan text.

**Plan template (`plan/templates/implementation-plan.md`), per task —** `done_when`
carries _intent_, with an optional _candidate_ command marked as a guess, never trusted
verbatim:

```
done_when:
  - intent: "Card unit tests pass"
    verify?: `npm test -- card.test.ts`    # CANDIDATE — re-resolve against the repo at build;
                                            # run only after confirming it matches reality
  - intent: "Card renders the design-token border"   # no feasible command → (manual)
```

At build, `/build` resolves each `intent` to a real command (repairing or replacing the
candidate), runs it, records pass/fail automatically. Intents with no feasible command
stay human-checked, tagged `(manual)` and **listed first**, so "what's checkable" never
silently becomes "what we check" — the Goodhart trap the extension review flagged; keep
`(manual)` first-class. A command that only proves a shallow proxy (`next build` standing
in for "displays content") is recorded as _compiles, behavior unverified_, not silently
counted as done (finding 1 of the empirical doc).

**`build/SKILL.md` `After All Tasks` (lines 50-60)** — the acceptance loop runs the
resolved executable criteria itself and asks the user only for the `(manual)` ones.

## §3 — One real review at the end (not N reflexive yeses) — end-batch review survives, single-agent framing SUPERSEDED

> The end-of-batch human review carries into the orchestrator (it reads this section's
> batch-diff handoff); what's superseded is that it's the _only_ review — Move 1.5 adds
> the per-task agent loop ahead of it, so the human now reviews pre-verified tasks.

Replace the per-task pause (deleted in §1) with a single loaded-in review after the batch.

**New section, after `For Each Task` and before `Phase Complete`:**

```
### After All Tasks: One Review

1. **Present the batch once** - Show `git diff <base>..HEAD` (the whole change), the list of
   commits (`git log --oneline <base>..HEAD`), every deviation, and every `(manual)`
   done_when awaiting a human eye.
2. **User reviews once** - One pass over the real diff, in context — the evaluation the
   per-task stamps were pretending to be.
3. **Acceptance criteria** - Run the executable criteria and show results; present the
   `(manual)` ones. Mark `[x]` per the verified outcome (build remains the sole authority
   for the checkboxes).
```

`<base>` = the branch point for this feature's work (e.g. `develop`, or the build
session's first commit). State how you determine it once, near the top of the skill.

## §4 — Delete the per-task Build Log table; point `/document` at git

The table (`build/SKILL.md:43,73-78` + the template's `| Date | Task | Files | Notes |`)
hand-transcribes three columns git already holds — Date = commit date, Task = commit
subject, Files = `git log --stat` — inside a workflow that otherwise forbids git. The one
non-derivable column, `Notes` (the _why_ of a deviation), belongs in the commit body.

**`build/SKILL.md`:**

- Delete step 5 (`Log`) from `For Each Task` (done in §1).
- Replace `Handling Deviations` (lines 64-78):

  ```
  ## Handling Deviations

  When reality doesn't match the plan:

  1. **Don't edit the plan** - it's a record of original thinking.
  2. **Record the why in the commit body** - one or two lines under the subject explaining
     what changed and why. That is the durable deviation note.
  3. **Continue** with the adjusted approach. If the deviation changes scope or is
     irreversible, that's an escalation (§1), not just a note.
  ```

- In `Phase Complete` (line 91) drop the "Build Log updated in: …" line.

**`plan/templates/implementation-plan.md`:** remove the Build Log table. The
**Completion** section already carries "Summary of what was actually built" + "Deviations
from original plan" — the durable record stays; the per-row transcript goes.

**`document/SKILL.md` — repoint the source from the table to git:**

- Step 1 (lines 40-47): replace _"Review the Build Log entries in the implementation
  plan"_ with:
  ```
  - Read the feature's commits: `git log <base>..HEAD` (subjects + dates = the narrative),
    `git log --stat <base>..HEAD` (files changed), and the commit bodies (deviation
    rationale). This is read-only git.
  - Summarize what was built and the deviations, from the commits.
  ```
- Step 3 changelog "Key files" and the PR Draft "Changes/Key files" (lines 76-80,
  120-123): source from `git log --stat` instead of the Build Log.
- Rule 5 (line 173): narrow to read-only git, matching Decision 2.

This is strictly more honest: `/document` was caught asserting acceptance criteria it
never verified, because it summarized a narrative the build phase wrote about itself.
Pointed at the commits, it can only report what landed. **Dependency:** good commits —
meaningful subjects (already true) and the deviation _why_ in the body. "Docs are the
handoff" becomes "**git** is the handoff."

---

## What this nets

- **Loses no real evaluation** — the per-task review was an auto-yes; it moves to one
  loaded-in pass where it can actually happen.
- **Ends with more verification** — executable `done_when` checks run every time and don't
  rubber-stamp.
- **Removes a hand-maintained artifact** (the Build Log) and its drift, replacing it with
  the record git keeps for free.

## Order of operations

1. Apply §0 (honest `allowed-tools`; narrow the no-git rule to
   read-only-plus-feature-branch-commits). Nothing else is real until this.
2. `build/SKILL.md` — §1 (loop + rules), §3 (end review), §4 (deviations, drop Log step).
3. `plan/templates/implementation-plan.md` — §2 (`verify:` on done_when), §4 (remove
   table).
4. `document/SKILL.md` — §4 (git-sourced Step 1, changelog, PR draft, Rule 5).
5. Run one real `/build` against a small plan and tune the §1 escalation triggers from
   what it interrupts on.

## Deliberately not here

Move 3b (lift the Rules footer into `CLAUDE.md`) and Move 3a (acceptance-criteria
single-sourcing) touch these same files, where the no-git rule repeats — do Move 1 first,
then Move 3 pulls the now-narrowed Rule 5 into one place.
