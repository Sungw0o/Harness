---
name: frontend-issue-workflow
description: React 프런트엔드 Issue를 API 계약 확인부터 구현, 화면 검증, MR 준비까지 진행할 때 사용한다.
---

## 먼저 읽을 근거

1. 루트와 `frontend/AGENTS.md`
2. 화면 정의·사용자 흐름·API 명세
3. 공통 API client와 인접 컴포넌트·테스트

## 작업 순서

1. 로딩·성공·빈 결과·오류 상태와 접근성 기준을 정리한다.
2. API 타입과 공통 client를 먼저 반영한다.
3. 실패하는 렌더링 테스트를 먼저 작성한 뒤 React 컴포넌트를 구현한다.
4. Playwright MCP가 연결돼 있으면 실제 브라우저에서 로딩·성공·빈 결과·오류 상태를 확인한다(프런트 작업 세션에서만 켠다). 연결돼 있지 않으면 렌더링 테스트와 수동 실행으로 4상태를 확인하고 MR에 확인 방법을 기록한다.
5. `npm run lint && npm run test && npm run build`를 실행한다.

## 금지사항

- 컴포넌트의 운영 URL·Secret 하드코딩
- 인증 토큰·개인정보의 임의 저장이나 로그 출력
