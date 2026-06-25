---
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# /document

You are starting **Implementation · Phase 3: Document**.

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
**Phase 3: Document** | Step [N]: [Step Name]
```

---

## Steps

### Step 1: Load and Summarize

The build history lives in **git**, not a Build Log. Source it from the commits.

- Read the implementation plan
- Read **Type** and **Overview** from the implementation plan header
- Read the build's commits with `git log <base>..HEAD` and `git log --stat <base>..HEAD`,
  including the **commit bodies** — that's where deviation rationale was recorded. Here
  `<base>` is the commit the build session started from (the parent of this feature's
  first commit; if unsure, use the merge-base with the main branch). The commit list gives
  the narrative, `--stat` gives the files, and the bodies give the deviations.
- Summarize what was built and any deviations noted
- Confirm this is the correct feature to document

### Step 2: Complete Implementation Plan

Update the implementation plan:

1. **Review acceptance criteria (read-only)** - Read the existing state in the Acceptance
   Criteria section. `/build` is the sole authority for marking `[x]`; document never sets
   or changes checkbox state. Use any items still `[ ]` to inform the Completion section
   below.

2. **Fill in Completion section:**
   - Completed date
   - Final status (Complete | Partial | Abandoned) — if any acceptance criteria remain
     `[ ]`, Final status must be `Partial` or `Abandoned`, and each unmet item is recorded
     as a deviation.
   - Summary of what was actually built
   - Deviations from original plan

### Step 3: Update Changelog

Read the design spec path from the implementation plan's `**Design Spec:**` header field.

Append an entry to `docs/changelog.md`:

```markdown
## YYYY-MM-DD: Feature Name

Brief description of what was built.

**Design:** [design spec path from implementation plan header] **Plan:** [link to
implementation plan] **Key files:** main files created/modified, from `git log --stat

<base>..HEAD`
```

### Step 4: Update README (if applicable)

If the feature adds user-facing functionality:

- Add or update relevant README sections
- Keep README as a comprehensive standalone reference
- Do not mention this Claude workflow (that's internal tooling)

Skip this step if the feature doesn't affect the README.

### Step 5: Final Notes

Ask user: "Anything to note? (discoveries, surprises, or context not captured in the
commit history)"

Incorporate any final notes into the implementation plan's Completion section.

---

## PR Draft Generation

Generate a PR draft from the implementation plan:

**Title format:** `[type-prefix]: [feature name from implementation plan title]`

**Type → Prefix mapping** (the Type values are those offered by the design spec template):

- Feature → `feat:`
- Enhancement → `feat:`
- Bugfix → `fix:`
- Refactor → `refactor:`
- Docs → `docs:`
- Process → `chore:`

If the Type doesn't match these, use best judgment or default to `feat:`.

**Description content:**

- Summary: 2-3 sentences based on the implementation plan's **Overview** and the commit
  history (`git log <base>..HEAD`)
- Changes: key files/areas from `git log --stat <base>..HEAD`
- Documentation: Paths to design spec (from implementation plan header) and implementation
  plan

---

## Phase Complete

When documentation is complete, announce:

```
**Phase 3: Document** | Complete

Documentation updated:
- Implementation plan completed: docs/implementation-plans/YYYY-MM-DD-HHMM-feature-name.md
- Changelog updated: docs/changelog.md
- README: [updated | no changes needed]

**Commit checkpoint:** Commit the documentation updates before ending this session.

---

**PR Draft** (copy/paste when creating PR):

**Title:** [type-prefix]: [feature name]

**Description:**
## Summary
[2-3 sentences based on Overview and the commit history]

## Changes
- [key files/areas from `git log --stat <base>..HEAD`]

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
5. **Git: read only, never commit** - May read git (`git status`, `git diff`, `git log`,
   `git rev-parse`) to source the narrative, files, and deviation rationale, but **never
   commits, stages, or writes git state**. Forbidden: commit, add, push, force-push,
   rebase, reset, branch creation/switching/deletion, tag, and any remote operation. The
   user commits the documentation updates.
6. **Slash commands only** - Phase transitions happen ONLY via explicit `/command`. This
   is the final phase, but the rule applies if restarting the workflow.
7. **One phase per session** - Complete this phase, then end the session. The workflow
   cycle is complete.
