# Claude Development Workflow

This repo contains a phase-based workflow system for building features with Claude Code.
The workflow itself is built and improved using this same system.

## Structure

```
.claude/skills/            # Skill definitions (design, plan, build, document, learn-by-doing, study-partner)
claude-code-insights/      # Claude Code usage analysis reports
docs/
├── design-specs/          # Design documents
├── implementation-plans/  # Task breakdowns
├── issues/                # Post-mortems / bug write-ups
├── research/              # Research notes and explorations
├── changelog.md           # Completed feature history
└── backlog.md             # Future improvements
```

## Skills

`/design` is a standalone upstream phase — it produces a frozen design spec. The
implementation workflow that follows is a three-phase arc.

**Design (standalone)**

| Skill     | Purpose                         |
| --------- | ------------------------------- |
| `/design` | Transform idea into design spec |

**Implementation**

| Skill             | Phase   | Purpose                            |
| ----------------- | ------- | ---------------------------------- |
| `/plan`           | 1       | Break design into executable tasks |
| `/build`          | 2       | Execute tasks with commits         |
| `/learn-by-doing` | 2 (alt) | User implements, Claude tutors     |
| `/document`       | 3       | Complete docs, generate PR draft   |

## Core Principles

- **User drives** — Claude proposes, user approves. No auto-advancing.
- **One phase per session** — End session after each phase. Docs are the handoff.
- **Slash commands only** — Phase transitions require explicit `/command`.
- **Preserve the mess** — Record deviations in the commit body, don't rewrite plans.
