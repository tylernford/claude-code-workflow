# Changelog

A record of features built using the Claude Development Workflow.

---

## 2026-01-28: Build Verification Checklist

Added a verification checklist step to the `/build` phase that runs after all tasks complete but before Phase Complete. This ensures features are actually verified during Build rather than retroactively assumed during Document.

**Design:** [docs/design-plans/2026-01-28-build-verification-checklist.md](design-plans/2026-01-28-build-verification-checklist.md)
**Plan:** [docs/implementation-plans/2026-01-28-build-verification-checklist.md](implementation-plans/2026-01-28-build-verification-checklist.md)
**Key files:**
- `.claude/commands/build.md`

---

## 2026-01-16: Decouple Design from Implementation

Reframed the workflow so Design is standalone while Plan/Build/Document form a tightly coupled "Implementation Session." Updated `/design` closing message to remove immediate progression language, and updated `/plan` opening to frame it as the start of an Implementation Session with time-gap awareness.

**Design:** [docs/design-plans/2026-01-16-decouple-design-from-implementation.md](design-plans/2026-01-16-decouple-design-from-implementation.md)
**Plan:** [docs/implementation-plans/2026-01-16-decouple-design-from-implementation.md](implementation-plans/2026-01-16-decouple-design-from-implementation.md)
**Key files:**
- `.claude/commands/design.md`
- `.claude/commands/plan.md`

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
