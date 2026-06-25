# `done_when`, tested against 13 real plans

**Date:** 2026-06-23 **Method:** empirical. Two fan-out passes of one agent per plan over
the 13 implementation plans in `~/sites/firestarter/docs/implementation-plans/`
(2026-01-24 → 2026-03-05), grounded in the real repo + its git history. Pass 1: _for each
task, what could an executable `done_when` actually be — and what is irreducibly manual?_
Pass 2 (after a methodological doubt): _of the plan↔code mismatches pass 1 found, which
were real at build time vs. artifacts of reading old plans against a newer repo?_

This is the empirical backing for `2026-06-23-build-phase-changes.md` §2 (executable
`done_when`) and for the trust-vs-gate open question in
`2026-06-23-workflow-upgrade-path.md`.

---

## Pass 1 — is `done_when` even viable? Mostly yes.

Across ~64 tasks, **~80% have a real executable `done_when`; ~20% are irreducibly
manual.** The split is predictable by task _kind_:

- **Mechanizable:** scaffolding (file/dir existence), config presence (grep yaml/json),
  lint/format/build/typecheck (exit codes), token-build output (grep generated CSS), tests
  (run the specific test). The token / lint / prettier / lefthook / test plans are ~95%+
  mechanizable.
- **Irreducibly manual**, clustering into five recognizable types: _runtime/server-up_
  ("displays at localhost:3000"), _visual judgment_ ("swatches look right"), _DB/content +
  cross-service_ (Craft entries, webhook fires), _secrets / out-of-band_ (token saved into
  Next.js), and _comment/doc quality_ (you can grep a comment exists, not that it's good).

**Five findings that shape how `done_when` must be written:**

1. **"It compiles" is the honest ceiling for a whole class of tasks — and it's a shallow
   gate.** For the Next.js↔Craft work, nearly every mechanizable check bottoms out at
   `tsc --noEmit` / `next build`: proves it compiles, not that it _displays Craft
   content_. A shallow `done_when` is a gate that passes while the work is still wrong —
   the "reviewer can be flattered" failure, reborn at the predicate. A present gate is not
   automatically a strong gate.
2. **Prefer outcome checks over process checks.** Check that `tokens.css` has one `:root`
   and `clamp()` vars (outcome), not that you ran the generator (process). The process
   drifts; the wanted output doesn't.
3. **For test-writing tasks, "test exists and passes" proves nothing** — an always-green
   test is worthless. The honest `done_when` is red-green (golden-file diff:
   `pnpm tokens && git diff --exit-code src/tokens/tokens.css`).
4. **A task isn't all-or-nothing.** Even pure-visual Storybook work has checkable negative
   invariants (`git diff --quiet package.json` = no new deps). `done_when` should be a
   _list_ separating the mechanical floor from an explicit `(manual)` remainder.
5. **Non-hanging.** "Is :3000 serving" is a bad gate (hangs); "the build binary works" is
   a good one.

---

## Pass 2 — the drift is real, but it's a different beast than it looked

Pass 1 kept flagging "the plan's command doesn't match the repo." That conflated two
things, and only one matters (a `done_when` is run once at build time and discarded, so
drift that accrues _afterward_ can never bite it):

- **KIND 1 — build-time drift:** the plan's command was _already wrong when the task was
  built_. The kind that matters.
- **KIND 2 — later drift:** at build time the code _matched_ the plan; the mismatch
  appeared later via refactors. Irrelevant to `done_when` — an artifact of reading a
  January plan against a June repo.

Git archaeology (pin each plan's build-time commit, re-check its divergences there):

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

**Real build-time drift in 7 of 13 plans; pure later-artifact in 4; clean in 2.** So:
build- time drift is real and common (the "always write fresh" instinct earns its keep) —
but the scary token-pipeline cases the first pass screamed about were _almost all KIND 2_,
harmless.

### The mechanism (and the smoking gun)

KIND 1 drift is not slow rot. It is: **the builder deviates from the plan's prediction
_during the build_** — often deliberately, often for good reasons (uses the official
starter's `{url}`, scaffolds whatever `storybook init` actually emits, picks a better
project name) — **and the plan's literal command is never back-ported to match the
deviation it just made.**

The gun, found twice (craft, and `unit→tokens`): the plan's _own change-log_ records the
deviation in prose — "Deviated: renamed project `unit` → `tokens`" — while the plan's
"Done when" line a few lines up still says `--project unit`. The document _knew_ it
deviated, wrote it down, and left the executable check stale. A copied `done_when` fails
with the right answer sitting in the same file.

---

## The design conclusion

Split `done_when` into two things, authored at two times by two actors:

- **Intent — locked before the build, from the plan.** "The token unit tests run and
  pass." The anti-gaming anchor: it can't be tailored to whatever got produced, and it
  survives every deviation unchanged.
- **Command — provisional in the plan, resolved against the real repo at dispatch, and
  re-resolved if the builder deviates mid-build.** This is what catches KIND 1. In the
  `unit→tokens` case the intent never moved; only the command did (`--project unit` →
  `--project tokens`). The command may track reality _as long as it still serves the
  locked intent._
- **Authored by not-the-builder** (orchestrator / reviewer), so "I deviated, let me also
  write myself an easy check" can't happen.

Plainly: **the plan carries the intent as fixed and the command as an
explicitly-provisional guess; the build phase's job is to make the command match what was
actually built, against the locked intent.** The drift is real but _catchable at the
moment it happens_, because the builder is the one creating it.

This corrects the earlier "author the executable `done_when` in the plan" framing
(`build-phase-changes.md` §2): the plan holds intent; the _command_ is derived at build
time, not frozen. Same single-source rule as the rest of the exploration — single-source
the _what_, derive the _how-to-check_ from reality instead of copying it.

## Two bonus findings

1. **A live case for the honesty gate.** The "14 tests" claim was false _at build time_ (6
   shipped) — not command drift, a false completion claim. Exactly what
   `verification-before-completion` (lifted from `ed3d` into `build-as-orchestrator.md`)
   exists to catch.
2. **Drift correlates with judgment latitude.** The two clean controls (eslint, prettier)
   are "install the one standard thing" — no room to deviate. The KIND 1 cluster is all
   config/infra/scaffolding, where the builder _discovers the right way during execution_.
   So fresh command-resolution is most needed there and near-wasted on mechanical installs
   — a usable heuristic for _when_ to spend the effort.
