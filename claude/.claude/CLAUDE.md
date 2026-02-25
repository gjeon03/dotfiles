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

## Hard Rules

- **NEVER** commit files containing secrets (.env, credentials, API keys)
- **NEVER** delete uncommitted changes without explicit confirmation
