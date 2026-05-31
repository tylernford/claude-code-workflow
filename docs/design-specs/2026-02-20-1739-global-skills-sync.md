# Global Skills Sync

**Created:** 2026-02-20 **Implementation Plan:**
docs/implementation-plans/2026-02-20-1746-global-skills-sync.md

---

## Overview

**What:** Automatically sync workflow skills from this repo to `~/.claude/skills/` after
pulling changes on `main`.

**Why:** The global `~/.claude/skills/` directory is where Claude Code loads skills from.
When workflow skills are updated in this repo, the global copies need to stay in sync.
Manual copy/paste is error-prone and easy to forget.

**Type:** Feature

---

## Requirements

### Must Have

- [ ] A git `post-merge` hook that detects when skills files changed and triggers a sync
- [ ] A sync script that copies the 4 workflow skills (`design`, `plan`, `build`,
      `document`) to `~/.claude/skills/`
- [ ] Sync must not touch non-workflow skills in the global directory (e.g.,
      `learning-opportunities`)
- [ ] The hook script is tracked in the repo at `scripts/post-merge`
- [ ] One-time setup is documented (symlink from `.git/hooks/post-merge` to the tracked
      script)

### Nice to Have

- [ ] Sync script output indicating what was updated

### Out of Scope

- Syncing non-workflow skills
- Automatic setup (user runs the symlink command once)
- Triggering sync from Claude Code hooks

---

## Design Decisions

### Hook mechanism: git `post-merge` hook

**Options considered:**

1. Claude Code `PostToolUse` hook — fires only during Claude sessions, wrong trigger
   (reacts to commits, not merges to main)
2. Git `post-merge` hook — fires on `git pull` regardless of client (CLI, GitHub Desktop,
   etc.)
3. Manual script — no automation, same effort as copy/paste

**Decision:** Git `post-merge` hook. It fires at the git level on any pull/merge, works
with any git client, and only runs when you're actually integrating changes — not during
mid-feature development.

### Hook storage: tracked in repo, symlinked into `.git/hooks/`

**Options considered:**

1. Store at `scripts/post-merge`, symlink into `.git/hooks/` — surgical, only affects this
   one hook
2. Use `core.hooksPath` to point git at a directory — cleaner but overrides all default
   hooks

**Decision:** Option 1 (symlink). More surgical and doesn't interfere with any other
hooks.

### Sync scope: explicit skill list

**Decision:** The sync script copies a fixed list of 4 workflow skill directories. Each
skill is a directory that may contain templates and other supporting files — the entire
directory is synced. If new workflow skills are added later, the script is updated. This
is simpler than pattern-matching or syncing everything, and avoids accidentally
overwriting non-workflow skills.

---

## Acceptance Criteria

- [ ] After `git pull` on `main` that includes changes under `.claude/skills/`, the 4
      workflow skills are copied to `~/.claude/skills/`
- [ ] After `git pull` on `main` with no skills changes, nothing happens
- [ ] Non-workflow skills in `~/.claude/skills/` (e.g., `learning-opportunities`) are not
      modified
- [ ] `scripts/post-merge` is version-controlled in the repo
- [ ] Setup instructions are documented in the README

---

## Suggested Files to Create/Modify

```
scripts/post-merge    # git post-merge hook (tracked in repo)
sync-skills.sh        # sync script (copies workflow skills to global)
README.md             # one-time setup instructions
```
