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

1. **Announce** - State which task you're starting
2. **Implement** - Write the code / create the files
3. **Verify** - Confirm "done when" criteria are met
4. **Report** - Show what was created/modified
5. **Log** - Add **one Build Log row for this task** to the implementation plan. `Files` =
   key files created/modified; `Notes` = deviations or discoveries, or `—` if none.
   (Canonical column schema lives in the plan template's Build Log.)
6. **Commit** - Use the commit message from the plan (user handles git)
7. **Pause** - Ask user: "Anything to note? (discoveries, surprises, context for later)"
   Then wait for confirmation before next task.

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

1. **One task at a time** - Complete fully before moving to next
2. **Follow the plan** - Don't add unplanned work
3. **Preserve the mess** - Note deviations, don't rewrite history
4. **User confirms** - Wait for approval between tasks
5. **Update Build Log** - Keep implementation plan current as you go
6. **Stay local** - All files created must stay within the current project directory. No
   system-level or global configuration changes.
7. **Git: read + commit only, on the current branch** - May read git (`git status`,
   `git diff`, `git log`, `git rev-parse`) freely, and may commit a completed task on the
   **current branch only**, staging the files that task **actually changed** by **explicit
   path** (never `git add -A`, never `git add .`). Forbidden: push, force-push, rebase,
   reset, branch creation/switching/deletion, tag, and any remote operation. If the work
   needs a branch change or a remote op, escalate to the user.
8. **Slash commands only** - Phase transitions happen ONLY via explicit `/command`. Never
   auto-advance based on natural language like "let's move to documentation."
9. **One phase per session** - Complete this phase, then end the session. Next phase
   starts fresh with docs as the handoff.
