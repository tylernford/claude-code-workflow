# Commands vs Skills in Claude Code

**Created:** 2026-02-18 **Purpose:** Evaluate whether to migrate the workflow from
`.claude/commands/` to `.claude/skills/`

---

## Background

This repo's phase-based workflow (`/design`, `/plan`, `/build`, `/document`) is currently
implemented as custom slash commands in `.claude/commands/`. Claude Code has introduced
Skills as the successor format. Commands still work and are not deprecated, but skills are
the recommended path forward.

---

## How Commands Work

- **Location:** `.claude/commands/<name>.md`
- **Format:** Plain markdown, no frontmatter
- **Invocation:** User types `/<name>` (e.g., `/design my-feature`)
- **Arguments:** `$ARGUMENTS` for all args, `$0`, `$1` for positional
- **Scope:** Project (`.claude/commands/`) or personal (`~/.claude/commands/`)
- **Discovery:** Project commands override personal commands with the same name

Commands are single files. No configuration, no metadata, no directory structure.

---

## How Skills Work

- **Location:** `.claude/skills/<name>/SKILL.md`
- **Format:** Markdown with optional YAML frontmatter
- **Invocation:** User types `/<name>` OR Claude auto-invokes based on description
- **Arguments:** Same as commands (`$ARGUMENTS`, `$0`, `$1`)
- **Scope:** Enterprise > Personal (`~/.claude/skills/`) > Project (`.claude/skills/`) >
  Plugin
- **Discovery:** Priority hierarchy; highest scope wins on name conflicts

Skills are directories. The `SKILL.md` file is required; supporting files (templates,
scripts, examples) are optional.

---

## Frontmatter Schema (Skills Only)

| Field                      | Type    | Default           | Description                                                                          |
| -------------------------- | ------- | ----------------- | ------------------------------------------------------------------------------------ |
| `name`                     | string  | directory name    | Slash command name. Lowercase, hyphens, max 64 chars.                                |
| `description`              | string  | first paragraph   | What the skill does. Claude uses this to decide when to auto-invoke.                 |
| `argument-hint`            | string  | —                 | Hint shown during autocomplete (e.g., `[feature-name]`)                              |
| `disable-model-invocation` | boolean | `false`           | Prevents Claude from auto-invoking. User-only.                                       |
| `user-invocable`           | boolean | `true`            | Hides from `/` menu when `false`. For background knowledge skills.                   |
| `allowed-tools`            | string  | —                 | Comma-separated tools granted without approval (e.g., `Read, Grep, Glob`)            |
| `model`                    | string  | session default   | Override model for this skill (e.g., `claude-haiku-4-5`)                             |
| `context`                  | `fork`  | —                 | Runs skill in an isolated subagent context                                           |
| `agent`                    | string  | `general-purpose` | Subagent type when `context: fork` (`Explore`, `Plan`, `general-purpose`, or custom) |
| `hooks`                    | object  | —                 | Hooks scoped to this skill's lifecycle                                               |

---

## Feature Comparison

| Feature                               | Commands | Skills                                 |
| ------------------------------------- | -------- | -------------------------------------- |
| Manual invocation via `/name`         | Yes      | Yes                                    |
| `$ARGUMENTS` and positional args      | Yes      | Yes                                    |
| Project + personal scope              | Yes      | Yes                                    |
| YAML frontmatter configuration        | No       | Yes                                    |
| Supporting files (templates, scripts) | No       | Yes (directory structure)              |
| Auto-invocation by Claude             | No       | Yes (via description matching)         |
| Disable auto-invocation               | N/A      | Yes (`disable-model-invocation: true`) |
| Hide from user menu                   | No       | Yes (`user-invocable: false`)          |
| Restrict tool access                  | No       | Yes (`allowed-tools`)                  |
| Run in isolated subagent              | No       | Yes (`context: fork`)                  |
| Model override                        | No       | Yes (`model` field)                    |
| Skill-scoped hooks                    | No       | Yes (`hooks` field)                    |
| Dynamic context injection             | No       | Yes (`` !`command` `` syntax)          |
| Argument hint in autocomplete         | No       | Yes (`argument-hint`)                  |

---

## What Skills Enable for This Workflow

### 1. Invocation Control

