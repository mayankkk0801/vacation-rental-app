#!/bin/sh
# Removes unwanted Co-authored-by trailers from commit messages.
set -eu

MSG_FILE="${1:?commit message file required}"
[ -f "$MSG_FILE" ] || exit 0

PATTERN='^co-authored-by:.*(cursor|cursoragent|cursor\.com|openai|anthropic|github-copilot)'

if ! grep -qiE "$PATTERN" "$MSG_FILE"; then
  exit 0
fi

tmp="${MSG_FILE}.strip-coauthor"
grep -viE "$PATTERN" "$MSG_FILE" >"$tmp" || true
mv "$tmp" "$MSG_FILE"
echo "Removed automated co-author trailer from commit message." >&2
