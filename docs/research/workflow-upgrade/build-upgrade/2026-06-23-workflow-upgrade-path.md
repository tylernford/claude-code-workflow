# Workflow upgrade path

**Date:** 2026-06-23 **Method:** Synthesis. Distills the two harness-engineering reviews
(`...-extension-review.md`, charitable/additive; `...-adversarial-review.md`, adversarial/
subtractive) plus a working-through of the felt problem — finishing a full
design->plan->build->document cycle leaves the dev tired, and during `/build` the per-step
approvals have become "auto-yeses" — into an actual sequenced path, not another review.

**Completes the trio:** extension review (what to add) + adversarial review (what's wrong
/ what to cut) + this (what to actually do, in order).

---

## The principle (hold onto just this)

**Gate decisions, not procedures. Mechanize the floor so it doesn't need you. Match
ceremony to stakes.**

This resolves the tension between the two reviews. The charitable review's "add more" is
right _only_ where a new check replaces an auto-yes with something mechanical; its "add
indexes / a /review skill" is the additive reflex the adversarial review correctly flags
as wrong for one person. So the path is mostly **subtract + mechanize**, with one thin
layer of **add**.

## The felt signal that drives the ordering

The fatigue is the most honest instrument available, and it discriminates between two
diagnoses that look identical on paper:

- **Process-tired** — spent serving ceremony (approvals, transcription, re-orientation).
  The hollow, faintly-resentful kind.
- **Decision-tired** — spent making hard calls. The satisfying kind; that one is the work.

Key admission that located the problem: the dev doesn't author the artifacts (the agent
does), so the tax isn't writing — it's being the **synchronous gate at high frequency**.
And during `/build` the approvals are "auto-yeses." An auto-yes gate has stopped doing
evaluation and started doing pacing; it is in fact _worse_ than no gate, because it
_feels_ supervised (false confidence) while training the reflex — approve before the eyes
engage — that waves the one real error through when it finally appears. `/build` is almost
entirely procedural (execution of work already decided upstream), which is exactly why
it's almost entirely auto-yes. The real, non-reflexive approvals live in design and plan.
So the upgrade relocates attention off procedure and onto decisions, and replaces the
auto-yes with a check.

---

## The path (sequenced; nothing depends on doing all of it)

### Move 1 — Fix the build phase (START HERE)

Highest leverage; directly targets the fatigue; already thought all the way through. One
skill (`/build`), four changes:

- **Stop pausing per task.** Default becomes _proceed_; the agent escalates only on a
  failing check, a genuine fork, or something irreversible. Approve-by-exception, not
  approve-by-default.
- **Make "done when" executable** where it can be. The plan task holds the stable
  _intent_; the actual command is **re-resolved against the repo at build time, by
  not-the-builder** (the plan's command is a provisional candidate, not frozen — see
  `build-phase-changes.md` §2). Where no command is feasible, tag it `(manual)`. That
  check _is_ the gate the auto-yes was pretending to be, and it doesn't get tired or
  rubber-stamp.
- **One real review at the end** — review the batch diff once, loaded-in, instead of N
  reflexive yeses through the middle.
- **Kill the per-task Build Log table** (`build/SKILL.md:43,66-78`) — three of its four
  columns (Date / Task / Files) are a hand-transcription of what git already holds (commit
  date, the commit subject = the task, `git log --stat` = the files), maintained by hand
  in a workflow that forbids touching git. The only column with non-derivable content is
  `Notes` (the _why_ of a deviation). Keep just that, as a short Completion "deviations
  from plan" summary or in the commit body — and drop the table.

Type: _subtract + mechanize the floor._ Loses no real evaluation (it wasn't happening at
the per-task level); ends with _more_ verification than the stamps gave.

**The Build Log's one consumer was `/document`** — it read the table to write the
changelog and PR draft. So killing the table flips `/document`'s source from a hand-copied
transcript to the real record: it reads `git log <base>..HEAD` for the narrative
(subjects, dates), `git log --stat` for the files, and the commit bodies (or the
Completion summary) for deviation rationale. Read-only git, allowed under the no-git rule.
This is strictly more honest — `/document` was caught asserting acceptance criteria it
never verified precisely because it summarized a narrative instead of reality; pointed at
git it can only report what actually got committed. The dependency: commits must be good
(meaningful subjects — already true, since `/build` step 6 commits with the plan's
per-task message — and the deviation _why_ in the body when something diverges). Net
effect: the changelog stops deriving from a hand-maintained middleman and starts deriving
from git. "Docs are the handoff" between build and document becomes the more honest
"**git** is the handoff."

### Move 2 — Add a lighter gear

