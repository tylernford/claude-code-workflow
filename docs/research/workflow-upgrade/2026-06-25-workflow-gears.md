# Workflow gears — right-sizing the design→plan→build→document arc

**Date:** 2026-06-25 **Relationship:** the concrete fleshing-out of Move 2 ("add a lighter
gear") from `build-upgrade/2026-06-23-workflow-upgrade-path.md`. Came out of a
working-through of "the full arc is overkill for a small bugfix or a simple component —
but then how does that work get tracked?" plus a survey of `~/Downloads/spec-kit-main` for
prior art.

---

## The problem

The workflow has **one gear, and it's the heavy one**. firestarter's actual work spans a
wide size range (from "configure prettier" to "the design-tokens pipeline"), weighted
toward the small end. Running the full four-phase arc on all of it is the bulk of the "the
output didn't justify the exhaustion" fatigue. The fix is not a second, dumber gear — it's
right-sizing.

## Two reframes that make right-sizing safe

**1. Phases dissolve uncertainty; they don't produce documents.** Design dissolves "what
should this be, and why." Plan dissolves "how, in what order." The document is a
_byproduct_ of the thinking, not the point. So size each phase to how much uncertainty
lives in _its_ dimension:

- prettier → ~0 what-uncertainty, ~0 how-uncertainty → both phases collapse (nothing to
  dissolve; you lose nothing by skipping).
- token pipeline → high both → full weight, the figuring-out is the whole game.
- refactor-for-testability → low what, real how → design collapses, plan stays.

You never lose the figuring-out _where it matters_ — you only skip a phase when there's
genuinely nothing to figure out. The fatigue was running the _ritual_ on tasks whose
uncertainty was already near zero: paying the document cost without getting the thinking
benefit.

**2. Tracking is separable from ceremony.** The reason "drop the arc for small work"
_feels_ like "lose the record" is that the full arc staples thinking and tracking
together. But the tracking never came from the spec/plan — it comes from **git +
`changelog.md`**, which you keep at every gear. Spec/plan are _thinking_; commit/changelog
are _tracking_. They're orthogonal.

- **Floor, identical at every gear:** a good commit (subject = what, body = why) + one
  `changelog.md` line. This is the Move 1 / Move 4 conclusion ("git is the handoff";
  changelog is the one durable ledger) applied here.
- **Coherence:** the changelog is the single unified view across all gears — everything
  lands a line there. The gear only changes how much spec/plan sits _behind_ each line,
  not whether it's tracked. One ledger, variable backing.
- **To-do-later** (not now): one line in `docs/backlog.md` — the lightweight _pre_-record.
  Work you do _now_ skips pre-tracking; the commit + changelog is the _post_-record. Don't
  open a task for something you're about to immediately do — that's the ceremony to cut.

## The gear ladder

| Gear              | Ceremony                                                              | Good for                                                                    |
| ----------------- | --------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| **featherweight** | commit (good body) + one changelog line, no doc                       | one-line fixes, trivial tweaks                                              |
| **assess-style**  | one compressed triage doc, then do it                                 | a real bug worth triaging (root cause, rejected alternatives worth keeping) |
| **lean**          | the four phases, each a single lean artifact, no template boilerplate | a feature where you want the thinking but not the heavy templates           |
| **full arc**      | design spec + plan + build + document                                 | the token-pipeline class (real architecture, downstream deps)               |

The dial is set by **uncertainty + blast-radius + durability**, not by habit. Most
firestarter work lives in the top two rows.

## Prior art to cannibalize: spec-kit (`~/Downloads/spec-kit-main`)

spec-kit solves this on **two axes**, which map onto the two reframes above:

- **By task _type_ — the `bug` extension** (`extensions/bug/`): a separate, smaller
  pipeline, `assess → fix → test`, three small markdown files in `.specify/bugs/<slug>/`.
  It independently runs our patterns: the **assessment is an immutable contract** ("Never
  edit `assessment.md`… record disagreements in `fix.md` under **Deviations from
  Assessment**") = the AC-ledger / ed3d immutable-upstream; scoped/minimal change;
  per-stage checks. Its **`assess` file is the single highest-value steal** — one page
  that does design+plan for a small thing: symptom → suspected paths →
  root-cause-with-confidence → files → tests → risks.
- **By ceremony _weight_ — the `lean` preset** (`presets/lean/`): the same
  specify→plan→tasks→implement phases, but "just the prompt, just the artifact… no
  boilerplate sections to fill in." This is reframe #2 (keep the thinking, drop the
  artifact ceremony) shipped as a one-line preset.

**What NOT to inherit:** even spec-kit's lightest gear (the bug extension) writes **three
files** for a bugfix. For a one-liner that's still too much — its floor sits _above_ our
featherweight. spec-kit confirms the multi-gear idea and hands us two ready models
(`assess`-style, `lean`), but the **featherweight tier is the one piece it doesn't have**
— that one is ours to define, and the "git is the handoff" instinct already covers it
better at solo scale.

**Also liftable:** spec-kit's answer to "I keep hitting a recurring small task _type_" is
_build a small dedicated extension for it_ (there's an `extensions/template/` to clone).
The "single simple component" case could be a tiny `component` gear modeled on
`assess→fix→test`, or just `lean`.

## Next action

Two things to actually build, in order: (1) the **featherweight** gear (a rule + the
commit/ changelog floor — the lightest tier nobody hands you), and (2) the
**heavy-vs-light routing rule** (uncertainty + blast-radius + durability) so the gear gets
_chosen_, not defaulted to heavy. The `assess`-style and `lean` gears can be lifted from
spec-kit when a task calls for them.
