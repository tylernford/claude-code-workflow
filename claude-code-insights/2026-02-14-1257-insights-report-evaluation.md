# Insights Report Evaluation Notes

Notes from reviewing the Claude Code Insights report (2026-01-02 to 2026-02-14).

## What's solid

The **quantitative data** is reliable and useful:

- Usage stats (3,657 messages, 260 sessions, tool usage breakdown)
- Session type distribution, language breakdown, time-of-day patterns
- Satisfaction scores (96% satisfied or above)
- 70% full-success rate across sessions

## What to be skeptical of

The **qualitative friction narratives** overfit to a small number of incidents. The report
extrapolates 1-2 specific sessions into broad behavioral patterns and recommends sweeping
CLAUDE.md rules to fix them.

### "Misreading project state" — weaker than it looks

- The primary example (MCP server treated as a proposal) actually happened because the
  design doc was given to Claude **outside the project repo**, not because Claude misread
  state. That's a context/workflow issue, not a behavioral one.
- The second example (wrong branch reference) is a single incident.
- Two incidents across 260 sessions doesn't justify a top-level rule.

### "Propose, don't ask" — already covered

- The specific examples in the report appear to describe a single incident.
- The existing CLAUDE.md already instructs Claude to propose ("User drives — Claude
  proposes, user approves").
- A one-off failure to follow an existing instruction doesn't mean a new rule is needed.

### "Explain before editing" — unverified

- Not recalled as a recurring problem. May be the report interpreting early session exits
  or rejected tool calls as evidence of this pattern.

## Actionable: postToolUse type-check hook for dev repos

The most data-backed recommendation from the report is a `postToolUse` hook to auto-run
type checking after edits. 18 buggy code incidents, 25 command failures, and specific
import path / file extension mismatches are real, countable errors — not narrative
extrapolation.

**Important:** This hook belongs in individual dev repos (MCP server, Terrazzo plugins,
Storybook), not in this workflow repo. This repo is almost entirely Markdown — there's
nothing to type-check here.

Example for a TypeScript project's `.claude/settings.json`:

```json
{
  "hooks": {
    "postToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "npx tsc --noEmit 2>&1 | head -20"
      }
    ]
  }
}
```

Consider adding this as part of project scaffolding for new TypeScript repos.

## Declined: voice-note drafting skill

The report recommended formalizing the voice-note-to-content workflow as a dedicated skill
based on 12 sessions. But the actual workflow is **ideation capture, not content
production** — raw thinking spoken into Spokenly to avoid entering "editor mode" too
early. The action taken with the transcription varies every time (design doc, workflow
idea, dev approach, clarified thinking), so a standardized skill would add friction to
something that works because it's flexible.

Recurring doesn't mean uniform. A skill is the wrong fit when the input is consistent but
the desired output isn't.

## Takeaway

When evaluating future insights reports:

1. **Trust the numbers**, be skeptical of the narratives
2. **Cross-check specific examples** — do you actually remember the incident? Was the root
   cause what the report claims?
3. **Watch for single-incident extrapolation** — one bad session doesn't warrant a
   permanent behavioral rule
4. **Check existing instructions first** — the fix might already exist and just wasn't
   followed
