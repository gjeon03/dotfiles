프로젝트별 태스크를 관리한다.

## 저장 위치

프로젝트 루트의 `tasks/` 디렉토리.

```
tasks/
├── feat-login-bug.md          ← 진행 중 태스크
├── refactor-auth.md
└── done/
    ├── 2026-02-25/
    │   └── feat-login-bug.md  ← 완료 (상태 변경 + 이동)
    └── 2026-02-26/
        └── refactor-auth.md
```

## 태스크 파일 형식 (`tasks/<slug>.md`)

```markdown
# 태스크 제목

- **상태**: 진행 중 | 완료
- **생성**: YYYY-MM-DD
- **완료**: YYYY-MM-DD (완료 시 추가)

## 내용
- 작업 설명, 메모, 관련 이슈 등
```

## 사용법

인자에 따라 동작이 달라진다:

### 인자 없음: `/task`
- `tasks/` 내 진행 중 태스크 파일 목록을 표시
- 디렉토리가 없으면 생성할지 확인

### 태스크 추가: `/task add 로그인 버그 수정`
- `tasks/login-bug-fix.md` 생성 (slug 자동 변환)

### 태스크 완료: `/task done login-bug-fix`
- 파일 상태를 "완료"로 변경, 완료 날짜 추가
- `tasks/done/YYYY-MM-DD/login-bug-fix.md`로 이동

### 목록: `/task list`
- 진행 중 태스크 전체 표시

### 완료 기록: `/task history`
- `tasks/done/` 내 날짜별 디렉토리와 완료된 태스크 표시

## 절차

1. 인자를 파싱하여 동작 결정
2. `tasks/` 디렉토리가 없으면 생성
3. 요청된 동작 수행
4. 변경 시 파일 업데이트

## 규칙

- 파일명은 케밥 케이스 slug (`feat-login-bug.md`)
- 날짜는 YYYY-MM-DD 형식
- `tasks/done/YYYY-MM-DD/` 디렉토리는 필요할 때 자동 생성

$ARGUMENTS
