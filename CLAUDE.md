# Claude Development Workflow

This repo contains a phase-based workflow system for building features with Claude Code.
The workflow itself is built and improved using this same system.

## Structure

```
.claude/skills/            # Skill definitions (design, plan, build, document)
claude-code-insights/      # Claude Code usage analysis reports
docs/
├── design-specs/          # Design documents
├── implementation-plans/  # Task breakdowns
├── changelog.md           # Completed feature history
└── backlog.md             # Future improvements
```

## Skills

| Skill       | Phase | Purpose                            |
| ----------- | ----- | ---------------------------------- |
| `/design`   | 1     | Transform idea into design spec    |
| `/plan`     | 2     | Break design into executable tasks |
| `/build`    | 3     | Execute tasks with commits         |
| `/document` | 4     | Complete docs, generate PR draft   |

## Core Principles

- **User drives** — Claude proposes, user approves. No auto-advancing.
- **One phase per session** — End session after each phase. Docs are the handoff.
- **Slash commands only** — Phase transitions require explicit `/command`.
- **Preserve the mess** — Note deviations in Build Log, don't rewrite plans.
