# Implementation Plan: Fix the Design-Spec File-List Hedge

**Created:** 2026-06-21 **Type:** Process **Overview:** Make `/design`'s "Files to
Create/Modify" output internally consistent and explicitly non-binding, and reconcile Rule
4 so naming files (scope) is distinguished from writing code (implementation). Keep the
file list — do not remove it. **Design Spec:**
docs/design-specs/2026-06-21-1821-design-file-list-hedge.md

---

## Summary

The `/design` skill contradicts itself: SKILL.md Step 5 ends its "Include" list with a
bare `Files to create/modify`, while the template heads the same section "Suggested Files
to Create/Modify." The section also nominally trips the skill's own Rule 4 ("No
implementation"). This change makes the wording consistent and hedged, marks the list as a
non-binding starting point that `/plan` re-verifies and owns, and clarifies Rule 4 to
distinguish scope (listing files — allowed) from implementation (writing code — not
allowed). The file list is retained; `/plan`, `/build`, and `/document` are untouched.

---

## Codebase Verification

_Confirm assumptions from design spec match actual codebase_

- [x] `design/SKILL.md:100` ends Step 5's "Include" list with bare
      `Files to create/modify` - Verified: yes (line 100)
- [x] Rule 4 reads "No implementation - This phase is design only, no code writing" -
      Verified: yes (line 128)
- [x] Template section already headed "Suggested Files to Create/Modify" - Verified: yes
      (line 55)
- [x] Template has no non-binding note yet - Verified: yes (lines 55–60 are just heading +
      code block)
- [x] Skill synced to `~/.claude/skills/` via `scripts/sync-skills.sh` - Verified: yes
      (`design` is in `WORKFLOW_SKILLS`)

**Patterns to leverage:**

- The design spec's own "Suggested Files to Create/Modify" blockquote
  (`docs/design-specs/2026-06-21-1821-design-file-list-hedge.md:128-131`) is the exact
  non-binding framing to reuse verbatim.

**Discrepancies found:**

- None. The change is exactly the two-file scope the spec describes.

---

## Tasks

### Task 1: Reconcile `design/SKILL.md` — hedge Step 5, add non-binding note, clarify Rule 4

**Description:** Remove the internal contradiction in the `/design` skill prose. Hedge the
Step 5 "Include" entry, add a note that the list is non-binding and that `/plan` owns
final paths, and clarify Rule 4 to allow scope (naming files) while still forbidding code
writing. **Files:**

- `.claude/skills/design/SKILL.md` - modify

**Code example:**

```
# Step 5 "Include" list (line 100) — replace bare entry:
- Suggested Files to Create/Modify (see template)

# Step 5 — add non-binding note after the "Include" list:
The "Suggested Files to Create/Modify" list is a non-binding starting point. `/plan`
re-verifies these against the codebase (its Step 2) and owns the final paths.

# Rule 4 (line 128) — clarify scope vs. code:
4. **No implementation** - Design names the likely files (scope) but writes no code.
   Listing the surface area is allowed; writing the implementation is not.
```

**Done when:** SKILL.md contains no bare "Files to create/modify" phrase; Step 5 carries a
non-binding note referencing `/plan`; Rule 4 distinguishes scope (allowed) from
code-writing (not allowed) with no contradiction against Step 5. **Commit:** "fix:
reconcile /design file-list wording and Rule 4"

---

### Task 2: Add non-binding note to `design-spec.md` template

**Description:** Add a blockquote note under the template's "Suggested Files to
Create/Modify" heading so every generated spec carries the non-binding framing. The code
block / file list is retained unchanged. **Files:**

- `.claude/skills/design/templates/design-spec.md` - modify

**Code example:**

````
## Suggested Files to Create/Modify

> Non-binding starting point. `/plan` re-verifies these against the codebase in its
> Step 2 and owns the final paths.

```​path/to/file1.ext  # description ...```
````

**Done when:** The template's Suggested Files section carries the non-binding note above
the code block; the file list/code block itself is retained unchanged. **Commit:** "fix:
note /design file list is non-binding in template"

---

## Acceptance Criteria

- [x] `design/SKILL.md` no longer contains the bare phrase "Files to create/modify"; it
      uses hedged "Suggested Files…" wording consistent with the template.
- [x] Both `design/SKILL.md` and `design/templates/design-spec.md` state the list is
      non-binding and that `/plan` re-verifies and owns final paths.
- [x] Rule 4 wording distinguishes scope (listing files — allowed) from implementation
      (writing code — not allowed), with no remaining contradiction against Step 5.
- [x] No file paths or the file-list section are removed from the design output.
- [x] `/plan`, `/build`, and `/document` are unchanged.

---

## Build Log

_Filled in during `/build` phase_

| Date       | Task   | Files                                          | Notes                                                                                                                                                                                  |
| ---------- | ------ | ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-06-21 | Task 1 | .claude/skills/design/SKILL.md                 | Hedged Step 5 Include entry to "Suggested Files to Create/Modify (see template)", added non-binding note referencing `/plan`, clarified Rule 4 (scope vs. code). Matches plan exactly. |
| 2026-06-21 | Task 2 | .claude/skills/design/templates/design-spec.md | Added non-binding blockquote above the Suggested Files code block; code block retained unchanged. Matches plan exactly.                                                                |

---

## Completion

**Completed:** 2026-06-21 **Final Status:** Complete

**Summary:** Removed the internal contradiction in the `/design` skill's file-list output.
`SKILL.md` Step 5 now hedges its "Include" entry to "Suggested Files to Create/Modify (see
template)" and carries a note that the list is a non-binding starting point which `/plan`
re-verifies and owns. Rule 4 now distinguishes scope (naming the likely files — allowed)
from implementation (writing code — not allowed), removing the apparent conflict with
Step 5. The `design-spec.md` template gained a matching non-binding blockquote above its
"Suggested Files to Create/Modify" code block. The file list is retained throughout; no
paths or sections were removed. `/plan`, `/build`, and `/document` are untouched.

**Deviations from Plan:** None. Both tasks were implemented exactly as planned (per Build
Log).

---

## Notes

- After `/build`, the user must run `scripts/sync-skills.sh` to propagate the updated
  `design` skill to `~/.claude/skills/`. The repo copy under `.claude/skills/` is the
  source of truth; the sync is a manual user step (out of scope for the build tasks).
