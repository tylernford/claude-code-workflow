#!/usr/bin/env bash
REPO_SKILLS="$(dirname "$0")/../.claude/skills"
GLOBAL_SKILLS="$HOME/.claude/skills"
WORKFLOW_SKILLS=("design" "plan" "build" "document")

for skill in "${WORKFLOW_SKILLS[@]}"; do
  rm -rf "$GLOBAL_SKILLS/$skill"
  cp -R "$REPO_SKILLS/$skill" "$GLOBAL_SKILLS/$skill"
  echo "Synced: $skill"
done
