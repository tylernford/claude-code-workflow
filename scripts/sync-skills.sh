#!/usr/bin/env bash
REPO_SKILLS="$(dirname "$0")/../.claude/skills"
GLOBAL_SKILLS="$HOME/.claude/skills"

# Skills in this repo to NOT sync globally. Empty by default — every skill dir
# under .claude/skills/ is synced (auto-discovered, so adding a skill needs no
# edit here). Add a skill's basename to exclude just that one.
IGNORE_SKILLS=()

for dir in "$REPO_SKILLS"/*/; do
  skill="$(basename "$dir")"

  for ignored in "${IGNORE_SKILLS[@]}"; do
    if [[ "$skill" == "$ignored" ]]; then
      echo "Skipped: $skill"
      continue 2
    fi
  done

  rm -rf "$GLOBAL_SKILLS/$skill"
  cp -R "$dir" "$GLOBAL_SKILLS/$skill"
  echo "Synced: $skill"
done
