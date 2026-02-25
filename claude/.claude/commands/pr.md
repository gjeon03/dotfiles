현재 브랜치의 변경 사항을 분석하고 Pull/Merge Request를 생성한다.

## 플랫폼 감지

`git remote get-url origin`으로 호스트를 확인하여 CLI를 선택한다:
- `github.com` → `gh` CLI
- `gitlab` → `glab` CLI

## 절차

### 0단계: 컨벤션 파일 확인
- `~/.claude/git-conventions/`에서 현재 프로젝트명에 해당하는 컨벤션 파일을 찾는다
- 프로젝트명: `git remote get-url origin`의 레포명 또는 현재 디렉토리명
- **파일이 있으면**: PR/MR 섹션의 컨벤션을 따른다
- **파일이 없으면**: 기본 형식 사용

### 1단계: 분석
1. 플랫폼 감지 (위 규칙)
2. 현재 브랜치와 베이스 브랜치(main/master/develop) 확인
3. 브랜치의 모든 커밋 분석: `git log --oneline <base>..HEAD`
4. 변경된 파일 목록 확인: `git diff --name-only <base>..HEAD`
5. 주요 변경 내용의 diff 확인

### 2단계: 사용자 선택
6. **반드시 AskUserQuestion으로 다음을 제시하고 사용자 승인을 받음**:
   - PR/MR 제목 후보 2~3개 (옵션으로 표시, description에 선택 이유 포함)
   - 사용자는 선택하거나 직접 입력 가능
7. 선택된 제목에 맞춰 Body를 작성하여 표시:
   ```
   ## Summary
   - 변경 사항 요약 (1-3 bullet points)

   ## Changes
   - 변경된 파일과 역할

   ## Test Plan
   - 테스트 방법 체크리스트
   ```
8. Body 내용을 사용자에게 보여주고 수정 요청이 있으면 반영

### 3단계: 실행
9. 리모트에 푸시되지 않았으면 `git push -u origin <branch>`
10. PR/MR 생성:
    - GitHub: `gh pr create`
    - GitLab: `glab mr create`
11. 생성된 PR/MR URL 반환

## 규칙

- 컨벤션 파일의 PR/MR 섹션이 있으면 그 형식을 따름
- 사용자 승인 없이 PR/MR을 생성하지 않음
- Title은 70자 이내

$ARGUMENTS
