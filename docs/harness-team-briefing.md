# C203 AI 개발 하네스 팀 브리핑

> 대상: C203 팀원 전체 · 기준: 2026-08-19 부트스트랩 하네스<br>
> 목적: 하네스가 저장소에 어떻게 적용돼 있는지, 무엇이 팀 표준이고 무엇이 개인 선택인지 한 문서로 파악한다.

한 문장 요약:

> "이 하네스는 사람이든 AI든 같은 규칙으로 안전하게 개발하고 작업 근거를 남기게 하는 팀 공통 안전장치다. 속도는 AI가 내고, 일관성과 안전은 저장소가 지킨다."

---

## 1. 하네스가 저장소에 어떻게 적용되어 있는가

### 1.1 네 개의 층

| 층 | 위치 | 역할 |
| --- | --- | --- |
| 규칙 | `AGENTS.md`(공통), `frontend/AGENTS.md`, `backend/AGENTS.md`, `CLAUDE.md` | AI와 사람이 항상 따르는 짧은 규칙. 브랜치·커밋 컨벤션, 수정 범위, 보안, API 계약 |
| 상태·기록 | `.agent/` | 프로젝트 상태(`project.yml`: Jira·DB·EC2·품질 게이트), Work Log(`worklogs/*.jsonl`), 개선 backlog, 인수인계 노트, 템플릿 |
| 절차(Skill) | `.agents/skills/` | 작업 종류별 상세 절차 13종. 필요한 것만 읽어 컨텍스트를 아낀다 |
| 검사 | `.harness/` + `.claude/`·`.codex/` 훅 + `.githooks/` + `.gitlab-ci.yml` | 위험 작업 차단과 품질 게이트. 구현은 `.harness/scripts/` 한 벌을 모든 계층이 공유 |

### 1.2 검사는 언제 어떻게 도는가

원칙: **초 단위 검사는 로컬 여러 겹, 분 단위 검사는 CI 한 곳.** 같은 무거운 검사를 반복해 개발을 느리게 하지 않는다.

| 시점 | 검사 | 소요 |
| --- | --- | --- |
| AI 도구 실행 전 | `.env`·키 파일 접근, 파괴적 명령(force push, rm -rf, DROP) 차단 | ms |
| AI 파일 수정 직후 | 변경 파일 하드코딩 Secret 검사(`secret-patterns.txt` 단일 원본) | 초 |
| AI 작업 종료 | 변경 영역 lint·단위 테스트 (빌드 제외) | 초~수십 초 |
| pre-commit | Secret 파일·whitespace·빠른 검사 | 초 |
| commit-msg | `<gitmoji> <type>: 요약` 형식 검사 | ms |
| pre-push | 브랜치 형식·Work Log 존재·Secret (약 0.2초) | 초 |
| GitLab CI | Gitleaks, Work Log 계약, 테스트, **커버리지 게이트(LINE 80%·BRANCH 70%)**, 빌드 | 분 |

MR을 열기 전에는 `scripts/harness/verify-all`로 CI와 같은 전체 검증(커버리지 포함)을 로컬에서 1회 돌린다. 환경이 의심되면 `scripts/harness/doctor`로 진단한다.

### 1.3 작업 한 사이클

```text
작업 키 확정(LOCAL-### / Jira Key)
→ dev에서 <type>/<KEY>-<kebab> 브랜치
→ task-log.py start (브랜치와 같은 키)
→ 필요한 Skill·Notion 문서만 읽고 구현
→ 중요한 오류·결정만 checkpoint 기록
→ verify-all → MR → 리뷰 → Pipeline → squash merge to dev
```

브랜치·Work Log 키가 다르면 push가 차단된다. `main`은 예외 없이 MR로만, `dev` 직접 push는 30줄 이하 문서·오타·빌드 수정에만 허용된다(`dev-hotfix` Skill).

### 1.4 품질 게이트: 커버리지 80%

- 강제 주체는 CI다: 백엔드 JaCoCo(LINE 80%·BRANCH 70%, DTO·설정·엔트리포인트 제외), 프런트 Vitest thresholds.
- 로컬 확인: `npm --prefix frontend run test:coverage`, `npm --prefix backend run test:coverage`
- 숫자 채우기 테스트는 리뷰 반려 대상이다. 미달 시 `test-coverage` Skill 절차를 따른다.
- SonarQube는 EC2 지급 후 dev 브랜치 대시보드로 추가한다(게이트는 계속 CI가 담당).

---

## 2. Skill — 무엇이 있고 언제 읽는가

모든 Skill을 매번 읽지 않는다. 현재 작업에 해당하는 것만 읽는다.

### 구현

| Skill | 상황 |
| --- | --- |
| `backend-issue-workflow` | Spring Boot 기능·버그. 실패하는 테스트 먼저 작성 |
| `frontend-issue-workflow` | React 화면·연동. 테스트 먼저 + Playwright로 4상태(로딩·성공·빈 결과·오류) 실제 확인 |
| `api-contract-sync` | Controller·DTO·경로 변경 시 OpenAPI·프런트 타입 동기화 |
| `db-migration` | Entity·Schema 변경 시 Flyway migration과 호환성 검증 |

### 품질·리뷰

| Skill | 상황 |
| --- | --- |
| `pr-check` | MR 생성 전 최종 점검 |
| `mr-review` | MR diff 리뷰와 코멘트 초안 — PR-Agent(AI Key 지급 대기) 도입 전 대체 |
| `test-coverage` | 커버리지 게이트 미달 시 의미 있는 테스트 보강 |
| `safe-refactor` | 동작 변경 없는 구조 개선 — 테스트 그린에서만 시작 |
| `bug-hunt` | 원인 불명 버그 — 재현 최소화→가설 검증→회귀 테스트, 증상 패치 금지 |

