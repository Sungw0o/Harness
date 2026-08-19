---
name: pr-check
description: MR 생성 전 변경 범위, 규칙, 테스트, 보안과 문서 누락을 최종 점검할 때 사용한다.
---

## 점검 순서

1. diff가 Issue 목적 하나에 맞고 금지 파일을 포함하지 않는지 확인한다.
2. API·DB·설정 변경에 필요한 계약 문서와 테스트가 있는지 확인한다.
3. `.harness/scripts/quick-check`와 `npm run verify`를 실행한다.
4. MR 템플릿에 변경, 검증, 위험, 미검증 항목과 Notion/Jira 링크를 기록한다.

## 완료 기준

- 실패한 검증을 성공으로 표현하지 않는다.
- 운영 변경과 Secret은 포함하지 않는다.
