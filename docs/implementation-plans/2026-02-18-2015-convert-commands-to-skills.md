# Implementation Plan: Convert Commands to Skills

**Created:** 2026-02-18 **Type:** Refactor **Overview:** Migrate the 4 workflow commands
(`/design`, `/plan`, `/build`, `/document`) from `.claude/commands/` to `.claude/skills/`,
bundling templates into skill directories and adding frontmatter configuration. **Design
Spec:** docs/design-specs/2026-02-18-1957-convert-commands-to-skills.md

---

## Summary

Convert the existing `.claude/commands/` workflow to `.claude/skills/`, adding frontmatter
configuration (`disable-model-invocation: true`, `allowed-tools: Read, Grep, Glob`) and
bundling templates into their respective skill directories. Delete old directories and
update CLAUDE.md.

---

## Codebase Verification

- [x] `.claude/commands/` exists with 4 files (`build.md`, `design.md`, `document.md`,
      `plan.md`) - Verified: yes
- [x] `docs/templates/` exists with 2 files (`design-spec.md`, `implementation-plan.md`) -
      Verified: yes
- [x] `.claude/skills/` does not exist yet - Verified: yes
- [x] `design.md` references `docs/templates/design-spec.md` on line 85 - Verified: yes
- [x] `plan.md` references `docs/templates/implementation-plan.md` on line 90 - Verified:
      yes
- [x] CLAUDE.md references `.claude/commands/` and `docs/templates/` - Verified: yes

**Patterns to leverage:**

- Existing command files contain the complete prompt content to migrate

**Discrepancies found:**

- None

---

## Tasks

### Task 1: Create `/design` skill

**Description:** Create the design skill directory with SKILL.md (frontmatter + prompt
content from `design.md`) and copy the design-spec template into the skill directory.
Update the template reference to use relative markdown link syntax.

**Files:**

- `.claude/skills/design/SKILL.md` — create
- `.claude/skills/design/templates/design-spec.md` — create (copy from
  `docs/templates/design-spec.md`)

**Code example** (frontmatter + updated template reference):

```markdown
---
disable-model-invocation: true
allowed-tools: Read, Grep, Glob
---

# /design $ARGUMENTS

...

Use the template at [templates/design-spec.md](templates/design-spec.md) as your guide.
```

**Done when:** `.claude/skills/design/` contains `SKILL.md` with frontmatter and
`templates/design-spec.md`. Template reference uses relative markdown link syntax.

**Commit:** "Add design skill with bundled template"

---

### Task 2: Create `/plan` skill

**Description:** Create the plan skill directory with SKILL.md (frontmatter + prompt
content from `plan.md`) and copy the implementation-plan template into the skill
directory. Update the template reference to use relative markdown link syntax.

**Files:**

- `.claude/skills/plan/SKILL.md` — create
- `.claude/skills/plan/templates/implementation-plan.md` — create (copy from
  `docs/templates/implementation-plan.md`)

**Code example** (updated template reference):

```markdown
Use the template at [templates/implementation-plan.md](templates/implementation-plan.md)
as your guide.
```

**Done when:** `.claude/skills/plan/` contains `SKILL.md` with frontmatter and
`templates/implementation-plan.md`. Template reference uses relative markdown link syntax.

**Commit:** "Add plan skill with bundled template"

---

### Task 3: Create `/build` and `/document` skills

**Description:** Create both skills with SKILL.md files containing frontmatter + prompt
content from their respective command files. These have no templates to bundle.

**Files:**

- `.claude/skills/build/SKILL.md` — create
- `.claude/skills/document/SKILL.md` — create

**Code example** (frontmatter block, same for both):

```markdown
---
disable-model-invocation: true
allowed-tools: Read, Grep, Glob
---
```

**Done when:** Both SKILL.md files exist with correct frontmatter and identical prompt
content to the original commands.

**Commit:** "Add build and document skills"

---

### Task 4: Delete old directories and update CLAUDE.md

**Description:** Delete `.claude/commands/` and `docs/templates/`. Update CLAUDE.md to
reflect the new `.claude/skills/` structure — update the directory tree (remove
`docs/templates/`, change `.claude/commands/` to `.claude/skills/`) and rename the
"Commands" section to "Skills".

**Files:**

- `.claude/commands/` — delete entire directory
- `docs/templates/` — delete entire directory
- `CLAUDE.md` — modify

**Code example** (CLAUDE.md updates):

````markdown
## Structure

\``` .claude/skills/ # Skill definitions (design, plan, build, document)
claude-code-insights/ # Claude Code usage analysis reports docs/ ├── design-specs/ #
Design documents ├── implementation-plans/ # Task breakdowns ├── changelog.md # Completed
feature history └── backlog.md # Future improvements \```

## Skills

| Skill       | Phase | Purpose                            |
| ----------- | ----- | ---------------------------------- |
| `/design`   | 1     | Transform idea into design spec    |
| `/plan`     | 2     | Break design into executable tasks |
| `/build`    | 3     | Execute tasks with commits         |
| `/document` | 4     | Complete docs, generate PR draft   |
````

**Done when:** Old directories are deleted, CLAUDE.md reflects `.claude/skills/` structure
with `docs/templates/` line removed from the tree.

**Commit:** "Remove commands/templates, update CLAUDE.md for skills"

---

## Acceptance Criteria

- [ ] `/design`, `/plan`, `/build`, `/document` are invocable as skills and produce the
      same behavior as the current commands
- [ ] `.claude/skills/` contains 4 skill directories with correct structure (SKILL.md +
      templates where applicable)
- [ ] Each SKILL.md has frontmatter with `disable-model-invocation: true` and
      `allowed-tools: Read, Grep, Glob`
- [ ] `/design` can locate and read `templates/design-spec.md` from its skill directory
- [ ] `/plan` can locate and read `templates/implementation-plan.md` from its skill
      directory
- [ ] `.claude/commands/` is deleted
- [ ] `docs/templates/` is deleted
- [ ] CLAUDE.md reflects the new `.claude/skills/` structure

---

## Build Log

_Filled in during `/build` phase_

| Date       | Task   | Files                                                                              | Notes                                                                 |
| ---------- | ------ | ---------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| 2026-02-18 | Task 1 | .claude/skills/design/SKILL.md, .claude/skills/design/templates/design-spec.md     | Created design skill with frontmatter and bundled template            |
| 2026-02-18 | Task 2 | .claude/skills/plan/SKILL.md, .claude/skills/plan/templates/implementation-plan.md | Created plan skill with frontmatter and bundled template              |
| 2026-02-18 | Task 3 | .claude/skills/build/SKILL.md, .claude/skills/document/SKILL.md                    | Created build and document skills with frontmatter                    |
| 2026-02-18 | Task 4 | .claude/commands/ (deleted), docs/templates/ (deleted), CLAUDE.md                  | Deleted old directories, updated CLAUDE.md structure and section name |

---

## Completion

**Completed:** [Date] **Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]

---

## Notes

Task 4 (deletions) must run after Tasks 1-3 to avoid losing source content.
