#!/usr/bin/env sh
set -eu

input="$(cat)"
# .env.example은 허용 대상이므로 먼저 제거하고, 따옴표를 공백으로 바꿔
# "cat .env" 같은 맨 파일명도 경계 검사에 걸리게 한다.
sanitized="$(printf '%s' "$input" | sed "s/\.env\.example//g; s/[\"']/ /g")"

if printf '%s' "$sanitized" | grep -Eiq '(^|[/\\[:space:] =(])\.env([.][a-z0-9_-]+)?([^a-z0-9_.-]|$)|[.](pem|key|p12|jks)([^a-z0-9_-]|$)'; then
  echo "차단: Secret 또는 실제 환경 파일을 읽거나 수정할 수 없습니다." >&2
  exit 2
fi

if printf '%s' "$input" | grep -Eiq 'git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+push([^\n]*)(--force|-f([[:space:]]|$))|git[[:space:]]+clean([^\n]*)-[a-z]*f|git[[:space:]]+branch[[:space:]]+-D([[:space:]]|$)|git[[:space:]]+(checkout|restore)[[:space:]]+--|rm[[:space:]]+-[a-z]*r[a-z]*|remove-item([^\n]*)-(recurse|r)([[:space:]]|$)|(rd|rmdir)[[:space:]]+/s([[:space:]]|$)|drop[[:space:]]+(database|schema|table)|kubectl([^\n]*)[[:space:]]+delete'; then
  echo "차단: 파괴적 Git, 파일, DB 또는 인프라 명령은 승인 없이 실행할 수 없습니다." >&2
  exit 2
fi
