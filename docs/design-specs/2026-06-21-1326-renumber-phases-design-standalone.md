# Renumber Phases — Design Standalone, Implementation 1–3

**Created:** 2026-06-21 **Implementation Plan:**
docs/implementation-plans/2026-06-21-1437-renumber-phases.md

---

## Overview

**What:** Restructure the workflow's phase model so `/design` is a standalone upstream
phase (unnumbered) and the implementation workflow is a clean three-phase arc — **Phase 1:
Plan → Phase 2: Build → Phase 3: Document**. Remove the "Implementation Session" framing
entirely and unify every skill's announce/handoff strings and CLAUDE.md's table on this
model.

**Why:** Two defects, one root cause. `plan/SKILL.md:8-10` opens with "You are starting an
**Implementation Session** — Phase 1: Plan / This session will take you through Plan →
Build → Document." This (a) contradicts the Core Principle _"One phase per session"_ by
priming the user to roll three phases into one session — the exact drift the workflow
exists to prevent — and (b) collides with plan's own announce blocks, which call it "Phase
2." The deeper issue: the repo has already shipped two changes ("Decouple Design from
Implementation," 2026-01-16; "Decouple /design from Other Phases," 2026-02-18) that freeze
the design spec and bar `/build` and `/document` from touching it. The architecture
already treats **design as a separate upstream artifact and Plan/Build/Document as
"implementation."** But the presentation layer — announce blocks and CLAUDE.md's flat 1–4
table — was never updated to match. This change aligns presentation with the architecture
the repo committed to, and kills the drift-priming "Session" language as a side effect.

**Type:** Refactor

---

## Requirements

### Must Have

- [ ] The "Implementation Session" concept is removed from all skill files (no skill tells
      the user one session spans multiple phases)
- [ ] `/design` announces as an unnumbered standalone phase (`**Design**`, not
      `**Phase N: Design**`)
- [ ] The implementation workflow is numbered consistently: Plan = Phase 1, Build = Phase
      2, Document = Phase 3
- [ ] `/learn-by-doing` (alternative to `/build`) announces as Phase 2, matching `/build`
- [ ] Every handoff line points to the correct next-phase number (design→"Phase 1: Plan",
      plan→"Phase 2: Build", build→"Phase 3: Document", learn-by-doing→"Phase 3:
      Document")
- [ ] No skill file contains an internally contradictory phase number (the plan "Phase
      1"/"Phase 2" split is resolved)
- [ ] CLAUDE.md's Skills table reflects the two-track structure (Design standalone;
      Implementation 1/2/3)

### Nice to Have

- [ ] A one-line note in CLAUDE.md making the Design-vs-Implementation distinction
      explicit for future readers

### Out of Scope

- Any change to phase _behavior_, steps, rules, or the artifacts produced — this is a
  renumbering/relabeling pass only
- Changes to the design-spec or implementation-plan templates
- The frozen-design-spec lifecycle (already shipped 2026-02-18)
- Renaming the `/design`, `/plan`, `/build`, `/document` commands themselves

---

## Design Decisions

### Phase model: linear 1–4 vs. Design-standalone + Implementation 1–3

**Options considered:**

1. **Model 1 — flat linear pipeline (Design 1, Plan 2, Build 3, Document 4).** Lowest
   churn: fix only `plan:8` ("Phase 2") and scrub the session sentence. But it tells a
   "single 1–4 pipeline" story that the shipped decoupling already contradicts — design is
   no longer just "step one of building"; build/document don't even read its output.
2. **Model 2 — Design standalone + Implementation 1–3.** Design is the upstream "what &
   why" producing a frozen spec; Plan/Build/Document are the implementation arc. Matches
   the architecture two shipped changes already established. Higher churn (renumber Build
   3→2, Document 4→3, rework CLAUDE.md table).

**Decision:** Model 2. The repo has twice shipped "decouple design from implementation";
the changelog's own language frames design and implementation as distinct. Numbering them
as one flat 1–4 sequence undersells a distinction the codebase already enforces. Model 2
makes the presentation honest and is the coherent end-state; Model 1 is a band-aid that
leaves the dissonance in place.

### How `/design` is labeled

**Options considered:**

1. **Unnumbered `**Design**`.** Honest expression of "design is decoupled, not phase-one
   of a pipeline." No numeric anchor.
2. **`**Phase 0: Design**`.** Keeps a numeric anchor for "where am I," but 0-indexing is
   awkward and reintroduces the linear-pipeline implication Model 2 is shedding.

**Decision:** Option 1, unnumbered `**Design**`. The whole point of Model 2 is that design
is not part of the implementation count. A number — even 0 — fights that. The opener and
CLAUDE.md provide the "where am I" context instead.

### Opener and announce strings

Implementation phases use a **grouped opener** (names the track once) and a **terse
announce line** (repeats every response). Openers:

- `/plan`: `You are starting **Implementation · Phase 1: Plan**.`
- `/build`: `You are starting **Implementation · Phase 2: Build**.`
- `/document`: `You are starting **Implementation · Phase 3: Document**.`
- `/learn-by-doing`: `You are starting **Implementation · Phase 2: Learn by Doing**.`
- `/design` (standalone, not implementation):
  `You are starting the **Design** for: **$ARGUMENTS**`

---

## Acceptance Criteria

- [ ] `grep -rn "Implementation Session" .claude/skills/` returns no matches
- [ ] `/design` opener, announce, and complete blocks read `**Design**` with no phase
      number; its handoff points to "Phase 1: Plan"
- [ ] `/plan` opener reads "**Implementation · Phase 1: Plan**" with no "Session" / "Plan
      → Build → Document" sentence; announce and complete blocks read the terse "**Phase
      1: Plan**"; handoff points to "Phase 2: Build"
- [ ] `/build` opener reads "**Implementation · Phase 2: Build**"; announce and complete
      read terse "**Phase 2: Build**"; handoff points to "Phase 3: Document"
- [ ] `/document` opener reads "**Implementation · Phase 3: Document**"; announce and
      complete read terse "**Phase 3: Document**"
- [ ] `/learn-by-doing` opener reads "**Implementation · Phase 2: Learn by Doing**";
      announce and complete read terse "**Phase 2: Learn by Doing**"; handoff points to
      "Phase 3: Document"
- [ ] Within any single skill file, the phase number is identical in the opener, announce
      block, and complete block (no internal contradiction)
- [ ] CLAUDE.md's Skills table shows `/design` as standalone and `/plan` `/build`
      `/learn-by-doing` `/document` under Implementation 1/2/2(alt)/3
- [ ] "One phase per session" Core Principle remains intact and is not contradicted by any
      skill's framing

---

## Suggested Files to Create/Modify

```
.claude/skills/design/SKILL.md          # opener→"Design" (unnumbered), announce :35, complete :109, handoff :118→"Phase 1: Plan"
.claude/skills/plan/SKILL.md            # opener :8-10 remove Session framing→"Phase 1: Plan", announce :32, complete :116, handoff :123→"Phase 2: Build"
.claude/skills/build/SKILL.md           # opener :8, announce :30, complete :84 →"Phase 2"; handoff :93→"Phase 3: Document"
.claude/skills/document/SKILL.md        # opener :8, announce :33, complete :126 →"Phase 3"
.claude/skills/learn-by-doing/SKILL.md  # opener :26, announce :52, complete :284 →"Phase 2"; handoff :294→"Phase 3: Document"
CLAUDE.md                               # Skills table :21-27 → two-track (Design standalone; Implementation 1/2/3)
```

> Note: `.claude/skills/` in this repo and `~/.claude/skills/` resolve to the same files —
> edit the repo paths above.
