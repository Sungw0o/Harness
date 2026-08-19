---
name: backend-issue-workflow
description: Spring Boot 백엔드 Issue를 요구사항 확인부터 구현, 테스트, MR 준비까지 진행할 때 사용한다.
---

## 먼저 읽을 근거

1. 루트와 `backend/AGENTS.md`
2. 관련 Notion 요구사항·정책·API 명세
3. Issue와 인접 코드·테스트

## 작업 순서

1. 범위와 완료 조건, API·DB 영향, 실패 경로를 정리한다.
2. `com.c203.app.domain.<domain>` 안에서 구현한다.
3. 정상·실패 경로 테스트를 추가한다.
4. API 변경 시 OpenAPI/계약 테스트, Schema 변경 시 Flyway migration을 함께 반영한다.
5. `./gradlew test bootJar`를 실행한다.

## 완료 기준

- 테스트와 빌드가 통과하고 Secret·운영 설정 변경이 없다.
- MR에 변경, 검증, 위험과 미검증 항목이 기록돼 있다.
