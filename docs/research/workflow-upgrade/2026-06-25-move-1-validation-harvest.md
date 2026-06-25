# Move 1 Validation Harvest

**Status:** ✅ RUN COMPLETE — observations below.

**Run against:** `docs/research/workflow-upgrade/2026-06-25-move-1-validation-plan.md`
**Run date:** 2026-06-25 **Branch:** `feat/build-phase-move-1-harvest` **Skills synced
before run:** yes (`scripts/sync-skills.sh`)

**Raw signal:** `docs/research/build-output.md`, `docs/research/document-output.md`
(session captures), and the commit bodies of `d80af30`, `71d3f2e`, `317e061` on the
harvest branch.

---

## The four observations

### 1. Batch-review feel — real evaluation or rubber-stamp?

**Structurally a real evaluation — but under-stressed by a trivial artifact.** The
end-of-batch review led with the Task 1 deviation (not the clean tasks), produced a
genuine verified-vs-just-compiled table, separated the `(manual)` prose check from the
green, and explicitly surfaced the one thing it could not verify (Task 2 prose clarity),
then **asked for a human verdict** instead of self-passing. The surrogation tell ("did it
pass?" replacing "is it right?") did **not** fire.

**Caveat:** the diff was three one-file commits of throwaway code. A real review's
pressure comes from a large, interdependent diff where "all green" is tempting. This run
shows the _shape_ is right; it does not prove the shape holds under load.

### 2. Manual-rate

Across the 3 tasks there were ~4 `done_when` items: **2 true-executable** (Task 1
re-resolved real-file check; Task 3 `count == 3`), **1 shallow proxy** (Task 2 grep →
labeled "compiles, behavior unverified"), **1 manual** (Task 2 prose clarity). Manual-rate
≈ 25%, shallow ≈ 25%.

The `(manual)`-first / verified-vs-just-compiled surfacing **worked**: neither the manual
item nor the shallow proxy was folded into the green. The manual check was held for the
user and confirmed separately ("read cleanly"). This is the behavior the design wanted.

### 3. `done_when` resolution behavior

**Resolution worked honestly on this run — caught the drift, did not lift verbatim, did
not tailor itself an easier check.** Task 1's candidate hardcoded an absent `README.md`;
build re-resolved it to the real plan file and asserted integer output + exit 0. Task 3's
candidate was already sound and resolved cleanly. No evidence of the Decision 1 compromise
(single agent dodging into a trivially-passing command) on this run.

**Caveat — the test telegraphed the answer.** The plan's own Notes warned that the
candidates were intentionally imperfect, so the agent knew to re-resolve. Real-plan drift
is subtler and unannounced. This run confirms the _mechanism_ exists and fires when
prompted; it does **not** establish that a single agent reliably catches _un-flagged_
drift. That reliability question is exactly what Move 1.5's honesty-gate / orchestrator is
meant to close, and this run does not retire it.

### 4. Round-cap pressure

**No signal — the cap was never approached.** Every check passed on the first attempt, so
the three-attempt cap and the escalate-on-3rd-failure path were never exercised. The
validation plan contained no deliberately-failing task. **Gap:** cap/loop behavior under
real failure remains unobserved.

---

## §1 escalation-trigger tuning

**No change made — and that conclusion is itself under-evidenced.** The run interrupted
exactly once, correctly: it presented the `(manual)` prose check for a human verdict (an
expected hand-off, not a spurious stop). It did **not** stop on anything it should have
plowed through, and it did **not** plow through anything it should have surfaced. So the
(a)/(b)/(c) triggers in `build/SKILL.md` look right.

**But** the triggers were never stress-tested: nothing failed (trigger a), nothing was
genuinely ambiguous (trigger b), and the only irreversible-ish action (committing) was
in-scope (trigger c). Tuning from this run would be tuning from absence.
**Recommendation:** leave the triggers as written; schedule a second validation that
includes (i) a task whose check fails ≥3 times to exercise the cap + escalation, and (ii)
a task with genuine plan ambiguity, before considering the triggers validated.

---

## Net assessment

The redesigned single-agent `/build` did everything Move 1 asked on a clean run:
approve-by-exception, build-time re-resolution, honesty labeling, explicit-path staging,
and a structured end-of-batch review + auto-run AC gate. `/document` correctly sourced
from git and flagged its own unfilled-harvest gap.

The two things this run could **not** establish — failure-path/cap behavior, and
un-telegraphed drift detection by a lone self-grading agent — are precisely the gaps Move
1.5 (orchestrator, honesty gate, write-lockout) is scoped to address. Move 1 is sound; the
known risks are deferred, not disproven.

---

## Disposition

- [ ] Sandbox (`move-1-sandbox/`) and validation plan deleted after harvest. _(On the
      harvest branch; discard with the branch — see note below.)_
- [ ] Findings fed into Move 1.5 design input — carry forward observations #3 and #4 plus
      the escalation-trigger stress-test recommendation.

> **Branch disposition:** the validation commits and sandbox live only on
> `feat/build-phase-move-1-harvest`. Recommended: keep this harvest doc on
> `feat/build-phase-move-1`, then delete the harvest branch — the sandbox never needs to
> merge. The changelog entry the Document run added lives on the harvest branch too;
> decide whether that throwaway-run entry is worth cherry-picking (the run itself judged
> it a borderline dangling-link risk).
