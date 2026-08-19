---
name: troubleshooting-record
description: 의미 있는 장애·오류·설계 실패를 로컬 Work Log와 Notion Troubleshooting DB에 재사용 가능한 지식으로 기록할 때 사용한다.
---

## 먼저 읽을 근거

1. `.agent/workflow.md`
2. 해당 Jira Issue와 `.agent/worklogs/{JIRA_KEY}.jsonl`
3. 관련 로그·테스트·MR의 필요한 부분

## 기록 조건

- 10분 이상 해결되지 않은 오류 또는 반복 실패
- 설계·데이터 모델 변경
- 외부 API 제한, 보안·성능·정합성 문제
- 재발 가능성이 있는 CI·운영 문제

## 작업 순서

1. Secret과 개인정보를 제거한다.
2. 증상·재현·환경·실패한 접근·근본 원인·해결·검증·재발 방지를 정리한다.
3. `task-log.py checkpoint`로 핵심 이벤트를 append한다.
4. Notion Troubleshooting DB에 Draft로 생성하거나 기존 항목을 갱신한다.
5. Jira Key, Work Log, MR을 연결하고 검토 후 Reviewed/Resolved로 변경한다.

## 완료 기준

- 원인과 검증이 추측이 아닌 재현 가능한 근거로 작성돼 있다.
- 후속 예방 조치가 Harness, 테스트, CI 또는 Runbook 중 적절한 곳에 반영돼 있다.
