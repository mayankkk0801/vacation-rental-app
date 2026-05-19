#!/usr/bin/env bash
# Enable repo git hooks that strip automated co-author trailers from commits.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

chmod +x .githooks/pre-commit .githooks/commit-msg .githooks/prepare-commit-msg .githooks/strip-coauthor-trailers.sh
git config --local core.hooksPath .githooks

echo "Git hooks enabled (core.hooksPath=.githooks)."
echo "Run ./scripts/verify-clean-commits.sh before pushing to confirm history is clean."
