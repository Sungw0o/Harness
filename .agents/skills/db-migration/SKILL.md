---
name: db-migration
description: Entity나 Schema 변경으로 Flyway migration과 호환성 검증이 필요할 때 사용한다.
---

## 작업 순서

1. 현재 Schema와 관련 Entity·쿼리·테스트를 확인한다.
2. 확장 후 축소 원칙으로 하위 호환 가능한 migration을 설계한다.
3. Flyway 파일과 Entity, 통합 테스트를 함께 작성한다.
4. 로컬/테스트 DB에서 적용과 재기동을 검증한다.

## 승인·금지

- 운영 DB 적용, UPDATE·DELETE·DDL 직접 실행은 사전 승인 없이는 금지한다.
- 이미 배포된 migration 파일을 수정하지 않고 새 버전을 추가한다.
