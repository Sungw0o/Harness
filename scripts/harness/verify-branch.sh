#!/usr/bin/env sh
set -eu
root="$(git rev-parse --show-toplevel)"
branch="${CI_COMMIT_REF_NAME:-$(git -C "$root" branch --show-current)}"
case "$branch" in
  main|dev) exit 0 ;;
  feat/ATH-[0-9]*-*|fix/ATH-[0-9]*-*|refactor/ATH-[0-9]*-*|test/ATH-[0-9]*-*|docs/ATH-[0-9]*-*|infra/ATH-[0-9]*-*|chore/ATH-[0-9]*-*|perf/ATH-[0-9]*-*|security/ATH-[0-9]*-*) exit 0 ;;
  feat/LOCAL-[0-9]*-*|fix/LOCAL-[0-9]*-*|refactor/LOCAL-[0-9]*-*|test/LOCAL-[0-9]*-*|docs/LOCAL-[0-9]*-*|infra/LOCAL-[0-9]*-*|chore/LOCAL-[0-9]*-*|perf/LOCAL-[0-9]*-*|security/LOCAL-[0-9]*-*) exit 0 ;;
  *) echo "[FAIL] 브랜치는 <type>/<ATH|LOCAL>-<num>-<kebab-case> 형식이어야 합니다: $branch" >&2; exit 1 ;;
esac
