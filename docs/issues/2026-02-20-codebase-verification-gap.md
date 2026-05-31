# Codebase Verification Gap

**Date:** 2026-02-20 **Context:** Global Skills Sync (PR #24) — post-merge hook conflicted
with existing `core.hooksPath` config, passed through all four workflow phases uncaught

---

## What Happened

The Global Skills Sync feature added a git `post-merge` hook at `scripts/post-merge` with
setup instructions to symlink it into `.git/hooks/`. But the repo already uses
`core.hooksPath = .githooks` with an existing `pre-commit` hook there.

When `core.hooksPath` is set, git ignores `.git/hooks/` entirely. The symlinked post-merge
hook would never fire.

This passed through all four workflow phases — design, plan, build, document — without
being caught.

---

## Where It Should Have Been Caught

### Phase 2: Plan — Step 2: Codebase Verification

The plan skill says:

> - Verify assumptions in the design spec match the actual codebase
> - Check for existing patterns, utilities, or components to leverage
> - Flag any discrepancies between design assumptions and reality

The design spec proposed a git hook. Codebase verification should have checked whether the
repo already had git hooks or hook configuration. It didn't — it verified skill
directories, the README, and the absence of a `post-merge` hook in `.git/hooks/`, but
never looked at `.githooks/` or `core.hooksPath`.

### Phase 3: Build — Acceptance Criteria

The acceptance criteria tested behavior ("after git pull, skills are synced") but not
integration ("the hook actually runs given the repo's hook configuration"). The criteria
passed because the sync script itself works — the untested assumption was that the hook
would be invoked.

---

## Why It Was Missed

1. **Verification was scoped too narrowly.** The plan phase verified the feature's own
   components (skill dirs exist, no existing post-merge hook) but didn't widen the search
   to related infrastructure (how does this repo manage hooks generally?).

2. **"Check for existing patterns" is too vague.** The instruction doesn't specifically
   prompt for infrastructure-level checks like git config, CI pipelines, or existing hook
   directories. It's easy to interpret as "check for code patterns to reuse" rather than
   "check for anything that could conflict."

3. **Acceptance criteria tested the script, not the integration.** "After git pull, skills
   are synced" was verified by running the sync script manually, not by confirming the
   hook would actually be triggered.

---

## Possible Improvements

### A: Add infrastructure checks to Plan's Codebase Verification

When the feature involves git hooks, CI, build config, or other infrastructure, explicitly
verify the repo's existing setup for that infrastructure:

- Git hooks → check `.githooks/`, `.git/hooks/`, `core.hooksPath`
- CI → check existing workflow files, runners, environment
- Build config → check existing scripts, package.json, Makefile

### B: Strengthen acceptance criteria to test integration, not just components

Add guidance to the Build phase: acceptance criteria should verify end-to-end behavior,
not just that individual components work. If a hook is supposed to fire on `git pull`,
test that the hook fires — not just that the script it calls works.

### C: Add a "conflict check" to Codebase Verification

Beyond "check for patterns to leverage," explicitly ask: "What existing configuration
could conflict with or override this feature?" This reframes verification from additive
(what can we reuse?) to defensive (what could break this?).

These are not mutually exclusive. A and C improve the Plan phase. B improves the Build
phase.

---

## Fix

Move `scripts/post-merge` into `.githooks/post-merge` to align with the existing hook
setup. Remove the symlink instructions from the README.