### 기록·운영

| Skill | 상황 |
| --- | --- |
| `troubleshooting-record` | 10분+ 오류, 반복 실패를 재사용 가능한 지식으로 기록 |
| `improvement-backlog` | 범위 밖 개선(인덱스·캐시·쿼리·부하테스트·리팩터링 후보)은 구현 대신 `.agent/backlog/`에 기록 |
| `session-handoff` | 세션 종료·교대 시 `.agent/handoff/`에 인수인계 노트, 이어받을 때 먼저 읽기 |
| `dev-hotfix` | dev 직접 push 예외의 조건 확인과 실패 시 revert 절차 |

Skill을 새로 만들 때는 `docs/runbook/harness-guide.md`의 "Skill 추가 절차"(frontmatter + 4절 골격 + 표 갱신 + 리뷰 1인)를 따른다.

---

## 3. MCP·도구 — 무엇이 팀 표준인가

### 저장소에 선언된 팀 표준 (`.mcp.json` / `.codex/config.toml`)

| MCP | 용도 | 왜 표준인가 |
| --- | --- | --- |
| Notion | 요구사항·정책 조회, Work Log·Troubleshooting 동기화 | 프로젝트 지식의 단일 원본 |
| Playwright | 프런트 화면 4상태를 실제 브라우저로 검증, 추후 E2E smoke | 키리스·전원 재현 가능. "구현했다" 보고 대신 실제 확인 |

### 지급 대기 (조건 충족 시 활성화)

| 항목 | 조건 | 그 전 대체 |
| --- | --- | --- |
| Atlassian MCP (Jira) | Jira 프로젝트·권한 지급 | `LOCAL-###` 키 + 로컬 JSONL |
| PR-Agent | AI API Key 지급 | `mr-review` Skill |
| 배포 Job·SonarQube | EC2 지급 | CI 게이트까지만 운영 |

### 개인 선택 (팀 표준 아님)

| 도구 | 판단 | 주의 |
| --- | --- | --- |
| chrome-devtools MCP | 성능 트레이스·네트워크 디버깅 보조로 유용 | 자동화 표준은 Playwright 하나로 통일 |
| glif | 발표 자료용 미디어 생성 | 개인 로그인 필요 → 표준 불가 |
| firecrawl | 리서치·문서 수집 | **시세 등 외부 데이터를 스크래핑으로 기능에 넣는 것 금지**(AGENTS.md 규칙) |
| ponytail 등 최소 코드 플러그인 | 취향껏 사용 | 팀 표준은 AGENTS.md의 "최소 변경" 규칙 |
| superpowers 등 워크플로 플러그인 | 개인 사용 가능 | 하네스와 절차가 겹침 — **충돌하면 하네스 우선**(CLAUDE.md) |

---

## 4. 필수 vs 취사선택

### 필수 (전원, 예외 없음)

- Node.js 20.19+, Java 21, Python 3 설치 후 `npm install`(Git Hook 자동 설정)과 `doctor` 진단 통과
- 작업 키 = 브랜치 = Work Log 파일명 일치 (`<type>/<KEY>-<kebab>`)
- 커밋 컨벤션 `<gitmoji> <type>: 명령형 요약` (✨feat 🐛fix ♻️refactor ✅test 📝docs 🚀infra 🔧chore ⚡️perf 🔒security)
- `main`은 MR로만 병합, force push 금지, MR 전 `verify-all` 1회
- 커버리지 게이트(LINE 80%·BRANCH 70%) 통과
- Secret 규칙: `.env`·키 파일 커밋 금지, 실제 값은 `.env.example`에 쓰지 않음, 로그에 토큰·개인정보 금지
- Hook 우회(`--no-verify`) 금지, 검증 실패를 성공으로 보고하지 않기
- 적용된 Flyway migration 수정·삭제 금지
- 팀 표준 MCP(Notion, Playwright)는 프런트·요구사항 작업 시 사용

### 취사선택 (개인 자유, 단서 있음)

- AI 도구 자체: Claude든 Codex든 자유 — 훅과 CI가 같은 규칙을 적용한다
- chrome-devtools·glif·ponytail·superpowers 등 개인 MCP·플러그인 — 단, 하네스와 충돌하면 하네스 우선
- firecrawl 등 스크래핑 도구 — 리서치 한정, 기능 코드 사용 금지
- `dev-hotfix` 예외 절차 — 쓸지 말지는 자유지만 쓰려면 조건 5개 전부 충족
- Notion 동기화 시점 — 로컬 JSONL이 원본이므로 동기화가 늦어도 개발은 막히지 않음
- 에디터·터미널·OS — 자유 (Windows 한글 경로는 `backend/scripts/gradle.mjs`가 자동 대응)

---

## 5. 1분 요약

- 지금은 Jira·EC2·AI Key 지급 전 Bootstrap 단계다: `LOCAL-###` 키, 배포·PR-Agent 비활성.
- 시작은 `GUIDE.md` → 환경은 `doctor` → 상세는 `docs/runbook/harness-guide.md`.
- 작업 키·브랜치·Work Log를 같은 키로, 중요한 것만 기록, MR 전 `verify-all`.
- 커버리지 80%는 CI가 강제한다. 범위 밖 개선은 만들지 말고 `improvement-backlog`에 적는다.
- 팀 표준 MCP는 Notion과 Playwright 둘. 나머지 도구는 자유, 충돌 시 하네스가 이긴다.
