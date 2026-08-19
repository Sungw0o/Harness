# C203 Monorepo

AI Trading Hunter 개발 전용 골격입니다. React 프런트엔드와 Spring Boot 백엔드를 한 저장소에서 관리하며, Limit 프로젝트의 Agent Harness를 C203 규칙에 맞게 적용했습니다.

## 구성

- `frontend/`: React 19 + TypeScript + Vite
- `backend/`: Java 21 + Spring Boot 4.1 + Gradle Wrapper
- `.agents/skills/`: 필요할 때만 읽는 공통 작업 절차
- `.agent/`: Jira·Notion Work Log 워크플로, 스키마와 템플릿
- `.harness/scripts/`: Claude/Codex/Git Hook이 공유하는 검사 구현
- `scripts/harness/`: 작업 시작·체크포인트·완료와 Convention 검증 도구
- `.githooks/`: 커밋·푸시 전 로컬 품질 게이트
- `.gitlab-ci.yml`: 서버 측 최종 품질 게이트
- `docs/`: ADR, API 계약, Runbook

처음 시작한다면 [C203 시작 가이드](GUIDE.md)를 먼저 읽으세요.

전체 운영 방법은 [C203 개발 하네스 가이드](docs/runbook/harness-guide.md)를 참고하세요.

팀 설명용 자료는 [C203 AI 개발 하네스 팀 브리핑](docs/harness-team-briefing.md)을 참고하세요.

Jira 구조, Release와 Flyway 규칙은 [Jira·Release·Flyway 운영안](docs/runbook/jira-release-and-flyway.md)을 참고하세요.

## 시작하기

Node.js 20.19 이상과 Java 21이 필요합니다.

```powershell
npm install
npm --prefix frontend install
npm run dev
```

- 프런트엔드: http://localhost:5173
- 백엔드 상태 확인: http://localhost:8080/actuator/health

## 검증

```powershell
npm run verify
```

최초 `npm install` 시 Git Hook 경로가 `.githooks`로 자동 설정됩니다.

## 브랜치와 커밋

- Jira 생성 전 브랜치: `chore/LOCAL-001-project-bootstrap`
- Jira 생성 후 브랜치: `feat/ATH-123-short-description`
- 커밋: `✨ feat: 기능 설명`
- 모든 작업은 `dev`에서 분기하고 MR을 통해 병합합니다.

## Jira·Notion Work Log

```powershell
python scripts/harness/task-log.py start LOCAL-001 "프로젝트 부트스트랩" --domain platform --work-type Chore
python scripts/harness/task-log.py checkpoint LOCAL-001 DECISION "하네스 구조 확정"
python scripts/harness/task-log.py finish LOCAL-001 "구현 완료" --verification "test/build 통과"
python scripts/harness/verify-worklog.py
```

Jira가 생성되기 전에는 `LOCAL-###`, 생성된 후에는 실제 Jira Key를 사용합니다. 로컬 로그는 `.agent/worklogs/{WORK_KEY}.jsonl`에 append-only로 저장합니다.
