#!/usr/bin/env sh
# C203 하네스 환경 진단. 온보딩 첫 단계와 훅 이상 의심 시 실행한다.
# 사용: sh scripts/harness/doctor.sh
fail=0
ok()   { printf '[OK]   %s\n' "$1"; }
bad()  { printf '[FAIL] %s\n' "$1"; fail=1; }

root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$root" ] && ok "Git 저장소: $root" || bad "Git 저장소가 아닙니다."
cd "${root:-.}"

# 1. 도구 버전
node_v="$(node --version 2>/dev/null || true)"
case "$node_v" in
  v2[1-9].*|v[3-9][0-9].*|v20.19*|v20.[2-9][0-9].*) ok "Node $node_v" ;;
  "") bad "Node.js가 없습니다 (20.19 이상 필요)." ;;
  *) bad "Node $node_v — 20.19 이상이 필요합니다." ;;
esac

java -version 2>&1 | grep -q '"21' && ok "Java 21" || bad "Java 21이 필요합니다: $(java -version 2>&1 | head -n 1 || echo '없음')"
python_command="$(command -v python 2>/dev/null || command -v python3 2>/dev/null || true)"
python_v="$(${python_command:-false} --version 2>&1 || true)"
case "$python_v" in
  "Python 3."*) ok "$python_v" ;;
  *) bad "Python 3이 필요합니다." ;;
esac

# 2. Git Hook 경로
hooks="$(git config --get core.hooksPath || true)"
[ "$hooks" = ".githooks" ] && ok "core.hooksPath=.githooks" || bad "core.hooksPath가 .githooks가 아닙니다 (npm install 실행)."

# 3. 의존성 설치 상태
[ -d frontend/node_modules ] && ok "frontend/node_modules" || bad "frontend npm install이 필요합니다."

# 4. guard 훅 동작 (차단이 정상)
if printf '%s' '{"command":"cat .env"}' | sh .harness/scripts/guard.sh >/dev/null 2>&1; then
  bad "guard가 .env 접근을 차단하지 못했습니다."
else
  ok "guard가 .env 접근을 차단합니다."
fi
if printf '%s' '{"command":"ls src"}' | sh .harness/scripts/guard.sh >/dev/null 2>&1; then
  ok "guard가 정상 명령을 통과시킵니다."
else
  bad "guard가 정상 명령까지 차단합니다."
fi

# 5. Secret 패턴 파일
grep -Evq '^[[:space:]]*(#|$)' .harness/secret-patterns.txt && ok "secret-patterns.txt 패턴 존재" || bad "secret-patterns.txt에 패턴이 없습니다."

# 6. 참고: Claude/Codex 프로젝트 훅은 저장소를 신뢰한 상태에서 열어야 동작한다.
echo
if [ "$fail" -eq 0 ]; then echo "진단 통과: 하네스 사용 준비 완료."; else echo "진단 실패 항목을 해결한 뒤 다시 실행하세요."; exit 1; fi
