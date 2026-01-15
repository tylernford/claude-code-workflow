# Implementation Plan: Workflow Phase Improvements

**Design Doc:** docs/design-plans/2026-01-15-workflow-phase-improvements.md
**Created:** 2026-01-15

---

## Summary

Improve the `/document` phase structure and add commit workflow guidance across all four phases. Changes include branch checking in `/design`, note prompts in `/build` and `/document`, and commit checkpoint reminders in all phases.

---

## Codebase Verification

*Confirmed during Plan phase*

- [x] `/design` has no Prerequisite section - Verified
- [x] `/design` Rule 6 is "No git operations" - Verified (design doc said Rule 5, but it's Rule 6)
- [x] All Phase Complete sections lack commit checkpoints - Verified
- [x] `/build` step 7 has no note prompt - Verified
- [x] `/document` has Steps 1-3 only - Verified

**Patterns to leverage:**
- All four command files use identical markdown structure
- Phase Complete sections follow consistent format

**Discrepancies found:**
- Design doc referenced "Rule 5" but the git rule is actually Rule 6 in `/design.md`

---

## Tasks

### Task 1: Update `/design.md` with branch check and commit checkpoint

**Description:** Add Prerequisite section with branch name check, update Rule 6 to allow limited git, add commit checkpoint to Phase Complete.

**Files:**
- `.claude/commands/design.md` - modify

**Changes:**

1. Add new `## Prerequisite` section after "Your Role" section:
```markdown
## Prerequisite

Run `git branch --show-current` to check the current branch.

If the branch name does not contain `feat` or `feature`, warn: "Your branch doesn't appear to be a feature branch — consider creating one before proceeding."

Continue regardless of branch.
```

2. Update Rule 6 from:
```markdown
6. **No git operations** - Never run git commands (commit, add, push, etc.). User handles all version control manually.
```
To:
```markdown
6. **Limited git** - Only `git branch --show-current` is allowed. All other git operations (commit, add, push, etc.) are user-only.
```

3. Update Phase Complete from:
```markdown
**Phase 1: Design** | Complete

Design document created at: docs/design-plans/YYYY-MM-DD-feature-name.md

Next: End this session and start a new Claude Code session.
Run `/plan` to begin Phase 2: Planning.
```
To:
```markdown
**Phase 1: Design** | Complete

Design document created at: docs/design-plans/YYYY-MM-DD-feature-name.md

**Commit checkpoint:** Commit the design document before ending this session.

Next: End this session and start a new Claude Code session.
Run `/plan` to begin Phase 2: Planning.
```

**Done when:**
- Prerequisite section exists with branch check instructions
- Rule 6 says "Limited git" and allows `git branch --show-current`
- Phase Complete includes "Commit checkpoint" line

**Commit:** "Add branch check and commit checkpoint to /design"

---

### Task 2: Update `/plan.md` with commit checkpoint

**Description:** Add commit checkpoint reminder to Phase Complete section.

**Files:**
- `.claude/commands/plan.md` - modify

**Changes:**

Update Phase Complete from:
```markdown
**Phase 2: Plan** | Complete

Implementation plan created at: docs/implementation-plans/YYYY-MM-DD-feature-name.md

Next: End this session and start a new Claude Code session.
Run `/build` to begin Phase 3: Build.
```
To:
```markdown
**Phase 2: Plan** | Complete

Implementation plan created at: docs/implementation-plans/YYYY-MM-DD-feature-name.md

**Commit checkpoint:** Commit the implementation plan before ending this session.

Next: End this session and start a new Claude Code session.
Run `/build` to begin Phase 3: Build.
```

**Done when:** Phase Complete includes "Commit checkpoint" line

**Commit:** "Add commit checkpoint to /plan"

---

### Task 3: Update `/build.md` with note prompt and commit checkpoint

**Description:** Update step 7 to prompt for notes, add commit checkpoint to Phase Complete.

**Files:**
- `.claude/commands/build.md` - modify

**Changes:**

1. Update step 7 in the Workflow section from:
```markdown
7. **Pause** - Wait for user to confirm before next task
```
To:
```markdown
7. **Pause** - Ask user: "Anything to note? (discoveries, surprises, context for later)" Then wait for confirmation before next task.
```

2. Update Phase Complete from:
```markdown
**Phase 3: Build** | Complete

All [N] tasks completed.
Build Log updated in: docs/design-plans/YYYY-MM-DD-feature-name.md

Next: End this session and start a new Claude Code session.
Run `/document` to begin Phase 4: Document.
```
To:
```markdown
**Phase 3: Build** | Complete

All [N] tasks completed.
Build Log updated in: docs/design-plans/YYYY-MM-DD-feature-name.md

**Commit checkpoint:** Ensure all tasks have been committed before ending this session.

Next: End this session and start a new Claude Code session.
Run `/document` to begin Phase 4: Document.
```

**Done when:**
- Step 7 includes "Anything to note?" prompt
- Phase Complete includes "Commit checkpoint" line

**Commit:** "Add note prompt and commit checkpoint to /build"

---

### Task 4: Restructure `/document.md` with new steps and commit checkpoint

**Description:** Add design doc path request to Prerequisite, add Step 1 (Load and Summarize), renumber existing steps, add Step 5 (Final Notes), add commit checkpoint.

**Files:**
- `.claude/commands/document.md` - modify

**Changes:**

1. Update Prerequisite section from:
```markdown
## Prerequisite

Build phase must be complete. Locate:
- The design document in `docs/design-plans/`
- The implementation plan in `docs/implementation-plans/`
- The changelog at `docs/changelog.md`
```
To:
```markdown
## Prerequisite

Build phase must be complete.

If the user does not provide a design doc path, ask them for the file path.

Then locate the corresponding implementation plan in `docs/implementation-plans/` and the changelog at `docs/changelog.md`.
```

2. Add new Step 1 before current Step 1:
```markdown
### Step 1: Load and Summarize

- Read the design document
- Locate the corresponding implementation plan
- Review the Build Log entries
- Summarize what was built and any deviations noted
- Confirm this is the correct feature to document
```

3. Renumber existing steps:
- "Step 1: Complete Design Document" → "Step 2: Complete Design Document"
- "Step 2: Update Changelog" → "Step 3: Update Changelog"
- "Step 3: Update README" → "Step 4: Update README (if applicable)"

4. Add new Step 5 after Step 4:
```markdown
### Step 5: Final Notes

Ask user: "Anything to note? (discoveries, surprises, or context not captured in the Build Log)"

Incorporate any final notes into the design document's Completion section.
```

5. Update Phase Complete from:
```markdown
**Phase 4: Document** | Complete

Documentation updated:
- Design doc completed: docs/design-plans/YYYY-MM-DD-feature-name.md
- Changelog updated: docs/changelog.md
- README: [updated | no changes needed]

Feature complete! The workflow cycle is finished.
```
To:
```markdown
**Phase 4: Document** | Complete

Documentation updated:
- Design doc completed: docs/design-plans/YYYY-MM-DD-feature-name.md
- Changelog updated: docs/changelog.md
- README: [updated | no changes needed]

**Commit checkpoint:** Commit the documentation updates before ending this session.

Feature complete! The workflow cycle is finished.
```

**Done when:**
- Prerequisite asks for design doc path if not provided
- Step 1 is "Load and Summarize"
- Steps 2-4 are the original steps (renumbered)
- Step 5 is "Final Notes" with "Anything to note?" prompt
- Phase Complete includes "Commit checkpoint" line

**Commit:** "Restructure /document with load step, notes step, and commit checkpoint"

---

## Verification Checklist

- [ ] `/design` warns when not on feature branch
- [ ] `/design` Phase Complete has commit checkpoint
- [ ] `/plan` Phase Complete has commit checkpoint
- [ ] `/build` step 7 prompts for notes
- [ ] `/build` Phase Complete has commit checkpoint
- [ ] `/document` asks for design doc path in Prerequisite
- [ ] `/document` Step 1 is "Load and Summarize"
- [ ] `/document` Step 5 is "Final Notes"
- [ ] `/document` Phase Complete has commit checkpoint
- [ ] Git rules unchanged in `/plan`, `/build`, `/document`

---

## Notes

- Tasks are independent and can be completed in any order
- Design doc referenced "Rule 5" but the actual git rule is Rule 6 — adjusted in this plan
- All changes are to markdown command files only — no code changes
