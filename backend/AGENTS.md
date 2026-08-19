# 백엔드 작업 규칙

- 도메인 코드는 `com.c203.app.domain.<domain>` 아래에 도메인 단위로 배치한다.
- `global`에는 공통 설정, 보안, 응답, 예외와 로깅만 두고 비즈니스 로직을 배치하지 않는다.
- Controller는 HTTP 변환, Service는 유스케이스, Domain은 비즈니스 규칙을 담당한다.
- Entity를 API에 직접 노출하지 않고 Request/Response DTO를 분리한다.
- 읽기 작업에는 `@Transactional(readOnly = true)`를 사용한다.
- JPA 연관관계는 단방향과 `LAZY`를 우선하고 운영 환경은 `ddl-auto=validate`를 사용한다.
- API 변경 시 OpenAPI와 계약 테스트를 함께 수정한다.
- 변경 후 `./gradlew test bootJar`를 실행한다.
