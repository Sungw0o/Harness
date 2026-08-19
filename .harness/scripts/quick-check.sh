#!/usr/bin/env sh
set -eu

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$root"

pattern="$(grep -Ev '^[[:space:]]*(#|$)' "$root/.harness/secret-patterns.txt" | head -n 1)"
if [ -z "$pattern" ]; then
  echo "검사 실패: .harness/secret-patterns.txt 에서 패턴을 읽지 못했습니다." >&2
  exit 1
fi

files="$(git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard)"

for file in $files; do
  [ -f "$file" ] || continue
  case "$file" in
    .harness/secret-patterns.txt) continue ;;
    *.png|*.jpg|*.jpeg|*.gif|*.jar|*.class|*.lock) continue ;;
  esac
  if grep -Eniq -- "$pattern" "$file" 2>/dev/null; then
    echo "검사 실패: $file 에 하드코딩된 Secret 의심 값이 있습니다." >&2
    exit 1
  fi
done

echo "빠른 검사 통과"
