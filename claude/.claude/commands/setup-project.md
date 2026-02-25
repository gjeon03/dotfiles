현재 프로젝트에 맞는 Claude Code 설정 파일을 생성한다.

## 절차

1. 프로젝트 분석:
   - `package.json`, `pubspec.yaml`, `pyproject.toml`, `Cargo.toml` 등으로 프로젝트 타입 파악
   - Lock 파일로 패키지 매니저 확인
   - 기존 스크립트(`scripts` in package.json) 확인
   - 프레임워크 설정 파일 확인 (next.config.*, astro.config.*, angular.json 등)
   - 기존 CLAUDE.md 또는 .claude/ 디렉토리 존재 여부 확인

2. 사용자에게 확인:
   - 감지된 프로젝트 정보 요약 보여주기
   - 추가할 내용이나 특이사항 물어보기

3. 프로젝트 루트에 `CLAUDE.md` 생성. 아래 구조를 따른다:

```markdown
# [프로젝트명]

[package.json 또는 설정 파일에서 파악한 한 줄 설명]

## Commands

- Dev: `[감지된 dev 명령어]`
- Build: `[감지된 build 명령어]`
- Test: `[감지된 test 명령어]`
- Lint: `[감지된 lint 명령어]`
- Typecheck: `[감지된 typecheck 명령어]`

## Architecture

[주요 디렉토리와 역할 — 비자명한 것만]

## Code Standards

[프로젝트 고유 규칙 — 프레임워크/언어 기본값은 제외]

## Gotchas

[발견된 비직관적인 패턴이나 주의사항]
```

4. 필요하면 `.claude/rules/` 디렉토리에 모듈화된 규칙 파일도 생성한다.

5. 생성한 파일 경로와 내용 요약을 보여준다.
