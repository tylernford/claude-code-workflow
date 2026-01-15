# Changelog

A record of features built using the Claude Development Workflow.

---

## 2026-01-15: Simplify Doc Path Input

Updated `/plan` and `/build` commands to ask for document paths instead of searching directories and listing files. Matches the existing `/document` pattern and reduces token usage.

**Design:** [docs/design-plans/2026-01-15-simplify-doc-path-input.md](design-plans/2026-01-15-simplify-doc-path-input.md)
**Plan:** [docs/implementation-plans/2026-01-15-simplify-doc-path-input.md](implementation-plans/2026-01-15-simplify-doc-path-input.md)
**Key files:**
- `.claude/commands/plan.md`
- `.claude/commands/build.md`

---

## 2026-01-15: Workflow Phase Improvements

Enhanced the Claude Development Workflow with better structure and commit guidance. Added branch checking to `/design`, commit checkpoint reminders to all phases, note-taking prompts to `/build` and `/document`, and restructured `/document` with a Load and Summarize step.

**Design:** [docs/design-plans/2026-01-15-workflow-phase-improvements.md](design-plans/2026-01-15-workflow-phase-improvements.md)
**Plan:** [docs/implementation-plans/2026-01-15-workflow-phase-improvements.md](implementation-plans/2026-01-15-workflow-phase-improvements.md)
**Key files:**
- `.claude/commands/design.md`
- `.claude/commands/plan.md`
- `.claude/commands/build.md`
- `.claude/commands/document.md`

---

## 2026-01-15: Claude Development Workflow

Implemented a phase-based workflow for building features with Claude Code. Four slash commands guide development through Design, Plan, Build, and Document phases.

**Design:** [docs/design-plans/2026-01-15-claude-development-workflow.md](design-plans/2026-01-15-claude-development-workflow.md)
**Plan:** (this feature bootstrapped itself)
**Key files:**
- `.claude/commands/design.md`
- `.claude/commands/plan.md`
- `.claude/commands/build.md`
- `.claude/commands/document.md`
- `docs/templates/design-doc.md`
- `docs/templates/implementation-plan.md`
