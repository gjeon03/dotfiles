# Personal Preferences

## Language

- 한국어로 대화한다. 코드, 커밋 메시지, 주석은 영어로 작성한다.

## Code Style

- TypeScript strict mode. Named exports only (Next.js pages/layouts는 default export).
- 2-space indent for JS/TS/JSON/YAML, 4-space for Python.
- Prefer `const` over `let`. Never use `var`.

## Package Manager

- 프로젝트의 lock 파일로 패키지 매니저를 판단한다:
  - `pnpm-lock.yaml` → pnpm
  - `yarn.lock` → yarn
  - `package-lock.json` → npm
- Lock 파일이 없는 새 프로젝트는 pnpm을 사용한다.

## Framework Conventions

- 프로젝트의 기존 설정과 패턴을 우선 따른다.
- 새 프로젝트 기본값:
  - Next.js: App Router, Server Components by default.
  - Tailwind CSS v4: `@import "tailwindcss"`, `@theme` in CSS. No `tailwind.config`.

## Git

- Conventional Commits: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`
- Commit messages in English, concise.
- **NEVER use `--no-verify`**
- **NEVER force push to main/master**
- **NEVER amend published commits**

## Verification

- Run typecheck (`tsc --noEmit` or equivalent) after making changes.
- Run lint and tests before committing.

## Decision Framework

### Autonomous (proceed immediately):

- Fix type errors, lint errors, failing tests
- Single-function implementation with clear spec
- Typos, formatting corrections

### Collaborative (propose first):

- Changes affecting 3+ files
- New features or significant behavior changes
- API or interface modifications
- Dependency additions or upgrades

### Always ask:

- Rewriting working code from scratch
- Changing core business logic
- Anything that could cause data loss
- File deletion or reverting changes

## Task Management

모든 작업은 `~/.claude/tasks/`에 프로젝트별 마크다운으로 기록한다.

### 작업 시작 시
1. `~/.claude/tasks/<project-name>.md` 파일을 읽는다 (없으면 생성)
2. 사용자의 요청을 태스크로 추가한다 (`- [ ]`, created 날짜 포함)
3. 해당 태스크를 진행 중으로 변경한다 (`- [-]`, started 날짜 포함)

### 작업 중
- 태스크가 여러 단계로 나뉘면 하위 항목으로 분리하고 각각 추적한다
- 중간에 새로운 작업이 발견되면 태스크로 추가한다

### 작업 완료 시
- 완료된 태스크를 Done으로 이동한다 (`- [x]`, done 날짜 포함)
- 미완료 태스크가 있으면 Active에 남겨둔다

### 프로젝트명 결정
- `git remote get-url origin`의 레포명 사용
- git이 아니거나 remote가 없으면 현재 디렉토리명 사용
- 프로젝트와 무관한 작업은 `_global.md`에 기록

### 이 규칙은 항상 적용된다
- `/task` 커맨드를 사용하지 않아도 자동으로 수행
- 사용자가 명시적으로 "태스크 관리 하지 마" 라고 하지 않는 한 항상 수행

## Hard Rules

- **NEVER** commit files containing secrets (.env, credentials, API keys)
- **NEVER** delete uncommitted changes without explicit confirmation
- **ALWAYS** read and update task file at start and end of work
