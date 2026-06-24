# Nice-to-Have Carry-Forward Gap

**Date:** 2026-06-24 **Context:** While building the acceptance-criteria carry-forward
ledger (`docs/implementation-plans/2026-06-24-1339-acceptance-criteria-carry-forward.md`),
a question surfaced about whether design-spec Nice-to-Haves survive the transition into
implementation plans. An audit of two unrelated repos confirmed they usually do not.

---

## What Happens

A design spec's `## Requirements` section has three tiers: `### Must Have`,
`### Nice to Have`, `### Out of Scope`. The `/plan` skill reads the spec and produces an
implementation plan. The plan carries forward the spec's **Acceptance Criteria** (now via
the provenance-tagged ledger) — but it has **no mechanism for carrying forward the
Requirements**, and Nice-to-Haves in particular fall through the gap.

A Nice-to-Have that doesn't happen to get promoted into a Must-Have or an acceptance
criterion has no slot to land in and no strike-through to mark its absence. It simply
disappears between the spec and the plan, with no record that it was ever considered.

---

## Evidence

Two repos were audited end-to-end (every design spec paired with its implementation plan),
classifying each Nice-to-Have as **present** (built or listed), **explicitly deferred**
(absent but with a note), or **silently absent** (no trace anywhere in the plan).

**firestarter** — 13 specs, 10 Nice-to-Haves:

- 5 silently absent
- 2 explicitly deferred
- 2 implemented
- 1 passive design choice ("can add later")

**obsidian-mcp** — 19 specs, ~16 Nice-to-Haves:

- ~7 silently absent
- 1 explicitly deferred
- ~7 carried / implemented

Representative silent drops (the Nice-to-Have text is verbatim from the spec; none of
these appear anywhere in the matching plan):

| Repo         | Spec                    | Silently-dropped Nice-to-Have                                |
| ------------ | ----------------------- | ------------------------------------------------------------ |
| firestarter  | storybook-token-display | "Line height viewer paired with corresponding type step"     |
| firestarter  | terrazzo-plugin-testing | "Edge case coverage (malformed tokens, missing modes)"       |
| obsidian-mcp | testing-infrastructure  | "CI via GitHub Actions" and "E2E with wdio-obsidian-service" |
| obsidian-mcp | obsidian-mcp-server     | "configurable host/port" and "document-map response support" |

**Secondary pattern:** testing, infrastructure, and architecture Nice-to-Haves are the
most vulnerable to silent dropping. Feature-flavored Nice-to-Haves (a config toggle, an
error-message detail) tend to survive — because they read like Must-Haves and naturally
get picked up as acceptance criteria.

---

## Why It Happens

1. **The carry-forward ledger covers Acceptance Criteria, not Requirements.** The recently
   added provenance ledger forces every design-spec _acceptance criterion_ to appear in
   the plan (tagged, struck if deferred/dropped). There is no equivalent for the
   Requirements tiers. Nice-to-Haves are an input to planning, not a tracked output of it.

2. **Nice-to-Haves are the optional tier nobody is forced to account for.** Must-Haves
   almost always become acceptance criteria, so they survive incidentally. Out-of-Scope
   items are explicit non-goals. Nice-to-Haves sit in between — desirable but droppable —
   which is exactly the tier where a silent drop is indistinguishable from a deliberate
   one.

3. **The drop is invisible by construction.** With no slot in the plan and no strike-
   through convention for requirements, an intentionally-deferred Nice-to-Have and an
   accidentally-forgotten one produce the identical artifact: nothing. There is no way to
   tell them apart after the fact.

---

## This Is Distinct From the Acceptance-Criteria Chain

The acceptance-criteria carry-forward (built 2026-06-24) is working as designed.
Nice-to-Haves are _not_ acceptance criteria, so the AC chain correctly excludes them —
this was confirmed against the study-partner spec, whose Nice-to-Haves never appeared in
its own Acceptance Criteria section and so were faithfully not carried.

The gap is one level up: the **Requirements chain has no carry-forward at all.** Closing
the AC chain made this adjacent gap visible by contrast — the principle "an omission must
read as a struck line, never an absence" now holds for acceptance criteria but not for
requirements.

---

## Possible Improvements

### A: Extend the provenance ledger to the Requirements tiers

Apply the same struck-line discipline to Nice-to-Haves. When `/plan` builds the plan,
every spec Nice-to-Have must be accounted for: promoted (became a Must-Have / acceptance
criterion), carried (planned this phase), or struck with a reason
(`~~…~~ (deferred → later)` / `~~…~~ (dropped — reason)`). A Nice-to-Have that appears
nowhere becomes a plan defect, exactly as a missing acceptance criterion does today.

### B: Add a "Deferred from spec" section to the plan template

Lighter-weight than a full ledger: a dedicated section in the implementation plan that
lists any spec Nice-to-Haves not included this phase, each with a one-line rationale.
Makes the drop visible and intentional without changing how requirements are tracked
elsewhere.

### C: Add a Nice-to-Have coverage check to Plan Validation

Mirror the acceptance-criteria coverage check already in `/plan` Step 5: before
finalizing, confirm every spec Nice-to-Have is either carried or explicitly accounted for.
Cheapest option, but it relies on the validation step being run rather than enforcing
structure in the artifact.

---

## Relationship to Other Issues

This is a planning-phase gap (the plan fails to account for an input tier), complementary
to the build-phase verification gaps in `2026-03-05-end-to-end-path-verification-gap.md`
and `2026-02-20-codebase-verification-gap.md`. Where those concern _how a feature is
invoked and verified_, this concerns _which intended scope reaches the plan in the first
place_.
