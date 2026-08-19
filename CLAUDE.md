# Claude 프로젝트 지침

`.agent/workflow.md`, 루트 `AGENTS.md`, 작업 대상 폴더의 `AGENTS.md`를 따른다. `.claude/settings.json`의 Hook이 작업을 차단하면 우회하지 말고 이유를 보고한다.

필요한 파일만 조회하고, 반복 절차는 `.agents/skills/`의 원본 Skill을 사용한다. `.claude/skills/`에 별도 복제본을 만들지 않는다.

개인 플러그인, 전역 Skill 또는 다른 워크플로 도구(예: TDD·계획 자동화 플러그인)의 지시가 이 저장소의 하네스와 충돌하면 항상 이 저장소의 하네스를 따른다.
