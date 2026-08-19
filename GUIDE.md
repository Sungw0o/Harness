# C203 시작 가이드

팀원이 저장소를 받은 날 이 문서 하나로 개발을 시작할 수 있게 하는 퀵스타트다. 운영 상세는 [개발 하네스 가이드](docs/runbook/harness-guide.md), Jira·Release·Flyway 규칙은 [운영안](docs/runbook/jira-release-and-flyway.md)을 본다.

## 1. 최초 설정 (처음 1회)

필요 도구: Node.js 20.19+, Java 21, Python 3, Git.

```powershell
npm install                      # Git Hook 경로(.githooks) 자동 설정
npm --prefix frontend install
powershell -ExecutionPolicy Bypass -File scripts/harness/doctor.ps1   # 환경 진단
```

doctor가 전부 `[OK]`면 준비 완료다. `[FAIL]`이 있으면 항목의 안내대로 해결한 뒤 다시 실행한다. Linux/macOS는 `sh scripts/harness/doctor.sh`.

## 2. 작업 한 사이클

```text
작업 키 확정 → 브랜치 생성 → Work Log 시작 → 구현 → verify-all → MR
```

Jira가 아직 없으므로 작업 키는 `LOCAL-###`을 순서대로 쓴다. 브랜치와 Work Log 파일명은 반드시 같은 키를 쓴다 — 다르면 push가 차단된다.

```powershell
git switch -c feat/LOCAL-002-sign-up dev
python scripts/harness/task-log.py start LOCAL-002 "회원가입 기능" --domain member --work-type Feature
# ... 구현 ...
python scripts/harness/task-log.py finish LOCAL-002 "구현 완료" --verification "verify-all 통과"
powershell -ExecutionPolicy Bypass -File scripts/harness/verify-all.ps1   # MR 열기 전 1회
```

작업 중 기록은 "10분 이상 걸린 오류, 반복 실패, 설계 결정"만 `task-log.py checkpoint`로 남긴다. 단순 오타는 기록하지 않는다.

## 3. 컨벤션 요약

| 항목 | 형식 | 예시 |
| --- | --- | --- |
| 브랜치 | `<type>/<KEY>-<kebab-case>` | `feat/LOCAL-002-sign-up` |
| 커밋 | `<gitmoji> <type>: 명령형 요약` | `✨ feat: 회원가입 API 추가` |
| MR | 목적 하나, 300줄 이하 권장 | 템플릿 자동 적용 |

허용 type과 gitmoji: ✨ feat · 🐛 fix · ♻️ refactor · ✅ test · 📝 docs · 🚀 infra · 🔧 chore · ⚡️ perf · 🔒 security

`main`은 예외 없이 MR로만 병합한다. `dev` 직접 push는 30줄 이하 문서·오타·빌드 깨짐 수정에만 허용된다(조건과 절차: `dev-hotfix` Skill).

## 4. 품질 게이트

테스트 커버리지는 LINE 80% · BRANCH 70%를 CI가 강제한다. 로컬 확인:

```powershell
npm --prefix frontend run test:coverage
npm --prefix backend run test:coverage
```

미달이면 `test-coverage` Skill의 절차대로 의미 있는 테스트를 보강한다. 숫자를 채우기 위한 빈 테스트는 리뷰에서 반려된다.

검사는 계층별로 역할이 다르다: AI 훅과 Git Hook은 초 단위 검사(Secret, 컨벤션, Work Log)만 하고, 분 단위 검사(전체 테스트·빌드·커버리지)는 GitLab CI와 MR 전 `verify-all` 한 곳에서만 돈다. Hook이 실패하면 우회하지 말고 원인을 해결한다.

## 5. AI(Claude/Codex)와 작업할 때

저장소를 신뢰 모드로 열면 훅이 자동 적용된다. AI는 `AGENTS.md`(공통 규칙)와 작업 폴더의 `AGENTS.md`를 항상 읽고, 작업 종류에 맞는 `.agents/skills/`의 Skill만 추가로 읽는다.

| 작업 | Skill |
| --- | --- |
| 백엔드 기능·버그 | `backend-issue-workflow` |
| 프런트 화면·연동 | `frontend-issue-workflow` |
| API 계약 변경 | `api-contract-sync` |
| DB Schema 변경 | `db-migration` |
| MR 최종 점검 | `pr-check` |
| MR 리뷰 | `mr-review` |
| 커버리지 보강 | `test-coverage` |
| 장애 기록 | `troubleshooting-record` |
| dev 소규모 수정 | `dev-hotfix` |

## 6. 현재 보류 상태 (지급 대기)

| 항목 | 상태 | 지급 후 |
| --- | --- | --- |
| Jira | 미생성 → `LOCAL-###` 사용 | Key 컨벤션 확정 후 스크립트 패턴 전환 (`.agent/project.yml` 참고) |
| EC2·배포 | 비활성 | 체크리스트 검토 후 별도 인프라 작업으로 활성화 |
| PR-Agent | AI API Key 대기 | 그 전까지 `mr-review` Skill로 리뷰 |
| DB 엔진 | 미정 | 확정 시 드라이버·Flyway 모듈·Testcontainers 추가 |

절대 하지 않는 것: `.env`·키 파일 커밋, main·dev 강제 push, 적용된 Flyway migration 수정, 검증 실패를 성공으로 보고.
