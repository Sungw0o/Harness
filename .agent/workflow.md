# C203 Jira·Notion Agent Workflow

## Source of Truth

- Jira: 활성화 이후 작업 범위와 상태
- Notion: 요구사항, 설계 결정, Work Log와 Troubleshooting 지식
- GitLab: 코드, MR과 Pipeline 결과

## 현재 단계: Bootstrap

- Jira 프로젝트: 미생성
- EC2: 미지급
- 배포: 비활성화
- 허용 범위: 문서, 하네스, 애플리케이션 골격, 로컬 테스트, CI 검증·패키징

Jira 활성화 전에는 `LOCAL-###`을 임시 작업 키로 사용한다. EC2 지급 전에는 배포·Rollback·SSH·운영 Secret 관련 스크립트나 CI Job을 만들거나 실행하지 않는다.

## 작업 시작

1. `.agent/project.yml`에서 Jira 상태를 확인한다.
2. Jira가 `pending`이면 다음 `LOCAL-###` 키를 정하고, `active`이면 유사 Jira Issue를 검색·확정한다.
3. 최신 `dev`에서 `<type>/<WORK_KEY>-<description>` 브랜치를 생성한다.
4. Notion Work Logs DB가 준비된 경우 `[WORK_KEY] 제목` 페이지를 만들고 상태를 `개발 중`으로 둔다.
5. `python scripts/harness/task-log.py start ...`로 로컬 JSONL 로그를 시작한다.

설명이나 단순 코드 읽기만 요청받은 경우에는 작업 키와 Work Log를 만들지 않는다. Jira 활성화 후에는 기존 `LOCAL-###` 기록을 Jira Issue와 연결하되 JSONL 파일을 덮어쓰지 않는다.

## 개발 중 기록

다음 상황을 로컬 로그에 기록하고 의미 있는 체크포인트에서 Notion에 동기화한다.

- 10분 이상 해결되지 않은 오류 또는 같은 접근의 반복 실패
- 설계 방향, 데이터 모델 또는 외부 계약 변경
- 외부 API의 제한·정책·비정상 동작 발견
- 테스트·CI 실패, 보안·성능·정합성 문제
- 임시 해결책이나 기술 부채

단순 오타, 즉시 해결된 import 오류, 최종 결과와 무관한 대화는 기록하지 않는다. Token, Secret, 개인정보, 인증 헤더, DB 비밀번호는 어느 로그에도 남기지 않는다.

## 체크포인트

- 의미 있는 문제 해결 또는 설계 변경 시
- 작업을 중단하기 전
- MR 생성 전
- 작업 완료 시

로컬 JSONL을 먼저 append하고 Notion에는 요약·근거·결정·검증만 반영한다. Notion 호출 실패는 코드 병합을 막지 않지만 로컬 로그에 동기화 대기 상태를 남기고 재시도한다.

## 작업 완료

1. `scripts/harness/verify-all`로 Convention Harness를 실행한다.
2. 로컬 로그에 검증 결과와 남은 위험을 기록한다.
3. Notion Work Log 상태를 `리뷰 중`으로 갱신한다.
4. 재사용 가치가 있는 문제는 Troubleshooting DB에 별도 등록한다.
5. Jira가 활성화된 경우 구현 요약, 테스트, MR, Notion 링크를 기록하고 `In Review`로 변경한다.
6. Jira가 아직 없다면 Jira 반영 대기 항목으로 정리한다.
7. 미해결 문제를 후속 Issue 후보로 분리한다.

## Jira·EC2 전환 조건

### Jira 활성화

1. 프로젝트 URL, 실제 Project Key와 팀 권한을 확인한다.
2. `.agent/project.yml`의 `jira.status`를 `active`, `projectKey`를 실제 값, `requireIssueKey`를 `true`로 바꾼다.
3. `.codex/config.toml`의 Atlassian MCP 설정을 활성화하고 개인 인증을 완료한다.
4. 기존 `LOCAL-###` 작업을 Jira Issue와 연결해 Notion Work Log에 매핑을 기록한다.
5. 이후 새 작업은 Jira Key만 사용한다.

### EC2 지급

1. 인스턴스, OS, 네트워크, 도메인, 배포 계정과 접근 정책을 확인한다.
2. Secret은 GitLab CI Variable 또는 승인된 Secret 저장소에 등록하고 저장소에 넣지 않는다.
3. Docker·Nginx·Health Check·Rollback 설계를 문서와 테스트로 먼저 작성한다.
4. 사용자 승인 후 별도 `infra/<WORK_KEY>-...` 작업에서 배포 Job을 추가한다.
5. Smoke·Readiness·Rollback 검증 후에만 `deploymentEnabled`와 `ciStageEnabled`를 `true`로 바꾼다.
