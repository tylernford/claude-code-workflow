# Implementation Plan: Renumber Phases — Design-standalone + Implementation 1–3

**Created:** 2026-06-21 **Type:** Refactor **Overview:** Restructure the workflow's phase
model so `/design` is a standalone upstream phase (unnumbered) and the implementation
workflow is a clean three-phase arc — **Phase 1: Plan → Phase 2: Build → Phase 3:
Document**. Remove the "Implementation Session" framing entirely and unify every skill's
announce/handoff strings and CLAUDE.md's table on this model. **Design Spec:**
docs/design-specs/2026-06-21-1326-renumber-phases-design-standalone.md

---

## Summary

A pure relabeling/renumbering pass across five skill files and `CLAUDE.md`. No phase
behavior, steps, rules, or produced artifacts change. The work resolves two defects with
one root cause: the `plan` skill's "Implementation Session" opener primes the user to roll
three phases into one session (contradicting the "One phase per session" principle), and
its opener ("Phase 1") collides with its own announce/complete blocks ("Phase 2"). The fix
aligns presentation with the already-shipped architecture: design is a decoupled upstream
artifact; Plan/Build/Document are the implementation arc.

---

## Codebase Verification

_Confirmed against the codebase on 2026-06-21 (spec line references all still accurate)._

- [x] `plan/SKILL.md:8` opens with "**Implementation Session** — Phase 1: Plan" plus a
      "Plan → Build → Document" sentence at `:10` — Verified: yes
- [x] `plan/SKILL.md` announce `:32` and complete `:116` say "Phase 2: Plan" (internal
      contradiction with the opener) — Verified: yes
- [x] `design/SKILL.md` uses "Phase 1: Design" at `:8`, `:35`, `:109`; handoff `:117-118`
      contains "Implementation Session (Plan → Build → Document)" — Verified: yes
- [x] `build/SKILL.md` uses "Phase 3: Build" at `:8`, `:30`, `:84`; handoff `:93` → "Phase
      4: Document" — Verified: yes
- [x] `document/SKILL.md` uses "Phase 4: Document" at `:8`, `:33`, `:126` — Verified: yes
- [x] `learn-by-doing/SKILL.md` uses "Phase 3: Learn by Doing" at `:26`, `:52`, `:284`;
      handoff `:294` → "Phase 4: Document" — Verified: yes
- [x] `CLAUDE.md:21-27` Skills table is a flat 1/2/3/3/4 list — Verified: yes
- [x] `grep -rn "Implementation Session" .claude/skills/` returns exactly 2 hits (plan
      `:8`, design `:118`) — Verified: yes

**Patterns to leverage:**

- Each skill follows the same three-block shape (opener → "Announce Your Location" block →
  "Phase Complete" block), so edits are positionally consistent across files.
- The "One phase per session" Core Principle already exists verbatim in every skill's
  Rules section and in `CLAUDE.md` — it must remain untouched.

**Discrepancies found:**

- None. The design spec's suggested files and line numbers match the current codebase
  exactly.

**Note beyond a pure number swap:** the spec requires **grouped openers** for the
implementation phases (`You are starting **Implementation · Phase N: X**.`), which is a
wording change, not just a number change. Current openers are plain
(`You are starting **Phase N: X**`).

---

## Tasks

### Task 1: Renumber all 5 skill files

**Description:** Apply the new phase labels, grouped openers, terse announce lines, and
corrected handoffs across all five skill files. This is the bulk of the change and removes
both "Implementation Session" occurrences. **Files:**

- `.claude/skills/design/SKILL.md` - modify
- `.claude/skills/plan/SKILL.md` - modify
- `.claude/skills/build/SKILL.md` - modify
- `.claude/skills/document/SKILL.md` - modify
- `.claude/skills/learn-by-doing/SKILL.md` - modify

**Per-file edits:**

**`design/SKILL.md`** — unnumbered standalone:

- `:8` opener → `You are starting the **Design** for: **$ARGUMENTS**`
- `:35` announce → `**Design** | Step [N]: [Step Name]`
- `:109` complete → `**Design** | Complete`
- `:117-118` handoff → remove "Implementation Session" framing; point to Phase 1: Plan.
  Note this handoff spans **two lines** (`:117-118`) — rewrite both, e.g.
  `run `/plan` to begin Implementation — Phase 1: Plan.`

**`plan/SKILL.md`** — Phase 1, Session framing removed:

- `:8-10` opener → `You are starting **Implementation · Phase 1: Plan**.` (delete the
  "This session will take you through Plan → Build → Document." line)
- `:32` announce → `**Phase 1: Plan** | Step [N]: [Step Name]`
- `:116` complete → `**Phase 1: Plan** | Complete`
- `:123` handoff → `Run `/build` to begin Phase 2: Build.`

**`build/SKILL.md`** — Phase 2:

- `:8` opener → `You are starting **Implementation · Phase 2: Build**.`
- `:30` announce → `**Phase 2: Build** | Task [N]/[Total]: [Task Name]`
- `:84` complete → `**Phase 2: Build** | Complete`
- `:93` handoff → `Run `/document` to begin Phase 3: Document.`

**`document/SKILL.md`** — Phase 3:

- `:8` opener → `You are starting **Implementation · Phase 3: Document**.`
- `:33` announce → `**Phase 3: Document** | Step [N]: [Step Name]`
- `:126` complete → `**Phase 3: Document** | Complete`

