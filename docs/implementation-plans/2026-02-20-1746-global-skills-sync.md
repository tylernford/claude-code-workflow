# Implementation Plan: Global Skills Sync

**Created:** 2026-02-20 **Type:** Feature **Overview:** Automatically sync workflow skills
from this repo to `~/.claude/skills/` after pulling changes on `main`. **Design Spec:**
docs/design-specs/2026-02-20-1739-global-skills-sync.md

---

## Summary

Create a git `post-merge` hook and sync script that automatically copies the 4 workflow
skill directories (`design`, `plan`, `build`, `document`) from this repo to
`~/.claude/skills/` whenever a pull includes changes under `.claude/skills/`.

---

## Codebase Verification

- [x] 4 workflow skills exist at `.claude/skills/` — Verified: `build`, `design`,
      `document`, `plan`
- [x] Each skill is a directory (with `SKILL.md` and optionally `templates/`) — Verified
- [x] Global `~/.claude/skills/` contains workflow skills plus `learning-opportunities` —
      Verified
- [x] No existing `post-merge` hook — Verified: clean slate
- [x] `README.md` exists for adding setup instructions — Verified

**Patterns to leverage:**

- None — this is new infrastructure (shell scripts, git hooks)

**Discrepancies found:**

- Design suggested `sync-skills.sh` at repo root; placing it in `scripts/` alongside
  `post-merge` instead

---

## Tasks

### Task 1: Create the sync script

**Description:** Create `scripts/sync-skills.sh` — a standalone script that copies the 4
workflow skill directories from the repo to `~/.claude/skills/`. Includes output
indicating what was synced.

**Files:**

- `scripts/sync-skills.sh` - create

**Code example:**

```bash
#!/usr/bin/env bash
REPO_SKILLS="$(dirname "$0")/../.claude/skills"
GLOBAL_SKILLS="$HOME/.claude/skills"
WORKFLOW_SKILLS=("design" "plan" "build" "document")

for skill in "${WORKFLOW_SKILLS[@]}"; do
  cp -R "$REPO_SKILLS/$skill" "$GLOBAL_SKILLS/$skill"
  echo "Synced: $skill"
done
```

**Done when:** Running `bash scripts/sync-skills.sh` manually copies the 4 skill
directories to `~/.claude/skills/` and prints output for each. Non-workflow skills like
`learning-opportunities` are untouched.

**Commit:** "Add sync-skills script"

---

### Task 2: Create the post-merge hook

**Description:** Create `scripts/post-merge` — a git post-merge hook that checks if any
files under `.claude/skills/` changed in the merge, and if so, runs the sync script.

**Files:**

- `scripts/post-merge` - create

**Code example:**

```bash
#!/usr/bin/env bash
CHANGED=$(git diff-tree -r --name-only ORIG_HEAD HEAD -- .claude/skills/)

if [ -n "$CHANGED" ]; then
  echo "Skills changed — syncing to global..."
  "$(dirname "$0")/../scripts/sync-skills.sh"
fi
```

**Done when:** The hook detects skill changes by comparing `ORIG_HEAD` to `HEAD`. When
changes exist under `.claude/skills/`, it calls the sync script. When no changes exist, it
exits silently.

**Commit:** "Add post-merge hook for skills sync"

---

### Task 3: Document setup instructions in README

**Description:** Add a setup section to `README.md` with one-time instructions: make the
scripts executable and symlink the hook into `.git/hooks/`.

**Files:**

- `README.md` - modify

**Done when:** README contains clear setup instructions. Following the instructions
creates a working symlink from `.git/hooks/post-merge` to `scripts/post-merge`.

**Commit:** "Add skills sync setup instructions to README"

---

## Acceptance Criteria

- [x] After `git pull` on `main` that includes changes under `.claude/skills/`, the 4
      workflow skills are copied to `~/.claude/skills/`
- [x] After `git pull` on `main` with no skills changes, nothing happens
- [x] Non-workflow skills in `~/.claude/skills/` (e.g., `learning-opportunities`) are not
      modified
- [x] `scripts/post-merge` is version-controlled in the repo
- [x] Setup instructions are documented in the README

---

## Build Log

_Filled in during `/build` phase_

| Date       | Task   | Files                  | Notes                                                                                                         |
| ---------- | ------ | ---------------------- | ------------------------------------------------------------------------------------------------------------- |
| 2026-02-20 | Task 1 | scripts/sync-skills.sh | Created sync script; verified manual run copies 4 skills                                                      |
| 2026-02-20 | Task 2 | scripts/post-merge     | Deviated: used `git rev-parse --show-toplevel` instead of relative dirname to handle symlink from .git/hooks/ |
| 2026-02-20 | Task 3 | README.md              | Added Setup section with hook install and manual sync instructions                                            |
| 2026-02-20 | Verify | scripts/sync-skills.sh | Fixed: added `rm -rf` before `cp -R` to prevent nested directories when target exists                         |

---

## Completion

**Completed:** 2026-02-20 **Final Status:** Complete

**Summary:** Created a sync script and git post-merge hook that automatically copies the 4
workflow skill directories (design, plan, build, document) from the repo to
`~/.claude/skills/` whenever a pull includes changes under `.claude/skills/`. Added README
setup instructions for one-time hook installation.

**Deviations from Plan:**

- Used `git rev-parse --show-toplevel` in the post-merge hook instead of relative
  `dirname` to correctly resolve the repo root when the hook runs as a symlink from
  `.git/hooks/`
- Added `rm -rf` before `cp -R` in the sync script to prevent nested directories when the
  target skill directory already exists

---

## Notes

- The sync script uses an explicit list of 4 skills. If new workflow skills are added,
  update the `WORKFLOW_SKILLS` array.
- `sync-skills.sh` is kept separate from the hook so it can also be run manually.
