---
name: api-contract-sync
description: Controller, DTO 또는 API 경로를 변경해 프런트 타입과 OpenAPI 계약 동기화가 필요할 때 사용한다.
---

## 작업 순서

1. Notion API 명세와 현재 Controller·DTO·프런트 타입의 차이를 확인한다.
2. 성공·실패 응답과 하위 호환성 영향을 정리한다.
3. 백엔드 계약 테스트와 프런트 API 타입/client를 함께 변경한다.
4. 양쪽 test와 build를 실행한다.

## 완료 기준

- 문서, OpenAPI, 백엔드, 프런트 계약이 일치한다.
- Breaking Change라면 버전·호환 기간·마이그레이션 계획이 있다.
