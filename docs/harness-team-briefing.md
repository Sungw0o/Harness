# C203 AI 개발 하네스 팀 브리핑

> 발표 대상: C203 팀원 전체<br>
> 권장 시간: 설명 12분 + 데모 3분 + 질문 5분<br>
> 발표 목표: 팀원이 하네스의 목적을 이해하고 다음 작업부터 같은 방식으로 시작·기록·검증할 수 있게 한다.

---

## 발표 전에 먼저 말할 한 문장

> “이 하네스는 AI를 더 많이 쓰기 위한 장치가 아니라, 사람이든 AI든 같은 규칙으로 안전하게 개발하고 작업 근거를 남기기 위한 팀 공통 안전장치입니다.”

---

## 1. 왜 하네스가 필요한가

AI에게 단순히 “이 기능 만들어줘”라고 지시하면 빠르게 코드를 만들 수 있다. 하지만 팀 프로젝트에서는 다음 문제가 생긴다.

- AI마다 프로젝트 구조와 컨벤션을 다르게 해석한다.
- 요구사항이나 API 명세를 읽지 않고 코드를 수정할 수 있다.
- `.env`, Secret, 운영 설정 같은 민감한 파일을 잘못 다룰 수 있다.
- 테스트하지 않은 코드를 완료했다고 보고할 수 있다.
- 오류를 어떻게 해결했는지 다음 사람에게 남지 않는다.
- Jira, Notion, GitLab의 정보가 서로 끊어진다.

하네스는 이 문제를 프롬프트가 아니라 저장소의 규칙과 자동 검사로 해결한다.

### 발표자 멘트

“매번 AI에게 컨벤션과 주의사항을 길게 설명하는 대신 저장소가 그 규칙을 기억하게 만들었습니다. AI를 믿어서 자동화한 것이 아니라, 실수할 수 있다는 전제로 여러 겹의 안전장치를 둔 겁니다.”

---

## 2. 현재 프로젝트 상태

현재는 본격적인 기능 개발 전 Bootstrap 단계다.

| 항목 | 현재 상태 | 지금 하는 일 |
| --- | --- | --- |
| 프런트엔드 | 준비 완료 | React 19 + TypeScript + Vite 골격 |
| 백엔드 | 준비 완료 | Java 21 + Spring Boot 4.1 골격 |
| Notion | 일부 사용 가능 | 요구사항 조회, 추후 Work Log DB 연결 |
| Jira | 미생성 | `LOCAL-###` 임시 작업 키 사용 |
| EC2 | 미지급 | 배포 기능 비활성화 |
| GitLab CI | 개발 검증만 구성 | Secret, Work Log, test, build 검사 |

지금은 배포보다 개발 규칙과 검증 기반을 먼저 고정하는 단계다.

### 발표자 멘트

“Jira와 EC2가 아직 없기 때문에 있는 것처럼 가정하지 않았습니다. Jira 전에는 LOCAL 키로 작업을 이어가고, EC2 전에는 배포 코드를 만들지 않습니다. 지급받은 뒤 체크리스트를 따라 안전하게 활성화합니다.”

---

## 3. 각 도구의 역할

| 도구 | 담당 역할 |
| --- | --- |
| Jira | 활성화 후 작업 범위, 담당자, 상태의 기준 |
| Notion | 기획, 요구사항, 설계 결정, Work Log, Troubleshooting |
| GitLab | 코드, Commit, MR, Pipeline 결과 |
| 로컬 JSONL | 개발 중 오류·시도·결정·검증의 임시 원본 |

한 도구에 모든 정보를 몰아넣지 않는다.

- “무엇을 해야 하는가?” → Jira
- “왜 이렇게 결정했는가?” → Notion
- “실제로 무엇이 바뀌고 검증됐는가?” → GitLab
- “개발 도중 무슨 일이 있었는가?” → 로컬 JSONL

### 발표자 멘트

“Jira는 업무 관리, Notion은 지식 관리, GitLab은 코드와 검증을 담당합니다. 같은 내용을 세 곳에 복사하는 게 아니라 각 도구가 가장 잘하는 역할만 맡깁니다.”

---

## 4. 전체 작업 흐름

```text
작업 요청
→ Jira 사용 가능 여부 확인
→ LOCAL 키 또는 Jira Key 확정
→ 브랜치와 Work Log 시작
→ 필요한 Notion 문서와 Skill만 조회
→ 코드 수정
→ 의미 있는 문제와 결정을 체크포인트로 기록
→ lint · test · build · Secret 검사
→ MR 생성
→ Notion과 Jira 상태 갱신
```

