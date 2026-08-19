#!/usr/bin/env sh
set -eu

message="${1:-$(git log -1 --pretty=%s 2>/dev/null || true)}"
[ -z "$message" ] && exit 0
case "$message" in
  "✨ feat: "*|"🐛 fix: "*|"♻️ refactor: "*|"✅ test: "*|"📝 docs: "*|"🚀 infra: "*|"🔧 chore: "*|"⚡️ perf: "*|"🔒 security: "*) ;;
  *) echo "[FAIL] 커밋 제목 형식이 올바르지 않습니다: $message" >&2; exit 1 ;;
esac
