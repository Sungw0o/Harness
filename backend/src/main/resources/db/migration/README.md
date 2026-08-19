# Flyway migration

이 디렉터리는 Flyway SQL migration의 단일 위치다. 현재 DB 엔진이 확정되지 않아 초기 Schema SQL은 만들지 않았다.

## 파일 규칙

```text
V<4자리 순번>__<JIRA_KEY>_<snake_case_description>.sql
```

예시:

```text
V0001__ATH_101_create_member_table.sql
V0002__ATH_115_add_member_status.sql
```

- 새 migration은 작업 브랜치의 최신 `dev`에서 다음 순번을 사용한다.
- 병합 직전 `dev`를 rebase하고 번호 중복 여부를 다시 확인한다.
- 번호가 충돌하면 아직 공유 환경에 적용되지 않은 작업 브랜치 파일만 다음 번호로 변경하고 깨끗한 로컬 DB에서 재검증한다.
- 공유 개발·스테이징·운영 DB에 한 번이라도 적용된 migration은 수정하거나 삭제하지 않는다. 수정이 필요하면 새 버전으로 보정한다.
- `out-of-order`는 사용하지 않는다.
- 파괴적 변경은 확장 후 축소 방식으로 여러 배포에 나눈다.
- 실제 SQL을 추가하는 MR은 빈 DB migration과 애플리케이션 재기동을 검증한다.

DB 엔진이 확정되면 JDBC 드라이버와 해당 엔진용 Flyway 모듈, Testcontainers 기반 통합 테스트를 함께 추가한다.
