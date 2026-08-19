---
name: test-coverage
description: 커버리지 게이트(LINE 80%/BRANCH 70%) 미달로 CI가 실패했거나, 새 기능의 테스트를 보강할 때 사용한다.
---

## 먼저 읽을 근거

1. 커버리지 리포트: 프런트 `frontend/coverage/`(vitest --coverage), 백엔드 `backend/build/reports/jacoco/test/html/`
2. 미커버 라인이 속한 코드와 인접 테스트
3. 해당 작업 키의 완료 조건

## 작업 순서

1. 미커버 라인을 확인하고 "가장 위험한 미커버"부터 정한다: 실패 경로, 경계값, 분기.
2. 시나리오 이름이 있는 테스트를 작성한다. 정상 1개당 실패·경계 경로를 우선 추가한다.
3. `npm run test:coverage`(frontend) / `npm --prefix backend run test:coverage`(backend)로 게이트 통과를 확인한다.
4. 게이트 미달이 남으면 남은 미커버가 왜 테스트 불가한지 MR에 기록한다.

## 완료 기준

- 커버리지 상승분이 의미 있는 시나리오로 설명 가능하다.
- assertion 없는 테스트, 구현을 복붙한 mock, 실행만 하고 검증하지 않는 테스트가 없다.

## 금지·승인

- 게이트를 낮추거나 exclude 목록(build.gradle의 coverageExcludes, vite.config.ts의 exclude)을 넓히는 변경은 MR 본문에 사유를 명시하고 리뷰 승인을 받는다.
- 커버리지 수치를 위해 프로덕션 코드를 변경하지 않는다.
