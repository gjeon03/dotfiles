프로젝트별 태스크를 관리한다.

## 저장 위치

프로젝트 루트의 `tasks/` 디렉토리.

```
tasks/
├── feat-login-bug.md      ← 진행 중 태스크
├── refactor-auth.md
└── done/
    ├── 2026-02-25.md      ← 날짜별 완료 기록
    └── 2026-02-26.md
```

## 태스크 파일 형식 (`tasks/<slug>.md`)

```markdown
# 태스크 제목

- **상태**: 진행 중
- **생성**: YYYY-MM-DD

## 내용
- 작업 설명, 메모, 관련 이슈 등
```

## 완료 기록 형식 (`tasks/done/YYYY-MM-DD.md`)

```markdown
# YYYY-MM-DD

- [x] 태스크 제목 — 간단한 완료 요약
- [x] 다른 태스크 — 요약
```

## 사용법

인자에 따라 동작이 달라진다:

### 인자 없음: `/task`
- `tasks/` 내 진행 중 태스크 파일 목록을 표시
- 디렉토리가 없으면 생성할지 확인

### 태스크 추가: `/task add 로그인 버그 수정`
- `tasks/login-bug-fix.md` 생성 (slug 자동 변환)

### 태스크 시작: `/task start login-bug-fix`
- 해당 파일의 상태를 "진행 중"으로 변경

### 태스크 완료: `/task done login-bug-fix`
- `tasks/done/YYYY-MM-DD.md`에 완료 항목 추가
- `tasks/login-bug-fix.md` 삭제

### 목록: `/task list`
- 진행 중 태스크 전체 표시

### 완료 기록: `/task history`
- `tasks/done/` 내 최근 날짜별 완료 기록 표시

## 절차

1. 인자를 파싱하여 동작 결정
2. `tasks/` 디렉토리가 없으면 생성
3. 요청된 동작 수행
4. 변경 시 파일 업데이트

## 규칙

- 파일명은 케밥 케이스 slug (`feat-login-bug.md`)
- 날짜는 YYYY-MM-DD 형식
- `tasks/done/` 디렉토리는 필요할 때 자동 생성

$ARGUMENTS
