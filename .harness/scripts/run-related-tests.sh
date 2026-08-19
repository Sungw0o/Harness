#!/usr/bin/env sh
set -eu

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$root"

# 커밋 유무와 무관하게 동작하도록 status 기반으로 변경 파일을 수집한다.
changed="$(git status --porcelain=v1 2>/dev/null | cut -c4-)"
if [ -z "$changed" ]; then
  echo "변경 없음: 빠른 검사 건너뜀"
  exit 0
fi

# 분 단위 검사(build/bootJar/coverage)는 CI와 verify-all에서만 실행한다.
if printf '%s\n' "$changed" | grep -q '^frontend/'; then
  if [ -d frontend/node_modules ]; then
    (cd frontend && npm run lint && npm run test)
  else
    echo "프런트 검사 건너뜀: npm install이 필요합니다."
  fi
fi

if printf '%s\n' "$changed" | grep -q '^backend/'; then
  (cd backend && node scripts/gradle.mjs compileTestJava)
fi

echo "변경 영역 빠른 검사 통과"
