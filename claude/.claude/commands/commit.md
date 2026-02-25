스마트 커밋을 생성한다.

## 절차

### 0단계: 컨벤션 파일 확인
- `~/.claude/git-conventions/`에서 현재 프로젝트명에 해당하는 컨벤션 파일을 찾는다
- 프로젝트명: `git remote get-url origin`의 레포명 또는 현재 디렉토리명
- **파일이 있으면**: Commit 섹션의 컨벤션을 따른다
- **파일이 없으면**: `git log`에서 커밋 스타일 파악

### 1단계: 분석
1. `git status`와 `git diff HEAD`로 모든 변경 사항 확인
2. 컨벤션 파일이 없으면 `git log --oneline -5`로 최근 커밋 스타일 파악
3. 커밋 전 다음 항목 검사:
   - TODO, FIXME, HACK 주석
   - console.log / print 디버깅 코드
   - 주석 처리된 코드 블록
   - 하드코딩된 테스트 데이터나 placeholder 값
4. 문제 발견 시 보고하고 진행 여부 확인

### 2단계: 사용자 선택
5. 컨벤션에 맞춰 커밋 메시지 후보 3개 생성
6. **반드시 AskUserQuestion으로 선택지를 제시하고 사용자가 선택할 때까지 대기**:
   - 후보 메시지 3개를 옵션으로 표시
   - 각 옵션에 해당 메시지를 선택한 이유를 description으로 포함
   - 사용자는 원하는 메시지를 선택하거나 직접 입력 가능

### 3단계: 실행
7. 관련 파일만 선택적으로 `git add` (git add -A 금지)
8. 선택된 메시지로 `git commit` 실행

## 규칙

- 컨벤션 파일의 Commit 섹션이 있으면 그 형식을 따름
- 컨벤션 파일이 없으면 Conventional Commits 기본값 사용
- 메시지는 영어로 작성
- Co-Authored-By 트레일러 포함하지 않음
- 사용자 선택 없이 자동으로 커밋하지 않음

$ARGUMENTS
