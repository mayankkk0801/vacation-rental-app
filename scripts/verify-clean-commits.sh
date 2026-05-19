#!/usr/bin/env bash
# Fails if commit history contains blocked co-author trailers or agent emails.
set -euo pipefail

COAUTHOR_PATTERN='^co-authored-by:.*(cursor|cursoragent|cursor\.com|openai|anthropic|github-copilot)'

if git log --format=%B | grep -qiE "$COAUTHOR_PATTERN"; then
  echo "error: Found blocked Co-authored-by trailer in commit history." >&2
  exit 1
fi

if git log --format='%ae %ce' | grep -qiE 'cursor|cursoragent'; then
  echo "error: Found agent author/committer email in commit history." >&2
  exit 1
fi

echo "Commit history looks clean."
