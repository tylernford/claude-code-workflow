# Workflow Notes

Process learnings and improvements discovered while using the design → plan → build → document workflow.

---

## 2026-01-27: Document phase serves two distinct purposes

Context: The Document phase can feel like busywork — just filling in completion sections. But it serves two non-obvious functions beyond record-keeping.

Purpose 1: Catches drift
Comparing the original plan to what was actually built surfaces deviations that should be recorded. Implementation often requires adapting to discovered realities — different library versions, APIs that work differently than expected, approaches that turned out to be unnecessary. These aren't failures; they're adaptations. The Document phase ensures they're captured rather than lost.

Purpose 2: Updates the onboarding path
Implementation changes often affect how new developers set up or use the project. Without updating the README during documentation, the next person to clone the repo won't know about new setup steps, changed commands, or added dependencies.

Takeaway: Don't treat /document as just "fill in the completion section." It's the checkpoint that ensures both the historical record and the living documentation (README) stay accurate.
