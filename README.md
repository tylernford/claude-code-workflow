# Claude Code Workflow

A phase-based workflow for building features with Claude Code, where documentation serves
as the handoff between sessions.

## Why

Working with Claude Code across multiple sessions tends to lose context. Without
structure, you get scope drift, repeated explanations, and sessions that start from
scratch. This workflow solves that by making documentation the connective tissue between
sessions — each phase produces artifacts that the next phase consumes.

The workflow itself was built and improved using this same system.

## How It Works

Four phases, run one per session. Each phase is a skill you invoke explicitly.

| Phase        | Skill       | What happens                                                         |
| ------------ | ----------- | -------------------------------------------------------------------- |
| **Design**   | `/design`   | Transform an idea into a design spec with requirements and decisions |
| **Plan**     | `/plan`     | Break the design into executable tasks with done-when criteria       |
| **Build**    | `/build`    | Execute tasks one at a time, committing at each checkpoint           |
| **Document** | `/document` | Update changelog, generate PR description, close out the work        |

Core principles:

- **User drives** — Claude proposes, user approves. No auto-advancing between phases.
- **One phase per session** — End the session after each phase. Docs are the handoff.
- **Preserve the mess** — Note deviations in the build log rather than rewriting plans.

## Project Structure

```
.claude/skills/            # Skill definitions (design, plan, build, document)
claude-code-insights/      # Claude Code usage analysis reports
docs/
├── design-specs/          # Design documents
├── implementation-plans/  # Task breakdowns
├── changelog.md           # Completed feature history
└── backlog.md             # Future improvements
CLAUDE.md                  # Project instructions for Claude Code
```
