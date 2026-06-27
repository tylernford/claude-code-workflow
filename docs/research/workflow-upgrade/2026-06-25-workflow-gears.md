# Workflow gears — right-sizing the design→plan→build→document arc

**Date:** 2026-06-25. Fleshes out Move 2 ("add a lighter gear") from
`build-upgrade/2026-06-23-workflow-upgrade-path.md`, plus a `~/Downloads/spec-kit-main`
survey for prior art.

## The problem

The workflow has **one gear, and it's the heavy one.** firestarter's work runs from
"configure prettier" to "the design-tokens pipeline," weighted toward the small end.
Running the full four-phase arc on all of it is most of the "the output didn't justify the
exhaustion" fatigue. The fix isn't a second, dumber gear. It's right-sizing.

## Two reframes that make right-sizing safe

**1. Phases dissolve uncertainty; they don't produce documents.** Design dissolves "what
should this be, and why." Plan dissolves "how, in what order." The document is a
byproduct. So size each phase to how much uncertainty lives in its dimension:

- prettier → ~0 what, ~0 how → both phases collapse. Nothing to dissolve.
- token pipeline → high on both → full weight. The figuring-out is the game.
- refactor-for-testability → low what, real how → design collapses, plan stays.

Skip a phase only when there's nothing to figure out; the thinking never goes missing
where it matters. The fatigue was running the ritual on near-zero-uncertainty tasks —
paying the document cost without the benefit.

**2. Tracking is separable from ceremony.** Dropping the arc _feels_ like losing the
record because the arc staples thinking and tracking together. But tracking comes from
**git + `changelog.md`**, which you keep at every gear — not from the spec/plan. Spec/plan
are thinking; commit/changelog are tracking. Orthogonal.

- **Floor, identical at every gear:** a good commit (subject = what, body = why) + one
  `changelog.md` line. The Move 1 / Move 4 conclusion ("git is the handoff"; changelog is
  the one durable ledger).
- **One ledger, variable backing:** every gear lands a changelog line, so the changelog
  stays the single unified view. The gear changes only how much spec/plan sits behind each
  line.
- **To-do-later:** one line in `docs/backlog.md`, the lightweight pre-record. Work you do
  now skips it; commit + changelog is the post-record. Don't open a task for something
  you're about to immediately do — that's the ceremony to cut.

## The gear ladder

| Gear              | Ceremony                                                              | Good for                                                                    |
| ----------------- | --------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| **featherweight** | commit (good body) + one changelog line, no doc                       | one-line fixes, trivial tweaks                                              |
| **assess-style**  | one compressed triage doc, then do it                                 | a real bug worth triaging (root cause, rejected alternatives worth keeping) |
| **lean**          | the four phases, each a single lean artifact, no template boilerplate | a feature where you want the thinking but not the heavy templates           |
| **full arc**      | design spec + plan + build + document                                 | the token-pipeline class (real architecture, downstream deps)               |

The dial is set by **uncertainty + blast-radius + durability**, not habit. Most
firestarter work lives in the top two rows.

## Prior art to cannibalize: spec-kit (`~/Downloads/spec-kit-main`)

spec-kit solves this on two axes that map onto the two reframes:

- **By task type — the `bug` extension** (`extensions/bug/`): a smaller
  `assess → fix → test` pipeline, three files in `.specify/bugs/<slug>/`. It runs our
  patterns independently: the **assessment is an immutable contract** ("Never edit
  `assessment.md`… record disagreements in `fix.md` under **Deviations from Assessment**")
  = our AC-ledger / ed3d immutable-upstream. Its **`assess` file is the highest-value
  steal** — one page doing design+plan for a small thing: symptom → suspected paths →
  root-cause-with-confidence → files → tests → risks.
- **By ceremony weight — the `lean` preset** (`presets/lean/`): the same
  specify→plan→tasks→implement phases, but "just the prompt, just the artifact… no
  boilerplate sections to fill in." Reframe #2 as a one-line preset.

**What NOT to inherit:** even spec-kit's lightest gear writes three files for a bugfix —
too much for a one-liner. Its floor sits above our featherweight. spec-kit confirms the
multi-gear idea and hands us two ready models (`assess`-style, `lean`), but the
**featherweight tier is ours to build.** spec-kit doesn't have it, and "git is the
handoff" already covers it better at solo scale.

**Also liftable:** spec-kit's answer to a recurring small task type is _build a dedicated
extension_ (clone `extensions/template/`). The "single simple component" case could be a
tiny `component` gear on `assess→fix→test`, or just `lean`.

## Next action

Build two things, in order: (1) the **featherweight** gear — a rule plus the
commit/changelog floor, the lightest tier nobody hands you; and (2) the **heavy-vs-light
routing rule** (uncertainty + blast-radius + durability) so the gear gets chosen, not
defaulted to heavy. Lift `assess`-style and `lean` from spec-kit when a task calls for
them.