중요한 점은 AI가 바로 코드를 수정하지 않는다는 것이다. 먼저 근거 문서, 작업 범위, 허용 영역과 검증 방법을 확인한다.

### 발표자 멘트

“작업 요청과 코드 수정 사이에 준비 단계가 있습니다. 이 준비 단계 덕분에 요구사항 누락과 엉뚱한 범위 수정을 줄일 수 있습니다.”

---

## 5. Jira가 생기기 전 작업 방법

Jira가 아직 없으므로 `LOCAL-###` 형식의 작업 키를 사용한다.

```text
chore/LOCAL-001-project-bootstrap
docs/LOCAL-002-harness-guide
infra/LOCAL-003-ci-guard
```

로컬 Work Log 파일명도 같은 키를 사용한다.

```text
.agent/worklogs/LOCAL-002.jsonl
```

Jira가 생성되면 기존 파일을 지우거나 이름을 바꾸지 않는다. Notion과 새 Jira Issue에 다음과 같이 매핑만 남긴다.

```text
LOCAL-002 → ATH-15
```

이후 새 작업부터 실제 Jira Key를 사용한다.

### 발표자 멘트

“Jira가 없다고 기록을 포기하지 않고 임시 키를 씁니다. 나중에 Jira가 생기면 기존 기록은 보존하고 연결 관계만 추가합니다.”

### Jira가 생긴 뒤의 구조

- 기본 계층은 `Epic → Task/Story` 2단계로 유지한다.
- Frontend, Backend, Database, Infra는 폴더가 아니라 Component로 분류한다.
- Jira Release는 MR마다 만들지 않고 스프린트 시연 또는 배포 후보마다 하나만 만든다.
- GitLab Release는 EC2 실제 배포가 성공한 Tag에만 만든다.

“MR은 변경 단위이고 Release는 배포 단위입니다. MR이 수백 건이어도 Release를 수백 개 만들지 않습니다.”

---

## 6. Work Log에는 무엇을 기록하는가

모든 행동을 기록하지 않는다. 다음과 같이 재사용 가치가 있는 내용만 남긴다.

### 기록하는 것

- 10분 이상 해결되지 않은 오류
- 같은 접근이 두 번 이상 실패한 경우
- 설계, 데이터 모델, API 계약 변경
- 외부 API의 제한이나 비정상 동작
- 테스트 또는 CI 실패
- 보안, 성능, 정합성 문제
- 임시 해결책과 기술 부채

### 기록하지 않는 것

- 단순 오타
- 즉시 해결된 import 오류
- 의미 없는 컴파일 오류 반복
- 최종 결과와 관계없는 대화
- Token, Secret, 개인정보, 인증 헤더, DB 비밀번호

### 사용 예시

```powershell
python scripts/harness/task-log.py start LOCAL-002 "하네스 발표 문서 작성" `
  --domain platform --work-type Docs

python scripts/harness/task-log.py checkpoint LOCAL-002 DECISION `
  "Jira 지급 전에는 LOCAL 작업 키를 사용함"

python scripts/harness/task-log.py finish LOCAL-002 "문서 작성 완료" `
  --verification "Markdown 및 하네스 검사 통과"
```

### 발표자 멘트

“로그를 많이 남기는 것이 목표가 아닙니다. 다음 사람이 같은 실패를 반복하지 않게 만드는 정보만 남깁니다. 단순 오타까지 기록하면 중요한 내용이 묻히기 때문입니다.”

---

## 7. 폴더별 역할

```text
AGENTS.md                 모든 Agent가 항상 따르는 공통 규칙
frontend/AGENTS.md        React 전용 규칙
backend/AGENTS.md         Spring Boot 전용 규칙

.agent/                   프로젝트 상태·워크플로·Work Log
.agents/skills/           작업 종류별 상세 절차
.harness/                 위험 작업과 Secret 검사 구현
scripts/harness/          작업 시작·기록·완료·검증 명령

