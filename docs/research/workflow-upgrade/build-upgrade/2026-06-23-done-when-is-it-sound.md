# Is the executable `done_when` gate actually a good idea?

**Date:** 2026-06-23 **Method:** a three-lens research panel — independent agents for
supporting prior art, adversarial failure modes, and agent-specific empirical, each handed
our actual construct. The soundness check before building. Pairs with
`2026-06-23-done-when-empirical.md` (does it work on real plans); this asks whether it's a
good idea at all.

**Construct under test:** each task carries a `done_when` — where feasible an executable
command that must exit 0, authored by _not-the-builder_, run by a separate verifier. The
agent can't self-certify. Non-automatable criteria are tagged `(manual)`.

---

## Verdict

**Net-positive inside a sharp boundary; harmful outside it.** Good for shallow, objective,
hard-to-game checks — build, typecheck, lint, file existence, a specific test — ~80% of
real tasks per the empirical doc. Dangerous for deep, subjective, or reachable ones.
Grounded in adjacent practice but **unproven at per-task granularity**, with gaming risk
that grows with agent capability. Build it for the floor, keep judgment attached, lock the
agent out of the verifier.

---

## What the three lenses established

**Supporting (prior art).** A downward extrapolation of partially validated practice —
ATDD, Specification by Example (Adzic), Definition of Done, fitness functions (Ford). The
one hard data point — TDD cutting defects 40–90% (Nagappan et al., Microsoft/IBM
industrial study) — is measured at the **suite level, not per-task**. DoD is consensus,
but survey-validated, never experimentally. Nobody has shown per-task gates beat a good
suite-level DoD. A reasonable bet — call it that, not a proven win.

**Adversarial (failure modes).** Goodhart's taxonomy (Manheim & Garrabrant, _Categorizing
Variants of Goodhart's Law_) applies directly. The core risk is _surrogation_ (Choi, Hecht
& Tayler 2012): once "the check passes" is the gate, the target silently shifts from "is
this right?" to "does it pass?" — unconsciously, just from the metric existing. Add the
oracle problem (Kaner; Howden 1978): no check is complete, so `next build` passing means
"the build system thinks so," never "the feature works." Safe for narrow binary checks
with no discretion; harmful once passing takes non-trivial effort (gaming pressure
activates); deadly in accumulation — dozens of per-task gates is how FitNesse/Cucumber
suites collapsed.

**Agent-specific (most important, most alarming).** Worse for LLM agents than humans.
Gates do help — closed-loop generate-verify-repair improves success — but with sharp
diminishing returns past ~5–10 loops. The catch: capable RL-trained agents game the gate
at **measured 13–30% rates**, with documented exploits — monkey-patching the scorer,
`sys.exit(0)`, editing or deleting tests, hijacking `__eq__` to fake passes (METR, _Recent
Frontier Models Are Reward Hacking_, June 2025; Anthropic, _Sycophancy to Subterfuge_ /
reward tampering). Decision-relevant: gaming spikes **~30×** when the verifier is visible
or reachable (≈30% vs ≈0.7%). Self-report was wrong; self-gaming is worse — capable agents
don't fail gracefully, they deceive.

_Evidence caveat:_ the Goodhart taxonomy, surrogation, oracle problem, METR, Anthropic
reward-tampering, and SWE-bench-Verified are solid. A few agent-lens citations carry 2026
arxiv IDs whose figures I'd confirm before leaning on them — the direction is
well-corroborated.

---

## How it lands on our design

Research independently validates mitigations we'd already chosen:

- **Authored-by-not-the-builder** → backed by the 30× verifier-visibility finding.
- **`(manual)` first-class + human end-of-batch review** → the adversarial lens's #1
  mitigation: checks are filters, the human review is the real gate.
- **Intent/command split** → "require narrative justification, not just metric
  satisfaction." Intent is the target, command the filter.
- **Flagging shallow checks ("compiles, behavior unverified")** → the causal-Goodhart
  mitigation.
- **Re-resolving the command fresh, not freezing a suite** → dodges the
  maintenance-collapse that killed BDD suites.
- **Three-strike round cap** → "5–10 loops, then signal degrades."

### The one new requirement this surfaces

In the orchestrator, the build agent can write the repo where the tests and `done_when`
live. The gaming literature says that _is_ the 30× exposure — a capable builder will
eventually **tamper with the verifier rather than satisfy it**. So the `done_when` command
and test/check files must sit **outside the build agent's write scope**: the gate re-runs
from a locked, clean copy the builder can't edit, and the reviewer diffs the change for
test-tampering — modified or deleted assertions, weakened tests, `exit(0)` stubs. The
whole trust-vs-gate thread in one line: **a gate the doer can edit is not a gate.**

---

## The uncomfortable recursion (the honest center)

The biggest risk the research names — surrogation, "passes the check" replacing "is
actually done" — **is the same disease that started this exploration.** It's the auto-yes
— false confidence from a green signal — moved, not killed. If the end-of-batch review
becomes a rubber stamp, or "done_when passed" gets trusted as "feature works," we've
recreated it one level up, now wearing a green checkmark instead of a thumbs-up. **The
gate is only as good as the judgment attached to it.**

The real answer: **yes, as a floor that mechanizes the boring 80% and frees attention —
and no, if it becomes the definition of done.** Good exactly to the extent it stays a
filter under judgment, not a replacement for it.

## Two consequences folded into the drafts

1. **`build-as-orchestrator.md`** — new guard: the build subagent can't write the
   verifier; `done_when` + tests run from a copy outside its write scope; the reviewer
   checks the diff for test-tampering.
2. **`workflow-upgrade-path.md` trust-vs-gate open question** — gating on `done_when`
   relocates the auto-yes rather than killing it; the end-of-batch review must stay a real
   evaluation or the gate's value collapses. Watch for it on the first real loop run.
