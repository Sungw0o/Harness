#!/usr/bin/env sh
set -eu
root="$(git rev-parse --show-toplevel)"
branch="${CI_COMMIT_REF_NAME:-$(git -C "$root" branch --show-current)}"
pattern='^(main|dev|(feat|fix|refactor|test|docs|infra|chore|perf|security)/(ATH|LOCAL)-[0-9]+(-[a-z0-9]+)+)$'
if printf '%s\n' "$branch" | grep -Eq "$pattern"; then
  exit 0
fi

echo "[FAIL] 브랜치는 <type>/<ATH|LOCAL>-<num>-<kebab-case> 형식이어야 합니다: $branch" >&2
exit 1
