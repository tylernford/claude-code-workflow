# Changelog

A record of features built using the Claude Development Workflow.

---

## 2026-02-18: Complete Phase Decoupling

Fully decoupled `/document` from the design spec by having `/plan` carry Type and Overview
into the implementation plan header. Updated `/document` to source PR draft content
entirely from the implementation plan, so downstream phases never need to read the design
spec.

**Design:**
[docs/design-specs/2026-02-18-1724-complete-phase-decoupling.md](design-specs/2026-02-18-1724-complete-phase-decoupling.md)
**Plan:**
[docs/implementation-plans/2026-02-18-1855-complete-phase-decoupling.md](implementation-plans/2026-02-18-1855-complete-phase-decoupling.md)
**Key files:**

- `docs/templates/implementation-plan.md`
- `.claude/commands/plan.md`
- `.claude/commands/document.md`
- `docs/templates/design-spec.md`

---

## 2026-02-18: Decouple /design from Other Phases

Moved Build Log and Completion sections from the design spec template to the
implementation plan template, then updated `/build` and `/document` so they never write to
the design spec. The design spec now freezes after `/plan`; the implementation plan owns
the full build story.

**Design:**
[docs/design-specs/2026-02-18-1317-decouple-design-from-other-phases.md](design-specs/2026-02-18-1317-decouple-design-from-other-phases.md)
**Plan:**
[docs/implementation-plans/2026-02-18-1442-decouple-design-from-other-phases.md](implementation-plans/2026-02-18-1442-decouple-design-from-other-phases.md)
**Key files:**

- `docs/templates/design-spec.md`
- `docs/templates/implementation-plan.md`
- `.claude/commands/build.md`
- `.claude/commands/document.md`
- `docs/backlog.md`

---

## 2026-02-18: Add Prettier Formatting

Added Prettier as a pre-commit hook for consistent Markdown formatting across the repo. A
`.prettierrc` config and `.githooks/pre-commit` script run Prettier against staged `.md`
files on every commit.

**Key files:**

- `.prettierrc`
- `.githooks/pre-commit`

---

## 2026-02-17: Rename "Design Plan" to "Design Spec"

Renamed "Design Plan" terminology to "Design Spec" across the workflow system. The design
phase produces a specification (what/why), not a plan — "Design Spec" pairs cleanly with
"Implementation Plan" (how/tasks), making each artifact's purpose distinct. Also updated
"design doc" / "design document" → "design spec" and "Implementation Plan Doc" →
"Implementation Plan" in slash commands, templates, and docs.

---

## 2026-02-16: Reorder Build Steps

Swapped the Log and Commit steps in the `/build` per-task workflow so the build log is
updated before committing. Each commit now includes its own log entry, making commits
self-contained records of what was done.

**Key files:**

- `.claude/commands/build.md`

---

## 2026-02-04: Acceptance Criteria Restructure

Restructured the `/build` command so acceptance criteria are embedded in the Workflow
section as a mandatory gate before Phase Complete. Previously, the standalone
"Verification Checklist" section was structurally isolated and Claude would skip it when
gravitating to Phase Complete. The new structure places "After All Tasks: Acceptance
Criteria" alongside "For Each Task" within Workflow.

**Design:**
[docs/design-plans/2026-02-04-0917-acceptance-criteria-restructure.md](design-plans/2026-02-04-0917-acceptance-criteria-restructure.md)
**Plan:**
[docs/implementation-plans/2026-02-04-0926-acceptance-criteria-restructure.md](implementation-plans/2026-02-04-0926-acceptance-criteria-restructure.md)
**Key files:**

- `.claude/commands/build.md`
- `docs/templates/implementation-plan.md`

---

## 2026-02-03: Add CLAUDE.md

Added a `CLAUDE.md` file to the repo root that provides instant workflow context for new
Claude sessions. The file includes the repo purpose, directory structure, command table,
and core principles—eliminating the need for Claude to read multiple files to understand
the project.

**Design:**
[docs/design-plans/2026-02-03-2241-add-claude-md.md](design-plans/2026-02-03-2241-add-claude-md.md)
**Plan:**
[docs/implementation-plans/2026-02-03-2243-add-claude-md.md](implementation-plans/2026-02-03-2243-add-claude-md.md)
**Key files:**

- `CLAUDE.md`

---

## 2026-02-03: Fix Doc Path Asking

Fixed a bug where `/plan` and `/build` commands would search directories instead of asking
for document paths when not provided via arguments. Simplified the Prerequisite sections
to remove directory references that triggered the search behavior, matching `/document`'s
working pattern.

**Design:**
[docs/design-plans/2026-02-03-2142-fix-doc-path-asking.md](design-plans/2026-02-03-2142-fix-doc-path-asking.md)
**Plan:**
[docs/implementation-plans/2026-02-03-2147-fix-doc-path-asking.md](implementation-plans/2026-02-03-2147-fix-doc-path-asking.md)
**Key files:**

- `.claude/commands/plan.md`
- `.claude/commands/build.md`

---

## 2026-02-03: Add Timestamp Verification Instructions

Added explicit instructions to the `/design` and `/plan` commands for obtaining the
current timestamp before creating documents. The instruction "Before creating the file,
run `date +%Y-%m-%d-%H%M` to get the current timestamp." now appears immediately before
the file path templates in both commands.

**Design:**
[docs/design-plans/2026-02-03-2059-add-timestamp-verification-instructions.md](design-plans/2026-02-03-2059-add-timestamp-verification-instructions.md)
**Plan:**
[docs/implementation-plans/2026-02-03-2104-add-timestamp-verification-instructions.md](implementation-plans/2026-02-03-2104-add-timestamp-verification-instructions.md)
**Key files:**

