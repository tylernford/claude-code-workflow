# Workflow Phase Improvements

**Created:** 2026-01-15
**Status:** Design

---

## Overview

**What:** Improve the `/document` phase structure and add commit workflow guidance across all four phases.

**Why:** The document phase felt looser than other phases — unclear what info to provide and when. Additionally, there was no clarity on when to commit during the workflow, leading to batching everything at the end.

**Type:** Enhancement

---

## Requirements

### Must Have
- [ ] `/document` asks for design doc path if not provided (matches `/plan` and `/build` pattern)
- [ ] `/document` has a "Load and Summarize" step before documentation work
- [ ] `/build` prompts "Anything to note?" after each task
- [ ] `/document` prompts "Anything to note?" before finalizing
- [ ] All four phases have commit checkpoint reminders in "Phase Complete" section
- [ ] `/design` checks branch name and warns if not a feature branch

### Nice to Have
- [ ] Consistent rule numbering across files

### Out of Scope
- Changes to design doc template (`docs/templates/design-doc.md`)
- Changes to implementation plan template (`docs/templates/implementation-plan.md`)
- Automated git operations (commits remain user-only)
- Changes to `/plan` phase structure

---

## Design Decisions

### Git Rule Approach
**Options considered:**
1. Blanket "No git operations" rule across all phases
2. Whitelist specific allowed git commands in all phases
3. Whitelist only in phases that need it

**Decision:** Option 3. Only `/design` needs to run `git branch --show-current` for the branch check. Other phases keep the "No git operations" rule unchanged.

### Branch Check Logic
**Options considered:**
1. Warn if on `main` or `master`
2. Warn if branch name doesn't contain `feat` or `feature`

**Decision:** Option 2. Positive check for feature branch naming convention is more robust than blacklisting specific branch names.

### Note Capture Timing
**Options considered:**
1. Rely on memory at document phase
2. User maintains separate notes document
3. Collaborative note-taking during all phases
4. Capture during build phase only, with catch-all at document phase

**Decision:** Option 4. Build phase is where implementation surprises happen. Adding "Anything to note?" at each task pause point captures context in the moment. Document phase gets a final sweep as catch-all.

### Document Phase Input
**Options considered:**
1. Proactively list available design docs and ask which one
2. Ask for file path only if user doesn't provide one

**Decision:** Option 2. Simpler flow — just ask for the path if not provided.

---

## Acceptance Criteria

- [ ] `/design` runs `git branch --show-current` and warns if `feat`/`feature` not in branch name
- [ ] `/design` Phase Complete includes commit checkpoint reminder
- [ ] `/plan` Phase Complete includes commit checkpoint reminder
- [ ] `/build` step 7 asks "Anything to note?" before continuing
- [ ] `/build` Phase Complete includes commit checkpoint reminder
- [ ] `/document` Prerequisite asks for design doc path if not provided
- [ ] `/document` has Step 1: Load and Summarize
- [ ] `/document` has Step 5: Final Notes with "Anything to note?" prompt
- [ ] `/document` Phase Complete includes commit checkpoint reminder
- [ ] `/design` Rule 5 updated to "Limited git" whitelist
- [ ] `/plan`, `/build`, `/document` git rules unchanged

---

## Files to Modify

```
.claude/commands/design.md    # Add branch check, update git rule, add commit checkpoint
.claude/commands/plan.md      # Add commit checkpoint
.claude/commands/build.md     # Add "Anything to note?" to step 7, add commit checkpoint
.claude/commands/document.md  # Restructure prerequisite, add steps 1 and 5, renumber, add commit checkpoint
```

---

## Proposed Changes

### `/design` Changes

**New Prerequisite section:**
```markdown
## Prerequisite

Run `git branch --show-current` to check the current branch.

If the branch name does not contain `feat` or `feature`, warn: "Your branch doesn't appear to be a feature branch — consider creating one before proceeding."

Continue regardless of branch.
```

**Updated Rule 5:**
```markdown
5. **Limited git** - Only `git branch --show-current` is allowed. All other git operations (commit, add, push, etc.) are user-only.
```

**Updated Phase Complete:**
```markdown
**Phase 1: Design** | Complete

Design document created at: docs/design-plans/YYYY-MM-DD-feature-name.md

**Commit checkpoint:** Commit the design document before ending this session.

Next: End this session and start a new Claude Code session.
Run `/plan` to begin Phase 2: Planning.
```

### `/plan` Changes

**Updated Phase Complete:**
```markdown
**Phase 2: Plan** | Complete

Implementation plan created at: docs/implementation-plans/YYYY-MM-DD-feature-name.md

**Commit checkpoint:** Commit the implementation plan before ending this session.

Next: End this session and start a new Claude Code session.
Run `/build` to begin Phase 3: Build.
```

### `/build` Changes

**Updated step 7:**
```markdown
7. **Pause** - Ask user: "Anything to note? (discoveries, surprises, context for later)" Then wait for confirmation before next task.
```

**Updated Phase Complete:**
```markdown
**Phase 3: Build** | Complete

All [N] tasks completed.
Build Log updated in: docs/design-plans/YYYY-MM-DD-feature-name.md

**Commit checkpoint:** Ensure all tasks have been committed before ending this session.

Next: End this session and start a new Claude Code session.
Run `/document` to begin Phase 4: Document.
```

### `/document` Changes

**Updated Prerequisite:**
```markdown
## Prerequisite

Build phase must be complete.

If the user does not provide a design doc path, ask them for the file path.

Then locate the corresponding implementation plan in `docs/implementation-plans/` and the changelog at `docs/changelog.md`.
```

**New Step 1:**
```markdown
### Step 1: Load and Summarize

- Read the design document
- Locate the corresponding implementation plan
- Review the Build Log entries
- Summarize what was built and any deviations noted
- Confirm this is the correct feature to document
```

**Renumbered steps:**
- Step 2: Complete Design Document (was Step 1)
- Step 3: Update Changelog (was Step 2)
- Step 4: Update README (was Step 3)

**New Step 5:**
```markdown
### Step 5: Final Notes

Ask user: "Anything to note? (discoveries, surprises, or context not captured in the Build Log)"

Incorporate any final notes into the design document's Completion section.
```

**Updated Phase Complete:**
```markdown
**Phase 4: Document** | Complete

Documentation updated:
- Design doc completed: docs/design-plans/YYYY-MM-DD-feature-name.md
- Changelog updated: docs/changelog.md
- README: [updated | no changes needed]

**Commit checkpoint:** Commit the documentation updates before ending this session.

Feature complete! The workflow cycle is finished.
```

---

## Build Log

*Filled in during `/build` phase*

| Date | Task | Files | Notes |
|------|------|-------|-------|
| 2026-01-15 | Task 1 | .claude/commands/design.md | Added Prerequisite section, updated Rule 6 to "Limited git", added commit checkpoint |
| 2026-01-15 | Task 2 | .claude/commands/plan.md | Added commit checkpoint to Phase Complete |
| 2026-01-15 | Task 3 | .claude/commands/build.md | Added "Anything to note?" prompt to step 7, added commit checkpoint |
| 2026-01-15 | Task 4 | .claude/commands/document.md | Restructured: new Prerequisite, Step 1 Load/Summarize, renumbered steps, Step 5 Final Notes, commit checkpoint |

---

## Completion

**Completed:** [Date]
**Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]
