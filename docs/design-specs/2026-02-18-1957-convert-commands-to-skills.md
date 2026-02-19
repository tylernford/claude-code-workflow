# Convert Commands to Skills

**Created:** 2026-02-18 **Implementation Plan:** [link to implementation plan]

---

## Overview

**What:** Migrate the 4 workflow commands (`/design`, `/plan`, `/build`, `/document`) from
`.claude/commands/` to `.claude/skills/`, bundling templates into skill directories and
adding frontmatter configuration.

**Why:** Skills provide structural enforcement of workflow principles (e.g.,
`disable-model-invocation` prevents Claude from auto-advancing phases) and make the
workflow fully portable via symlinks by bundling templates inside skill directories.

**Type:** Refactor

---

## Requirements

### Must Have

- [ ] Convert all 4 commands to skills with identical prompt content
- [ ] Add frontmatter with `disable-model-invocation: true` and
      `allowed-tools: Read, Grep, Glob` to all 4 skills
- [ ] Move `docs/templates/design-spec.md` into `.claude/skills/design/templates/`
- [ ] Move `docs/templates/implementation-plan.md` into `.claude/skills/plan/templates/`
- [ ] Update template references in `/design` and `/plan` to use relative markdown link
      syntax
- [ ] Delete `.claude/commands/`
- [ ] Delete `docs/templates/`
- [ ] Update CLAUDE.md to reflect `.claude/skills/` structure

### Nice to Have

- [ ] Document future enhancement opportunities (see Notes)

### Out of Scope

- Dynamic context injection (`!`command`` syntax)
- `argument-hint` values
- `model` overrides per phase
- `context: fork` for isolated subagent execution
- Per-phase `allowed-tools` differentiation (Write/Edit/Bash grants)

---

## Design Decisions

### Template Location

**Options considered:**

1. Move templates into skill directories — Self-contained, portable via symlinks. Delete
   `docs/templates/`.
2. Keep templates in `docs/templates/` — No move, but skills aren't self-contained when
   symlinked.

**Decision:** Option 1. Templates only exist for the workflow commands, so bundling them
makes skills fully portable. The `docs/templates/` directory is deleted since the skill
directories become the single source of truth.

### Template Path References

**Options considered:**

1. Project-relative paths (e.g., `.claude/skills/design/templates/design-spec.md`)
2. Skill-relative paths with markdown link syntax (e.g.,
   `[templates/design-spec.md](templates/design-spec.md)`)

**Decision:** Option 2. Skills resolve file paths relative to the skill directory.
Markdown link syntax lets Claude load the file on demand. This also works when symlinked
to `~/.claude/skills/`.

### Tool Access (`allowed-tools`)

**Options considered:**

1. Per-phase tool grants matching each phase's needs (e.g., `/build` gets Bash, `/design`
   doesn't)
2. Uniform read-only grants across all phases, with Write/Edit/Bash requiring approval
3. No `allowed-tools` — inherit global permission settings

**Decision:** Option 2. `allowed-tools: Read, Grep, Glob` on all 4 skills. Write, Edit,
and Bash always require user approval. This is intentionally conservative — per-phase
grants may be expanded in the future as the workflow matures. See Notes for details.

### Frontmatter Configuration

**Options considered:**

1. Minimal frontmatter (only `disable-model-invocation`)
2. Moderate frontmatter (`disable-model-invocation` + `allowed-tools`)
3. Full frontmatter (all available fields)

**Decision:** Option 2. `disable-model-invocation: true` enforces the "user drives"
principle structurally. `allowed-tools` adds a lightweight permission layer. Other fields
are deferred to future exploration.

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

## Suggested Files to Create/Modify

```
.claude/skills/design/SKILL.md              # create — design skill with frontmatter
.claude/skills/design/templates/design-spec.md  # move from docs/templates/
.claude/skills/plan/SKILL.md                # create — plan skill with frontmatter
.claude/skills/plan/templates/implementation-plan.md  # move from docs/templates/
.claude/skills/build/SKILL.md               # create — build skill with frontmatter
.claude/skills/document/SKILL.md            # create — document skill with frontmatter
.claude/commands/                           # delete entire directory
docs/templates/                             # delete entire directory
CLAUDE.md                                   # modify — update structure and table heading
```

---

## Notes

### Future Enhancements to Explore

These features were evaluated during design and deferred. They're worth revisiting once
the base migration is stable:

- **Dynamic context injection** — Replace imperative steps like "run
  `git branch --show-current`" with `!`git branch --show-current`` in the prompt. Faster
  (no tool call) and simpler (no prerequisite step). Explore other places live data could
  be injected.
- **`argument-hint`** — Shows a placeholder hint during autocomplete (e.g.,
  `/design [feature-name]`). Purely cosmetic, improves discoverability.
- **Per-phase `allowed-tools` expansion** — The current uniform `Read, Grep, Glob` is
  conservative. As comfort grows, consider granting `Write` to design/plan phases and
  `Write, Edit, Bash` to build phase for less friction.
- **`model` overrides** — `/document` is the most formulaic phase and could potentially
  use a cheaper model. Low priority given minimal savings with only 4 skills.

### Research

Background research for this migration is documented at
`docs/research/2026-02-18-1216-commands-vs-skills.md`.
