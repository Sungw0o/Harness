# Jira·Release·Flyway 운영안

이 문서는 C203에서 MR이 많이 발생해도 Jira와 Release가 관리 부담이 되지 않도록 하는 최소 운영 규칙이다. 첨부 교육 자료의 Git/Jira 개념을 참고하되, 프로젝트의 실제 기준은 이 문서와 저장소 하네스다.

## 1. 결론

- Jira Issue와 MR은 작업 추적 단위다.
- Jira Release는 MR마다 만들지 않고 스프린트 시연 또는 배포 후보 묶음마다 하나만 만든다.
- GitLab Release는 EC2에 배포한 검증된 Git Tag에만 만든다.
- DB 변경은 Flyway versioned migration으로 관리한다.
- Jira가 생기기 전에는 기존처럼 `LOCAL-###`을 사용하고 Release 기능은 활성화하지 않는다.

즉, 수백 개의 MR이 생겨도 Release 수는 스프린트 수 또는 실제 배포 횟수 정도만 증가한다.

## 2. Jira 구조

Jira에는 파일 시스템 같은 폴더 계층을 만들지 않는다. 다음 두 축으로 찾는다.

### 업무 계층: 2단계 기본

```text
Epic: 회원/인증
├── Task: 회원가입 API 구현
├── Task: 로그인 화면 구현
└── Task: 토큰 재발급 처리
```

- Epic: 사용자 가치나 큰 기능 영역
- Task: 한 명이 하나의 MR로 완료 가능한 구현 단위
- Story: 사용자 관점 표현이 실제로 도움이 될 때만 Task 대신 사용
- Sub-task: 담당자가 다르거나 독립적으로 상태 추적해야 할 때만 예외적으로 사용

교육 자료의 `Epic → Story → Task` 구조는 개념 이해에는 유효하지만, C203에서는 스토리 포인트 중복과 보드 복잡도를 피하기 위해 기본 2단계를 사용한다.

### 기술 분류: Component

초기 Component는 네 개만 둔다.

| Component | 범위 |
| --- | --- |
| Frontend | React UI, 상태, 브라우저 API 연동 |
| Backend | Spring Boot API, 도메인 로직 |
| Database | Schema, Flyway, 쿼리, 데이터 정합성 |
| Infra | CI/CD, EC2, 네트워크, 모니터링 |

Component를 폴더처럼 계속 세분화하지 않는다. 기능 영역은 Epic, 기술 영역은 Component로 구분한다.

## 3. Jira Issue 컨벤션

### 제목

```text
회원가입 API 구현
WebSocket 재연결 오류 수정
주문 테이블 생성
```

`[BE]`, `[FE]` 같은 접두사는 Component와 중복되므로 제목에 넣지 않는다.

### 필수 필드

- Epic
- Component
- 담당자
- 우선순위
- Story Point: 1, 2, 3, 5 중 하나. 8 이상이면 분할 검토
- 완료 조건
- API/DB 변경 여부
- 관련 Notion 문서 또는 Work Log

### 연결 규칙

```text
브랜치: feat/ATH-123-sign-up
MR 제목: ✨ feat: ATH-123 회원가입 API 구현
Flyway: V0012__ATH_123_create_member_table.sql
```

하나의 Jira Issue에 여러 MR이 필요할 수는 있지만, 각 MR은 독립적으로 검토·되돌리기 가능한 크기로 유지한다. 반대로 서로 무관한 여러 Issue를 하나의 MR에 넣지 않는다.

## 4. MR이 수백 건일 때의 병합 전략

### 권장 설정

- 대상 브랜치: 기능 MR은 `dev`
- 짧은 작업 브랜치 사용, 병합 후 삭제
- Draft MR을 일찍 열어 충돌과 계약 변경을 공유
- 승인과 Pipeline 성공을 병합 조건으로 설정
- `Squash commits`를 기본 또는 필수로 설정
- Squash commit 제목에 Jira Key 유지
- `main`은 EC2 배포 후보 또는 실제 배포 시점에만 갱신

MR마다 버전을 올리거나 Release를 만들지 않는다. MR은 변경 단위이고 Release는 배포 단위다.

### 권장 흐름

```text
Jira Task
  → feature branch
  → Draft MR
  → review·pipeline
  → squash merge to dev
  → 스프린트 시연 후보 확정
  → dev 검증
  → main 병합 및 tag
  → EC2 배포 성공
  → GitLab Release 발행
```

장기간 유지되는 `release/*` 브랜치는 기본적으로 만들지 않는다. 안정화 기간 동안 `dev`에 다음 스프린트 작업이 계속 들어와 분리가 꼭 필요할 때만 짧게 사용한다.

## 5. Jira Release 사용법

