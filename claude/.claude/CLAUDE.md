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

의미 있는 작업은 프로젝트 루트의 `tasks/` 디렉토리에서 태스크별 파일로 관리한다.

### 구조

```
tasks/
├── feat-login-bug.md              ← 진행 중 태스크
├── refactor-auth.md
└── done/
    ├── 2026-02-25/
    │   └── feat-login-bug.md      ← 완료된 태스크 (상태 변경 + 파일 이동)
    └── 2026-02-26/
        └── refactor-auth.md
```

### 태스크 파일 형식 (`tasks/<slug>.md`)

```markdown
# 태스크 제목

- **상태**: 진행 중 | 완료
- **생성**: 2026-02-26
- **완료**: 2026-02-27 (완료 시 추가)

## 내용
- 작업 설명, 메모, 관련 이슈 등
```

### 태스크 관리 대상
- 기능 추가, 버그 수정, 리팩토링, 설정 변경 등 결과물이 남는 작업
- 여러 단계가 필요하거나 세션을 넘길 수 있는 작업

### 태스크 관리 안 함
- 타이포 수정, 변수명 변경, 단순 질문/답변
- 1~2분 내로 끝나는 사소한 작업

### 작업 시작 시
1. `tasks/` 디렉토리를 확인한다 (없으면 생성)
2. `tasks/<slug>.md` 파일을 생성한다 (slug: 케밥 케이스로 요약)
3. 상태를 "진행 중"으로 기록

### 작업 완료 시
1. 태스크 파일의 상태를 "완료"로, 완료 날짜를 추가한다
2. `tasks/done/YYYY-MM-DD/` 디렉토리로 파일을 이동한다 (디렉토리 없으면 생성)

### 이 규칙은 자동으로 적용된다
- `/task` 커맨드 없이도 대상 작업이면 자동으로 수행
- 사용자가 명시적으로 "태스크 관리 하지 마" 라고 하면 해당 세션에서 중지

## Hard Rules

- **NEVER** commit files containing secrets (.env, credentials, API keys)
- **NEVER** delete uncommitted changes without explicit confirmation