- `.claude/commands/design.md`
- `.claude/commands/plan.md`

---

## 2026-01-28: Design Doc Link to Implementation Plan

Added bidirectional linking between design docs and implementation plans. The design doc
template now includes an `Implementation Plan Doc` field, `/plan` writes the plan path
back into the design doc, and `/document` reads the link from the header instead of
searching.

**Design:**
[docs/design-plans/2026-01-28-1517-design-doc-link-to-plan.md](design-plans/2026-01-28-1517-design-doc-link-to-plan.md)
**Plan:**
[docs/implementation-plans/2026-01-28-1520-design-doc-link-to-plan.md](implementation-plans/2026-01-28-1520-design-doc-link-to-plan.md)
**Key files:**

- `docs/templates/design-doc.md`
- `.claude/commands/plan.md`
- `.claude/commands/document.md`

---

## 2026-01-28: Add Time to Filename Dates

Added HHMM time component to design doc and implementation plan filename formats, changing
from `YYYY-MM-DD-feature-name.md` to `YYYY-MM-DD-HHMM-feature-name.md`. This enables
chronological sorting when multiple documents are created on the same date.

**Design:**
[docs/design-plans/2026-01-28-1129-add-time-to-filename-dates.md](design-plans/2026-01-28-1129-add-time-to-filename-dates.md)
**Plan:**
[docs/implementation-plans/2026-01-28-1138-add-time-to-filename-dates.md](implementation-plans/2026-01-28-1138-add-time-to-filename-dates.md)
**Key files:**

- `.claude/commands/design.md`
- `.claude/commands/plan.md`

---

## 2026-01-28: Add PR Draft to Document Phase

Added PR draft generation to the `/document` phase. The PR draft appears in Phase Complete
output with a conventional commit-style title, summary, key changes, and documentation
links—giving users copy/paste-ready content for PR creation.

**Design:**
[docs/design-plans/2026-01-28-add-pr-draft-to-document-phase.md](design-plans/2026-01-28-add-pr-draft-to-document-phase.md)
**Plan:**
[docs/implementation-plans/2026-01-28-add-pr-draft-to-document-phase.md](implementation-plans/2026-01-28-add-pr-draft-to-document-phase.md)
**Key files:**

- `.claude/commands/document.md`

---

## 2026-01-28: Build Verification Checklist

Added a verification checklist step to the `/build` phase that runs after all tasks
complete but before Phase Complete. This ensures features are actually verified during
Build rather than retroactively assumed during Document.

**Design:**
[docs/design-plans/2026-01-28-build-verification-checklist.md](design-plans/2026-01-28-build-verification-checklist.md)
**Plan:**
[docs/implementation-plans/2026-01-28-build-verification-checklist.md](implementation-plans/2026-01-28-build-verification-checklist.md)
**Key files:**

- `.claude/commands/build.md`

---

## 2026-01-16: Decouple Design from Implementation

Reframed the workflow so Design is standalone while Plan/Build/Document form a tightly
coupled "Implementation Session." Updated `/design` closing message to remove immediate
progression language, and updated `/plan` opening to frame it as the start of an
Implementation Session with time-gap awareness.

**Design:**
[docs/design-plans/2026-01-16-decouple-design-from-implementation.md](design-plans/2026-01-16-decouple-design-from-implementation.md)
**Plan:**
[docs/implementation-plans/2026-01-16-decouple-design-from-implementation.md](implementation-plans/2026-01-16-decouple-design-from-implementation.md)
**Key files:**

- `.claude/commands/design.md`
- `.claude/commands/plan.md`

---

## 2026-01-15: Simplify Doc Path Input

Updated `/plan` and `/build` commands to ask for document paths instead of searching
directories and listing files. Matches the existing `/document` pattern and reduces token
usage.

**Design:**
[docs/design-plans/2026-01-15-simplify-doc-path-input.md](design-plans/2026-01-15-simplify-doc-path-input.md)
**Plan:**
[docs/implementation-plans/2026-01-15-simplify-doc-path-input.md](implementation-plans/2026-01-15-simplify-doc-path-input.md)
**Key files:**

- `.claude/commands/plan.md`
- `.claude/commands/build.md`

---

## 2026-01-15: Workflow Phase Improvements

Enhanced the Claude Development Workflow with better structure and commit guidance. Added
branch checking to `/design`, commit checkpoint reminders to all phases, note-taking
prompts to `/build` and `/document`, and restructured `/document` with a Load and
Summarize step.

**Design:**
[docs/design-plans/2026-01-15-workflow-phase-improvements.md](design-plans/2026-01-15-workflow-phase-improvements.md)
**Plan:**
[docs/implementation-plans/2026-01-15-workflow-phase-improvements.md](implementation-plans/2026-01-15-workflow-phase-improvements.md)
**Key files:**

- `.claude/commands/design.md`
- `.claude/commands/plan.md`
- `.claude/commands/build.md`
- `.claude/commands/document.md`

---

## 2026-01-15: Claude Development Workflow

Implemented a phase-based workflow for building features with Claude Code. Four slash
commands guide development through Design, Plan, Build, and Document phases.

**Design:**
[docs/design-plans/2026-01-15-claude-development-workflow.md](design-plans/2026-01-15-claude-development-workflow.md)
**Plan:** (this feature bootstrapped itself) **Key files:**

- `.claude/commands/design.md`
- `.claude/commands/plan.md`
- `.claude/commands/build.md`
- `.claude/commands/document.md`
- `docs/templates/design-doc.md`
- `docs/templates/implementation-plan.md`
