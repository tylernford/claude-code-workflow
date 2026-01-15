# Claude Development Workflow

**Created:** 2026-01-15
**Status:** Complete

---

## Overview

**What:** A rigorous, phase-based workflow for building features with Claude Code.

**Why:** Working with LLMs can be disorienting — things happen fast, context gets lost, and it's easy to feel like you're "riding the dragon" instead of driving. This workflow keeps you in control with explicit phases, clear checkpoints, and documentation that captures not just what we built, but how we got there.

**Type:** Process/Workflow

---

## Core Principles

1. **You drive** — Claude proposes, you approve. No auto-advancing.
2. **Slash commands only** — Phases are triggered ONLY by `/command`. Natural language like "ready to build" does not trigger anything.
3. **One phase per session** — Each phase is a discrete Claude Code session. When a phase completes, end the session. Start a new session for the next phase. The docs are the handoff, not conversation memory.
4. **Announce location** — Every response states the current phase and step.
5. **Pause at transitions** — Phase ends, you decide when to start the next.
6. **Summarize before moving** — Recap decisions at the end of each phase.
7. **Preserve the mess** — Plans stay as originally written; deviations are noted, not erased.

---

## Workflow Phases

### Phase 1: Design (`/design feature-name`)

**Purpose:** Transform a raw idea into a structured, validated design document.

**Steps:**

1. **Context Gathering**
   - What are we building?
   - What constraints exist?
   - What decisions have already been made?
   - Any reference URLs, docs, or examples?

2. **Clarification**
   - Identify ambiguous terms
   - Define scope precisely (e.g., "users" → website visitors? form submitters? content editors?)
   - Confirm what's in scope vs. out of scope

3. **Brainstorming** (if needed)
   - Present 2-3 architectural approaches
   - Outline trade-offs for each
   - User selects direction

4. **Incremental Validation**
   - Present small sections of the approach for feedback
   - Iterate until solid

5. **Write Design Document**
   - Create `docs/design-plans/YYYY-MM-DD-feature-name.md`
   - Include: overview, requirements, design decisions, acceptance criteria

**Output:** Finalized design document with clear requirements and acceptance criteria.

**End of session.** Start a new Claude Code session and run `/plan` to begin the next phase.

---

### Phase 2: Plan (`/plan`)

**Purpose:** Break the design into atomic, executable tasks with clear commit points.

**Input:** The design document from Phase 1.

**Steps:**

1. **Codebase Verification**
   - Verify assumptions in design doc match actual codebase
   - Check for existing patterns, utilities, or components to leverage
   - Flag any discrepancies

2. **Task Creation**
   - Break design into right-sized tasks (15-45 min each)
   - Each task includes:
     - Clear description of what to do
     - Specific file paths to create/modify
     - Code examples where helpful
     - Expected output (what "done" looks like)
     - Commit message

3. **Plan Validation**
   - Review task list against design doc
   - Confirm all requirements are covered
   - Confirm all acceptance criteria are testable

**Output:** Implementation plan at `docs/implementation-plans/YYYY-MM-DD-feature-name.md`

**End of session.** Start a new Claude Code session and run `/build` to begin the next phase.

---

### Phase 3: Build (`/build`)

**Purpose:** Execute the plan, task by task, with commits at each checkpoint.

**Input:** The implementation plan from Phase 2.

**Steps:**

1. **Execute Tasks Sequentially**
   - Work through tasks in order
   - Announce current task before starting
   - Complete one task fully before moving to next

2. **Commit Per Task**
   - One commit per completed task
   - Use the commit message from the plan
   - Commit to feature branch

3. **Note Deviations**
   - If something doesn't go as planned, note it
   - Don't update the plan doc — record deviations in design doc's Build Log
   - Continue with adjusted approach

4. **Update Design Doc**
   - Fill in Build Log section as we go
   - Record date, files created, deviations, notes

**Output:** Working feature on feature branch, with design doc Build Log completed.

**End of session.** Start a new Claude Code session and run `/document` to begin the next phase.

---

### Phase 4: Document (`/document`)

**Purpose:** Complete project history documentation and update developer-facing docs.

**Steps:**

1. **Complete Design Doc**
   - Fill in Completion section
   - Mark status as "Complete"
   - Ensure Build Log captures any deviations

2. **Update Changelog**
   - Append entry to `docs/changelog.md`
   - Format:
     ```markdown
     ## YYYY-MM-DD: Feature Name
     Brief description of what was built.

     **Design:** [link to design doc]
     **Plan:** [link to implementation plan]
     **Key files:** list of main files created/modified
     ```

