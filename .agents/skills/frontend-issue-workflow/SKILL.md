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
3. React 컴포넌트와 렌더링 테스트를 구현한다.
4. `npm run lint && npm run test && npm run build`를 실행한다.

## 금지사항

- 컴포넌트의 운영 URL·Secret 하드코딩
- 인증 토큰·개인정보의 임의 저장이나 로그 출력
