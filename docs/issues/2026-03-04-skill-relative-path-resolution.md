# Skill Relative Path Resolution

**Date:** 2026-03-04
**Context:** Using `/design` and `/plan` skills from `~/.claude/skills/` in external projects — Claude fails to find supporting template files referenced with relative paths

---

## What Happened

The `/design` and `/plan` skills reference template files using relative markdown links:

```markdown
Use the template at [templates/design-spec.md](templates/design-spec.md) as your guide.
```

When invoked from a different project (not this repo), Claude resolves the path against the project's working directory instead of the SKILL.md location (`~/.claude/skills/design/`). It concludes the template doesn't exist and improvises.

---

## What the Docs Say

The [official skills documentation](https://code.claude.com/docs/en/skills) shows relative paths as the correct approach:

> Reference supporting files from your `SKILL.md` so Claude knows what each file contains and when to load them:
> ```
> - For complete API details, see [reference.md](reference.md)
> - For usage examples, see [examples.md](examples.md)
> ```

The [best practices guide](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) reinforces this:

> "Claude navigates your skill directory like a filesystem."

---

## Known Issues

This is a known class of bugs in Claude Code's path resolution for skills:

- [#11011](https://github.com/anthropics/claude-code/issues/11011) — Skill plugin scripts fail on first execution with relative path resolution. Claude self-corrects on retry with an absolute path.
- [#10113](https://github.com/anthropics/claude-code/issues/10113) — Skills from git-installed marketplace plugins resolve to the wrong path entirely.
- [#14836](https://github.com/anthropics/claude-code/issues/14836) — Skills not loading from symlinked directories.

---

## Workaround

Replace relative paths with absolute paths using `~/.claude/skills/`:

```markdown
<!-- Before -->
Use the template at [templates/design-spec.md](templates/design-spec.md) as your guide.

<!-- After -->
Use the template at [~/.claude/skills/design/templates/design-spec.md](~/.claude/skills/design/templates/design-spec.md) as your guide.
```

This is a pragmatic fix. Absolute paths bypass the resolution bug at the cost of assuming the skill lives in `~/.claude/skills/`. If the upstream bug is fixed, these can be reverted to relative paths.

---

## Affected Files

- `.claude/skills/design/SKILL.md` — line 90, template reference
- `.claude/skills/plan/SKILL.md` — line 95, template reference
