프로젝트별 태스크를 관리한다.

## 저장 위치

`~/.claude/tasks/<project-name>.md`
- project-name: `git remote get-url origin`의 레포명 또는 현재 디렉토리명
- 프로젝트 무관 태스크: `~/.claude/tasks/_global.md`
- 완료 태스크 보관: `~/.claude/tasks/archive/<project-name>-YYYY-MM.md`

## 태스크 파일 형식

```markdown
# <project-name> Tasks

## Active
- [ ] 태스크 설명 (created: 2026-02-25)
  - 진행 메모, 관련 이슈 등
- [-] 진행 중인 태스크 (created: 2026-02-24, started: 2026-02-25)
  - 현재 상태 메모

## Done
- [x] 완료된 태스크 (created: 2026-02-23, done: 2026-02-25)
```

## 사용법

인자에 따라 동작이 달라진다:

### 인자 없음: `/task`
- 현재 프로젝트의 태스크 파일을 읽어 Active 목록을 표시
- 파일이 없으면 생성할지 확인

### 태스크 추가: `/task add 로그인 버그 수정`
- Active 섹션에 새 태스크 추가 (created 날짜 자동)

### 태스크 완료: `/task done 1`
- Active 목록에서 N번째 태스크를 Done으로 이동 (done 날짜 자동)

### 태스크 시작: `/task start 1`
- Active 목록에서 N번째 태스크를 진행 중(`[-]`)으로 변경 (started 날짜 자동)

### 아카이브: `/task archive`
- Done 섹션의 태스크를 `archive/<project-name>-YYYY-MM.md`로 이동
- Done 섹션을 비움

### 글로벌: `/task global`
- `_global.md` 파일의 태스크를 표시
- `/task global add ...` 등 같은 하위 명령 사용 가능

## 절차

1. 인자를 파싱하여 동작 결정
2. `~/.claude/tasks/` 디렉토리가 없으면 생성
3. 해당 프로젝트의 태스크 파일을 읽거나 생성
4. 요청된 동작 수행
5. 변경 시 파일 업데이트

## 규칙

- 태스크 파일은 마크다운 체크박스 형식 유지
- 날짜는 YYYY-MM-DD 형식
- 태스크 번호는 Active 목록에서의 순서 (1부터 시작)
- archive 디렉토리는 필요할 때 자동 생성

$ARGUMENTS
