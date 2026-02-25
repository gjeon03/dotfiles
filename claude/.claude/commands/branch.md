이슈를 분석하여 브랜치를 생성한다.

## 플랫폼 감지

`git remote get-url origin`으로 호스트를 확인하여 CLI를 선택한다:
- `github.com` → `gh` CLI
- `gitlab` → `glab` CLI

## 절차

### 0단계: 컨벤션 파일 확인
- `~/.claude/git-conventions/`에서 현재 프로젝트명에 해당하는 컨벤션 파일을 찾는다
- 프로젝트명: `git remote get-url origin`의 레포명 또는 현재 디렉토리명
- **파일이 있으면**: Branch 섹션의 컨벤션을 따른다 (1단계 건너뜀)
- **파일이 없으면**: 1단계에서 직접 분석

### 1단계: 컨벤션 파악 (컨벤션 파일이 없을 때만)
1. `git branch -a`로 기존 브랜치 목록 확인
2. 기존 브랜치가 충분히 있으면 (5개 이상) 네이밍 패턴을 분석:
   - 구분자, prefix, 이슈 번호 형식, 대소문자 규칙
3. 기존 브랜치가 부족하면 보편적 컨벤션 사용:
   - 형식: `<type>/<issue-number>-<short-description>`
   - type: `feat`, `fix`, `refactor`, `docs`, `chore`

### 2단계: 이슈 분석
4. 플랫폼 감지 (위 규칙)
5. 이슈 내용 확인:
   - GitHub: `gh issue view $ARGUMENTS`
   - GitLab: `glab issue view $ARGUMENTS`
6. 이슈 제목, 라벨, 설명을 분석하여 작업 유형 판단

### 3단계: 사용자 선택
7. 컨벤션에 맞춰 브랜치명 후보 3개를 생성
8. **AskUserQuestion으로 제시**:
   - 적용한 컨벤션 출처를 간단히 표시 (컨벤션 파일 또는 브랜치 분석)
   - 후보 3개를 옵션으로 표시, 각 옵션에 선택 이유 포함
   - 사용자는 선택하거나 직접 입력 가능

### 4단계: 실행
9. 선택된 이름으로 브랜치 생성 및 체크아웃: `git checkout -b <branch-name>`

## 규칙

- 사용자 선택 없이 브랜치를 생성하지 않음
- 브랜치명에 한국어 사용하지 않음
- 이슈 번호를 반드시 포함
- 컨벤션 파일(`/git-convention`) > 프로젝트 기존 브랜치 > 보편적 컨벤션 순으로 우선

$ARGUMENTS
