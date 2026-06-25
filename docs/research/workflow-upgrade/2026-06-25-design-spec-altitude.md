# Design-spec altitude — specify the contract, not the implementation

**Date:** 2026-06-25 **Origin:** noticed while reviewing `2026-06-25-spine-validator.md` —
it read cleaner than the usual specs, and the difference turned out to be _altitude_, not
style. This is the principle that fell out.

---

## The principle

A design spec should specify the **contract** — what must be true and why — and stay loose
about the **implementation** — how it gets built. Precise about the contract; loose about
the how. The how is the build phase's job, resolved against the real repo.

- **Contract (belongs in the spec):** the schema, the checks/behaviors, the decisions and
  their reasons, the non-goals, the intent of each piece.
- **Implementation (does NOT belong; push to plan/build):** code snippets, exact file
  paths, the step-by-step mechanics.

## Why code-heavy specs are a bug, not thoroughness

A prescriptive, code-heavy spec is a **drift generator.** It freezes the most _perishable_
part of the work — the literal code and paths — into the most _durable_ artifact. By build
time the codebase has moved and the spec's code is stale. That is the `done_when` drift
finding (7/13 plans) one altitude up: the spec was right when written and wrong by the
time it's used.

It also **collapses the altitude** — design does build's job prematurely, against a
codebase that will have changed — which buries the durable _what/why_ under the perishable
_how_, and over- constrains the builder, who should be resolving against reality.

A high-altitude spec has _nothing to go stale_, because it never pinned the perishable
stuff. ed3d institutionalizes this: design plans are "intentionally high-level… generate
code fresh based on codebase investigation. Do NOT copy code from the design document,"
and the _plan_ phase does the codebase investigation, not design. Design shouldn't know
the file paths yet.

## Same insight, already held elsewhere

This is the **intent/command split promoted to the document level** — the durable intent
lives in the spec; the command/code is resolved fresh at build by not-the-builder. It is
also the PRD-vs-design-plan altitude (don't let _how_ leak up into _what_) and ed3d's
high-level-design rule. Three threads, one principle: keep the perishable how out of the
durable artifact.

You already half-hold this. The spec template says of its file list: "_Non-binding
starting point. `/plan` re-verifies these and owns the final paths._" The fix is to **take
the template at its word** — right now the code examples and path lists still dominate the
page and read as binding.

## The test

For any line in a design spec, ask: **"Would this still be true if the codebase changed
next week?"**

- **Yes** → a check, a decision, an intent, a schema field — it's contract, it belongs.
- **No** → a code snippet, an exact path, a how — push it down to plan/build.

That one question sorts contract from implementation cleanly.

## The guardrail (don't over-rotate)

**Less-prescriptive is NOT vague.** A good high-altitude spec is _ruthlessly precise_ —
about the schema, the checks, the decisions. The skill is being exact about the _contract_
and loose about the _implementation_, not loose about everything. Under-specifying the
contract is the opposite failure and just as real. **High altitude, sharp edges.**

## So what

When writing or reviewing a design spec: lead with contract (intent, decisions, checks,
non-goals); demote code to clearly-illustrative-only (or cut it); mark file lists
non-binding and mean it; run the "true next week?" test on anything that looks like code
or a path. Let `/plan` and `/build` resolve the how against the real repo — that's where
it belongs and where it stays current.
