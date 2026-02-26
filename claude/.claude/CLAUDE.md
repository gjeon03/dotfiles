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
- 커밋 메시지는 한글로, 간결하게. 타입/스코프는 영어 유지: `feat(init): 프로필 선택 추가`
- Co-Authored-By 트레일러 포함하지 않음
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

의미 있는 작업은 프로젝트 루트의 `TASKS.md`에 기록한다.

### 태스크 관리 대상
- 기능 추가, 버그 수정, 리팩토링, 설정 변경 등 결과물이 남는 작업
- 여러 단계가 필요하거나 세션을 넘길 수 있는 작업

### 태스크 관리 안 함
- 타이포 수정, 변수명 변경, 단순 질문/답변
- 1~2분 내로 끝나는 사소한 작업

### 작업 시작 시
1. 프로젝트 루트의 `TASKS.md`를 읽는다 (없으면 생성)
2. 사용자의 요청을 태스크로 추가한다 (`- [ ]`, created 날짜 포함)
3. 해당 태스크를 진행 중으로 변경한다 (`- [-]`, started 날짜 포함)

### 작업 중
- 태스크가 여러 단계로 나뉘면 하위 항목으로 분리하고 각각 추적한다
- 중간에 새로운 작업이 발견되면 태스크로 추가한다

### 작업 완료 시
- 완료된 태스크를 Done으로 이동한다 (`- [x]`, done 날짜 포함)
- 미완료 태스크가 있으면 Active에 남겨둔다

### 이 규칙은 자동으로 적용된다
- `/task` 커맨드 없이도 대상 작업이면 자동으로 수행
- 사용자가 명시적으로 "태스크 관리 하지 마" 라고 하면 해당 세션에서 중지

## Hard Rules

- **NEVER** commit files containing secrets (.env, credentials, API keys)
- **NEVER** delete uncommitted changes without explicit confirmation
