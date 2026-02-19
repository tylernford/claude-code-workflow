---
disable-model-invocation: true
allowed-tools: Read, Grep, Glob
---

# /document

You are starting **Phase 4: Document**

---

## Your Role

Complete project documentation and update developer-facing docs. This is the final phase.

---

## Prerequisite

Build phase must be complete.

If the user does not provide an implementation plan path, ask them for the file path.

Also locate the changelog at `docs/changelog.md`.

---

## Announce Your Location

Every response must begin with:

```
**Phase 4: Document** | Step [N]: [Step Name]
```

---

## Steps

### Step 1: Load and Summarize

- Read the implementation plan
- Read **Type** and **Overview** from the implementation plan header
- Review the Build Log entries in the implementation plan
- Summarize what was built and any deviations noted
- Confirm this is the correct feature to document

### Step 2: Complete Implementation Plan

Update the implementation plan:

1. **Mark acceptance criteria** as `[x]` in the Acceptance Criteria section

2. **Fill in Completion section:**
   - Completed date
   - Final status (Complete | Partial | Abandoned)
   - Summary of what was actually built
   - Deviations from original plan

3. **Review Build Log** - Ensure it captures the full build history

### Step 3: Update Changelog

Read the design spec path from the implementation plan's `**Design Spec:**` header field.

Append an entry to `docs/changelog.md`:

```markdown
## YYYY-MM-DD: Feature Name

Brief description of what was built.

**Design:** [design spec path from implementation plan header] **Plan:** [link to
implementation plan] **Key files:** list of main files created/modified
```

### Step 4: Update README (if applicable)

If the feature adds user-facing functionality:

- Add or update relevant README sections
- Keep README as a comprehensive standalone reference
- Do not mention this Claude workflow (that's internal tooling)

Skip this step if the feature doesn't affect the README.

### Step 5: Final Notes

Ask user: "Anything to note? (discoveries, surprises, or context not captured in the Build
Log)"

Incorporate any final notes into the implementation plan's Completion section.

---

## PR Draft Generation

Generate a PR draft from the implementation plan:

**Title format:** `[type-prefix]: [feature name from implementation plan title]`

**Type → Prefix mapping:**

- Enhancement → `feat:`
- Bug Fix → `fix:`
- Refactor → `refactor:`
- Documentation → `docs:`
- Chore → `chore:`

If the Type doesn't match these, use best judgment or default to `feat:`.

**Description content:**

- Summary: 2-3 sentences based on the implementation plan's **Overview** and Build Log
- Changes: Key files/areas from the implementation plan's Build Log
- Documentation: Paths to design spec (from implementation plan header) and implementation
  plan

---

## Phase Complete

When documentation is complete, announce:

```
**Phase 4: Document** | Complete

Documentation updated:
- Implementation plan completed: docs/implementation-plans/YYYY-MM-DD-feature-name.md
- Changelog updated: docs/changelog.md
- README: [updated | no changes needed]

**Commit checkpoint:** Commit the documentation updates before ending this session.

---

**PR Draft** (copy/paste when creating PR):

**Title:** [type-prefix]: [feature name]

**Description:**
## Summary
[2-3 sentences based on Overview and Build Log]

## Changes
- [key files/areas from Build Log]

## Documentation
- Design: [path to design spec]
- Plan: [path to implementation plan]

---

Feature complete! The workflow cycle is finished.
```

---

## Rules

1. **Accurate history** - Document what actually happened, not what was planned
2. **User-facing only** - README updates should help future developers, not document
   process
3. **Complete the loop** - Don't skip this phase; documentation is part of done
4. **Stay local** - All files created must stay within the current project directory. No
   system-level or global configuration changes.
5. **No git operations** - Never run git commands (commit, add, push, etc.). User handles
   all version control manually.
6. **Slash commands only** - Phase transitions happen ONLY via explicit `/command`. This
   is the final phase, but the rule applies if restarting the workflow.
7. **One phase per session** - Complete this phase, then end the session. The workflow
   cycle is complete.