.claude/                  Claude Hook 설정
.codex/                   Codex Hook·MCP 설정
.githooks/                commit/push 직전 검사
.gitlab-ci.yml            서버에서 실행하는 최종 검사
```

### `.agent`와 `.agents`가 다른 이유

- `.agent`: 프로젝트 상태와 작업 기록
- `.agents`: 필요할 때 선택해서 읽는 Skill

항상 필요한 규칙은 짧게 유지하고, 긴 절차는 작업별 Skill로 분리해 AI의 컨텍스트와 토큰을 절약한다.

### 발표자 멘트

“점 하나 차이라 헷갈릴 수 있습니다. 단수 agent는 프로젝트 운영 데이터, 복수 agents는 재사용 가능한 작업 매뉴얼이라고 기억하면 됩니다.”

---

## 8. 어떤 Skill을 사용하는가

| 작업 | Skill |
| --- | --- |
| Spring Boot 기능·버그 | `backend-issue-workflow` |
| React 화면·API 연동 | `frontend-issue-workflow` |
| Controller·DTO·API 변경 | `api-contract-sync` |
| Entity·Schema 변경 | `db-migration` |
| 의미 있는 장애 기록 | `troubleshooting-record` |
| MR 생성 전 점검 | `pr-check` |

모든 Skill을 매번 읽지 않고 현재 작업에 필요한 것만 읽는다.

### 발표자 멘트

“백엔드 작업을 하는데 프런트 작업 절차까지 전부 읽으면 오히려 AI가 산만해집니다. 필요한 Skill만 선택해서 품질은 유지하고 컨텍스트는 줄입니다.”

---

## 9. 안전장치는 여러 겹으로 동작한다

| 시점 | 안전장치 |
| --- | --- |
| AI 명령 실행 전 | 위험 명령과 Secret 파일 접근 차단 |
| 파일 수정 직후 | 하드코딩 Secret 검사 |
| 작업 종료 | 변경 영역 lint·단위 테스트 |
| commit 전 | Secret 파일과 whitespace 검사 |
| commit 메시지 작성 | Gitmoji + type 컨벤션 검사 |
| push 전 | 브랜치, Work Log, Secret 검사 |
| GitLab Pipeline | Gitleaks, Work Log 계약, test, 커버리지 80% 게이트, build |

AI Hook이 실행되지 않는 환경도 있을 수 있으므로 Git Hook과 GitLab CI가 최종 검사를 담당한다.

### 절대 자동 실행하지 않는 것

- 운영 DB 변경
- 배포와 Rollback
- CI Credential 변경
- IAM/RBAC 변경
- force push, `git reset --hard`, 광범위 삭제
- 실제 `.env`, PEM, SSH Private Key 읽기·출력·커밋

### 발표자 멘트

“한 단계가 빠져도 다음 단계가 막도록 방어층을 겹쳤습니다. 특히 운영과 Secret 관련 작업은 하네스가 있다고 자동 허용되는 것이 아니라 반드시 사람의 승인이 필요합니다.”

---

## 10. EC2를 지급받기 전과 후

### 현재: EC2 지급 전

GitLab CI는 다음 단계까지만 수행한다.

```text
guard → test → build
```

현재 하지 않는 것:

- EC2 접속과 SSH 배포
- 운영 `.env` 주입
- Docker Image 운영 배포
- Nginx·도메인·인증서 실제 설정
- 운영 Smoke Check와 Rollback

### EC2 지급 후

다음 내용을 먼저 확인한다.

1. 인스턴스 OS·사양·리전
2. 도메인과 외부 접근 방식
3. 최소 권한 SSH 배포 계정
4. GitLab CI Variable과 Secret 저장 위치
5. Docker Compose·Nginx·애플리케이션 포트
6. `/actuator/health` 기반 Readiness와 Smoke Check
7. 실패 조건과 Rollback 방법
8. 로그·메트릭·디스크·백업 정책

별도 인프라 작업과 리뷰를 거쳐 Smoke·Rollback 테스트가 끝난 뒤에만 배포를 활성화한다.

### 발표자 멘트

“EC2를 받았다고 바로 SSH 스크립트부터 만드는 게 아닙니다. 접근 정책과 Secret 저장 방식, 실패했을 때 되돌리는 방법까지 먼저 결정한 뒤 배포를 켭니다.”

---

## 11. 팀원이 실제로 해야 하는 것

### 작업 시작 전

- `dev`를 최신 상태로 갱신한다.
- 다음 `LOCAL-###` 또는 Jira Key를 확인한다.
- 브랜치와 Work Log를 같은 키로 만든다.
- 관련 Notion 문서와 필요한 Skill만 읽는다.

### 작업 중

- 요청 범위를 벗어나지 않는다.
- 중요한 오류와 설계 결정만 기록한다.
- API·DB 계약 변경 시 문서와 테스트를 함께 수정한다.
- Secret과 개인정보를 로그에 남기지 않는다.

### 작업 완료 전

```powershell
powershell -ExecutionPolicy Bypass -File scripts/harness/verify-all.ps1
```