Jira의 Version/Release는 해당 버전에 포함될 Issue의 진행률을 보는 계획 도구로 사용한다.

### 지금 권장하는 이름

EC2 전:

```text
C203-S01-DEMO
C203-S02-DEMO
```

EC2 배포 시작 후:

```text
v0.1.0
v0.2.0
v0.2.1
```

- 스프린트 시작 시 Release 후보 하나를 만든다.
- 이번 시연/배포에 반드시 포함할 Issue에만 `Fix Version`을 지정한다.
- 단순 계획 후보는 Backlog에 두고 억지로 Version을 붙이지 않는다.
- 미완료 Issue는 Release를 미루지 말고 다음 Version으로 이동한다.
- 배포/시연 검증이 끝났을 때만 Jira Release를 완료 처리한다.

## 6. Jira Release와 GitLab Release의 차이

| 구분 | Jira Release | GitLab Release |
| --- | --- | --- |
| 목적 | 포함할 업무 계획과 진행률 | 배포된 코드의 불변 스냅샷 |
| 생성 시점 | 스프린트/배포 계획 확정 | Tag 빌드와 배포 검증 성공 후 |
| 연결 대상 | Jira Issue의 Fix Version | Git Tag, 산출물, Release Note |
| EC2 지급 전 | 시연 단위로 선택 사용 | 비활성 |
| EC2 지급 후 | 배포 범위 관리 | 실제 배포 이력 관리 |

두 이름은 가능하면 동일하게 맞춘다. 예: Jira `v0.2.0` ↔ Git Tag `v0.2.0` ↔ GitLab Release `v0.2.0`.

## 7. Flyway 운영 규칙

### 현재 상태

- `flyway-core` 의존성과 표준 migration 경로만 준비한다.
- DB 엔진은 `pending`이다.
- DB가 정해지면 JDBC 드라이버, DB별 Flyway 모듈과 Testcontainers 테스트를 추가한다.
- 초기 Schema는 도메인 모델이 확정된 뒤 `V0001`부터 작성한다.

### 파일명

```text
V<4자리 순번>__<JIRA_KEY>_<설명>.sql
```

예:

```text
V0012__ATH_123_create_member_table.sql
```

### 병렬 MR 충돌 처리

여러 브랜치가 같은 `V0012`를 만들 수 있다. 이를 피하려고 `out-of-order`를 켜지 않는다.

1. DB 변경 MR은 최신 `dev`로 rebase한다.
2. migration의 최대 번호를 확인한다.
3. 충돌한 작업 브랜치 파일을 다음 번호로 변경한다.
4. 깨끗한 로컬/CI DB에 전체 migration을 처음부터 적용한다.
5. 애플리케이션 재기동과 테스트를 확인한 뒤 병합한다.

공유 환경에 적용된 SQL은 절대 번호 변경·수정·삭제하지 않는다. 오류는 새 migration으로 전진 수정한다.

### 안전한 Schema 변경

```text
1차 Release: 새 nullable 컬럼/테이블 추가
2차 Release: 애플리케이션이 새 구조를 함께 사용
3차 Release: 데이터 이관과 검증
4차 Release: 이전 컬럼/코드 제거
```

운영 DB에 Flyway를 수동 실행하지 않는다. EC2와 DB가 준비되면 백업, 권한, 실패 중단, Health Check와 Rollback 절차를 포함한 CI 배포 Job으로만 실행한다.

## 8. 처음에는 자동화하지 않을 것

- MR마다 Jira Release 자동 생성
- MR마다 Semantic Version 증가
- Jira와 GitLab Release의 양방향 자동 동기화
- EC2 미지급 상태에서 Release/Deploy Job 생성
- 운영 DB `clean`, 임의 `repair`, `out-of-order=true`

먼저 1~2개 스프린트를 수동 운영해 실제 부담을 확인한다. 반복 작업이 확인되면 Tag Pipeline에서 GitLab Release Note 생성과 Jira Release 링크 갱신만 자동화한다.

## 9. Jira 생성 시 결정할 항목

- Company-managed 프로젝트 사용 여부: Component를 쓰려면 권장
- 실제 Project Key
- Epic과 Task/Story의 정확한 Issue Type
- Workflow: To Do → In Progress → In Review → Done
- Story Point 필드와 완료 기준
- Release 기능 활성화 여부
- GitLab 개발 정보 연동 가능 여부
- Jira/Notion 중복 기록을 막는 링크 정책

`컨버젼스`가 Confluence를 의미한다면, 현재 프로젝트는 Notion을 지식 원본으로 사용하므로 둘을 동시에 운영하지 않는 것이 좋다. 교육 과정에서 Confluence가 필수일 때만 Notion 문서의 링크 인덱스 역할로 제한한다.
