# /design $ARGUMENTS

You are starting **Phase 1: Design** for the feature: **$ARGUMENTS**

---

## Your Role

Transform a raw idea into a structured, validated design document. You propose, the user approves. Do not auto-advance through steps.

---

## Announce Your Location

Every response must begin with:
```
**Phase 1: Design** | Step [N]: [Step Name]
```

---

## Steps

Work through these steps one at a time. Wait for user input before proceeding to the next step.

### Step 1: Context Gathering

Ask the user:
1. What are we building? (Get specifics)
2. What constraints exist? (Tech stack, timeline, dependencies)
3. What decisions have already been made?
4. Any reference URLs, docs, or examples to review?

Summarize what you learned before moving on.

### Step 2: Clarification

- Identify ambiguous terms and ask for definitions
- Define scope precisely (e.g., "users" → website visitors? form submitters? admins?)
- Confirm what's in scope vs. out of scope
- List assumptions and verify them

### Step 3: Brainstorming (if needed)

If there are multiple valid approaches:
- Present 2-3 architectural options
- Outline trade-offs for each (complexity, performance, maintainability)
- Ask user to select a direction

Skip this step if the approach is obvious or already decided.

### Step 4: Incremental Validation

- Present small sections of the proposed approach
- Get feedback on each section
- Iterate until the approach is solid
- Confirm requirements and acceptance criteria

### Step 5: Write Design Document

Create the design document at:
```
docs/design-plans/YYYY-MM-DD-feature-name.md
```

Use the template at `docs/templates/design-doc.md` as your guide.

Include:
- Overview (what and why)
- Requirements (must have, nice to have, out of scope)
- Design decisions with rationale
- Acceptance criteria (testable)
- Files to create/modify

---

## Phase Complete

When the design document is written, announce:

```
**Phase 1: Design** | Complete

Design document created at: docs/design-plans/YYYY-MM-DD-feature-name.md

Next: End this session and start a new Claude Code session.
Run `/plan` to begin Phase 2: Planning.
```

---

## Rules

1. **One step at a time** - Do not combine steps or rush ahead
2. **Summarize before moving** - Recap decisions at the end of each step
3. **User drives** - Wait for explicit approval to proceed
4. **No implementation** - This phase is design only, no code writing
5. **Stay local** - All files created must stay within the current project directory. No system-level or global configuration changes.
6. **No git operations** - Never run git commands (commit, add, push, etc.). User handles all version control manually.
