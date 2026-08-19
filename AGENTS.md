# C203 프로젝트 작업 규칙

## 프로젝트 개요

- 서비스: AI Trading Hunter — 주간 수익률 기반 AI·사용자 모의투자 리그
- 구조: React 프런트엔드 + Spring Boot 백엔드 모노레포
- 기본 브랜치: `dev`; 배포 기준 브랜치: `main`
- 기획 근거: Notion C203의 PRD, 요구사항 명세서, 정책 정의서, API 명세서

## 작업 전 순서

1. `.agent/workflow.md`, 이 파일, 작업 대상 폴더의 `AGENTS.md`를 읽는다.
2. 관련 Notion 원문과 API 계약을 읽는다. Jira가 활성화된 경우에만 Atlassian MCP로 유사 Issue를 확인한다.
3. 최신 `dev`에서 작업 키를 포함한 브랜치를 만들고 로컬 JSONL 로그를 시작한다. Jira 활성화 전에는 `LOCAL-###`, 활성화 후에는 Jira Key를 사용한다.
4. 작업 유형에 맞는 `.agents/skills/*/SKILL.md`를 읽는다.
5. 허용된 범위에서 최소 변경을 구현하고 의미 있는 문제·결정을 체크포인트로 기록한다.
6. 변경 영역의 lint, test, build와 Secret 검사를 통과한다.
7. Notion Work Log와 Jira를 갱신하고 MR에 변경, 검증, 위험과 미검증 항목을 기록한다.

## 브랜치·커밋

- Jira 활성화 전: `<type>/LOCAL-<num>-<kebab-case>` (예: `chore/LOCAL-001-project-bootstrap`)
- Jira 활성화 후: `<type>/<JIRA_KEY>-<kebab-case>` (예: `feat/ATH-123-order-create`)
- 허용 type: `feat`, `fix`, `refactor`, `test`, `docs`, `infra`, `chore`, `perf`, `security`
- 커밋: `<gitmoji> <type>: <명령형 요약>`
- `main`은 예외 없이 MR로만 병합한다(GitLab Protected Branch로 설정). force push는 모든 브랜치에서 금지한다.
- `dev` 직접 push는 다음을 모두 만족하는 소규모 수정에만 허용한다(상세 절차: `dev-hotfix` Skill): ① 문서·주석·오타 수정 또는 dev 빌드/CI를 깨뜨린 원인의 즉시 수정 ② 변경 30줄 이하 1커밋 ③ API·DB·의존성 계약 변경 없음 ④ 커밋 컨벤션 준수 ⑤ push 후 dev Pipeline 녹색 확인(실패 시 즉시 revert). 조건을 벗어나면 MR 절차를 따른다.
- MR 하나는 목적 하나, 300줄 이하를 권장하며 squash merge를 기본으로 한다.

## 수정 범위와 승인

- 일반 코드, 테스트, 개발 문서는 요청 범위에서 수정할 수 있다.
- 운영 설정, 배포 실행, DB migration 적용, CI credential, IAM/RBAC 변경은 사전 승인이 필요하다.
- 실제 `.env`, Secret, 토큰, 키, 인증서, 개인정보를 읽거나 출력하거나 커밋하지 않는다.
- `git reset --hard`, force push, 광범위 삭제, 운영 DB write/DDL을 실행하지 않는다.
- 문서와 코드 계약이 다르면 임의로 선택하지 말고 불일치로 보고한다.
- EC2 지급 전에는 배포 Job, 실제 호스트, SSH Key, 운영 환경변수 주입을 추가하거나 실행하지 않는다.
- EC2 지급 후에도 배포 활성화는 별도 인프라 작업과 사용자 승인을 통해 진행한다.

## 공통 계약

- API prefix는 `/api/v1`을 사용한다.
- API 경로는 복수 자원명과 `kebab-case`를 사용하고 행위는 HTTP Method로 표현한다.
- 성공 응답은 `{ "data": ..., "meta": null }`, 실패 응답은 `{ "error": { "code", "message", "fieldErrors" }, "traceId": "..." }` 형태를 사용한다.
- API 변경 시 OpenAPI와 계약 테스트를 같은 MR에서 수정한다.
- Entity·Schema 변경 시 Flyway migration과 호환성 계획을 포함한다.
- `.env.example`에는 이름과 설명만 두고 실제 값은 넣지 않는다.
- 로그에 비밀번호, 토큰, API Key, 개인정보를 남기지 않는다.

## 검증

```powershell
npm run verify
```

MR을 열기 전에는 `scripts/harness/verify-all`을 1회 실행한다. 테스트 커버리지 게이트(LINE 80%·BRANCH 70%)는 CI와 verify-all이 강제하며, 미달 시 `test-coverage` Skill을 사용한다.

완료 보고에는 변경 파일과 이유, 실행한 검증과 결과, 남은 위험과 미검증 항목을 포함한다.