3. **Update README** (if applicable)
   - Add/update sections relevant to the new feature
   - Keep README as comprehensive standalone developer reference
   - No mention of Claude workflow (that's personal tooling)

**Output:** Complete documentation trail; README updated if needed.

---

## File Structure

```
docs/
├── design-plans/
│   └── YYYY-MM-DD-feature-name.md
├── implementation-plans/
│   └── YYYY-MM-DD-feature-name.md
├── changelog.md
└── ...
```

---

## Commands Summary

| Command | Purpose |
|---------|---------|
| `/design feature-name` | Start design phase for a new feature |
| `/plan` | Start planning phase (requires design doc) |
| `/build` | Start build phase (requires implementation plan) |
| `/document` | Start documentation phase (after build complete) |

---

## Task Sizing Guide

**Right-sized task (15-45 min):**
- Coherent unit of work
- Independently verifiable
- Makes a sensible commit

**Example breakdown for a CardGrid component:**

| Task | Commit |
|------|--------|
| Create CardGrid with base structure (tsx, scss, index) | "Add CardGrid component base structure" |
| Add responsive grid layout | "Add CardGrid responsive layout" |
| Add compact and featured variants | "Add CardGrid variants" |
| Register in ContentBuilder + GraphQL fragment | "Integrate CardGrid with ContentBuilder" |
| Create Storybook story | "Add CardGrid Storybook story" |

---

## Handling Deviations

When reality doesn't match the plan:

1. **Don't update the plan doc** — it's a record of original thinking
2. **Note the deviation in Build Log** — what changed and why
3. **Continue with adjusted approach**
4. **Reflect later** — patterns in deviations become insights

---

## Requirements

### Must Have
- [x] Four distinct phases with explicit commands
- [x] Clear phase/step indicators in every response
- [x] Design document template
- [x] Implementation plan template
- [x] Changelog format
- [x] Task sizing guidelines
- [x] Deviation handling process

### Nice to Have
- [ ] Templates as actual files in `docs/templates/`
- [ ] Example completed design doc
- [ ] Example completed implementation plan

### Out of Scope
- Sub-agents or parallel task execution
- Automated phase transitions
- Integration with external tools

---

## Acceptance Criteria

- [ ] `/design` command initiates design phase with context gathering
- [ ] `/plan` command initiates planning phase with codebase verification
- [ ] `/build` command initiates build phase with task-by-task execution
- [ ] `/document` command initiates documentation phase
- [ ] Each phase announces current step clearly
- [ ] Phase transitions require explicit user confirmation
- [ ] Design docs are created at correct path
- [ ] Implementation plans are created at correct path
- [ ] Changelog is appended after completion
- [ ] Deviations are recorded in Build Log, not by updating plan

---

## Files to Create

```
docs/
├── design-plans/          # (directory, if not exists)
├── implementation-plans/  # (directory, create)
├── changelog.md           # (create)
└── templates/
    ├── design-doc.md      # (exists, may need updates)
    └── implementation-plan.md  # (create)
```

---

## Next Steps

1. Review this design document
2. Run `/plan` to create implementation tasks
3. Run `/build` to implement the workflow
4. Run `/document` to finalize

---

## Build Log

| Date | Task | Files | Notes |
|------|------|-------|-------|
| 2026-01-15 | Create directory structure | `.claude/commands/`, `docs/implementation-plans/`, `docs/templates/` | Added .gitkeep to implementation-plans |
| 2026-01-15 | Create design doc template | `docs/templates/design-doc.md` | |
| 2026-01-15 | Create implementation plan template | `docs/templates/implementation-plan.md` | |
| 2026-01-15 | Create /design command | `.claude/commands/design.md` | Phase 1 workflow |
| 2026-01-15 | Create /plan command | `.claude/commands/plan.md` | Phase 2 workflow |
| 2026-01-15 | Create /build command | `.claude/commands/build.md` | Phase 3 workflow |
| 2026-01-15 | Create /document command | `.claude/commands/document.md` | Phase 4 workflow |
| 2026-01-15 | Create changelog | `docs/changelog.md` | Includes this feature as first entry |

---

## Completion

**Completed:** 2026-01-15
**Final Status:** Complete

**Summary:** Implemented a four-phase development workflow with slash commands (`/design`, `/plan`, `/build`, `/document`). Created supporting templates for design docs and implementation plans, plus a changelog for tracking completed features.

**Deviations from Plan:** The workflow bootstrapped itself - no formal implementation plan document was created since this was the first use of the system. Future features will follow the full cycle.
