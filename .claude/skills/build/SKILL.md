---
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# /build

You are starting **Implementation · Phase 2: Build**.

---

## Your Role

Execute the implementation plan task by task, with commits at each checkpoint. You
implement, user reviews.

---

## Prerequisite

If the user does not provide an implementation plan path, ask them for the file path.

---

## Announce Your Location

Every response must begin with:

```
**Phase 2: Build** | Task [N]/[Total]: [Task Name]
```

---

## Workflow

### For Each Task:

The default is **proceed** — you run the whole task and move to the next without pausing.
Stop only by exception (see "Approve by exception" below).

1. **Announce** - State which task you're starting.
2. **Resolve check** - Read the task's `done_when`. For each item with an `intent` +
   candidate `command`, **resolve the intent into a real command against this repo** —
   find the actual test/build/grep target, file path, or symbol. **Never lift the
   candidate command verbatim**; it's a guess the plan author made, and your job is to
   re-resolve it against reality. Items marked `manual: true` have no command — note them
   for the end-of-batch review.
3. **Implement** - Write the code / create the files.
4. **Run resolved command** - Run the resolved command(s). **Exit 0 is the gate.** If the
   task deviated mid-implementation so the resolved command no longer fits, **re-resolve**
   it before running. When the command is only a shallow proxy for the intent (e.g. it
   proves the file parses or compiles but not that behavior is correct), record the result
   as **"compiles, behavior unverified."** `manual: true` intents are **noted, not counted
   as done** — they are surfaced in the end-of-batch review, never silently passed.
5. **Commit** - Commit the task on the current branch, staging the files this task changed
   by **explicit path** (never `git add -A`). Use the plan's commit message; if the task
   deviated, record the why in the **commit body** (see "Handling Deviations").
6. **Proceed** - Move to the next task. No pause.

**Three-attempt cap:** if a task's check fails, fix and re-run — but bound this at **three
attempts** per check. On the **third consecutive failure**, stop and **escalate** to the
user with the failing command output. Do not grind past the cap.

**Approve by exception:** the default is proceed. Stop and escalate to the user only when:

- (a) a check is **still failing after the three-attempt cap**,
- (b) there is a **genuine plan ambiguity** you cannot resolve from the plan and repo, or
- (c) the task requires an **irreversible or out-of-scope action** (a branch/remote op, a
  destructive change, work the plan didn't authorize).

Anything outside (a)–(c) — proceed.

### After All Tasks: Acceptance Criteria

The gate is the plan's **active (unstruck) criteria** — the `(design)` and `(added)`
items. Struck items (`(deferred)` / `(dropped)`) are recorded in the ledger but **not
verified here**; they belong to a later plan or are intentionally out of scope. Do not
skip silently over them — the strike is the record.

1. **Prompt** - Ask user: "All tasks complete. Run acceptance criteria before completing
   phase?"
2. **Wait for confirmation** - User must confirm to proceed
3. **For each active (unstruck) checklist item:**
   - Present the item
   - Verify with user (pass/fail)
   - If pass: Mark `[x]` in implementation plan
   - If fail: Fix the issue, log deviation in Build Log, re-verify
4. **All active items must pass** before proceeding to Phase Complete

---

## Handling Deviations

When reality doesn't match the plan, the deviation goes in the **`Notes` column of that
task's Build Log row** — every task still gets a row whether or not it deviated.

1. **Don't update the implementation plan** - It's a record of original thinking
2. **Record it in Notes** - What changed and why, in that task's row
3. **Continue** - Proceed with adjusted approach

Example Build Log rows (a clean task, then a deviation):

| Date       | Task   | Files                  | Notes                                         |
| ---------- | ------ | ---------------------- | --------------------------------------------- |
| 2024-01-15 | Task 2 | src/components/Card.ts | —                                             |
| 2024-01-15 | Task 3 | src/utils/helper.ts    | Used existing utility instead of creating new |

---

## Phase Complete

When all tasks are done and verification checklist passes, announce:

```
**Phase 2: Build** | Complete

All [N] tasks completed.
Acceptance criteria passed.
Build Log updated in: docs/implementation-plans/YYYY-MM-DD-HHMM-feature-name.md

**Commit checkpoint:** Ensure all tasks have been committed before ending this session.

Next: End this session and start a new Claude Code session.
Run `/document` to begin Phase 3: Document.
```

---

## Rules

1. **Sequential execution** - Complete each task fully before moving to the next.
   Sequential order is not a per-task approval gate — proceed by default; do not wait for
   confirmation between tasks.
2. **Follow the plan** - Don't add unplanned work
3. **Preserve the mess** - Note deviations, don't rewrite history
4. **Approve by exception** - Proceed by default; stop and escalate only on the exception
   cases (check failing after the three-attempt cap, genuine plan ambiguity, or an
   irreversible/out-of-scope action).
5. **Stay local** - All files created must stay within the current project directory. No
   system-level or global configuration changes.
6. **Git: read + commit only, on the current branch** - May read git (`git status`,
   `git diff`, `git log`, `git rev-parse`) freely, and may commit a completed task on the
   **current branch only**, staging the files that task **actually changed** by **explicit
   path** (never `git add -A`, never `git add .`). Forbidden: push, force-push, rebase,
   reset, branch creation/switching/deletion, tag, and any remote operation. If the work
   needs a branch change or a remote op, escalate to the user.
7. **Slash commands only** - Phase transitions happen ONLY via explicit `/command`. Never
   auto-advance based on natural language like "let's move to documentation."
8. **One phase per session** - Complete this phase, then end the session. Next phase
   starts fresh with docs as the handoff.
