# `done_when`, tested against 13 real plans

**Date:** 2026-06-23 **Method:** empirical. Two fan-out passes, one agent per plan, over
the 13 plans in `~/sites/firestarter/docs/implementation-plans/` (2026-01-24 →
2026-03-05), grounded in the real repo and its git history. Pass 1: for each task, what
could an executable `done_when` be, and what's irreducibly manual? Pass 2: of pass 1's
plan↔code mismatches, which were real at build time vs. artifacts of reading old plans
against a newer repo?

Backs `2026-06-23-build-phase-changes.md` §2 and the trust-vs-gate question in
`2026-06-23-workflow-upgrade-path.md`.

---

## Pass 1 — is `done_when` viable? Mostly yes.

Across ~64 tasks, **~80% have a real executable `done_when`; ~20% are irreducibly
manual.** The split is predictable by task kind.

- **Mechanizable:** scaffolding (file/dir existence), config presence (grep yaml/json),
  lint/format/build/typecheck (exit codes), token-build output (grep generated CSS), tests
  (run the specific test). The token / lint / prettier / lefthook / test plans are ~95%+
  mechanizable.
- **Irreducibly manual**, in five recognizable types: runtime/server-up ("displays at
  localhost:3000"), visual judgment ("swatches look right"), DB/content + cross-service
  (Craft entries, webhook fires), secrets / out-of-band (token saved into Next.js), and
  comment/doc quality (you can grep that a comment exists, not that it's good).

Five findings that shape how `done_when` must be written:

1. **"It compiles" is the honest ceiling for a whole class of tasks — and it's a shallow
   gate.** For Next.js↔Craft work, nearly every mechanizable check bottoms out at
   `tsc --noEmit` / `next build`: proves it compiles, not that it displays Craft content.
   A shallow `done_when` passes while the work is still wrong — the "reviewer can be
   flattered" failure, reborn at the predicate.
2. **Prefer outcome checks over process checks.** Check that `tokens.css` has one `:root`
   and `clamp()` vars, not that you ran the generator. The process drifts; the output
   doesn't.
3. **For test-writing tasks, "test exists and passes" proves nothing.** An always-green
   test is worthless. The honest `done_when` is red-green:
   `pnpm tokens && git diff --exit-code src/tokens/tokens.css`.
4. **A task isn't all-or-nothing.** Even pure-visual Storybook work has checkable negative
   invariants (`git diff --quiet package.json` = no new deps). `done_when` should be a
   list separating the mechanical floor from an explicit `(manual)` remainder.
5. **Non-hanging.** "Is :3000 serving" is a bad gate (hangs); "the build binary works" is
   good.

---

## Pass 2 — the drift is real, but a different beast than it looked

Pass 1 kept flagging "the plan's command doesn't match the repo." That conflated two
things, and only one matters — a `done_when` runs once at build time and is discarded, so
drift that accrues afterward can't bite it.

- **KIND 1 — build-time drift:** the command was already wrong when the task was built.
  The kind that matters.
- **KIND 2 — later drift:** at build time the code matched the plan; the mismatch appeared
  later via refactors. Irrelevant — an artifact of reading a January plan against a June
  repo.

Git archaeology (pin each plan's build-time commit, re-check divergences there):

| Plan                         | Verdict                                                                                                |
| ---------------------------- | ------------------------------------------------------------------------------------------------------ |
| repo-architecture            | 2 KIND 1 (.env skipped; scaffold shipped nextjs-vite, not planned nextjs)                              |
| craft-cms-content-setup      | 2 KIND 1 (`@frontendUrl`/`FRONTEND_URL` consciously rejected for `{url}`/`PRIMARY_SITE_URL` mid-build) |
| nextjs-craft-integration     | 2 KIND 1 (no `typecheck` script ever; no route/graphql test infra) + 1 false-positive                  |
| lefthook-precommit           | 3 KIND 1 (`jobs:` not `commands:`, no `postinstall`, no `.lefthook-local.yml` — wrong day one)         |
| eslint-import-sorting        | CLEAN (control)                                                                                        |
| configure-prettier           | CLEAN (control)                                                                                        |
| design-tokens-pipeline       | 3 KIND 2 (generator→plugin refactor a week later)                                                      |
| consolidate-token-output     | KIND 2 (+ benign false-positive)                                                                       |
| fluid-tokens-terrazzo-plugin | KIND 1 (shipped `.mjs`; plan's check assumed `.ts` + `tsc`)                                            |
| fluid-token-modes            | KIND 2 (extracted API came 3 weeks later, for testability)                                             |
| storybook-token-display      | KIND 2 (plan's exact filenames existed at build; renamed ~11h later)                                   |
| terrazzo-integration-tests   | KIND 1 (`--project unit` never existed; shipped `tokens`)                                              |
| terrazzo-unit-tests          | KIND 1 ("14 tests" false at build SHA — only 6 shipped) + `unit→tokens` staleness                      |

**Real build-time drift in 7 of 13 plans; pure later-artifact in 4; clean in 2.** So
build-time drift is real and common — the "always write fresh" instinct earns its keep.
But the scary token-pipeline cases pass 1 screamed about were almost all KIND 2, harmless.

### The mechanism (and the smoking gun)

KIND 1 drift isn't slow rot. **The builder deviates from the plan's prediction during the
build** — often deliberately, for good reasons (the official starter's `{url}`, whatever
`storybook init` emits, a better project name) — **and the plan's literal command is never
back-ported to match.**

The gun, found twice (craft, and `unit→tokens`): the plan's own change-log records the
deviation in prose — "Deviated: renamed project `unit` → `tokens`" — while its "Done when"
line a few lines up still says `--project unit`. The document knew it deviated, wrote it
down, and left the check stale. A copied `done_when` fails with the right answer in the
same file.

---

## The design conclusion

Split `done_when` into two things, authored at two times by two actors:

- **Intent — locked before the build, from the plan.** "The token unit tests run and
  pass." The anti-gaming anchor: it can't be tailored to whatever got produced, and it
  survives every deviation unchanged.
- **Command — provisional in the plan, resolved against the real repo at dispatch,
  re-resolved if the builder deviates mid-build.** This catches KIND 1. In `unit→tokens`,
  intent never moved; only the command did (`--project unit` → `--project tokens`). The
  command may track reality as long as it still serves the locked intent.
- **Authored by not-the-builder** (orchestrator / reviewer), so "I deviated, let me write
  myself an easy check" can't happen.

This corrects the earlier "author the executable `done_when` in the plan" framing
(`build-phase-changes.md` §2). Same single-source rule as the rest of the exploration:
single-source the what, derive the how-to-check, don't freeze it. The drift is catchable
the moment it happens, because the builder creates it.

## Two bonus findings

1. **A live case for the honesty gate.** The "14 tests" claim was false at build time (6
   shipped) — not command drift, a false completion claim. Exactly what
   `verification-before-completion` (lifted from `ed3d` into `build-as-orchestrator.md`)
   catches.
2. **Drift correlates with judgment latitude.** The clean controls (eslint, prettier) are
   "install the one standard thing" — no room to deviate. The KIND 1 cluster is all
   config/infra/scaffolding, where the builder discovers the right way during execution.
   So fresh command-resolution is most needed there and near-wasted on mechanical installs
   — a heuristic for when to spend the effort.
