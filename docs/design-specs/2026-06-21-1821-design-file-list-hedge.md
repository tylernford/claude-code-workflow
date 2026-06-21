# Fix the Design-Spec File-List Hedge

**Created:** 2026-06-21 **Implementation Plan:** [link to implementation plan]

---

## Overview

**What:** Make `/design`'s "Files to Create/Modify" output internally consistent and
explicitly non-binding, and reconcile Rule 4 so naming files (scope) is distinguished from
writing code (implementation). Keep the file list — do not remove it.

**Why:** A review flagged that the design spec reaches into implementation altitude: the
SKILL.md prose (`design/SKILL.md:100`) ends Step 5's "Include" list with a bare
`Files to create/modify`, while the template (`templates/design-spec.md:55-60`) hedges the
same section as "Suggested Files to Create/Modify." Prose and template contradict each
other, and the section nominally trips the skill's own Rule 4 ("No implementation").

The review also claimed the file list is "destined to be discarded" because `/plan` Step 2
re-verifies the codebase. **That half of the premise is empirically false.** Comparing 16
design→plan→build trios across two repos (this workflow repo and the firestarter
application codebase) showed the design file list is a near-verbatim, reused baseline, not
a discarded one:

- **96%** accurate in this repo, **94%** in firestarter.
- **Zero** files the design listed were ever dropped by `/plan` — in either repo.
- Divergences were only _additions_ (lock files, auto-fixed sources, generated outputs)
  and **3 path/extension fixes** (e.g. `.ts`→`.mjs` forced by a tool constraint).
- Time gap between design and plan did not degrade accuracy (an 8-day-gap pair was as
  accurate as same-day pairs).

Notably, the 3 divergences were exactly the "how" details the decoupling principle worries
about — and `/plan` Step 2 caught every one. The list being occasionally wrong cost
nothing, because the architecture already self-corrects downstream.

So the real defect is narrow: an internal prose/template contradiction plus a
self-contradictory Rule 4 — not a useless or stale artifact. This change fixes the
contradiction while preserving a proven-useful baseline.

**Type:** Process

---

## Requirements

### Must Have

- [ ] `/design` SKILL.md and its template use one consistent, hedged framing for the file
      list ("Suggested Files…").
- [ ] Both SKILL.md and the template state the list is non-binding and that `/plan`
      re-verifies it and owns the final paths.
- [ ] Rule 4 distinguishes scope (listing the likely surface area — allowed) from
      implementation (writing code — not allowed), removing the contradiction with Step 5.
- [ ] The file list is retained in the design output (no removal, no scope-pointer
      substitution).

### Nice to Have

- [ ] A one-line rationale near the section (or in the spec history) noting the list is a
      starting suggestion that `/plan` resolves, so future reviewers don't re-flag it.

### Out of Scope

- Replacing the file list with a higher-altitude "scope / surface area" pointer.
- Removing the file list entirely.
- Any change to `/plan` — its Step 2 codebase verification already re-derives and owns
  final paths, which is the behavior this change leans on.
- Any change to `/build` or `/document`.

---

## Design Decisions

### What to do with the "Files to Create/Modify" output

**Options considered:**

1. Replace file paths with a higher-altitude "Affected Areas / Surface Area" pointer
   (subsystems, not paths) — attractive if the list went stale.
2. Remove the section entirely for strict alignment with the decoupling specs.
3. Keep the file list; fix the prose/template contradiction and mark it explicitly
   non-binding.

**Decision:** Option 3. The empirical evidence (16 pairs, two repos, 94–96% accuracy, zero
drops, no time-gap decay) shows the list is reused, not discarded. Options 1 and 2 were
predicated on the list going stale; since it does not, they would discard a measurably
useful artifact to satisfy a principle the data does not support. Honor the evidence: keep
the precise, accurate paths and fix the actual defect (the contradiction).

### How to reconcile Rule 4 ("No implementation")

**Options considered:**

1. Leave Rule 4 as-is and accept it contradicts Step 5.
2. Clarify Rule 4 to distinguish scope from code.

**Decision:** Option 2. "No implementation" should mean "no writing code," not "no naming
files." Listing the likely surface area is scope — design's job — and is what `/plan`
consumes as a baseline. Clarifying this resolves the self-contradiction the review
correctly identified, without weakening the no-code-writing constraint.

### Where the non-binding note lives

**Options considered:**

1. Template only (keeps SKILL.md lean).
2. Both SKILL.md and the template.

**Decision:** Option 2. The template is what survives into each generated spec, but
SKILL.md is what the agent reads while writing the spec. Putting the note in both keeps
the guidance present at authoring time and in the artifact.

---

## Acceptance Criteria

- [ ] `design/SKILL.md` no longer contains the bare phrase "Files to create/modify"; it
      uses hedged "Suggested Files…" wording consistent with the template.
- [ ] Both `design/SKILL.md` and `design/templates/design-spec.md` state the list is
      non-binding and that `/plan` re-verifies and owns final paths.
- [ ] Rule 4 wording distinguishes scope (listing files — allowed) from implementation
      (writing code — not allowed), with no remaining contradiction against Step 5.
- [ ] No file paths or the file-list section are removed from the design output.
- [ ] `/plan`, `/build`, and `/document` are unchanged.

---

## Suggested Files to Create/Modify

> Non-binding starting point. `/plan` re-verifies these against the codebase in its Step 2
> and owns the final paths.

```
.claude/skills/design/SKILL.md                    # Hedge Step 5 wording; clarify Rule 4; add non-binding note
.claude/skills/design/templates/design-spec.md    # Add non-binding note to the Suggested Files section
```

Note: the skill is also synced to `~/.claude/skills/design/` via `scripts/sync-skills.sh`;
the repo copy under `.claude/skills/` is the source of truth.
