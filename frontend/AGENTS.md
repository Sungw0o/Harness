# 프런트엔드 작업 규칙

- React 함수 컴포넌트와 TypeScript를 사용한다.
- API 호출은 `src/api/`의 공통 client를 거치며 컴포넌트에 운영 주소를 하드코딩하지 않는다.
- 인증 토큰과 개인정보를 로그나 `localStorage`에 임의 저장하지 않는다.
- 로딩, 성공, 빈 결과, 오류 상태를 화면에 명시한다.
- API 응답의 공통 `data`와 오류 계약(`error.code`, `traceId`)을 확인한다.
- 새 UI에는 접근 가능한 이름과 키보드 사용성을 제공하고 인접 렌더링 테스트를 작성한다.
- 변경 후 `npm run lint`, `npm run test`, `npm run build`를 실행한다.
