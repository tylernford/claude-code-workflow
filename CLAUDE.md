# Claude Development Workflow

This repo contains a phase-based workflow system for building features with Claude Code. The workflow itself is built and improved using this same system.

## Structure

```
.claude/commands/          # Slash command definitions
claude-code-insights/      # Claude Code usage analysis reports
docs/
├── design-plans/          # Design documents
├── implementation-plans/  # Task breakdowns
├── templates/             # design-doc.md, implementation-plan.md
├── changelog.md           # Completed feature history
└── backlog.md             # Future improvements
```

## Commands

| Command | Phase | Purpose |
|---------|-------|---------|
| `/design` | 1 | Transform idea into design document |
| `/plan` | 2 | Break design into executable tasks |
| `/build` | 3 | Execute tasks with commits |
| `/document` | 4 | Complete docs, generate PR draft |

## Core Principles

- **User drives** — Claude proposes, user approves. No auto-advancing.
- **One phase per session** — End session after each phase. Docs are the handoff.
- **Slash commands only** — Phase transitions require explicit `/command`.
- **Preserve the mess** — Note deviations in Build Log, don't rewrite plans.