The dev is tired partly because there is only one gear and it's the heavy one — every
change pays the full four-phase arc, even a one-file fix. Add a **lightweight path**:
brief intent -> do it -> one-line changelog, no design->plan->build->document. Write down
the rule for heavy vs. light (stakes / novelty / blast radius). The harness doc keeps
exactly this ephemeral path; this workflow has no lightweight gear, which is most of the
"the output didn't justify the exhaustion" feeling.

Type: _add_ — but it's an escape hatch _from_ ceremony, not more of it.

**Fleshed out (2026-06-25):** see `../2026-06-25-workflow-gears.md` — the gear ladder
(featherweight → assess-style → lean → full arc), the two reframes that make right-sizing
safe (phases dissolve _uncertainty_ not produce documents; tracking is separable from
ceremony = git + changelog at every gear), and spec-kit (`~/Downloads/spec-kit-main`) as
prior art to cannibalize (its `bug` extension's `assess` file; its `lean` preset). The one
tier spec-kit lacks — featherweight — is ours to build.

### Move 3 — Collapse the duplication

- **Acceptance-criteria drift — SUPERSEDED (2026-06-24) by the carry-forward ledger.**
  This bullet originally read "author AC once in the spec; the plan _references_ them,
  doesn't re-type." That mechanism is **retired.** Two things overturned it:
  - **The enemy is _silent_ drift, not drift.** Plans legitimately _add_ criteria and
    legitimately _narrow_ scope for phased work — that's healthy. The sin is doing it with
    no trace. "Reference, don't re-type" treats all divergence as rot and would suppress
    the healthy adds; it answers the wrong problem. (And ed3d, the mature reference
    implementation, doesn't reference either — it copies AC literally and defends the
    source by immutability.)
  - **A better, more-evidenced design now exists:**
    `docs/design-specs/2026-06-24-1235-acceptance-criteria-carry-forward.md` (diagnosed
    across 30 spec/plan pairs in 3 projects, vs. our 13). The answer is **two docs, not
    merged** — design stays the unchanged source — with the plan carrying _every_ design
    criterion forward as a **provenance-tagged ledger** (`(design)` / `(added)` /
    `(deferred → …)` / `(dropped — reason)`), so a dropped criterion shows as a struck
    line, not an absence. `/build` gates on the active (unstruck) criteria. This is the
    artifact-gate the rest of this exploration kept arriving at, applied to the AC chain.

  So the **spec-vs-plan merge question is resolved: keep them separate.** Not for the
  original "single-home the AC" reason (which is retired) but because design = durable
  source and the plan = a carry-forward ledger that's _allowed_ to diverge, visibly. The
  original 3/11 firestarter finding still stands as evidence the gap is real; only its
  proposed _fix_ changed.

- **Pull the copy-pasted phase boilerplate into `CLAUDE.md`.** Specifically the global
  **Rules footer** (No git / Stay local / Slash-commands-only / One-phase-per-session) and
  the "Announce Your Location" banners, currently re-copied across all 4-5 SKILL.md files.
  Lift them out into `CLAUDE.md` once — the map every phase already reads. That copy-paste
  _is_ the drift vector that reintroduced the relative-path bug twice.

The boilerplate bullet is the same single-source disease as the per-task Build Log
(hand-copies git) — re-typed content with one true home rots. The AC case is the
**exception that refined the rule**: criteria genuinely have one source (the spec) but the
plan _should_ carry them forward, because the plan needs to add and narrow them — so the
fix there is a visible provenance ledger, not de-duplication. Subtract blind copies; tag
the copies that have to exist.

Type: _subtract (boilerplate) + make-visible (AC ledger)._

### Move 4 — Lay one thin mechanical floor

The one place the additive instinct is right, because the check removes a job from the
human rather than adding one: a **pre-commit link check + exec-bit/shebang check** in the
existing `.githooks/pre-commit`. Catches the recurring documented rot (dead
`design-plans/` links, the still-live `sync-skills.sh` `100644` bug) without anyone
watching for it. Fix the live bugs in the same pass (sync-skills mismatch, dead links,
ghost `docs/learning/`).

Type: _add_ — but a check that removes vigilance from the human, not one that adds a task.

### Move 5 — Decide learn-by-doing's fate (separate track)

Largest file in the repo, broken in the field (references a synced file that isn't synced;
writes to a `docs/learning/` that doesn't exist), and a tutoring product wearing the
workflow's costume. Not part of the core upgrade — but pull it into its own thing or fix
its sync/scope; don't leave it half-wired inside the build arc.

Type: _subtract / separate._

---

## Deliberately left off (for now)

The charitable review's **index generator**, **`/review` skill**, and elaborate
**meta-loop machinery**. Real, but _additive_, and the live signal (fatigue) points at
subtraction. Defer until the weight comes off; revisit only if a specific pain returns.
The one piece of the meta-loop worth keeping in view: backlog lessons that never reach the
skills ("5 tasks max," "split by system boundary") — fold those in opportunistically, but
don't build machinery for it yet.

## The shape of the whole thing

Moves 1-3 delete ceremony and relocate attention to the decisions that deserve it. Move 4
is the one thin floor that makes deleting _safe_ (rigor moves from where it wasn't
happening — auto-yes — to where it can: a check + one real review). That's the upgrade:
lighter, with the human gating decisions instead of procedures.

**What survives every cut (the core, don't touch):** small explicit human-evaluated
artifacts on the _decisions_; the map (`CLAUDE.md`); the one real mechanical gate
(`disable-model-invocation: true`); one durable ledger (`changelog.md`); design/plan as
the phases where real judgment lives.

## Resolved direction (2026-06-24): human reviews end-of-batch, not per-task

**Decided, from lived evidence — not from this doc.** The human is **out of the per-task
loop**. The build is automated as far as it will go — agents do the work _and_ run the
per-task checks, looping on their own — and the human comes in **once, at the end, to
review the whole batch.**

The evidence that settled it: the per-task manual review the dev was running by hand
(after each "done," fire a subagent to review, then adjust) _catches real things_ — so the
second-set-of-eyes review earns its keep and is worth automating. But doing it
task-by-task, inside a full manual design→plan→build→document flow, is **too taxing to
sustain.** So the trade is made deliberately: accept less per-task contact in exchange for
a build that doesn't cost attention task-by-task. This picks the **full orchestrator**
(`2026-06-23-build-as-orchestrator.md`, Move 1.5) over the minimal single-agent Move 1 —
the scale-fit reviewer's "a solo dev reads his own diffs, skip the orchestrator" was wrong
_here_, because the dev's review was never a diff-read; it was already a separate review
agent. The orchestrator automates a habit that already works, not speculative machinery.

**What this implies (where the design effort now goes):** the loop running is the easy
part and is basically spec'd. The part that decides whether this _works_ is the **handoff
to the batch review** — because moving the human to end-of-batch is exactly the
surrogation move the soundness doc warns about (less contact, a finished pile already
wearing green checkmarks, the auto-yes relocated one level up). So the batch review has to
stay a _real_ read, and the handoff is what keeps it cheap enough to stay real.
Concretely, the end-of-batch handoff should surface:

- **Deviations first** — wherever the agents did something not in the plan (the
  `shouldProcess` case in `~/sites/firestarter/.../terrazzo-plugin-unit-tests.md`'s own
  Build Log is the pattern: the out-of-plan work is where the bodies are buried).
- **`(manual)` items separately** — the "looks right / matches spec" checks no command can
  cover, pulled out so they don't hide in the green; these are the human's actual job.
- **Verified-vs-just-compiled, per task** — so attention goes to the shallow greens, not
  the proven ones (keeps the "compiles, behavior unverified" labeling load-bearing, not
  cosmetic).
- **Diffs, especially test-file changes** — this is also the tamper-catch: surfacing test
  changes at batch review is _why_ this dev does not need the builder-write-lockout
  machinery (Guard 4 / the soundness doc's "one new requirement"). The batch review is the
  lock, as long as test changes get surfaced instead of buried.

**The line that must not be crossed:** review, not auto-fix-and-forget. The dev stays the
one who _decides what to do with findings_; the agents must not silently fix-agents'-work
while the human scrolls past. The moment "did it pass?" replaces "is it right?" at batch
review, the gate has become the new auto-yes (see the surrogation recursion below).

**What this leaves open:** the _gate type_ fork below (outcome vs. procedure) is **not**
settled by this — that's still an empirical call for the first real loop run. This
decision is only about _where the human sits_ (end-of-batch) and _what the batch handoff
must show_ to keep that review real.

## Open questions (don't let these settle silently)

- **Procedure gate vs. outcome gate for the build review loop.** When `/build` becomes an
  orchestrator (`2026-06-23-build-as-orchestrator.md`, Move 1.5), what is the loop's exit
  condition? Two postures, and we've only _provisionally_ picked one:
  - **Outcome gate (current pick):** the loop exits when the executable `done_when` passes
    **and** the review subagent has no findings _scoped to the task contract_. Quality
    beyond the contract is a backlog item, not a loop blocker. Fits the principle (gate
    outcomes, match ceremony to stakes) and avoids gold-plating non-convergence.
  - **Procedure gate (the `ed3d-plan-and-execute` posture, not adopted):** the loop exits
    only at _zero issues in every category, Minor included_ — "Minor is not optional."
    Stricter, more uniform, but it's the maximal-ceremony stance the adversarial review
    warned against, and it lets an unscoped reviewer block forever.

  The reason this isn't settled: `ed3d` runs that strict gate **off the human, between
  cheap subagents** — which neutralizes the usual objection (it doesn't tire _me_). So the
  real question is empirical, not philosophical: **does outcome-gating let too much
  through in practice?** Decide it from evidence, not from this doc.

  **Trigger to revisit:** after proving the orchestrator loop on one real substantive task
  (the "prove it on one task" step in `build-as-orchestrator.md`). If the outcome gate
  ships work with Minor-grade rot the end-of-batch review keeps catching, escalate toward
  the procedure gate — but scoped, and still off the human. Until that evidence exists,
  hold the outcome gate; do not let either default win by silence.

- **Trust vs. gate: which build-loop "MUSTs" should be mechanized?** (One layer beneath
  the fork above.) Almost everything we lifted from `ed3d-plan-and-execute` into the
  orchestrator draft is enforced by **prose trust** — long markdown that says MANDATORY /
  NEVER / "Minor is not optional" and hopes the agent complies. The tell that this is
  trust, not enforcement: `ed3d`'s giant "Common Rationalizations — STOP" tables. You only
  need to win an argument with the agent in advance when you have no mechanism to make the
  bad action impossible. Exactly **one** mechanic in the whole orchestrator design is a
  real gate: the executable `done_when` exits 0 — which is _why_ it keeps getting called
  the honesty floor. Everything else (transparency mandate, fix-all-Minor, three-strike,
  verbatim findings, just-in-time loading) is the agent policing itself.

  Crosslink is the counter-example and the reference posture: its PreToolUse hook doesn't
  _ask_ for an issue first, it **blocks** the Write/Edit/Bash call until one exists. A
  gate can't be rationalized past, doesn't get tired, and deletes the rationalization
  table outright. This is Thread 1's standing conclusion applied here — _lift the
  enforcement posture, not the engine._

  **The triage to actually do:** for each build-loop "MUST," ask whether a **crisp,
  checkable predicate** sits under it — _a task record exists_, _the `done_when` command
  exited 0_, _the commit carries the trailer/real SHA_, _the review artifact was written_.
  Where one does → gate it (candidate gates: block commit unless this task's `done_when`
  passed in-session; block Write/Edit unless an active task record exists; capture the
  real SHA at commit time via the hook, not the agent's self-report — the `reconcile.py`
  broken-join-key finding). Where the predicate is irreducibly a **judgment call** ("is
  this report complete," "is this Minor actually fixed") → keep it as trust, and _label it
  as trust_ rather than dressing it up as MANDATORY. A "MANDATORY" in markdown is a wish,
  not a wall.

  **Hard caveat (don't trade one hazard for a worse one):** a PreToolUse hook is shell
  that runs on _every_ tool call — it is itself "plugins as kill-your-environment code"
  wearing an enforcement hat (see the opencode-plugins note). Gate only with the smallest,
  narrowest, most declarative check that does the job; crosslink's "does a row exist in
  the db" is about the right size. Don't convert a markdown-trust problem into a
  hook-that-bricks-the-machine problem.

  **Trigger to revisit:** same as the fork above — the first real run of the orchestrator
  loop. As each trust-instruction either holds or gets violated in practice, sort it into
  gate-it (has a predicate, got violated) vs. leave-as-honest-trust (judgment, or never
  violated). Don't pre-build hooks for instructions that the agent actually follows; gate
  the ones that fail.

  **The surrogation recursion (don't let the gate become the new auto-yes).** The
  soundness research (`2026-06-23-done-when-is-it-sound.md`, "The uncomfortable
  recursion") names the core risk: gating `done_when` doesn't _kill_ the auto-yes, it
  _moves_ it one level up — "did it pass?" silently replacing "is it right?". Two
  consequences this open question turns on: (1) the end-of-batch human review must stay a
  _real evaluation_, or the gate's value collapses and we're back where we began; (2) a
  shallow `done_when` trusted as full proof is surrogation in miniature — keep the
  "compiles, behavior unverified" labeling honest. Watch for both on the first real loop
  run: the tell is the moment "did it pass?" replaces "is it right?" in your own head.

## Next action

Move 1 — draft the concrete `/build` changes: approve-by-exception, executable `done_when`
(intent in the plan, command re-resolved at build), batch-review-at-end, drop the per-task
table. Everything else can follow once the build phase stops costing attention it isn't
using.
