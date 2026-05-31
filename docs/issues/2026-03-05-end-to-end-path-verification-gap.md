# End-to-End Path Verification Gap

**Date:** 2026-03-05 **Context:** Global Skills Sync — `sync-skills.sh` was committed
without execute permission (`100644`), causing the post-merge hook to fail with
"Permission denied" on any fresh pull

---

## What Happened

The Global Skills Sync feature created `scripts/sync-skills.sh` and a post-merge hook that
calls it. During development, the script was made executable locally with `chmod +x`, so it
worked on the developer's machine. But the execute permission was never staged in git — the
file was committed as `100644` (not executable) instead of `100755`.

On any subsequent pull — or for anyone cloning the repo — the hook would fire, detect skill
changes, and then fail with "Permission denied" when trying to execute the sync script.

This passed through all four workflow phases uncaught. The related hooks path conflict
(documented in `2026-02-20-codebase-verification-gap.md`) was a separate issue caught and
fixed earlier.

---

## Where It Should Have Been Caught

### Phase 3: Build — Per-Task Verification

The build phase verifies each task's "done when" criteria. For Task 1, that was: "Running
`bash scripts/sync-skills.sh` manually copies the 4 skill directories." This passed because
`bash scripts/sync-skills.sh` bypasses the execute permission entirely — bash reads the
file as input, it doesn't need +x. The "done when" criteria tested the script's logic, not
its deployment readiness.

### Phase 3: Build — Acceptance Criteria

The acceptance criteria tested "after `git pull` on `main` that includes changes under
`.claude/skills/`, the 4 workflow skills are copied." This was verified by running the sync
script directly, not by simulating the actual trigger path (hook → script). The hook calling
the script via `"$REPO_ROOT/scripts/sync-skills.sh"` requires execute permission, which
`bash scripts/sync-skills.sh` does not.

---

## Why It Was Missed

1. **Local state masked the problem.** The developer ran `chmod +x` during development, so
   the script was executable on their machine. The git-tracked permission (`100644`) was
   never checked.

2. **Verification tested components, not the execution chain.** The script was tested by
   running it directly with `bash`. The hook-to-script call path — which requires execute
   permission — was never exercised.

3. **No "fresh clone" mental model.** Nobody asked: "If I clone this repo and follow the
   setup instructions, does the hook actually work?" That question would have immediately
   surfaced the permission issue.

---

## Possible Improvements

### A: Add end-to-end path tracing to Build verification

After all tasks complete, before acceptance criteria, the build phase should trace the
user-facing execution path from trigger to outcome:

- What triggers the feature? (e.g., `git pull`)
- What chain of calls happens? (e.g., hook → script)
- What does each step assume? (e.g., execute permission, PATH, config)
- Would this work on a fresh clone following only the documented setup?

This is distinct from acceptance criteria, which verify *what* the feature does. Path
tracing verifies *how* it gets invoked.

### B: Add deployment-readiness checks to Build for scripts and executables

When the build creates shell scripts or executables that will be called by automation (hooks,
CI, other scripts), verify:

- File has execute permission in git (`git ls-files -s`)
- Shebang line is present
- Script can be called via its path (not just `bash script.sh`)

### C: Strengthen Plan's acceptance criteria guidance

The plan skill could prompt for execution-path criteria when the feature involves automation.
Instead of just "the sync script copies files," also include "the hook successfully calls the
sync script." However, this alone wouldn't catch deviations introduced during build.

---

## Relationship to Previous Issue

The `2026-02-20-codebase-verification-gap.md` issue addressed the plan phase failing to
check for conflicting infrastructure (hooks path). This issue addresses the build phase
failing to verify the end-to-end execution path. They are complementary gaps — one in
planning, one in verification.

Option A from this issue and Option B from the previous issue together would address both:
the plan checks for conflicts, and the build traces the full path from trigger to outcome.