- 검증 결과를 Work Log에 남긴다.
- Notion과 Jira가 활성화된 범위에서 상태를 갱신한다.
- MR 템플릿에 변경, 검증, 위험과 미검증 항목을 작성한다.

### 발표자 멘트

“팀원이 외워야 하는 것은 많지 않습니다. 작업 키 맞추기, 중요한 것만 기록하기, 마지막에 전체 검증하기—이 세 가지가 핵심입니다.”

---

## 12. 3분 데모 순서

### 1단계: 작업 시작

```powershell
python scripts/harness/task-log.py start LOCAL-010 "하네스 데모" `
  --domain platform --work-type Spike
```

`.agent/worklogs/LOCAL-010.jsonl`이 생성되는 것을 보여준다.

### 2단계: 결정 기록

```powershell
python scripts/harness/task-log.py checkpoint LOCAL-010 DECISION `
  "Jira 활성화 전 LOCAL 키를 사용함"
```

JSONL에 기존 내용을 덮어쓰지 않고 한 줄이 추가되는 것을 보여준다.

### 3단계: 검증

```powershell
python scripts/harness/verify-worklog.py --branch docs/LOCAL-010-harness-demo
```

정상 통과 후 다른 번호의 브랜치를 넣어 Work Log 누락이 차단되는 것도 보여준다.

```powershell
python scripts/harness/verify-worklog.py --branch docs/LOCAL-011-missing-log
```

### 4단계: 완료

```powershell
python scripts/harness/task-log.py finish LOCAL-010 "데모 완료" `
  --verification "Work Log 검증 통과"
```

데모 후 생성한 `LOCAL-010.jsonl`은 실제 작업 로그가 아니므로 삭제한다.

---

## 13. 예상 질문과 답변

### Q. 기록 때문에 개발이 더 느려지지 않나요?

모든 행동을 기록하지 않는다. 오래 걸린 오류, 반복 실패, 설계 결정처럼 다시 사용할 가치가 있는 내용만 기록한다. 같은 문제를 반복해서 조사하는 시간을 줄이는 것이 목표다.

### Q. Notion이 안 되면 개발을 못 하나요?

아니다. 로컬 JSONL을 먼저 저장하므로 개발과 코드 검증은 계속할 수 있다. Notion은 연결이 복구된 뒤 마지막 체크포인트부터 동기화한다.

### Q. AI가 Hook을 우회하면 어떻게 하나요?

Git Hook과 GitLab CI가 다시 검사한다. 코드·테스트·보안 실패는 Pipeline에서 병합을 막는다.

### Q. Jira가 생기면 LOCAL 로그는 어떻게 하나요?

삭제하거나 이름을 바꾸지 않는다. `LOCAL-002 → ATH-15`처럼 Jira와 Notion에 매핑을 남긴다. 새 작업부터 Jira Key를 쓴다.

### Q. EC2를 받으면 바로 자동 배포가 되나요?

아니다. 접근 정책, Secret, Health Check, Smoke Test, Rollback이 준비되고 리뷰된 뒤 별도 인프라 작업으로 활성화한다.

### Q. Hook이 실패하면 급할 때 건너뛰어도 되나요?

우회하지 않는다. 실행할 수 없는 검증은 성공으로 처리하지 않고 원인과 남은 위험을 MR에 기록한다.

---

## 14. 마무리

하네스의 목표는 규칙을 늘리는 것이 아니라 팀의 반복 비용과 사고 가능성을 줄이는 것이다.

팀원이 기억할 세 가지:

1. **같은 작업 키를 브랜치와 Work Log에 사용한다.**
2. **중요한 오류와 설계 결정만 기록한다.**
3. **MR 전에 전체 Harness 검증을 실행한다.**

> “속도는 AI가 높이고, 일관성과 안전은 하네스가 지킨다.”

---

## 팀 공유용 1분 요약

- 현재 Jira가 없으므로 `LOCAL-###` 키를 사용한다.
- EC2가 없으므로 배포는 비활성화돼 있다.
- 작업 시작 시 브랜치와 JSONL Work Log를 같은 키로 만든다.
- 중요한 오류·반복 실패·설계 결정만 기록한다.
- `AGENTS.md`는 항상 읽고 작업별 Skill은 필요할 때만 읽는다.
- Hook → Git Hook → GitLab CI 순서로 위험 작업과 품질을 검사한다.
- MR 전 `scripts/harness/verify-all`을 실행한다.
- Jira와 EC2는 지급 후 전환 체크리스트를 거쳐 활성화한다.
