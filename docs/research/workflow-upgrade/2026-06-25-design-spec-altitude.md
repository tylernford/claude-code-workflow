# Design-spec altitude — specify the contract, not the implementation

**Date:** 2026-06-25 **Origin:** `2026-06-25-spine-validator.md` read cleaner than usual
specs. The difference was altitude, not style.

---

## The principle

A spec specifies the **contract** — what must be true and why. It stays loose about the
**implementation** — how it gets built. The how is build's job, resolved against the real
repo.

- **Contract (belongs):** schema, checks, decisions and their reasons, non-goals, the
  intent of each piece.
- **Implementation (push to plan/build):** code snippets, exact paths, step-by-step
  mechanics.

## Code-heavy specs are a drift generator

They freeze the most _perishable_ part of the work — literal code and paths — into the
most _durable_ artifact. By build time the codebase has moved and the spec's code is
stale. That's the `done_when` drift finding (7/13 plans) one altitude up: right when
written, wrong when used. A high-altitude spec has nothing to go stale, because it never
pinned the perishable stuff.

## Same insight, held elsewhere

This is the intent/command split promoted to the document level: durable intent lives in
the spec; the command resolves fresh at build, by not-the-builder. ed3d says the same —
design plans are "intentionally high-level… generate code fresh based on codebase
investigation. Do NOT copy code from the design document." The _plan_ phase does that
investigation; design shouldn't know the paths yet.

You already half-hold this. The template calls its file list a "non-binding starting
point" that `/plan` re-verifies and owns. Take it at its word — right now code and paths
dominate the page and read as binding.

## The test

For any line, ask: **"Would this still be true if the codebase changed next week?"**

- **Yes** → check, decision, intent, schema field. Contract. It belongs.
- **No** → code snippet, exact path, a how. Push it down.

One question, clean sort.

## Guardrail — don't over-rotate

**Less-prescriptive is NOT vague.** A good high-altitude spec is ruthlessly precise about
the schema, the checks, the decisions. Be exact about the _contract_ and loose about the
_implementation_ — not loose about everything. Under-specifying the contract is the
opposite failure, and just as real. **High altitude, sharp edges.**

## So what

Lead with contract (intent, decisions, checks, non-goals). Demote code to illustration or
cut it. Mark file lists non-binding and mean it. Run the "true next week?" test on
anything that looks like code or a path. Let `/plan` and `/build` resolve the how against
the real repo.