**`learn-by-doing/SKILL.md`** — Phase 2 (alternative to Build):

- `:26` opener → `You are starting **Implementation · Phase 2: Learn by Doing**.`
- `:52` announce → `**Phase 2: Learn by Doing** | Task [N]/[Total]: [Task Name]`
- `:284` complete → `**Phase 2: Learn by Doing** | Complete`
- `:294` handoff → `Run `/document` to begin Phase 3: Document.`

**Done when:**

- `grep -rn "Implementation Session" .claude/skills/` returns no matches
- `grep -rn "Phase [0-9]: Design" .claude/skills/design/SKILL.md` returns no matches
- Within each skill file the opener, announce, and complete blocks carry one identical
  phase number (design carries none)
- Handoffs read: design → "Phase 1: Plan", plan → "Phase 2: Build", build → "Phase 3:
  Document", learn-by-doing → "Phase 3: Document"

**Commit:** "refactor: renumber workflow phases to Design-standalone + Implementation 1-3"

---

### Task 2: Update CLAUDE.md Skills table to two-track model

**Description:** Replace the flat 1/2/3/3/4 Skills table with a two-track structure
(Design standalone; Implementation 1/2/2-alt/3) and add the one-line note making the
Design-vs-Implementation distinction explicit (the spec's Nice-to-Have). Also fix the
stale Structure comment at `:9`, which omits `learn-by-doing` from the skills list.
**Files:**

- `CLAUDE.md` - modify (`:19-27`, Skills table)
- `CLAUDE.md` - modify (`:9`, Structure comment)

**Code example:**

```markdown
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
```

The Structure comment fix at `:9`:

```diff
- .claude/skills/            # Skill definitions (design, plan, build, document)
+ .claude/skills/            # Skill definitions (design, plan, build, learn-by-doing, document)
```

**Done when:** the Skills section shows `/design` as standalone and `/plan` `/build`
`/learn-by-doing` `/document` under Implementation 1/2/2 (alt)/3; the explanatory note is
present; the Structure comment at `:9` lists all five skills including `learn-by-doing`;
the "One phase per session" Core Principle below the table is unchanged.

**Commit:** "refactor: restructure CLAUDE.md Skills table to two-track model"

---

## Acceptance Criteria

- [x] `grep -rn "Implementation Session" .claude/skills/` returns no matches
- [x] `/design` opener, announce, and complete blocks read `**Design**` with no phase
      number; its handoff points to "Phase 1: Plan"
- [x] `/plan` opener reads "**Implementation · Phase 1: Plan**" with no "Session" / "Plan
      → Build → Document" sentence; announce and complete read terse "**Phase 1: Plan**";
      handoff points to "Phase 2: Build"
- [x] `/build` opener reads "**Implementation · Phase 2: Build**"; announce and complete
      read terse "**Phase 2: Build**"; handoff points to "Phase 3: Document"
- [x] `/document` opener reads "**Implementation · Phase 3: Document**"; announce and
      complete read terse "**Phase 3: Document**"
- [x] `/learn-by-doing` opener reads "**Implementation · Phase 2: Learn by Doing**";
      announce and complete read terse "**Phase 2: Learn by Doing**"; handoff points to
      "Phase 3: Document"
- [x] Within any single skill file the phase number is identical in the opener, announce
      block, and complete block (no internal contradiction)
- [x] CLAUDE.md's Skills table shows `/design` as standalone and `/plan` `/build`
      `/learn-by-doing` `/document` under Implementation 1/2/2 (alt)/3, with the
      distinction note present
- [x] CLAUDE.md's Structure comment at `:9` lists all five skills, including
      `learn-by-doing`
- [x] "One phase per session" Core Principle remains intact and is not contradicted by any
      skill's framing

---

## Build Log

_Filled in during `/build` phase_

| Date       | Task   | Files                                              | Notes                                                                                                                                                                                                             |
| ---------- | ------ | -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-06-21 | Task 1 | design/plan/build/document/learn-by-doing SKILL.md | Renumbered all 5 skills: design unnumbered standalone; Implementation Plan=1, Build=2, Learn by Doing=2, Document=3. Grouped openers, terse announce/complete, handoffs point to next phase. No deviations.       |
| 2026-06-21 | Task 2 | CLAUDE.md                                          | Replaced flat 1/2/3/3/4 Skills table with two-track model (Design standalone + Implementation 1/2/2-alt/3), added distinction note, fixed stale Structure comment at :9 to include learn-by-doing. No deviations. |

---

## Completion

**Completed:** [Date] **Final Status:** [Complete | Partial | Abandoned]

**Summary:** [Brief description of what was actually built]

**Deviations from Plan:** [Any significant changes from original design]

---

## Notes

- Pure relabeling/renumbering pass — no change to phase behavior, steps, rules, or
  produced artifacts (per the design spec's Out of Scope).
- Scope deviation (deliberate): Task 2 also fixes the stale Structure comment at
  `CLAUDE.md:9` (omits `learn-by-doing`). Outside the spec's `:21-27` window but a
  trivial, same-file accuracy fix made while already editing CLAUDE.md.
- `.claude/skills/` and `~/.claude/skills/` resolve to the same files in this repo;
  editing the repo paths is sufficient.
- Watch the handoff verbs: each handoff names the **next** phase, not the current one —
  easy to off-by-one when editing five files in a row.