The workflow's core principle is "user drives — no auto-advancing." With commands, this is
enforced by convention (CLAUDE.md rules). With skills, it's enforced structurally:

```yaml
disable-model-invocation: true
```

Claude literally cannot trigger a phase transition on its own.

### 2. Supporting Files in the Skill Directory

Currently, commands reference templates at `docs/templates/design-spec.md` via a path in
the markdown. With skills, the template can live inside the skill directory:

```
.claude/skills/design/
├── SKILL.md
└── templates/
    └── design-spec.md
```

This keeps the skill self-contained. The template travels with the skill when symlinked to
`~/.claude/skills/`.

### 3. Tool Restrictions

Each phase could restrict what Claude is allowed to do:

| Phase       | Sensible `allowed-tools`                                |
| ----------- | ------------------------------------------------------- |
| `/design`   | `Read, Grep, Glob, Write` (no Bash except branch check) |
| `/plan`     | `Read, Grep, Glob, Write`                               |
| `/build`    | `Read, Edit, Write, Bash, Grep, Glob`                   |
| `/document` | `Read, Edit, Write, Grep, Glob`                         |

This prevents mistakes like Claude running destructive commands during a design phase.

### 4. Dynamic Context Injection

Skills can inject live data before Claude sees the prompt:

```markdown
Current branch: !`git branch --show-current`
```

This replaces the current approach of instructing Claude to run
`git branch --show-current` as a step. The data is available immediately.

### 5. Model Override

Lower-stakes phases could use cheaper/faster models:

```yaml
model: claude-sonnet-4-6 # for /document phase
```

### 6. Argument Hints

```yaml
argument-hint: [feature-name]
```

Shows `[feature-name]` during autocomplete so you remember what to type.

---

## What Doesn't Change

- Invocation syntax: `/design my-feature` works identically
- Prompt content: The SKILL.md body is the same markdown that's currently in the command
  file
- Workflow rules: Still enforced via the skill content and CLAUDE.md
- User experience: Functionally identical from the user's perspective

---

## Migration Considerations

### Template Location

Commands currently reference `docs/templates/design-spec.md` and
`docs/templates/implementation-plan.md`. Two options:

1. **Move templates into skill directories** — Self-contained, portable via symlinks.
   Delete `docs/templates/` since the skill directories become the single source of truth.
   Templates are less discoverable for someone browsing the repo, but they're still
   findable in `.claude/skills/`.
2. **Keep templates in `docs/templates/`** — No move needed, but skills aren't fully
   self-contained when symlinked to `~/.claude/skills/` (they'd reference paths that don't
   exist in other projects).

Option 1 is better for portability. The templates only exist to be used by the workflow
commands, so there's no reason to keep a separate `docs/templates/` directory once the
skills contain them.

### Symlink Strategy

If skills are installed globally via symlinks:

```bash
ln -s /path/to/repo/.claude/skills ~/.claude/skills
```

Skills must be self-contained — they can't reference `docs/templates/` via relative paths
because those paths won't exist in other projects. This is another argument for bundling
templates inside skill directories.

### Backward Compatibility

If both `.claude/commands/design.md` and `.claude/skills/design/SKILL.md` exist, the skill
takes precedence. Migration can be incremental — convert one command at a time.

---

## Gotchas

- **Description budget:** Skill descriptions share a context window budget (2% of context,
  fallback 16,000 chars). With only 4 skills this is not a concern.
- **`context: fork` requires explicit instructions:** A forked skill needs a clear task,
  not just guidelines. The current workflow commands are task-oriented, so this would work
  if desired.
- **`user-invocable: false` doesn't block the Skill tool:** Only
  `disable-model-invocation: true` actually prevents Claude from triggering a skill
  programmatically.
- **Argument appending:** If `$ARGUMENTS` isn't in the skill content, Claude Code appends
  `ARGUMENTS: <value>` to the end. Current commands already use `$ARGUMENTS`, so this is a
  non-issue.

---

## Recommendation

Migrate. The structural enforcement of `disable-model-invocation: true` aligns with the
workflow's core principles better than relying on CLAUDE.md rules alone. Bundling
templates inside skill directories makes the workflow fully portable via symlinks. Tool
restrictions add a safety layer that doesn't exist today.

The migration is low-risk: same invocation, same prompt content, same user experience. The
frontmatter adds capabilities without changing behavior.
