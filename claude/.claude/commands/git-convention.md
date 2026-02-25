현재 프로젝트의 Git 워크플로우 컨벤션을 분석/설정하여 저장하거나 업데이트한다.

## 저장 위치

`~/.claude/git-conventions/<project-name>.md`
- project-name은 `git remote get-url origin`의 레포명 또는 디렉토리명 사용

## 절차

### 1단계: 프로젝트 상태 판단
1. 컨벤션 파일이 이미 있는지 확인
2. `git log --oneline -1`로 커밋 이력이 있는지 확인
3. 상황에 따라 분기:

   **A) 컨벤션 파일이 이미 있음:**
   - 현재 내용을 표시
   - AskUserQuestion으로 선택: "전체 재분석" / "부분 수정" / "현재 내용 유지"
   - "부분 수정" 선택 시 수정할 섹션을 대화로 확인

   **B) 기존 프로젝트 (커밋 이력 있음):**
   - 2단계(프로젝트 분석)로 진행

   **C) 새 프로젝트 (커밋 이력 없음 또는 매우 적음):**
   - 2단계를 건너뛰고 3단계(컨벤션 설계)로 진행

### 2단계: 프로젝트 분석 (기존 프로젝트일 때)
4. 다음 항목을 분석:

   **브랜치 컨벤션:**
   - `git branch -a`로 기존 브랜치 패턴 분석
   - prefix, 구분자, 이슈 번호 형식, 대소문자 규칙

   **커밋 컨벤션:**
   - `git log --oneline -30`으로 최근 커밋 메시지 패턴 분석
   - type 종류, scope 사용 여부, 언어, 길이 경향

   **PR/MR 컨벤션:**
   - 플랫폼 감지 (GitHub/GitLab)
   - 최근 PR/MR 제목 패턴 확인 (가능한 경우)

5. 분석 결과를 정리하여 표시 → 4단계로

### 3단계: 컨벤션 설계 (새 프로젝트일 때)
6. **AskUserQuestion으로 항목별 컨벤션을 함께 결정**:

   **브랜치:**
   - 패턴 선택: `type/issue-desc`, `type/PROJ-issue-desc`, `issue-desc` 등
   - prefix 종류: `feat/fix/refactor` vs `feature/bugfix` 등

   **커밋:**
   - 형식: Conventional Commits / 자유 형식 / Angular 등
   - scope 사용 여부
   - 언어

   **PR/MR:**
   - 플랫폼: GitHub / GitLab
   - 템플릿 스타일

7. 각 항목은 추천 옵션을 먼저 제시하되 사용자가 원하는 대로 수정 가능

### 4단계: 확인 및 저장
8. 최종 컨벤션을 마크다운으로 정리하여 표시
9. **AskUserQuestion으로 최종 확인** — 수정 요청이 있으면 반영
10. 확정 후 `~/.claude/git-conventions/<project-name>.md`에 저장

## 컨벤션 파일 형식

```markdown
# <project-name> Git Convention

> 이 파일은 `/git-convention` 커맨드로 생성/수정됩니다.
> 다음 커맨드에서 자동으로 참조됩니다:
> - `/branch` — Branch 섹션 (브랜치 네이밍)
> - `/commit` — Commit 섹션 (커밋 메시지 형식)
> - `/pr` — PR/MR 섹션 (제목, 본문 형식)
> 코드 스타일 설정은 `/setup-project`로 CLAUDE.md에서 관리합니다.
> 수정: `/git-convention`을 다시 실행하거나 이 파일을 직접 편집

## Branch
- pattern: `<type>/<issue-number>-<description>`
- types: feat, fix, refactor, docs, chore
- separator: `/`
- case: kebab-case

## Commit
- format: Conventional Commits
- pattern: `<type>(<scope>): <description>`
- language: English
- max-length: 72

## PR/MR
- platform: GitHub | GitLab
- title-pattern: ...
```

## 규칙

- 사용자 확인 없이 파일을 생성/덮어쓰지 않음
- 새 프로젝트에서는 추천값을 제안하되 강제하지 않음
- 분석 데이터가 부족한 항목은 사용자에게 직접 확인
- 코드 스타일은 이 커맨드의 범위 밖 (→ `/setup-project` 사용)

$ARGUMENTS
